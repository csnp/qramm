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
# edit the copy of the workbook, and run the checker there. Cases 15 and 17
# make the same copies and pass the copy of the workbook to the repository's
# checker as a document.
#
# Cases:
#   1. No file arguments (the documents in DOCUMENTS): exit 0, RESULT: PASS,
#      the lowest and highest multiplier read from the workbook are listed
#      as 1.00 and 1.50, and the checklist's line 18 and the Welcome!H9 text
#      of both workbooks each give a PASS line.
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
#  14. Where the fixtures were written: the directory is under .tmp-tests/
#      at the repository root and holds the fixture of case 2.
#  15. A copy of the workbook whose Welcome!H9 text gives the earlier
#      "(0.8x – 1.5x)", with an en dash: exit 1, one FAIL line that names
#      Welcome!H9 line 12 and gives 0.8 to 1.5.
#  16. Ranges written with an en dash, "(0.8x – 1.5x)", "1.00 – 1.50" and
#      "1.0–1.5": exit 1, a FAIL line for the first and a PASS line for each
#      of the others.
#  17. A copy of the workbook whose Welcome!H9 text gives no range: exit 1,
#      a FAIL line that says the workbook gives no multiplier range.
#  18. A text file whose name ends in .xlsx: exit 1, a FAIL line that says
#      it is not a zip file.
#  19. An empty file argument: exit 1, "FAIL '': no file name given", no
#      "cannot read" line.
#  20. A zip archive whose name ends in .xlsx and that holds only a text
#      file: exit 1, a FAIL line that says it is not a workbook, then
#      RESULT: FAIL.
#  21. A workbook whose sheet XML part does not parse: exit 1, a FAIL line
#      that says it is not a workbook.
#  22. A workbook with a text cell whose shared-string index is past the end
#      of the shared string table: exit 1, a FAIL line that says it is not a
#      workbook.
#  23. A workbook whose relationship for its sheet has no Target attribute.
#  24. A workbook whose sheet XML declares the unknown encoding "bogus".
#  25. A workbook whose xl/workbook.xml entry gives compression method 6
#      (implode), which zipfile does not support.
#  26. A workbook whose sheet entry gives compression method 8 (deflate) but
#      holds bytes that are not deflate data.
#  27. A workbook whose xl/workbook.xml entry has the encrypted flag that
#      zip -P sets (general purpose flag bit 0).
#  28. A workbook whose sheet entry gives compression method 93 (Zstandard)
#      but holds bytes that are not Zstandard data.
#  Cases 23 to 28, and case 30 below, pass the workbook and then a text
#  document that gives the workbook's range: exit 1, nothing on stderr, one
#  FAIL line, which says the workbook is not a workbook, a PASS line for the
#  text document, and RESULT: FAIL as the last line.
#  29. A text document with a Latin-1 byte, then a document that gives the
#      workbook's range: exit 1, no traceback, a FAIL line that says the
#      first is not UTF-8 text, a PASS line for the second, then
#      RESULT: FAIL.
#  30. A workbook whose sheet entry gives compression method 12 (bzip2) but
#      holds bytes that are not bzip2 data.
#  31. A .xlsx document that does not exist, then a document that gives the
#      workbook's range: exit 1, nothing on stderr, a FAIL line that gives
#      the reason "No such file or directory", a PASS line for the second,
#      then RESULT: FAIL.
#
# The temporary directory is made under .tmp-tests/ at the repository root,
# and the cleanup removes only a directory under it.
#
# Exit status: 0 when every case passes, 1 when any case fails.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
root="$(dirname "$here")"
checker="$here/check-profile-multiplier.py"
toolkit="toolkit/QRAMM_Assessment_Toolkit.xlsx"

tmp_root="$root/.tmp-tests"
mkdir -p "$tmp_root"
work="$(mktemp -d "$tmp_root/check-profile-multiplier.XXXXXX")"
cleanup() {
  case "$work" in
    "$tmp_root"/?*) rm -rf -- "$work" ;;
    *) exit 1 ;;
  esac
  rmdir "$tmp_root" 2> /dev/null || true
}
trap cleanup EXIT

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
expect "the checklist is checked" \
  "has_line '== toolkit-specs/MASTER_PLAN_Document_Checklist.md against $toolkit'"
expect "PASS line for the checklist's line 18" 'has_line "  PASS line 18: 1.00 to 1.50"'
expect "the text of both workbooks is checked" \
  "has_line '== $toolkit against $toolkit' && has_line '== toolkit/Sample_Assessment.xlsx against $toolkit'"
expect "a PASS line for Welcome!H9 in each workbook" \
  '[ "$(printf "%s\n" "$out" | grep -c -x -F "  PASS Welcome!H9 line 12: 1.00 to 1.50")" -eq 2 ]'
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

