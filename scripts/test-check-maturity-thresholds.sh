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
#  16. Under the en_US.UTF-8 locale, a file argument that holds the byte
#      0xff, which is not valid UTF-8, and names no file, then the document
#      from case 5: exit 1, no traceback, the name printed with the byte as
#      \xff on its == line and in a FAIL line that says it cannot be read,
#      a PASS line for the Basic range of the case 5 document, then RESULT:
#      FAIL.
#  17. A workbook written with zipfile whose one text cell, Notes!A1, gives
#      the Scorecard's four ranges: exit 0, a PASS line for each range, and
#      RESULT: PASS. Cases 18 to 21 damage copies of it.
#  18. A copy whose sheet entry holds bytes that do not match the CRC-32 its
#      headers give.
#  19. A copy whose sheet entry gives compression method 12 (bzip2) but
#      holds the sheet's XML, which is not bzip2 data.
#  20. A copy whose end of central directory record gives a central
#      directory offset of twice the archive's length, past the end of the
#      file, so that the offset zipfile works out for each entry is
#      negative.
#  Cases 18 to 20 are zip archives that zipfile.is_zipfile() accepts. They
#  pass the copy and then a text document that gives the Scorecard's four
#  ranges: exit 1, nothing on stderr, one FAIL line, which says the copy is
#  not a workbook, a PASS line for each range of the text document, and
#  RESULT: FAIL as the last line.
#  21. A copy whose zip64 end of central directory locator gives two disks,
#      which zipfile does not open, then the text document of cases 18 to
#      20: the results of those cases, except that the FAIL line says the
#      copy is not a zip file. zipfile.is_zipfile() returns False for this
#      archive in Python 3.13.12 and 3.14.3, and raises BadZipFile for it in
#      Python 3.9.6.
#  22. A text document with a Latin-1 byte, then a document that gives the
#      Scorecard's four ranges: exit 1, no traceback, one FAIL line, which
#      says the first is not UTF-8 text, four PASS lines for the second,
#      then RESULT: FAIL.
#  23. Under the en_US.ISO8859-1 locale, a file argument that is valid UTF-8
#      and holds the character U+65E5, which ISO-8859-1 cannot encode, and
#      names no file, then the document from case 5: exit 1, nothing on
#      stderr, the name printed with the character as \u65e5 on its == line
#      and in a FAIL line that says it cannot be read (No such file or
#      directory), a PASS line for the Basic range of the case 5 document,
#      then RESULT: FAIL. The case is skipped, with a line that says so, when
#      python3 -I does not decode file names as UTF-8 and write stdout as
#      ISO-8859-1 under that locale on this machine.
#  24. A copy of the toolkit workbook whose text cell Welcome!H9 stores the
#      shared string index 99999999, past the end of the shared string
#      table, in place of its index 1820.
#  25. A copy whose Welcome!H9 stores the index 1820 written as +1820.
#  26. A copy whose Welcome!H9 stores the index written as " 1820", a space
#      followed by 1820.
#  27. A copy whose Welcome!H9 stores the index written as "1820 ", 1820
#      followed by a space.
#  28. A copy whose Welcome!H9 stores the index written as 18_20.
#  29. A copy whose Welcome!H9 stores the index written with the
#      ARABIC-INDIC digits U+0661, U+0668, U+0662 and U+0660.
#  30. A copy whose Welcome!H9 stores -1 in place of the index 1820.
#  Cases 24 to 30 pass the copy and then the text document of cases 18 to
#  20, and give the results of those cases: the copy of cases 25 to 30
#  fails as the copy of case 24 does. int() strips whitespace from the
#  start and end of text, reads a leading sign, allows an underscore
#  between two digits and reads the other Unicode decimal digits, so it
#  reads the index of cases 25 to 29 as 1820, and -1 as the index of the
#  last shared string.
#  31. A copy of the toolkit workbook whose Basic chart value, Scorecard!M21,
#      has 8,152 spaces after its divisor, so that its formula is 8,192
#      characters long, the most Excel allows: exit 0, a PASS line for
#      Scorecard!M21, and RESULT: PASS.
#  32. A copy whose Scorecard!M21 formula has 8,153 spaces after its
#      divisor, so that it is 8,193 characters long: exit 1, one FAIL line,
#      which names Scorecard!M21 and says the formula is longer than the
#      8,192 characters Excel allows.
#  33. The checker loaded as a module, count_criteria() called on COUNTIF(
#      followed by 32,768 spaces and )/12, and criteria_band() called on one
#      criterion of 32,768 spaces: exit 0, nothing on stderr, and each call
#      returns None and uses less than one second of CPU time. A call still
#      running after 10 seconds is stopped, and the case fails.
#  34. A document that gives the four Scorecard ranges, but writes Basic as
#      "below" followed by U+0661, a period and U+0665 (ARABIC-INDIC DIGIT
#      ONE and FIVE): exit 1, one FAIL line, which names line 1 and says the
#      number has a digit other than 0 to 9, PASS lines for lines 2 to 4,
#      and RESULT: FAIL.
#  35. The same document with Basic written as "below 1.5" and Developing
#      as "1.5 to below" followed by U+FF12, a period and U+FF15 (FULLWIDTH
#      DIGIT TWO and FIVE): exit 1, one FAIL line, which names line 2.
#  36. A copy of the toolkit workbook whose Scorecard!M21 formula compares
#      with U+0661, a period and U+0665 in place of 1.5: exit 1, one FAIL
#      line, which names Scorecard!M21 and says the number has a digit
#      other than 0 to 9.
#  37. A copy of the repository whose toolkit workbook gives the Advanced
#      cut-off of each of the five Scorecard formulas, Scorecard!H9:H12 and
#      H14, as U+0663, a period and U+0665 (ARABIC-INDIC DIGIT THREE and
#      FIVE) in place of 3.5, then the text document of cases 18 to 20:
#      exit 1, five FAIL lines, one for each formula, which say the number
#      has a digit other than 0 to 9, no Scorecard ranges listed, no PASS
#      line, and RESULT: FAIL.
#  38. A copy of the toolkit workbook whose Maturity Distribution chart
#      value range starts at the row U+0662 U+0661 (ARABIC-INDIC DIGIT TWO
#      and ONE) in place of 21: exit 1, one FAIL line, which says the number
#      of a row of the value range has a digit other than 0 to 9, and no
#      PASS line for the chart.
#  39. A copy whose chart category range ends at the row U+0662 U+0665 in
#      place of 25: exit 1, one FAIL line, which says the same of a row of
#      the category range, and no PASS line for the chart.
#  float() and int() read every Unicode decimal digit, so the checker read
#  the numbers of cases 34 to 36 as 1.5 and 2.5, the cut-off of case 37 as
#  3.5, and the rows of cases 38 and 39 as 21 and 25.
#  40. A copy of the repository whose toolkit workbook has the document type
#      declaration <!DOCTYPE r [<!ENTITY e0 "FAKE">]> after the XML
#      declaration of xl/workbook.xml.
#  41. A copy whose toolkit workbook has <unclosed after the root element of
#      xl/workbook.xml, so that its XML is not well-formed.
#  42. A copy whose toolkit workbook has an XML declaration in
#      xl/workbook.xml that names the encoding x-bogus, which Python has no
#      codec for.
#  43. A copy whose toolkit workbook has an XML declaration in
#      xl/workbook.xml that names the encoding shift_jis, a multi-byte
#      encoding the XML parser does not read.
#  44. A copy whose toolkit workbook does not hold xl/workbook.xml.
#  Cases 40 to 44 pass the text document of cases 18 to 20: exit 1, nothing
#  on stderr, one FAIL line, which says
#  "toolkit/QRAMM_Assessment_Toolkit.xlsx: cannot read" and gives the reason
#  in parentheses, no Scorecard ranges listed, no == line for the text
#  document, no PASS line, and RESULT: FAIL as the last line. The reason is
#  "document type declaration" and "junk after document element", each
#  followed by the line and column where the XML parser stopped, "unknown
#  encoding: x-bogus", "multi-byte encodings are not supported", and "There
#  is no item named 'xl/workbook.xml' in the archive" in double quotes.
#  45. A copy of the repository with no toolkit workbook.
#  46. A copy whose toolkit workbook is a text file.
#  47. A copy whose toolkit workbook has an xl/workbook.xml entry that does
#      not match the CRC-32 that both of its headers give.
#  48. A copy whose toolkit workbook has no Target attribute on its
#      Relationship element with Id rId8, the relationship of the
#      Compliance sheet.
#  Cases 45 to 48 pass the text document of cases 18 to 20 and give the
#  results of cases 40 to 44. The reason is "No such file or directory",
#  "File is not a zip file", "Bad CRC-32 for file 'xl/workbook.xml'" and
#  "xl/_rels/workbook.xml.rels has a Relationship element with Id rId8 and
#  no Target attribute".
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

