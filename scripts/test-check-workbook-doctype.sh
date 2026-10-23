#!/usr/bin/env bash
# Tests that the checkers that read workbook XML refuse a part with a
# document type declaration (<!DOCTYPE), before ElementTree reads it and
# expands the entities it declares, at each part each checker reads.
#
# Usage:
#   scripts/test-check-workbook-doctype.sh
#
# The checkers are the ones named in checkers below. The test copies the
# files git ls-files lists, as they are in the working tree, into a new
# temporary directory and runs each checker from scripts/ there, so that
# the checker treats that directory as the repository root.
# check-workbook-protection.py is given the tracked workbooks as arguments;
# the others are run with no arguments.
#
# A part given a document type declaration has, after its XML declaration,
# <!DOCTYPE r [...]> declaring the entities e0 to e3, each of e1 to e3 made
# of ten references to the one before, and a reference to e3 as the first
# text of its root element, unless that element is empty (<x/>).
#
# Cases:
#   1. The source of each checker: ET.fromstring, ET.XML, ET.parse,
#      ET.iterparse and ET.XMLParser are called only inside the function
#      parse_xml, which the checker calls at least once.
#   2. Each checker on the copy: exit 0, and at least one part whose name
#      ends in .xml or .rels read from a workbook. The parts it reads are
#      recorded for case 3.
#   3. For each checker other than check-workbook-protection.py, and each
#      part case 2 recorded for it: the copy with a document type
#      declaration in that part alone: an exit status other than 0, nothing
#      on stderr, RESULT: FAIL as the last line of stdout, the part is read,
#      and ET.fromstring is never given XML that holds "<!DOCTYPE". Some
#      checkers print such a workbook as one they cannot read without naming
#      the reason, so the FAIL lines are not matched.
#
# The checker runs through runpy in a python3 -I process that wraps
# zipfile.ZipFile.open, to record the parts the checker opens, and
# ET.fromstring, to count the XML with "<!DOCTYPE" it is given.
#   4. check-workbook-protection.py, given each tracked workbook with a
#      document type declaration in every part whose name starts with xl/
#      and ends in .xml: exit 1, and a FAIL line for each such part, which
#      names it and says it has a document type declaration.
#
# The temporary directory is made under .tmp-tests/ at the repository root,
# and the cleanup removes only a directory under it.
#
# Exit status: 0 when every case passes, 1 when any case fails.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
root="$(dirname "$here")"
checkers=(
  check-compliance-map.py
  check-maturity-thresholds.py
  check-profile-multiplier.py
  check-scoring-example.py
  check-top-strengths.py
  check-workbook-errors.py
  check-workbook-protection.py
)
protection=check-workbook-protection.py
tab=$'\t'

tmp_root="$root/.tmp-tests"
mkdir -p "$tmp_root"
work="$(mktemp -d "$tmp_root/check-workbook-doctype.XXXXXX")"
cleanup() {
  case "$work" in
    "$tmp_root"/?*) rm -rf -- "$work" ;;
    *) exit 1 ;;
  esac
  rmdir "$tmp_root" 2> /dev/null || true
}
trap cleanup EXIT

failed=0

expect() {
  local name="$1" condition="$2"
  if eval "$condition"; then
    echo "  ok   $name"
  else
    echo "  FAIL $name"
    failed=1
  fi
}

show_output() {
  echo "  -- stdout --"
  printf '%s\n' "$out" | sed 's/^/  /'
  echo "  -- stderr --"
  printf '%s\n' "$err" | sed 's/^/  /'
}

# Copies the tracked files, as they are in the working tree, to $work/repo.
copy="$work/repo"
mkdir -p "$copy"
(cd "$root" && git ls-files -z | xargs -0 tar -cf - --) | (cd "$copy" && tar -xf -)
workbooks=()
while IFS= read -r -d '' name; do
  workbooks+=("$name")
done < <(git -C "$root" ls-files -z -- '*.xlsx')

