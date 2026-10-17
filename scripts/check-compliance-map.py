#!/usr/bin/env python3
"""Checks that the toolkit workbooks carry the compliance mapping in the spec.

Usage:
    python3 -I scripts/check-compliance-map.py [workbook ...]

toolkit-specs/4_QRAMM_Compliance_Mapping_Details.md gives, for each of the
120 questions, a control and a relevance weight in eight frameworks, or "-"
where the question maps to nothing. The workbooks store the same mapping in
the range named ComplianceMap (Question_ID, Framework, Helper Column,
Control_ID, Category, Weight). With no arguments this script checks the
workbooks in WORKBOOKS; with arguments it checks those files instead (paths
relative to the repository root, or absolute). For each workbook:

    1. Every question and framework in the spec has exactly one row in the
       map, and the map has no other rows.
    2. The row's Control_ID is the spec's control. A Control_ID stored as a
       number (CIS v8 safeguards such as 3.11) is compared as a number, so
       the spec's "1.10" matches a stored 1.1.
    3. The row's Weight is the spec's weight. A "-" in the spec matches a
       row whose Control_ID is "-" and whose Weight is empty.

The script reads the stored cell values only and uses the Python standard
library only.

Exit status: 0 when the workbooks match the spec, 1 when they do not, 2 on a
usage error.
"""

import os
import re
import sys
import xml.etree.ElementTree as ET
import zipfile

SPEC = "toolkit-specs/4_QRAMM_Compliance_Mapping_Details.md"

WORKBOOKS = [
    "toolkit/QRAMM_Assessment_Toolkit.xlsx",
    "toolkit/Sample_Assessment.xlsx",
]

MAP_NAME = "ComplianceMap"

# Spec table column -> framework name in the workbook map.
FRAMEWORKS = [
    ("NIST CSF", "NIST CSF 2.0"),
    ("NIST PQC", "NIST PQC"),
    ("CMMC", "CMMC 2.0"),
    ("FISMA", "FISMA"),
    ("FedRAMP", "FedRAMP"),
    ("ISO", "ISO 27001"),
    ("SOC2", "SOC2"),
    ("CIS", "CIS v8"),
]

QUESTIONS = 120

# Offsets of the columns read from each row of the map.
QUESTION_COLUMN = 0
FRAMEWORK_COLUMN = 1
CONTROL_COLUMN = 3
WEIGHT_COLUMN = 5
MAP_WIDTH = 6

MAIN_NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
REL_NS = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
PKG_REL_NS = "http://schemas.openxmlformats.org/package/2006/relationships"

SPEC_ROW = re.compile(r"^\|\s*(Q\d+):")
SPEC_CELL = re.compile(r"^(.+?) \((\d+(?:\.\d+)?)\)$")
CELL_REF = re.compile(r"([A-Z]+)(\d+)")
RANGE_REF = re.compile(r"'?(.+?)'?!\$?([A-Z]+)\$?(\d+):\$?([A-Z]+)\$?(\d+)")
TOLERANCE = 1e-9

USAGE = "usage: python3 -I scripts/check-compliance-map.py [workbook ...]"


def ns(prefix, tag):
    return "{%s}%s" % (prefix, tag)


def column_number(letters):
    number = 0
    for letter in letters:
        number = number * 26 + ord(letter) - ord("A") + 1
    return number


def column_letters(number):
    letters = ""
    while number:
        number, rest = divmod(number - 1, 26)
        letters = chr(ord("A") + rest) + letters
    return letters


