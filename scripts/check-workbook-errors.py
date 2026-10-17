#!/usr/bin/env python3
"""Checks that the toolkit workbooks show no error value in a visible cell.

Usage:
    python3 -I scripts/check-workbook-errors.py [workbook ...]

A workbook stores the value each formula last gave, and a spreadsheet
application shows that value until it recalculates, so an error value
stored in a visible cell is what the reader sees first. With no workbook
arguments this script reads the workbooks in WORKBOOKS; with arguments it
reads those files instead (paths relative to the repository root, or
absolute). For each workbook it reports every cell that stores an error
value (#N/A, #VALUE!, #DIV/0!, #REF!, #NAME?, #NUM! or #NULL!) in a sheet,
row and column that are not hidden, with the cell's formula. A cell in a
hidden sheet, a hidden row or a hidden column is not reported, as the
reader does not see it.

The script uses the Python standard library only. Exit status: 0 when no
workbook stores an error value in a visible cell, 1 when one does or a
workbook cannot be read, 2 on a usage error. An empty workbook argument
fails with "no file name given". --help (or -h) prints the usage line and
this text on stderr and exits 2.
"""

import os
import re
import sys
import xml.etree.ElementTree as ET
import zipfile

WORKBOOKS = [
    "toolkit/QRAMM_Assessment_Toolkit.xlsx",
    "toolkit/Sample_Assessment.xlsx",
]

MAIN_NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
REL_NS = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
PKG_REL_NS = "http://schemas.openxmlformats.org/package/2006/relationships"

CELL_REF = re.compile(r"([A-Z]+)(\d+)")

USAGE = "usage: python3 -I scripts/check-workbook-errors.py [workbook ...]"


def ns(prefix, tag):
    return "{%s}%s" % (prefix, tag)


def column_number(letters):
    number = 0
    for letter in letters:
        number = number * 26 + ord(letter) - ord("A") + 1
    return number


def sheets(book):
    """List of (name, part path, hidden) in workbook order."""
    workbook = ET.fromstring(book.read("xl/workbook.xml"))
    rels = ET.fromstring(book.read("xl/_rels/workbook.xml.rels"))
    targets = {
        rel.get("Id"): rel.get("Target")
        for rel in rels.iter(ns(PKG_REL_NS, "Relationship"))
    }
    found = []
    for sheet in workbook.iter(ns(MAIN_NS, "sheet")):
        target = targets[sheet.get(ns(REL_NS, "id"))]
        part = target.lstrip("/") if target.startswith("/") else "xl/" + target
        hidden = sheet.get("state") in ("hidden", "veryHidden")
        found.append((sheet.get("name"), part, hidden))
    return found


def hidden_columns(root):
    """List of (first, last) column numbers of the hidden column ranges."""
    ranges = []
    for col in root.iter(ns(MAIN_NS, "col")):
        if col.get("hidden") in ("1", "true"):
            ranges.append((int(col.get("min")), int(col.get("max"))))
    return ranges


def formula_text(cell):
    """The cell's formula with whitespace runs collapsed, or "no formula"."""
    node = cell.find(ns(MAIN_NS, "f"))
    if node is None or not (node.text or "").strip():
        return "no formula"
    return " ".join(node.text.split())


def check_sheet(name, root, label, problems):
    """Adds a problem per visible error cell. Returns the number of visible
    cells with a formula."""
    hidden = hidden_columns(root)
    formulas = 0
    for row in root.iter(ns(MAIN_NS, "row")):
        if row.get("hidden") in ("1", "true"):
            continue
        for cell in row.iter(ns(MAIN_NS, "c")):
            match = CELL_REF.match(cell.get("r", ""))
            if not match:
                continue
            column = column_number(match.group(1))
            if any(first <= column <= last for first, last in hidden):
                continue
            if cell.find(ns(MAIN_NS, "f")) is not None:
                formulas += 1
            if cell.get("t") == "e":
                value = cell.find(ns(MAIN_NS, "v"))
                error = value.text if value is not None and value.text else "an error"
                problems.append(
                    "{}: {}!{} stores {}: {}".format(
                        label, name, cell.get("r"), error, formula_text(cell)
                    )
                )
    return formulas


def check_workbook(label, path, problems):
    before = len(problems)
    try:
        with zipfile.ZipFile(path) as book:
            formulas = 0
            for name, part, hidden in sheets(book):
                if hidden:
                    continue
                root = ET.fromstring(book.read(part))
                formulas += check_sheet(name, root, label, problems)
    except OSError as error:
        problems.append("{}: cannot read ({})".format(label, error.strerror))
        return
    except (zipfile.BadZipFile, KeyError, ET.ParseError, ValueError) as error:
        problems.append("{}: not a workbook ({})".format(label, error))
        return
    if len(problems) == before:
        print("  PASS {} visible formula cells, none stores an error value".format(formulas))


def main(argv):
    if "--help" in argv or "-h" in argv:
        print(USAGE, file=sys.stderr)
        print(file=sys.stderr)
        print(__doc__.strip(), file=sys.stderr)
        return 2
    if any(arg.startswith("-") for arg in argv):
        print(USAGE, file=sys.stderr)
        return 2
    root = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))

    problems = []
    for label in argv or WORKBOOKS:
        print("== {}".format(label or "''"))
        if not label:
            problems.append("'': no file name given")
            continue
        check_workbook(label, os.path.join(root, label), problems)

    for problem in problems:
        print("  FAIL {}".format(problem))
    print("RESULT: {}".format("FAIL" if problems else "PASS"))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
