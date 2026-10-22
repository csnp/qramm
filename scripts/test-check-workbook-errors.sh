#!/usr/bin/env bash
# Tests scripts/check-workbook-errors.py against the repository workbooks and
# against fixture workbooks that store error values.
#
# Usage:
#   scripts/test-check-workbook-errors.sh
#
# Case 2 copies the checker into a new temporary directory laid out like the
# repository (scripts/ and toolkit/), so the checker treats that directory as
# the repository root and reads its default workbook paths from it. Each
# fixture workbook has a visible sheet "Scorecard" and a hidden sheet "Data".
# Scorecard!D1, in a hidden column, stores #REF!; Scorecard!C3, in a hidden
# row, stores #DIV/0!; Data!A1 stores #NAME?. The fixture that stands in for
# the blank toolkit also stores #N/A in Scorecard!A1, from a MATCH formula,
# and #VALUE! in Scorecard!B2, with no formula.
#
# Cases:
#   1. The repository workbooks: exit 0, a PASS line for each workbook,
#      RESULT: PASS.
#   2. The fixture workbooks: exit 1, a FAIL line for Scorecard!A1 that gives
#      its formula and one for Scorecard!B2 that says it has no formula, no
#      other FAIL line (the cells in the hidden row, column and sheet are not
#      reported), a PASS line for the workbook whose error cells are all
#      hidden, and RESULT: FAIL.
#   3. A workbook argument that does not exist: exit 1, a FAIL line that says
#      it cannot be read.
#   4. A file argument that is not a workbook: exit 1, a FAIL line that says
#      so.
#   5. An option such as --help: exit 2, usage on stderr, then the checker's
#      header text.
#   6. An empty workbook argument: exit 1, "FAIL '': no file name given",
#      RESULT: FAIL.
#   7. --help under python3 -OO, which removes the header text: exit 2 and
#      only the usage line on stderr, with no traceback.
#   8. -h under python3 -OO: the same as case 7.
#   9. Under the en_US.UTF-8 locale, a workbook argument that holds the byte
#      0xff, which is not valid UTF-8, and names no file, then the sample
#      workbook: exit 1, no traceback, the name printed with the byte as
#      \xff on its == line and in a FAIL line that says it cannot be read,
#      a PASS line for the sample workbook, then RESULT: FAIL.
#  10. Under the en_US.ISO8859-1 locale, a workbook argument that is valid
#      UTF-8 and holds the character U+65E5, which ISO-8859-1 cannot encode,
#      and names no file, then the sample workbook: exit 1, nothing on
#      stderr, the name printed with the character as \u65e5 on its == line
#      and in a FAIL line that says it cannot be read (No such file or
#      directory), a PASS line for the sample workbook, then RESULT: FAIL.
#      The case is skipped, with a line that says so, when python3 -I does
#      not decode file names as UTF-8 and write stdout as ISO-8859-1 under
#      that locale on this machine.
#  11. A zip archive whose xl/workbook.xml entry gives compression method 12
#      (bzip2) but holds bytes that are not bzip2 data. bz2 raises
#      OSError("Invalid data stream"), which has no errno.
#  12. A zip archive whose end of central directory record gives a central
#      directory offset 1000 bytes past the end of the file.
#      zipfile.is_zipfile() accepts this archive, and zipfile raises
#      OSError(22, "Invalid argument") when it reads the xl/workbook.xml
#      entry.
#  13. A zip archive whose xl/workbook.xml entry is stored with the deflate
#      method and whose first 4 bytes of deflate data are 0xff, which does
#      not decompress. zlib raises zlib.error("Error -3 while decompressing
#      data: invalid block type").
#  14. A zip archive whose xl/workbook.xml entry has bit 0 of its general
#      purpose flags set, which marks it as encrypted. zipfile raises
#      RuntimeError("File 'xl/workbook.xml' is encrypted, password required
#      for extraction").
#  15. A zip archive whose xl/workbook.xml entry gives compression method
#      98 (PPMd), which zipfile does not support. zipfile raises
#      NotImplementedError("That compression method is not supported").
#  16. A zip archive whose xl/workbook.xml entry gives compression method
#      93 (Zstandard) but holds bytes that are not Zstandard data. In Python
#      3.14.3, compression.zstd raises ZstdError("Unable to decompress
#      Zstandard data: Unknown frame descriptor"). Python 3.13.12 and 3.9.6
#      have no compression.zstd module, and zipfile raises
#      NotImplementedError as in case 15.
#  17. A zip archive whose xl/workbook.xml entry gives compression method
#      14 (LZMA) and holds 11 bytes that do not decompress: the 4-byte header
#      zipfile reads before LZMA data, which gives 5 bytes of LZMA
#      properties, those properties, then 0xff 0xff. lzma raises
#      LZMAError("Corrupt input data").
#  Cases 11 to 17 pass the archive and then the sample workbook: exit 1,
#  nothing on stderr, one FAIL line, which says the archive cannot be read
#  (not a workbook), a PASS line for the sample workbook, and RESULT: FAIL
#  as the last line.
#  18. Under the en_US.ISO8859-1 locale, a workbook with one visible sheet,
#      whose name holds the character U+2192, which ISO-8859-1 cannot
#      encode, and whose cells A1 and B1 store #DIV/0!, A1 from the formula
#      1/0 and B1 from a formula that holds U+00D7, which ISO-8859-1 can
#      encode: exit 1, nothing on stderr, two FAIL lines, each giving the
#      sheet name with U+2192 as \u2192, the one for B1 giving its formula
#      with U+00D7 as the ISO-8859-1 byte 0xd7, then RESULT: FAIL. The case
#      is skipped, with a line that says so, when python3 -I does not write
#      stdout as ISO-8859-1 under that locale on this machine.
#  19. A zip archive whose xl/workbook.xml entry gives, in both of its
#      headers, a compressed and an uncompressed size equal to the length of
#      the archive, which run past its end, then the sample workbook: exit
#      1, nothing on stderr, one FAIL line, a PASS line for the sample
#      workbook, and RESULT: FAIL as the last line. With Python 3.9.6,
#      zipfile reads the entry to the end of the file and raises EOFError,
#      and the FAIL line says the archive cannot be read (not a workbook).
#      Python 3.13.12 and 3.14.3 raise zipfile.BadZipFile("Overlapped
#      entries: 'xl/workbook.xml' (possible zip bomb)") instead, and the
#      FAIL line says the archive is not a workbook and gives that reason.
#  20. The archive of case 19 with a second central directory header, for
#      an entry named xl/workbook.xmz, that gives the same local header
#      offset, then the sample workbook: as cases 11 to 17, except that
#      stderr can hold a warning. Python 3.13.12 and 3.14.3 print the
#      warning "UserWarning: Overlapped entries: 'xl/workbook.xml' (possible
#      zip bomb)" and read on, and zipfile raises EOFError, as with Python
#      3.9.6.
#  21. A copy of the sample workbook whose col element for column M of the
#      Welcome sheet, xl/worksheets/sheet1.xml, has hidden="1" and no min
#      attribute. The Welcome sheet is the first sheet and is not hidden.
#  22. The same copy with the min attribute and no max attribute.
#  Cases 21 and 22 pass the copy and then the sample workbook: exit 1,
#  nothing on stderr, one FAIL line, which says the copy is not a workbook
#  as xl/worksheets/sheet1.xml has a hidden col element with no min (case 21)
#  or no max (case 22) attribute, a PASS line for the sample workbook, and
#  RESULT: FAIL as the last line.
#  23. A copy of the sample workbook whose Relationship element with Id rId1
#      in xl/_rels/workbook.xml.rels, the one the Welcome sheet names, has no
#      Target attribute, then the sample workbook: exit 1, nothing on stderr,
#      one FAIL line, which says the copy is not a workbook as that
#      Relationship element has no Target attribute, a PASS line for the
#      sample workbook, and RESULT: FAIL as the last line.
#  24. A copy of the sample workbook whose first c element in
#      xl/worksheets/sheet1.xml, the one for A1 of the Welcome sheet, in row
#      1, which is not hidden, is replaced by a c element with no r
#      attribute that stores #DIV/0! from the formula 1/0.
#  25. The same copy with the r attribute 1A, which is not a cell
#      reference, in that c element.
#  26. The copy of case 24 with no r attribute in the row element of row 1
#      either.
#  Cases 24 to 26 pass the copy and then the sample workbook: exit 1,
#  nothing on stderr, one FAIL line, which says the copy is not a workbook
#  as xl/worksheets/sheet1.xml has a c element with no r attribute in row 1
#  (case 24), a c element in row 1 whose r attribute 1A is not a cell
#  reference (case 25) or a c element with no r attribute (case 26), a PASS
#  line for the sample workbook, and RESULT: FAIL as the last line.
#  27. A copy of the sample workbook whose c element for E6 of the Welcome
#      sheet, in row 6, which is hidden, is replaced by a c element with no
#      r attribute that stores #DIV/0! from the formula 1/0: exit 0, nothing
#      on stderr, no FAIL line, one PASS line, and RESULT: PASS as the last
#      line.
#  28. The copy of case 25 with the r attribute M1x in place of 1A. M1x
#      starts with the cell reference M1 and goes on with x, and column M
#      of the Welcome sheet is hidden. As cases 24 to 26, with a FAIL line
#      that says the copy is not a workbook as xl/worksheets/sheet1.xml has
#      a c element in row 1 whose r attribute M1x is not a cell reference.
#  29. A copy of the sample workbook whose first c element in
#      xl/worksheets/sheet1.xml, the one for A1 of the Welcome sheet, is
#      replaced by one that stores #DIV/0! from the formula 1/0, and in which
#      each of the namespace names
#      http://schemas.openxmlformats.org/spreadsheetml/2006/main and
#      http://schemas.openxmlformats.org/officeDocument/2006/relationships is
#      replaced by the one the Strict Open XML format uses in its place,
#      http://purl.oclc.org/ooxml/spreadsheetml/main and
#      http://purl.oclc.org/ooxml/officeDocument/relationships, in every part
#      under xl/ whose name ends in .xml, then the sample workbook: exit 1,
#      nothing on stderr, one FAIL line, for Welcome!A1, which gives its
#      formula, a PASS line for the sample workbook, and RESULT: FAIL as the
#      last line.
#  30. A copy of the sample workbook with the namespace names of case 29
#      replaced in the same parts: exit 0, nothing on stderr, no FAIL line, a
#      PASS line that gives as many visible formula cells as the checker
#      gives for the sample workbook, and RESULT: PASS as the last line.
#  31. A copy of the sample workbook whose xl/workbook.xml declares the
#      namespace urn:example:spreadsheetml in place of
#      http://schemas.openxmlformats.org/spreadsheetml/2006/main, so that it
#      has no sheet element in a namespace the checker reads, then the
#      sample workbook: exit 1, nothing on stderr, one FAIL line, which says
#      the copy is not a workbook as xl/workbook.xml has no sheet element in
#      a namespace the checker reads, a PASS line for the sample workbook,
#      and RESULT: FAIL as the last line.
#  32. Under the en_US.UTF-8 locale, the copy of case 25 with the r
#      attribute M followed by U+0661 (ARABIC-INDIC DIGIT ONE) in place of
#      1A. U+0661 is a Unicode decimal digit but not one of the digits 0 to
#      9, and column M of the Welcome sheet is hidden. As case 28, with
#      this r attribute, written as UTF-8, in place of M1x in the FAIL line.
#  33. As case 32, with U+FF11 (FULLWIDTH DIGIT ONE) in place of U+0661.
#  34. The copy of case 25 with the r attribute 1A, a line feed, RESULT:
#      PASS, a carriage return, a tab and U+0085 (NEXT LINE) in place of 1A.
#      As case 25, with the line feed, carriage return, tab and U+0085
#      written as \n, \r, \t and \x85 in the FAIL line, and no line that
#      reads RESULT: PASS.
#  35. Under the en_US.UTF-8 locale, a copy of the sample workbook whose
#      first c element in xl/worksheets/sheet1.xml, the one for A1 of the
#      Welcome sheet, is replaced by one for M1 that stores #DIV/0! from
#      the formula 1/0, and whose hidden col element for column M gives 13
#      as its min and max attributes written with U+0661 and U+0663
#      (ARABIC-INDIC DIGIT ONE and THREE). int() reads that text as 13, the
#      number of column M.
#  36. The copy of case 35 with the min attribute 13 and the max attribute
#      1_3 in that col element. int() reads 1_3 as 13 too.
#  37. The copy of case 35 with the min attribute x and the max attribute
#      13 in that col element.
#  Cases 35 to 37 pass the copy and then the sample workbook: exit 1,
#  nothing on stderr, one FAIL line, which says the copy is not a workbook
#  as xl/worksheets/sheet1.xml has a hidden col element whose min (cases 35
#  and 37) or max (case 36) attribute, quoted, is not one or more of the
#  digits 0 to 9, a PASS line for the sample workbook, and RESULT: FAIL as
#  the last line.
#  38. A copy of the sample workbook whose xl/worksheets/sheet1.xml, the
#      part of the Welcome sheet, has an XML declaration that names the
#      encoding x-bogus, which Python has no codec for, in place of UTF-8.
#      ElementTree raises LookupError("unknown encoding: x-bogus").
#  39. The same copy with the multi-byte encoding shift_jis in place of
#      x-bogus. ElementTree raises ValueError("multi-byte encodings are not
#      supported").
#  Cases 38 and 39 pass the copy and then the sample workbook: exit 1,
#  nothing on stderr, one FAIL line, which says the copy is not a workbook
#  and gives the error's text as the reason, a PASS line for the sample
#  workbook, and RESULT: FAIL as the last line.
#
# Each case prints a title that starts with "case N:", where N is its
# number. A FAIL line follows each title that gives the number of an
# earlier one.
#
# The temporary directory is made under .tmp-tests/ at the repository root,
# and the cleanup removes only a directory under it.
#
# Exit status: 0 when every case passes, 1 when any case fails or two titles
# give the same number.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
root="$(cd "$here/.." && pwd -P)"
checker="$here/check-workbook-errors.py"

