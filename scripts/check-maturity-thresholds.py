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
those files instead (paths relative to the repository root, or absolute). A
document is a text file, or a workbook (a path that ends in .xlsx) whose text
cells, the cells of every sheet that hold a shared or inline string, are
checked one cell at a time. For each document:

    1. Every score range given for a maturity level is the range the
       Scorecard labels with that level.
    2. No score range is given for a level the Scorecard does not assign,
       such as Optimizing.
    3. The document gives a score range for each level the Scorecard assigns.

A score range is written as "below 1.5", "1.5 to below 2.5", "3.5 to 4.0",
"1.0 - 1.5", "Score 4.0", "**4.0**" or "4.0: Optimizing" (a number, a colon
and a level name), with one decimal place or more. An en dash may take the
place of the hyphen. A score range counts for a level when it is on a line,
outside code blocks, that names exactly one of Basic, Developing,
Established, Advanced and Optimizing; in a workbook, each line of a cell's
text is a line.

A workbook can also have a chart titled "Maturity Distribution", as the
Scorecard of each toolkit workbook does. Each category of the chart is a cell
that holds a label, and each value is a cell that holds a formula of the form

    COUNTIFS(PracticeScoreOutcomes,">=1.5",PracticeScoreOutcomes,"<2.5")/12

or COUNTIF with one criterion, which counts the practice scores in one
range. For each such chart:

    4. Every category labelled with a maturity level counts the range the
       Scorecard labels with that level.
    5. No category counts a level the Scorecard does not assign.
    6. The chart has a category for each level the Scorecard assigns.

A category whose formula counts only "-", the practices with no score, is
not checked unless its label is a maturity level. A value whose formula is
longer than 8,192 characters, the most Excel allows in a formula, fails with
"longer than the 8,192 Excel allows", and its criteria are not read. A
cut-off of a Scorecard formula, a number of a score range or of a chart
value criterion, or a row of a chart category or value range, with a
Unicode decimal digit other than 0 to 9, such as U+0661 (ARABIC-INDIC DIGIT
ONE), fails with "has a digit other than 0 to 9". The script uses the
Python standard library only.

