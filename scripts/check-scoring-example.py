#!/usr/bin/env python3
"""Checks the worked scoring example in framework/scoring-methodology.md.

Usage:
    python3 -I scripts/check-scoring-example.py

The methodology document carries a worked example taken from the sample
assessment, toolkit/Sample_Assessment.xlsx. The example is the fenced block
whose label (the nearest non-blank line above the opening fence) names that
file. This script reads the values the workbook saved for the defined names
below and checks that the example shows the same values, on the lines that
start with the matching labels:

    CVI_1_Score        "Practice 1.1 score"
    CVI_2_Score        "Practice 1.2 score"
    CVI_3_Score        "Practice 1.3 score"
    CVI_Score          "CVI score"
    ProfileMultiplier  "Profile multiplier"

The value on a labelled line is the first number after its last "=". The
check fails for a number with a Unicode decimal digit other than 0 to 9,
such as U+0662 (ARABIC-INDIC DIGIT TWO). The workbook values are the cached
results Excel stored when the file was last calculated; the script does not
recompute any formula. It uses the Python standard library only.

Exit status: 0 when the example matches the workbook, 1 when it does not, 2 on
a usage error. --help (or -h) prints the usage line and this text on stderr
and exits 2. The script takes no other argument: given one, it names each
argument on stderr on a line of its own, "unknown option: --verbose" for one
that starts with "-" and "unexpected argument: README.md" for any other,
then prints "this checker takes no arguments" and the usage line, and exits
2.
"""

import math
import os
import re
import sys
import xml.etree.ElementTree as ET
import zipfile

DOC = "framework/scoring-methodology.md"
WORKBOOK = "toolkit/Sample_Assessment.xlsx"

# Defined name in the workbook -> label of the line that shows it in the doc.
EXPECTED = [
    ("CVI_1_Score", "Practice 1.1 score"),
    ("CVI_2_Score", "Practice 1.2 score"),
    ("CVI_3_Score", "Practice 1.3 score"),
    ("CVI_Score", "CVI score"),
    ("ProfileMultiplier", "Profile multiplier"),
]

MAIN_NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
REL_NS = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
PKG_REL_NS = "http://schemas.openxmlformats.org/package/2006/relationships"

# \d, not [0-9]: in a str pattern \d matches every Unicode decimal digit,
# such as U+0662 (ARABIC-INDIC DIGIT TWO), so NUMBER reads a number written
# with one of them whole, and shown_value() refuses it. With [0-9], U+0662
# followed by 2.56 would be read as 2.56.
NUMBER = re.compile(r"-?\d+(?:\.\d+)?")
TOLERANCE = 1e-9

USAGE = "usage: python3 -I scripts/check-scoring-example.py"


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
    """Workbook-scoped defined name -> (sheet name, cell reference)."""
    result = {}
    for node in workbook.iter(ns(MAIN_NS, "definedName")):
        if node.get("localSheetId") is not None:
            continue
        match = re.fullmatch(r"'?(.+?)'?!\$?([A-Z]+)\$?(\d+)", (node.text or "").strip())
        if match:
            sheet = match.group(1).replace("''", "'")
            result[node.get("name")] = (sheet, match.group(2) + match.group(3))
    return result


def ascii_float(text):
    """float(text), except that text with a character outside ASCII or with
    an underscore raises ValueError, as float() does for text such as "x".
    The workbook writes its numbers with the digits 0 to 9. float() also
    reads every Unicode decimal digit, such as U+0662 (ARABIC-INDIC DIGIT
    TWO) as 2, and allows an underscore between two digits, so it reads
    2.5_6 as 2.56."""
    if not text.isascii() or "_" in text:
        raise ValueError("could not convert string to float: {!r}".format(text))
    return float(text)


def cached_number(node):
    """Number the c element node stores, or None when node is None or the
    cell stores no number: it has no v element or an empty one, its t
    attribute is s, str, e or inlineStr, ascii_float() cannot read the text
    of its v element, such as "x" or "2.5_6", or ascii_float() reads that
    text as a value that is not finite, as it reads nan as a NaN and inf as
    an infinity."""
    value = None if node is None else node.find(ns(MAIN_NS, "v"))
    if value is None or value.text is None or node.get("t") in ("s", "str", "e", "inlineStr"):
        return None
    try:
        number = ascii_float(value.text)
    except ValueError:
        return None
    # main() passes a shown number unless abs(shown - value) > TOLERANCE,
    # which is false when value is a NaN, or an infinity and float() reads
    # the shown number, such as 1 followed by 400 zeros, as the same
    # infinity.
    return number if math.isfinite(number) else None


