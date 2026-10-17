#!/usr/bin/env bash
# Tests scripts/check-assessment-copies.py against the repository copies and
# against fixture copies that differ from their source.
#
# Usage:
#   scripts/test-check-assessment-copies.sh
#
# Cases 2 to 5 copy the checker into a new temporary directory laid out like
# the repository (scripts/, framework/ and toolkit/assessment/), so the
# checker treats that directory as the repository root. Each fixture source
# has one question with four answer options and a link to
# framework/scoring-methodology.md.
#
# Cases:
#   1. The repository copies: exit 0, RESULT: PASS.
#   2. A copy that lists options 1 to 3 and leaves out option 4: exit 1, a
#      FAIL line that names the missing source lines and shows the option 4
#      text.
#   3. A copy that rewrites the link for its own directory so that it still
#      reaches framework/scoring-methodology.md: exit 0, RESULT: PASS.
#   4. A copy that keeps the source's link text, which from the copy's
#      directory reaches a different file: exit 1, a FAIL line for that line.
#   5. A copy that does not exist: exit 1, a FAIL line that says it cannot be
#      read.
#   6. An argument such as --help: exit 2, usage on stderr.
#
# Exit status: 0 when every case passes, 1 when any case fails.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
checker="$here/check-assessment-copies.py"

work="$(mktemp -d "${TMPDIR:-/tmp}/check-assessment-copies.XXXXXX")"
work="$(cd "$work" && pwd -P)"
trap 'rm -rf "$work"' EXIT

failed=0

# Prints the lines of a fixture assessment. $1 is the scoring methodology
# link target, $2 is "4" to include option 4 and anything else to leave it out.
assessment() {
  printf '%s\n' \
    '# Assessment' \
    '' \
    '**Options**:' \
    '' \
    '1. **Basic**: Not included' \
    '' \
    '2. **Developing**: Manual list' \
    '' \
    '3. **Established**: Systematic inventory' \
    ''
  if [ "$2" = "4" ]; then
    printf '%s\n' '4. **Advanced**: Automated discovery' ''
  fi
  printf '%s\n' \
    '**Evidence to Look For**:' \
    '' \
    "See the [Scoring Methodology]($1)."
}

# Lays out a copy of the repository at $1 whose full-assessment.md copy has
# the link target $2 and, when $3 is "4", option 4. Prints the layout path.
make_copy() {
  local copy="$work/$1"
  mkdir -p "$copy/scripts" "$copy/framework" "$copy/toolkit/assessment"
  cp "$checker" "$copy/scripts/check-assessment-copies.py"
  assessment 'scoring-methodology.md' 4 > "$copy/framework/full-assessment.md"
  assessment "$2" "$3" > "$copy/toolkit/assessment/full-assessment.md"
  printf '%s\n' '# Questions' '' '1. A question' \
    > "$copy/framework/Complete_QRAMM_Questions.md"
  cp "$copy/framework/Complete_QRAMM_Questions.md" \
    "$copy/toolkit/assessment/Complete_QRAMM_Questions.md"
  printf '%s\n' "$copy"
}

# Runs the checker at $1 with the remaining arguments. Sets out, err and
# status.
run_checker() {
  local script="$1"
  shift
  status=0
  python3 -I "$script" "$@" > "$work/out" 2> "$work/err" || status=$?
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

has_line() {
  printf '%s\n' "$out" | grep -q -F -- "$1"
}

last_line_is() {
  [ "$(printf '%s\n' "$out" | tail -n 1)" = "$1" ]
}

show_output() {
  echo "  -- stdout --"
  printf '%s\n' "$out" | sed 's/^/  /'
  echo "  -- stderr --"
  printf '%s\n' "$err" | sed 's/^/  /'
}

# Runs one case: $1 is its title, the rest are run_checker arguments. Leaves
# the result in out, err and status for the expect lines that follow.
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

start_case "case 1: repository copies" "$checker"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "last line is RESULT: PASS" 'last_line_is "RESULT: PASS"'
end_case

copy="$(make_copy missing ../../framework/scoring-methodology.md 3)"
start_case "case 2: option 4 left out of the copy" \
  "$copy/scripts/check-assessment-copies.py"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line names the missing source lines" \
  'has_fail "toolkit/assessment/full-assessment.md: framework/full-assessment.md lines 11-12 are missing (after copy line 10)"'
expect "option 4 text is shown" \
  'has_line "source 11: 4. **Advanced**: Automated discovery"'
expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
end_case

copy="$(make_copy rewritten ../../framework/scoring-methodology.md 4)"
start_case "case 3: link rewritten for the copy's directory" \
  "$copy/scripts/check-assessment-copies.py"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "last line is RESULT: PASS" 'last_line_is "RESULT: PASS"'
end_case

copy="$(make_copy unchanged scoring-methodology.md 4)"
start_case "case 4: link that reaches a different file from the copy" \
  "$copy/scripts/check-assessment-copies.py"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line for the link line" \
  'has_fail "toolkit/assessment/full-assessment.md line 15: differ from framework/full-assessment.md line 15"'
end_case

copy="$(make_copy absent ../../framework/scoring-methodology.md 4)"
rm "$copy/toolkit/assessment/full-assessment.md"
start_case "case 5: copy does not exist" "$copy/scripts/check-assessment-copies.py"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line says the copy cannot be read" \
  'has_fail "toolkit/assessment/full-assessment.md: cannot read"'
end_case

start_case "case 6: option argument" "$checker" --help
expect "exit status is 2" '[ "$status" -eq 2 ]'
expect "usage on stderr" 'printf "%s\n" "$err" | grep -q "^usage:"'
end_case

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
