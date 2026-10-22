#!/usr/bin/env bash
# Tests scripts/check-spec-passwords.sh in and outside a git checkout, and the
# shapes of a password line that it recognises.
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
#   8-13. A spec file whose line 3 records the value FAKE-1234 as
#      "- password=FAKE-1234", after "- Password" and a fullwidth colon
#      (U+FF1A) or a fullwidth equals sign (U+FF1D), in the sentences "The
#      sheet password is set to FAKE-1234." and "The workbook password was
#      set to FAKE-1234.", and after None in "The sheet password is set to
#      None and the workbook password is set to FAKE-1234.": exit 1, one
#      problem line, which names line 3, RESULT: FAIL, nothing on stderr,
#      and FAKE-1234 printed nowhere.
#   14. A spec file with the value None after "Password:" and in each shape
#      of cases 8 to 12, and the sentence "Protect each sheet without a
#      password, allowing users to:": exit 0, the summary line "1 files
#      checked, 6 Password lines found, 1 other lines say there is no
#      password", RESULT: PASS, nothing on stderr.
#   15. --help: exit 2, a usage line and then the header text on stderr,
#      nothing on stdout. Two unknown options, --bogus and --json: exit 2,
#      and on stderr "unknown option: --bogus", "unknown option: --json"
#      and the usage line.
#   16. An empty file argument: exit 1, "== ''", FAIL file: no file name
#      given, no "not found" line.
#   17. A spec file whose bytes are not UTF-8: exit 1, the file's == line
#      and then FAIL file: cannot read (not UTF-8 text), RESULT: FAIL,
#      nothing on stderr, no Python traceback.
#   18. A directory: exit 1, the directory's == line and then FAIL file: is
#      a directory, no "not found" line, RESULT: FAIL, nothing on stderr.
#   19-27. Line 3 records FAKE-1234 after "Passphrase:", "Passcode:",
#      "- pwd:", "Unlock with:", "- Password" and an en dash (U+2013) or an
#      em dash (U+2014), "Password" in fullwidth letters and a fullwidth
#      colon, "- Pass" and "word:" with a zero width space (U+200B) between
#      them, and "Protected without a password:": the same results as cases
#      8 to 13.
#   28-33. Line 3 mentions a password in no recognised shape: "The sheet
#      password is FAKE-1234", "Sheet password FAKE-1234", the table row
#      "| Password | FAKE-1234 |", "No password on the sheets. Workbook
#      password FAKE-1234", "Sheet password FAKE-1234; Password: None" and
#      "The sheets are not password-protected.": exit 1, one problem line,
#      which names line 3 and says to write "Password: None", or "without a
#      password", RESULT: FAIL, nothing on stderr, and FAKE-1234 printed
#      nowhere.
#   34. A spec file with "- Password: None", "- Password", an en dash and
#      None, "No passwords are recorded.", "Protect each sheet without a
#      password, allowing users to:", "The sheets are protected without a
#      password.", the code line cd "$(pwd)" and "Unlock with the Review
#      tab.": exit 0, the summary line "1 files checked, 2 Password lines
#      found, 3 other lines say there is no password", RESULT: PASS, nothing
#      on stderr.
#   35. The checker header names every word, separator, sentence form and
#      "no password" form that its patterns are built from.
#   36-40. Line 3 records, after "- Password:", None followed by FAKE-1234
#      spelt in Unicode tag characters (U+E0000 to U+E007F), None with a
#      zero width space (U+200B) or a soft hyphen (U+00AD) inside it, None
#      in fullwidth letters, and a zero width space right after the colon,
#      then a space and None: the same results as cases 8 to 13.
#   41. A spec file with None after "- Pass" and "word:" with a zero width
#      space between them, after "- Password", a zero width space and a
#      colon, after "Password" in fullwidth letters and a fullwidth colon,
#      and in "**Password:** `None`": exit 0, the summary line "1 files
#      checked, 4 Password lines found, 0 other lines say there is no
#      password", RESULT: PASS, nothing on stderr.
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

# The value that cases 8 to 13 record. The checker must never print it.
value="FAKE-1234"
# U+FF1A FULLWIDTH COLON and U+FF1D FULLWIDTH EQUALS SIGN, written as their
# UTF-8 bytes so this script stays ASCII.
fullwidth_colon="$(printf '\357\274\232')"
fullwidth_equals="$(printf '\357\274\235')"
# U+2013 EN DASH, U+2014 EM DASH and U+200B ZERO WIDTH SPACE (a format
# character), and "Password" in fullwidth letters (U+FF30 and on).
en_dash="$(printf '\342\200\223')"
em_dash="$(printf '\342\200\224')"
zero_width_space="$(printf '\342\200\213')"
fullwidth_password="$(python3 -I -c \
  'print("".join(chr(ord(c) + 0xFEE0) for c in "Password"))')"
