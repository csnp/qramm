#!/usr/bin/env bash
# Tests scripts/check-maturity-thresholds.py against the repository documents
# and workbooks, and against fixture documents and workbook copies that give
# other maturity cut-offs.
#
# Usage:
#   scripts/test-check-maturity-thresholds.sh
#
# Cases:
#   1. No file arguments (the documents in DOCUMENTS): exit 0, RESULT: PASS,
#      the cut-offs read from the Scorecard are listed, and in each of the
#      two toolkit workbooks the Welcome!H9 text (lines 5 to 8) and the
#      Maturity Distribution chart (Scorecard!M21:M24) give the Scorecard's
#      four ranges.
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
#   6. An option such as --help: exit 2, usage on stderr, then the checker's
#      header text.
#   7. Ranges at the end of a sentence, such as "score is 3.6 to 3.9." for
#      Advanced: exit 1, a FAIL line for each of the three ranges that are
#      not the Scorecard's, a PASS line for "1.5 to below 2.5." for
#      Developing, and no line for "1.6 to 2.4.2." or "**2.5.1**", which are
#      not read in part.
#   8. An empty file argument: exit 1, "FAIL '': no file name given", no
#      "cannot read" line.
#   9. A copy of the toolkit workbook whose chart counts Advanced from 3.6
#      to below 4 (the earlier Scorecard!M24 formula): exit 1, one FAIL line
#      that names Scorecard!M24 and both ranges.
#  10. A copy whose Incomplete Assessment chart category is labelled
#      Optimizing and counts practice scores of 4 or more: exit 1, one FAIL
#      line that says the Scorecard labels no score Optimizing.
#  11. A copy whose chart ranges start at row 22: exit 1, one FAIL line that
#      says the chart has no category for Basic.
#  12. A copy of the sample workbook whose Welcome!H9 text gives
#      "1.0 – 1.5: Basic" and "4.0: Optimizing", as the earlier text did:
#      exit 1, a FAIL line for each that names Welcome!H9 and the line.
#  13. A text file whose name ends in .xlsx: exit 1, one FAIL line that says
#      it is not a zip file.
#  14. Ranges written with an en dash and as "4.0: Optimizing", and a
#      practice number "1.1:" before a word that is not a level name: exit
#      1, a FAIL line for each of the two ranges that are not the
#      Scorecard's, three PASS lines, and no line for the practice number.
#  15. A copy whose Basic chart value is SUM(PracticeScoreOutcomes)/12:
#      exit 1, one FAIL line that names Scorecard!M21 and says the value is
#      not a count of practice scores in one range.
#
# The temporary directory is made under .tmp-tests/ at the repository root,
# and the cleanup removes only a directory under it.
#
# Exit status: 0 when every case passes, 1 when any case fails.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
root="$(dirname "$here")"
checker="$here/check-maturity-thresholds.py"
toolkit="toolkit/QRAMM_Assessment_Toolkit.xlsx"
sample="toolkit/Sample_Assessment.xlsx"

tmp_root="$(cd "$here/.." && pwd -P)/.tmp-tests"
mkdir -p "$tmp_root"
work="$(mktemp -d "$tmp_root/check-maturity-thresholds.XXXXXX")"
cleanup() {
  case "$work" in
    "$tmp_root"/?*) rm -rf -- "$work" ;;
    *) exit 1 ;;
  esac
  rmdir "$tmp_root" 2> /dev/null || true
}
trap cleanup EXIT

failed=0

# Writes $2, a copy of the repository workbook $1 in which, for each pair of
# the remaining arguments, every occurrence of the first in the XML parts
# under xl/ is replaced by the second. Fails when one of the first arguments
# is in none of those parts.
make_copy() {
  mkdir -p "$(dirname "$2")"
  python3 -I - "$root/$1" "$2" "${@:3}" <<'PY'
import sys
import zipfile

source, target = sys.argv[1:3]
pairs = list(zip(sys.argv[3::2], sys.argv[4::2]))
found = {old: 0 for old, _ in pairs}
with zipfile.ZipFile(source) as book, zipfile.ZipFile(target, "w") as copy:
    for info in book.infolist():
        data = book.read(info.filename)
        if info.filename.startswith("xl/") and info.filename.endswith(".xml"):
            text = data.decode("utf-8")
            for old, new in pairs:
                found[old] += text.count(old)
                text = text.replace(old, new)
            data = text.encode("utf-8")
        copy.writestr(info, data)
for old, count in found.items():
    if not count:
        print("make_copy: not in {}: {}".format(source, old), file=sys.stderr)
sys.exit(0 if all(found.values()) else 1)
PY
}

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