tmp_root="$root/.tmp-tests"
mkdir -p "$tmp_root"
work="$(mktemp -d "$tmp_root/check-workbook-errors.XXXXXX")"
cleanup() {
  case "$work" in
    "$tmp_root"/?*) rm -rf -- "$work" ;;
    *) exit 1 ;;
  esac
  rmdir "$tmp_root" 2> /dev/null || true
}
trap cleanup EXIT

failed=0
# Interpreter option that run_checker passes before -I, such as -OO; empty
# for none.
optimize=""

# Writes to $1 a fixture workbook. When $2 is "visible", Scorecard!A1 and
# Scorecard!B2 store errors in visible cells as well.
make_workbook() {
  python3 -I - "$@" <<'PY'
import sys
import zipfile

target, kind = sys.argv[1:3]
MAIN = 'xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"'
a1 = ""
row2 = ""
if kind == "visible":
    a1 = '<c r="A1" t="e"><f>MATCH(1,B1:B3,0)</f><v>#N/A</v></c>'
    row2 = '<row r="2"><c r="B2" t="e"><v>#VALUE!</v></c></row>'
scorecard = (
    "<worksheet {}>"
    '<cols><col min="4" max="4" width="9" hidden="1"/></cols>'
    '<sheetData><row r="1">{}<c r="D1" t="e"><f>INDEX(B1:B3,4)</f><v>#REF!</v></c></row>{}'
    '<row r="3" hidden="1"><c r="C3" t="e"><f>1/0</f><v>#DIV/0!</v></c></row>'
    "</sheetData></worksheet>"
).format(MAIN, a1, row2)
data = (
    "<worksheet {}>"
    '<sheetData><row r="1"><c r="A1" t="e"><f>NOSUCH()</f><v>#NAME?</v></c></row>'
    "</sheetData></worksheet>"
).format(MAIN)
parts = {
    "[Content_Types].xml": (
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="xml" ContentType="application/xml"/>'
        '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>'
        '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
        '<Override PartName="/xl/worksheets/sheet2.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
        "</Types>"
    ),
    "_rels/.rels": (
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
        "</Relationships>"
    ),
    "xl/workbook.xml": (
        "<workbook {} "
        'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
        '<sheets><sheet name="Scorecard" sheetId="1" r:id="rId1"/>'
        '<sheet name="Data" sheetId="2" state="hidden" r:id="rId2"/></sheets>'
        "</workbook>"
    ).format(MAIN),
    "xl/_rels/workbook.xml.rels": (
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>'
        '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet2.xml"/>'
        "</Relationships>"
    ),
    "xl/worksheets/sheet1.xml": scorecard,
    "xl/worksheets/sheet2.xml": data,
}
with zipfile.ZipFile(target, "w") as book:
    for name, text in parts.items():
        book.writestr(name, '<?xml version="1.0" encoding="UTF-8"?>' + text)
PY
}

