#!/usr/bin/env bash
# Tests scripts/check-compliance-map.py against the repository workbooks and
# against copies of the spec that differ from them.
#
# Usage:
#   scripts/test-check-compliance-map.sh
#
# Cases 2, 3, 6 and 7 copy the checker, the spec and both workbooks into a
# new temporary directory laid out like the repository (scripts/,
# toolkit-specs/ and toolkit/), edit the copy of the spec or of the
# workbooks, and run the checker there.
#
# Cases:
#   1. The repository spec and workbooks: exit 0, a map PASS line and a
#      category name PASS line for each workbook, RESULT: PASS.
#   2. A spec that differs from the workbooks in five cells: a different
#      control (Q1 CMMC), "-" where the workbooks carry a control (Q2 CMMC),
#      a control where the workbooks carry "-" (Q19 CMMC), a different weight
#      (Q3 CMMC) and a different CIS safeguard (Q1 CIS): exit 1, the 7 FAIL
#      lines those cells give for each workbook.
#   3. A spec with no row for Q120: exit 1, FAIL lines for the missing spec
#      cells and for the workbook rows the spec does not give.
#   4. A workbook argument that does not exist: exit 1, a FAIL line that
#      says the map cannot be read.
#   5. An option such as --help: exit 2, usage on stderr, then the checker's
#      header text, whose example of a CIS v8 safeguard a number cannot
#      keep apart from another is 3.10 and 3.1.
#   6. Workbooks whose Compliance sheet looks category names up in
#      Data!$BG$3:$BH$106, which ends before the FISMA and FedRAMP SR rows:
#      exit 1, a FAIL line for Q14 FISMA and Q14 FedRAMP in each workbook.
#   7. A workbook whose Compliance sheet has no category name lookup:
#      exit 1, a FAIL line that says the lookup cannot be read.
#   8. An empty workbook argument: exit 1, "FAIL '': no file name given",
#      no "cannot read" line.
#   9. Workbooks whose Q55 CIS v8 Control_ID (Data!AY442) is the number
#      1.1000000000000001 and whose Q59 CIS v8 Control_ID (Data!AY474) is
#      the text of Q1's (Data!AY10), where the spec gives 1.10 for both:
#      exit 1, a FAIL line for each of the two cells in each workbook.
#  10. Under the en_US.UTF-8 locale, a workbook argument that holds the byte
#      0xff, which is not valid UTF-8, and names no file, then the sample
#      workbook: exit 1, no traceback, the name printed with the byte as
#      \xff on its == line and in a FAIL line that says the map cannot be
#      read (No such file or directory), the map PASS line for the sample
#      workbook, then RESULT: FAIL.
#  11. Under the en_US.ISO8859-1 locale, a workbook argument that is valid
#      UTF-8 and holds the character U+65E5, which ISO-8859-1 cannot encode,
#      and names no file, then the sample workbook: exit 1, nothing on
#      stderr, the name printed with the character as \u65e5 on its == line
#      and in a FAIL line that says the map cannot be read (No such file or
#      directory), the map PASS line for the sample workbook, then
#      RESULT: FAIL. The case is skipped, with a line that says so, when
#      python3 -I does not decode file names as UTF-8 and write stdout as
#      ISO-8859-1 under that locale on this machine.
#  12. A zip archive whose end of central directory record gives a central
#      directory offset 1000 bytes past the end of the file, then the sample
#      workbook: exit 1, nothing on stderr, one FAIL line, which says the map
#      cannot be read (not a workbook), the map PASS line for the sample
#      workbook, then RESULT: FAIL. zipfile.is_zipfile() accepts this
#      archive, and zipfile raises OSError(22, "Invalid argument") when it
#      reads the xl/workbook.xml entry.
#  13. A zip archive whose xl/workbook.xml entry is stored with the deflate
#      method and whose first 4 bytes of deflate data are 0xff, which does
#      not decompress, then the sample workbook: exit 1, nothing on stderr,
#      one FAIL line, which says the map cannot be read (not a workbook),
#      the map PASS line for the sample workbook, then RESULT: FAIL. zlib
#      raises zlib.error("Error -3 while decompressing data: invalid block
#      type") when zipfile reads the entry.
#  14. A copy of the sample workbook whose Compliance sheet part has its
#      first 4 bytes of deflate data replaced by 0xff: exit 1, nothing on
#      stderr, the map PASS line, then one FAIL line, which says the
#      category name lookup cannot be read (not a workbook), then
#      RESULT: FAIL.
#  15. Under the en_US.ISO8859-1 locale, a copy of the sample workbook whose
#      Q1 FISMA Control_ID (Data!AY6) is SI-12 followed by the character
#      U+2192, which ISO-8859-1 cannot encode, and whose Q1 FedRAMP
#      Control_ID (Data!AY7) is CM-8 followed by U+00D7, which it can:
#      exit 1, nothing on stderr, two FAIL lines, the one for Q1 FISMA
#      giving the control with U+2192 as \u2192 and the one for Q1 FedRAMP
#      giving it with U+00D7 as the ISO-8859-1 byte 0xd7, the category name
#      PASS line, then RESULT: FAIL.
#  16. Under the en_US.ISO8859-1 locale, a copy of the sample workbook whose
#      Data sheet is named Data followed by U+2192 in the workbook's sheet
#      list, in the ComplianceMap range and in the Compliance sheet's
#      category name lookups: exit 0, nothing on stderr, the map PASS line,
#      the category name PASS line giving the range as
#      Data\u2192!BG3:BH108, then RESULT: PASS.
#  Cases 15 and 16 are skipped, with a line that says so, when python3 -I
#  does not write stdout as ISO-8859-1 under that locale on this machine.
#  15. A zip archive whose xl/workbook.xml entry has bit 0 of its general
#      purpose flags set, which marks it as encrypted. zipfile raises
#      RuntimeError("File 'xl/workbook.xml' is encrypted, password required
#      for extraction").
#  16. A zip archive whose xl/workbook.xml entry gives compression method
#      98 (PPMd), which zipfile does not support. zipfile raises
#      NotImplementedError("That compression method is not supported").
#  17. A zip archive whose xl/workbook.xml entry gives compression method
#      93 (Zstandard) and holds XML text, which is not Zstandard data. In
#      Python 3.14.3, compression.zstd raises ZstdError("Unable to decompress
#      Zstandard data: Unknown frame descriptor"). Python 3.13.12 and 3.9.6
#      have no compression.zstd module, and zipfile raises
#      NotImplementedError as in case 16.
#  18. A zip archive whose xl/workbook.xml entry gives compression method
#      14 (LZMA) and whose data starts with 11 bytes that do not decompress:
#      the 4-byte header zipfile reads before LZMA data, which gives 5 bytes
#      of LZMA properties, those properties, then 0xff 0xff. lzma raises
#      LZMAError("Corrupt input data").
#  Cases 15 to 18 pass the archive and then the sample workbook: exit 1,
#  nothing on stderr, one FAIL line, which says the map cannot be read (not
#  a workbook), the map PASS line for the sample workbook, then
#  RESULT: FAIL.
#  19 to 22. A copy of the sample workbook whose Compliance sheet part is
#      damaged as the xl/workbook.xml entry is in cases 15 to 18, in that
#      order: exit 1, nothing on stderr, the map PASS line, then one FAIL
#      line, which says the category name lookup cannot be read (not a
#      workbook), then RESULT: FAIL.
#  23. A zip archive whose xl/workbook.xml entry gives, in both of its
#      headers, a compressed and an uncompressed size equal to the length of
#      the archive, which run past its end, then the sample workbook: exit
#      1, nothing on stderr, one FAIL line, which says the map cannot be
#      read, the map PASS line for the sample workbook, then RESULT: FAIL.
#      With Python 3.9.6, zipfile reads the entry to the end of the file and
#      raises EOFError, and the FAIL line gives the reason as not a
#      workbook. Python 3.13.12 and 3.14.3 raise
#      zipfile.BadZipFile("Overlapped entries: 'xl/workbook.xml' (possible
#      zip bomb)") instead, and the FAIL line gives that reason.
#  24. The archive of case 23 with a second central directory header, for
#      an entry named xl/workbook.xmz, that gives the same local header
#      offset, then the sample workbook: as cases 15 to 18, except that
#      stderr can hold a warning. Python 3.13.12 and 3.14.3 print the
#      warning "UserWarning: Overlapped entries: 'xl/workbook.xml' (possible
#      zip bomb)" and read on, and zipfile raises EOFError, as with Python
#      3.9.6.
#  25. A copy of the sample workbook whose Compliance sheet part is damaged
#      as the xl/workbook.xml entry is in case 24, with the second central
#      directory header for xl/worksheets/sheet8.xmz: as cases 19 to 22,
#      except that stderr can hold the warning of case 24 for that part.
#  23. A copy of the sample workbook whose row element for row 3 of the Data
#      sheet, xl/worksheets/sheet10.xml, the first row of the ComplianceMap
#      range, has no r attribute, then the sample workbook: exit 1, nothing
#      on stderr, one FAIL line, which says the map cannot be read as
#      xl/worksheets/sheet10.xml has a row element with no r attribute, the
#      map PASS line for the sample workbook, then RESULT: FAIL.
#
# The temporary directory is made under .tmp-tests/ at the repository root,
# and the cleanup removes only a directory under it.
#
# Exit status: 0 when every case passes, 1 when any case fails.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
root="$(dirname "$here")"
checker="$here/check-compliance-map.py"
spec="toolkit-specs/4_QRAMM_Compliance_Mapping_Details.md"
toolkit="toolkit/QRAMM_Assessment_Toolkit.xlsx"
sample="toolkit/Sample_Assessment.xlsx"

