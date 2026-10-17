#!/usr/bin/env python3
"""Checks that documents giving score ranges for the QRAMM maturity levels
state the ranges the toolkit's Scorecard labels use.

Usage:
    python3 -I scripts/check-maturity-thresholds.py [file ...]

The Scorecard in toolkit/QRAMM_Assessment_Toolkit.xlsx labels each dimension
score and the overall score (Scorecard!H9:H12 and H14) with an IFS formula of
the form

    IFS(E9="-", "Incomplete Assessment", E9>=3.5,"Advanced", ..., 1=1,"Basic")

This script reads those five formulas from the workbook, checks that they
use the same cut-offs, and turns the cut-offs into one score range for each
label. The top range ends at 4.0, the highest unadjusted score. With no file
arguments it checks the documents in DOCUMENTS; with file arguments it checks
those files instead (paths relative to the repository root, or absolute). For
each document:

    1. Every score range given for a maturity level is the range the
       Scorecard labels with that level.
    2. No score range is given for a level the Scorecard does not assign,
       such as Optimizing.
    3. The document gives a score range for each level the Scorecard assigns.

A score range is written as "below 1.5", "1.5 to below 2.5", "3.5 to 4.0",
"1.0 - 1.5", "Score 4.0" or "**4.0**", with one decimal place or more. It
counts for a level when it is on a line, outside code blocks, that names
exactly one of Basic, Developing, Established, Advanced and Optimizing. The
script uses the Python standard library only.

Exit status: 0 when the documents agree with the Scorecard, 1 when they do
not, 2 on a usage error.
"""

import os
import re
import sys
import xml.etree.ElementTree as ET
import zipfile

WORKBOOK = "toolkit/QRAMM_Assessment_Toolkit.xlsx"
SHEET = "Scorecard"
LABEL_CELLS = ["H9", "H10", "H11", "H12", "H14"]

DOCUMENTS = [
    "framework/scoring-methodology.md",
    "framework/maturity-levels.md",
    "docs/overview.md",
    "toolkit/toolkit-overview.md",
]

LEVELS = ["Basic", "Developing", "Established", "Advanced", "Optimizing"]

# Unadjusted scores run from 1 to 4, the answer scale in
# framework/scoring-methodology.md.
MIN_SCORE = 1.0
MAX_SCORE = 4.0

MAIN_NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
REL_NS = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
PKG_REL_NS = "http://schemas.openxmlformats.org/package/2006/relationships"

CUT_OFF = re.compile(r"[A-Z]+\d+>=(\d+(?:\.\d+)?),\s*\"([A-Za-z ]+)\"")
DEFAULT = re.compile(r"1=1,\s*\"([A-Za-z ]+)\"")

LEVEL_NAME = re.compile(r"\b(" + "|".join(LEVELS) + r")\b")
RANGE = re.compile(
    r"(?<![\d.])(?:"
    r"(?P<lo>\d+\.\d+) ?(?P<sep>to below|to|-) ?(?P<hi>\d+\.\d+)"
    r"|below (?P<below>\d+\.\d+)"
    r"|(?:score |\*\*)(?P<single>\d+\.\d+)(?! ?(?:to below|to|-) ?\d)"
    r")(?![\d.])",
    re.IGNORECASE,
)

USAGE = "usage: python3 -I scripts/check-maturity-thresholds.py [file ...]"


def ns(prefix, tag):
    return "{%s}%s" % (prefix, tag)


def sheet_path(book, name):
    """Path of the named sheet's XML part inside the workbook archive."""
    workbook = ET.fromstring(book.read("xl/workbook.xml"))
    rels = ET.fromstring(book.read("xl/_rels/workbook.xml.rels"))
    targets = {
        rel.get("Id"): rel.get("Target")
        for rel in rels.iter(ns(PKG_REL_NS, "Relationship"))
    }
    for sheet in workbook.iter(ns(MAIN_NS, "sheet")):
        if sheet.get("name") == name:
            target = targets[sheet.get(ns(REL_NS, "id"))]
            return target.lstrip("/") if target.startswith("/") else "xl/" + target
    return None


def label_formulas(path, problems):
    """Cell reference -> formula text for LABEL_CELLS on the Scorecard."""
    with zipfile.ZipFile(path) as book:
        part = sheet_path(book, SHEET)
        if part is None:
            problems.append("{}: no sheet named {}".format(WORKBOOK, SHEET))
            return {}
        sheet = ET.fromstring(book.read(part))
    found = {}
    for cell in sheet.iter(ns(MAIN_NS, "c")):
        if cell.get("r") in LABEL_CELLS:
            formula = cell.find(ns(MAIN_NS, "f"))
            if formula is not None and formula.text:
                found[cell.get("r")] = formula.text
    for ref in LABEL_CELLS:
        if ref not in found:
            problems.append("{}: {}!{} has no formula".format(WORKBOOK, SHEET, ref))
    return found