Exit status: 0 when the documents agree with the Scorecard, 1 when they do
not or a file cannot be read, 2 on a usage error. An empty file argument
fails with "no file name given", a workbook that cannot be read fails with
"cannot read", and a text document whose bytes are not UTF-8 fails with
"not UTF-8 text". A file name is printed with each byte that the file system
encoding cannot decode, and each character that the encoding of stdout
cannot encode, as a backslash escape, such as \\xff for the byte 0xff and
\\u65e5 for the character U+65E5. --help (or -h) prints the usage line and
this text on stderr and exits 2. Any other argument that starts with "-",
such as --verbose or --, is an unknown option: each one is named on stderr
on a line of its own, such as "unknown option: --verbose", before the usage
line, and the exit status is 2.
"""

import os
import re
import sys
import xml.etree.ElementTree as ET
import xml.parsers.expat
import zipfile

WORKBOOK = "toolkit/QRAMM_Assessment_Toolkit.xlsx"
SHEET = "Scorecard"
LABEL_CELLS = ["H9", "H10", "H11", "H12", "H14"]
CHART_TITLE = "Maturity Distribution"

DOCUMENTS = [
    "framework/scoring-methodology.md",
    "framework/maturity-levels.md",
    "docs/overview.md",
    "toolkit/toolkit-overview.md",
    "toolkit/QRAMM_Assessment_Toolkit.xlsx",
    "toolkit/Sample_Assessment.xlsx",
]

LEVELS = ["Basic", "Developing", "Established", "Advanced", "Optimizing"]

# Unadjusted scores run from 1 to 4, the answer scale in
# framework/scoring-methodology.md.
MIN_SCORE = 1.0
MAX_SCORE = 4.0

MAIN_NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
REL_NS = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
PKG_REL_NS = "http://schemas.openxmlformats.org/package/2006/relationships"
CHART_NS = "http://schemas.openxmlformats.org/drawingml/2006/chart"
DRAWING_NS = "http://schemas.openxmlformats.org/drawingml/2006/main"

# A cut-off of a Scorecard formula, such as E9>=3.5,"Advanced". \d, not
# [0-9], for the cut-off, as in RANGE and COMPARISON: a cut-off written with
# a digit other than 0 to 9 is matched whole, and odd_number() refuses it.
CUT_OFF = re.compile(r"[A-Z]+\d+>=(\d+(?:\.\d+)?),\s*\"([A-Za-z ]+)\"")
DEFAULT = re.compile(r"1=1,\s*\"([A-Za-z ]+)\"")

LEVEL_NAME = re.compile(r"\b(" + "|".join(LEVELS) + r")\b")
# \d, not [0-9], in RANGE and COMPARISON: in a str pattern \d matches every
# Unicode decimal digit, such as U+0661 (ARABIC-INDIC DIGIT ONE), so a number
# written with one of them is matched whole, and odd_number() refuses it.
# With [0-9], U+0661 followed by 1.5 would be read as 1.5.
RANGE = re.compile(
    r"(?<![\d.])(?:"
    r"(?P<lo>\d+\.\d+) ?(?P<sep>to below|to|-|\N{EN DASH}) ?(?P<hi>\d+\.\d+)"
    r"|below (?P<below>\d+\.\d+)"
    r"|(?:score |\*\*)(?P<single>\d+\.\d+)(?! ?(?:to below|to|-|\N{EN DASH}) ?\d)"
    r"|(?P<named>\d+\.\d+)(?=: ?(?:" + "|".join(LEVELS) + r")\b)"
    r")(?!\.\d|\d)",
    re.IGNORECASE,
)

# A shared string index. [0-9], not \d: in a str pattern \d also matches the
# other Unicode decimal digits, such as U+0661 (ARABIC-INDIC DIGIT ONE), and
# int() reads them too.
INDEX = re.compile(r"[0-9]+")

CHART_PART = re.compile(r"xl/charts/chart\d+\.xml")
# A chart series range, Sheet!$A$1:$A$9 or 'Sheet name'!$A$1:$A$9. \d, not
# [0-9], for the rows: a row written with a digit other than 0 to 9 is
# matched whole, and odd_number() refuses it.
SERIES_RANGE = re.compile(
    r"(?:'((?:[^']|'')+)'|([^'!]+))!\$?([A-Z]+)\$?(\d+)(?::\$?([A-Z]+)\$?(\d+))?"
)
# COUNTIF or COUNTIFS of one range against one or more criteria, divided by a
# whole number, one range-and-criterion pair of its arguments, and a criterion
# that compares with a number. In CRITERION and COMPARISON each quantifier is
# followed by a character it cannot match or by the end of the text, so no two
# quantifiers can match the same characters. In a pattern such as
# \s*([^,"]+?)\s*, where three can match the same spaces, the time a failed
# match on a run of spaces takes grows with the cube of the length of the run.
COUNT = re.compile(r"\s*COUNTIFS?\((?P<arguments>.*)\)\s*/\s*\d+\s*", re.IGNORECASE)
CRITERION = re.compile(r'([^,"]+),\s*"([^"]*)"\s*(?:,|$)')
COMPARISON = re.compile(r"\s*(?:(<=|>=|<|>|=)\s*)?(\d+(?:\.\d+)?)\s*")

# Excel limits the contents of a formula to 8,192 characters.
MAX_FORMULA_LENGTH = 8192

USAGE = "usage: python3 -I scripts/check-maturity-thresholds.py [file ...]"


class DoctypeError(ET.ParseError):
    """The error parse_xml raises for a document type declaration."""


class _RootElement(Exception):
    """Ends parse_xml's scan at the root element's start tag."""


def parse_xml(data):
    """The root element of the XML document data, as ET.fromstring(data)
    gives it, except that data with a document type declaration, such as
    <!DOCTYPE r [<!ENTITY e "FAKE">]>, raises DoctypeError, a subclass of
    ET.ParseError, before ElementTree reads it. A workbook part carries no
    document type declaration. The entities one declares are expanded in
    memory by an expat without a limit on entity expansion, such as expat
    2.2.8 in the macOS system Python 3.9.6. A scan with expat that stops at
    the root element's start tag looks for the declaration first; XML that
    is not well-formed before that tag is left for ET.fromstring to report."""
    scan = xml.parsers.expat.ParserCreate()

    def doctype(*_):
        position = (scan.CurrentLineNumber, scan.CurrentColumnNumber)
        error = DoctypeError(
            "document type declaration: line {}, column {}".format(*position)
        )
        error.position = position
        raise error

    def root(*_):
        raise _RootElement

    scan.StartDoctypeDeclHandler = doctype
    scan.StartElementHandler = root
    try:
        scan.Parse(data, True)
    except (_RootElement, xml.parsers.expat.ExpatError):
        pass
    return ET.fromstring(data)


def ns(prefix, tag):
    return "{%s}%s" % (prefix, tag)


def sheet_paths(book):
    """Sheet name -> path of its XML part inside the workbook archive."""
    workbook = parse_xml(book.read("xl/workbook.xml"))
    rels = parse_xml(book.read("xl/_rels/workbook.xml.rels"))
    targets = {
        rel.get("Id"): rel.get("Target")
        for rel in rels.iter(ns(PKG_REL_NS, "Relationship"))
    }
    paths = {}
    for sheet in workbook.iter(ns(MAIN_NS, "sheet")):
        target = targets[sheet.get(ns(REL_NS, "id"))]
        if target.startswith("/"):
            paths[sheet.get("name")] = target.lstrip("/")
        else:
            paths[sheet.get("name")] = "xl/" + target
    return paths


def label_formulas(path, problems):
    """Cell reference -> formula text for LABEL_CELLS on the Scorecard."""
    with zipfile.ZipFile(path) as book:
        part = sheet_paths(book).get(SHEET)
        if part is None:
            problems.append("{}: no sheet named {}".format(WORKBOOK, SHEET))
            return {}
        sheet = parse_xml(book.read(part))
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
    """(cut-offs as (score, label) pairs, default label), or None. A cut-off
    with a digit other than 0 to 9 adds a problem, and the result is then
    None."""
    found = CUT_OFF.findall(formula)
    default = DEFAULT.search(formula)
    if not found or default is None:
        problems.append(
            "{}: {}!{} is not an IFS of score cut-offs: {}".format(
                WORKBOOK, SHEET, ref, formula
            )
        )
        return None
    odd = [(score, label) for score, label in found if odd_number([score]) is not None]
    for score, label in odd:
        problems.append(
            "{}: {}!{}: the cut-off for {}: {}".format(
                WORKBOOK, SHEET, ref, label, number_problem(score)
            )
        )
    if odd:
        return None
    cut_offs = tuple((float(score), label) for score, label in found)
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
    start = "{:.1f}".format(lo) if lo_inclusive else "above {:.1f}".format(lo)
    if not hi_inclusive:
        if lo == MIN_SCORE and lo_inclusive:
            return "below {:.1f}".format(hi)
        return "{} to below {:.1f}".format(start, hi)
    return "{} to {:.1f}".format(start, hi)


def odd_number(numbers):
    """The first of numbers, the texts of the numbers that RANGE or
    COMPARISON matched, with a digit other than 0 to 9, or None. float()
    reads every Unicode decimal digit, so it would read U+0661, a period and
    U+0665 (ARABIC-INDIC DIGIT ONE and FIVE) as 1.5."""
    for number in numbers:
        if number is not None and not number.isascii():
            return number
    return None


def number_problem(number):
    """The reason a FAIL line gives for the number text odd_number() found.
    !a writes each digit other than 0 to 9 as a backslash escape, as ascii()
    does."""
    return "the number {!a} has a digit other than 0 to 9".format(number)


def to_band(match):
    """(lo, lo inclusive, hi, hi inclusive) of a RANGE match, or the reason
    a FAIL line gives when one of its numbers has a digit other than 0 to
    9."""
    odd = odd_number(
        match.group(name) for name in ("lo", "hi", "below", "single", "named")
    )
    if odd is not None:
        return number_problem(odd)
    if match.group("lo"):
        lo, hi = float(match.group("lo")), float(match.group("hi"))
        below = match.group("sep").lower() == "to below"
        return (lo, True, hi, not below)
    if match.group("below"):
        return (MIN_SCORE, True, float(match.group("below")), False)
    value = float(match.group("single") or match.group("named"))
    return (value, True, value, True)


def stated_ranges(lines):
    """List of (line number, level, band) outside fenced code blocks. band
    is the reason a FAIL line gives, a str, when a number of the range has a
    digit other than 0 to 9."""
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


def check_document(name, parts, bands, problems):
    """name is the document's file name as printed. parts is a list of
    (place, lines): place is "" for a text file and Sheet!Cell for each text
    cell of a workbook."""
    stated = set()
    for place, lines in parts:
        where = place + " " if place else ""
        for number, level, band in stated_ranges(lines):
            stated.add(level)
            if isinstance(band, str):
                problems.append(
                    "{} {}line {}: the score range for {}: {}".format(
                        name, where, number, level, band
                    )
                )
            elif level not in bands:
                problems.append(
                    "{} {}line {}: {} is given the score range {}, but the {} labels "
                    "no dimension or overall score {} ({}!H9:H12 and H14)".format(
                        name, where, number, level, describe(band), SHEET, level,
                        SHEET,
                    )
                )
            elif band != bands[level]:
                problems.append(
                    "{} {}line {}: {} is {} here, but on the {} it is {}".format(
                        name, where, number, level, describe(band), SHEET,
                        describe(bands[level]),
                    )
                )
            else:
                print("  PASS {}line {}: {} {}".format(
                    where, number, level, describe(band)
                ))
    for level in LEVELS:
        if level in bands and level not in stated:
            problems.append("{}: no score range for {}".format(name, level))


def shared_strings(book):
    """The workbook's shared string table, as a list of strings."""
    if "xl/sharedStrings.xml" not in book.namelist():
        return []
    table = parse_xml(book.read("xl/sharedStrings.xml"))
    strings = []
    for item in table.iter(ns(MAIN_NS, "si")):
        runs = item.findall(ns(MAIN_NS, "t"))
        runs += item.findall("{}/{}".format(ns(MAIN_NS, "r"), ns(MAIN_NS, "t")))
        strings.append("".join(run.text or "" for run in runs))
    return strings