# \377 is the byte 0xff, which is not valid UTF-8, so Python holds it as a
# lone surrogate. Under en_US.UTF-8 printing that raises UnicodeEncodeError;
# the C, C.UTF-8 and UTF-8 locales write the byte as it is. The checker is
# expected to print \xff in either case. No file is made with this name.
LC_ALL=en_US.UTF-8 start_case "case 16: a file argument that is not UTF-8" \
  "$work/bad$(printf '\377').md" "$work/fenced.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "the name is printed with the byte as \\xff" \
  "has_line '== $work/bad\\xff.md against the Scorecard'"
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says the file cannot be read and gives the byte as \\xff" \
  "has_fail '$work/bad\\xff.md: cannot read ('"
expect "the case 5 document is checked" \
  "has_line '== $work/fenced.md against the Scorecard' && has_line '  PASS line 1: Basic below 1.5'"
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

# Writes a zip archive at $1 with one entry per remaining argument, each of
# the form name=content. zipfile stores each entry without compression.
make_zip() {
  python3 -I - "$@" <<'PY'
import sys
import zipfile

with zipfile.ZipFile(sys.argv[1], "w") as book:
    for entry in sys.argv[2:]:
        name, _, content = entry.partition("=")
        book.writestr(name, content)
PY
}

# Sets the compression method ($3) and the general purpose flags ($4) that
# both headers of the entry $2 give in the zip archive at $1, and leaves the
# bytes stored for the entry as they are.
set_entry() {
  python3 -I - "$@" <<'PY'
import struct
import sys
import zipfile

path, name = sys.argv[1:3]
method, flags = int(sys.argv[3]), int(sys.argv[4])
with zipfile.ZipFile(path) as book:
    infos = book.infolist()
with open(path, "rb") as fh:
    data = bytearray(fh.read())
# The archive has no comment, so its last 22 bytes are the end of central
# directory record, which ends with the central directory's offset and a
# 2-byte comment length.
(directory,) = struct.unpack_from("<I", data, len(data) - 6)
found = 0
for info in infos:
    if info.filename == name:
        found += 1
        struct.pack_into("<HH", data, info.header_offset + 6, flags, method)
        struct.pack_into("<HH", data, directory + 8, flags, method)
    names, extra, comment = struct.unpack_from("<HHH", data, directory + 28)
    directory += 46 + names + extra + comment
with open(path, "wb") as fh:
    fh.write(data)
sys.exit(0 if found else 1)
PY
}