echo "case 14: where the fixtures were written"
case_failed="$failed"
failed=0
expect "fixtures directory is under .tmp-tests/ at the repository root" \
  'case "$work" in "$root"/.tmp-tests/?*) true ;; *) false ;; esac'
expect "the fixture of case 2 is in it" '[ -f "$work/old.md" ]'
[ "$failed" -eq 0 ] || echo "  -- fixtures directory: $work"
failed=$((failed | case_failed))

make_copy "$work/oldtext" \
  'multiplier between 1.00 and 1.50, adjusted by' \
  'multiplier (0.8x – 1.5x), adjusted by'
start_case "case 15: workbook whose Welcome!H9 text gives the earlier range" \
  "$checker" "$work/oldtext/$toolkit"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line names Welcome!H9 line 12 and gives 0.8 to 1.5" \
  "has_fail 'oldtext/$toolkit Welcome!H9 line 12: the multiplier range is 0.8 to 1.5 here, but $toolkit calculates 1.00 to 1.50'"
end_case

printf '%s\n' \
  'A profile multiplier (0.8x – 1.5x) adjusts the scores.' \
  'The multiplier runs 1.00 – 1.50, set on the Profile tab.' \
  'The multiplier is 1.0–1.5.' \
  > "$work/endash.md"
start_case "case 16: ranges written with an en dash" "$checker" "$work/endash.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line for (0.8x – 1.5x)" \
  "has_fail 'endash.md line 1: the multiplier range is 0.8 to 1.5 here, but $toolkit calculates 1.00 to 1.50'"
expect "two PASS lines" '[ "$(pass_count)" -eq 2 ]'
expect "PASS line for 1.00 – 1.50" 'has_line "  PASS line 2: 1.00 to 1.50"'
expect "PASS line for 1.0–1.5" 'has_line "  PASS line 3: 1.0 to 1.5"'
end_case

make_copy "$work/norangebook" \
  'multiplier between 1.00 and 1.50, adjusted by' \
  'multiplier, adjusted by'
start_case "case 17: workbook whose text gives no multiplier range" \
  "$checker" "$work/norangebook/$toolkit"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says there is no range" \
  "has_fail 'norangebook/$toolkit: gives no multiplier range'"
end_case

printf '%s\n' 'The profile multiplier is between 1.00 and 1.50.' > "$work/text.xlsx"
start_case "case 18: a text file whose name ends in .xlsx" "$checker" "$work/text.xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says it is not a zip file" \
  "has_fail 'text.xlsx: cannot read (not a zip file)'"
end_case

start_case "case 19: an empty file argument" "$checker" ""
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL says no file name was given" \
  'printf "%s\n" "$out" | grep -qxF "  FAIL '"''"': no file name given"'
expect "no cannot read line" '! printf "%s\n" "$out" | grep -q "cannot read"'
end_case

# Writes a zip archive at $1 with one entry per remaining argument, each of
# the form name=content.
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

main_ns='http://schemas.openxmlformats.org/spreadsheetml/2006/main'
rel_ns='http://schemas.openxmlformats.org/officeDocument/2006/relationships'
pkg_rel_ns='http://schemas.openxmlformats.org/package/2006/relationships'
book_xml="xl/workbook.xml=<workbook xmlns=\"$main_ns\" xmlns:r=\"$rel_ns\"><sheets><sheet name=\"Notes\" sheetId=\"1\" r:id=\"rId1\"/></sheets></workbook>"
rels_xml="xl/_rels/workbook.xml.rels=<Relationships xmlns=\"$pkg_rel_ns\"><Relationship Id=\"rId1\" Target=\"worksheets/sheet1.xml\"/></Relationships>"
strings_xml="xl/sharedStrings.xml=<sst xmlns=\"$main_ns\"><si><t>The profile multiplier is between 1.00 and 1.50.</t></si></sst>"

make_zip "$work/notabook.xlsx" 'note.txt=note'
start_case "case 20: a zip archive that is not a workbook" "$checker" "$work/notabook.xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says it is not a workbook" \
  "has_fail 'notabook.xlsx: cannot read (not a workbook)'"
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

make_zip "$work/badxml.xlsx" "$book_xml" "$rels_xml" "$strings_xml" \
  "xl/worksheets/sheet1.xml=<worksheet xmlns=\"$main_ns\"><sheetData>"
start_case "case 21: a workbook whose sheet XML does not parse" "$checker" "$work/badxml.xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says it is not a workbook" \
  "has_fail 'badxml.xlsx: cannot read (not a workbook)'"
end_case

make_zip "$work/badindex.xlsx" "$book_xml" "$rels_xml" "$strings_xml" \
  "xl/worksheets/sheet1.xml=<worksheet xmlns=\"$main_ns\"><sheetData><row r=\"1\"><c r=\"A1\" t=\"s\"><v>5</v></c></row></sheetData></worksheet>"
