#!/usr/bin/env bash
# Tests scripts/check-scoring-formulas.py against the repository documents and
# against fixture documents that describe a different calculation.
#
# Usage:
#   scripts/test-check-scoring-formulas.sh
#
# Cases:
#   1. No file arguments (the documents in DOCUMENTS): exit 0, RESULT: PASS.
#   2. A "5-point scale" where questions are "scored from 1-5": exit 1, one
#      FAIL line for each statement.
#   3. A dimension score formula written as a plain average of the practice
#      scores: exit 1, a FAIL line that says the Dimension Score differs.
#   4. Prose that describes the scores with no formulas, such as "Apply
#      minimum scoring across practices": exit 1, a FAIL line for each of the
#      three missing formulas.
#   5. An option such as --help: exit 2, usage on stderr, then the checker's
#      header text.
#   6. Ranges at the end of a sentence, such as "scored from 1 to 5.": exit 1,
#      a FAIL line for each range that does not run from 1 to 4, and none for
#      "scored from 1 to 4." or the decimal in "score 1-2.5".
#   7. An empty file argument: exit 1, "FAIL '': no file name given", no
#      "cannot read" line.
#   8. Under the en_US.UTF-8 locale, a file argument that holds the byte
#      0xff, which is not valid UTF-8, and names no file, then
#      framework/qramm-overview.md: exit 1, no traceback, the name printed
#      with the byte as \xff on its == line and in a FAIL line that says it
#      cannot be read, a PASS line for the overview's Overall Score formula,
#      then RESULT: FAIL.
#   9. Under the en_US.ISO8859-1 locale, a file argument that is valid UTF-8
#      and holds the character U+65E5, which ISO-8859-1 cannot encode, and
#      names no file, then framework/qramm-overview.md: exit 1, nothing on
#      stderr, the name printed with the character as 日 on its == line
#      and in a FAIL line that says it cannot be read (No such file or
#      directory), a PASS line for the overview's Overall Score formula,
#      then RESULT: FAIL. The case is skipped, with a line that says so, when
#      python3 -I does not decode file names as UTF-8 and write stdout as
#      ISO-8859-1 under that locale on this machine.
#  10. A document with a Latin-1 byte, then framework/qramm-overview.md:
#      exit 1, nothing on stderr, one FAIL line, which says the document is
#      not UTF-8 text, a PASS line for the overview's Overall Score formula,
#      then RESULT: FAIL.
#
# The temporary directory is made under .tmp-tests/ at the repository root,
# and the cleanup removes only a directory under it.
#
# Exit status: 0 when every case passes, 1 when any case fails.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
checker="$here/check-scoring-formulas.py"

tmp_root="$(cd "$here/.." && pwd -P)/.tmp-tests"
mkdir -p "$tmp_root"
work="$(mktemp -d "$tmp_root/check-scoring-formulas.XXXXXX")"
cleanup() {
  case "$work" in
    "$tmp_root"/?*) rm -rf -- "$work" ;;
    *) exit 1 ;;
  esac
  rmdir "$tmp_root" 2> /dev/null || true
}
trap cleanup EXIT

failed=0