# Lays out a copy of the repository at $1 whose blank toolkit workbook
# stores errors in visible cells and whose sample workbook stores errors in
# hidden cells only.
make_copy() {
  mkdir -p "$1/scripts" "$1/toolkit"
  cp "$checker" "$1/scripts/check-workbook-errors.py"
  make_workbook "$1/toolkit/QRAMM_Assessment_Toolkit.xlsx" visible
  make_workbook "$1/toolkit/Sample_Assessment.xlsx" hidden
}

# Runs the checker at $1 with the remaining arguments, under python3 -I and
# the option in optimize when it is set. Sets out, err and status.
run_checker() {
  local checker_path="$1"
  shift
  status=0
  python3 ${optimize:+"$optimize"} -I "$checker_path" "$@" \
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

# The numbers of the cases whose titles have been printed, each followed by
# a space.
case_numbers=" "

# Prints the case title $1, which starts with "case N:". When an earlier
# title gave the same N, prints a FAIL line after it and fails the run.
print_title() {
  local number="${1#case }"
  number="${number%%:*}"
  echo "$1"
  case "$case_numbers" in
    *" $number "*)
      echo "  FAIL case $number is also the number of an earlier case"
      failed=1
      ;;
  esac
  case_numbers="$case_numbers$number "
}

# Runs one case: $1 is its title, the rest are run_checker arguments. Leaves
# the result in out, err and status for the expect lines that follow.
start_case() {
  print_title "$1"
  shift
  case_failed="$failed"
  failed=0
  run_checker "$@"
}

end_case() {
  [ "$failed" -eq 0 ] || show_output
  failed=$((failed | case_failed))
}

start_case "case 1: repository workbooks" "$checker"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "header line for the blank toolkit" \
  'has_line "== toolkit/QRAMM_Assessment_Toolkit.xlsx"'
expect "header line for the sample" 'has_line "== toolkit/Sample_Assessment.xlsx"'
expect "one PASS line per workbook" '[ "$(pass_count)" -eq 2 ]'
expect "last line is RESULT: PASS" 'last_line_is "RESULT: PASS"'
end_case

make_copy "$work/errors"
start_case "case 2: fixture workbooks" "$work/errors/scripts/check-workbook-errors.py"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line for Scorecard!A1 gives its formula" \
  'has_fail "toolkit/QRAMM_Assessment_Toolkit.xlsx: Scorecard!A1 stores #N/A: MATCH(1,B1:B3,0)"'
expect "FAIL line for Scorecard!B2 says it has no formula" \
  'has_fail "toolkit/QRAMM_Assessment_Toolkit.xlsx: Scorecard!B2 stores #VALUE!: no formula"'
expect "no other FAIL line" '[ "$(fail_count)" -eq 2 ]'
expect "PASS line for the workbook whose error cells are hidden" \
  'has_line "  PASS 0 visible formula cells, none stores an error value"'
expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
end_case

start_case "case 3: workbook that does not exist" "$checker" toolkit/missing.xlsx
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line says the workbook cannot be read" \
  'has_fail "toolkit/missing.xlsx: cannot read"'
expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
end_case