# Replaces the first "$2" in the bytes of the zip archive at $1 with "$3",
# which has the same length, and changes nothing else. Fails when the
# archive does not hold "$2" or when "$3" has another length.
replace_first() {
  python3 -I - "$@" <<'PY'
import sys

path = sys.argv[1]
old, new = sys.argv[2].encode("utf-8"), sys.argv[3].encode("utf-8")
with open(path, "rb") as fh:
    data = fh.read()
if old not in data or len(new) != len(old):
    sys.exit(1)
with open(path, "wb") as fh:
    fh.write(data.replace(old, new, 1))
PY
}

# Sets the central directory offset that the end of central directory record
# of the zip archive at $1 gives to twice the archive's length, which is past
# the end of the file.
move_directory() {
  python3 -I - "$1" <<'PY'
import struct
import sys

path = sys.argv[1]
with open(path, "rb") as fh:
    data = bytearray(fh.read())
# The archive has no comment, so its last 22 bytes are the end of central
# directory record, which ends with the central directory's offset and a
# 2-byte comment length.
struct.pack_into("<I", data, len(data) - 6, 2 * len(data))
with open(path, "wb") as fh:
    fh.write(data)
PY
}

# Puts a zip64 end of central directory locator that gives two disks just
# before the end of central directory record of the zip archive at $1.
give_two_disks() {
  python3 -I - "$1" <<'PY'
import struct
import sys

path = sys.argv[1]
with open(path, "rb") as fh:
    data = fh.read()
# The archive has no comment, so its last 22 bytes are the end of central
# directory record. The locator is its signature, the disk that holds the
# zip64 end of central directory record, that record's offset and the
# number of disks.
locator = struct.pack("<4sLQL", b"PK\x06\x07", 0, 0, 2)
with open(path, "wb") as fh:
    fh.write(data[:-22] + locator + data[-22:])
PY
}

main_ns='http://schemas.openxmlformats.org/spreadsheetml/2006/main'
rel_ns='http://schemas.openxmlformats.org/officeDocument/2006/relationships'
pkg_rel_ns='http://schemas.openxmlformats.org/package/2006/relationships'
book_xml="xl/workbook.xml=<workbook xmlns=\"$main_ns\" xmlns:r=\"$rel_ns\"><sheets><sheet name=\"Notes\" sheetId=\"1\" r:id=\"rId1\"/></sheets></workbook>"
rels_xml="xl/_rels/workbook.xml.rels=<Relationships xmlns=\"$pkg_rel_ns\"><Relationship Id=\"rId1\" Target=\"worksheets/sheet1.xml\"/></Relationships>"
# &#10; is a line break, so the text cell has one line for each range.
strings_xml="xl/sharedStrings.xml=<sst xmlns=\"$main_ns\"><si><t>Below 1.5: Basic&#10;1.5 to below 2.5: Developing&#10;2.5 to below 3.5: Established&#10;3.5 to 4.0: Advanced</t></si></sst>"
sheet_xml="xl/worksheets/sheet1.xml=<worksheet xmlns=\"$main_ns\"><sheetData><row r=\"1\"><c r=\"A1\" t=\"s\"><v>0</v></c></row></sheetData></worksheet>"

make_zip "$work/book.xlsx" "$book_xml" "$rels_xml" "$strings_xml" "$sheet_xml"
start_case "case 17: a workbook written with zipfile" "$work/book.xlsx"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "a PASS line for each range of Notes!A1" \
  '[ "$(printf "%s\n" "$out" | grep -c "^  PASS")" -eq 4 ] &&
   has_line "  PASS Notes!A1 line 1: Basic below 1.5" &&
   has_line "  PASS Notes!A1 line 4: Advanced 3.5 to 4.0"'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
end_case

printf '%s\n' \
  'Below 1.5: Basic' \
  '1.5 to below 2.5: Developing' \
  '2.5 to below 3.5: Established' \
  '3.5 to 4.0: Advanced' \
  > "$work/ranges.md"

