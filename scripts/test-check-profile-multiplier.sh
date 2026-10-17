#!/usr/bin/env bash
# Tests scripts/check-profile-multiplier.py against the repository documents
# and workbook, against fixture documents that give other multiplier ranges,
# and against copies of the workbook that calculate the multiplier
# differently.
#
# Usage:
#   scripts/test-check-profile-multiplier.sh
#
# Cases 7 to 10 copy the checker and the toolkit workbook into a new
# temporary directory laid out like the repository (scripts/ and toolkit/),
# edit the copy of the workbook, and run the checker there.
#
# Cases:
#   1. No file arguments (the documents in DOCUMENTS): exit 0, RESULT: PASS,
#      and the lowest and highest multiplier read from the workbook are
#      listed as 1.00 and 1.50.
#   2. The toolkit overview's earlier wording, "a profile multiplier
#      (0.8-1.5x)": exit 1, one FAIL line that gives 0.8 to 1.5 and the
#      workbook's 1.00 to 1.50.
#   3. The range written as "(1.0-1.5x)", "1.00 - 1.50", "from 1.00 to
#      1.50.", "between 1.00 and 1.50" and "(1.0x to 1.5x range)", on lines
#      that say "multiplier", "Multiplier" or "ProfileMultiplier": exit 0,
#      five PASS lines.
#   4. The ranges "between 0.80 and 1.50", "1.00 to 2.00" and "0.8x-1.5x":
#      exit 1, a FAIL line for each.
#   5. Other ranges on a line that does not say "multiplier" and inside a
#      fenced code block, whole numbers ("3-9") on a line that does, and the
#      workbook's range on one line: exit 0, one PASS line.
#   6. A document that names the multiplier but gives no range: exit 1, a
#      FAIL line that says so.
#   7. A workbook whose risk values of 1.0 are 0.8: the lowest multiplier is
#      listed as 0.80, "between 1.00 and 1.50" fails and "(0.8-1.5x)"
#      passes.
#   8. A workbook whose risk values of 1.0 are 1.005: the lowest multiplier,
#      1.005, is listed rounded half up to 1.01.
#   9. A workbook whose ProfileMultiplier formula leaves out the factor for
#      the answer in D17: exit 1, one FAIL line that says the formula is not
#      a sum of risk value times factor terms.
#  10. A workbook in which the organization size answers carry the factor
#      0.15, as the geographic scope answers do: exit 1, one FAIL line that
#      says the rows cannot be grouped into profile questions by factor.
#  11. An option such as --help: exit 2, usage on stderr, then the checker's
#      header text.
#  12. -h: exit 2, usage on stderr, then the checker's header text.
#  13. An unknown option, --verbose: exit 2, only the usage line on stderr.
#
# Exit status: 0 when every case passes, 1 when any case fails.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
root="$(dirname "$here")"
checker="$here/check-profile-multiplier.py"
toolkit="toolkit/QRAMM_Assessment_Toolkit.xlsx"

work="$(mktemp -d "${TMPDIR:-/tmp}/check-profile-multiplier.XXXXXX")"
work="$(cd "$work" && pwd -P)"
trap 'rm -rf "$work"' EXIT

failed=0