start_case "case 4: file that is not a workbook" "$checker" \
  scripts/check-workbook-errors.py
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line says the file is not a workbook" \
  'has_fail "scripts/check-workbook-errors.py: not a workbook"'
end_case

start_case "case 5: option argument" "$checker" --help
expect "exit status is 2" '[ "$status" -eq 2 ]'
expect "usage on stderr" 'printf "%s\n" "$err" | grep -q "^usage:"'
expect "header text on stderr" \
  'printf "%s\n" "$err" | grep -qx "Checks that the toolkit workbooks show no error value in a visible cell\."'
end_case

start_case "case 6: empty workbook argument" "$checker" ""
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line names the empty argument" "has_fail \"'': no file name given\""
expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
end_case

optimize="-OO"
start_case "case 7: --help under python3 -OO" "$checker" --help
expect "exit status is 2" '[ "$status" -eq 2 ]'
expect "only the usage line on stderr" \
  '[ "$err" = "usage: python3 -I scripts/check-workbook-errors.py [workbook ...]" ]'
end_case

start_case "case 8: -h under python3 -OO" "$checker" -h
expect "exit status is 2" '[ "$status" -eq 2 ]'
expect "only the usage line on stderr" \
  '[ "$err" = "usage: python3 -I scripts/check-workbook-errors.py [workbook ...]" ]'
end_case
optimize=""

# \377 is the byte 0xff, which is not valid UTF-8, so Python holds it as a
# lone surrogate. Under en_US.UTF-8 printing that raises UnicodeEncodeError;
# the C, C.UTF-8 and UTF-8 locales write the byte as it is. The checker is
# expected to print \xff in either case. No file is made with this name.
LC_ALL=en_US.UTF-8 start_case "case 9: a workbook argument that is not UTF-8" \
  "$checker" "$work/bad$(printf '\377').xlsx" toolkit/Sample_Assessment.xlsx
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "the name is printed with the byte as \\xff" "has_line '== $work/bad\\xff.xlsx'"
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says the workbook cannot be read and gives the byte as \\xff" \
  "has_fail '$work/bad\\xff.xlsx: cannot read ('"
expect "the sample workbook is checked" \
  'has_line "== toolkit/Sample_Assessment.xlsx" && [ "$(pass_count)" -eq 1 ]'
expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
end_case

# \346\227\245 is U+65E5 encoded as UTF-8. Under en_US.ISO8859-1 on macOS,
# python3 decodes the name as UTF-8 and writes stdout as ISO-8859-1, which
# has no byte for U+65E5, so printing the name as it is raises
# UnicodeEncodeError. The checker is expected to print \u65e5 in its place.
# No file is made with this name.
title="case 10: a workbook argument that stdout's encoding cannot hold"
probe="$(LC_ALL=en_US.ISO8859-1 python3 -I -c 'import codecs, sys; print(codecs.lookup(sys.getfilesystemencoding()).name, codecs.lookup(sys.stdout.encoding).name)' 2>&1 || true)"
if [ "$probe" = "utf-8 iso8859-1" ]; then
  LC_ALL=en_US.ISO8859-1 start_case "$title" \
    "$checker" "$work/$(printf '\346\227\245').xlsx" toolkit/Sample_Assessment.xlsx
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "no traceback on stderr" '[ -z "$err" ]'
  expect "the name is printed with the character as \\u65e5" \
    "has_line '== $work/\\u65e5.xlsx'"
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line says the workbook cannot be read and gives the character as \\u65e5" \
    "has_fail '$work/\\u65e5.xlsx: cannot read (No such file or directory)'"
  expect "the sample workbook is checked" \
    'has_line "== toolkit/Sample_Assessment.xlsx" && [ "$(pass_count)" -eq 1 ]'
  expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
  end_case
else
  print_title "$title"
  echo "  skip python3 does not decode file names as UTF-8 and write stdout as ISO-8859-1 under en_US.ISO8859-1 here ($probe)"
fi

# Writes to $1 a zip archive with one entry, xl/workbook.xml, damaged as $2
# names. bzip2: both headers of the entry give compression method 12
# (bzip2), and the entry holds bytes that are not bzip2 data. offset: the
# end of central directory record gives a central directory offset 1000
# bytes past the end of the file. deflate: the entry is stored with the
# deflate method, and its first 4 bytes of deflate data are 0xff, which
# start a block of the reserved type 3. encrypted: both headers of the entry
# set bit 0 of the general purpose flags, which marks the entry as
# encrypted. ppmd, zstd and lzma: both headers of the entry give compression
# method 98 (PPMd), 93 (Zstandard) or 14 (LZMA). The entry holds the 11
# bytes <workbook/>, which are not Zstandard data; for lzma, they are
# replaced by the 4-byte header zipfile reads before LZMA data, which gives
# 5 bytes of LZMA properties, the properties 0x5d (lc=3, lp=0, pb=2) and a
# 64 KiB dictionary size, then 0xff 0xff. past-end: both headers of the
# entry give a compressed and an uncompressed size equal to the length of
# the archive, which run past its end, as the entry's data starts after its
# local file header. same-offset: as past-end, with a copy of the central
# directory header, for an entry named xl/workbook.xmz, after it.
make_damaged_zip() {
  python3 -I - "$@" <<'PY'
import struct
import sys
import zipfile

path, damage = sys.argv[1:3]
if damage == "deflate":
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as book:
        book.writestr("xl/workbook.xml", "<workbook>" + "AB" * 1500 + "</workbook>")
else:
    with zipfile.ZipFile(path, "w") as book:
        book.writestr("xl/workbook.xml", "<workbook/>")
with open(path, "rb") as fh:
    data = bytearray(fh.read())
# The archive has no comment, so its last 22 bytes are the end of central
# directory record, which ends with the central directory's offset and a
# 2-byte comment length.
(directory,) = struct.unpack_from("<I", data, len(data) - 6)
if damage == "bzip2":
    # The entry's local file header starts the archive and gives the
    # compression method at offset 8; its central directory header gives it
    # at offset 10.
    struct.pack_into("<H", data, 8, 12)
    struct.pack_into("<H", data, directory + 10, 12)
elif damage == "offset":
    struct.pack_into("<I", data, len(data) - 6, len(data) + 1000)
elif damage == "deflate":
    # The entry's data follows its 30-byte local file header and the file
    # name; writestr() writes no extra field there.
    start = 30 + len("xl/workbook.xml")
    data[start:start + 4] = bytes([255] * 4)
elif damage == "encrypted":
    # The local file header gives the general purpose flags at offset 6; the
    # central directory header gives them at offset 8.
    for offset in (6, directory + 8):
        (flags,) = struct.unpack_from("<H", data, offset)
        struct.pack_into("<H", data, offset, flags | 1)
elif damage in ("ppmd", "zstd", "lzma"):
    method = {"ppmd": 98, "zstd": 93, "lzma": 14}[damage]
    struct.pack_into("<H", data, 8, method)
    struct.pack_into("<H", data, directory + 10, method)
    if damage == "lzma":
        # The entry's 11 bytes of data follow its local file header and
        # the file name.
        start = 30 + len("xl/workbook.xml")
        data[start:start + 11] = bytes([9, 20, 5, 0, 0x5D, 0, 0, 1, 0, 255, 255])
elif damage in ("past-end", "same-offset"):
    headers = [directory]
    if damage == "same-offset":
        # A central directory header gives the file name from offset 46. The
        # end of central directory record gives the number of entries on
        # this disk and in all at offsets 8 and 10, and the size of the
        # central directory at offset 12.
        record = data[directory:len(data) - 22]
        record[45 + len("xl/workbook.xml")] = ord("z")
        end = data[len(data) - 22:]
        struct.pack_into("<HHI", end, 8, 2, 2, 2 * len(record))
        headers.append(len(data) - 22)
        data = data[:len(data) - 22] + record + end
    # The local file header gives the compressed and uncompressed sizes at
    # offsets 18 and 22; a central directory header gives them at offsets 20
    # and 24.
    struct.pack_into("<II", data, 18, len(data), len(data))
    for header in headers:
        struct.pack_into("<II", data, header + 20, len(data), len(data))
else:
    sys.exit("make_damaged_zip: unknown damage " + damage)
with open(path, "wb") as fh:
    fh.write(data)
PY
}

