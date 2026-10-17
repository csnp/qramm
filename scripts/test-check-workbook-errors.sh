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
#
# The temporary directory is made under .tmp-tests/ at the repository root,
# and the cleanup removes only a directory under it.
#
# Exit status: 0 when every case passes, 1 when any case fails.
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

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
