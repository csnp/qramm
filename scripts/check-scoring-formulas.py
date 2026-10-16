#!/usr/bin/env python3
"""Checks that the framework overview states the same score formulas as the
scoring methodology.

Usage:
    python3 -I scripts/check-scoring-formulas.py

framework/scoring-methodology.md describes how the toolkit workbook calculates
QRAMM scores, and scripts/check-scoring-example.py checks its worked example
against the sample workbook. framework/qramm-overview.md repeats the practice,
dimension and overall score formulas. This script checks that the two
documents agree:

    1. Every score formula in the overview has a formula with the same left
       side in the methodology, and the two have the same text.
    2. The overview states each formula named in REQUIRED.

A score formula is a fenced code block whose first line starts with
"<name> Score =", or a line outside code blocks written in bold as
"**<name> Score = ...**". Formula text is compared with runs of whitespace
collapsed to one space. The script uses the Python standard library only.

Exit status: 0 when the documents agree, 1 when they do not, 2 on a usage
error.
"""

import os
import re
import sys

OVERVIEW = "framework/qramm-overview.md"
METHODOLOGY = "framework/scoring-methodology.md"

REQUIRED = ["Practice Score", "Dimension Score", "Overall Score"]

LEFT_SIDE = re.compile(r"^([A-Z][A-Za-z ]*Score) =")
BOLD_LINE = re.compile(r"^\*\*(.+)\*\*$")


def normalize(text):
    return " ".join(text.split())


def formulas(lines):
    """List of (line number, left side, formula text) for each score formula."""
    found = []
    fenced = False
    block = []
    for number, line in enumerate(lines, 1):
        if line.lstrip().startswith("```"):
            if fenced:
                fenced = False
                if block:
                    first_number, first_line = block[0]
                    match = LEFT_SIDE.match(first_line.strip())
                    if match:
                        text = normalize(" ".join(text for _, text in block))
                        found.append((first_number, match.group(1), text))
            else:
                fenced = True
                block = []
            continue
        if fenced:
            if line.strip() or block:
                block.append((number, line))
            continue
        bold = BOLD_LINE.match(line.strip())
        if bold:
            match = LEFT_SIDE.match(bold.group(1).strip())
            if match:
                found.append((number, match.group(1), normalize(bold.group(1))))
    return found


def read_lines(root, relative):
    with open(os.path.join(root, relative), encoding="utf-8") as fh:
        return fh.read().splitlines()


def main(argv):
    if argv:
        print("usage: python3 -I scripts/check-scoring-formulas.py", file=sys.stderr)
        return 2
    root = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
    overview = formulas(read_lines(root, OVERVIEW))
    methodology = formulas(read_lines(root, METHODOLOGY))

    print("== {} against {}".format(OVERVIEW, METHODOLOGY))
    problems = []

    reference = {}
    for number, name, text in methodology:
        if name in reference and reference[name][1] != text:
            problems.append(
                "{}: lines {} and {} state different formulas for {}".format(
                    METHODOLOGY, reference[name][0], number, name
                )
            )
            continue
        reference.setdefault(name, (number, text))

    for number, name, text in overview:
        if name not in reference:
            problems.append(
                "{} line {}: {} has no formula in {}".format(
                    OVERVIEW, number, name, METHODOLOGY
                )
            )
        elif reference[name][1] != text:
            problems.append(
                "{} line {}: {} differs from {} line {}\n"
                "         overview:    {}\n"
                "         methodology: {}".format(
                    OVERVIEW, number, name, METHODOLOGY, reference[name][0],
                    text, reference[name][1],
                )
            )
        else:
            print("  PASS {} (line {}, methodology line {})".format(
                name, number, reference[name][0]
            ))

    stated = {name for _, name, _ in overview}
    for name in REQUIRED:
        if name not in reference:
            problems.append("{}: no formula for {}".format(METHODOLOGY, name))
        if name not in stated:
            problems.append("{}: no formula for {}".format(OVERVIEW, name))

    for problem in problems:
        print("  FAIL {}".format(problem))
    print("RESULT: {}".format("FAIL" if problems else "PASS"))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