# True when stderr is empty or each of its lines holds "UserWarning:
# Overlapped entries: '$1' (possible zip bomb)" or starts with two spaces,
# as do the two lines of the warning Python 3.13.12 and 3.14.3 print for the
# entry $1 of the archive of case 20: the second quotes the checker's line
# that read the entry. The first line of a traceback does neither.
only_overlap_warning() {
  local rest
  rest="$(printf '%s\n' "$err" \
    | grep -v -F -- "UserWarning: Overlapped entries: '$1' (possible zip bomb)" \
    | grep -v '^  ' || true)"
  [ -z "$rest" ]
}

# Expectations for cases 11 to 17 and 20: $1 is the archive's file name.
# With $2, stderr can hold the warning only_overlap_warning allows for the
# entry $2.
expect_not_a_workbook() {
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  if [ "$#" -gt 1 ]; then
    expect "no traceback on stderr, at most a warning for $2" \
      "only_overlap_warning '$2'"
  else
    expect "no traceback on stderr" '[ -z "$err" ]'
  fi
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line says it is not a workbook" \
    "has_fail '$1: cannot read (not a workbook)'"
  expect "the sample workbook is checked" \
    'has_line "== toolkit/Sample_Assessment.xlsx" && [ "$(pass_count)" -eq 1 ]'
  expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
}

make_damaged_zip "$work/bzip2.xlsx" bzip2
start_case "case 11: bzip2 data that does not decompress" \
  "$checker" "$work/bzip2.xlsx" toolkit/Sample_Assessment.xlsx
expect_not_a_workbook "$work/bzip2.xlsx"
end_case

make_damaged_zip "$work/badoffset.xlsx" offset
start_case "case 12: a central directory offset past the end of the file" \
  "$checker" "$work/badoffset.xlsx" toolkit/Sample_Assessment.xlsx
expect_not_a_workbook "$work/badoffset.xlsx"
end_case

make_damaged_zip "$work/deflate.xlsx" deflate
start_case "case 13: deflate data that does not decompress" \
  "$checker" "$work/deflate.xlsx" toolkit/Sample_Assessment.xlsx
expect_not_a_workbook "$work/deflate.xlsx"
end_case

make_damaged_zip "$work/encrypted.xlsx" encrypted
start_case "case 14: an entry marked as encrypted" \
  "$checker" "$work/encrypted.xlsx" toolkit/Sample_Assessment.xlsx
expect_not_a_workbook "$work/encrypted.xlsx"
end_case

make_damaged_zip "$work/ppmd.xlsx" ppmd
start_case "case 15: compression method 98 (PPMd)" \
  "$checker" "$work/ppmd.xlsx" toolkit/Sample_Assessment.xlsx
expect_not_a_workbook "$work/ppmd.xlsx"
end_case

make_damaged_zip "$work/zstd.xlsx" zstd
start_case "case 16: Zstandard data that does not decompress" \
  "$checker" "$work/zstd.xlsx" toolkit/Sample_Assessment.xlsx
expect_not_a_workbook "$work/zstd.xlsx"
end_case

make_damaged_zip "$work/lzma.xlsx" lzma
start_case "case 17: LZMA data that does not decompress" \
  "$checker" "$work/lzma.xlsx" toolkit/Sample_Assessment.xlsx
expect_not_a_workbook "$work/lzma.xlsx"
end_case

# Writes to $1 a workbook with one visible sheet, named "Scores \u2192
# Totals", whose A1 stores #DIV/0! from the formula 1/0 and whose B1 stores
# #DIV/0! from the formula "\u00d7"&A1, where \u2192 is the character U+2192
# and \u00d7 is U+00D7.
make_arrow_workbook() {
  python3 -I - "$1" <<'PY'
import sys
import zipfile

MAIN = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
REL = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
PKG = "http://schemas.openxmlformats.org/package/2006/relationships"
parts = {
    "xl/workbook.xml": (
        '<workbook xmlns="%s" xmlns:r="%s"><sheets>'
        '<sheet name="Scores \u2192 Totals" sheetId="1" r:id="rId1"/>'
        "</sheets></workbook>" % (MAIN, REL)
    ),
    "xl/_rels/workbook.xml.rels": (
        '<Relationships xmlns="%s"><Relationship Id="rId1" Type="%s/worksheet" '
        'Target="worksheets/sheet1.xml"/></Relationships>' % (PKG, REL)
    ),
    "xl/worksheets/sheet1.xml": (
        '<worksheet xmlns="%s"><sheetData><row r="1">'
        '<c r="A1" t="e"><f>1/0</f><v>#DIV/0!</v></c>'
        '<c r="B1" t="e"><f>"\u00d7"&amp;A1</f><v>#DIV/0!</v></c>'
        "</row></sheetData></worksheet>" % MAIN
    ),
}
with zipfile.ZipFile(sys.argv[1], "w") as book:
    for name, text in parts.items():
        book.writestr(name, '<?xml version="1.0" encoding="UTF-8"?>' + text)
PY
}

