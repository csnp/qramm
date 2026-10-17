#!/usr/bin/env bash
# Tests scripts/check-spec-passwords.sh in and outside a git checkout.
#
# Usage:
#   scripts/test-check-spec-passwords.sh [checker]
#
# checker defaults to check-spec-passwords.sh next to this script. Each case
# copies it into a new temporary directory laid out like the repository
# (scripts/ and toolkit-specs/), so the checker treats that directory as the
# repository root. GIT_CEILING_DIRECTORIES stops git from finding a checkout
# above the temporary directory.
#
# Cases:
#   1. Not a git checkout, no file arguments: exit 1, one FAIL line that says
#      it is not a git checkout and to pass the files as arguments, a
#      RESULT: FAIL line, nothing on stderr, no Python traceback.
#   2. Not a git checkout, the spec file as an argument: exit 0, RESULT: PASS.
#   3. A git checkout with the spec file tracked, no file arguments: exit 0,
#      1 file checked, RESULT: PASS.
#   4-6. Case 1 again with LANG, LC_ALL and LANGUAGE set to German, French
#      and Spanish, so git prints its messages in that language: the same
#      results as case 1. A language is skipped, with a line that says so,
#      when git prints its message untranslated for it on this machine.
#   7. The checker header against the repository's workbooks: at least one
#      .xlsx file is found under toolkit/ and toolkit-specs/, and when none of
#      them has a sheetProtection or workbookProtection element, the header
#      sentence about protection applied without a password starts with "If",
#      so it does not say that the toolkit is protected.
#   8. --help: exit 2, a usage line and then the header text on stderr,
#      nothing on stdout. An unknown option: exit 2, a usage line on stderr.
#   9. An empty file argument: exit 1, "== ''", FAIL file: no file name
#      given, no "not found" line.
#
# The temporary directory is made under .tmp-tests/ at the repository root,
# and the cleanup removes only a directory under it.
#
# Exit status: 0 when every case passes, 1 when any case fails.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
checker="${1:-$here/check-spec-passwords.sh}"
if [ ! -f "$checker" ]; then
  echo "checker not found: $checker" >&2
  exit 1
fi

tmp_root="$(cd "$here/.." && pwd -P)/.tmp-tests"
mkdir -p "$tmp_root"
work="$(mktemp -d "$tmp_root/check-spec-passwords.XXXXXX")"
cleanup() {
  case "$work" in
    "$tmp_root"/?*) rm -rf -- "$work" ;;
    *) exit 1 ;;
  esac
  rmdir "$tmp_root" 2> /dev/null || true
}
trap cleanup EXIT
export GIT_CEILING_DIRECTORIES="$work"

failed=0

# Lays out a copy of the repository at $1 with one spec file that passes.
make_copy() {
  mkdir -p "$1/scripts" "$1/toolkit-specs"
  cp "$checker" "$1/scripts/check-spec-passwords.sh"
  printf '# Spec\n\n- Password: None\n' > "$1/toolkit-specs/spec.md"
}