# Expectations for cases 18 to 21 and 24 to 30: $1 is the copy's file name
# and $2 the reason its FAIL line gives.
expect_cannot_read() {
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "no traceback on stderr" '[ -z "$err" ]'
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line says it is $2" "has_fail '$1: cannot read ($2)'"
  expect "the document after it is checked" \
    'has_line "== $work/ranges.md against the Scorecard" &&
     [ "$(printf "%s\n" "$out" | grep -c "^  PASS line ")" -eq 4 ]'
  expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
}

# The cell reference is changed in the stored sheet data, so only the CRC-32
# check fails: the cell still holds the text that gives the ranges.
make_zip "$work/badcrc.xlsx" "$book_xml" "$rels_xml" "$strings_xml" "$sheet_xml"
replace_first "$work/badcrc.xlsx" 'r="A1"' 'r="B1"'
start_case "case 18: an entry whose data does not match its CRC-32" \
  "$work/badcrc.xlsx" "$work/ranges.md"
expect_cannot_read badcrc.xlsx "not a workbook"
end_case

make_zip "$work/bzip2.xlsx" "$book_xml" "$rels_xml" "$strings_xml" "$sheet_xml"
set_entry "$work/bzip2.xlsx" xl/worksheets/sheet1.xml 12 0
start_case "case 19: bzip2 data that does not decompress" \
  "$work/bzip2.xlsx" "$work/ranges.md"
expect_cannot_read bzip2.xlsx "not a workbook"
end_case

make_zip "$work/badoffset.xlsx" "$book_xml" "$rels_xml" "$strings_xml" "$sheet_xml"
move_directory "$work/badoffset.xlsx"
start_case "case 20: a central directory offset past the end of the file" \
  "$work/badoffset.xlsx" "$work/ranges.md"
expect_cannot_read badoffset.xlsx "not a workbook"
end_case

make_zip "$work/twodisk.xlsx" "$book_xml" "$rels_xml" "$strings_xml" "$sheet_xml"
give_two_disks "$work/twodisk.xlsx"
start_case "case 21: a zip64 locator that gives two disks" \
  "$work/twodisk.xlsx" "$work/ranges.md"
expect_cannot_read twodisk.xlsx "not a zip file"
end_case

# \351 is e with an acute accent in Latin-1, and not valid UTF-8 here.
printf 'Basic: below 1.5, caf\351.\n' > "$work/latin1.md"
printf '%s\n' \
  '## Level 1: Basic (Score below 1.5)' \
  '## Level 2: Developing (Score 1.5 to below 2.5)' \
  '## Level 3: Established (Score 2.5 to below 3.5)' \
  '## Level 4: Advanced (Score 3.5 to 4.0)' \
  > "$work/levels.md"
start_case "case 22: a text document that is not UTF-8" "$work/latin1.md" "$work/levels.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says it is not UTF-8 text" \
  'has_fail "latin1.md: cannot read (not UTF-8 text)"'
expect "the next document is checked" \
  'has_line "== $work/levels.md against the Scorecard" &&
   has_line "  PASS line 4: Advanced 3.5 to 4.0"'
expect "four PASS lines" '[ "$(printf "%s\n" "$out" | grep -c "^  PASS")" -eq 4 ]'
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

# \346\227\245 is U+65E5 encoded as UTF-8. Under en_US.ISO8859-1 on macOS,
# python3 decodes the name as UTF-8 and writes stdout as ISO-8859-1, which
# has no byte for U+65E5, so printing the name as it is raises
# UnicodeEncodeError. The checker is expected to print \u65e5 in its place.
# No file is made with this name.
title="case 23: a file argument that stdout's encoding cannot hold"
probe="$(LC_ALL=en_US.ISO8859-1 python3 -I -c 'import codecs, sys; print(codecs.lookup(sys.getfilesystemencoding()).name, codecs.lookup(sys.stdout.encoding).name)' 2>&1 || true)"
if [ "$probe" = "utf-8 iso8859-1" ]; then
  LC_ALL=en_US.ISO8859-1 start_case "$title" \
    "$work/$(printf '\346\227\245').md" "$work/fenced.md"
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "no traceback on stderr" '[ -z "$err" ]'
  expect "the name is printed with the character as \\u65e5" \
    "has_line '== $work/\\u65e5.md against the Scorecard'"
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line says the file cannot be read and gives the character as \\u65e5" \
    "has_line '  FAIL $work/\\u65e5.md: cannot read (No such file or directory)'"
  expect "the case 5 document is checked" \
    "has_line '== $work/fenced.md against the Scorecard' && has_line '  PASS line 1: Basic below 1.5'"
  expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
  end_case
else
  echo "$title"
  echo "  skip python3 does not decode file names as UTF-8 and write stdout as ISO-8859-1 under en_US.ISO8859-1 here ($probe)"
fi

# The text cell Welcome!H9 of the toolkit workbook stores the shared string
# index 1820, the index of the text that gives the score ranges.
h9='<c r="H9" s="205" t="s"><v>1820</v>'

make_copy "$toolkit" "$work/endindex.xlsx" "$h9" '<c r="H9" s="205" t="s"><v>99999999</v>'
start_case "case 24: a shared string index past the end of the table" \
  "$work/endindex.xlsx" "$work/ranges.md"
expect_cannot_read endindex.xlsx "not a workbook"
end_case