# Runs the checker $1 from the copy, with the tracked workbooks as arguments
# when it is check-workbook-protection.py, and records each part it opens
# from a zip archive in $2 as a line: the archive's path relative to the
# copy, a tab, and the part's name. Leaves the result in out, err and
# status.
run_checker() {
  local args=()
  if [ "$1" = "$protection" ]; then
    for name in "${workbooks[@]}"; do
      args+=("$copy/$name")
    done
  fi
  status=0
  out="$(cd "$work" && python3 -I - "$copy/scripts/$1" "$2" "$copy" "${args[@]+"${args[@]}"}" \
    2> "$work/stderr" <<'PY'
import os
import runpy
import sys
import xml.etree.ElementTree as ET
import zipfile

checker, record, copy = sys.argv[1:4]
opened = []
doctype_parsed = []
zip_open = zipfile.ZipFile.open
fromstring = ET.fromstring


def recording_open(self, name, *args, **kwargs):
    if isinstance(self.filename, str):
        opened.append((self.filename, getattr(name, "filename", name)))
    return zip_open(self, name, *args, **kwargs)


def recording_fromstring(text, *args, **kwargs):
    marker = b"<!DOCTYPE" if isinstance(text, bytes) else "<!DOCTYPE"
    if marker in text:
        doctype_parsed.append(1)
    return fromstring(text, *args, **kwargs)


zipfile.ZipFile.open = recording_open
ET.fromstring = recording_fromstring
sys.argv = [checker] + sys.argv[4:]
code = 0
try:
    runpy.run_path(checker, run_name="__main__")
except SystemExit as error:
    code = error.code
finally:
    sys.stdout.flush()
    with open(record, "w", encoding="utf-8") as fh:
        for archive, part in opened:
            fh.write("{}\t{}\n".format(os.path.relpath(archive, copy), part))
    with open(record + ".doctype", "w", encoding="utf-8") as fh:
        fh.write("{}\n".format(len(doctype_parsed)))
sys.exit(code)
PY
)" || status=$?
  err="$(cat "$work/stderr")"
}

# Writes $2, a copy of the workbook $1 in which each part named in the
# remaining arguments has a document type declaration.
make_doctype_copy() {
  python3 -I - "$@" <<'PY'
import re
import sys
import zipfile

source, target = sys.argv[1:3]
parts = set(sys.argv[3:])
entities = ['<!ENTITY e0 "FAKE">'] + [
    '<!ENTITY e{} "{}">'.format(level, "&e{};".format(level - 1) * 10)
    for level in range(1, 4)
]
doctype = "<!DOCTYPE r [{}]>".format("".join(entities)).encode("ascii")
declaration = re.compile(rb"<\?xml[^>]*\?>")
start_tag = re.compile(rb"<[A-Za-z_][^>]*>")
found = set()
with zipfile.ZipFile(source) as book, zipfile.ZipFile(target, "w") as copy:
    for info in book.infolist():
        data = book.read(info.filename)
        if info.filename in parts:
            found.add(info.filename)
            match = declaration.match(data)
            head = match.end() if match else 0
            tag = start_tag.search(data, head)
            reference = b"" if tag.group().endswith(b"/>") else b"&e3;"
            data = (
                data[:head] + doctype + data[head:tag.end()] + reference + data[tag.end():]
            )
        copy.writestr(info, data)
missing = sorted(parts - found)
for part in missing:
    print("make_doctype_copy: no part {} in {}".format(part, source), file=sys.stderr)
sys.exit(1 if missing else 0)
PY
}

echo "case 1: only parse_xml calls the ElementTree parsers"
for checker in "${checkers[@]}"; do
  calls="$(python3 -I - "$here/$checker" <<'PY'
import ast
import sys

PARSERS = {"fromstring", "XML", "parse", "iterparse", "XMLParser"}
with open(sys.argv[1], encoding="utf-8") as fh:
    tree = ast.parse(fh.read())
outside = 0
inside = 0
helper_calls = 0


def visit(node, function):
    global outside, inside, helper_calls
    if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
        function = function or node.name
    if isinstance(node, ast.Call):
        target = node.func
        if (
            isinstance(target, ast.Attribute)
            and isinstance(target.value, ast.Name)
            and target.value.id == "ET"
            and target.attr in PARSERS
        ):
            if function == "parse_xml":
                inside += 1
            else:
                outside += 1
        if isinstance(target, ast.Name) and target.id == "parse_xml":
            helper_calls += 1
    for child in ast.iter_child_nodes(node):
        visit(child, function)


