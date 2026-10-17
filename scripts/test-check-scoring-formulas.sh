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
#   5. An option such as --help: exit 2, usage on stderr.
#   6. Ranges at the end of a sentence, such as "scored from 1 to 5.": exit 1,
#      a FAIL line for each range that does not run from 1 to 4, and none for
#      "scored from 1 to 4." or the decimal in "score 1-2.5".
#
# Exit status: 0 when every case passes, 1 when any case fails.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
checker="$here/check-scoring-formulas.py"

work="$(mktemp -d "${TMPDIR:-/tmp}/check-scoring-formulas.XXXXXX")"
work="$(cd "$work" && pwd -P)"
trap 'rm -rf "$work"' EXIT

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

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