def parse_labels(ref, formula, problems):
    """(cut-offs as (score, label) pairs, default label), or None."""
    cut_offs = tuple((float(score), label) for score, label in CUT_OFF.findall(formula))
    default = DEFAULT.search(formula)
    if not cut_offs or default is None:
        problems.append(
            "{}: {}!{} is not an IFS of score cut-offs: {}".format(
                WORKBOOK, SHEET, ref, formula
            )
        )
        return None
    return cut_offs, default.group(1)


def scorecard_bands(path, problems):
    """Level -> (lo, lo inclusive, hi, hi inclusive) from the Scorecard."""
    parsed = {}
    for ref, formula in label_formulas(path, problems).items():
        labels = parse_labels(ref, formula, problems)
        if labels is not None:
            parsed[ref] = labels
    if not parsed:
        return {}
    first_ref = min(parsed, key=LABEL_CELLS.index)
    for ref in sorted(parsed, key=LABEL_CELLS.index):
        if parsed[ref] != parsed[first_ref]:
            problems.append(
                "{}: {}!{} and {}!{} use different cut-offs".format(
                    WORKBOOK, SHEET, first_ref, SHEET, ref
                )
            )
    cut_offs, default = parsed[first_ref]
    ordered = sorted(cut_offs)
    bands = {default: (MIN_SCORE, True, ordered[0][0], False)}
    for index, (score, label) in enumerate(ordered):
        if index + 1 < len(ordered):
            bands[label] = (score, True, ordered[index + 1][0], False)
        else:
            bands[label] = (score, True, MAX_SCORE, True)
    for label in bands:
        if label not in LEVELS:
            problems.append(
                "{}: {} label '{}' is not a QRAMM maturity level".format(
                    WORKBOOK, SHEET, label
                )
            )
    return bands


def describe(band):
    lo, lo_inclusive, hi, hi_inclusive = band
    if lo == hi and lo_inclusive and hi_inclusive:
        return "{:.1f}".format(lo)
    if not hi_inclusive:
        if lo == MIN_SCORE and lo_inclusive:
            return "below {:.1f}".format(hi)
        return "{:.1f} to below {:.1f}".format(lo, hi)
    return "{:.1f} to {:.1f}".format(lo, hi)


def to_band(match):
    if match.group("lo"):
        lo, hi = float(match.group("lo")), float(match.group("hi"))
        below = match.group("sep").lower() == "to below"
        return (lo, True, hi, not below)
    if match.group("below"):
        return (MIN_SCORE, True, float(match.group("below")), False)
    value = float(match.group("single"))
    return (value, True, value, True)


def stated_ranges(lines):
    """List of (line number, level, band) outside fenced code blocks."""
    found = []
    fenced = False
    for number, line in enumerate(lines, 1):
        if line.lstrip().startswith("```"):
            fenced = not fenced
            continue
        if fenced:
            continue
        names = set(LEVEL_NAME.findall(line))
        if len(names) != 1:
            continue
        level = names.pop()
        for match in RANGE.finditer(line):
            found.append((number, level, to_band(match)))
    return found


def check_document(path, lines, bands, problems):
    stated = set()
    for number, level, band in stated_ranges(lines):
        stated.add(level)
        if level not in bands:
            problems.append(
                "{} line {}: {} is given the score range {}, but the {} labels "
                "no dimension or overall score {} ({}!H9:H12 and H14)".format(
                    path, number, level, describe(band), SHEET, level, SHEET,
                )
            )
        elif band != bands[level]:
            problems.append(
                "{} line {}: {} is {} here, but on the {} it is {}".format(
                    path, number, level, describe(band), SHEET,
                    describe(bands[level]),
                )
            )
        else:
            print("  PASS line {}: {} {}".format(number, level, describe(band)))
    for level in LEVELS:
        if level in bands and level not in stated:
            problems.append("{}: no score range for {}".format(path, level))


def main(argv):
    if any(arg.startswith("-") for arg in argv):
        print(USAGE, file=sys.stderr)
        return 2
    root = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
    documents = argv or DOCUMENTS

    problems = []
    bands = scorecard_bands(os.path.join(root, WORKBOOK), problems)
    if bands:
        print("== {} {}!H9:H12 and H14".format(WORKBOOK, SHEET))
        for level in LEVELS:
            if level in bands:
                print("  {} {}".format(level, describe(bands[level])))

    if bands:
        for path in documents:
            print("== {} against the {}".format(path, SHEET))
            try:
                with open(os.path.join(root, path), encoding="utf-8") as fh:
                    lines = fh.read().splitlines()
            except OSError as error:
                problems.append("{}: cannot read ({})".format(path, error.strerror))
                continue
            check_document(path, lines, bands, problems)

    for problem in problems:
        print("  FAIL {}".format(problem))
    print("RESULT: {}".format("FAIL" if problems else "PASS"))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
