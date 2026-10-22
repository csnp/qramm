#!/usr/bin/env bash
# Tests scripts/check-workbook-protection.py against the tracked workbooks
# and against files built at run time, most of them from a copy of
# toolkit/Sample_Assessment.xlsx, a tracked workbook.
#
# Usage:
#   scripts/test-check-workbook-protection.sh
#
# Cases 2 to 7 copy the checker into scripts/ of a new temporary directory,
# so the checker treats that directory as the repository root, and run it
# with no file arguments, except case 4 and the second run of case 7.
# GIT_CEILING_DIRECTORIES stops git from finding a checkout above the
# temporary directory. The other cases pass the files they build as
# arguments. A copy of the sample workbook gets a protection element in
# the place the schema gives it: after </sheetData> in a sheet, and before
# <workbookPr (fileSharing) or <bookViews> (workbookProtection) in
# xl/workbook.xml. xl/worksheets/sheet1.xml is the Welcome sheet, the first
# sheet, and xl/worksheets/sheet2.xml the Profile sheet.
#
# Each attribute value that a case writes, other than the value of an on/off
# setting, is FAKE-1234. Each case that expects a FAIL line for an attribute
# checks that FAKE-1234 is printed nowhere, on stdout or on stderr.
#
# Cases:
#   1. The tracked workbooks, with no file arguments: exit 0, nothing on
#      stderr, an == line for each tracked file whose name ends in .xlsx, in
#      the order git ls-files lists them, and at least one, a PASS line for
#      each, no FAIL line, a summary line that gives that number of files
#      and 0 elements with an attribute that is not an on/off setting, and
#      RESULT: PASS as the last line.
#   2. Not a git checkout, no file arguments: exit 1, nothing on stderr, two
#      lines: a FAIL line that says it is not a git checkout and to pass the
#      files to check as arguments, then RESULT: FAIL.
#   3. Case 2 with LANG, LC_ALL and LANGUAGE set to German, so that git
#      prints its messages in German: the same results as case 2. The case
#      is skipped, with a line that says so, when git prints its message
#      untranslated for German on this machine.
#   4. Not a git checkout, the workbook given as an argument: exit 0, one
#      PASS line, RESULT: PASS.
#   5. A git checkout that tracks no workbook: exit 1, nothing on stderr, two
#      lines: a FAIL line that says git ls-files lists no workbook, then
#      RESULT: FAIL.
#   6. A git checkout whose tracked toolkit/Sample_Assessment.xlsx is a copy
#      of the sample workbook with a sheetProtection element in
#      xl/worksheets/sheet1.xml that has a password attribute and the on/off
#      settings sheet, objects and scenarios: exit 1, nothing on stderr, one
#      FAIL line, which names the file, the part, sheetProtection and
#      password, a summary line that counts 1 element with an attribute that
#      is not an on/off setting, and RESULT: FAIL as the last line.
#   7. A git checkout that tracks copies of the sample workbook named
#      Book.xlsx, Upper.XLSX and Macro.xlsm, and a compound file named
#      Old.XLS: exit 1, nothing on stderr, a FAIL line for Macro.xlsm and one
#      for Old.XLS that says the checker does not read that format, no
#      other FAIL line, a PASS line for each of the other two, 4 files
#      checked, and RESULT: FAIL as the last line. Then Macro.xlsm given as
#      an argument: exit 1, the same FAIL line for it, and no other.
#   8. In xl/worksheets/sheet1.xml, a sheetProtection element with the hash
#      attributes algorithmName, hashValue, saltValue and spinCount and the
#      on/off setting sheet: one FAIL line, which names the four.
#   9. In xl/workbook.xml, a workbookProtection element with the attributes
#      workbookPassword and workbookHashValue and the on/off setting
#      lockStructure: one FAIL line, which names the two.
#  10. In xl/workbook.xml, a fileSharing element with a reservationPassword
#      attribute and the on/off setting readOnlyRecommended: one FAIL line,
#      which names reservationPassword.
#  11. In xl/worksheets/sheet1.xml, a protectedRanges element that holds a
#      protectedRange element with the attributes password, sqref and name,
#      and one with only sqref and name: two FAIL lines, one that names
#      password, sqref and name, and one that names sqref and name.
#  12. In xl/worksheets/sheet1.xml, a sheetProtection element with an
#      attribute named note, which is in no list, and the on/off setting
#      sheet: one FAIL line, which names note.
#  13. A sheetProtection element with a password attribute and the on/off
#      setting sheet in three sheets: in xl/worksheets/sheet1.xml written
#      with the prefix x, bound to the SpreadsheetML namespace, in
#      xl/worksheets/sheet2.xml in no namespace (xmlns=""), and in
#      xl/worksheets/sheet3.xml in the namespace urn:example:FAKE-1234: three
#      FAIL lines, one for each part, which name sheetProtection and
#      password.
#  14. In xl/worksheets/sheet1.xml, a sheetProtection element whose sheet
#      attribute is in the namespace urn:example:FAKE-1234: one FAIL line,
#      which names it as "sheet in a namespace". The namespace is the value
#      of an xmlns attribute, so it is not printed either.
#  15. In xl/worksheets/sheet1.xml, a sheetProtection element whose sheet
#      attribute has the value FAKE-1234 and whose objects attribute has the
#      value 1: one FAIL line, which names sheet as an on/off attribute
#      whose value is not true, false, 1 or 0.
#  16. The copy of case 6 with xl/worksheets/sheet1.xml renamed
#      XL/worksheets/sheet1.XML: one FAIL line, which names that part.
#  17. The copy of case 6 with xl/worksheets/sheet1.xml renamed
#      xl/worksheets/a, a line feed, then RESULT: PASS.xml: one FAIL line,
#      which names the part with the line feed as \n, so no line of the
#      output is RESULT: PASS.
#  Cases 8 to 17 pass the copy alone: exit 1, nothing on stderr, the FAIL
#  lines given and no other, FAKE-1234 printed nowhere, and RESULT: FAIL as
#  the last line.
#  18. A copy of the sample workbook whose xl/worksheets/sheet1.xml holds
#      <sheetProtection followed by the next element, so it is not
#      well-formed XML: exit 1, nothing on stderr, one FAIL line, which says
#      that part is not well-formed XML and gives a line and a column, and
#      RESULT: FAIL as the last line.
#  19. On/off settings only: a copy of the sample workbook with a
#      sheetProtection element with sheet, objects and scenarios set to 1 in
#      xl/worksheets/sheet1.xml, a sheetProtection element written with the
#      prefix x, with sheet set to true and formatCells set to 0 with a tab
#      and a space before it and a line feed and a carriage return after it,
#      in xl/worksheets/sheet2.xml, and a fileSharing element with
#      readOnlyRecommended set to 1 and a workbookProtection element with
#      lockStructure set to 1 and lockWindows set to false in
#      xl/workbook.xml: exit 0, nothing on stderr, no FAIL line, the PASS
#      line the checker prints for the sample workbook with 4 protection
#      elements in place of 0, the summary line "1 files checked, 4
#      protection elements with on/off settings only, 0 with an attribute
#      that is not an on/off setting", and RESULT: PASS as the last line.
#  20. A text file.
#  21. A compound file, the container an encrypted workbook is stored in:
#      the 8-byte signature D0 CF 11 E0 A1 B1 1A E1, then 504 zero bytes.
#  22-31. A zip archive with one entry, which zipfile cannot read: an entry
#      whose compression method is bzip2 and whose data is not bzip2 data;
#      an archive whose end of central directory record gives a central
#      directory offset past the end of the file; an entry whose deflate
#      data does not decompress; an entry whose flags mark it as encrypted;
#      an entry whose compression method is PPMd, which zipfile does not
#      support; an entry whose compression method is Zstandard or LZMA and
#      whose data does not decompress; an entry whose name is not UTF-8
#      though its flags say it is; an entry whose sizes run past the end of
#      the archive; and that entry with a second central directory header
#      that gives the same local header offset.
#  Cases 20 to 31 pass the file alone: exit 1, one FAIL line, which says the
#  file is not a readable zip package, and RESULT: FAIL as the last line.
#  stderr is empty, except in case 31, where it can hold the warning zipfile
#  prints for overlapped entries, as it does with Python 3.14.3, and nothing
#  else.
#  32. A zip package whose only part is docProps/app.xml: exit 1, one FAIL
#      line, which says it has no part whose name starts with xl/ and ends
#      in .xml.
#  33. A file that does not exist, whose name holds a line feed followed by
#      RESULT: PASS: exit 1, nothing on stderr, the name printed with the
#      line feed as \n on its == line and in one FAIL line, which says it
#      cannot be read (No such file or directory), no line that is
#      RESULT: PASS, and RESULT: FAIL as the last line.
#  34. An empty file argument: exit 1, the == line "== ''", one FAIL line,
#      "'': no file name given", and RESULT: FAIL as the last line.
#  35. Under the en_US.UTF-8 locale, an argument that holds the byte 0xff,
#      which is not valid UTF-8, and names no file: exit 1, nothing on
#      stderr, the name printed with the byte as \xff on its == line and in
#      a FAIL line that says it cannot be read.
#  36. Under the en_US.ISO8859-1 locale, an argument that is valid UTF-8,
#      holds the character U+65E5, which ISO-8859-1 cannot encode, and names
#      no file, then the copy of case 6 with xl/worksheets/sheet1.xml
#      renamed xl/worksheets/ followed by U+65E5 and .xml: exit 1, nothing
#      on stderr, the name printed with the character as \u65e5 on its ==
#      line and in a FAIL line that says it cannot be read (No such file or
#      directory), a FAIL line for the copy that gives the part's name with
#      the character as \u65e5, no other FAIL line, and RESULT: FAIL as the
#      last line. The case is skipped, with a line that says so, when
#      python3 -I does not decode file names as UTF-8 and write stdout as
#      ISO-8859-1 under that locale on this machine.
#  37. --help: exit 2, nothing on stdout, and on stderr the usage line, a
#      blank line and the checker's header text. An unknown option, --bogus:
#      exit 2, nothing on stdout, and on stderr "unknown option: --bogus",
#      then the usage line.
#  38. ON_OFF, read from the checker: it gives the elements fileSharing,
#      protectedRange, sheetProtection and workbookProtection, and none of
#      the attribute names it gives contains "password", "hash", "salt",
#      "spin" or "algorithm", in any case.
#  39-40. A copy of the sample workbook whose xl/worksheets/sheet1.xml has
#      an XML declaration that names the encoding x-bogus, which Python does
#      not know, or shift_jis, a multi-byte encoding, with the rest of the
#      part as it is, passed before the sample workbook: exit 1, nothing on
#      stderr, one FAIL line, which says the XML declaration of that part
#      names an encoding that the XML parser cannot use, the == line of the
#      sample workbook followed by its PASS line, the summary line "2 files
#      checked, 0 protection elements with on/off settings only, 0 with an
#      attribute that is not an on/off setting", and RESULT: FAIL as the
#      last line.
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
checker="$here/check-workbook-protection.py"
sample="$root/toolkit/Sample_Assessment.xlsx"
for file in "$checker" "$sample"; do
  if [ ! -f "$file" ]; then
    echo "not found: $file" >&2
    exit 1
  fi