# Under en_US.ISO8859-1 on macOS, python3 writes stdout as ISO-8859-1, which
# has the byte 0xd7 (\327) for U+00D7 and no byte for U+2192, so printing a
# FAIL line that quotes the sheet name as it is raises UnicodeEncodeError.
# The checker is expected to print \u2192 in place of U+2192 and the byte
# 0xd7 for U+00D7. The line with that byte is matched under LC_ALL=C, where
# grep compares bytes, not characters.
title="case 18: FAIL lines that quote a character stdout's encoding cannot hold"
stdout_encoding="$(LC_ALL=en_US.ISO8859-1 python3 -I -c 'import codecs, sys; print(codecs.lookup(sys.stdout.encoding).name)' 2>&1 || true)"
if [ "$stdout_encoding" = "iso8859-1" ]; then
  make_arrow_workbook "$work/arrow.xlsx"
  LC_ALL=en_US.ISO8859-1 start_case "$title" "$checker" "$work/arrow.xlsx"
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "no traceback on stderr" '[ -z "$err" ]'
  expect "two FAIL lines" '[ "$(LC_ALL=C fail_count)" -eq 2 ]'
  expect "FAIL line for A1 gives the sheet name with U+2192 as \\u2192" \
    "has_fail '$work/arrow.xlsx: Scores \\u2192 Totals!A1 stores #DIV/0!: 1/0'"
  b1_line="  FAIL $work/arrow.xlsx: Scores \\u2192 Totals!B1 stores #DIV/0!: \"$(printf '\327')\"&A1"
  expect "FAIL line for B1 gives its formula with U+00D7 as the byte 0xd7" \
    'LC_ALL=C has_line "$b1_line"'
  expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
  end_case
else
  print_title "$title"
  echo "  skip python3 does not write stdout as ISO-8859-1 under en_US.ISO8859-1 here ($stdout_encoding)"
fi

# The FAIL line for the archive $1 of case 19: the one Python 3.9.6 gives, or
# the one Python 3.13.12 and 3.14.3 give.
past_end_fail() {
  has_fail "$1: cannot read (not a workbook)" ||
    has_fail "$1: not a workbook (Overlapped entries: 'xl/workbook.xml' (possible zip bomb))"
}

make_damaged_zip "$work/past-end.xlsx" past-end
start_case "case 19: entry sizes that run past the end of the file" \
  "$checker" "$work/past-end.xlsx" toolkit/Sample_Assessment.xlsx
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says it is not a workbook" "past_end_fail '$work/past-end.xlsx'"
expect "the sample workbook is checked" \
  'has_line "== toolkit/Sample_Assessment.xlsx" && [ "$(pass_count)" -eq 1 ]'
expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
end_case

make_damaged_zip "$work/same-offset.xlsx" same-offset
start_case "case 20: entry sizes past the end and a second header at the same offset" \
  "$checker" "$work/same-offset.xlsx" toolkit/Sample_Assessment.xlsx
expect_not_a_workbook "$work/same-offset.xlsx" xl/workbook.xml
end_case

# Writes to $2 a copy of the workbook $1 whose part $3 has its first "$4"
# replaced by "$5". Fails when the part does not hold "$4".
edit_part() {
  python3 -I - "$@" <<'PY'
import sys
import zipfile

source, target, part, old, new = sys.argv[1:6]
with zipfile.ZipFile(source) as book, zipfile.ZipFile(target, "w") as copy:
    for info in book.infolist():
        data = book.read(info.filename)
        if info.filename == part:
            text = data.decode("utf-8")
            if old not in text:
                sys.exit("edit_part: no %s in %s" % (old, part))
            data = text.replace(old, new, 1).encode("utf-8")
        copy.writestr(info, data)
PY
}

# Expectations for cases 21 and 22: $1 is the copy's file name and $2 the
# attribute its hidden col element lacks.
expect_no_column_bound() {
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "no traceback on stderr" '[ -z "$err" ]'
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line says it is not a workbook as a hidden col element has no $2 attribute" \
    "has_fail '$1: not a workbook (xl/worksheets/sheet1.xml has a hidden col element with no $2 attribute)'"
  expect "the sample workbook is checked" \
    'has_line "== toolkit/Sample_Assessment.xlsx" && [ "$(pass_count)" -eq 1 ]'
  expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
}

# Column M of the Welcome sheet, the first sheet of the sample workbook, is
# hidden.
edit_part "$root/toolkit/Sample_Assessment.xlsx" "$work/nomin.xlsx" \
  xl/worksheets/sheet1.xml '<col min="13" max="13" ' '<col max="13" '
start_case "case 21: a hidden col element with no min attribute" \
  "$checker" "$work/nomin.xlsx" toolkit/Sample_Assessment.xlsx
expect_no_column_bound "$work/nomin.xlsx" min
end_case

edit_part "$root/toolkit/Sample_Assessment.xlsx" "$work/nomax.xlsx" \
  xl/worksheets/sheet1.xml '<col min="13" max="13" ' '<col min="13" '
start_case "case 22: a hidden col element with no max attribute" \
  "$checker" "$work/nomax.xlsx" toolkit/Sample_Assessment.xlsx
expect_no_column_bound "$work/nomax.xlsx" max
end_case

edit_part "$root/toolkit/Sample_Assessment.xlsx" "$work/notarget.xlsx" \
  xl/_rels/workbook.xml.rels ' Target="worksheets/sheet1.xml"' ''
start_case "case 23: a sheet's Relationship element with no Target attribute" \
  "$checker" "$work/notarget.xlsx" toolkit/Sample_Assessment.xlsx
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says it is not a workbook as the Relationship element has no Target attribute" \
  "has_fail '$work/notarget.xlsx: not a workbook (xl/_rels/workbook.xml.rels has a Relationship element with Id rId1 and no Target attribute)'"
expect "the sample workbook is checked" \
  'has_line "== toolkit/Sample_Assessment.xlsx" && [ "$(pass_count)" -eq 1 ]'
expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
end_case

# Expectations for cases 24 to 26, 28 and 32 to 34: $1 is the copy's file
# name and $2 what its FAIL line says xl/worksheets/sheet1.xml has.
expect_no_cell_reference() {
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "no traceback on stderr" '[ -z "$err" ]'
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line says it is not a workbook as sheet1.xml has $2" \
    "has_fail '$1: not a workbook (xl/worksheets/sheet1.xml has $2)'"
  expect "the sample workbook is checked" \
    'has_line "== toolkit/Sample_Assessment.xlsx" && [ "$(pass_count)" -eq 1 ]'
  expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
}

# A1 is the first c element of the Welcome sheet, in row 1; row 6 is hidden.
error_cell='<c t="e"><f>1/0</f><v>#DIV/0!</v></c>'
edit_part "$root/toolkit/Sample_Assessment.xlsx" "$work/nocellref.xlsx" \
  xl/worksheets/sheet1.xml '<c r="A1" s="28"/>' "$error_cell"