make_copy "$toolkit" "$work/plusindex.xlsx" "$h9" '<c r="H9" s="205" t="s"><v>+1820</v>'
start_case "case 25: a shared string index written with a plus sign" \
  "$work/plusindex.xlsx" "$work/ranges.md"
expect_cannot_read plusindex.xlsx "not a workbook"
end_case

make_copy "$toolkit" "$work/spaceindex.xlsx" "$h9" '<c r="H9" s="205" t="s"><v> 1820</v>'
start_case "case 26: a shared string index written after a space" \
  "$work/spaceindex.xlsx" "$work/ranges.md"
expect_cannot_read spaceindex.xlsx "not a workbook"
end_case

make_copy "$toolkit" "$work/indexspace.xlsx" "$h9" '<c r="H9" s="205" t="s"><v>1820 </v>'
start_case "case 27: a shared string index written before a space" \
  "$work/indexspace.xlsx" "$work/ranges.md"
expect_cannot_read indexspace.xlsx "not a workbook"
end_case

make_copy "$toolkit" "$work/underscoreindex.xlsx" "$h9" '<c r="H9" s="205" t="s"><v>18_20</v>'
start_case "case 28: a shared string index written with an underscore" \
  "$work/underscoreindex.xlsx" "$work/ranges.md"
expect_cannot_read underscoreindex.xlsx "not a workbook"
end_case

# \331\241\331\250\331\242\331\240 is U+0661, U+0668, U+0662 and U+0660
# (ARABIC-INDIC DIGIT ONE, EIGHT, TWO and ZERO) encoded as UTF-8.
make_copy "$toolkit" "$work/arabicindex.xlsx" "$h9" \
  "<c r=\"H9\" s=\"205\" t=\"s\"><v>$(printf '\331\241\331\250\331\242\331\240')</v>"
start_case "case 29: a shared string index written with ARABIC-INDIC digits" \
  "$work/arabicindex.xlsx" "$work/ranges.md"
expect_cannot_read arabicindex.xlsx "not a workbook"
end_case

make_copy "$toolkit" "$work/negativeindex.xlsx" "$h9" '<c r="H9" s="205" t="s"><v>-1</v>'
start_case "case 30: a negative shared string index" \
  "$work/negativeindex.xlsx" "$work/ranges.md"
expect_cannot_read negativeindex.xlsx "not a workbook"
end_case

# The Basic chart value of the toolkit workbook, Scorecard!M21. Parsed, its
# formula is 40 characters long.
basic='COUNTIF(PracticeScoreOutcomes,"&lt;1.5")/12'

make_copy "$toolkit" "$work/longest/QRAMM_Assessment_Toolkit.xlsx" \
  "$basic" "$basic$(printf '%8152s' '')"
start_case "case 31: a chart value formula of 8,192 characters" \
  "$work/longest/QRAMM_Assessment_Toolkit.xlsx"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "PASS line for Scorecard!M21" 'has_line "  PASS Scorecard!M21: Basic below 1.5"'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
end_case

make_copy "$toolkit" "$work/toolong/QRAMM_Assessment_Toolkit.xlsx" \
  "$basic" "$basic$(printf '%8153s' '')"
start_case "case 32: a chart value formula of 8,193 characters" \
  "$work/toolong/QRAMM_Assessment_Toolkit.xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line names Scorecard!M21 and says the formula is too long" \
  'has_fail "toolong/QRAMM_Assessment_Toolkit.xlsx Scorecard!M21: the Maturity Distribution chart value is a formula of 8,193 characters, longer than the 8,192 Excel allows"'
end_case

# Loads the checker as a module and calls count_criteria() and
# criteria_band() on a run of 32,768 spaces. For each call prints its name,
# what it returned and the seconds of CPU time it used. SIGALRM stops a call
# still running after 10 seconds, and its line then says "timed out" in
# place of what it returned. -B keeps python3 from writing a bytecode cache
# of the checker under scripts/. Sets out, err and status.
run_calls() {
  status=0
  python3 -B -I - "$checker" > "$work/out" 2> "$work/err" <<'PY' || status=$?
import importlib.util
import signal
import sys
import time

spec = importlib.util.spec_from_file_location("checker", sys.argv[1])
checker = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checker)


def stop(signum, frame):
    raise TimeoutError


signal.signal(signal.SIGALRM, stop)
spaces = " " * 32768
calls = [
    ("count_criteria", checker.count_criteria, "COUNTIF(" + spaces + ")/12"),
    ("criteria_band", checker.criteria_band, [spaces]),
]
for name, function, argument in calls:
    start = time.process_time()
    signal.alarm(10)
    try:
        result = function(argument)
    except TimeoutError:
        result = "timed out"
    signal.alarm(0)
    print("{} {} {:.3f}".format(name, result, time.process_time() - start))
PY
  out="$(cat "$work/out")"
  err="$(cat "$work/err")"
}

# True when out has a line for the call $1 that says it returned None and
# used less than one second of CPU time.
returned_none_quickly() {
  printf '%s\n' "$out" | awk -v name="$1" '
    $1 == name && $2 == "None" && $3 < 1 { found = 1 }
    END { exit !found }'
}