# Lays out a copy of the checker at $1, with a copy of the toolkit workbook
# in which every "$2" in its XML parts under xl/ is replaced by "$3". Fails
# when no such part of the workbook contains "$2".
make_copy() {
  mkdir -p "$1/scripts" "$1/toolkit"
  cp "$checker" "$1/scripts/check-profile-multiplier.py"
  python3 -I - "$root/$toolkit" "$1/$toolkit" "$2" "$3" <<'PY'
import sys
import zipfile

source, target, old, new = sys.argv[1:5]
found = 0
with zipfile.ZipFile(source) as book, zipfile.ZipFile(target, "w") as copy:
    for info in book.infolist():
        data = book.read(info.filename)
        if info.filename.startswith("xl/") and info.filename.endswith(".xml"):
            text = data.decode("utf-8")
            found += text.count(old)
            data = text.replace(old, new).encode("utf-8")
        copy.writestr(info, data)
sys.exit(0 if found else 1)
PY
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

pass_count() {
  printf '%s\n' "$out" | grep -c '^  PASS' || true
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

start_case "case 1: repository documents and workbook" "$checker"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
expect "workbook answers are listed" 'has_line "  answers: D9, D11, D13, D15, D17"'
expect "workbook range is 1.00 to 1.50" 'has_line "  lowest 1.00, highest 1.50"'
expect "no FAIL lines" '[ "$(fail_count)" -eq 0 ]'
end_case

printf '%s\n' \
  'The Organization Profile Tab captures this context through a profile multiplier (0.8-1.5x) that adjusts raw scores based on:' \
  > "$work/old.md"
start_case "case 2: the toolkit overview's earlier wording" "$checker" "$work/old.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line gives 0.8 to 1.5 and the workbook range" \
  "has_fail 'old.md line 1: the multiplier range is 0.8 to 1.5 here, but $toolkit calculates 1.00 to 1.50'"
end_case

printf '%s\n' \
  'The profile multiplier (1.0-1.5x) adjusts the dimension scores.' \
  'A Multiplier of 1.00 - 1.50 applies.' \
  'The multiplier runs from 1.00 to 1.50.' \
  'It is a profile multiplier between 1.00 and 1.50, set on the Profile tab.' \
  '- [ ] ProfileMultiplier calculates correctly (1.0x to 1.5x range)' \
  > "$work/forms.md"
start_case "case 3: the workbook's range in five forms" "$checker" "$work/forms.md"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
expect "five PASS lines" '[ "$(pass_count)" -eq 5 ]'
expect "PASS line for (1.0-1.5x)" 'has_line "  PASS line 1: 1.0 to 1.5"'
expect "PASS line for 1.00 - 1.50" 'has_line "  PASS line 2: 1.00 to 1.50"'
expect "PASS line for from 1.00 to 1.50." 'has_line "  PASS line 3: 1.00 to 1.50"'
expect "PASS line for between 1.00 and 1.50" 'has_line "  PASS line 4: 1.00 to 1.50"'
expect "PASS line for (1.0x to 1.5x range)" 'has_line "  PASS line 5: 1.0 to 1.5"'
end_case

printf '%s\n' \
  'The profile multiplier is between 0.80 and 1.50.' \
  'The multiplier runs from 1.00 to 2.00.' \
  'A profile multiplier (0.8x-1.5x) adjusts the scores.' \
  > "$work/wrong.md"
start_case "case 4: other ranges" "$checker" "$work/wrong.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "three FAIL lines" '[ "$(fail_count)" -eq 3 ]'
expect "FAIL line for between 0.80 and 1.50" \
  "has_fail 'wrong.md line 1: the multiplier range is 0.80 to 1.50 here, but $toolkit calculates 1.00 to 1.50'"
expect "FAIL line for 1.00 to 2.00" \
  "has_fail 'wrong.md line 2: the multiplier range is 1.00 to 2.00 here, but $toolkit calculates 1.00 to 1.50'"
expect "FAIL line for 0.8x-1.5x" \
  "has_fail 'wrong.md line 3: the multiplier range is 0.8 to 1.5 here, but $toolkit calculates 1.00 to 1.50'"
end_case

printf '%s\n' \
  'Answers are scored from 1.0 to 4.0, and adjusted scores can reach 6.0.' \
  '```' \
  'Profile multiplier: 0.8-1.5' \
  '```' \
  'A Multi-region (3-9 countries) answer raises the multiplier.' \
  'The profile multiplier is between 1.00 and 1.50.' \
  > "$work/skipped.md"
start_case "case 5: ranges that are not multiplier ranges" "$checker" "$work/skipped.md"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
expect "one PASS line, for line 6" \
  '[ "$(pass_count)" -eq 1 ] && has_line "  PASS line 6: 1.00 to 1.50"'
end_case

printf '%s\n' \
  'The Organization Profile Tab captures this context through a profile multiplier.' \
  'Each answer carries a risk value of 1.0, 1.3 or 1.5.' \
  > "$work/norange.md"
start_case "case 6: no multiplier range" "$checker" "$work/norange.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says there is no range" 'has_fail "norange.md: gives no multiplier range"'
end_case

printf '%s\n' \
  'The Organization Profile Tab captures this context through a profile multiplier between 1.00 and 1.50 that adjusts raw scores based on:' \
  > "$work/new.md"

make_copy "$work/low" '> 1.0 <' '> 0.8 <'
start_case "case 7: workbook whose risk values of 1.0 are 0.8" \
  "$work/low/scripts/check-profile-multiplier.py" "$work/new.md" "$work/old.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "workbook range is 0.80 to 1.50" 'has_line "  lowest 0.80, highest 1.50"'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line for between 1.00 and 1.50" \
  "has_fail 'new.md line 1: the multiplier range is 1.00 to 1.50 here, but $toolkit calculates 0.80 to 1.50'"
expect "PASS line for (0.8-1.5x)" 'has_line "  PASS line 1: 0.8 to 1.5"'
end_case

make_copy "$work/half" '> 1.0 <' '> 1.005 <'
start_case "case 8: workbook whose risk values of 1.0 are 1.005" \
  "$work/half/scripts/check-profile-multiplier.py" "$work/new.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "workbook range is 1.01 to 1.50" 'has_line "  lowest 1.01, highest 1.50"'
expect "FAIL line for between 1.00 and 1.50" \
  "has_fail 'new.md line 1: the multiplier range is 1.00 to 1.50 here, but $toolkit calculates 1.01 to 1.50'"
end_case

make_copy "$work/noterm" \
  'VLOOKUP(D17, RiskMatrix, 3, FALSE) * VLOOKUP(D17, RiskMatrix, 2, FALSE)' \
  'VLOOKUP(D17, RiskMatrix, 3, FALSE)'
start_case "case 9: formula without the factor for D17" \
  "$work/noterm/scripts/check-profile-multiplier.py" "$work/new.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says the formula has another form" \
  "has_fail '$toolkit: Profile!D21 (ProfileMultiplier) is not ROUND of a sum of VLOOKUP(answer, RiskMatrix, 3, FALSE) * VLOOKUP(answer, RiskMatrix, 2, FALSE) terms'"
expect "no document is checked" '[ "$(pass_count)" -eq 0 ]'
end_case

make_copy "$work/shared" '> 0.10 <' '> 0.15 <'
start_case "case 10: two profile questions with the factor 0.15" \
  "$work/shared/scripts/check-profile-multiplier.py" "$work/new.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says the rows cannot be grouped" \
  "has_fail '$toolkit: RiskMatrix has 4 different factors but Profile!D21 adds 5 answers, so its rows cannot be grouped into profile questions by factor'"
end_case

start_case "case 11: option argument" "$checker" --help
expect "exit status is 2" '[ "$status" -eq 2 ]'
expect "usage on stderr" 'printf "%s\n" "$err" | grep -q "^usage:"'
expect "header text on stderr" \
  'printf "%s\n" "$err" | grep -qx "Checks that documents giving the range of the QRAMM profile multiplier"'
end_case

start_case "case 12: -h" "$checker" -h
expect "exit status is 2" '[ "$status" -eq 2 ]'
expect "usage on stderr" 'printf "%s\n" "$err" | grep -q "^usage:"'
expect "header text on stderr" \
  'printf "%s\n" "$err" | grep -qx "Checks that documents giving the range of the QRAMM profile multiplier"'
end_case

start_case "case 13: unknown option" "$checker" --verbose
expect "exit status is 2" '[ "$status" -eq 2 ]'
expect "only the usage line on stderr" \
  '[ "$err" = "usage: python3 -I scripts/check-profile-multiplier.py [file ...]" ]'
end_case

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
