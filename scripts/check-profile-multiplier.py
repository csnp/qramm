#!/usr/bin/env python3
"""Checks that documents giving the range of the QRAMM profile multiplier
state the range the toolkit workbook can calculate.

Usage:
    python3 -I scripts/check-profile-multiplier.py [file ...]

The Profile tab of toolkit/QRAMM_Assessment_Toolkit.xlsx calculates the
profile multiplier (the defined name ProfileMultiplier, Profile!D21) with a
formula of the form

    ROUND(V(D9, 3) * V(D9, 2) + ... + V(D17, 3) * V(D17, 2), 2)

inside an IFERROR that shows "-" until every answer is set, where V(cell, n)
is VLOOKUP(cell, RiskMatrix, n, FALSE). There is one term for each profile
answer. RiskMatrix (Data!M2:O30) gives each answer a factor in its second
column and a risk value in its third; its first row is a header. This script
reads the formula and fails unless every term has that form. The answers to
one profile question share that question's factor, so the script groups the
RiskMatrix rows by factor and fails unless there is one group for each term.
The lowest multiplier adds each factor times the lowest risk value in its
group, and the highest adds each factor times the highest. Both are rounded
to the decimal places the formula's ROUND gives, with halves rounded up.

With no file arguments it checks the documents in DOCUMENTS; with file
arguments it checks those files instead (paths relative to the repository
root, or absolute). A document is a text file, or a workbook (a path that
ends in .xlsx) whose text cells, the cells of every sheet that hold a shared
or inline string, are checked one cell at a time. For each document:

    1. Every multiplier range it gives runs from the lowest to the highest
       multiplier.
    2. The document gives a multiplier range.

A multiplier range is two numbers with one decimal place or more, written as
"A-B", "A - B", "A to B", "between A and B" or with an en dash in place of
the hyphen, where each number may be followed by "x". It counts when it is
on a line, outside code blocks, that contains "multiplier" in any case; in a
workbook, each line of a cell's text is a line. The script uses the Python
standard library only.

Exit status: 0 when the documents agree with the workbook, 1 when they do
not or the workbook does not have the form described above, 2 on a usage
error. An empty file argument fails with "no file name given". --help (or -h)
prints the usage line and this text on stderr and exits 2.
"""

import os
import re
import sys
import xml.etree.ElementTree as ET
import zipfile
from decimal import ROUND_HALF_UP, Decimal, InvalidOperation

WORKBOOK = "toolkit/QRAMM_Assessment_Toolkit.xlsx"
MULTIPLIER = "ProfileMultiplier"
MATRIX = "RiskMatrix"

DOCUMENTS = [
    "framework/scoring-methodology.md",
    "toolkit/toolkit-overview.md",
    "toolkit-specs/MASTER_PLAN_Document_Checklist.md",
    "toolkit/QRAMM_Assessment_Toolkit.xlsx",
    "toolkit/Sample_Assessment.xlsx",
]

MAIN_NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
REL_NS = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
PKG_REL_NS = "http://schemas.openxmlformats.org/package/2006/relationships"

# A defined name's reference, Sheet!$A$1 or Sheet!$A$1:$C$9.
REFERENCE = re.compile(r"'?(.+?)'?!\$?([A-Z]+)\$?(\d+)(?::\$?([A-Z]+)\$?(\d+))?")
CELL = re.compile(r"([A-Z]+)(\d+)")

# Formula parts, matched after all whitespace is removed.
IFERROR = re.compile(r'IFERROR\((.+),"[^"]*"\)')
ROUNDED = re.compile(r"ROUND\((.+),(\d+)\)")
TERM = re.compile(
    r"VLOOKUP\((\$?[A-Z]+\$?\d+),{0},3,FALSE\)\*VLOOKUP\(\1,{0},2,FALSE\)".format(
        re.escape(MATRIX)
    )
)

RANGE = re.compile(
    r"(?<![\d.])(?:between (\d+\.\d+)x? and (\d+\.\d+)x?"
    r"|(\d+\.\d+)x? ?(?:-|\N{EN DASH}|to) ?(\d+\.\d+)x?)(?!\.?\d)",
    re.IGNORECASE,
)

USAGE = "usage: python3 -I scripts/check-profile-multiplier.py [file ...]"


def ns(prefix, tag):
    return "{%s}%s" % (prefix, tag)


def sheet_paths(book):
    """Sheet name -> path of its XML part inside the workbook archive."""
    workbook = ET.fromstring(book.read("xl/workbook.xml"))
    rels = ET.fromstring(book.read("xl/_rels/workbook.xml.rels"))
    targets = {
        rel.get("Id"): rel.get("Target")
        for rel in rels.iter(ns(PKG_REL_NS, "Relationship"))
    }
    paths = {}
    for sheet in workbook.iter(ns(MAIN_NS, "sheet")):
        target = targets[sheet.get(ns(REL_NS, "id"))]
        if target.startswith("/"):
            path = target.lstrip("/")
        else:
            path = "xl/" + target
        paths[sheet.get("name")] = path
    return workbook, paths