done

tmp_root="$root/.tmp-tests"
mkdir -p "$tmp_root"
work="$(mktemp -d "$tmp_root/check-workbook-protection.XXXXXX")"
cleanup() {
  case "$work" in
    "$tmp_root"/?*) rm -rf -- "$work" ;;
    *) exit 1 ;;
  esac
  rmdir "$tmp_root" 2> /dev/null || true
}
trap cleanup EXIT
export GIT_CEILING_DIRECTORIES="$work"

failed=0

# The value of each attribute the cases write, other than the value of an
# on/off setting. The checker must never print it.
value="FAKE-1234"
main_ns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
usage="usage: python3 -I scripts/check-workbook-protection.py [workbook ...]"

# Writes to $2 a copy of the workbook $1 in which, for each further group of
# three arguments, a part name, an old text and a new text, the first old
# text in that part is replaced by the new text. Fails when a part does not
# hold its old text.
edit_part() {
  python3 -I - "$@" <<'PY'
import sys
import zipfile

source, target = sys.argv[1:3]
edits = sys.argv[3:]
if not edits or len(edits) % 3:
    sys.exit("edit_part: give a part name, an old text and a new text")
groups = [edits[start:start + 3] for start in range(0, len(edits), 3)]
with zipfile.ZipFile(source) as book, zipfile.ZipFile(target, "w") as copy:
    for info in book.infolist():
        data = book.read(info.filename)
        for part, old, new in groups:
            if info.filename == part:
                text = data.decode("utf-8")
                if old not in text:
                    sys.exit("edit_part: no %s in %s" % (old, part))
                data = text.replace(old, new, 1).encode("utf-8")
        copy.writestr(info, data)
PY
}