def cell_text(cell, strings):
    """Text of a cell: its shared or inline string, or its stored value.
    Raises IndexError for a shared string index past the end of strings,
    and ValueError for one that is not one or more of the digits 0 to 9.
    int() strips whitespace from the start and end of text, reads a leading
    sign, allows an underscore between two digits and reads the other
    Unicode decimal digits, so it reads " 1820", +1820, 18_20 and 1820
    written with ARABIC-INDIC digits as 1820, and -1 as the index of the
    last shared string."""
    if cell is None:
        return None
    if cell.get("t") == "inlineStr":
        return "".join(t.text or "" for t in cell.iter(ns(MAIN_NS, "t")))
    value = cell.find(ns(MAIN_NS, "v"))
    if value is None or value.text is None:
        return None
    if cell.get("t") == "s":
        if not INDEX.fullmatch(value.text):
            raise ValueError(
                "shared string index {!r} is not one or more of the digits 0 "
                "to 9".format(value.text)
            )
        return strings[int(value.text)]
    return value.text


def range_cells(reference):
    """(sheet name, cell references) of a range in one column, None for
    another range, or the reason a FAIL line gives, a str, when the number
    of one of its rows has a digit other than 0 to 9. int() reads every
    Unicode decimal digit, so it would read U+0662 U+0661 (ARABIC-INDIC
    DIGIT TWO and ONE) as 21."""
    match = SERIES_RANGE.fullmatch(reference.strip())
    if match is None or match.group(5) not in (None, match.group(3)):
        return None
    odd = odd_number([match.group(4), match.group(6)])
    if odd is not None:
        return number_problem(odd)
    sheet = (match.group(1) or "").replace("''", "'") or match.group(2)
    first_row = int(match.group(4))
    last_row = int(match.group(6) or match.group(4))
    return sheet, [
        "{}{}".format(match.group(3), row) for row in range(first_row, last_row + 1)
    ]