line_count() {
  printf '%s\n' "$out" | grep -c -x -F -- "$1" || true
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
expect "both workbooks are checked" \
  'has_line "== $toolkit against the Scorecard" && has_line "== $sample against the Scorecard"'
expect "Welcome!H9 of each workbook gives the four Scorecard ranges" \
  '[ "$(line_count "  PASS Welcome!H9 line 5: Basic below 1.5")" -eq 2 ] &&
   [ "$(line_count "  PASS Welcome!H9 line 6: Developing 1.5 to below 2.5")" -eq 2 ] &&
   [ "$(line_count "  PASS Welcome!H9 line 7: Established 2.5 to below 3.5")" -eq 2 ] &&
   [ "$(line_count "  PASS Welcome!H9 line 8: Advanced 3.5 to 4.0")" -eq 2 ]'
expect "the Maturity Distribution chart of each workbook is checked" \
  'has_line "== $toolkit Maturity Distribution chart (Scorecard!\$L\$21:\$L\$25, Scorecard!\$M\$21:\$M\$25) against the Scorecard" &&
   has_line "== $sample Maturity Distribution chart (Scorecard!\$L\$21:\$L\$25, Scorecard!\$M\$21:\$M\$25) against the Scorecard"'
expect "the chart of each workbook counts the four Scorecard ranges" \
  '[ "$(line_count "  PASS Scorecard!M21: Basic below 1.5")" -eq 2 ] &&
   [ "$(line_count "  PASS Scorecard!M22: Developing 1.5 to below 2.5")" -eq 2 ] &&
   [ "$(line_count "  PASS Scorecard!M23: Established 2.5 to below 3.5")" -eq 2 ] &&
   [ "$(line_count "  PASS Scorecard!M24: Advanced 3.5 to 4.0")" -eq 2 ]'
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
expect "header text on stderr" \
  'printf "%s\n" "$err" | grep -qx "Checks that documents giving score ranges for the QRAMM maturity levels"'
end_case

printf '%s\n' \
  '| Below 1.5 | **Level 1: Basic** |' \
  '| 1.5 to below 2.5 | **Level 2: Developing** |' \
  '| 2.5 to below 3.5 | **Level 3: Established** |' \
  '| 3.5 to 4.0 | **Level 4: Advanced** |' \
  '' \
  'An organization is Advanced when its score is 3.6 to 3.9.' \
  'Basic covers any score below 1.6.' \
  'A perfect result is Optimizing, with a Score 4.0.' \
  'An organization is Developing when its score is 1.5 to below 2.5.' \
  'Developing practices are covered in sections 1.6 to 2.4.2.' \
  '- **2.5.1**: Established practices' \
  > "$work/sentence.md"
start_case "case 7: ranges at the end of a sentence" "$work/sentence.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "three FAIL lines" '[ "$(fail_count)" -eq 3 ]'
expect "FAIL line for Advanced 3.6 to 3.9." \
  'has_fail "sentence.md line 6: Advanced is 3.6 to 3.9 here, but on the Scorecard it is 3.5 to 4.0"'
expect "FAIL line for Basic below 1.6." \
  'has_fail "sentence.md line 7: Basic is below 1.6 here, but on the Scorecard it is below 1.5"'
expect "FAIL line for Optimizing Score 4.0." \
  'has_fail "sentence.md line 8: Optimizing is given the score range 4.0, but the Scorecard labels no dimension or overall score Optimizing"'
expect "PASS line for Developing 1.5 to below 2.5." \
  'has_line "  PASS line 9: Developing 1.5 to below 2.5"'
expect "1.6 to 2.4.2 is not read as 1.6 to 2.4" \
  '! printf "%s\n" "$out" | grep -q "line 10: "'
expect "**2.5.1** is not read as 2.5" \
  '! printf "%s\n" "$out" | grep -q "line 11: "'
end_case

start_case "case 8: an empty file argument" ""
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL says no file name was given" \
  'printf "%s\n" "$out" | grep -qxF "  FAIL '"''"': no file name given"'
expect "no cannot read line" '! printf "%s\n" "$out" | grep -q "cannot read"'
end_case

make_copy "$toolkit" "$work/chartcut/QRAMM_Assessment_Toolkit.xlsx" \
  'COUNTIF(PracticeScoreOutcomes,"&gt;=3.5")/12' \
  'COUNTIFS(PracticeScoreOutcomes,"&gt;=3.6",PracticeScoreOutcomes,"&lt;4")/12'
start_case "case 9: a chart that counts Advanced from 3.6 to below 4" \
  "$work/chartcut/QRAMM_Assessment_Toolkit.xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line names Scorecard!M24 and both ranges" \
  'has_fail "chartcut/QRAMM_Assessment_Toolkit.xlsx Scorecard!M24: the Maturity Distribution chart counts 3.6 to below 4.0 as Advanced, but on the Scorecard Advanced is 3.5 to 4.0"'
end_case

make_copy "$toolkit" "$work/optimizing/QRAMM_Assessment_Toolkit.xlsx" \
  '<si><t>Incomplete Assessment</t></si>' '<si><t>Optimizing</t></si>' \
  'COUNTIF(PracticeScoreOutcomes,"-")/12' 'COUNTIF(PracticeScoreOutcomes,"&gt;=4")/12'
start_case "case 10: a chart category for Optimizing" \
  "$work/optimizing/QRAMM_Assessment_Toolkit.xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says the Scorecard labels no score Optimizing" \
  'has_fail "optimizing/QRAMM_Assessment_Toolkit.xlsx Scorecard!M25: the Maturity Distribution chart counts 4.0 as Optimizing, but the Scorecard labels no dimension or overall score Optimizing (Scorecard!H9:H12 and H14)"'
end_case

make_copy "$toolkit" "$work/nobasic/QRAMM_Assessment_Toolkit.xlsx" \
  'Scorecard!$L$21:$L$25' 'Scorecard!$L$22:$L$25' \
  'Scorecard!$M$21:$M$25' 'Scorecard!$M$22:$M$25'
start_case "case 11: a chart with no category for Basic" \
  "$work/nobasic/QRAMM_Assessment_Toolkit.xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says there is no category for Basic" \
  'has_fail "nobasic/QRAMM_Assessment_Toolkit.xlsx: the Maturity Distribution chart has no category for Basic"'
end_case

make_copy "$sample" "$work/oldwelcome/Sample_Assessment.xlsx" \
  'Below 1.5: Basic' '1.0 – 1.5: Basic' \
  'Optimizing, the fifth maturity level, has no raw score range.' \
  '4.0: Optimizing – Excellence and industry leadership'
start_case "case 12: Welcome!H9 text with the earlier ranges" \
  "$work/oldwelcome/Sample_Assessment.xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "two FAIL lines" '[ "$(fail_count)" -eq 2 ]'
expect "FAIL line for 1.0 – 1.5: Basic" \
  'has_fail "oldwelcome/Sample_Assessment.xlsx Welcome!H9 line 5: Basic is 1.0 to 1.5 here, but on the Scorecard it is below 1.5"'
expect "FAIL line for 4.0: Optimizing" \
  'has_fail "oldwelcome/Sample_Assessment.xlsx Welcome!H9 line 9: Optimizing is given the score range 4.0, but the Scorecard labels no dimension or overall score Optimizing (Scorecard!H9:H12 and H14)"'
end_case

printf '%s\n' 'Basic: below 1.5' > "$work/text.xlsx"
start_case "case 13: a text file whose name ends in .xlsx" "$work/text.xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says it is not a zip file" \
  'has_fail "text.xlsx: cannot read (not a zip file)"'
end_case

printf '%s\n' \
  '- 1.0 – 1.5: Basic' \
  '- 1.5 to below 2.5: Developing' \
  '- 2.5 to below 3.5: Established' \
  '- 3.5–4.0: Advanced' \
  '- 4.0: Optimizing' \
  '- Practice 1.1: Cryptographic discovery for Advanced programs' \
  > "$work/endash.md"
start_case "case 14: ranges with an en dash or before a level name" "$work/endash.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "two FAIL lines" '[ "$(fail_count)" -eq 2 ]'
expect "FAIL line for 1.0 – 1.5: Basic" \
  'has_fail "endash.md line 1: Basic is 1.0 to 1.5 here, but on the Scorecard it is below 1.5"'
expect "FAIL line for 4.0: Optimizing" \
  'has_fail "endash.md line 5: Optimizing is given the score range 4.0, but the Scorecard labels no dimension or overall score Optimizing (Scorecard!H9:H12 and H14)"'
expect "three PASS lines" '[ "$(printf "%s\n" "$out" | grep -c "^  PASS")" -eq 3 ]'
expect "PASS line for 3.5–4.0: Advanced" 'has_line "  PASS line 4: Advanced 3.5 to 4.0"'
expect "practice number 1.1: is not read as a range" \
  '! printf "%s\n" "$out" | grep -q "line 6: "'
end_case

make_copy "$toolkit" "$work/notcount/QRAMM_Assessment_Toolkit.xlsx" \
  'COUNTIF(PracticeScoreOutcomes,"&lt;1.5")/12' 'SUM(PracticeScoreOutcomes)/12'
start_case "case 15: a chart value that is not a count" \
  "$work/notcount/QRAMM_Assessment_Toolkit.xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line names Scorecard!M21 and the formula" \
  'has_fail "notcount/QRAMM_Assessment_Toolkit.xlsx Scorecard!M21: the Maturity Distribution chart value is not a count of practice scores in one range: SUM(PracticeScoreOutcomes)/12"'
end_case

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
