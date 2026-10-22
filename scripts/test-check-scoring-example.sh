#!/usr/bin/env bash
# Tests scripts/check-scoring-example.py against the repository document and
# workbook, against copies of the sample workbook whose cached value for
# CVI_Score is not a finite number, is written in another way or is a
# logical value, and against copies of the document whose CVI score line
# shows a number with a digit other than 0 to 9.
#
# Usage:
#   scripts/test-check-scoring-example.sh
#
# The checker reads framework/scoring-methodology.md and
# toolkit/Sample_Assessment.xlsx from the directory above its own. Cases 2
# to 8, 13 and 14 copy the checker and the document into a new temporary
# directory laid out like the repository (scripts/, framework/ and toolkit/),
# write an edited copy of the sample workbook there, and run the checker
# there. Cases 13 and 14 also edit the copy of the document, so that its CVI
# score line shows the value the cell stores. Cases 9 to 12 copy the checker
# and the sample workbook into such a directory, write there a copy of the
# document whose line that starts with "CVI score" ends with "= " and the
# text the case names in place of its own text after the last "=", and run
# the checker there.
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
#   7. A copy of the sample workbook whose cell L5 of the Dimension 1 - CVI
#      sheet stores the text nan in place of its number, as <v>nan</v>,
#      which float() reads as a NaN.
#   8. A copy of the sample workbook whose cell L5 of the Dimension 1 - CVI
#      sheet stores the text inf in place of its number, as <v>inf</v>,
#      which float() reads as an infinity.
#  Cases 7 and 8: the same expectations as cases 2 to 5.
#   9. The CVI score line shows 2.56 written with U+0662, a period, U+0665
#      and U+0666 (ARABIC-INDIC DIGIT TWO, FIVE and SIX), which float()
#      reads as 2.56.
#  10. The CVI score line shows 2.56 written with U+FF12, a period, U+FF15
#      and U+FF16 (FULLWIDTH DIGIT TWO, FIVE and SIX), which float() reads
#      as 2.56.
#  11. The CVI score line shows U+0662 followed by 2.56.
#  12. The CVI score line shows 2.56 followed by U+0666.
#  Cases 9 to 12: exit 1, nothing on stderr, the == line first, a PASS line
#  for each of the other four defined names, one FAIL line, which says
#  "CVI_Score: line <n>: the number after the last '=' is '<text>', which
#  has a digit other than 0 to 9", where <n> is the number of the CVI score
#  line and <text> is the text the case writes, with each digit other than
#  0 to 9 written as \u and four hex digits, such as \u0662, then
#  RESULT: FAIL.
#  13. A copy of the sample workbook whose cell L5 of the Dimension 1 - CVI
#      sheet stores the logical value TRUE in place of its number, as
#      t="b" on the c element and <v>1</v>, checked against a copy of the
#      document whose CVI score line shows 1 in place of 2.56.
#  14. A copy of the sample workbook whose cell L5 of the Dimension 1 - CVI
#      sheet stores the logical value FALSE in place of its number, as
#      t="b" on the c element and <v>0</v>, checked against a copy of the
#      document whose CVI score line shows 0 in place of 2.56.
#  Cases 13 and 14: the same expectations as cases 2 to 5.
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
# $3 has the v element $5 in place of its own and, when $6 is given, the t
# attribute $6 in place of any t attribute it has. Fails when the part does
# not have exactly one cell $4 with a v element.
set_cached_value() {
  python3 -I - "$@" <<'PY'
import re
import sys
import zipfile

source, target, part, ref, new = sys.argv[1:6]
kind = sys.argv[6] if len(sys.argv) > 6 else ""


def replace(match):
    start = match.group(1)
    if kind:
        start = re.sub(r'\st="[^"]*"', "", start) + ' t="%s"' % kind
    return start + match.group(2) + new


found = 0
with zipfile.ZipFile(source) as book, zipfile.ZipFile(target, "w") as copy:
    for info in book.infolist():
        data = book.read(info.filename)
        if info.filename == part:
            text, found = re.subn(
                r'(<c r="%s"[^>]*)(>(?:<f[^>]*>[^<]*</f>)?)<v>[^<]*</v>' % ref,
                replace,
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
# has the v element $2 and, when $3 is given, the t attribute $3.
make_copy() {
  mkdir -p "$1/scripts" "$1/framework" "$1/toolkit"
  cp "$checker" "$1/scripts/check-scoring-example.py"
  cp "$root/$methodology" "$1/$methodology"
  set_cached_value "$root/$sample" "$1/$sample" "$cvi_part" L5 "$2" ${3+"$3"}
}

# Edits the copy of the document in the copy of the repository at $1 so that
# its CVI score line shows $2 in place of 2.56 after its last "=". Fails when
# the copy does not have exactly one CVI score line that ends with = 2.56.
show_cvi_score() {
  python3 -I - "$1/$methodology" "$2" <<'PY'
import re
import sys

path, shown = sys.argv[1:3]
with open(path, encoding="utf-8") as fh:
    text = fh.read()
text, found = re.subn(
    r"^(CVI score .*= )2\.56$", lambda match: match.group(1) + shown, text, flags=re.M
)
if found != 1:
    sys.exit("%s has %d CVI score lines that end with = 2.56, expected 1" % (path, found))
with open(path, "w", encoding="utf-8") as fh:
    fh.write(text)
PY
}

# Writes to $2 a copy of the document $1 whose line that starts with
# "CVI score" ends with "= " and the text $3 in place of its own text after
# the last "=". In $3, \u and four hex digits stand for that code point.
# Prints the number of that line. Fails when the document does not have
# exactly one such line.
set_shown_value() {
  python3 -I - "$@" <<'PY'
import sys

source, target, new = sys.argv[1:4]
with open(source, encoding="utf-8", newline="") as fh:
    lines = fh.read().split("\n")
hits = [index for index, line in enumerate(lines) if line.startswith("CVI score ")]
if len(hits) != 1:
    sys.exit("%s has %d lines that start with 'CVI score ', expected 1" % (source, len(hits)))
index = hits[0]
lines[index] = (
    lines[index].rsplit("=", 1)[0] + "= " + new.encode("ascii").decode("unicode_escape")
)
with open(target, "w", encoding="utf-8", newline="") as fh:
    fh.write("\n".join(lines))
print(index + 1)
PY
}

# Lays out a copy of the repository at $1 with the checker, the sample
# workbook and a copy of the document whose CVI score line shows the text $2
# after its last "=", written as set_shown_value() reads it. Sets cvi_line
# to the number of that line.
make_doc_copy() {
  mkdir -p "$1/scripts" "$1/framework" "$1/toolkit"
  cp "$checker" "$1/scripts/check-scoring-example.py"
  cp "$root/$sample" "$1/$sample"
  cvi_line="$(set_shown_value "$root/$methodology" "$1/$methodology" "$2")"
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

# The expect lines of a case whose checker run fails CVI_Score and passes the
# other four defined names. $1 says what the FAIL line says, and $2 is that
# line as the checker prints it.
expect_cvi_fail() {
  local defined fail_line="$2"
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "nothing on stderr" '[ -z "$err" ]'
  expect "first line is the == line" \
    '[ "$(printf "%s\n" "$out" | head -n 1)" = "== $methodology against $sample" ]'
  for defined in CVI_1_Score CVI_2_Score CVI_3_Score ProfileMultiplier; do
    expect "PASS line for $defined" "printf '%s\n' \"\$out\" | grep -q '^  PASS $defined = '"
  done
  expect "no PASS line for CVI_Score" "! printf '%s\n' \"\$out\" | grep -q '^  PASS CVI_Score '"
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line says $1" 'has_line "$fail_line"'
  expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
}

# The expect lines of cases 2 to 5, 7, 8, 13 and 14.
expect_no_cvi_number() {
  expect_cvi_fail "CVI_Score has no cached number" \
    "  FAIL CVI_Score: Dimension 1 - CVI!L5 has no cached number"
}

# The expect lines of cases 9 to 12. $1 is the text the case writes after
# the last "=" of the CVI score line, with each digit other than 0 to 9
# written as \u and four lowercase hex digits, as the checker prints it.
expect_cvi_digit_not_ascii() {
  local shown="the number after the last '=' is '$1'"
  expect_cvi_fail "line $cvi_line has a digit other than 0 to 9" \
    "  FAIL CVI_Score: line $cvi_line: $shown, which has a digit other than 0 to 9"
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

make_copy "$work/nan" '<v>nan</v>'
start_case "case 7: CVI_Score cell stores the text nan" \
  "$work/nan/scripts/check-scoring-example.py"
expect_no_cvi_number
end_case

make_copy "$work/inf" '<v>inf</v>'
start_case "case 8: CVI_Score cell stores the text inf" \
  "$work/inf/scripts/check-scoring-example.py"
expect_no_cvi_number
end_case

make_doc_copy "$work/doc-arabic-indic" '\u0662.\u0665\u0666'
start_case "case 9: CVI score line shows 2.56 in Arabic-Indic digits" \
  "$work/doc-arabic-indic/scripts/check-scoring-example.py"
expect_cvi_digit_not_ascii '\u0662.\u0665\u0666'
end_case

make_doc_copy "$work/doc-fullwidth" '\uff12.\uff15\uff16'
start_case "case 10: CVI score line shows 2.56 in fullwidth digits" \
  "$work/doc-fullwidth/scripts/check-scoring-example.py"
expect_cvi_digit_not_ascii '\uff12.\uff15\uff16'
end_case

make_doc_copy "$work/doc-leading" '\u06622.56'
start_case "case 11: CVI score line shows U+0662 followed by 2.56" \
  "$work/doc-leading/scripts/check-scoring-example.py"
expect_cvi_digit_not_ascii '\u06622.56'
end_case

make_doc_copy "$work/doc-trailing" '2.56\u0666'
start_case "case 12: CVI score line shows 2.56 followed by U+0666" \
  "$work/doc-trailing/scripts/check-scoring-example.py"
expect_cvi_digit_not_ascii '2.56\u0666'
end_case

make_copy "$work/true" '<v>1</v>' b
show_cvi_score "$work/true" 1
start_case "case 13: CVI_Score cell stores the logical value TRUE, the document shows 1" \
  "$work/true/scripts/check-scoring-example.py"
expect_no_cvi_number
end_case

make_copy "$work/false" '<v>0</v>' b
show_cvi_score "$work/false" 0
start_case "case 14: CVI_Score cell stores the logical value FALSE, the document shows 0" \
  "$work/false/scripts/check-scoring-example.py"
expect_no_cvi_number
end_case

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
