#!/usr/bin/env bash
# Tests the nist check of scripts/check-framework-docs.sh.
#
# Usage:
#   scripts/test-check-framework-docs.sh [checker]
#
# checker defaults to check-framework-docs.sh next to this script. Every run
# passes --no-network. Fixtures are written to a new temporary directory and
# given to the checker by absolute path.
#
# Cases:
#   1. A compliance-mapping.md whose NIST PQC cell is "NIST Testing Guide":
#      exit 1, FAIL nist, a line that names the question and the label,
#      RESULT: FAIL.
#   2. A compliance-mapping.md whose NIST PQC cells are "-", FIPS 203,
#      NIST SP 800-131A Rev. 2, NIST IR 8547 (initial public draft) and
#      OMB M-23-02: exit 0, PASS nist with 5 question rows, 1 with '-'.
#   3. A compliance-mapping.md with a NIST PQC column and no question rows:
#      exit 1, FAIL nist, "no question rows".
#   4. A file with another name and the same label as case 1: exit 0, no
#      nist line.
#   5. The repository's framework/compliance-mapping.md: exit 0, PASS nist.
#   6. --help: exit 2, a usage line and then the header text on stderr,
#      nothing on stdout. Two unknown options, --bogus and --json: exit 2,
#      and on stderr "unknown option: --bogus", "unknown option: --json"
#      and the usage line.
#   7. An empty file argument: exit 1, "== ''", FAIL file: no file name
#      given, no "not found" line.
#   8. A file whose bytes are not UTF-8: exit 1, the file's == line and then
#      FAIL file: cannot read (not UTF-8 text), RESULT: FAIL, nothing on
#      stderr, no Python traceback.
#   9. A directory: exit 1, the directory's == line and then FAIL file: is a
#      directory, no "not found" line, RESULT: FAIL, nothing on stderr.
#
# The temporary directory is made under .tmp-tests/ at the repository root,
# and the cleanup removes only a directory under it.
#
# Exit status: 0 when every case passes, 1 when any case fails.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
checker="${1:-$here/check-framework-docs.sh}"
if [ ! -f "$checker" ]; then
  echo "checker not found: $checker" >&2
  exit 1
fi
repo_doc="$(cd "$here/.." && pwd -P)/framework/compliance-mapping.md"

tmp_root="$(cd "$here/.." && pwd -P)/.tmp-tests"
mkdir -p "$tmp_root"
work="$(mktemp -d "$tmp_root/check-framework-docs.XXXXXX")"
cleanup() {
  case "$work" in
    "$tmp_root"/?*) rm -rf -- "$work" ;;
    *) exit 1 ;;
  esac
  rmdir "$tmp_root" 2> /dev/null || true
}
trap cleanup EXIT

failed=0

# Writes a mapping table to $1 with one question row per remaining argument,
# each argument being that row's NIST PQC cell.
write_mapping() {
  local file="$1" n=0 cell
  shift
  mkdir -p "$(dirname "$file")"
  {
    printf '# Mapping\n\n'
    printf '| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |\n'
    printf '|----------------|----------|----------|---------|--------|\n'
    for cell in "$@"; do
      n=$((n + 1))
      printf '| **Q1.1.%d**: A question? | %s | - | CM-8 | NIST SP 800-53 CM-8 |\n' \
        "$n" "$cell"
    done
  } > "$file"
}