start_case "case 24: a c element with no r attribute" \
  "$checker" "$work/nocellref.xlsx" toolkit/Sample_Assessment.xlsx
expect_no_cell_reference "$work/nocellref.xlsx" "a c element with no r attribute in row 1"
end_case

edit_part "$root/toolkit/Sample_Assessment.xlsx" "$work/badcellref.xlsx" \
  xl/worksheets/sheet1.xml '<c r="A1" s="28"/>' '<c r="1A" t="e"><f>1/0</f><v>#DIV/0!</v></c>'
start_case "case 25: a c element whose r attribute is not a cell reference" \
  "$checker" "$work/badcellref.xlsx" toolkit/Sample_Assessment.xlsx
expect_no_cell_reference "$work/badcellref.xlsx" \
  "a c element in row 1 whose r attribute 1A is not a cell reference"
end_case

edit_part "$work/nocellref.xlsx" "$work/norowref.xlsx" \
  xl/worksheets/sheet1.xml '<row r="1" ' '<row '
start_case "case 26: a c element with no r attribute in a row element with no r attribute" \
  "$checker" "$work/norowref.xlsx" toolkit/Sample_Assessment.xlsx
expect_no_cell_reference "$work/norowref.xlsx" "a c element with no r attribute"
end_case

edit_part "$root/toolkit/Sample_Assessment.xlsx" "$work/hiddenrow.xlsx" \
  xl/worksheets/sheet1.xml '<c r="E6" s="47"/>' "$error_cell"
start_case "case 27: a c element with no r attribute in a hidden row" \
  "$checker" "$work/hiddenrow.xlsx"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "nothing on stderr" '[ -z "$err" ]'
expect "no FAIL line" '[ "$(fail_count)" -eq 0 ]'
expect "one PASS line" '[ "$(pass_count)" -eq 1 ]'
expect "last line is RESULT: PASS" 'last_line_is "RESULT: PASS"'
end_case

# M1x starts with M1, a cell reference in column M, which is hidden.
edit_part "$work/badcellref.xlsx" "$work/prefixcellref.xlsx" \
  xl/worksheets/sheet1.xml '<c r="1A" ' '<c r="M1x" '
start_case "case 28: a c element whose r attribute only starts with a cell reference" \
  "$checker" "$work/prefixcellref.xlsx" toolkit/Sample_Assessment.xlsx
expect_no_cell_reference "$work/prefixcellref.xlsx" \
  "a c element in row 1 whose r attribute M1x is not a cell reference"
end_case

# Writes to $2 a copy of the workbook $1 in which each of the namespace names
# http://schemas.openxmlformats.org/spreadsheetml/2006/main and
# http://schemas.openxmlformats.org/officeDocument/2006/relationships is
# replaced by the one the Strict Open XML format uses in its place,
# http://purl.oclc.org/ooxml/spreadsheetml/main and
# http://purl.oclc.org/ooxml/officeDocument/relationships, in every part
# under xl/ whose name ends in .xml. Fails when xl/workbook.xml does not hold
# both names.
make_strict() {
  python3 -I - "$@" <<'PY'
import sys
import zipfile

source, target = sys.argv[1:3]
STRICT = {
    "http://schemas.openxmlformats.org/spreadsheetml/2006/main":
        "http://purl.oclc.org/ooxml/spreadsheetml/main",
    "http://schemas.openxmlformats.org/officeDocument/2006/relationships":
        "http://purl.oclc.org/ooxml/officeDocument/relationships",
}
with zipfile.ZipFile(source) as book, zipfile.ZipFile(target, "w") as copy:
    for info in book.infolist():
        data = book.read(info.filename)
        if info.filename.startswith("xl/") and info.filename.endswith(".xml"):
            text = data.decode("utf-8")
            for old, new in STRICT.items():
                if info.filename == "xl/workbook.xml" and old not in text:
                    sys.exit("make_strict: no %s in xl/workbook.xml" % old)
                text = text.replace(old, new)
            data = text.encode("utf-8")
        copy.writestr(info, data)
PY
}

# The PASS line of the output the checker last printed, or nothing.
pass_line() {
  printf '%s\n' "$out" | grep '^  PASS' || true
}

edit_part "$root/toolkit/Sample_Assessment.xlsx" "$work/a1error.xlsx" \
  xl/worksheets/sheet1.xml '<c r="A1" s="28"/>' '<c r="A1" t="e"><f>1/0</f><v>#DIV/0!</v></c>'
make_strict "$work/a1error.xlsx" "$work/strict-a1error.xlsx"
start_case "case 29: an error value in a visible cell of a workbook in the Strict namespaces" \
  "$checker" "$work/strict-a1error.xlsx" toolkit/Sample_Assessment.xlsx
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line for Welcome!A1 gives its formula" \
  "has_fail '$work/strict-a1error.xlsx: Welcome!A1 stores #DIV/0!: 1/0'"
expect "the sample workbook is checked" \
  'has_line "== toolkit/Sample_Assessment.xlsx" && [ "$(pass_count)" -eq 1 ]'
expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
end_case

# Case 30 expects the PASS line the checker prints for the sample workbook.
run_checker "$checker" toolkit/Sample_Assessment.xlsx
sample_pass="$(pass_line)"
make_strict "$root/toolkit/Sample_Assessment.xlsx" "$work/strict.xlsx"
start_case "case 30: the sample workbook in the Strict namespaces" "$checker" "$work/strict.xlsx"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "nothing on stderr" '[ -z "$err" ]'
expect "no FAIL line" '[ "$(fail_count)" -eq 0 ]'
expect "the PASS line counts as many visible formula cells as for the sample workbook" \
  '[ -n "$sample_pass" ] && [ "$(pass_line)" = "$sample_pass" ]'
expect "last line is RESULT: PASS" 'last_line_is "RESULT: PASS"'
end_case

# xl/workbook.xml of the sample workbook declares the spreadsheetml
# namespace once, as the default namespace of its root element.
edit_part "$root/toolkit/Sample_Assessment.xlsx" "$work/othernamespace.xlsx" \
  xl/workbook.xml 'xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"' \
  'xmlns="urn:example:spreadsheetml"'
start_case "case 31: sheet elements in a namespace the checker does not read" \
  "$checker" "$work/othernamespace.xlsx" toolkit/Sample_Assessment.xlsx
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says it is not a workbook as xl/workbook.xml has no sheet element the checker reads" \
  "has_fail '$work/othernamespace.xlsx: not a workbook (xl/workbook.xml has no sheet element in a namespace the script reads)'"
expect "the sample workbook is checked" \
  'has_line "== toolkit/Sample_Assessment.xlsx" && [ "$(pass_count)" -eq 1 ]'
expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
end_case