echo "case 33: a run of 32,768 spaces in the arguments and in a criterion"
case_failed="$failed"
failed=0
run_calls
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "nothing on stderr" '[ -z "$err" ]'
expect "count_criteria returns None in under a second" 'returned_none_quickly count_criteria'
expect "criteria_band returns None in under a second" 'returned_none_quickly criteria_band'
end_case

# \331\241 and \331\245 are U+0661 and U+0665 (ARABIC-INDIC DIGIT ONE and
# FIVE) encoded as UTF-8.
printf '%s\n' \
  "- Basic: below $(printf '\331\241.\331\245')" \
  '- Developing: 1.5 to below 2.5' \
  '- Established: 2.5 to below 3.5' \
  '- Advanced: 3.5 to 4.0' \
  > "$work/arabic.md"
start_case "case 34: a score range written with ARABIC-INDIC digits" "$work/arabic.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line names line 1 and says the number has a digit other than 0 to 9" \
  "has_fail \"arabic.md line 1: the score range for Basic: the number '\\u0661.\\u0665' has a digit other than 0 to 9\""
expect "PASS lines for lines 2 to 4" \
  'has_line "  PASS line 2: Developing 1.5 to below 2.5" &&
   has_line "  PASS line 3: Established 2.5 to below 3.5" &&
   has_line "  PASS line 4: Advanced 3.5 to 4.0"'
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

# \357\274\222 and \357\274\225 are U+FF12 and U+FF15 (FULLWIDTH DIGIT TWO
# and FIVE) encoded as UTF-8.
printf '%s\n' \
  '- Basic: below 1.5' \
  "- Developing: 1.5 to below $(printf '\357\274\222.\357\274\225')" \
  '- Established: 2.5 to below 3.5' \
  '- Advanced: 3.5 to 4.0' \
  > "$work/fullwidth.md"
start_case "case 35: the end of a score range written with FULLWIDTH digits" \
  "$work/fullwidth.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line names line 2 and says the number has a digit other than 0 to 9" \
  "has_fail \"fullwidth.md line 2: the score range for Developing: the number '\\uff12.\\uff15' has a digit other than 0 to 9\""
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

make_copy "$toolkit" "$work/arabiccount/QRAMM_Assessment_Toolkit.xlsx" \
  "$basic" 'COUNTIF(PracticeScoreOutcomes,"&lt;&#x661;.&#x665;")/12'
start_case "case 36: a chart value criterion written with ARABIC-INDIC digits" \
  "$work/arabiccount/QRAMM_Assessment_Toolkit.xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line names Scorecard!M21 and says the number has a digit other than 0 to 9" \
  "has_fail \"arabiccount/QRAMM_Assessment_Toolkit.xlsx Scorecard!M21: the Maturity Distribution chart value: the number '\\u0661.\\u0665' has a digit other than 0 to 9\""
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

# Lays out a copy of the repository at $1: a copy of the checker in scripts/
# and, in toolkit/, a copy of the toolkit workbook made by make_copy with the
# remaining arguments. The copy of the checker reads the Scorecard from that
# copy of the workbook.
copy_repository() {
  mkdir -p "$1/scripts"
  cp "$checker" "$1/scripts/check-maturity-thresholds.py"
  make_copy "$toolkit" "$1/$toolkit" "${@:2}"
}

# True when out has the FAIL line for the Scorecard formula in $1 whose
# Advanced cut-off is U+0663, a period and U+0665.
has_cut_off_fail() {
  has_fail "toolkit/QRAMM_Assessment_Toolkit.xlsx: Scorecard!$1: the cut-off for Advanced: the number '\\u0663.\\u0665' has a digit other than 0 to 9"
}

# &#x663; and &#x665; are U+0663 and U+0665 (ARABIC-INDIC DIGIT THREE and
# FIVE) written as XML character references. The assignment in front of
# start_case runs the copy of the checker for this case only.
copy_repository "$work/arabiccut" \
  '&gt;=3.5,"Advanced"' '&gt;=&#x663;.&#x665;,"Advanced"'
checker="$work/arabiccut/scripts/check-maturity-thresholds.py" \
  start_case "case 37: Scorecard cut-offs written with ARABIC-INDIC digits" \
  "$work/ranges.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "five FAIL lines" '[ "$(fail_count)" -eq 5 ]'
expect "a FAIL line for each formula says the number has a digit other than 0 to 9" \
  'has_cut_off_fail H9 && has_cut_off_fail H10 && has_cut_off_fail H11 &&
   has_cut_off_fail H12 && has_cut_off_fail H14'
expect "no Scorecard ranges are listed" \
  '! has_line "== $toolkit Scorecard!H9:H12 and H14" && ! has_line "  Advanced 3.5 to 4.0"'
expect "no PASS line" '! printf "%s\n" "$out" | grep -q "^  PASS"'
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

# &#x662; and &#x661; are U+0662 and U+0661 (ARABIC-INDIC DIGIT TWO and ONE)
# written as XML character references.
make_copy "$toolkit" "$work/arabicrow/QRAMM_Assessment_Toolkit.xlsx" \
  'Scorecard!$M$21:$M$25' 'Scorecard!$M$&#x662;&#x661;:$M$25'
