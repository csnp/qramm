#!/usr/bin/env bash
# Tests scripts/check-published-toolkit.sh against site directories read
# through file:// URLs, so that no case uses the network.
#
# Usage:
#   scripts/test-check-published-toolkit.sh [checker]
#
# checker defaults to check-published-toolkit.sh next to this script. Every
# run passes --base-url with the file:// URL of a site directory laid out
# like qramm.org (toolkit/<workbook>), and the checker compares that site
# with the workbooks in the repository.
#
# Cases:
#   1. A site with byte-identical copies of both workbooks, no workbook
#      arguments: exit 0, a "== <URL> against <path>" line for each workbook
#      that names its file:// URL on the site, two PASS same file lines with
#      the length and sha256 hash of each workbook, RESULT: PASS, nothing on
#      stderr.
#   2. The same site with the last byte of Sample_Assessment.xlsx changed:
#      exit 1, PASS for QRAMM_Assessment_Toolkit.xlsx, a FAIL published copy
#      differs line that gives the length and sha256 hash of the served copy
#      and of the repository's file, RESULT: FAIL, nothing on stderr.
#   3. A site without Sample_Assessment.xlsx: exit 1, a FAIL cannot fetch
#      line with the reason under that workbook, no Python traceback,
#      RESULT: FAIL, nothing on stderr.
#   4. --help and -h: exit 2, the usage line and then the header text on
#      stderr, nothing on stdout.
#   5. Two unknown options, --bogus and --json: exit 2, and on stderr
#      "unknown option: --bogus", "unknown option: --json" and then the
#      usage line, each on a line of its own; nothing on stdout.
#   6. An empty workbook argument: exit 1, "== ''", FAIL file: no file name
#      given, no "not found" line, RESULT: FAIL.
#   7. A workbook path in the repository that does not exist: exit 1, FAIL
#      file: not found, no cannot fetch line, RESULT: FAIL.
#   8. Where the fixtures were written: the directory is under .tmp-tests/
#      at the repository root and holds the site of case 1, and it is gone
#      after the cleanup runs.
#
# The temporary directory is made under .tmp-tests/ at the repository root,
# and the cleanup removes only a directory under it.
#
# Exit status: 0 when every case passes, 1 when any case fails.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
repo="$(cd "$here/.." && pwd -P)"
checker="${1:-$here/check-published-toolkit.sh}"
if [ ! -f "$checker" ]; then
  echo "checker not found: $checker" >&2
  exit 1
fi

tmp_root="$repo/.tmp-tests"
mkdir -p "$tmp_root"
work="$(mktemp -d "$tmp_root/check-published-toolkit.XXXXXX")"
cleanup() {
  case "$work" in
    "$tmp_root"/?*) rm -rf -- "$work" ;;
    *) exit 1 ;;
  esac
  rmdir "$tmp_root" 2> /dev/null || true
}
trap cleanup EXIT

failed=0

toolkit="toolkit/QRAMM_Assessment_Toolkit.xlsx"
sample="toolkit/Sample_Assessment.xlsx"
usage="usage: bash scripts/check-published-toolkit.sh [--base-url URL] [workbook ...]"

# Prints the file:// URL of directory $1.
file_url() {
  python3 -I -c 'import pathlib, sys; print(pathlib.Path(sys.argv[1]).as_uri())' "$1"
}

# Prints "<length> bytes, sha256 <hash>" for file $1, the way the checker
# describes a file.
describe() {
  python3 -I - "$1" <<'PY'
import hashlib
import sys

with open(sys.argv[1], "rb") as fh:
    data = fh.read()
print("{} bytes, sha256 {}".format(len(data), hashlib.sha256(data).hexdigest()))
PY
}

# Changes the last byte of file $1 and keeps its length.
change_last_byte() {
  python3 -I - "$1" <<'PY'
import sys

with open(sys.argv[1], "r+b") as fh:
    fh.seek(-1, 2)
    last = fh.read(1)[0]
    fh.seek(-1, 2)
    fh.write(bytes([last ^ 0xFF]))
PY
}

# Lays out a site directory at $1 with a copy of each remaining argument, a
# workbook path relative to the repository root.
make_site() {
  local site="$1" name
  shift
  mkdir -p "$site/toolkit"
  for name in "$@"; do
    cp "$repo/$name" "$site/$name"
  done
}

# Runs the checker with --base-url set to the file:// URL of site directory
# $1 and the remaining arguments. Sets out, err and status.
run_checker() {
  local site="$1"
  shift
  status=0
  bash "$checker" --base-url "$(file_url "$site")" "$@" \
    > "$work/out" 2> "$work/err" || status=$?
  out="$(cat "$work/out")"
  err="$(cat "$work/err")"
}

expect() {
  local name="$1" condition="$2"
  if eval "$condition"; then
    echo "  ok   $name"
  else
    echo "  FAIL $name"
    failed=1
  fi
}

show_output() {
  echo "  -- stdout --"
  printf '%s\n' "$out" | sed 's/^/  /'
  echo "  -- stderr --"
  printf '%s\n' "$err" | sed 's/^/  /'
}

echo "case 1: a site with identical copies of both workbooks"
case_failed="$failed"
failed=0
make_site "$work/site" "$toolkit" "$sample"
site_url="$(file_url "$work/site")"
run_checker "$work/site"
toolkit_head="== $site_url/$toolkit against $toolkit"
sample_head="== $site_url/$sample against $sample"
toolkit_pass="  PASS same file ($(describe "$repo/$toolkit"))"
sample_pass="  PASS same file ($(describe "$repo/$sample"))"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "the toolkit line names its file:// URL on the site" \
  'printf "%s\n" "$out" | grep -qxF "$toolkit_head"'