# Writes to $2 a copy of the workbook $1 whose part $3 is named $4 instead.
# Fails when $1 has no part $3.
rename_part() {
  python3 -I - "$@" <<'PY'
import sys
import zipfile

source, target, old, new = sys.argv[1:5]
found = False
with zipfile.ZipFile(source) as book, zipfile.ZipFile(target, "w") as copy:
    for info in book.infolist():
        data = book.read(info.filename)
        if info.filename == old:
            found = True
            renamed = zipfile.ZipInfo(new, info.date_time)
            renamed.compress_type = info.compress_type
            info = renamed
        copy.writestr(info, data)
if not found:
    sys.exit("rename_part: no %s" % old)
PY
}

# Writes to $1 a compound file: its 8-byte signature, D0 CF 11 E0 A1 B1 1A
# E1, then 504 zero bytes, the rest of a 512-byte header.
make_compound_file() {
  printf '\320\317\021\340\241\261\032\341' > "$1"
  head -c 504 /dev/zero >> "$1"
}

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
# 64 KiB dictionary size, then 0xff 0xff. name: the entry is named
# xl/workbook followed by U+00E9 and .xml, so zipfile sets bit 11 of its
# general purpose flags, which says its name is UTF-8, and the two bytes of
# U+00E9 in UTF-8, 0xc3 0xa9, are replaced by 0xff 0xfe, which are not.
# past-end: both headers of the entry give a compressed and an uncompressed
# size equal to the length of the archive, which run past its end, as the
# entry's data starts after its local file header. same-offset: as
# past-end, with a copy of the central directory header, for an entry named
# xl/workbook.xmz, after it.
make_damaged_zip() {
  python3 -I - "$@" <<'PY'
import struct
import sys
import zipfile

path, damage = sys.argv[1:3]
name = "xl/workbook.xml"
if damage == "name":
    name = "xl/workbook\xe9.xml"
if damage == "deflate":
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as book:
        book.writestr(name, "<workbook>" + "AB" * 1500 + "</workbook>")
else:
    with zipfile.ZipFile(path, "w") as book:
        book.writestr(name, "<workbook/>")
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
    start = 30 + len(name)
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
        start = 30 + len(name)
        data[start:start + 11] = bytes([9, 20, 5, 0, 0x5D, 0, 0, 1, 0, 255, 255])
elif damage == "name":
    # Both headers give the flags with bit 11 set, and the name.
    for offset in (6, directory + 8):
        (flags,) = struct.unpack_from("<H", data, offset)
        if not flags & 0x800:
            sys.exit("make_damaged_zip: the name is not marked as UTF-8")
    encoded = "\xe9".encode("utf-8")
    if data.count(encoded) != 2:
        sys.exit("make_damaged_zip: the name is not in both headers")
    data = bytearray(bytes(data).replace(encoded, b"\xff\xfe"))
elif damage in ("past-end", "same-offset"):
    headers = [directory]
    if damage == "same-offset":
        # A central directory header gives the file name from offset 46. The
        # end of central directory record gives the number of entries on
        # this disk and in all at offsets 8 and 10, and the size of the
        # central directory at offset 12.
        record = data[directory:len(data) - 22]
        record[45 + len(name)] = ord("z")
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

# Lays out a copy of the repository at $1 with the checker and, as
# toolkit/Sample_Assessment.xlsx, a copy of the workbook $2.
make_copy() {
  mkdir -p "$1/scripts" "$1/toolkit"
  cp "$checker" "$1/scripts/check-workbook-protection.py"
  cp "$2" "$1/toolkit/Sample_Assessment.xlsx"
}

# Runs the checker at $1 with the remaining arguments under python3 -I.
# Sets out, err and status.
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

# True when a FAIL line of a file is "  FAIL $1".
has_fail_line() {
  printf '%s\n' "$out" | grep -q -x -F -- "  FAIL $1"
}

# True when a FAIL line of a file holds $1.
has_fail() {
  printf '%s\n' "$out" | grep '^  FAIL' | grep -q -F -- "$1"
}

# The number of FAIL lines of a file, which are indented.
fail_count() {
  printf '%s\n' "$out" | grep -c '^  FAIL' || true
}

# The number of FAIL lines that are not about one file, which start the line.
top_fail_count() {
  printf '%s\n' "$out" | grep -c '^FAIL' || true
}

pass_count() {
  printf '%s\n' "$out" | grep -c '^  PASS' || true
}

# The PASS line of the output the checker last printed, or nothing.
pass_line() {
  printf '%s\n' "$out" | grep '^  PASS' || true
}

line_count() {
  printf '%s\n' "$out" | wc -l | tr -d ' '
}

# True when a line of the output is $1.
has_line() {
  printf '%s\n' "$out" | grep -q -x -F -- "$1"
}

last_line_is() {
  [ "$(printf '%s\n' "$out" | tail -n 1)" = "$1" ]
}

value_not_shown() {
  ! printf '%s\n%s\n' "$out" "$err" | grep -q -F -- "$value"
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

# Expectations for cases 2 and 3.
expect_not_a_checkout() {
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "nothing on stderr" '[ -z "$err" ]'
  expect "two lines" '[ "$(line_count)" -eq 2 ]'
  expect "one FAIL line" '[ "$(top_fail_count)" -eq 1 ]'
  expect "FAIL line says not a git checkout" \
    'printf "%s\n" "$out" | grep "^FAIL" | grep -q "not a git checkout"'
  expect "FAIL line says to pass the files as arguments" \
    'printf "%s\n" "$out" | grep "^FAIL" | grep -q "pass the files to check as arguments"'
  expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
}

# Expectations for cases 8 to 17: $1 is the copy's file name, and each
# further argument is the text of a FAIL line after "$1: ".
expect_fail_lines() {
  local copy="$1" line wanted
  shift
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "nothing on stderr" '[ -z "$err" ]'
  for line in "$@"; do
    wanted="$copy: $line"
    expect "FAIL line: $line" 'has_fail_line "$wanted"'
  done
  wanted="$#"
  expect "$# FAIL lines in all" '[ "$(fail_count)" -eq "$wanted" ]'
  expect "$value printed nowhere" 'value_not_shown'
  expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
}

# True when stderr is empty or each of its lines holds "UserWarning:
# Overlapped entries: '$1' (possible zip bomb)" or starts with two spaces,
# as do the two lines of the warning Python 3.14.3 prints for the entry $1
# of the archive of case 31: the second quotes the line of zipfile that
# raised it. The first line of a traceback does neither.
only_overlap_warning() {
  local rest
  rest="$(printf '%s\n' "$err" \
    | grep -v -F -- "UserWarning: Overlapped entries: '$1' (possible zip bomb)" \
    | grep -v '^  ' || true)"
  [ -z "$rest" ]
}

# Expectations for cases 20 to 31: $1 is the file's name. With $2, stderr
# can hold the warning only_overlap_warning allows for the entry $2.
expect_not_a_package() {
  local wanted="$1: not a readable zip package"
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  if [ "$#" -gt 1 ]; then
    expect "no traceback on stderr, at most a warning for $2" \
      "only_overlap_warning '$2'"
  else
    expect "nothing on stderr" '[ -z "$err" ]'
  fi
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line says it is not a readable zip package" 'has_fail_line "$wanted"'
  expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
}

tracked="$(git -C "$root" ls-files | grep -i '\.xlsx$' || true)"
count="$(printf '%s\n' "$tracked" | grep -c . || true)"
start_case "case 1: the tracked workbooks" "$checker"
listed="$(printf '%s\n' "$out" | sed -n 's/^== //p')"
summary="$(printf '%s\n' "$out" | grep ' files checked, ' || true)"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "nothing on stderr" '[ -z "$err" ]'
expect "at least one tracked workbook" '[ "$count" -gt 0 ]'
expect "an == line for each tracked workbook, in the order git ls-files lists them" \
  '[ "$listed" = "$tracked" ]'
expect "a PASS line for each" '[ "$(pass_count)" -eq "$count" ]'
expect "no FAIL line" '[ "$(fail_count)" -eq 0 ] && [ "$(top_fail_count)" -eq 0 ]'
expect "the summary line gives the number of files and 0 elements that fail" \
  'case "$summary" in "$count files checked, "*", 0 with an attribute that is not an on/off setting") true ;; *) false ;; esac'
expect "last line is RESULT: PASS" 'last_line_is "RESULT: PASS"'
end_case

make_copy "$work/plain" "$sample"
start_case "case 2: not a git checkout, no file arguments" \
  "$work/plain/scripts/check-workbook-protection.py"
expect_not_a_checkout
end_case

title="case 3: not a git checkout, no file arguments, LANG=de_DE.UTF-8"
probe="$(LANG=de_DE.UTF-8 LC_ALL=de_DE.UTF-8 LANGUAGE=de \
  git -C "$work/plain" ls-files 2>&1 > /dev/null || true)"
if printf '%s\n' "$probe" | grep -q "not a git repository"; then
  print_title "$title"
  echo "  skip git prints this message untranslated for de_DE.UTF-8 here"
else
  LANG=de_DE.UTF-8 LC_ALL=de_DE.UTF-8 LANGUAGE=de start_case "$title" \
    "$work/plain/scripts/check-workbook-protection.py"
  expect_not_a_checkout
  end_case
fi

start_case "case 4: not a git checkout, the workbook given as an argument" \
  "$work/plain/scripts/check-workbook-protection.py" toolkit/Sample_Assessment.xlsx
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "one PASS line" '[ "$(pass_count)" -eq 1 ]'
expect "last line is RESULT: PASS" 'last_line_is "RESULT: PASS"'
end_case

mkdir -p "$work/empty/scripts"
cp "$checker" "$work/empty/scripts/check-workbook-protection.py"
printf '# Notes\n' > "$work/empty/README.md"
git -C "$work/empty" init -q
git -C "$work/empty" add README.md scripts/check-workbook-protection.py
start_case "case 5: a git checkout that tracks no workbook" \
  "$work/empty/scripts/check-workbook-protection.py"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "nothing on stderr" '[ -z "$err" ]'
expect "two lines" '[ "$(line_count)" -eq 2 ]'
expect "one FAIL line" '[ "$(top_fail_count)" -eq 1 ]'
expect "FAIL line says git ls-files lists no workbook" \
  'printf "%s\n" "$out" | grep "^FAIL" | grep -q "no tracked workbook: git ls-files lists no file"'
expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
end_case

edit_part "$sample" "$work/password.xlsx" xl/worksheets/sheet1.xml '</sheetData>' \
  "</sheetData><sheetProtection password=\"$value\" sheet=\"1\" objects=\"1\" scenarios=\"1\"/>"
make_copy "$work/checkout" "$work/password.xlsx"
git -C "$work/checkout" init -q
git -C "$work/checkout" add scripts/check-workbook-protection.py toolkit/Sample_Assessment.xlsx
start_case "case 6: a tracked workbook whose first sheet has a password" \
  "$work/checkout/scripts/check-workbook-protection.py"
wanted="toolkit/Sample_Assessment.xlsx: xl/worksheets/sheet1.xml: sheetProtection has an attribute that is not an on/off setting: password (value not shown)"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "nothing on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line names the file, the part, sheetProtection and password" \
  'has_fail_line "$wanted"'
expect "$value printed nowhere" 'value_not_shown'
expect "the summary line counts 1 element that fails" \
  'has_line "1 files checked, 0 protection elements with on/off settings only, 1 with an attribute that is not an on/off setting"'
expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
end_case

mkdir -p "$work/formats/scripts" "$work/formats/toolkit"
cp "$checker" "$work/formats/scripts/check-workbook-protection.py"
cp "$sample" "$work/formats/toolkit/Book.xlsx"
cp "$sample" "$work/formats/toolkit/Upper.XLSX"
cp "$sample" "$work/formats/toolkit/Macro.xlsm"
make_compound_file "$work/formats/toolkit/Old.XLS"
git -C "$work/formats" init -q
git -C "$work/formats" add scripts/check-workbook-protection.py toolkit/Book.xlsx \
  toolkit/Upper.XLSX toolkit/Macro.xlsm toolkit/Old.XLS
start_case "case 7: tracked spreadsheets in a format the checker does not read" \
  "$work/formats/scripts/check-workbook-protection.py"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "nothing on stderr" '[ -z "$err" ]'
expect "FAIL line for Macro.xlsm" \
  'has_fail_line "toolkit/Macro.xlsm: a spreadsheet format the script does not read (it reads .xlsx files only)"'
expect "FAIL line for Old.XLS" \
  'has_fail_line "toolkit/Old.XLS: a spreadsheet format the script does not read (it reads .xlsx files only)"'
expect "no other FAIL line" '[ "$(fail_count)" -eq 2 ]'
expect "Book.xlsx and Upper.XLSX are read" \
  'has_line "== toolkit/Book.xlsx" && has_line "== toolkit/Upper.XLSX" && [ "$(pass_count)" -eq 2 ]'
expect "4 files checked" 'printf "%s\n" "$out" | grep -q "^4 files checked, "'
expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
[ "$failed" -eq 0 ] || show_output
run_checker "$work/formats/scripts/check-workbook-protection.py" toolkit/Macro.xlsm
expect "Macro.xlsm as an argument: exit status is 1" '[ "$status" -eq 1 ]'
expect "Macro.xlsm as an argument: the same FAIL line, and no other" \
  'has_fail_line "toolkit/Macro.xlsm: a spreadsheet format the script does not read (it reads .xlsx files only)" && [ "$(fail_count)" -eq 1 ]'
end_case

edit_part "$sample" "$work/hash.xlsx" xl/worksheets/sheet1.xml '</sheetData>' \
  "</sheetData><sheetProtection algorithmName=\"$value\" hashValue=\"$value\" saltValue=\"$value\" spinCount=\"$value\" sheet=\"1\"/>"
start_case "case 8: hash attributes in a sheetProtection element" "$checker" "$work/hash.xlsx"
expect_fail_lines "$work/hash.xlsx" \
  "xl/worksheets/sheet1.xml: sheetProtection has attributes that are not on/off settings: algorithmName, hashValue, saltValue, spinCount (values not shown)"
end_case

edit_part "$sample" "$work/workbook.xlsx" xl/workbook.xml '<bookViews>' \
  "<workbookProtection workbookPassword=\"$value\" workbookHashValue=\"$value\" lockStructure=\"1\"/><bookViews>"
start_case "case 9: a workbook-level password" "$checker" "$work/workbook.xlsx"
expect_fail_lines "$work/workbook.xlsx" \
  "xl/workbook.xml: workbookProtection has attributes that are not on/off settings: workbookPassword, workbookHashValue (values not shown)"
end_case

edit_part "$sample" "$work/sharing.xlsx" xl/workbook.xml '<workbookPr ' \
  "<fileSharing readOnlyRecommended=\"1\" reservationPassword=\"$value\"/><workbookPr "
start_case "case 10: a fileSharing element with a reservation password" \
  "$checker" "$work/sharing.xlsx"
expect_fail_lines "$work/sharing.xlsx" \
  "xl/workbook.xml: fileSharing has an attribute that is not an on/off setting: reservationPassword (value not shown)"
end_case

edit_part "$sample" "$work/ranges.xlsx" xl/worksheets/sheet1.xml '</sheetData>' \
  "</sheetData><protectedRanges><protectedRange password=\"$value\" sqref=\"$value\" name=\"$value\"/><protectedRange sqref=\"$value\" name=\"$value\"/></protectedRanges>"
start_case "case 11: protectedRange elements with and without a password" \
  "$checker" "$work/ranges.xlsx"
expect_fail_lines "$work/ranges.xlsx" \
  "xl/worksheets/sheet1.xml: protectedRange has attributes that are not on/off settings: password, sqref, name (values not shown)" \
  "xl/worksheets/sheet1.xml: protectedRange has attributes that are not on/off settings: sqref, name (values not shown)"
end_case

edit_part "$sample" "$work/note.xlsx" xl/worksheets/sheet1.xml '</sheetData>' \
  "</sheetData><sheetProtection note=\"$value\" sheet=\"1\"/>"
start_case "case 12: an attribute name that is in no list" "$checker" "$work/note.xlsx"
expect_fail_lines "$work/note.xlsx" \
  "xl/worksheets/sheet1.xml: sheetProtection has an attribute that is not an on/off setting: note (value not shown)"
end_case

edit_part "$sample" "$work/prefix.xlsx" \
  xl/worksheets/sheet1.xml '</sheetData>' \
  "</sheetData><x:sheetProtection xmlns:x=\"$main_ns\" password=\"$value\" sheet=\"1\"/>" \
  xl/worksheets/sheet2.xml '</sheetData>' \
  "</sheetData><sheetProtection xmlns=\"\" password=\"$value\" sheet=\"1\"/>" \
  xl/worksheets/sheet3.xml '</sheetData>' \
  "</sheetData><e:sheetProtection xmlns:e=\"urn:example:$value\" password=\"$value\" sheet=\"1\"/>"
start_case "case 13: sheetProtection elements with a prefix, in no namespace and in another one" \
  "$checker" "$work/prefix.xlsx"
expect_fail_lines "$work/prefix.xlsx" \
  "xl/worksheets/sheet1.xml: sheetProtection has an attribute that is not an on/off setting: password (value not shown)" \
  "xl/worksheets/sheet2.xml: sheetProtection has an attribute that is not an on/off setting: password (value not shown)" \
  "xl/worksheets/sheet3.xml: sheetProtection has an attribute that is not an on/off setting: password (value not shown)"
end_case

edit_part "$sample" "$work/namespace.xlsx" xl/worksheets/sheet1.xml '</sheetData>' \
  "</sheetData><sheetProtection xmlns:p=\"urn:example:$value\" p:sheet=\"1\"/>"
start_case "case 14: an on/off attribute name in a namespace" \
  "$checker" "$work/namespace.xlsx"
expect_fail_lines "$work/namespace.xlsx" \
  "xl/worksheets/sheet1.xml: sheetProtection has an attribute that is not an on/off setting: sheet in a namespace (value not shown)"
end_case

edit_part "$sample" "$work/value.xlsx" xl/worksheets/sheet1.xml '</sheetData>' \
  "</sheetData><sheetProtection sheet=\"$value\" objects=\"1\"/>"
start_case "case 15: an on/off attribute whose value is not on or off" \
  "$checker" "$work/value.xlsx"
expect_fail_lines "$work/value.xlsx" \
  "xl/worksheets/sheet1.xml: sheetProtection has an on/off attribute whose value is not true, false, 1 or 0: sheet (value not shown)"
end_case

rename_part "$work/password.xlsx" "$work/upper.xlsx" \
  xl/worksheets/sheet1.xml XL/worksheets/sheet1.XML
start_case "case 16: a part name in upper case" "$checker" "$work/upper.xlsx"
expect_fail_lines "$work/upper.xlsx" \
  "XL/worksheets/sheet1.XML: sheetProtection has an attribute that is not an on/off setting: password (value not shown)"
end_case

rename_part "$work/password.xlsx" "$work/linefeed.xlsx" \
  xl/worksheets/sheet1.xml "xl/worksheets/a
RESULT: PASS.xml"
start_case "case 17: a part name with a line feed" "$checker" "$work/linefeed.xlsx"
expect_fail_lines "$work/linefeed.xlsx" \
  'xl/worksheets/a\nRESULT: PASS.xml: sheetProtection has an attribute that is not an on/off setting: password (value not shown)'
expect "no line is RESULT: PASS" '! has_line "RESULT: PASS"'
end_case

edit_part "$sample" "$work/broken.xlsx" xl/worksheets/sheet1.xml '</sheetData>' \
  '</sheetData><sheetProtection'
start_case "case 18: a part that is not well-formed XML" "$checker" "$work/broken.xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "nothing on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says the part is not well-formed XML and gives a line and a column" \
  'printf "%s\n" "$out" | grep -q -x -E "  FAIL .*/broken\.xlsx: xl/worksheets/sheet1\.xml: not well-formed XML \(line [0-9]+, column [0-9]+\)"'
expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
end_case

# Case 19 expects the PASS line the checker prints for the sample workbook,
# with 4 protection elements in place of 0.
run_checker "$checker" toolkit/Sample_Assessment.xlsx
sample_pass="$(pass_line)"
edit_part "$sample" "$work/on-off.xlsx" \
  xl/worksheets/sheet1.xml '</sheetData>' \
  '</sheetData><sheetProtection sheet="1" objects="1" scenarios="1"/>' \
  xl/worksheets/sheet2.xml '</sheetData>' \
  "</sheetData><x:sheetProtection xmlns:x=\"$main_ns\" sheet=\"true\" formatCells=\"&#9; 0&#10;&#13;\"/>" \
  xl/workbook.xml '<workbookPr ' '<fileSharing readOnlyRecommended="1"/><workbookPr ' \
  xl/workbook.xml '<bookViews>' \
  '<workbookProtection lockStructure="1" lockWindows="false"/><bookViews>'
start_case "case 19: protection with on/off settings only" "$checker" "$work/on-off.xlsx"
wanted="${sample_pass/  PASS 0 /  PASS 4 }"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "nothing on stderr" '[ -z "$err" ]'
expect "no FAIL line" '[ "$(fail_count)" -eq 0 ]'
expect "the PASS line counts 4 protection elements" \
  '[ "$wanted" != "$sample_pass" ] && [ "$(pass_line)" = "$wanted" ]'
expect "the summary line counts 4 elements with on/off settings only" \
  'has_line "1 files checked, 4 protection elements with on/off settings only, 0 with an attribute that is not an on/off setting"'
expect "last line is RESULT: PASS" 'last_line_is "RESULT: PASS"'
end_case

printf 'not a workbook\n' > "$work/text.xlsx"
start_case "case 20: a text file" "$checker" "$work/text.xlsx"
expect_not_a_package "$work/text.xlsx"
end_case

make_compound_file "$work/encrypted.xlsx"
start_case "case 21: a compound file, as an encrypted workbook is" \
  "$checker" "$work/encrypted.xlsx"
expect_not_a_package "$work/encrypted.xlsx"
end_case

case_number=22
for damage in bzip2 offset deflate encrypted ppmd zstd lzma name past-end same-offset; do
  case "$damage" in
    bzip2) about="bzip2 data that does not decompress" ;;
    offset) about="a central directory offset past the end of the file" ;;
    deflate) about="deflate data that does not decompress" ;;
    encrypted) about="an entry whose flags mark it as encrypted" ;;
    ppmd) about="an entry compressed with PPMd" ;;
    zstd) about="Zstandard data that does not decompress" ;;
    lzma) about="LZMA data that does not decompress" ;;
    name) about="an entry name that is not UTF-8 though its flags say it is" ;;
    past-end) about="an entry whose sizes run past the end of the archive" ;;
    same-offset) about="that entry and a second header at the same offset" ;;
  esac
  make_damaged_zip "$work/$damage.xlsx" "$damage"
  start_case "case $case_number: a zip archive with $about" "$checker" "$work/$damage.xlsx"
  if [ "$damage" = same-offset ]; then
    expect_not_a_package "$work/$damage.xlsx" xl/workbook.xml
  else
    expect_not_a_package "$work/$damage.xlsx"
  fi
  end_case
  case_number=$((case_number + 1))
