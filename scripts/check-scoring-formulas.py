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

Exit status: 0 when the documents agree, 1 when they do not or a file cannot
be read, 2 on a usage error. An empty file argument fails with "no file name
given", and a document whose bytes are not UTF-8 fails with "not UTF-8
text". A file name is printed with each byte that the file system encoding
cannot decode, and each character that the encoding of stdout cannot encode,
as a backslash escape, such as \\xff for the byte 0xff and \\u65e5 for the
character U+65E5. A FAIL line, such as one that quotes a formula, is printed
with each character that the encoding of stdout cannot encode as a backslash
escape too, such as \\u2192 for U+2192. --help (or -h) prints the usage line
and this text on stderr and exits 2.
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


def check_document(document, lines, reference, scale, problems):
    """document is the document's file name as printed."""
    found = formulas(lines)
    for number, name, text in found:
        if name not in reference:
            problems.append(
                "{} line {}: {} has no formula in {}".format(
                    document, number, name, METHODOLOGY
                )
            )
        elif reference[name][1] != text:
            problems.append(
                "{} line {}: {} differs from {} line {}\n"
                "         document:    {}\n"
                "         methodology: {}".format(
                    document, number, name, METHODOLOGY, reference[name][0],
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
            problems.append("{}: no formula for {}".format(document, name))

    if scale is None:
        return
    for number, line in enumerate(lines, 1):
        for match in SCALE.finditer(line):
            if int(match.group(1)) != scale:
                problems.append(
                    "{} line {}: \"{}\" but {} uses a {}-point scale".format(
                        document, number, match.group(0), METHODOLOGY, scale
                    )
                )
        for match in SCORE_RANGE.finditer(line):
            if (int(match.group(1)), int(match.group(2))) != (1, scale):
                problems.append(
                    "{} line {}: \"{}\" but answers in {} score 1 to {}".format(
                        document, number, match.group(0), METHODOLOGY, scale
                    )
                )


def printable(text):
    """text with each character the encoding of stdout cannot encode written
    as a backslash escape, such as \\u2192 for U+2192. Under en_US.ISO8859-1
    on macOS, the encoding of stdout is ISO-8859-1, so text quoted from a
    document, such as a formula that holds U+2192, can hold a character that
    print() cannot encode."""
    # sys.stdout is None when file descriptor 1 is closed, and print() then
    # writes nothing.
    encoding = getattr(sys.stdout, "encoding", None)
    if encoding is None:
        return text
    return text.encode(encoding, "backslashreplace").decode(encoding)


def shown(path):
    """path in a form stdout can encode: the bytes os.fsencode gives back,
    decoded with each byte the file system encoding cannot decode written as
    a backslash escape, such as \\xff for the byte 0xff, then with each
    character the encoding of stdout cannot encode written as a backslash
    escape, such as \\u65e5 for U+65E5. Python holds such a byte of a
    command-line argument as a lone surrogate, which print() cannot encode
    under a locale such as en_US.UTF-8. Under en_US.ISO8859-1 on macOS, the
    file system encoding is UTF-8 and the encoding of stdout is ISO-8859-1,
    so a file name that is valid UTF-8 can hold a character, such as U+65E5,
    that print() cannot encode."""
    name = os.fsencode(path).decode(sys.getfilesystemencoding(), "backslashreplace")
    return printable(name)


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
        document = shown(path)
        print("== {} against {}".format(document or "''", METHODOLOGY))
        if not path:
            problems.append("'': no file name given")
            continue
        try:
            lines = read_lines(root, path)
        except OSError as error:
            problems.append("{}: cannot read ({})".format(document, error.strerror))
            continue
        except UnicodeDecodeError:
            # A document whose bytes are not UTF-8.
            problems.append("{}: cannot read (not UTF-8 text)".format(document))
            continue
        check_document(document, lines, reference, scale, problems)

    for problem in problems:
        # A problem can quote a document's text, such as a formula.
        print(printable("  FAIL {}".format(problem)))
    print("RESULT: {}".format("FAIL" if problems else "PASS"))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