def defined_names(workbook):
    """Workbook-scoped defined name -> the reference it stands for."""
    return {
        node.get("name"): (node.text or "").strip()
        for node in workbook.iter(ns(MAIN_NS, "definedName"))
        if node.get("localSheetId") is None
    }


def shared_strings(book):
    """The workbook's shared string table, as a list of strings."""
    if "xl/sharedStrings.xml" not in book.namelist():
        return []
    table = ET.fromstring(book.read("xl/sharedStrings.xml"))
    strings = []
    for item in table.iter(ns(MAIN_NS, "si")):
        runs = item.findall(ns(MAIN_NS, "t"))
        runs += item.findall("{}/{}".format(ns(MAIN_NS, "r"), ns(MAIN_NS, "t")))
        strings.append("".join(run.text or "" for run in runs))
    return strings


def column_number(letters):
    number = 0
    for letter in letters:
        number = number * 26 + ord(letter) - ord("A") + 1
    return number


def cell_text(cell, strings):
    """Text of a cell: its shared or inline string, or its stored value."""
    if cell is None:
        return None
    if cell.get("t") == "inlineStr":
        return "".join(t.text or "" for t in cell.iter(ns(MAIN_NS, "t")))
    value = cell.find(ns(MAIN_NS, "v"))
    if value is None or value.text is None:
        return None
    if cell.get("t") == "s":
        return strings[int(value.text)]
    return value.text


def named_cells(book, paths, names, name, problems):
    """(reference, top row, left column, bottom row, cells) for a defined
    name, where cells maps (row, column) to each cell inside the reference.
    None when the name does not refer to cells of a sheet in the workbook."""
    match = REFERENCE.fullmatch(names.get(name, ""))
    sheet = match.group(1).replace("''", "'") if match else None
    if sheet not in paths:
        problems.append(
            "{}: no defined name {} that refers to cells".format(WORKBOOK, name)
        )
        return None
    _, left, top, right, bottom = match.groups()
    top, bottom = int(top), int(bottom or top)
    left, right = column_number(left), column_number(right or left)
    cells = {}
    for cell in ET.fromstring(book.read(paths[sheet])).iter(ns(MAIN_NS, "c")):
        ref = CELL.fullmatch(cell.get("r") or "")
        if ref:
            row, column = int(ref.group(2)), column_number(ref.group(1))
            if top <= row <= bottom and left <= column <= right:
                cells[(row, column)] = cell
    return names[name].replace("$", ""), top, left, bottom, cells


def multiplier_range(path, problems):
    """(formula cell, answers, matrix reference, factor -> risk values,
    lowest, highest) from the workbook, or None after adding a problem."""
    with zipfile.ZipFile(path) as book:
        workbook, paths = sheet_paths(book)
        names = defined_names(workbook)
        strings = shared_strings(book)
        target = named_cells(book, paths, names, MULTIPLIER, problems)
        matrix = named_cells(book, paths, names, MATRIX, problems)
    if target is None or matrix is None:
        return None

    where, top, left, _, cells = target
    formula = cells.get((top, left))
    formula = None if formula is None else formula.find(ns(MAIN_NS, "f"))
    text = re.sub(r"\s+", "", formula.text or "") if formula is not None else ""
    wrapped = IFERROR.fullmatch(text)
    rounded = ROUNDED.fullmatch(wrapped.group(1) if wrapped else text)
    terms = []
    if rounded:
        terms = [TERM.fullmatch(term) for term in rounded.group(1).split("+")]
    if not terms or not all(terms):
        problems.append(
            "{}: {} ({}) is not ROUND of a sum of VLOOKUP(answer, {m}, 3, FALSE) "
            "* VLOOKUP(answer, {m}, 2, FALSE) terms: {}".format(
                WORKBOOK, where, MULTIPLIER, text or "no formula", m=MATRIX
            )
        )
        return None
    answers = [term.group(1) for term in terms]

    reference, top, left, bottom, cells = matrix
    before = len(problems)
    groups = {}
    for row in range(top, bottom + 1):
        category, factor, value = (
            cell_text(cells.get((row, left + offset)), strings) for offset in range(3)
        )
        if not (category or "").strip():
            continue
        try:
            factor, value = Decimal(factor.strip()), Decimal(value.strip())
        except (AttributeError, InvalidOperation):
            if row != top:
                problems.append(
                    "{}: {} row {} ({}): factor {!r} and risk value {!r} are not "
                    "both numbers".format(
                        WORKBOOK, MATRIX, row, category.strip(), factor, value
                    )
                )
            continue
        groups.setdefault(factor, []).append(value)
    if len(problems) > before:
        return None
    if len(groups) != len(answers):
        problems.append(
            "{}: {} has {} different factors but {} adds {} answers, so its rows "
            "cannot be grouped into profile questions by factor".format(
                WORKBOOK, MATRIX, len(groups), where, len(answers)
            )
        )
        return None

    places = Decimal(1).scaleb(-int(rounded.group(2)))
    lowest = sum(f * min(v) for f, v in groups.items()).quantize(
        places, rounding=ROUND_HALF_UP
    )
    highest = sum(f * max(v) for f, v in groups.items()).quantize(
        places, rounding=ROUND_HALF_UP
    )
    return where, answers, reference, groups, lowest, highest