done

python3 -I - "$work/no-xl.xlsx" <<'PY'
import sys
import zipfile

with zipfile.ZipFile(sys.argv[1], "w") as book:
    book.writestr("docProps/app.xml", "<Properties/>")
PY
start_case "case 32: a zip package with no part under xl/" "$checker" "$work/no-xl.xlsx"
wanted="$work/no-xl.xlsx: no part whose name starts with xl/ and ends in .xml (not a workbook)"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "nothing on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says it has no part under xl/ that ends in .xml" 'has_fail_line "$wanted"'
expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
end_case

start_case "case 33: a file that does not exist, whose name holds a line feed" \
  "$checker" "$work/missing
RESULT: PASS.xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "nothing on stderr" '[ -z "$err" ]'
wanted="== $work/missing\\nRESULT: PASS.xlsx"
expect "the name is printed with the line feed as \\n" 'has_line "$wanted"'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
wanted="$work/missing\\nRESULT: PASS.xlsx: cannot read (No such file or directory)"
expect "FAIL line says it cannot be read" 'has_fail_line "$wanted"'
expect "no line is RESULT: PASS" '! has_line "RESULT: PASS"'
expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
end_case

start_case "case 34: an empty file argument" "$checker" ""
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "the file is shown as ''" "has_line \"== ''\""
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says no file name was given" "has_fail_line \"'': no file name given\""
expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
end_case

