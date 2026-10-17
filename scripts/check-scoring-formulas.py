#!/usr/bin/env python3
"""Checks that documents describing QRAMM scores state the same score formulas
and answer scale as the scoring methodology.

Usage:
    python3 -I scripts/check-scoring-formulas.py [file ...]

framework/scoring-methodology.md describes how the toolkit workbook calculates
QRAMM scores, and scripts/check-scoring-example.py checks its worked example
against the sample workbook. The documents in DOCUMENTS repeat the practice,
dimension and overall score formulas. With no file arguments this script
checks each of them; with file arguments it checks those files instead (paths
relative to the repository root, or absolute). For each document:

    1. Every score formula has a formula with the same left side in the
       methodology, and the two have the same text.
    2. The document states each formula named in REQUIRED.
    3. Every "N-point scale" names the same N as the methodology, and every
       range written as "scored from A to B", "scores from A-B" or similar
       runs from 1 to that N.

A score formula is a fenced code block whose first line starts with
"<name> Score =", or a line outside code blocks written in bold as
"**<name> Score = ...**". Formula text is compared with runs of whitespace
collapsed to one space. The script uses the Python standard library only.

Exit status: 0 when the documents agree, 1 when they do not, 2 on a usage
error. An empty file argument fails with "no file name given". --help (or -h)
prints the usage line and this text on stderr and exits 2.
"""

import os
import re
import sys

METHODOLOGY = "framework/scoring-methodology.md"

DOCUMENTS = [
    "framework/qramm-overview.md",
    "framework/full-assessment.md",
    "toolkit/assessment/full-assessment.md",
    "docs/overview.md",
    "implementation/getting-started.md",
]

REQUIRED = ["Practice Score", "Dimension Score", "Overall Score"]

LEFT_SIDE = re.compile(r"^([A-Z][A-Za-z ]*Score) =")
BOLD_LINE = re.compile(r"^\*\*(.+)\*\*$")
SCALE = re.compile(r"(\d+)-point scale", re.IGNORECASE)
SCORE_RANGE = re.compile(
    r"\bscor(?:e|es|ed)(?: from)? (\d+) ?(?:-|to) ?(\d+)(?!\.\d|\d)", re.IGNORECASE
)

USAGE = "usage: python3 -I scripts/check-scoring-formulas.py [file ...]"


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


def reference_formulas(methodology, problems):
    """Left side -> (line number, formula text) from the methodology."""
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
    return reference


def reference_scale(lines, problems):
    """The N of the methodology's "N-point scale", or None."""
    sizes = {int(m.group(1)) for line in lines for m in SCALE.finditer(line)}
    if len(sizes) != 1:
        problems.append(
            "{}: expected one answer scale, found {}".format(
                METHODOLOGY, sorted(sizes) or "none"
            )
        )
        return None
    return sizes.pop()


def check_document(path, lines, reference, scale, problems):
    found = formulas(lines)
    for number, name, text in found:
        if name not in reference:
            problems.append(
                "{} line {}: {} has no formula in {}".format(
                    path, number, name, METHODOLOGY
                )
            )
        elif reference[name][1] != text:
            problems.append(
                "{} line {}: {} differs from {} line {}\n"
                "         document:    {}\n"
                "         methodology: {}".format(
                    path, number, name, METHODOLOGY, reference[name][0],
                    text, reference[name][1],
                )
            )
        else:
            print("  PASS {} (line {}, methodology line {})".format(
                name, number, reference[name][0]
            ))

    stated = {name for _, name, _ in found}
    for name in REQUIRED:
        if name not in stated:
            problems.append("{}: no formula for {}".format(path, name))

    if scale is None:
        return
    for number, line in enumerate(lines, 1):
        for match in SCALE.finditer(line):
            if int(match.group(1)) != scale:
                problems.append(
                    "{} line {}: \"{}\" but {} uses a {}-point scale".format(
                        path, number, match.group(0), METHODOLOGY, scale
                    )
                )
        for match in SCORE_RANGE.finditer(line):
            if (int(match.group(1)), int(match.group(2))) != (1, scale):
                problems.append(
                    "{} line {}: \"{}\" but answers in {} score 1 to {}".format(
                        path, number, match.group(0), METHODOLOGY, scale
                    )
                )


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
    methodology_lines = read_lines(root, METHODOLOGY)
    reference = reference_formulas(formulas(methodology_lines), problems)
    scale = reference_scale(methodology_lines, problems)
    for name in REQUIRED:
        if name not in reference:
            problems.append("{}: no formula for {}".format(METHODOLOGY, name))

    for path in documents:
        print("== {} against {}".format(path or "''", METHODOLOGY))
        if not path:
            problems.append("'': no file name given")
            continue
        try:
            lines = read_lines(root, path)
        except OSError as error:
            problems.append("{}: cannot read ({})".format(path, error.strerror))
            continue
        check_document(path, lines, reference, scale, problems)

    for problem in problems:
        print("  FAIL {}".format(problem))
    print("RESULT: {}".format("FAIL" if problems else "PASS"))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