# The part gives the digit after M as a character reference: &#x661; for
# U+0661 and &#xFF11; for U+FF11. Under en_US.UTF-8 the FAIL line quotes the
# r attribute as UTF-8, in which \331\241 is U+0661 and \357\274\221 is
# U+FF11.
edit_part "$work/badcellref.xlsx" "$work/arabicdigit.xlsx" \
  xl/worksheets/sheet1.xml '<c r="1A" ' '<c r="M&#x661;" '
LC_ALL=en_US.UTF-8 start_case "case 32: a c element whose r attribute holds an Arabic-Indic digit" \
  "$checker" "$work/arabicdigit.xlsx" toolkit/Sample_Assessment.xlsx
expect_no_cell_reference "$work/arabicdigit.xlsx" \
  "a c element in row 1 whose r attribute M$(printf '\331\241') is not a cell reference"
end_case

edit_part "$work/badcellref.xlsx" "$work/fullwidthdigit.xlsx" \
  xl/worksheets/sheet1.xml '<c r="1A" ' '<c r="M&#xFF11;" '
LC_ALL=en_US.UTF-8 start_case "case 33: a c element whose r attribute holds a fullwidth digit" \
  "$checker" "$work/fullwidthdigit.xlsx" toolkit/Sample_Assessment.xlsx
expect_no_cell_reference "$work/fullwidthdigit.xlsx" \
  "a c element in row 1 whose r attribute M$(printf '\357\274\221') is not a cell reference"
end_case

# The part gives the control characters as character references: &#10; for
# the line feed, &#13; for the carriage return, &#9; for the tab and &#x85;
# for U+0085. The FAIL line is expected to hold each one's backslash escape.
edit_part "$work/badcellref.xlsx" "$work/controlcellref.xlsx" \
  xl/worksheets/sheet1.xml '<c r="1A" ' '<c r="1A&#10;RESULT: PASS&#13;&#9;&#x85;" '
start_case "case 34: a c element whose r attribute holds a line feed and other control characters" \
  "$checker" "$work/controlcellref.xlsx" toolkit/Sample_Assessment.xlsx
expect_no_cell_reference "$work/controlcellref.xlsx" \
  'a c element in row 1 whose r attribute 1A\nRESULT: PASS\r\t\x85 is not a cell reference'
expect "no line reads RESULT: PASS" '! printf "%s\n" "$out" | grep -q -x "RESULT: PASS"'
end_case

# Expectations for cases 35 to 37: $1 is the copy's file name, $2 the
# attribute of its hidden col element that the FAIL line names and $3 the
# value of that attribute, which the FAIL line quotes.
expect_bad_column_bound() {
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "no traceback on stderr" '[ -z "$err" ]'
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line says it is not a workbook as the $2 attribute of a hidden col element is not one or more of the digits 0 to 9" \
    "has_fail \"$1: not a workbook (xl/worksheets/sheet1.xml has a hidden col element whose $2 attribute '$3' is not one or more of the digits 0 to 9)\""
  expect "the sample workbook is checked" \
    'has_line "== toolkit/Sample_Assessment.xlsx" && [ "$(pass_count)" -eq 1 ]'
  expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
}

# M1 is in column M of the Welcome sheet, a hidden column.
edit_part "$root/toolkit/Sample_Assessment.xlsx" "$work/m1error.xlsx" \
  xl/worksheets/sheet1.xml '<c r="A1" s="28"/>' '<c r="M1" t="e"><f>1/0</f><v>#DIV/0!</v></c>'

# The part gives the digits as character references: &#x661; for U+0661 and
# &#x663; for U+0663. Under en_US.UTF-8 the FAIL line quotes the min
# attribute as UTF-8, in which \331\241 is U+0661 and \331\243 is U+0663.
edit_part "$work/m1error.xlsx" "$work/arabicbound.xlsx" \
  xl/worksheets/sheet1.xml '<col min="13" max="13" ' '<col min="&#x661;&#x663;" max="&#x661;&#x663;" '
LC_ALL=en_US.UTF-8 start_case "case 35: a hidden col element whose min and max hold Arabic-Indic digits" \
  "$checker" "$work/arabicbound.xlsx" toolkit/Sample_Assessment.xlsx
expect_bad_column_bound "$work/arabicbound.xlsx" min "$(printf '\331\241\331\243')"
end_case

edit_part "$work/m1error.xlsx" "$work/underscorebound.xlsx" \
  xl/worksheets/sheet1.xml '<col min="13" max="13" ' '<col min="13" max="1_3" '
start_case "case 36: a hidden col element whose max holds an underscore" \
  "$checker" "$work/underscorebound.xlsx" toolkit/Sample_Assessment.xlsx
expect_bad_column_bound "$work/underscorebound.xlsx" max 1_3
end_case

edit_part "$work/m1error.xlsx" "$work/letterbound.xlsx" \
  xl/worksheets/sheet1.xml '<col min="13" max="13" ' '<col min="x" max="13" '
start_case "case 37: a hidden col element whose min is a letter" \
  "$checker" "$work/letterbound.xlsx" toolkit/Sample_Assessment.xlsx
expect_bad_column_bound "$work/letterbound.xlsx" min x
end_case

# Expectations for cases 38 and 39: $1 is the copy's file name and $2 the
# reason its FAIL line gives.
expect_bad_encoding() {
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "no traceback on stderr" '[ -z "$err" ]'
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line says it is not a workbook ($2)" \
    "has_fail '$1: not a workbook ($2)'"
  expect "the sample workbook is checked" \
    'has_line "== toolkit/Sample_Assessment.xlsx" && [ "$(pass_count)" -eq 1 ]'
  expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
}

# The XML declaration of xl/worksheets/sheet1.xml in the sample workbook
# names the encoding UTF-8.
edit_part "$root/toolkit/Sample_Assessment.xlsx" "$work/unknownencoding.xlsx" \
  xl/worksheets/sheet1.xml 'encoding="UTF-8"' 'encoding="x-bogus"'
start_case "case 38: a sheet part whose XML declaration names an unknown encoding" \
  "$checker" "$work/unknownencoding.xlsx" toolkit/Sample_Assessment.xlsx
expect_bad_encoding "$work/unknownencoding.xlsx" "unknown encoding: x-bogus"
end_case

edit_part "$root/toolkit/Sample_Assessment.xlsx" "$work/multibyteencoding.xlsx" \
  xl/worksheets/sheet1.xml 'encoding="UTF-8"' 'encoding="shift_jis"'
start_case "case 39: a sheet part whose XML declaration names a multi-byte encoding" \
  "$checker" "$work/multibyteencoding.xlsx" toolkit/Sample_Assessment.xlsx
expect_bad_encoding "$work/multibyteencoding.xlsx" "multi-byte encodings are not supported"
end_case

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