# \377 is the byte 0xff, which is not valid UTF-8, so Python holds it as a
# lone surrogate. No file is made with this name.
LC_ALL=en_US.UTF-8 start_case "case 35: a file argument that is not UTF-8" \
  "$checker" "$work/bad$(printf '\377').xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "nothing on stderr" '[ -z "$err" ]'
expect "the name is printed with the byte as \\xff" "has_line '== $work/bad\\xff.xlsx'"
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says it cannot be read and gives the byte as \\xff" \
  "has_fail '$work/bad\\xff.xlsx: cannot read ('"
expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
end_case

# \346\227\245 is U+65E5 encoded as UTF-8. Under en_US.ISO8859-1 on macOS,
# python3 decodes the name as UTF-8 and writes stdout as ISO-8859-1, which
# has no byte for U+65E5. No file is made with the name of the first
# argument; zipfile stores the part name of the copy as UTF-8.
title="case 36: a file and a part name that stdout's encoding cannot hold"
probe="$(LC_ALL=en_US.ISO8859-1 python3 -I -c 'import codecs, sys; print(codecs.lookup(sys.getfilesystemencoding()).name, codecs.lookup(sys.stdout.encoding).name)' 2>&1 || true)"
if [ "$probe" = "utf-8 iso8859-1" ]; then
  rename_part "$work/password.xlsx" "$work/part-name.xlsx" \
    xl/worksheets/sheet1.xml "xl/worksheets/$(printf '\346\227\245').xml"
  LC_ALL=en_US.ISO8859-1 start_case "$title" \
    "$checker" "$work/$(printf '\346\227\245').xlsx" "$work/part-name.xlsx"
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "nothing on stderr" '[ -z "$err" ]'
  expect "the name is printed with the character as \\u65e5" \
    "has_line '== $work/\\u65e5.xlsx'"
  expect "FAIL line says it cannot be read and gives the character as \\u65e5" \
    "has_fail_line '$work/\\u65e5.xlsx: cannot read (No such file or directory)'"
  expect "FAIL line for the copy gives the part name with the character as \\u65e5" \
    "has_fail_line '$work/part-name.xlsx: xl/worksheets/\\u65e5.xml: sheetProtection has an attribute that is not an on/off setting: password (value not shown)'"
  expect "no other FAIL line" '[ "$(fail_count)" -eq 2 ]'
  expect "$value printed nowhere" 'value_not_shown'
  expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
  end_case