def workbook_texts(path):
    """List of (Sheet!Cell, lines of its text) for every cell of a workbook
    that holds a shared or inline string, in sheet order."""
    texts = []
    with zipfile.ZipFile(path) as book:
        _, paths = sheet_paths(book)
        strings = shared_strings(book)
        for sheet, part in paths.items():
            for cell in ET.fromstring(book.read(part)).iter(ns(MAIN_NS, "c")):
                if cell.get("t") in ("s", "inlineStr"):
                    text = cell_text(cell, strings) or ""
                    place = "{}!{}".format(sheet, cell.get("r"))
                    texts.append((place, text.splitlines()))
    return texts


def stated_ranges(lines):
    """List of (line number, low, high) outside fenced code blocks, as written."""
    found = []
    fenced = False
    for number, line in enumerate(lines, 1):
        if line.lstrip().startswith("```"):
            fenced = not fenced
            continue
        if fenced or "multiplier" not in line.lower():
            continue
        for match in RANGE.finditer(line):
            if match.group(1):
                found.append((number, match.group(1), match.group(2)))
            else:
                found.append((number, match.group(3), match.group(4)))
    return found


def check_document(path, parts, lowest, highest, problems):
    """parts is a list of (place, lines): place is "" for a text file and
    Sheet!Cell for each text cell of a workbook."""
    stated = 0
    for place, lines in parts:
        where = place + " " if place else ""
        for number, low, high in stated_ranges(lines):
            stated += 1
            if (Decimal(low), Decimal(high)) != (lowest, highest):
                problems.append(
                    "{} {}line {}: the multiplier range is {} to {} here, but {} "
                    "calculates {} to {}".format(
                        path, where, number, low, high, WORKBOOK, lowest, highest
                    )
                )
            else:
                print("  PASS {}line {}: {} to {}".format(where, number, low, high))
    if not stated:
        problems.append("{}: gives no multiplier range".format(path))


def main(argv):
    if "--help" in argv or "-h" in argv:
        print(USAGE, file=sys.stderr)
        # __doc__ is None when python3 -OO removes docstrings.
        if __doc__:
            print(file=sys.stderr)
            print(__doc__.strip(), file=sys.stderr)
        return 2
    if any(arg.startswith("-") for arg in argv):
        print(USAGE, file=sys.stderr)
        return 2
    root = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
    documents = argv or DOCUMENTS

    problems = []
    found = multiplier_range(os.path.join(root, WORKBOOK), problems)
    if found:
        where, answers, reference, groups, lowest, highest = found
        print("== {} {} ({}), {} ({})".format(
            WORKBOOK, MULTIPLIER, where, MATRIX, reference
        ))
        print("  answers: {}".format(", ".join(answers)))
        for factor, values in groups.items():
            print("  factor {}: risk values {}".format(
                factor, ", ".join(str(value) for value in sorted(set(values)))
            ))
        print("  lowest {}, highest {}".format(lowest, highest))

        for path in documents:
            print("== {} against {}".format(path or "''", WORKBOOK))
            if not path:
                problems.append("'': no file name given")
                continue
            is_workbook = path.lower().endswith(".xlsx")
            try:
                if is_workbook:
                    parts = workbook_texts(os.path.join(root, path))
                else:
                    with open(os.path.join(root, path), encoding="utf-8") as fh:
                        parts = [("", fh.read().splitlines())]
            except OSError as error:
                problems.append("{}: cannot read ({})".format(path, error.strerror))
                continue
            except zipfile.BadZipFile:
                problems.append("{}: cannot read (not a zip file)".format(path))
                continue
            except (KeyError, IndexError, ValueError, ET.ParseError):
                # A zip archive without the workbook parts, with an XML part
                # that does not parse, or with a shared-string index that is
                # not in the table.
                if not is_workbook:
                    raise
                problems.append("{}: cannot read (not a workbook)".format(path))
                continue
            check_document(path, parts, lowest, highest, problems)

    for problem in problems:
        print("  FAIL {}".format(problem))
    print("RESULT: {}".format("FAIL" if problems else "PASS"))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