tmp_root="$(cd "$here/.." && pwd -P)/.tmp-tests"
mkdir -p "$tmp_root"
work="$(mktemp -d "$tmp_root/check-compliance-map.XXXXXX")"
cleanup() {
  case "$work" in
    "$tmp_root"/?*) rm -rf -- "$work" ;;
    *) exit 1 ;;
  esac
  rmdir "$tmp_root" 2> /dev/null || true
}
trap cleanup EXIT

failed=0

# Lays out a copy of the repository at $1 with the spec edited by the sed
# script $2.
make_copy() {
  mkdir -p "$1/scripts" "$1/toolkit-specs" "$1/toolkit"
  cp "$checker" "$1/scripts/check-compliance-map.py"
  cp "$root/$toolkit" "$root/$sample" "$1/toolkit/"
  sed -e "$2" "$root/$spec" > "$1/$spec"
}

# Writes to $2 a copy of the workbook $1 with every "$3" in its worksheet
# parts replaced by "$4". Fails when no worksheet part of $1 contains "$3".
replace_in_sheets() {
  python3 -I - "$@" <<'PY'
import sys
import zipfile

source, target, old, new = sys.argv[1:5]
found = 0
with zipfile.ZipFile(source) as book, zipfile.ZipFile(target, "w") as copy:
    for info in book.infolist():
        data = book.read(info.filename)
        if info.filename.startswith("xl/worksheets/") and info.filename.endswith(".xml"):
            text = data.decode("utf-8")
            found += text.count(old)
            data = text.replace(old, new).encode("utf-8")
        copy.writestr(info, data)
sys.exit(0 if found else 1)
PY
}

