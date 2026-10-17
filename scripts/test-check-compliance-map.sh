#!/usr/bin/env bash
# Tests scripts/check-compliance-map.py against the repository workbooks and
# against copies of the spec that differ from them.
#
# Usage:
#   scripts/test-check-compliance-map.sh
#
# Cases 2 to 4 copy the checker, the spec and both workbooks into a new
# temporary directory laid out like the repository (scripts/, toolkit-specs/
# and toolkit/), edit the copy of the spec, and run the checker there.
#
# Cases:
#   1. The repository spec and workbooks: exit 0, a PASS line for each
#      workbook, RESULT: PASS.
#   2. A spec that differs from the workbooks in five cells: a different
#      control (Q1 CMMC), "-" where the workbooks carry a control (Q2 CMMC),
#      a control where the workbooks carry "-" (Q19 CMMC), a different weight
#      (Q3 CMMC) and a different CIS safeguard stored as a number (Q1 CIS):
#      exit 1, the 7 FAIL lines those cells give for each workbook.
#   3. A spec with no row for Q120: exit 1, FAIL lines for the missing spec
#      cells and for the workbook rows the spec does not give.
#   4. A workbook argument that does not exist: exit 1, a FAIL line that
#      says the map cannot be read.
#   5. An option such as --help: exit 2, usage on stderr.
#
# Exit status: 0 when every case passes, 1 when any case fails.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
root="$(dirname "$here")"
checker="$here/check-compliance-map.py"
spec="toolkit-specs/4_QRAMM_Compliance_Mapping_Details.md"
toolkit="toolkit/QRAMM_Assessment_Toolkit.xlsx"
sample="toolkit/Sample_Assessment.xlsx"

work="$(mktemp -d "${TMPDIR:-/tmp}/check-compliance-map.XXXXXX")"
work="$(cd "$work" && pwd -P)"
trap 'rm -rf "$work"' EXIT

failed=0

# Lays out a copy of the repository at $1 with the spec edited by the sed
# script $2.
make_copy() {
  mkdir -p "$1/scripts" "$1/toolkit-specs" "$1/toolkit"
  cp "$checker" "$1/scripts/check-compliance-map.py"
  cp "$root/$toolkit" "$root/$sample" "$1/toolkit/"
  sed -e "$2" "$root/$spec" > "$1/$spec"
}

# Runs the checker at $1 with the remaining arguments. Sets out, err and
# status.
run_checker() {
  local checker_path="$1"
  shift
  status=0
  python3 -I "$checker_path" "$@" > "$work/out" 2> "$work/err" || status=$?
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

show_output() {
  echo "  -- stdout --"
  printf '%s\n' "$out" | sed 's/^/  /'
  echo "  -- stderr --"
  printf '%s\n' "$err" | sed 's/^/  /'
}

# Runs one case: $1 is its title, $2 the checker, the rest are checker
# arguments. Leaves the result in out, err and status for the expect lines
# that follow.
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

start_case "case 1: repository spec and workbooks" "$checker"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "PASS line for each workbook" \
  '[ "$(printf "%s\n" "$out" | grep -c "^  PASS 120 questions x 8 frameworks, 960 rows$")" -eq 2 ]'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
end_case

make_copy "$work/cells" '
/^| Q1: /s/| AC\.L1-b\.1\.i (0\.8) |/| AC.L1-3.1.1 (0.8) |/
/^| Q1: /s/| 1\.1 (1\.0) |$/| 1.2 (1.0) |/
/^| Q2: /s/| AC\.L2-3\.1\.3 (0\.8) |/| - |/
/^| Q3: /s/| SC\.L2-3\.13\.11 (1\.0) |/| SC.L2-3.13.11 (0.6) |/
/^| Q19: /s/| - | - |/| - | CA.L2-3.12.2 (1.0) |/
'
start_case "case 2: spec differs from the workbooks in five cells" \
  "$work/cells/scripts/check-compliance-map.py"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "14 FAIL lines (7 for each workbook)" '[ "$(fail_count)" -eq 14 ]'
for book in "$toolkit" "$sample"; do
  expect "$book: Q1 CMMC control" \
    "has_fail '$book Q1 CMMC 2.0: Data!AY5 is AC.L1-b.1.i, the spec gives AC.L1-3.1.1'"
  expect "$book: Q2 CMMC control" \
    "has_fail '$book Q2 CMMC 2.0: Data!AY13 is AC.L2-3.1.3, the spec gives -'"
  expect "$book: Q2 CMMC weight" \
    "has_fail '$book Q2 CMMC 2.0: Data!BA13 is 0.8, the spec gives no weight'"
  expect "$book: Q3 CMMC weight" \
    "has_fail '$book Q3 CMMC 2.0: Data!BA21 is 1, the spec gives 0.6'"
  expect "$book: Q19 CMMC control" \
    "has_fail '$book Q19 CMMC 2.0: Data!AY149 is -, the spec gives CA.L2-3.12.2'"
  expect "$book: Q19 CMMC weight" \
    "has_fail '$book Q19 CMMC 2.0: Data!BA149 is empty, the spec gives 1'"
  expect "$book: Q1 CIS control" \
    "has_fail '$book Q1 CIS v8: Data!AY10 is 1.1, the spec gives 1.2'"
done
end_case

make_copy "$work/missing" '/^| Q120: /d'
start_case "case 3: spec with no row for Q120" \
  "$work/missing/scripts/check-compliance-map.py" "$sample"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line for the missing CMMC cell" "has_fail '$spec: no CMMC cell for Q120'"
expect "FAIL line for a workbook row the spec does not give" \
  "has_fail '$sample Data row 962: not a question and framework in $spec'"
end_case

start_case "case 4: workbook that does not exist" "$checker" "toolkit/missing.xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line says the map cannot be read" \
  "has_fail 'toolkit/missing.xlsx: cannot read the compliance map'"
end_case

start_case "case 5: option argument" "$checker" --help
expect "exit status is 2" '[ "$status" -eq 2 ]'
expect "usage on stderr" 'printf "%s\n" "$err" | grep -q "^usage:"'
end_case

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