# Runs the checker on the given files. Sets out, err and status.
run_checker() {
  status=0
  bash "$checker" --no-network "$@" > "$work/out" 2> "$work/err" || status=$?
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

echo "case 1: a NIST PQC label with no publication number"
write_mapping "$work/bad/compliance-mapping.md" "NIST Testing Guide"
run_checker "$work/bad/compliance-mapping.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "nist check fails" 'printf "%s\n" "$out" | grep -q "^  FAIL nist"'
expect "problem names the question and the label" \
  'printf "%s\n" "$out" | grep -q "Q1.1.1 NIST PQC cell .NIST Testing Guide. names no publication number"'
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
expect "stderr is empty" '[ -z "$err" ]'
[ "$failed" -eq 0 ] || show_output

echo "case 2: '-' and publication numbers"
case_failed="$failed"
failed=0
write_mapping "$work/good/compliance-mapping.md" "-" "FIPS 203" \
  "NIST SP 800-131A Rev. 2" "NIST IR 8547 (initial public draft)" "OMB M-23-02"
run_checker "$work/good/compliance-mapping.md"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "nist check passes with 5 rows, 1 with '-'" \
  'printf "%s\n" "$out" | grep -qx "  PASS nist (5 question rows, 1 with '"'"'-'"'"')"'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 3: a NIST PQC column with no question rows"
case_failed="$failed"
failed=0
write_mapping "$work/empty/compliance-mapping.md"
run_checker "$work/empty/compliance-mapping.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "nist check says there are no question rows" \
  'printf "%s\n" "$out" | grep -q "no question rows under a .NIST PQC. column"'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 4: another file name is not given the nist check"
case_failed="$failed"
failed=0
write_mapping "$work/other/other.md" "NIST Testing Guide"
run_checker "$work/other/other.md"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "no nist line" '! printf "%s\n" "$out" | grep -q " nist"'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 5: the repository's compliance mapping"
case_failed="$failed"
failed=0
run_checker "$repo_doc"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "nist check passes" 'printf "%s\n" "$out" | grep -q "^  PASS nist"'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 6: --help and an unknown option"
case_failed="$failed"
failed=0
run_checker --help
expect "exit status is 2" '[ "$status" -eq 2 ]'
expect "stderr starts with a usage line" \
  '[ "$(printf "%s\n" "$err" | head -n 1 | cut -c 1-7)" = "usage: " ]'
expect "stderr has the header text" \
  'printf "%s\n" "$err" | grep -qx "Checks QRAMM framework documents before they are merged."'
expect "stdout is empty" '[ -z "$out" ]'
[ "$failed" -eq 0 ] || show_output
run_checker --bogus --json
expect "an unknown option exits 2" '[ "$status" -eq 2 ]'
expected="$(printf '%s\n' "unknown option: --bogus" "unknown option: --json" \
  "usage: bash scripts/check-framework-docs.sh [--no-network] [file ...]")"
expect "stderr names each option on a line of its own, then the usage line" \
  '[ "$err" = "$expected" ]'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 7: an empty file argument"
case_failed="$failed"
failed=0
run_checker ""
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "the file is shown as ''" 'printf "%s\n" "$out" | grep -qx "== '"''"'"'
expect "FAIL says no file name was given" \
  'printf "%s\n" "$out" | grep -qx "  FAIL file: no file name given"'
expect "no not found line" '! printf "%s\n" "$out" | grep -q "not found"'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 8: a file that is not UTF-8"
case_failed="$failed"
failed=0
mkdir -p "$work/latin1"
# \307\377 are the bytes 0xc7 and 0xff, which are not valid UTF-8.
printf '# Notes\n\n\307\377\n' > "$work/latin1/notes.md"
run_checker "$work/latin1/notes.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line follows the file's == line and says it is not UTF-8 text" \
  '[ "$(printf "%s\n" "$out" | grep -A 1 "^== .*/latin1/notes\.md$" | tail -n 1)" = "  FAIL file: cannot read (not UTF-8 text)" ]'
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
expect "stderr is empty" '[ -z "$err" ]'
expect "no traceback" '! printf "%s\n%s\n" "$out" "$err" | grep -q Traceback'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 9: a directory"
case_failed="$failed"
failed=0
mkdir -p "$work/folder"
run_checker "$work/folder"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line follows the directory's == line and says it is a directory" \
  '[ "$(printf "%s\n" "$out" | grep -A 1 "^== .*/folder$" | tail -n 1)" = "  FAIL file: is a directory" ]'
expect "no not found line" '! printf "%s\n" "$out" | grep -q "not found"'
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
expect "stderr is empty" '[ -z "$err" ]'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