# Writes to $2 a copy of the workbook $1 whose Data sheet cell $3 holds the
# number $4 and whose Data sheet cell $5 holds the stored value of its cell
# $6. Fails when the Data sheet lacks one of the cells.
edit_data_cells() {
  python3 -I - "$@" <<'PY'
import re
import sys
import zipfile

source, target, number_ref, number, copy_ref, from_ref = sys.argv[1:7]
data = "xl/worksheets/sheet10.xml"


def cell(text, ref):
    match = re.search(r'<c r="%s"( s="\d+")?[^>]*>.*?</c>' % ref, text)
    if match is None:
        sys.exit("no cell %s" % ref)
    return match


with zipfile.ZipFile(source) as book, zipfile.ZipFile(target, "w") as copy:
    for info in book.infolist():
        part = book.read(info.filename)
        if info.filename == data:
            text = part.decode("utf-8")
            old = cell(text, number_ref)
            text = text.replace(
                old.group(0),
                '<c r="%s"%s><v>%s</v></c>' % (number_ref, old.group(1) or "", number),
            )
            old = cell(text, copy_ref)
            text = text.replace(old.group(0), cell(text, from_ref).group(0).replace(
                'r="%s"' % from_ref, 'r="%s"' % copy_ref, 1))
            part = text.encode("utf-8")
        copy.writestr(info, part)
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

start_case "case 1: repository spec and workbooks" "$checker"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "PASS line for each workbook" \
  '[ "$(printf "%s\n" "$out" | grep -c "^  PASS 120 questions x 8 frameworks, 960 rows$")" -eq 2 ]'
expect "category name PASS line for each workbook" \
  '[ "$(printf "%s\n" "$out" | grep -c "^  PASS 848 rows with a category, each named in Data!BG3:BH108$")" -eq 2 ]'
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
expect "header text on stderr" \
  'printf "%s\n" "$err" | grep -qx "Checks that the toolkit workbooks carry the compliance mapping in the spec."'
expect "header text gives CIS v8 safeguards 3.10 and 3.1 as its example" \
  'printf "%s\n" "$err" | grep -qx "       safeguard such as 3.10 apart from 3.1."'
end_case

make_copy "$work/narrow" ''
for book in "$toolkit" "$sample"; do
  replace_in_sheets "$root/$book" "$work/narrow/$book" \
    'Data!$BG$3:$BH$108' 'Data!$BG$3:$BH$106'
done
start_case "case 6: category name lookup that ends at row 106" \
  "$work/narrow/scripts/check-compliance-map.py"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "4 FAIL lines (2 for each workbook)" '[ "$(fail_count)" -eq 4 ]'
expect "map PASS line for each workbook" \
  '[ "$(printf "%s\n" "$out" | grep -c "^  PASS 120 questions x 8 frameworks, 960 rows$")" -eq 2 ]'
for book in "$toolkit" "$sample"; do
  expect "$book: Q14 FISMA category name" \
    "has_fail '$book Q14 FISMA: Data!AZ110 is SR, which has no name in Data!BG3:BH106'"
  expect "$book: Q14 FedRAMP category name" \
    "has_fail '$book Q14 FedRAMP: Data!AZ111 is SR, which has no name in Data!BG3:BH106'"
done
end_case

make_copy "$work/nolookup" ''
replace_in_sheets "$root/$sample" "$work/nolookup/$sample" \
  'VLOOKUP(_xlfn.CONCAT($M$4,' 'HLOOKUP(_xlfn.CONCAT($M$4,'
start_case "case 7: Compliance sheet with no category name lookup" \
  "$work/nolookup/scripts/check-compliance-map.py" "$sample"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line says the lookup cannot be read" \
  "has_fail '$sample: cannot read the category name lookup (the Compliance sheet has no category name lookup)'"
end_case

start_case "case 8: an empty workbook argument" "$checker" ""
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL says no file name was given" \
  'printf "%s\n" "$out" | grep -qxF "  FAIL '"''"': no file name given"'
expect "no cannot read line" '! printf "%s\n" "$out" | grep -q "cannot read"'
end_case

make_copy "$work/numeric" ''
for book in "$toolkit" "$sample"; do
  edit_data_cells "$root/$book" "$work/numeric/$book" \
    AY442 1.1000000000000001 AY474 AY10
done
start_case "case 9: Q55 CIS v8 stored as the number 1.1, Q59 as the text 1.1" \
  "$work/numeric/scripts/check-compliance-map.py"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "4 FAIL lines (2 for each workbook)" '[ "$(fail_count)" -eq 4 ]'
for book in "$toolkit" "$sample"; do
  expect "$book: Q55 CIS control stored as a number" \
    "has_fail '$book Q55 CIS v8: Data!AY442 is the number 1.1, the spec gives 1.10 (line 114)'"
  expect "$book: Q59 CIS control stored as 1.1" \
    "has_fail '$book Q59 CIS v8: Data!AY474 is 1.1, the spec gives 1.10 (line 118)'"
done
end_case

# \377 is the byte 0xff, which is not valid UTF-8, so Python holds it as a
# lone surrogate. Under en_US.UTF-8 printing that raises UnicodeEncodeError;
# the C, C.UTF-8 and UTF-8 locales write the byte as it is. The checker is
# expected to print \xff in either case. No file is made with this name.
LC_ALL=en_US.UTF-8 start_case "case 10: a workbook argument that is not UTF-8" \
  "$checker" "$work/bad$(printf '\377').xlsx" "$sample"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "the name is printed with the byte as \\xff" \
  "has_line '== $work/bad\\xff.xlsx against $spec'"
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says the map cannot be read and gives the byte as \\xff" \
  "has_line '  FAIL $work/bad\\xff.xlsx: cannot read the compliance map (No such file or directory)'"
expect "the sample workbook is checked" \
  "has_line '== $sample against $spec' && has_line '  PASS 120 questions x 8 frameworks, 960 rows'"
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

# \346\227\245 is U+65E5 encoded as UTF-8. Under en_US.ISO8859-1 on macOS,
# python3 decodes the name as UTF-8 and writes stdout as ISO-8859-1, which
# has no byte for U+65E5, so printing the name as it is raises
# UnicodeEncodeError. The checker is expected to print \u65e5 in its place.
# No file is made with this name.
title="case 11: a workbook argument that stdout's encoding cannot hold"
probe="$(LC_ALL=en_US.ISO8859-1 python3 -I -c 'import codecs, sys; print(codecs.lookup(sys.getfilesystemencoding()).name, codecs.lookup(sys.stdout.encoding).name)' 2>&1 || true)"
if [ "$probe" = "utf-8 iso8859-1" ]; then
  LC_ALL=en_US.ISO8859-1 start_case "$title" \
    "$checker" "$work/$(printf '\346\227\245').xlsx" "$sample"
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "no traceback on stderr" '[ -z "$err" ]'
  expect "the name is printed with the character as \\u65e5" \
    "has_line '== $work/\\u65e5.xlsx against $spec'"
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line says the map cannot be read and gives the character as \\u65e5" \
    "has_line '  FAIL $work/\\u65e5.xlsx: cannot read the compliance map (No such file or directory)'"
  expect "the sample workbook is checked" \
    "has_line '== $sample against $spec' && has_line '  PASS 120 questions x 8 frameworks, 960 rows'"
  expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
  end_case
else
  echo "$title"
  echo "  skip python3 does not decode file names as UTF-8 and write stdout as ISO-8859-1 under en_US.ISO8859-1 here ($probe)"
fi

# Writes to $1 a zip archive with one entry, xl/workbook.xml, whose end of
# central directory record gives a central directory offset 1000 bytes past
# the end of the file.
make_bad_offset() {
  python3 -I - "$1" <<'PY'
import struct
import sys
import zipfile

path = sys.argv[1]
with zipfile.ZipFile(path, "w") as book:
    book.writestr("xl/workbook.xml", "<workbook/>")
with open(path, "rb") as fh:
    data = bytearray(fh.read())
# The archive has no comment, so its last 22 bytes are the end of central
# directory record, which ends with the central directory's offset and a
# 2-byte comment length.
struct.pack_into("<I", data, len(data) - 6, len(data) + 1000)
with open(path, "wb") as fh:
    fh.write(data)
PY
}

make_bad_offset "$work/badoffset.xlsx"
start_case "case 12: a central directory offset past the end of the file" \
  "$checker" "$work/badoffset.xlsx" "$sample"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says the map cannot be read as it is not a workbook" \
  "has_line '  FAIL $work/badoffset.xlsx: cannot read the compliance map (not a workbook)'"
expect "the sample workbook is checked" \
  "has_line '== $sample against $spec' && has_line '  PASS 120 questions x 8 frameworks, 960 rows'"
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

# Writes to $1 a zip archive whose entry $2 is stored with the deflate method
# and has its first 4 bytes of deflate data replaced by 0xff, which start a
# block of the reserved type 3. With $3, the archive holds every entry of the
# workbook $3; without it, it holds only $2, a compressible xl/workbook.xml.
make_bad_deflate() {
  python3 -I - "$@" <<'PY'
import struct
import sys
import zipfile

path, entry = sys.argv[1:3]
with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as book:
    if len(sys.argv) > 3:
        with zipfile.ZipFile(sys.argv[3]) as source:
            for info in source.infolist():
                book.writestr(info.filename, source.read(info.filename))
    else:
        book.writestr(entry, "<workbook>" + "AB" * 1500 + "</workbook>")
with zipfile.ZipFile(path) as book:
    offset = book.getinfo(entry).header_offset
with open(path, "rb") as fh:
    data = bytearray(fh.read())
# The entry's data follows its 30-byte local file header, which gives the
# lengths of the file name and of the extra field at offsets 26 and 28.
name_length, extra_length = struct.unpack_from("<HH", data, offset + 26)
start = offset + 30 + name_length + extra_length
data[start:start + 4] = bytes([255] * 4)
with open(path, "wb") as fh:
    fh.write(data)
PY
}

make_bad_deflate "$work/deflate.xlsx" xl/workbook.xml
start_case "case 13: deflate data that does not decompress" \
  "$checker" "$work/deflate.xlsx" "$sample"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says the map cannot be read as it is not a workbook" \
  "has_line '  FAIL $work/deflate.xlsx: cannot read the compliance map (not a workbook)'"
expect "the sample workbook is checked" \
  "has_line '== $sample against $spec' && has_line '  PASS 120 questions x 8 frameworks, 960 rows'"
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

# The Compliance sheet is rId8 in the sample workbook, xl/worksheets/sheet8.xml.
make_bad_deflate "$work/lookup.xlsx" xl/worksheets/sheet8.xml "$root/$sample"
start_case "case 14: deflate data in the Compliance sheet that does not decompress" \
  "$checker" "$work/lookup.xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "the map is checked" "has_line '  PASS 120 questions x 8 frameworks, 960 rows'"
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says the category name lookup cannot be read as it is not a workbook" \
  "has_line '  FAIL $work/lookup.xlsx: cannot read the category name lookup (not a workbook)'"
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

# Writes to $2 a copy of the workbook $1 whose Data sheet cell $3 holds the
# text $4, and so on for each further pair of a cell and a text. A text is
# given with Python's backslash escapes, such as \u2192 for the character
# U+2192. Fails when the Data sheet lacks one of the cells.
set_data_text() {
  python3 -I - "$@" <<'PY'
import re
import sys
import zipfile

source, target = sys.argv[1:3]
pairs = list(zip(sys.argv[3::2], sys.argv[4::2]))
data = "xl/worksheets/sheet10.xml"

with zipfile.ZipFile(source) as book, zipfile.ZipFile(target, "w") as copy:
    for info in book.infolist():
        part = book.read(info.filename)
        if info.filename == data:
            text = part.decode("utf-8")
            for ref, value in pairs:
                old = re.search(r'<c r="%s"( s="\d+")?[^>]*>.*?</c>' % ref, text)
                if old is None:
                    sys.exit("no cell %s" % ref)
                value = value.encode("ascii").decode("unicode_escape")
                text = text.replace(
                    old.group(0),
                    '<c r="%s"%s t="inlineStr"><is><t>%s</t></is></c>'
                    % (ref, old.group(1) or "", value),
                )
            part = text.encode("utf-8")
        copy.writestr(info, part)
PY
}

# Writes to $2 a copy of the workbook $1 whose Data sheet is named $3, given
# with Python's backslash escapes, in the workbook's sheet list, in the
# ComplianceMap range and in the category name lookups of the Compliance
# sheet, xl/worksheets/sheet8.xml in the sample workbook. Fails when one of
# them does not name the Data sheet.
rename_data_sheet() {
  python3 -I - "$@" <<'PY'
import sys
import zipfile

source, target, name = sys.argv[1:4]
name = name.encode("ascii").decode("unicode_escape")
edits = {
    "xl/workbook.xml": [
        ('<sheet name="Data" ', '<sheet name="%s" ' % name),
        (">Data!$AV$3:$BA$962<", ">'%s'!$AV$3:$BA$962<" % name),
    ],
    "xl/worksheets/sheet8.xml": [
        ("Data!$BG$3:$BH$108", "'%s'!$BG$3:$BH$108" % name),
    ],
}
with zipfile.ZipFile(source) as book, zipfile.ZipFile(target, "w") as copy:
    for info in book.infolist():
        part = book.read(info.filename)
        for old, new in edits.get(info.filename, []):
            text = part.decode("utf-8")
            if old not in text:
                sys.exit("no %s in %s" % (old, info.filename))
            part = text.replace(old, new).encode("utf-8")
        copy.writestr(info, part)
PY
}

# U+2192 has no byte in ISO-8859-1, and U+00D7 has the byte 0xd7 (\327).
# Under en_US.ISO8859-1 on macOS, python3 writes stdout as ISO-8859-1, so
# printing a line that quotes U+2192 as it is raises UnicodeEncodeError. The
# checker is expected to print \u2192 in place of U+2192 and the byte 0xd7
# for U+00D7. The line with that byte is matched under LC_ALL=C, where grep
# compares bytes, not characters.
stdout_encoding="$(LC_ALL=en_US.ISO8859-1 python3 -I -c 'import codecs, sys; print(codecs.lookup(sys.stdout.encoding).name)' 2>&1 || true)"

title="case 15: FAIL lines that quote a character stdout's encoding cannot hold"
if [ "$stdout_encoding" = "iso8859-1" ]; then
  set_data_text "$root/$sample" "$work/arrowmap.xlsx" AY6 'SI-12\u2192' AY7 'CM-8\u00d7'
  LC_ALL=en_US.ISO8859-1 start_case "$title" "$checker" "$work/arrowmap.xlsx"
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "no traceback on stderr" '[ -z "$err" ]'
  expect "two FAIL lines" '[ "$(LC_ALL=C fail_count)" -eq 2 ]'
  expect "FAIL line for Q1 FISMA gives the control with U+2192 as \\u2192" \
    "has_line '  FAIL $work/arrowmap.xlsx Q1 FISMA: Data!AY6 is SI-12\\u2192, the spec gives SI-12 (line 33)'"
  ay7_line="  FAIL $work/arrowmap.xlsx Q1 FedRAMP: Data!AY7 is CM-8$(printf '\327'), the spec gives CM-8 (line 33)"
  expect "FAIL line for Q1 FedRAMP gives the control with U+00D7 as the byte 0xd7" \
    'LC_ALL=C has_line "$ay7_line"'
  expect "the category names are checked" \
    "has_line '  PASS 848 rows with a category, each named in Data!BG3:BH108'"
  expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
  end_case
else
  echo "$title"
  echo "  skip python3 does not write stdout as ISO-8859-1 under en_US.ISO8859-1 here ($stdout_encoding)"
fi

# The category name PASS line names the range the Compliance sheet looks
# category names up in, with the sheet name its formulas give.
title="case 16: a PASS line that quotes a sheet name stdout's encoding cannot hold"
if [ "$stdout_encoding" = "iso8859-1" ]; then
  rename_data_sheet "$root/$sample" "$work/renamed.xlsx" 'Data\u2192'
  LC_ALL=en_US.ISO8859-1 start_case "$title" "$checker" "$work/renamed.xlsx"
  expect "exit status is 0" '[ "$status" -eq 0 ]'
  expect "no traceback on stderr" '[ -z "$err" ]'
  expect "the map is checked" "has_line '  PASS 120 questions x 8 frameworks, 960 rows'"
  expect "the category name PASS line gives the sheet name with U+2192 as \\u2192" \
    "has_line '  PASS 848 rows with a category, each named in Data\\u2192!BG3:BH108'"
  expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
  end_case
else
  echo "$title"
  echo "  skip python3 does not write stdout as ISO-8859-1 under en_US.ISO8859-1 here ($stdout_encoding)"
fi

# Writes to $1 a zip archive whose entry $2 is stored, with no compression,
# and damaged as $3 names. encrypted: both headers of the entry set bit 0 of
# the general purpose flags, which marks the entry as encrypted. ppmd, zstd
# and lzma: both headers of the entry give compression method 98 (PPMd), 93
# (Zstandard) or 14 (LZMA); for lzma, the first 11 bytes of the entry's data
# are replaced by the 4-byte header zipfile reads before LZMA data, which
# gives 5 bytes of LZMA properties, the properties 0x5d (lc=3, lp=0, pb=2)
# and a 64 KiB dictionary size, then 0xff 0xff. past-end: both headers of
# the entry give a compressed and an uncompressed size equal to the length
# of the archive, which run past its end, as the entry's data starts after
# its local file header. same-offset: as past-end, with a copy of the
# entry's central directory header, whose file name ends in z in place of
# the last letter, at the end of the central directory. With $4, the archive
# holds every entry of the workbook $4, the others stored with the deflate
# method; without it, it holds only $2, an xl/workbook.xml of XML text.
make_damaged_entry() {
  python3 -I - "$@" <<'PY'
import struct
import sys
import zipfile

path, entry, damage = sys.argv[1:4]
with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as book:
    if len(sys.argv) > 4:
        with zipfile.ZipFile(sys.argv[4]) as source:
            for info in source.infolist():
                book.writestr(
                    info.filename,
                    source.read(info.filename),
                    compress_type=zipfile.ZIP_STORED if info.filename == entry else None,
                )
    else:
        book.writestr(
            entry,
            "<workbook>" + "AB" * 1500 + "</workbook>",
            compress_type=zipfile.ZIP_STORED,
        )
with zipfile.ZipFile(path) as book:
    names = book.namelist()
    local = book.getinfo(entry).header_offset
with open(path, "rb") as fh:
    data = bytearray(fh.read())
# The archive has no comment, so its last 22 bytes are the end of central
# directory record, which ends with the central directory's offset and a
# 2-byte comment length. The central directory holds a header for each entry
# in the order namelist() gives: 46 bytes, then the file name, the extra
# field and the comment, whose lengths the header gives at offsets 28, 30
# and 32.
(central,) = struct.unpack_from("<I", data, len(data) - 6)
for _ in range(names.index(entry)):
    central += 46 + sum(struct.unpack_from("<HHH", data, central + 28))
if damage == "encrypted":
    # The local file header gives the general purpose flags at offset 6; the
    # central directory header gives them at offset 8.
    for offset in (local + 6, central + 8):
        (flags,) = struct.unpack_from("<H", data, offset)
        struct.pack_into("<H", data, offset, flags | 1)
elif damage in ("ppmd", "zstd", "lzma"):
    # The local file header gives the compression method at offset 8; the
    # central directory header gives it at offset 10.
    method = {"ppmd": 98, "zstd": 93, "lzma": 14}[damage]
    struct.pack_into("<H", data, local + 8, method)
    struct.pack_into("<H", data, central + 10, method)
    if damage == "lzma":
        # The entry's data follows its 30-byte local file header, which
        # gives the lengths of the file name and of the extra field at
        # offsets 26 and 28.
        name_length, extra_length = struct.unpack_from("<HH", data, local + 26)
        start = local + 30 + name_length + extra_length
        data[start:start + 11] = bytes([9, 20, 5, 0, 0x5D, 0, 0, 1, 0, 255, 255])
elif damage in ("past-end", "same-offset"):
    headers = [central]
    if damage == "same-offset":
        # The end of central directory record gives the number of entries on
        # this disk and in all at offsets 8 and 10, and the size of the
        # central directory at offset 12.
        name_length = struct.unpack_from("<H", data, central + 28)[0]
        size = 46 + sum(struct.unpack_from("<HHH", data, central + 28))
        record = data[central:central + size]
        record[45 + name_length] = ord("z")
        end = data[len(data) - 22:]
        entries, _, directory_size = struct.unpack_from("<HHI", end, 8)
        struct.pack_into("<HHI", end, 8, entries + 1, entries + 1, directory_size + size)
        headers.append(len(data) - 22)
        data = data[:len(data) - 22] + record + end
    # The local file header gives the compressed and uncompressed sizes at
    # offsets 18 and 22; a central directory header gives them at offsets 20
    # and 24.
    struct.pack_into("<II", data, local + 18, len(data), len(data))
    for header in headers:
        struct.pack_into("<II", data, header + 20, len(data), len(data))
else:
    sys.exit("make_damaged_entry: unknown damage " + damage)
with open(path, "wb") as fh:
    fh.write(data)
PY
}

# True when stderr is empty or each of its lines holds "UserWarning:
# Overlapped entries: '$1' (possible zip bomb)" or starts with two spaces,
# as do the two lines of the warning Python 3.13.12 and 3.14.3 print for the
# entry $1 of the archives of cases 24 and 25: the second quotes the
# checker's line that read the entry. The first line of a traceback does
# neither.
only_overlap_warning() {
  local rest
  rest="$(printf '%s\n' "$err" \
    | grep -v -F -- "UserWarning: Overlapped entries: '$1' (possible zip bomb)" \
    | grep -v '^  ' || true)"
  [ -z "$rest" ]
}

# Expects nothing on stderr or, with $1, at most the warning
# only_overlap_warning allows for the entry $1.
expect_no_traceback() {
  if [ "$#" -gt 0 ]; then
    expect "no traceback on stderr, at most a warning for $1" \
      "only_overlap_warning '$1'"
  else
    expect "no traceback on stderr" '[ -z "$err" ]'
  fi
}

# Expectations for cases 15 to 18 and 24: $1 is the archive's file name.
# With $2, stderr can hold the warning only_overlap_warning allows for the
# entry $2.
expect_map_not_a_workbook() {
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect_no_traceback "${@:2}"
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line says the map cannot be read as it is not a workbook" \
    "has_line '  FAIL $1: cannot read the compliance map (not a workbook)'"
  expect "the sample workbook is checked" \
    "has_line '== $sample against $spec' && has_line '  PASS 120 questions x 8 frameworks, 960 rows'"
  expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
}

# Expectations for cases 19 to 22 and 25: $1 is the copy's file name. With
# $2, stderr can hold the warning only_overlap_warning allows for the entry
# $2.
expect_lookup_not_a_workbook() {
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect_no_traceback "${@:2}"
  expect "the map is checked" "has_line '  PASS 120 questions x 8 frameworks, 960 rows'"
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line says the category name lookup cannot be read as it is not a workbook" \
    "has_line '  FAIL $1: cannot read the category name lookup (not a workbook)'"
  expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
}

make_damaged_entry "$work/encrypted.xlsx" xl/workbook.xml encrypted
start_case "case 15: an entry marked as encrypted" \
  "$checker" "$work/encrypted.xlsx" "$sample"
expect_map_not_a_workbook "$work/encrypted.xlsx"
end_case

make_damaged_entry "$work/ppmd.xlsx" xl/workbook.xml ppmd
start_case "case 16: compression method 98 (PPMd)" \
  "$checker" "$work/ppmd.xlsx" "$sample"
expect_map_not_a_workbook "$work/ppmd.xlsx"
end_case

make_damaged_entry "$work/zstd.xlsx" xl/workbook.xml zstd
start_case "case 17: Zstandard data that does not decompress" \
  "$checker" "$work/zstd.xlsx" "$sample"
expect_map_not_a_workbook "$work/zstd.xlsx"
end_case

make_damaged_entry "$work/lzma.xlsx" xl/workbook.xml lzma
start_case "case 18: LZMA data that does not decompress" \
  "$checker" "$work/lzma.xlsx" "$sample"
expect_map_not_a_workbook "$work/lzma.xlsx"
end_case

make_damaged_entry "$work/lookup-encrypted.xlsx" xl/worksheets/sheet8.xml encrypted "$root/$sample"
start_case "case 19: a Compliance sheet part marked as encrypted" \
  "$checker" "$work/lookup-encrypted.xlsx"
expect_lookup_not_a_workbook "$work/lookup-encrypted.xlsx"
end_case

make_damaged_entry "$work/lookup-ppmd.xlsx" xl/worksheets/sheet8.xml ppmd "$root/$sample"
start_case "case 20: a Compliance sheet part with compression method 98 (PPMd)" \
  "$checker" "$work/lookup-ppmd.xlsx"
expect_lookup_not_a_workbook "$work/lookup-ppmd.xlsx"
end_case

make_damaged_entry "$work/lookup-zstd.xlsx" xl/worksheets/sheet8.xml zstd "$root/$sample"
start_case "case 21: Zstandard data in the Compliance sheet that does not decompress" \
  "$checker" "$work/lookup-zstd.xlsx"
expect_lookup_not_a_workbook "$work/lookup-zstd.xlsx"
end_case

make_damaged_entry "$work/lookup-lzma.xlsx" xl/worksheets/sheet8.xml lzma "$root/$sample"
start_case "case 22: LZMA data in the Compliance sheet that does not decompress" \
  "$checker" "$work/lookup-lzma.xlsx"
expect_lookup_not_a_workbook "$work/lookup-lzma.xlsx"
end_case

# The FAIL line for the archive $1 of case 23: the one Python 3.9.6 gives, or
# the one Python 3.13.12 and 3.14.3 give.
past_end_fail() {
  has_line "  FAIL $1: cannot read the compliance map (not a workbook)" ||
    has_line "  FAIL $1: cannot read the compliance map (Overlapped entries: 'xl/workbook.xml' (possible zip bomb))"
}

make_damaged_entry "$work/past-end.xlsx" xl/workbook.xml past-end
start_case "case 23: entry sizes that run past the end of the file" \
  "$checker" "$work/past-end.xlsx" "$sample"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect_no_traceback
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says the map cannot be read" "past_end_fail '$work/past-end.xlsx'"
expect "the sample workbook is checked" \
  "has_line '== $sample against $spec' && has_line '  PASS 120 questions x 8 frameworks, 960 rows'"
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

make_damaged_entry "$work/same-offset.xlsx" xl/workbook.xml same-offset
start_case "case 24: entry sizes past the end and a second header at the same offset" \
  "$checker" "$work/same-offset.xlsx" "$sample"
expect_map_not_a_workbook "$work/same-offset.xlsx" xl/workbook.xml
end_case

make_damaged_entry "$work/lookup-same-offset.xlsx" xl/worksheets/sheet8.xml same-offset "$root/$sample"
start_case "case 25: Compliance sheet part sizes past the end and a second header at the same offset" \
  "$checker" "$work/lookup-same-offset.xlsx"
expect_lookup_not_a_workbook "$work/lookup-same-offset.xlsx" xl/worksheets/sheet8.xml
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

# The Data sheet is xl/worksheets/sheet10.xml in the sample workbook, and
# the ComplianceMap range, Data!$AV$3:$BA$962, starts at its row 3.
edit_part "$root/$sample" "$work/norow.xlsx" xl/worksheets/sheet10.xml '<row r="3" ' '<row '
start_case "case 23: a row element with no r attribute" \
  "$checker" "$work/norow.xlsx" "$sample"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says the map cannot be read as a row element has no r attribute" \
  "has_line '  FAIL $work/norow.xlsx: cannot read the compliance map (xl/worksheets/sheet10.xml has a row element with no r attribute)'"
expect "the sample workbook is checked" \
  "has_line '== $sample against $spec' && has_line '  PASS 120 questions x 8 frameworks, 960 rows'"
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