start_case "case 38: a chart value range that starts at a row written with ARABIC-INDIC digits" \
  "$work/arabicrow/QRAMM_Assessment_Toolkit.xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says the number of a row of the value range has a digit other than 0 to 9" \
  "has_fail \"arabicrow/QRAMM_Assessment_Toolkit.xlsx: Maturity Distribution chart: a row of the value range: the number '\\u0662\\u0661' has a digit other than 0 to 9\""
expect "no PASS line for the chart" '! printf "%s\n" "$out" | grep -q "^  PASS Scorecard!"'
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

# &#x665; is U+0665 (ARABIC-INDIC DIGIT FIVE).
make_copy "$toolkit" "$work/arabiclast/QRAMM_Assessment_Toolkit.xlsx" \
  'Scorecard!$L$21:$L$25' 'Scorecard!$L$21:$L$&#x662;&#x665;'
start_case "case 39: a chart category range that ends at a row written with ARABIC-INDIC digits" \
  "$work/arabiclast/QRAMM_Assessment_Toolkit.xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says the number of a row of the category range has a digit other than 0 to 9" \
  "has_fail \"arabiclast/QRAMM_Assessment_Toolkit.xlsx: Maturity Distribution chart: a row of the category range: the number '\\u0662\\u0665' has a digit other than 0 to 9\""
expect "no PASS line for the chart" '! printf "%s\n" "$out" | grep -q "^  PASS Scorecard!"'
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

# Writes to $2 a copy of the workbook $1 whose xl/workbook.xml is edited as
# $3 says: doctype puts <!DOCTYPE r [<!ENTITY e0 "FAKE">]> after its XML
# declaration, unclosed puts <unclosed at its end, after its root element,
# encoding=<name> makes its XML declaration name the encoding <name>, and
# missing leaves the part out of the copy. Fails when the workbook has no
# xl/workbook.xml that starts with an XML declaration naming an encoding.
break_workbook_xml() {
  python3 -I - "$@" <<'PY'
import re
import sys
import zipfile

source, target, edit = sys.argv[1:4]
part = "xl/workbook.xml"
declaration = re.compile(rb'<\?xml[^>]*\bencoding="[^"]*"[^>]*\?>')
found = False
with zipfile.ZipFile(source) as book, zipfile.ZipFile(target, "w") as copy:
    for info in book.infolist():
        data = book.read(info.filename)
        if info.filename == part:
            found = True
            head = declaration.match(data)
            if head is None:
                sys.exit("%s: %s has no XML declaration that names an encoding" % (source, part))
            if edit == "missing":
                continue
            if edit == "doctype":
                data = data[:head.end()] + b'<!DOCTYPE r [<!ENTITY e0 "FAKE">]>' + data[head.end():]
            elif edit == "unclosed":
                data += b"<unclosed"
            elif edit.startswith("encoding="):
                name = edit[len("encoding="):].encode("ascii")
                named = re.sub(rb'\bencoding="[^"]*"', b'encoding="' + name + b'"', head.group())
                data = named + data[head.end():]
            else:
                sys.exit("unknown edit: %s" % edit)
        copy.writestr(info, data)
if not found:
    sys.exit("%s has no part %s" % (source, part))
PY
}

# Lays out a copy of the repository at $1, as copy_repository does, with a
# copy of the toolkit workbook made by break_workbook_xml with the edit $2.
break_repository() {
  mkdir -p "$1/scripts" "$1/toolkit"
  cp "$checker" "$1/scripts/check-maturity-thresholds.py"
  break_workbook_xml "$root/$toolkit" "$1/$toolkit" "$2"
}

# Writes to $2 a copy of the workbook $1 damaged as $3 says: crc changes the
# CRC-32 that both headers of the entry xl/workbook.xml give, so that the
# entry's data does not match it, and no-target removes the Target attribute
# of the Relationship element with Id rId8 in xl/_rels/workbook.xml.rels.
# Fails when the workbook does not have exactly one such entry or attribute.
damage_workbook() {
  python3 -I - "$@" <<'PY'
import re
import struct
import sys
import zipfile

source, target, edit = sys.argv[1:4]
if edit not in ("crc", "no-target"):
    sys.exit("unknown edit: %s" % edit)
found = 0
with zipfile.ZipFile(source) as book, zipfile.ZipFile(target, "w") as copy:
    for info in book.infolist():
        data = book.read(info.filename)
        if edit == "no-target" and info.filename == "xl/_rels/workbook.xml.rels":
            data, found = re.subn(
                rb'(<Relationship Id="rId8"[^>]*?) Target="[^"]*"', rb"\1", data
            )
        copy.writestr(info, data)
if edit == "crc":
    with zipfile.ZipFile(target) as book:
        infos = book.infolist()
    with open(target, "rb") as fh:
        data = bytearray(fh.read())
    # The copy has no comment, so its last 22 bytes are the end of central
    # directory record, which ends with the central directory's offset and a
    # 2-byte comment length.
    (directory,) = struct.unpack_from("<I", data, len(data) - 6)
    for info in infos:
        if info.filename == "xl/workbook.xml":
            found += 1
            # The CRC-32 is at offset 14 of the local file header and at
            # offset 16 of the central directory header.
            crc = info.CRC ^ 0xFFFFFFFF
            struct.pack_into("<I", data, info.header_offset + 14, crc)
            struct.pack_into("<I", data, directory + 16, crc)
        names, extra, comment = struct.unpack_from("<HHH", data, directory + 28)
        directory += 46 + names + extra + comment
    with open(target, "wb") as fh:
        fh.write(data)
if found != 1:
    sys.exit("%s: %d places for the edit %s, expected 1" % (source, found, edit))
PY
}