expect "the sample line names its file:// URL on the site" \
  'printf "%s\n" "$out" | grep -qxF "$sample_head"'
expect "two PASS lines" '[ "$(printf "%s\n" "$out" | grep -c "^  PASS ")" -eq 2 ]'
expect "PASS line gives the toolkit length and sha256 hash" \
  'printf "%s\n" "$out" | grep -qxF "$toolkit_pass"'
expect "PASS line gives the sample length and sha256 hash" \
  'printf "%s\n" "$out" | grep -qxF "$sample_pass"'
expect "no FAIL line" '! printf "%s\n" "$out" | grep -q "FAIL"'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
expect "stderr is empty" '[ -z "$err" ]'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 2: one byte of the served sample changed"
case_failed="$failed"
failed=0
make_site "$work/changed" "$toolkit" "$sample"
change_last_byte "$work/changed/$sample"
served="$(describe "$work/changed/$sample")"
tracked="$(describe "$repo/$sample")"
differs="  FAIL published copy differs: served $served; repository $tracked"
run_checker "$work/changed"
after_sample="$(printf '%s\n' "$out" \
  | grep -A 1 -xF "== $(file_url "$work/changed")/$sample against $sample" | tail -n 1 \
  || true)"
expect "the changed copy has the same length and another hash" \
  '[ "${served%%,*}" = "${tracked%%,*}" ] && [ "$served" != "$tracked" ]'
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "PASS line for the toolkit" 'printf "%s\n" "$out" | grep -qxF "$toolkit_pass"'
expect "FAIL line gives both lengths and both sha256 hashes" \
  'printf "%s\n" "$out" | grep -qxF "$differs"'
expect "the FAIL line is under the sample line" '[ "$after_sample" = "$differs" ]'
expect "one FAIL line" '[ "$(printf "%s\n" "$out" | grep -c "^  FAIL ")" -eq 1 ]'
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
expect "stderr is empty" '[ -z "$err" ]'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 3: the served sample is missing"
case_failed="$failed"
failed=0
make_site "$work/partial" "$toolkit"
run_checker "$work/partial"
after_sample="$(printf '%s\n' "$out" \
  | grep -A 1 -xF "== $(file_url "$work/partial")/$sample against $sample" | tail -n 1 \
  || true)"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "PASS line for the toolkit" 'printf "%s\n" "$out" | grep -qxF "$toolkit_pass"'
expect "FAIL cannot fetch, with a reason, under the sample line" \
  'case "$after_sample" in "  FAIL cannot fetch ("?*")") true ;; *) false ;; esac'
expect "one FAIL line" '[ "$(printf "%s\n" "$out" | grep -c "^  FAIL ")" -eq 1 ]'
expect "no traceback" '! printf "%s\n%s\n" "$out" "$err" | grep -q Traceback'
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
expect "stderr is empty" '[ -z "$err" ]'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 4: --help and -h"
case_failed="$failed"
failed=0
for option in --help -h; do
  run_checker "$work/site" "$option"
  expect "$option exits 2" '[ "$status" -eq 2 ]'
  expect "$option prints the usage line first on stderr" \
    '[ "$(printf "%s\n" "$err" | head -n 1)" = "$usage" ]'
  expect "$option prints the header text after it" \
    '[ "$(printf "%s\n" "$err" | sed -n 3p)" = "Checks that qramm.org serves the same toolkit workbooks as this repository." ]'
  expect "$option prints the exit status text" \
    'printf "%s\n" "$err" | grep -qx "Exit status: 0 when every check passes, 1 when any check fails, 2 on a"'
  expect "$option prints nothing on stdout" '[ -z "$out" ]'
  [ "$failed" -eq 0 ] || show_output
done
failed=$((failed | case_failed))

echo "case 5: two unknown options"
case_failed="$failed"
failed=0
run_checker "$work/site" --bogus --json
expected="$(printf '%s\n' "unknown option: --bogus" "unknown option: --json" "$usage")"
expect "exit status is 2" '[ "$status" -eq 2 ]'
expect "stderr names each option on a line of its own, then the usage line" \
  '[ "$err" = "$expected" ]'
expect "no joined line" '! printf "%s\n" "$err" | grep -q "unknown option: --bogus --json"'
expect "stdout is empty" '[ -z "$out" ]'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 6: an empty workbook argument"
case_failed="$failed"
failed=0
run_checker "$work/site" ""
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "the workbook is shown as ''" 'printf "%s\n" "$out" | grep -qx "== '"''"'"'
expect "FAIL says no file name was given" \
  'printf "%s\n" "$out" | grep -qx "  FAIL file: no file name given"'
expect "no not found line" '! printf "%s\n" "$out" | grep -q "not found"'
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 7: a workbook path that does not exist"
case_failed="$failed"
failed=0
run_checker "$work/site" toolkit/No_Such_Workbook.xlsx
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL file: not found" 'printf "%s\n" "$out" | grep -qx "  FAIL file: not found"'
expect "no cannot fetch line" '! printf "%s\n" "$out" | grep -q "cannot fetch"'
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 8: where the fixtures were written"
case_failed="$failed"
failed=0
expect "fixtures directory is under .tmp-tests/ at the repository root" \
  'case "$work" in "$repo"/.tmp-tests/?*) true ;; *) false ;; esac'
expect "the site of case 1 is in it" '[ -f "$work/site/$toolkit" ] && [ -f "$work/site/$sample" ]'
cleanup
expect "the fixtures directory is gone after the cleanup" '[ ! -e "$work" ]'
[ "$failed" -eq 0 ] || echo "  -- fixtures directory: $work"
failed=$((failed | case_failed))

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