def read_spec(path, problems):
    """(question, framework) -> (line number, control or None, weight or None)."""
    with open(path, encoding="utf-8") as fh:
        lines = fh.read().splitlines()
    spec = {}
    header = None
    for number, line in enumerate(lines, 1):
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if cells and cells[0] == "Question":
            header = cells[1:]
            continue
        match = SPEC_ROW.match(line)
        if not match:
            continue
        question = match.group(1)
        if header != [column for column, _ in FRAMEWORKS]:
            problems.append(
                "{} line {}: the table header does not list {}".format(
                    SPEC, number, " | ".join(column for column, _ in FRAMEWORKS)
                )
            )
            continue
        if len(cells) != len(FRAMEWORKS) + 1:
            problems.append(
                "{} line {}: {} has {} cells, expected {}".format(
                    SPEC, number, question, len(cells), len(FRAMEWORKS) + 1
                )
            )
            continue
        for (column, framework), cell in zip(FRAMEWORKS, cells[1:]):
            key = (question, framework)
            if key in spec:
                problems.append(
                    "{} line {}: {} {} is also given on line {}".format(
                        SPEC, number, question, column, spec[key][0]
                    )
                )
                continue
            if cell == "-":
                spec[key] = (number, None, None)
                continue
            parsed = SPEC_CELL.match(cell)
            if not parsed:
                problems.append(
                    "{} line {}: {} {} is \"{}\", expected \"<control> (<weight>)\" "
                    "or \"-\"".format(SPEC, number, question, column, cell)
                )
                continue
            spec[key] = (number, parsed.group(1), float(parsed.group(2)))
    for index in range(1, QUESTIONS + 1):
        question = "Q{}".format(index)
        for column, framework in FRAMEWORKS:
            if (question, framework) not in spec:
                problems.append("{}: no {} cell for {}".format(SPEC, column, question))
    return spec


def shared_strings(book):
    try:
        root = ET.fromstring(book.read("xl/sharedStrings.xml"))
    except KeyError:
        return []
    return [
        "".join(node.text or "" for node in item.iter(ns(MAIN_NS, "t")))
        for item in root.iter(ns(MAIN_NS, "si"))
    ]


def map_range(book):
    """(sheet part path, sheet name, first column, first row, last row)."""
    workbook = ET.fromstring(book.read("xl/workbook.xml"))
    rels = ET.fromstring(book.read("xl/_rels/workbook.xml.rels"))
    targets = {
        rel.get("Id"): rel.get("Target")
        for rel in rels.iter(ns(PKG_REL_NS, "Relationship"))
    }
    paths = {}
    for sheet in workbook.iter(ns(MAIN_NS, "sheet")):
        target = targets[sheet.get(ns(REL_NS, "id"))]
        paths[sheet.get("name")] = target.lstrip("/") if target.startswith("/") else "xl/" + target
    for node in workbook.iter(ns(MAIN_NS, "definedName")):
        if node.get("name") != MAP_NAME or node.get("localSheetId") is not None:
            continue
        match = RANGE_REF.fullmatch((node.text or "").strip())
        if not match:
            raise ValueError("{} is not a cell range: {}".format(MAP_NAME, node.text))
        sheet = match.group(1).replace("''", "'")
        first, last = column_number(match.group(2)), column_number(match.group(4))
        if last - first + 1 != MAP_WIDTH:
            raise ValueError(
                "{} is {} columns wide, expected {}".format(MAP_NAME, last - first + 1, MAP_WIDTH)
            )
        if sheet not in paths:
            raise ValueError("{} names sheet '{}', which is not in the workbook".format(MAP_NAME, sheet))
        return paths[sheet], sheet, first, int(match.group(3)), int(match.group(5))
    raise ValueError("the workbook has no defined name {}".format(MAP_NAME))


def cell_value(node, strings):
    """Stored value of a cell: str, float, or None when it is empty."""
    value = node.find(ns(MAIN_NS, "v"))
    kind = node.get("t")
    if kind == "inlineStr":
        return "".join(t.text or "" for t in node.iter(ns(MAIN_NS, "t")))
    if value is None or value.text is None:
        return None
    if kind == "s":
        return strings[int(value.text)]
    if kind in ("str", "e"):
        return value.text
    return float(value.text)


