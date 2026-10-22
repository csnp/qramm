#!/usr/bin/env bash
# Tests scripts/check-scoring-example.py against the repository document and
# workbook and against copies of the sample workbook whose cached value for
# CVI_Score is not a number or is written in another way.
#
# Usage:
#   scripts/test-check-scoring-example.sh
#
# The checker reads framework/scoring-methodology.md and
# toolkit/Sample_Assessment.xlsx from the directory above its own. Cases 2
# to 6 copy the checker and the document into a new temporary directory
# laid out like the repository (scripts/, framework/ and toolkit/), write an
# edited copy of the sample workbook there, and run the checker there.
#
# Cases:
#   1. The repository document and workbook: exit 0, nothing on stderr, a
#      PASS line for each of the five defined names, RESULT: PASS.
#   2. A copy of the sample workbook whose cell L5 of the Dimension 1 - CVI
#      sheet, the cell of CVI_Score, stores the text x in place of its
#      number, as <v>x</v>.
#   3. A copy of the sample workbook whose cell L5 of the Dimension 1 - CVI
#      sheet has an empty v element, <v/>, in place of its number.
#   4. A copy of the sample workbook whose cell L5 of the Dimension 1 - CVI
#      sheet stores 2.5_6, with an underscore between the 5 and the 6, in
#      place of its number, as <v>2.5_6</v>.
#   5. A copy of the sample workbook whose cell L5 of the Dimension 1 - CVI
#      sheet stores 2.56 written with U+0662, a period, U+0665 and U+0666
#      (ARABIC-INDIC DIGIT TWO, FIVE and SIX) in place of its number, as
#      <v>&#x662;.&#x665;&#x666;</v>.
#  Cases 2 to 5: exit 1, nothing on stderr, the == line first, a PASS line
#  for each of the other four defined names, one FAIL line, which says
#  "CVI_Score: Dimension 1 - CVI!L5 has no cached number", then
#  RESULT: FAIL.
#   6. A copy of the sample workbook whose cell L5 of the Dimension 1 - CVI
#      sheet stores 2.560 in place of its number, as <v>2.560</v>: exit 0,
#      nothing on stderr, a PASS line for CVI_Score = 2.56, no FAIL line,
#      RESULT: PASS.
#
# The temporary directory is made under .tmp-tests/ at the repository root,
# and the cleanup removes only a directory under it.
#
# Exit status: 0 when every case passes, 1 when any case fails.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
root="$(dirname "$here")"
checker="$here/check-scoring-example.py"
methodology="framework/scoring-methodology.md"
sample="toolkit/Sample_Assessment.xlsx"
# The part of the Dimension 1 - CVI sheet in the sample workbook.
cvi_part="xl/worksheets/sheet3.xml"

tmp_root="$(cd "$here/.." && pwd -P)/.tmp-tests"
mkdir -p "$tmp_root"
work="$(mktemp -d "$tmp_root/check-scoring-example.XXXXXX")"
cleanup() {
  case "$work" in
    "$tmp_root"/?*) rm -rf -- "$work" ;;
    *) exit 1 ;;
  esac
  rmdir "$tmp_root" 2> /dev/null || true
}
trap cleanup EXIT

failed=0

# Writes to $2 a copy of the workbook $1 whose cell $4 in the worksheet part
# $3 has the v element $5 in place of its own. Fails when the part does not
# have exactly one cell $4 with a v element.
set_cached_value() {
  python3 -I - "$@" <<'PY'
import re
import sys
import zipfile

source, target, part, ref, new = sys.argv[1:6]
found = 0
with zipfile.ZipFile(source) as book, zipfile.ZipFile(target, "w") as copy:
    for info in book.infolist():
        data = book.read(info.filename)
        if info.filename == part:
            text, found = re.subn(
                r'(<c r="%s"[^>]*>(?:<f[^>]*>[^<]*</f>)?)<v>[^<]*</v>' % ref,
                lambda match: match.group(1) + new,
                data.decode("utf-8"),
            )
            data = text.encode("utf-8")
        copy.writestr(info, data)
if found != 1:
    sys.exit("%s has %d cells %s with a v element, expected 1" % (part, found, ref))
PY
}