start_case "case 22: a shared-string index past the end of the table" "$checker" "$work/badindex.xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says it is not a workbook" \
  "has_fail 'badindex.xlsx: cannot read (not a workbook)'"
end_case

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

# Expectations for cases 23 to 28 and 30: $1 is the workbook's file name.
expect_not_a_workbook() {
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "no traceback on stderr" '[ -z "$err" ]'
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line says it is not a workbook" \
    "has_fail '$1: cannot read (not a workbook)'"
  expect "the document after it is checked" \
    '[ "$(pass_count)" -eq 1 ] && has_line "  PASS line 1: 1.00 to 1.50"'
  expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
}

sheet_xml="xl/worksheets/sheet1.xml=<worksheet xmlns=\"$main_ns\"><sheetData><row r=\"1\"><c r=\"A1\" t=\"s\"><v>0</v></c></row></sheetData></worksheet>"

make_zip "$work/notarget.xlsx" "$book_xml" \
  "xl/_rels/workbook.xml.rels=<Relationships xmlns=\"$pkg_rel_ns\"><Relationship Id=\"rId1\"/></Relationships>" \
  "$strings_xml" "$sheet_xml"
start_case "case 23: a relationship without a Target" \
  "$checker" "$work/notarget.xlsx" "$work/new.md"
expect_not_a_workbook notarget.xlsx
end_case

make_zip "$work/encoding.xlsx" "$book_xml" "$rels_xml" "$strings_xml" \
  "xl/worksheets/sheet1.xml=<?xml version=\"1.0\" encoding=\"bogus\"?>${sheet_xml#*=}"
start_case "case 24: XML that declares an unknown encoding" \
  "$checker" "$work/encoding.xlsx" "$work/new.md"
expect_not_a_workbook encoding.xlsx
end_case

make_zip "$work/method.xlsx" "$book_xml" "$rels_xml" "$strings_xml" "$sheet_xml"
set_entry "$work/method.xlsx" xl/workbook.xml 6 0
start_case "case 25: a compression method zipfile does not support" \
  "$checker" "$work/method.xlsx" "$work/new.md"
expect_not_a_workbook method.xlsx
end_case

make_zip "$work/deflate.xlsx" "$book_xml" "$rels_xml" "$strings_xml" \
  "xl/worksheets/sheet1.xml=not deflate data"
set_entry "$work/deflate.xlsx" xl/worksheets/sheet1.xml 8 0
start_case "case 26: deflate data that does not decompress" \
  "$checker" "$work/deflate.xlsx" "$work/new.md"
expect_not_a_workbook deflate.xlsx
end_case

make_zip "$work/encrypted.xlsx" "$book_xml" "$rels_xml" "$strings_xml" "$sheet_xml"
set_entry "$work/encrypted.xlsx" xl/workbook.xml 0 1
start_case "case 27: an encrypted entry" \
  "$checker" "$work/encrypted.xlsx" "$work/new.md"
expect_not_a_workbook encrypted.xlsx
end_case

make_zip "$work/zstd.xlsx" "$book_xml" "$rels_xml" "$strings_xml" \
  "xl/worksheets/sheet1.xml=not zstd data"
set_entry "$work/zstd.xlsx" xl/worksheets/sheet1.xml 93 0
start_case "case 28: Zstandard data that does not decompress" \
  "$checker" "$work/zstd.xlsx" "$work/new.md"
expect_not_a_workbook zstd.xlsx
end_case

# \351 is e with an acute accent in Latin-1, and not valid UTF-8 here.
printf 'The profile multiplier is between 1.00 and 1.50, caf\351.\n' > "$work/latin1.md"
start_case "case 29: a text document that is not UTF-8" "$checker" "$work/latin1.md" "$work/new.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says it is not UTF-8 text" \
  "has_fail 'latin1.md: cannot read (not UTF-8 text)'"
expect "the next document is checked" \
  "has_line '== $work/new.md against $toolkit' && has_line '  PASS line 1: 1.00 to 1.50'"
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

make_zip "$work/bzip2.xlsx" "$book_xml" "$rels_xml" "$strings_xml" \
  "xl/worksheets/sheet1.xml=not bzip2 data"
set_entry "$work/bzip2.xlsx" xl/worksheets/sheet1.xml 12 0
start_case "case 30: bzip2 data that does not decompress" \
  "$checker" "$work/bzip2.xlsx" "$work/new.md"
expect_not_a_workbook bzip2.xlsx
end_case

start_case "case 31: a .xlsx document that does not exist" \
  "$checker" "$work/missing.xlsx" "$work/new.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line gives the reason No such file or directory" \
  "has_fail 'missing.xlsx: cannot read (No such file or directory)'"
expect "the next document is checked" \
  "has_line '== $work/new.md against $toolkit' && has_line '  PASS line 1: 1.00 to 1.50'"
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