# U+00AD SOFT HYPHEN (a format character), "None" in fullwidth letters, and
# FAKE-1234 spelt in Unicode tag characters (U+E0000 to U+E007F, format
# characters that are not drawn).
soft_hyphen="$(printf '\302\255')"
fullwidth_none="$(python3 -I -c \
  'print("".join(chr(ord(c) + 0xFEE0) for c in "None"))')"
tagged_value="$(python3 -I -c \
  'import sys; print("".join(chr(0xE0000 + ord(c)) for c in sys.argv[1]))' \
  "$value")"

# The problem lines the checker prints, without the line number.
value_problem="Password line has a value other than None (value not shown)"
shape_problem='mentions a password in no recognised shape (text not shown); write "Password: None", or "without a password"'

# Runs the checker on a spec file whose lines are the remaining arguments,
# in a new copy at $1 that is not a git checkout.
run_on_lines() {
  local copy="$1"
  shift
  make_copy "$copy"
  printf '%s\n' "$@" > "$copy/toolkit-specs/spec.md"
  run_checker "$copy" toolkit-specs/spec.md
}

# Checks a run on a spec file in which line $1, and no other line, fails
# with the problem text $2: by default, that it records a password with a
# value other than None.
expect_line_fails() {
  local number="$1" problem="${2:-$value_problem}" problems
  problems="$(printf '%s\n' "$out" | grep -c '^    line ' || true)"
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "one problem line" '[ "$problems" -eq 1 ]'
  expect "problem line names line $number: $problem" \
    'printf "%s\n" "$out" | grep -qF "    line $number: $problem"'
  expect "value not printed" '! printf "%s\n%s\n" "$out" "$err" | grep -qF "$value"'
  expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
  expect "stderr is empty" '[ -z "$err" ]'
}

# Runs the next case on a spec file whose line 3 is $2, a line that records
# the value FAKE-1234. $1 describes the line for the case heading. $3, when
# given, is the problem text expected in place of the value problem.
check_failing_line() {
  echo "case $case_number: $1 on line 3"
  case_failed="$failed"
  failed=0
  run_on_lines "$work/case$case_number" "# Spec" "" "$2"
  expect_line_fails 3 "${3:-}"
  [ "$failed" -eq 0 ] || show_output
  failed=$((failed | case_failed))
  case_number=$((case_number + 1))
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

case_number=8
check_failing_line "password=" "- password=$value"
check_failing_line "fullwidth colon (U+FF1A)" "- Password${fullwidth_colon}$value"
check_failing_line "fullwidth equals sign (U+FF1D)" "- Password${fullwidth_equals}$value"
check_failing_line "password is set to" "The sheet password is set to $value."
check_failing_line "password was set to" "The workbook password was set to $value."
check_failing_line "a value after None" \
  "The sheet password is set to None and the workbook password is set to $value."

echo "case $case_number: None in every shape, and a sentence without a password"
case_failed="$failed"
failed=0
run_on_lines "$work/case$case_number" "# Spec" "" \
  "- Password: None" \
  "- password=None" \
  "- Password${fullwidth_colon}None" \
  "- Password${fullwidth_equals}None" \
  "The sheet password is set to None" \
  'The workbook password was set to `None`' \
  "Protect each sheet without a password, allowing users to:"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "summary line counts 6 Password lines and 1 other line" \
  'printf "%s\n" "$out" | grep -qxF "1 files checked, 6 Password lines found, 1 other lines say there is no password"'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
expect "stderr is empty" '[ -z "$err" ]'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 15: --help and an unknown option"
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
run_checker "$work/plain" --bogus --json
expect "an unknown option exits 2" '[ "$status" -eq 2 ]'
expected="$(printf '%s\n' "unknown option: --bogus" "unknown option: --json" \
  "usage: bash scripts/check-spec-passwords.sh [file ...]")"
expect "stderr names each option on a line of its own, then the usage line" \
  '[ "$err" = "$expected" ]'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 16: an empty file argument"
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

echo "case 17: a spec file that is not UTF-8"
case_failed="$failed"
failed=0
make_copy "$work/case17"
# \307\377 are the bytes 0xc7 and 0xff, which are not valid UTF-8.
printf '# Spec\n\n\307\377\n' > "$work/case17/toolkit-specs/latin1.md"
run_checker "$work/case17" toolkit-specs/latin1.md
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line follows the file's == line and says it is not UTF-8 text" \
  '[ "$(printf "%s\n" "$out" | grep -A 1 -x "== toolkit-specs/latin1.md" | tail -n 1)" = "  FAIL file: cannot read (not UTF-8 text)" ]'
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
expect "stderr is empty" '[ -z "$err" ]'
expect "no traceback" '! printf "%s\n%s\n" "$out" "$err" | grep -q Traceback'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 18: a directory"
case_failed="$failed"
failed=0
run_checker "$work/plain" toolkit-specs
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line follows the directory's == line and says it is a directory" \
  '[ "$(printf "%s\n" "$out" | grep -A 1 -x "== toolkit-specs" | tail -n 1)" = "  FAIL file: is a directory" ]'
expect "no not found line" '! printf "%s\n" "$out" | grep -q "not found"'
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
expect "stderr is empty" '[ -z "$err" ]'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

case_number=19
check_failing_line "Passphrase:" "Passphrase: $value"
check_failing_line "Passcode:" "Passcode: $value"
check_failing_line "pwd:" "- pwd: $value"
check_failing_line "Unlock with:" "Unlock with: $value"
check_failing_line "Password and an en dash (U+2013)" "- Password ${en_dash} $value"
check_failing_line "Password and an em dash (U+2014)" "- Password${em_dash}$value"
check_failing_line "Password in fullwidth letters and a fullwidth colon" \
  "${fullwidth_password}${fullwidth_colon}$value"
check_failing_line "Password with a zero width space (U+200B) inside" \
  "- Pass${zero_width_space}word: $value"
check_failing_line "without a password and a value" \
  "Protected without a password: $value"
check_failing_line "password is and a value" "The sheet password is $value" \
  "$shape_problem"
check_failing_line "password and a value" "Sheet password $value" \
  "$shape_problem"
check_failing_line "a table row" "| Password | $value |" "$shape_problem"
check_failing_line "no password, then a password with a value" \
  "No password on the sheets. Workbook password $value" "$shape_problem"
check_failing_line "a password with a value before Password: None" \
  "Sheet password $value; Password: None" "$shape_problem"
check_failing_line "not password-protected" \
  "The sheets are not password-protected." "$shape_problem"

echo "case $case_number: None, no password, and words with ordinary uses"
case_failed="$failed"
failed=0
run_on_lines "$work/case$case_number" "# Spec" "" \
  "- Password: None" \
  "- Password ${en_dash} None" \
  "No passwords are recorded." \
  "Protect each sheet without a password, allowing users to:" \
  "The sheets are protected without a password." \
  '    cd "$(pwd)"' \
  "Unlock with the Review tab."
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "summary line counts 2 Password lines and 3 other lines" \
  'printf "%s\n" "$out" | grep -qxF "1 files checked, 2 Password lines found, 3 other lines say there is no password"'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
expect "stderr is empty" '[ -z "$err" ]'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))
case_number=$((case_number + 1))