def cached_values(path, names):
    """Defined name -> cached numeric value, or an error message string."""
    with zipfile.ZipFile(path) as book:
        workbook, paths = sheet_paths(book)
        refs = defined_names(workbook)
        parsed = {}
        values = {}
        for name in names:
            if name not in refs:
                values[name] = "defined name not found in the workbook"
                continue
            sheet, cell = refs[name]
            if sheet not in paths:
                values[name] = "sheet '{}' not found in the workbook".format(sheet)
                continue
            if sheet not in parsed:
                parsed[sheet] = ET.fromstring(book.read(paths[sheet]))
            node = None
            for candidate in parsed[sheet].iter(ns(MAIN_NS, "c")):
                if candidate.get("r") == cell:
                    node = candidate
                    break
            number = cached_number(node)
            if number is None:
                values[name] = "{}!{} has no cached number".format(sheet, cell)
                continue
            values[name] = number
    return values


def labelled_blocks(lines, label):
    """Fenced blocks whose nearest non-blank line above the fence names label."""
    blocks = []
    fenced = False
    current = None
    previous = ""
    for number, line in enumerate(lines, 1):
        if line.lstrip().startswith("```"):
            if not fenced:
                fenced = True
                current = (number, label in previous, [])
            else:
                fenced = False
                if current[1]:
                    blocks.append((current[0], current[2]))
                current = None
            previous = line
            continue
        if fenced:
            current[2].append((number, line))
        elif line.strip():
            previous = line
    return blocks


def shown_value(block, label):
    """(line number, number text) for the one line that starts with label."""
    hits = [
        (number, line)
        for number, line in block
        if re.match(re.escape(label) + r"\b", line.strip())
    ]
    if len(hits) != 1:
        return None, "{} lines start with '{}', expected 1".format(len(hits), label)
    number, line = hits[0]
    if "=" not in line:
        return number, "line {}: no '=' on the '{}' line".format(number, label)
    found = NUMBER.search(line.rsplit("=", 1)[1])
    if not found:
        return number, "line {}: no number after the last '='".format(number)
    # float() reads every Unicode decimal digit, so main() would read U+0662,
    # a period, U+0665 and U+0666 (ARABIC-INDIC DIGIT TWO, FIVE and SIX) as
    # 2.56. !a writes each such digit as a backslash escape, as ascii() does.
    if not found.group(0).isascii():
        return number, (
            "line {}: the number after the last '=' is {!a}, which has a digit "
            "other than 0 to 9".format(number, found.group(0))
        )
    return number, found.group(0)


def main(argv):
    if "--help" in argv or "-h" in argv:
        print(USAGE, file=sys.stderr)
        # __doc__ is None when python3 -OO removes docstrings.
        if __doc__:
            print(file=sys.stderr)
            print(__doc__.strip(), file=sys.stderr)
        return 2
    if argv:
        for arg in argv:
            if arg.startswith("-"):
                print("unknown option: {}".format(arg), file=sys.stderr)
            else:
                print("unexpected argument: {}".format(arg or "''"), file=sys.stderr)
        print("this checker takes no arguments", file=sys.stderr)
        print(USAGE, file=sys.stderr)
        return 2
    root = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
    doc_path = os.path.join(root, DOC)
    workbook_path = os.path.join(root, WORKBOOK)

    values = cached_values(workbook_path, [name for name, _ in EXPECTED])
    with open(doc_path, encoding="utf-8") as fh:
        lines = fh.read().splitlines()

    print("== {} against {}".format(DOC, WORKBOOK))
    problems = []
    label = os.path.basename(WORKBOOK)
    blocks = labelled_blocks(lines, label)
    if len(blocks) != 1:
        problems.append(
            "{} fenced blocks are labelled with {}, expected 1".format(len(blocks), label)
        )
    else:
        start, block = blocks[0]
        print("  example block opens at line {}".format(start))
        for name, line_label in EXPECTED:
            value = values[name]
            if isinstance(value, str):
                problems.append("{}: {}".format(name, value))
                continue
            expected = "{:.10g}".format(value)
            number, shown = shown_value(block, line_label)
            if not NUMBER.fullmatch(shown):
                problems.append("{}: {}".format(name, shown))
            elif abs(float(shown) - value) > TOLERANCE:
                problems.append(
                    "{}: line {} shows {}, the workbook has {}".format(
                        name, number, shown, expected
                    )
                )
            else:
                print("  PASS {} = {} (line {})".format(name, expected, number))

    for problem in problems:
        print("  FAIL {}".format(problem))
    print("RESULT: {}".format("FAIL" if problems else "PASS"))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