visit(tree, None)
print(outside, inside, helper_calls)
PY
)"
  read -r outside inside helper_calls <<< "$calls"
  expect "$checker: no ElementTree parser call outside parse_xml (found $outside)" \
    '[ "$outside" -eq 0 ]'
  expect "$checker: parse_xml calls ET.fromstring" '[ "$inside" -ge 1 ]'
  expect "$checker: parse_xml is called ($helper_calls calls)" '[ "$helper_calls" -ge 1 ]'
done

echo "case 2: each checker on the copy of the repository"
for checker in "${checkers[@]}"; do
  run_checker "$checker" "$work/$checker.parts"
  failed_before="$failed"
  failed=0
  expect "$checker: exit status is 0" '[ "$status" -eq 0 ]'
  grep -E $'\t.*\\.(xml|rels)$' "$work/$checker.parts" | sort -u > "$work/$checker.xml-parts" || true
  count="$(wc -l < "$work/$checker.xml-parts" | tr -d ' ')"
  expect "$checker: reads at least one XML part ($count)" '[ "$count" -ge 1 ]'
  if [ "$failed" -ne 0 ]; then
    show_output
  fi
  failed=$((failed_before | failed))
done

echo "case 3: a document type declaration in each part a checker reads"
for checker in "${checkers[@]}"; do
  [ "$checker" = "$protection" ] && continue
  while IFS=$'\t' read -r workbook part; do
    cp "$copy/$workbook" "$work/original.xlsx"
    make_doctype_copy "$work/original.xlsx" "$copy/$workbook" "$part"
    run_checker "$checker" "$work/doctype.parts"
    cp "$work/original.xlsx" "$copy/$workbook"
    parsed="$(cat "$work/doctype.parts.doctype")"
    failed_before="$failed"
    failed=0
    expect "$checker, $workbook: $part: exit status is not 0 ($status)" \
      '[ "$status" -ne 0 ]'
    expect "$checker, $workbook: $part: nothing on stderr" '[ -z "$err" ]'
    expect "$checker, $workbook: $part: last line is RESULT: FAIL" \
      '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
    expect "$checker, $workbook: $part: ET.fromstring is given no document type declaration ($parsed)" \
      '[ "$parsed" -eq 0 ]'
    expect "$checker, $workbook: $part: the part is read" \
      'grep -q -x -F -- "$workbook$tab$part" "$work/doctype.parts"'
    if [ "$failed" -ne 0 ]; then
      show_output
    fi
    failed=$((failed_before | failed))
  done < "$work/$checker.xml-parts"
done

echo "case 4: $protection, a document type declaration in every part"
for name in "${workbooks[@]}"; do
  cp "$copy/$name" "$work/original-$(basename "$name")"
  parts=()
  while IFS= read -r -d '' part; do
    parts+=("$part")
  done < <(python3 -I - "$copy/$name" <<'PY'
import re
import sys
import zipfile

PART = re.compile(r"xl/.*\.xml", re.ASCII | re.IGNORECASE | re.DOTALL)
with zipfile.ZipFile(sys.argv[1]) as book:
    for name in book.namelist():
        if PART.fullmatch(name):
            sys.stdout.write(name + "\0")
PY
)
  make_doctype_copy "$work/original-$(basename "$name")" "$copy/$name" "${parts[@]}"
done
run_checker "$protection" "$work/ignored.parts"
failed_before="$failed"
failed=0
expect "exit status is 1" '[ "$status" -eq 1 ]'
for name in "${workbooks[@]}"; do
  while IFS= read -r part; do
    line="  FAIL $copy/$name: $part: has a document type declaration"
    expect "FAIL line for $name: $part" \
      'printf "%s\n" "$out" | grep -q -F -- "$line (line "'
  done < <(python3 -I - "$work/original-$(basename "$name")" <<'PY'
import re
import sys
import zipfile

PART = re.compile(r"xl/.*\.xml", re.ASCII | re.IGNORECASE | re.DOTALL)
with zipfile.ZipFile(sys.argv[1]) as book:
    for name in book.namelist():
        if PART.fullmatch(name):
            print(name)
PY
)
done
if [ "$failed" -ne 0 ]; then
  show_output
fi
failed=$((failed_before | failed))

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