echo "case $case_number: the header names every word, separator and form"
case_failed="$failed"
failed=0
# The Python part of the checker, run without its last line, prints each
# entry of the lists its patterns are built from as the header writes it.
named="$({
  awk '/<<'"'"'PY'"'"'$/ { inside = 1; next } /^PY$/ { inside = 0 } inside' \
    "$checker" | grep -v '^sys\.exit(main('
  cat <<'PY'
for word in WORDS + GUARDED_WORDS + SENTENCE_FORMS:
    print('"{}"'.format(word))
for sep in SEPARATORS:
    print("({})".format(sep if sep.isascii() else "U+{:04X}".format(ord(sep))))
for form in NO_PASSWORD_FORMS:
    print('"{}"'.format(form.format("password")))
PY
} | python3 -I -)" || named=""
expect "the checker lists words, separators and forms" '[ -n "$named" ]'
if [ -n "$named" ]; then
  while IFS= read -r entry; do
    expect "header names $entry" 'printf "%s\n" "$header" | grep -qF -- "$entry"'
  done <<< "$named"
fi
[ "$failed" -eq 0 ] || echo "  header: $header"
failed=$((failed | case_failed))
case_number=$((case_number + 1))

check_failing_line "None followed by Unicode tag characters (U+E0000 to U+E007F)" \
  "- Password: None${tagged_value}"
check_failing_line "None with a zero width space (U+200B) inside" \
  "- Password: No${zero_width_space}ne"
check_failing_line "None with a soft hyphen (U+00AD) inside" \
  "- Password: No${soft_hyphen}ne"
check_failing_line "None in fullwidth letters" "- Password: ${fullwidth_none}"
check_failing_line "a zero width space (U+200B) between the separator and None" \
  "- Password:${zero_width_space} None"

echo "case $case_number: None as written, after a format character or fullwidth letters before the separator"
case_failed="$failed"
failed=0
run_on_lines "$work/case$case_number" "# Spec" "" \
  "- Pass${zero_width_space}word: None" \
  "- Password${zero_width_space}: None" \
  "${fullwidth_password}${fullwidth_colon}None" \
  '**Password:** `None`'
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "summary line counts 4 Password lines and 0 other lines" \
  'printf "%s\n" "$out" | grep -qxF "1 files checked, 4 Password lines found, 0 other lines say there is no password"'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
expect "stderr is empty" '[ -z "$err" ]'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
