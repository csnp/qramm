#!/usr/bin/env bash
# Tests what the blank 120-questions workbook,
# toolkit-specs/QRAMM_120_questions.xlsx, shows before anyone enters a score.
#
# Usage:
#   scripts/test-questions-workbook.sh
#
# Cases:
#   1. scripts/check-workbook-errors.py on the workbook: exit 0, RESULT: PASS
#      (no visible cell stores an error value such as #DIV/0!).
#   2. The Scoring Dashboard's maturity level and percentage cells for the
#      four dimensions (E2:F5) and its overall score, level and percentage
#      (D7:F7) store "-" while the dimension scores (D2:D5) are blank.
#   3. No text in the workbook carries Markdown source: a link written as
#      "](", bold "**", a heading " ## " or " ### ", or a "• --" rule.
#
# Exit status: 0 when every case passes, 1 when any case fails.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
root="$(cd "$here/.." && pwd -P)"
workbook="toolkit-specs/QRAMM_120_questions.xlsx"

failed=0

echo "case 1: no error value in a visible cell"
status=0
out="$(cd "$root" && python3 -I scripts/check-workbook-errors.py "$workbook" 2>&1)" || status=$?
if [ "$status" -eq 0 ] && [ "$(printf '%s\n' "$out" | tail -n 1)" = "RESULT: PASS" ]; then
  echo "  ok   exit status is 0 and the last line is RESULT: PASS"
else
  echo "  FAIL exit status $status"
  printf '%s\n' "$out" | sed 's/^/  /'
  failed=1
fi

echo "cases 2 and 3: blank dashboard and cell text"
status=0
python3 -I - "$root/$workbook" <<'PY' || status=$?
import re
import sys
import xml.etree.ElementTree as ET
import zipfile

MAIN = "{http://schemas.openxmlformats.org/spreadsheetml/2006/main}"
book = zipfile.ZipFile(sys.argv[1])
strings = [
    "".join(t.text or "" for t in si.iter(MAIN + "t"))
    for si in ET.fromstring(book.read("xl/sharedStrings.xml")).findall(MAIN + "si")
]
failed = 0

dashboard = ET.fromstring(book.read("xl/worksheets/sheet3.xml"))
cells = {c.get("r"): c for c in dashboard.iter(MAIN + "c")}
for ref in ["D2", "D3", "D4", "D5"]:
    if cells[ref].find(MAIN + "v") is not None:
        print("  FAIL Scoring Dashboard!%s is not blank" % ref)
        failed = 1
refs = ["E2", "F2", "E3", "F3", "E4", "F4", "E5", "F5", "D7", "E7", "F7"]
for ref in refs:
    value = cells[ref].find(MAIN + "v")
    shown = None if value is None else value.text
    if shown != "-":
        print("  FAIL Scoring Dashboard!%s stores %r, expected '-'" % (ref, shown))
        failed = 1
if not failed:
    print("  ok   Scoring Dashboard %s store '-'" % ", ".join(refs))

markdown = re.compile(r"\]\(|\*\*| #{2,3} |• --")
found = 0
for index, text in enumerate(strings):
    match = markdown.search(text)
    if match:
        start = max(0, match.start() - 40)
        print("  FAIL shared string %d carries Markdown: %r"
              % (index, text[start:match.end() + 40]))
        found += 1
if found:
    failed = 1
else:
    print("  ok   none of the %d shared strings carries Markdown" % len(strings))
sys.exit(failed)
PY
[ "$status" -eq 0 ] || failed=1

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
