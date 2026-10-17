#!/usr/bin/env bash
# Tests scripts/check-maturity-thresholds.py against the repository documents
# and against fixture documents that give other maturity cut-offs.
#
# Usage:
#   scripts/test-check-maturity-thresholds.sh
#
# Cases:
#   1. No file arguments (the documents in DOCUMENTS): exit 0, RESULT: PASS,
#      and the cut-offs read from the Scorecard are listed.
#   2. Thresholds written as "Score 1.0 - 1.5", "Score 1.6 - 2.5", "Score
#      2.6 - 3.5", "Score 3.6 - 3.9" and "Level 5 (Optimizing): Score 4.0":
#      exit 1, one FAIL line for each of the five lines.
#   3. Bold ranges such as "**1.6-2.5**: Developing" and "**4.0**:
#      Optimizing": exit 1, a FAIL line for each, and a FAIL line for each
#      Scorecard level the fixture gives no range for.
#   4. The Scorecard cut-offs for three levels, with Advanced left out:
#      exit 1, a FAIL line that says there is no score range for Advanced.
#   5. The Scorecard cut-offs, plus other cut-offs inside a fenced code
#      block: exit 0, the code block is not checked.
#   6. An option such as --help: exit 2, usage on stderr.
#
# Exit status: 0 when every case passes, 1 when any case fails.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
checker="$here/check-maturity-thresholds.py"

work="$(mktemp -d "${TMPDIR:-/tmp}/check-maturity-thresholds.XXXXXX")"
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
expect "Scorecard Basic is below 1.5" 'has_line "  Basic below 1.5"'
expect "Scorecard Developing is 1.5 to below 2.5" 'has_line "  Developing 1.5 to below 2.5"'
expect "Scorecard Established is 2.5 to below 3.5" 'has_line "  Established 2.5 to below 3.5"'
expect "Scorecard Advanced is 3.5 to 4.0" 'has_line "  Advanced 3.5 to 4.0"'
expect "Scorecard assigns no Optimizing range" '! printf "%s\n" "$out" | grep -q "^  Optimizing "'
end_case

printf '%s\n' \
  '### Maturity Thresholds' \
  '- **Level 1 (Basic)**: Score 1.0 - 1.5' \
  '- **Level 2 (Developing)**: Score 1.6 - 2.5' \
  '- **Level 3 (Established)**: Score 2.6 - 3.5' \
  '- **Level 4 (Advanced)**: Score 3.6 - 3.9' \
  '- **Level 5 (Optimizing)**: Score 4.0 (Perfect score demonstrating excellence)' \
  > "$work/thresholds.md"
start_case "case 2: thresholds from 1.0 - 1.5 to 4.0" "$work/thresholds.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "five FAIL lines" '[ "$(fail_count)" -eq 5 ]'
expect "FAIL line for Basic" \
  'has_fail "line 2: Basic is 1.0 to 1.5 here, but on the Scorecard it is below 1.5"'
expect "FAIL line for Developing" \
  'has_fail "line 3: Developing is 1.6 to 2.5 here, but on the Scorecard it is 1.5 to below 2.5"'
expect "FAIL line for Established" \
  'has_fail "line 4: Established is 2.6 to 3.5 here, but on the Scorecard it is 2.5 to below 3.5"'
expect "FAIL line for Advanced" \
  'has_fail "line 5: Advanced is 3.6 to 3.9 here, but on the Scorecard it is 3.5 to 4.0"'
expect "FAIL line for Optimizing" \
  'has_fail "line 6: Optimizing is given the score range 4.0, but the Scorecard labels no dimension or overall score Optimizing"'
end_case

printf '%s\n' \
  '### Raw Scores' \
  '- **1.6-2.5**: Developing - Structured approaches beginning to emerge' \
  '- **4.0**: Optimizing - Perfect score demonstrating excellence' \
  > "$work/bold.md"
start_case "case 3: bold ranges" "$work/bold.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line for Developing" \
  'has_fail "line 2: Developing is 1.6 to 2.5 here, but on the Scorecard it is 1.5 to below 2.5"'
expect "FAIL line for Optimizing" \
  'has_fail "line 3: Optimizing is given the score range 4.0"'
expect "FAIL line for no Basic range" 'has_fail "bold.md: no score range for Basic"'
expect "FAIL line for no Established range" 'has_fail "bold.md: no score range for Established"'
expect "FAIL line for no Advanced range" 'has_fail "bold.md: no score range for Advanced"'
expect "no FAIL line for a missing Developing range" \
  '! has_fail "bold.md: no score range for Developing"'
end_case

printf '%s\n' \
  '| Score Range | Maturity Level |' \
  '|-------------|----------------|' \
  '| Below 1.5 | **Level 1: Basic** |' \
  '| 1.5 to below 2.5 | **Level 2: Developing** |' \
  '| 2.5 to below 3.5 | **Level 3: Established** |' \
  > "$work/missing.md"
start_case "case 4: no range for Advanced" "$work/missing.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line for no Advanced range" 'has_fail "missing.md: no score range for Advanced"'
end_case

printf '%s\n' \
  '## Level 1: Basic (Score below 1.5)' \
  '## Level 2: Developing (Score 1.5 to below 2.5)' \
  '## Level 3: Established (Score 2.5 to below 3.5)' \
  '## Level 4: Advanced (Score 3.5 to 4.0)' \
  '```' \
  'Basic: Score 1.0 - 1.4' \
  'Optimizing: Score 4.0' \
  '```' \
  > "$work/fenced.md"
start_case "case 5: other cut-offs inside a code block" "$work/fenced.md"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
expect "four PASS lines" '[ "$(printf "%s\n" "$out" | grep -c "^  PASS")" -eq 4 ]'
end_case

start_case "case 6: option argument" --help
expect "exit status is 2" '[ "$status" -eq 2 ]'
expect "usage on stderr" 'printf "%s\n" "$err" | grep -q "^usage:"'
end_case

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