def series_categories(series, cells, strings):
    """(category range, value range, categories) of a chart series.
    categories is a list of (label place, label, value place, formula), or a
    string that says why the ranges cannot be read."""
    references = []
    for part in ("cat", "val"):
        found = series.find("c:{}//c:f".format(part), {"c": CHART_NS})
        references.append((found.text or "").strip() if found is not None else "")
    category_range, value_range = references
    labels, values = range_cells(category_range), range_cells(value_range)
    if labels is None or values is None:
        problem = "a range is not one column of cells"
    elif isinstance(labels, str):
        problem = "a row of the category range: {}".format(labels)
    elif isinstance(values, str):
        problem = "a row of the value range: {}".format(values)
    elif labels[0] not in cells or values[0] not in cells:
        problem = "a range names a sheet the workbook does not have"
    elif len(labels[1]) != len(values[1]):
        problem = "the ranges are not the same length"
    else:
        problem = None
    if problem:
        return category_range, value_range, problem
    categories = []
    for label_ref, value_ref in zip(labels[1], values[1]):
        label = cell_text(cells[labels[0]].get(label_ref), strings)
        formula = None
        value_cell = cells[values[0]].get(value_ref)
        if value_cell is not None:
            found = value_cell.find(ns(MAIN_NS, "f"))
            if found is not None:
                formula = found.text
        categories.append((
            "{}!{}".format(labels[0], label_ref), label,
            "{}!{}".format(values[0], value_ref), formula,
        ))
    return category_range, value_range, categories


