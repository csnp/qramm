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

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