# Lays out a copy of the repository at $1 with the checker, the document and
# a copy of the sample workbook whose cell L5 of the Dimension 1 - CVI sheet
# has the v element $2.
make_copy() {
  mkdir -p "$1/scripts" "$1/framework" "$1/toolkit"
  cp "$checker" "$1/scripts/check-scoring-example.py"
  cp "$root/$methodology" "$1/$methodology"
  set_cached_value "$root/$sample" "$1/$sample" "$cvi_part" L5 "$2"
}

# Runs the checker at $1. Sets out, err and status.
run_checker() {
  status=0
  python3 -I "$1" > "$work/out" 2> "$work/err" || status=$?
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

# Runs one case: $1 is its title, $2 the checker. Leaves the result in out,
# err and status for the expect lines that follow.
start_case() {
  echo "$1"
  case_failed="$failed"
  failed=0
  run_checker "$2"
}

end_case() {
  [ "$failed" -eq 0 ] || show_output
  failed=$((failed | case_failed))
}

# The expect lines of cases 2 to 5.
expect_no_cvi_number() {
  local defined
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "nothing on stderr" '[ -z "$err" ]'
  expect "first line is the == line" \
    '[ "$(printf "%s\n" "$out" | head -n 1)" = "== $methodology against $sample" ]'
  for defined in CVI_1_Score CVI_2_Score CVI_3_Score ProfileMultiplier; do
    expect "PASS line for $defined" "printf '%s\n' \"\$out\" | grep -q '^  PASS $defined = '"
  done
  expect "no PASS line for CVI_Score" "! printf '%s\n' \"\$out\" | grep -q '^  PASS CVI_Score '"
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line says CVI_Score has no cached number" \
    "has_line '  FAIL CVI_Score: Dimension 1 - CVI!L5 has no cached number'"
  expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
}

start_case "case 1: repository document and workbook" "$checker"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "nothing on stderr" '[ -z "$err" ]'
for defined in CVI_1_Score CVI_2_Score CVI_3_Score CVI_Score ProfileMultiplier; do
  expect "PASS line for $defined" "printf '%s\n' \"\$out\" | grep -q '^  PASS $defined = '"
done
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
end_case

make_copy "$work/text" '<v>x</v>'
start_case "case 2: CVI_Score cell stores the text x" \
  "$work/text/scripts/check-scoring-example.py"
expect_no_cvi_number
end_case

make_copy "$work/empty" '<v/>'
start_case "case 3: CVI_Score cell has an empty v element" \
  "$work/empty/scripts/check-scoring-example.py"
expect_no_cvi_number
end_case

make_copy "$work/underscore" '<v>2.5_6</v>'
start_case "case 4: CVI_Score cell stores 2.5_6" \
  "$work/underscore/scripts/check-scoring-example.py"
expect_no_cvi_number
end_case

make_copy "$work/arabic-indic" '<v>&#x662;.&#x665;&#x666;</v>'
start_case "case 5: CVI_Score cell stores 2.56 in Arabic-Indic digits" \
  "$work/arabic-indic/scripts/check-scoring-example.py"
expect_no_cvi_number
end_case

make_copy "$work/trailing-zero" '<v>2.560</v>'
start_case "case 6: CVI_Score cell stores 2.560" \
  "$work/trailing-zero/scripts/check-scoring-example.py"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "nothing on stderr" '[ -z "$err" ]'
expect "PASS line for CVI_Score = 2.56" \
  "printf '%s\n' \"\$out\" | grep -q '^  PASS CVI_Score = 2\.56 (line [0-9]*)\$'"
expect "no FAIL line" '[ "$(fail_count)" -eq 0 ]'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
end_case

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