# Lays out a copy of the repository at $1, as copy_repository does, with the
# toolkit workbook as $2 says: missing leaves it out, text writes a text file
# in its place, and crc or no-target writes a copy of it made by
# damage_workbook with that edit.
damage_repository() {
  mkdir -p "$1/scripts" "$1/toolkit"
  cp "$checker" "$1/scripts/check-maturity-thresholds.py"
  case "$2" in
    missing) ;;
    text) printf 'This is a text file, not a workbook.\n' > "$1/$toolkit" ;;
    *) damage_workbook "$root/$toolkit" "$1/$toolkit" "$2" ;;
  esac
}

# The expect lines of cases 40 to 48, whose copy of the repository has a
# toolkit workbook that cannot be read, or none. $1 is the reason the FAIL
# line gives in parentheses, as an extended regular expression.
expect_scorecard_unreadable() {
  local fail_pattern="  FAIL toolkit/QRAMM_Assessment_Toolkit\\.xlsx: cannot read \\($1\\)"
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "no traceback on stderr" '[ -z "$err" ]'
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line names the workbook and the reason" \
    'printf "%s\n" "$out" | grep -q -x -E -- "$fail_pattern"'
  expect "no Scorecard ranges are listed" '! has_line "== $toolkit Scorecard!H9:H12 and H14"'
  expect "the text document is not checked" \
    '! has_line "== $work/ranges.md against the Scorecard"'
  expect "no PASS line" '! printf "%s\n" "$out" | grep -q "^  PASS"'
  expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
}

# The assignment in front of start_case runs the copy of the checker for
# that case only, as in case 37.
break_repository "$work/book-doctype" doctype
checker="$work/book-doctype/scripts/check-maturity-thresholds.py" \
  start_case "case 40: xl/workbook.xml has a document type declaration" \
  "$work/ranges.md"
expect_scorecard_unreadable 'document type declaration: line [0-9]+, column [0-9]+'
end_case

break_repository "$work/book-unclosed" unclosed
checker="$work/book-unclosed/scripts/check-maturity-thresholds.py" \
  start_case "case 41: xl/workbook.xml has <unclosed after its root element" \
  "$work/ranges.md"
expect_scorecard_unreadable 'junk after document element: line [0-9]+, column [0-9]+'
end_case

break_repository "$work/book-x-bogus" encoding=x-bogus
checker="$work/book-x-bogus/scripts/check-maturity-thresholds.py" \
  start_case "case 42: the XML declaration of xl/workbook.xml names the encoding x-bogus" \
  "$work/ranges.md"
expect_scorecard_unreadable 'unknown encoding: x-bogus'
end_case

break_repository "$work/book-shift-jis" encoding=shift_jis
checker="$work/book-shift-jis/scripts/check-maturity-thresholds.py" \
  start_case "case 43: the XML declaration of xl/workbook.xml names the encoding shift_jis" \
  "$work/ranges.md"
expect_scorecard_unreadable 'multi-byte encodings are not supported'
end_case

break_repository "$work/book-missing" missing
checker="$work/book-missing/scripts/check-maturity-thresholds.py" \
  start_case "case 44: the toolkit workbook does not hold xl/workbook.xml" \
  "$work/ranges.md"
expect_scorecard_unreadable "\"There is no item named 'xl/workbook\\.xml' in the archive\""
end_case

damage_repository "$work/no-workbook" missing
checker="$work/no-workbook/scripts/check-maturity-thresholds.py" \
  start_case "case 45: there is no toolkit workbook" \
  "$work/ranges.md"
expect_scorecard_unreadable 'No such file or directory'
end_case

damage_repository "$work/text-workbook" text
checker="$work/text-workbook/scripts/check-maturity-thresholds.py" \
  start_case "case 46: the toolkit workbook is a text file" \
  "$work/ranges.md"
expect_scorecard_unreadable 'File is not a zip file'
end_case

damage_repository "$work/bad-crc" crc
checker="$work/bad-crc/scripts/check-maturity-thresholds.py" \
  start_case "case 47: the xl/workbook.xml entry does not match its CRC-32" \
  "$work/ranges.md"
expect_scorecard_unreadable "Bad CRC-32 for file 'xl/workbook\\.xml'"
end_case

damage_repository "$work/no-target" no-target
checker="$work/no-target/scripts/check-maturity-thresholds.py" \
  start_case "case 48: the Relationship element with Id rId8 has no Target attribute" \
  "$work/ranges.md"
expect_scorecard_unreadable 'xl/_rels/workbook\.xml\.rels has a Relationship element with Id rId8 and no Target attribute'
end_case

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