def read_workbook(path):
    """(text parts, charts) of a workbook. Text parts is a list of
    (Sheet!Cell, lines of its text) for every cell that holds a shared or
    inline string, in sheet order. Charts has one series_categories result
    for each series of each chart titled CHART_TITLE."""
    with zipfile.ZipFile(path) as book:
        strings = shared_strings(book)
        cells = {}
        parts = []
        for sheet, part in sheet_paths(book).items():
            cells[sheet] = {}
            for cell in parse_xml(book.read(part)).iter(ns(MAIN_NS, "c")):
                cells[sheet][cell.get("r")] = cell
                if cell.get("t") in ("s", "inlineStr"):
                    text = cell_text(cell, strings) or ""
                    place = "{}!{}".format(sheet, cell.get("r"))
                    parts.append((place, text.splitlines()))
        charts = []
        for name in book.namelist():
            if not CHART_PART.fullmatch(name):
                continue
            chart = parse_xml(book.read(name))
            title = chart.find("c:chart/c:title", {"c": CHART_NS})
            if title is None:
                continue
            text = "".join(t.text or "" for t in title.iter(ns(DRAWING_NS, "t")))
            if text.strip() != CHART_TITLE:
                continue
            for series in chart.iter(ns(CHART_NS, "ser")):
                charts.append(series_categories(series, cells, strings))
    return parts, charts