def read_map(path):
    """(sheet name, list of (row number, {offset: value}))."""
    with zipfile.ZipFile(path) as book:
        strings = shared_strings(book)
        part, sheet, first, top, bottom = map_range(book)
        root = ET.fromstring(book.read(part))
    rows = {number: {} for number in range(top, bottom + 1)}
    for row in root.iter(ns(MAIN_NS, "row")):
        number = int(row.get("r"))
        if number not in rows:
            continue
        for node in row.iter(ns(MAIN_NS, "c")):
            letters = CELL_REF.fullmatch(node.get("r")).group(1)
            offset = column_number(letters) - first
            if 0 <= offset < MAP_WIDTH:
                rows[number][offset] = cell_value(node, strings)
    return sheet, first, sorted(rows.items())


def show(value):
    if value is None:
        return "empty"
    if isinstance(value, float):
        return "{:.15g}".format(value)
    return value


def same_control(stored, expected):
    if isinstance(stored, float):
        try:
            return abs(stored - float(expected)) <= TOLERANCE
        except ValueError:
            return False
    return stored == expected


def check_workbook(label, path, spec, problems):
    try:
        sheet, first, rows = read_map(path)
    except (OSError, KeyError, ValueError, zipfile.BadZipFile, ET.ParseError) as error:
        problems.append("{}: cannot read the compliance map ({})".format(label, error))
        return
    control_letters = column_letters(first + CONTROL_COLUMN)
    weight_letters = column_letters(first + WEIGHT_COLUMN)
    seen = {}
    before = len(problems)
    for number, values in rows:
        question = values.get(QUESTION_COLUMN)
        framework = values.get(FRAMEWORK_COLUMN)
        key = (question, framework)
        where = "{} {} {}".format(label, show(question), show(framework))
        if key not in spec:
            problems.append(
                "{} {} row {}: not a question and framework in {}".format(label, sheet, number, SPEC)
            )
            continue
        if key in seen:
            problems.append("{}: on {} rows {} and {}".format(where, sheet, seen[key], number))
            continue
        seen[key] = number
        line, control, weight = spec[key]
        stored_control = values.get(CONTROL_COLUMN)
        stored_weight = values.get(WEIGHT_COLUMN)
        expected_control = "-" if control is None else control
        if not same_control(stored_control, expected_control):
            problems.append(
                "{}: {}!{}{} is {}, the spec gives {} (line {})".format(
                    where, sheet, control_letters, number,
                    show(stored_control), expected_control, line,
                )
            )
        if weight is None:
            weight_ok = stored_weight is None
        else:
            weight_ok = isinstance(stored_weight, float) and abs(stored_weight - weight) <= TOLERANCE
        if not weight_ok:
            problems.append(
                "{}: {}!{}{} is {}, the spec gives {} (line {})".format(
                    where, sheet, weight_letters, number, show(stored_weight),
                    "no weight" if weight is None else "{:g}".format(weight), line,
                )
            )
    for key in sorted(spec, key=lambda item: (int(item[0][1:]), item[1])):
        if key not in seen:
            problems.append(
                "{}: no row for {} {} in {}".format(label, key[0], key[1], MAP_NAME)
            )
    if len(problems) == before:
        print("  PASS {} questions x {} frameworks, {} rows".format(
            QUESTIONS, len(FRAMEWORKS), len(seen)
        ))


def main(argv):
    if any(arg.startswith("-") for arg in argv):
        print(USAGE, file=sys.stderr)
        return 2
    root = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
    workbooks = argv or WORKBOOKS

    problems = []
    try:
        spec = read_spec(os.path.join(root, SPEC), problems)
    except OSError as error:
        print("  FAIL {}: cannot read ({})".format(SPEC, error.strerror))
        print("RESULT: FAIL")
        return 1

    for label in workbooks:
        print("== {} against {}".format(label, SPEC))
        check_workbook(label, os.path.join(root, label), spec, problems)

    for problem in problems:
        print("  FAIL {}".format(problem))
    print("RESULT: {}".format("FAIL" if problems else "PASS"))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