# Runs the checker with the given arguments. Sets out, err and status.
run_checker() {
  status=0
  python3 -I "$checker" "$@" > "$work/out" 2> "$work/err" || status=$?
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

has_fail() {
  printf '%s\n' "$out" | grep '^  FAIL' | grep -q -F -- "$1"
}

fail_count() {
  printf '%s\n' "$out" | grep -c '^  FAIL' || true
}

has_line() {
  printf '%s\n' "$out" | grep -q -x -F -- "$1"
}

show_output() {
  echo "  -- stdout --"
  printf '%s\n' "$out" | sed 's/^/  /'
  echo "  -- stderr --"
  printf '%s\n' "$err" | sed 's/^/  /'
}

# Runs one case: $1 is its title, the rest are checker arguments. Leaves the
# result in out, err and status for the expect lines that follow.
start_case() {
  echo "$1"
  shift
  case_failed="$failed"
  failed=0
  run_checker "$@"
}

end_case() {
  [ "$failed" -eq 0 ] || show_output
  failed=$((failed | case_failed))
}

start_case "case 1: repository documents"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
end_case

printf '%s\n' \
  '## Scoring Methodology' \
  '' \
  'The QRAMM assessment uses a 5-point scale where:' \
  '- Each question is scored from 1-5 based on the selected maturity level' \
  > "$work/scale.md"
start_case "case 2: 5-point scale" "$work/scale.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line for the 5-point scale" 'has_fail "\"5-point scale\" but"'
expect "FAIL line for scored from 1-5" 'has_fail "\"scored from 1-5\" but"'
end_case

printf '%s\n' \
  '### Scoring Calculation' \
  '```' \
  'Dimension Score = Average of practice scores within dimension' \
  '```' \
  > "$work/average.md"
start_case "case 3: dimension score as a plain average" "$work/average.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line says the Dimension Score differs" \
  'has_fail "line 3: Dimension Score differs from"'
end_case

printf '%s\n' \
  '#### Score Calculation' \
  '- **Practice Scores**: Calculate average scores for each practice' \
  '- **Dimension Scores**: Apply minimum scoring across practices' \
  > "$work/prose.md"
start_case "case 4: prose with no formulas" "$work/prose.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line for Practice Score" 'has_fail "prose.md: no formula for Practice Score"'
expect "FAIL line for Dimension Score" 'has_fail "prose.md: no formula for Dimension Score"'
expect "FAIL line for Overall Score" 'has_fail "prose.md: no formula for Overall Score"'
end_case

start_case "case 5: option argument" --help
expect "exit status is 2" '[ "$status" -eq 2 ]'
expect "usage on stderr" 'printf "%s\n" "$err" | grep -q "^usage:"'
expect "header text on stderr" \
  'printf "%s\n" "$err" | grep -qx "Checks that documents describing QRAMM scores state the same score formulas"'
end_case

printf '%s\n' \
  '## Scoring Methodology' \
  '' \
  'Each question is scored from 1 to 5.' \
  'Each question is scored from 1-5.' \
  'Each question is scored 0 to 4.' \
  'Each question is scored from 1 to 4.' \
  'A practice may score 1-2.5 on average.' \
  > "$work/sentence.md"
start_case "case 6: ranges at the end of a sentence" "$work/sentence.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line for scored from 1 to 5." \
  'has_fail "sentence.md line 3: \"scored from 1 to 5\" but"'
expect "FAIL line for scored from 1-5." \
  'has_fail "sentence.md line 4: \"scored from 1-5\" but"'
expect "FAIL line for scored 0 to 4." \
  'has_fail "sentence.md line 5: \"scored 0 to 4\" but"'
expect "no FAIL line for scored from 1 to 4." '! has_fail "sentence.md line 6:"'
expect "no FAIL line for score 1-2.5" '! has_fail "sentence.md line 7:"'
end_case

start_case "case 7: an empty file argument" ""
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL says no file name was given" \
  'printf "%s\n" "$out" | grep -qxF "  FAIL '"''"': no file name given"'
expect "no cannot read line" '! printf "%s\n" "$out" | grep -q "cannot read"'
end_case

# \377 is the byte 0xff, which is not valid UTF-8, so Python holds it as a
# lone surrogate. Under en_US.UTF-8 printing that raises UnicodeEncodeError;
# the C, C.UTF-8 and UTF-8 locales write the byte as it is. The checker is
# expected to print \xff in either case. No file is made with this name.
methodology="framework/scoring-methodology.md"
overview="framework/qramm-overview.md"
LC_ALL=en_US.UTF-8 start_case "case 8: a file argument that is not UTF-8" \
  "$work/bad$(printf '\377').md" "$overview"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "the name is printed with the byte as \\xff" \
  "has_line '== $work/bad\\xff.md against $methodology'"
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says the file cannot be read and gives the byte as \\xff" \
  "has_fail '$work/bad\\xff.md: cannot read ('"
expect "the overview is checked" "has_line '== $overview against $methodology'"
expect "PASS line for the overview's Overall Score" \
  'printf "%s\n" "$out" | grep -q "^  PASS Overall Score (line "'
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

# \346\227\245 is U+65E5 encoded as UTF-8. Under en_US.ISO8859-1 on macOS,
# python3 decodes the name as UTF-8 and writes stdout as ISO-8859-1, which
# has no byte for U+65E5, so printing the name as it is raises
# UnicodeEncodeError. The checker is expected to print 日 in its place.
# No file is made with this name.
title="case 9: a file argument that stdout's encoding cannot hold"
probe="$(LC_ALL=en_US.ISO8859-1 python3 -I -c 'import codecs, sys; print(codecs.lookup(sys.getfilesystemencoding()).name, codecs.lookup(sys.stdout.encoding).name)' 2>&1 || true)"
if [ "$probe" = "utf-8 iso8859-1" ]; then
  LC_ALL=en_US.ISO8859-1 start_case "$title" \
    "$work/$(printf '\346\227\245').md" "$overview"
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "no traceback on stderr" '[ -z "$err" ]'
  expect "the name is printed with the character as \\u65e5" \
    "has_line '== $work/\\u65e5.md against $methodology'"
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line says the file cannot be read and gives the character as \\u65e5" \
    "has_line '  FAIL $work/\\u65e5.md: cannot read (No such file or directory)'"
  expect "the overview is checked" "has_line '== $overview against $methodology'"
  expect "PASS line for the overview's Overall Score" \
    'printf "%s\n" "$out" | grep -q "^  PASS Overall Score (line "'
  expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
  end_case
else
  echo "$title"
  echo "  skip python3 does not decode file names as UTF-8 and write stdout as ISO-8859-1 under en_US.ISO8859-1 here ($probe)"
fi

# \351 is e with an acute accent in Latin-1, and not valid UTF-8 here.
printf 'Each question is scored from 1 to 4, caf\351.\n' > "$work/latin1.md"
start_case "case 10: a document that is not UTF-8" "$work/latin1.md" "$overview"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says it is not UTF-8 text" \
  "has_line '  FAIL $work/latin1.md: cannot read (not UTF-8 text)'"
expect "the overview is checked" "has_line '== $overview against $methodology'"
expect "PASS line for the overview's Overall Score" \
  'printf "%s\n" "$out" | grep -q "^  PASS Overall Score (line "'
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