def is_zip_file(path):
    """zipfile.is_zipfile(path), or False where that raises BadZipFile, as it
    does in Python 3.9.6 for an archive whose zip64 locator gives two disks."""
    try:
        return zipfile.is_zipfile(path)
    except zipfile.BadZipFile:
        return False


def count_criteria(formula):
    """Criteria of a COUNTIF or COUNTIFS formula over one range, divided by
    a whole number, or None. A range is read without the white space at its
    ends, or as its last character when it is all white space."""
    match = COUNT.fullmatch(formula or "")
    if match is None:
        return None
    arguments = match.group("arguments")
    ranges, criteria = set(), []
    position = 0
    while position < len(arguments):
        pair = CRITERION.match(arguments, position)
        if pair is None or pair.end() == position:
            return None
        ranges.add(pair.group(1).strip() or pair.group(1)[-1])
        criteria.append(pair.group(2))
        position = pair.end()
    if len(ranges) != 1:
        return None
    return criteria


def criteria_band(criteria):
    """(lo, lo inclusive, hi, hi inclusive) of the scores from MIN_SCORE to
    MAX_SCORE that meet every criterion, None when a criterion is not a
    comparison with a number, or the reason a FAIL line gives, a str, when
    the number of a comparison has a digit other than 0 to 9."""
    lo, lo_inclusive, hi, hi_inclusive = MIN_SCORE, True, MAX_SCORE, True
    for criterion in criteria:
        match = COMPARISON.fullmatch(criterion)
        if match is None:
            return None
        if odd_number([match.group(2)]) is not None:
            return number_problem(match.group(2))
        operator, value = match.group(1) or "=", float(match.group(2))
        if operator in (">", ">=", "="):
            inclusive = operator != ">"
            if value > lo or (value == lo and not inclusive):
                lo, lo_inclusive = value, inclusive
        if operator in ("<", "<=", "="):
            inclusive = operator != "<"
            if value < hi or (value == hi and not inclusive):
                hi, hi_inclusive = value, inclusive
    return (lo, lo_inclusive, hi, hi_inclusive)


def check_chart(path, chart, bands, problems):
    category_range, value_range, categories = chart
    print("== {} {} chart ({}, {}) against the {}".format(
        path, CHART_TITLE, category_range, value_range, SHEET
    ))
    if isinstance(categories, str):
        problems.append("{}: {} chart: {}".format(path, CHART_TITLE, categories))
        return
    counted = set()
    for label_place, label, value_place, formula in categories:
        level = (label or "").strip()
        # A formula longer than Excel allows fails before any pattern is
        # matched against it.
        too_long = formula is not None and len(formula) > MAX_FORMULA_LENGTH
        criteria = None if too_long else count_criteria(formula)
        if criteria == ["-"] and level not in LEVELS:
            # The practices with no score, such as Incomplete Assessment.
            continue
        if level in LEVELS:
            counted.add(level)
        band = None
        if criteria is not None and criteria != ["-"]:
            band = criteria_band(criteria)
        if too_long:
            problems.append(
                "{} {}: the {} chart value is a formula of {:,} characters, "
                "longer than the {:,} Excel allows".format(
                    path, value_place, CHART_TITLE, len(formula),
                    MAX_FORMULA_LENGTH,
                )
            )
        elif criteria == ["-"]:
            problems.append(
                "{} {}: the {} chart counts the practices with no score as "
                "{}".format(path, value_place, CHART_TITLE, level)
            )
        elif isinstance(band, str):
            problems.append(
                "{} {}: the {} chart value: {}".format(
                    path, value_place, CHART_TITLE, band
                )
            )
        elif band is None:
            problems.append(
                "{} {}: the {} chart value is not a count of practice scores in "
                "one range: {}".format(path, value_place, CHART_TITLE, formula)
            )
        elif level not in LEVELS:
            problems.append(
                "{} {}: the {} chart category '{}' is not a QRAMM maturity "
                "level".format(path, label_place, CHART_TITLE, label or "")
            )
        elif level not in bands:
            problems.append(
                "{} {}: the {} chart counts {} as {}, but the {} labels no "
                "dimension or overall score {} ({}!H9:H12 and H14)".format(
                    path, value_place, CHART_TITLE, describe(band), level, SHEET,
                    level, SHEET,
                )
            )
        elif band != bands[level]:
            problems.append(
                "{} {}: the {} chart counts {} as {}, but on the {} {} is "
                "{}".format(
                    path, value_place, CHART_TITLE, describe(band), level, SHEET,
                    level, describe(bands[level]),
                )
            )
        else:
            print("  PASS {}: {} {}".format(value_place, level, describe(band)))
    for level in LEVELS:
        if level in bands and level not in counted:
            problems.append(
                "{}: the {} chart has no category for {}".format(
                    path, CHART_TITLE, level
                )
            )


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
    # sys.stdout is None when file descriptor 1 is closed, and print() then
    # writes nothing.
    encoding = getattr(sys.stdout, "encoding", None)
    if encoding is None:
        return name
    return name.encode(encoding, "backslashreplace").decode(encoding)