else
  print_title "$title"
  echo "  skip python3 does not decode file names as UTF-8 and write stdout as ISO-8859-1 under en_US.ISO8859-1 here ($probe)"
fi

# The checker's header text, its module docstring without the white space
# around it.
header="$(python3 -I - "$checker" <<'PY'
import ast
import sys

with open(sys.argv[1], encoding="utf-8") as fh:
    print(ast.get_docstring(ast.parse(fh.read()), clean=False).strip())
PY
)"
start_case "case 37: --help and an unknown option" "$checker" --help
wanted="$(printf '%s\n\n%s' "$usage" "$header")"
expect "exit status is 2" '[ "$status" -eq 2 ]'
expect "nothing on stdout" '[ -z "$out" ]'
expect "stderr is the usage line, a blank line and the header text" '[ "$err" = "$wanted" ]'
[ "$failed" -eq 0 ] || show_output
run_checker "$checker" --bogus
wanted="unknown option: --bogus"$'\n'"$usage"
expect "an unknown option exits 2" '[ "$status" -eq 2 ]'
expect "nothing on stdout for an unknown option" '[ -z "$out" ]'
expect "stderr names the unknown option, then the usage line" '[ "$err" = "$wanted" ]'
end_case

print_title "case 38: the on/off attribute names in ON_OFF"
case_failed="$failed"
failed=0
# -B, so that loading the checker as a module writes no __pycache__
# directory next to it.
names="$(python3 -I -B - "$checker" <<'PY'
import importlib.util
import sys

