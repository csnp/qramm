#!/usr/bin/env python3
"""Checks that documents quoting rows of the compliance mapping spec quote
them as the spec gives them.

Usage:
    python3 -I scripts/check-compliance-quotes.py [document ...]

toolkit-specs/4_QRAMM_Compliance_Mapping_Details.md gives, for each of the
120 questions, a control and a relevance weight in eight frameworks, or "-"
where the question maps to nothing. Other documents copy rows of that table
as examples. With no arguments this script checks the documents in
DOCUMENTS; with arguments it checks those files instead (paths relative to
the repository root, or absolute). For each document:

    1. A quoted row is a row of a table whose header is the spec's header
       (Question | NIST CSF | NIST PQC | CMMC | FISMA | FedRAMP | ISO | SOC2 |
       CIS) and whose first cell is a question number, alone ("Q1") or
       followed by a colon and a name ("Q1: Automated asset discovery").
       Tables inside fenced code blocks count. Other rows are not read.
    2. The document quotes at least one row.
    3. Each quoted row names a question in the spec and has a cell for each
       of the eight frameworks.
    4. Each cell is the spec's cell: the same control and the same weight,
       or "-" where the spec gives "-".

The spec is read with read_spec from check-compliance-map.py in this
directory, and each problem it reports in the spec (a missing or malformed
cell, for example) is a FAIL line here too. The script uses the Python
standard library only.

Exit status: 0 when the documents match the spec, 1 when they do not, 2 on a
usage error.
"""

import importlib.util
import os
import re
import sys

DOCUMENTS = [
    "toolkit-specs/compliance-tab-vision/compliance-vision-summary.md",
]

QUOTED_ROW = re.compile(r"^(Q\d+)(?::.*)?$")
TOLERANCE = 1e-9

USAGE = "usage: python3 -I scripts/check-compliance-quotes.py [document ...]"


def load_map_check(here):
    # Loading the module would otherwise leave scripts/__pycache__ behind.
    sys.dont_write_bytecode = True
    path = os.path.join(here, "check-compliance-map.py")
    spec = importlib.util.spec_from_file_location("check_compliance_map", path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def split_row(line):
    return [cell.strip() for cell in line.strip().strip("|").split("|")]


def quoted_rows(lines, header):
    """(line number, cells) of each quoted row."""
    rows = []
    in_table = False
    for number, line in enumerate(lines, 1):
        if not line.lstrip().startswith("|"):
            in_table = False
            continue
        cells = split_row(line)
        if cells == header:
            in_table = True
            continue
        if in_table and QUOTED_ROW.match(cells[0]):
            rows.append((number, cells))
    return rows


def show_cell(control, weight):
    return "-" if control is None else "{} ({})".format(control, weight)


def same_cell(cell, control, weight, cell_pattern):
    if control is None:
        return cell == "-"
    parsed = cell_pattern.match(cell)
    return (
        parsed is not None
        and parsed.group(1) == control
        and abs(float(parsed.group(2)) - weight) <= TOLERANCE
    )


def check_document(label, path, mapping, spec, problems):
    try:
        with open(path, encoding="utf-8") as fh:
            lines = fh.read().splitlines()
    except OSError as error:
        problems.append("{}: cannot read ({})".format(label, error.strerror))
        return
    header = ["Question"] + [column for column, _ in mapping.FRAMEWORKS]
    rows = quoted_rows(lines, header)
    before = len(problems)
    if not rows:
        problems.append(
            "{}: quotes no row of {} (no table with the header {})".format(
                label, mapping.SPEC, " | ".join(header)
            )
        )
    for number, cells in rows:
        question = QUOTED_ROW.match(cells[0]).group(1)
        where = "{} line {}".format(label, number)
        if not any((question, framework) in spec for _, framework in mapping.FRAMEWORKS):
            problems.append("{}: {} is not a question in {}".format(where, question, mapping.SPEC))
            continue
        if len(cells) != len(header):
            problems.append(
                "{}: {} has {} cells, expected {}".format(where, question, len(cells), len(header))
            )
            continue
        for (column, framework), cell in zip(mapping.FRAMEWORKS, cells[1:]):
            if (question, framework) not in spec:
                # read_spec has already reported the spec cell it could not read.
                continue
            line, control, weight = spec[(question, framework)]
            if not same_cell(cell, control, weight, mapping.SPEC_CELL):
                problems.append(
                    "{}: {} {} is {}, the spec gives {} (line {})".format(
                        where, question, column, cell, show_cell(control, weight), line
                    )
                )
    if len(problems) == before:
        print("  PASS {} quoted row{}".format(len(rows), "" if len(rows) == 1 else "s"))


def main(argv):
    if any(arg.startswith("-") for arg in argv):
        print(USAGE, file=sys.stderr)
        return 2
    here = os.path.dirname(os.path.realpath(__file__))
    root = os.path.dirname(here)
    mapping = load_map_check(here)
    documents = argv or DOCUMENTS

    problems = []
    try:
        spec = mapping.read_spec(os.path.join(root, mapping.SPEC), problems)
    except OSError as error:
        print("  FAIL {}: cannot read ({})".format(mapping.SPEC, error.strerror))
        print("RESULT: FAIL")
        return 1

    for label in documents:
        print("== {} against {}".format(label, mapping.SPEC))
        check_document(label, os.path.join(root, label), mapping, spec, problems)

    for problem in problems:
        print("  FAIL {}".format(problem))
    print("RESULT: {}".format("FAIL" if problems else "PASS"))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