def main(argv):
    if "--help" in argv or "-h" in argv:
        print(USAGE, file=sys.stderr)
        # __doc__ is None when python3 -OO removes docstrings.
        if __doc__:
            print(file=sys.stderr)
            print(__doc__.strip(), file=sys.stderr)
        return 2
    unknown = [arg for arg in argv if arg.startswith("-")]
    if unknown:
        for arg in unknown:
            print("unknown option: {}".format(arg), file=sys.stderr)
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
            name = shown(path)
            print("== {} against the {}".format(name or "''", SHEET))
            if not path:
                problems.append("'': no file name given")
                continue
            is_workbook = path.lower().endswith(".xlsx")
            try:
                if is_workbook:
                    parts, charts = read_workbook(os.path.join(root, path))
                else:
                    with open(os.path.join(root, path), encoding="utf-8") as fh:
                        parts, charts = [("", fh.read().splitlines())], []
            except OSError as error:
                if is_workbook and (
                    error.errno is None or is_zip_file(os.path.join(root, path))
                ):
                    # An entry of a zip archive that cannot be read. bz2
                    # raises OSError("Invalid data stream"), which has no
                    # errno and so no strerror, for bzip2 data that does not
                    # decompress. A central directory offset past the end of
                    # the file can give an entry a negative offset, and the
                    # seek to it raises OSError(22, "Invalid argument").
                    problems.append("{}: cannot read (not a workbook)".format(name))
                    continue
                problems.append("{}: cannot read ({})".format(name, error.strerror))
                continue
            except zipfile.BadZipFile:
                # zipfile raises BadZipFile for a file that is not a zip
                # archive, and also when it reads an entry of a zip archive
                # whose data does not match its CRC-32, or whose local file
                # header signature is not at the offset zipfile works out
                # for it, which a central directory offset past the end of
                # the file can also cause.
                if is_zip_file(os.path.join(root, path)):
                    problems.append("{}: cannot read (not a workbook)".format(name))
                else:
                    problems.append("{}: cannot read (not a zip file)".format(name))
                continue
            except Exception as error:
                if not is_workbook:
                    # A text document whose bytes are not UTF-8.
                    if isinstance(error, UnicodeDecodeError):
                        problems.append("{}: cannot read (not UTF-8 text)".format(name))
                        continue
                    raise
                # A zip archive that is not a readable workbook: a missing
                # part or relationship Target, XML that does not parse, or a
                # shared-string index past the end of the table or not
                # written as one or more of the digits 0 to 9, for example.
                problems.append("{}: cannot read (not a workbook)".format(name))
                continue
            check_document(name, parts, bands, problems)
            for chart in charts:
                check_chart(name, chart, bands, problems)

    for problem in problems:
        print("  FAIL {}".format(problem))
    print("RESULT: {}".format("FAIL" if problems else "PASS"))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