# Runs the checker in copy $1 with the remaining arguments. Sets out, err
# and status.
run_checker() {
  local copy="$1"
  shift
  status=0
  (cd "$copy" && bash scripts/check-spec-passwords.sh "$@") \
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

# Checks a run with no file arguments in a copy that is not a git checkout.
expect_not_a_checkout() {
  local fail_lines
  fail_lines="$(printf '%s\n' "$out" | grep -c '^FAIL' || true)"
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "one FAIL line" '[ "$fail_lines" -eq 1 ]'
  expect "FAIL line says not a git checkout" \
    'printf "%s\n" "$out" | grep "^FAIL" | grep -q "not a git checkout"'
  expect "FAIL line says to pass the files as arguments" \
    'printf "%s\n" "$out" | grep "^FAIL" | grep -q "pass the files to check as arguments"'
  expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
  expect "stderr is empty" '[ -z "$err" ]'
  expect "no traceback" '! printf "%s\n%s\n" "$out" "$err" | grep -q Traceback'
}

echo "case 1: not a git checkout, no file arguments"
make_copy "$work/plain"
run_checker "$work/plain"
expect_not_a_checkout
[ "$failed" -eq 0 ] || show_output

echo "case 2: not a git checkout, file given as an argument"
case_failed="$failed"
failed=0
run_checker "$work/plain" toolkit-specs/spec.md
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 3: git checkout, no file arguments"
case_failed="$failed"
failed=0
make_copy "$work/checkout"
git -C "$work/checkout" init -q
git -C "$work/checkout" add toolkit-specs/spec.md
run_checker "$work/checkout"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "one file checked" 'printf "%s\n" "$out" | grep -q "^1 files checked"'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

case_number=4
for locale in de_DE.UTF-8 fr_FR.UTF-8 es_ES.UTF-8; do
  language="${locale%%_*}"
  echo "case $case_number: not a git checkout, no file arguments, LANG=$locale"
  case_number=$((case_number + 1))
  probe="$(LANG="$locale" LC_ALL="$locale" LANGUAGE="$language" \
    git -C "$work/plain" ls-files 2>&1 > /dev/null || true)"
  if printf '%s\n' "$probe" | grep -q "not a git repository"; then
    echo "  skip git prints this message untranslated for $locale here"
    continue
  fi
  case_failed="$failed"
  failed=0
  LANG="$locale" LC_ALL="$locale" LANGUAGE="$language" run_checker "$work/plain"
  expect_not_a_checkout
  [ "$failed" -eq 0 ] || show_output
  failed=$((failed | case_failed))
done

echo "case 7: checker header and the repository's workbooks"
case_failed="$failed"
failed=0
repo="$(cd "$here/.." && pwd -P)"
# Prints the number of workbooks found, then the number of sheetProtection
# and workbookProtection elements in their workbook and worksheet parts.
counts="$(python3 -I - "$repo" <<'PY'
import os
import re
import sys
import zipfile

root = sys.argv[1]
part = re.compile(r"xl/workbook\.xml|xl/worksheets/[^/]+\.xml")
element = re.compile(rb"<(?:\w+:)?(?:sheetProtection|workbookProtection)\b")
books = 0
found = 0
for top in ("toolkit", "toolkit-specs"):
    for base, _, names in os.walk(os.path.join(root, top)):
        for name in names:
            if not name.endswith(".xlsx"):
                continue
            books += 1
            with zipfile.ZipFile(os.path.join(base, name)) as book:
                for member in book.namelist():
                    if part.fullmatch(member):
                        found += len(element.findall(book.read(member)))
print(books, found)
PY
)"
books="${counts% *}"
protection="${counts#* }"
# The comment block at the top of the checker, as one line of text.
header="$(sed -n '2,/^set /p' "$checker" | sed -e '/^set /d' -e 's/^#[[:space:]]*//' \
  | tr '\n' ' ' | tr -s ' ')"
sentence="$(printf '%s\n' "$header" | grep -oE '[^.]*applied without a password[^.]*' \
  | head -n 1 | sed 's/^ *//')"
expect "at least one workbook found" '[ "$books" -gt 0 ]'
expect "header has a sentence about protection applied without a password" \
  '[ -n "$sentence" ]'
if [ "$protection" -eq 0 ]; then
  expect "header sentence starts with If while no workbook is protected" \
    'case "$sentence" in "If "*) true ;; *) false ;; esac'
fi
if [ "$failed" -ne 0 ]; then
  echo "  workbooks: $books, protection elements: $protection"
  echo "  header sentence: $sentence"
fi
failed=$((failed | case_failed))

echo "case 8: --help and an unknown option"
case_failed="$failed"
failed=0
run_checker "$work/plain" --help
expect "exit status is 2" '[ "$status" -eq 2 ]'
expect "stderr starts with a usage line" \
  '[ "$(printf "%s\n" "$err" | head -n 1 | cut -c 1-7)" = "usage: " ]'
expect "stderr has the header text" \
  'printf "%s\n" "$err" | grep -qx "Checks that the toolkit specs do not record a password."'
expect "stdout is empty" '[ -z "$out" ]'
[ "$failed" -eq 0 ] || show_output
run_checker "$work/plain" --bogus
expect "an unknown option exits 2" '[ "$status" -eq 2 ]'
expect "stderr has a usage line" 'printf "%s\n" "$err" | grep -q "^usage: "'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 9: an empty file argument"
case_failed="$failed"
failed=0
run_checker "$work/plain" ""
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "the file is shown as ''" 'printf "%s\n" "$out" | grep -qx "== '"''"'"'
expect "FAIL says no file name was given" \
  'printf "%s\n" "$out" | grep -qx "  FAIL file: no file name given"'
expect "no not found line" '! printf "%s\n" "$out" | grep -q "not found"'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