spec = importlib.util.spec_from_file_location("checker", sys.argv[1])
checker = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checker)
print("elements " + " ".join(sorted(checker.ON_OFF)))
for element, attributes in sorted(checker.ON_OFF.items()):
    print("element {} gives {} names".format(element, len(attributes)))
    for attribute in attributes:
        for word in ("password", "hash", "salt", "spin", "algorithm"):
            if word in attribute.lower():
                print("{} gives {}, which contains {}".format(element, attribute, word))
PY
)"
expect "ON_OFF gives the four protection elements" \
  'printf "%s\n" "$names" | grep -q -x -F -- "elements fileSharing protectedRange sheetProtection workbookProtection"'
expect "no name contains password, hash, salt, spin or algorithm" \
  '! printf "%s\n" "$names" | grep -q ", which contains "'
if [ "$failed" -ne 0 ]; then
  printf '%s\n' "$names" | sed 's/^/  /'
fi
failed=$((failed | case_failed))

# Cases 39 and 40 expect the PASS line of case 19 for the sample workbook.
case_number=39
for encoding in x-bogus shift_jis; do
  case "$encoding" in
    x-bogus) about="an encoding Python does not know" ;;
    shift_jis) about="a multi-byte encoding" ;;
  esac
  edit_part "$sample" "$work/$encoding.xlsx" xl/worksheets/sheet1.xml \
    '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' \
    "<?xml version=\"1.0\" encoding=\"$encoding\" standalone=\"yes\"?>"
  start_case "case $case_number: a part whose XML declaration names $about, $encoding" \
    "$checker" "$work/$encoding.xlsx" "$sample"
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "nothing on stderr" '[ -z "$err" ]'
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  wanted="$work/$encoding.xlsx: xl/worksheets/sheet1.xml: the XML declaration names an encoding that the XML parser cannot use"
  expect "FAIL line says the part names an encoding the XML parser cannot use" \
    'has_fail_line "$wanted"'
  wanted="== $sample"
  expect "the sample workbook after it is checked and gets its PASS line" \
    '[ -n "$sample_pass" ] && [ "$(printf "%s\n" "$out" | grep -A 1 -x -F -- "$wanted" | tail -n 1)" = "$sample_pass" ]'
  expect "the summary line counts 2 files" \
    'has_line "2 files checked, 0 protection elements with on/off settings only, 0 with an attribute that is not an on/off setting"'
  expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
  end_case
  case_number=$((case_number + 1))
done

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
