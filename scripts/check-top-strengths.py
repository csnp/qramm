#!/usr/bin/env python3
"""Checks that the toolkit overview describes the Scorecard's Top Strengths
as the Scorecard shows them.

Usage:
    python3 -I scripts/check-top-strengths.py

The Scorecard of toolkit/QRAMM_Assessment_Toolkit.xlsx lists practices under
the heading "Top Strengths" in Scorecard!C34, one in each entry that ENTRIES
names. The first cell of an entry, B35, B39 or B43, shows a mark when a
practice score is at least a threshold:

    IF(AND(ISNUMBER(A36),A36>=3.6),"<mark>","")

The second cell, C36, C40 or C44, is empty until the first shows the mark,
and then gives that score out of a maximum:

    IF(B35="","",<text>&FIXED(A36,2)&" out of 4.")

In the toolkit workbook, <text> is the practice name followed by the words
before the score. Whitespace outside the quoted text of a formula is
ignored. This script reads the heading and those formulas, and fails unless
C34 reads "Top Strengths", every formula has the form above, the second
formula of an entry tests the entry's first cell and gives the score that
the first formula tests, and every entry has the same threshold and the
same maximum.

Each line of toolkit/toolkit-overview.md, outside fenced code blocks, that
contains "Top Strengths" describes them, and the overview must have such a
line. Each one must, in upper or lower case:

    1. say "up to" the number of entries, written as a word or in digits,
       such as "up to three", not followed by a period and a digit as in
       "up to 3.6";
    2. give the threshold as a number, such as 3.6 or 3.60, other than the
       number after "out of";
    3. say "out of" the maximum, such as "out of 4".

The rules read such a line without its format characters (Unicode
category Cf), such as U+200B (ZERO WIDTH SPACE) and U+2060 (WORD JOINER):
3.6 followed by U+200B and 1 is read as 3.61, not as 3.6 and 1.

A number on such a line is read with the characters with a numeric value
right after it, such as U+00B2 (SUPERSCRIPT TWO) or U+00BD (VULGAR
FRACTION ONE HALF). A number with a character other than 0 to 9 and the
period fails, and it is not read as the threshold or the maximum: with
"has a digit other than 0 to 9" when each such character is a digit,
such as U+0661 (ARABIC-INDIC DIGIT ONE) or U+00B2, and with "has a
numeric character that is not a digit" otherwise, such as with U+00BD.

The script uses the Python standard library only. Exit status: 0 when the
overview agrees with the Scorecard, 1 when it does not, the workbook does
not have the form above or a file cannot be read, 2 on a usage error.
--help (or -h) prints the usage line and this text on stderr and exits 2.
The script takes no other argument: given one, it names each argument on
stderr on a line of its own, "unknown option: --verbose" for one that starts
with "-" and "unexpected argument: README.md" for any other, then prints
"this checker takes no arguments" and the usage line, and exits 2.
"""

import os
import re
import sys
import unicodedata
import xml.etree.ElementTree as ET
import xml.parsers.expat
import zipfile
from decimal import Decimal

WORKBOOK = "toolkit/QRAMM_Assessment_Toolkit.xlsx"
OVERVIEW = "toolkit/toolkit-overview.md"
SHEET = "Scorecard"
HEADING_CELL = "C34"
HEADING = "Top Strengths"

# The mark cell and the sentence cell of each Top Strengths entry, from the
# top of the Scorecard down.
ENTRIES = [("B35", "C36"), ("B39", "C40"), ("B43", "C44")]

NUMBER_WORDS = [
    "zero", "one", "two", "three", "four", "five", "six",
    "seven", "eight", "nine", "ten", "eleven", "twelve",
]

MAIN_NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
REL_NS = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
PKG_REL_NS = "http://schemas.openxmlformats.org/package/2006/relationships"

# [0-9], not \d: in a str pattern \d also matches the other Unicode decimal
# digits, such as U+0661 (ARABIC-INDIC DIGIT ONE), and Decimal() reads them
# too.
CELL = r"[A-Z]+[0-9]+"
NUMBER_TEXT = r"[0-9]+(?:\.[0-9]+)?"
MARK = re.compile(
    r'IF\(AND\(ISNUMBER\((?P<score>' + CELL + r')\),(?P=score)>='
    r'(?P<threshold>' + NUMBER_TEXT + r')\),"[^"]+",""\)'
)
SENTENCE = re.compile(
    r'IF\((?P<mark>' + CELL + r')="","",(?P<text>.+)&FIXED\((?P<score>'
    + CELL + r'),[0-9]+\)&" out of (?P<maximum>' + NUMBER_TEXT + r')\.?"\)',
    re.DOTALL,
)
# The quoted text of a formula, with "" for a quote inside it.
QUOTED = re.compile(r'("(?:[^"]|"")*")')
# A shared string index.
INDEX = re.compile(r"[0-9]+")

# \d, not [0-9], in OUT_OF and NUMBER, which read the overview: in a str
# pattern \d matches every Unicode decimal digit, so a number written with
# one other than 0 to 9 is matched whole, and read_numbers() refuses it.
# With [0-9], 3.6 followed by U+0661 would be read as 3.6.
OVERVIEW_NUMBER = r"\d+(?:\.\d+)?"
OUT_OF = re.compile(r"\bout of (" + OVERVIEW_NUMBER + r")", re.IGNORECASE)
NUMBER = re.compile(r"(?<![\w.])(" + OVERVIEW_NUMBER + r")")

USAGE = "usage: python3 -I scripts/check-top-strengths.py"


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


def ns(namespace, tag):
    return "{%s}%s" % (namespace, tag)


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


def string_text(item):
    """The text of a shared or inline string: its t element and the t
    elements of its runs."""
    parts = [item.find(ns(MAIN_NS, "t"))]
    parts += [run.find(ns(MAIN_NS, "t")) for run in item.findall(ns(MAIN_NS, "r"))]
    return "".join(part.text or "" for part in parts if part is not None)


def scorecard_cells(path, refs):
    """Cell reference -> (formula text, cell text) for the cells in refs on
    the Scorecard, or None when the workbook has no Scorecard. Either is None
    when the cell has no formula or no text that can be read."""
    with zipfile.ZipFile(path) as book:
        part = sheet_paths(book).get(SHEET)
        if part is None:
            return None
        sheet = parse_xml(book.read(part))
        strings = []
        if "xl/sharedStrings.xml" in book.namelist():
            table = parse_xml(book.read("xl/sharedStrings.xml"))
            strings = [string_text(item) for item in table.iter(ns(MAIN_NS, "si"))]
    cells = {}
    for cell in sheet.iter(ns(MAIN_NS, "c")):
        if cell.get("r") not in refs:
            continue
        formula = cell.find(ns(MAIN_NS, "f"))
        value = cell.find(ns(MAIN_NS, "v"))
        text = value.text if value is not None else None
        if cell.get("t") == "s":
            index = text or ""
            if INDEX.fullmatch(index) and int(index) < len(strings):
                text = strings[int(index)]
            else:
                text = None
        elif cell.get("t") == "inlineStr":
            inline = cell.find(ns(MAIN_NS, "is"))
            text = string_text(inline) if inline is not None else None
        cells[cell.get("r")] = (formula.text if formula is not None else None, text)
    return cells


def compact(formula):
    """formula with the whitespace outside its quoted text removed."""
    parts = QUOTED.split(formula)
    return "".join(
        part if index % 2 else re.sub(r"\s+", "", part)
        for index, part in enumerate(parts)
    )


def joined(items):
    """items as "A", "A and B" or "A, B and C"."""
    items = list(items)
    if len(items) < 2:
        return "".join(items)
    return "{} and {}".format(", ".join(items[:-1]), items[-1])


def read_entries(cells, problems):
    """(threshold, maximum) as written in the Top Strengths formulas, or
    None after adding a problem for each way the workbook does not have the
    form the module docstring gives."""
    where = "{}: {}!".format(WORKBOOK, SHEET)
    before = len(problems)
    if cells.get(HEADING_CELL, (None, None))[1] != HEADING:
        problems.append('{}{} does not read "{}"'.format(where, HEADING_CELL, HEADING))
    thresholds = {}
    maximums = {}
    for mark_ref, sentence_ref in ENTRIES:
        mark = MARK.fullmatch(compact(cells.get(mark_ref, (None, None))[0] or ""))
        sentence = SENTENCE.fullmatch(
            compact(cells.get(sentence_ref, (None, None))[0] or "")
        )
        if mark is None:
            problems.append(
                "{}{} is not a Top Strengths mark formula (see --help)".format(
                    where, mark_ref
                )
            )
        if sentence is None:
            problems.append(
                "{}{} is not a Top Strengths sentence formula (see --help)".format(
                    where, sentence_ref
                )
            )
        if mark is None or sentence is None:
            continue
        if sentence.group("mark") != mark_ref:
            problems.append(
                "{}{} tests {}, not {}".format(
                    where, sentence_ref, sentence.group("mark"), mark_ref
                )
            )
        if sentence.group("score") != mark.group("score"):
            problems.append(
                "{}{} gives the score in {}, and {} tests the score in {}".format(
                    where,
                    sentence_ref,
                    sentence.group("score"),
                    mark_ref,
                    mark.group("score"),
                )
            )
        thresholds[mark_ref] = mark.group("threshold")
        maximums[sentence_ref] = sentence.group("maximum")
    for found, name in ((thresholds, "thresholds"), (maximums, "maximums")):
        if len({Decimal(text) for text in found.values()}) > 1:
            problems.append(
                "{}{} give different {}: {}".format(
                    where,
                    joined(found),
                    name,
                    ", ".join("{} {}".format(ref, text) for ref, text in found.items()),
                )
            )
    if len(problems) > before:
        return None
    return thresholds[ENTRIES[0][0]], maximums[ENTRIES[0][1]]


def without_format(line):
    """line without its format characters (Unicode category Cf), such as
    U+200B (ZERO WIDTH SPACE). The rules read a Top Strengths line without
    them: OUT_OF and NUMBER stop at one, so they would read 3.6 followed by
    U+200B and 1 as 3.6 and 1, and up_to would read "up to 3" followed by
    U+200B and 1 as "up to 3"."""
    return "".join(char for char in line if unicodedata.category(char) != "Cf")


def number_texts(pattern, text):
    """The texts that group 1 of pattern, OUT_OF or NUMBER, matches in text,
    each with the characters with a numeric value right after it, such as
    U+00B2 (SUPERSCRIPT TWO). \\d matches decimal digits only, and U+00B2 is
    not one, so the match of "out of 4" followed by U+00B2 ends at 4."""
    texts = []
    for match in pattern.finditer(text):
        end = match.end(1)
        while end < len(text) and text[end].isnumeric():
            end += 1
        texts.append(text[match.start(1):end])
    return texts


def read_numbers(texts, where, problems):
    """The Decimal values of texts, the number texts that number_texts()
    read from the overview line at where. A text with a character other
    than 0 to 9 and the period is left out, and adds a problem. Decimal()
    reads every Unicode decimal digit, so it would read 3.6 followed by
    U+0661 (ARABIC-INDIC DIGIT ONE) as 3.61. !a writes each character
    other than ASCII as a backslash escape, as ascii() does."""
    values = []
    for text in texts:
        if text.isascii():
            values.append(Decimal(text))
        elif all(char.isdigit() or char == "." for char in text):
            problems.append(
                "{}: the number {!a} has a digit other than 0 to 9".format(where, text)
            )
        else:
            problems.append(
                "{}: the number {!a} has a numeric character that is not a "
                "digit".format(where, text)
            )
    return values


def check_overview(lines, threshold, maximum, problems):
    """Prints a PASS line for each rule that a Top Strengths line of the
    overview meets, and adds a problem for each rule that one does not."""
    count = len(ENTRIES)
    word = NUMBER_WORDS[count]
    # \b also matches between the number and a period, so that alone it
    # reads "up to 3.6" as "up to 3"; (?!\.\d) refuses a period followed by
    # a digit. \d, not [0-9]: a period followed by another Unicode decimal
    # digit, such as U+0666 (ARABIC-INDIC DIGIT SIX), is refused too, as \b
    # already refuses such a digit right after the number.
    up_to = re.compile(
        r"\bup to (?:{}|{})\b(?!\.\d)".format(word, count), re.IGNORECASE
    )
    marks = joined(mark for mark, _ in ENTRIES)
    sentences = joined(sentence for _, sentence in ENTRIES)
    fenced = False
    described = False
    for number, line in enumerate(lines, 1):
        if line.lstrip().startswith("```"):
            fenced = not fenced
            continue
        if fenced or HEADING not in line:
            continue
        described = True
        where = "{}:{}".format(OVERVIEW, number)
        text = without_format(line)
        if up_to.search(text):
            print("  PASS line {}: up to {}".format(number, word))
        else:
            problems.append(
                '{}: does not say "up to {}"; the {} has {} {} entries ({})'.format(
                    where, word, SHEET, word, HEADING, sentences
                )
            )
        given = read_numbers(
            number_texts(NUMBER, OUT_OF.sub(" ", text)), where, problems
        )
        if Decimal(threshold) in given:
            print("  PASS line {}: threshold {}".format(number, threshold))
        else:
            problems.append(
                "{}: does not give {}, the score from which the {} lists a "
                "practice ({})".format(where, threshold, SHEET, marks)
            )
        if Decimal(maximum) in read_numbers(
            number_texts(OUT_OF, text), where, problems
        ):
            print("  PASS line {}: out of {}".format(number, maximum))
        else:
            problems.append(
                '{}: does not say "out of {}"; the {} gives each score out of '
                "{} ({})".format(where, maximum, SHEET, maximum, sentences)
            )
    if not described:
        problems.append(
            '{}: no line outside fenced code blocks contains "{}"'.format(
                OVERVIEW, HEADING
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

    problems = []
    refs = {HEADING_CELL} | {ref for entry in ENTRIES for ref in entry}
    entries = None
    try:
        cells = scorecard_cells(os.path.join(root, WORKBOOK), refs)
    except OSError as error:
        problems.append(
            "{}: cannot read ({})".format(WORKBOOK, error.strerror or "not a workbook")
        )
    except (KeyError, zipfile.BadZipFile, ET.ParseError):
        # A file that is not a zip archive, or a zip archive with a missing
        # part or relationship Target or XML that does not parse.
        problems.append("{}: cannot read (not a workbook)".format(WORKBOOK))
    else:
        if cells is None:
            problems.append("{}: no sheet named {}".format(WORKBOOK, SHEET))
        else:
            entries = read_entries(cells, problems)

    if entries is not None:
        threshold, maximum = entries
        print("== {} {} {}".format(WORKBOOK, SHEET, HEADING))
        print("  {} entries: {}".format(len(ENTRIES), joined(s for _, s in ENTRIES)))
        print("  threshold {}".format(threshold))
        print("  out of {}".format(maximum))
        print("== {} against the {}".format(OVERVIEW, SHEET))
        try:
            with open(os.path.join(root, OVERVIEW), encoding="utf-8") as fh:
                lines = fh.read().splitlines()
        except OSError as error:
            problems.append("{}: cannot read ({})".format(OVERVIEW, error.strerror))
        except UnicodeDecodeError:
            problems.append("{}: cannot read (not UTF-8 text)".format(OVERVIEW))
        else:
            check_overview(lines, threshold, maximum, problems)

    for problem in problems:
        print("  FAIL {}".format(problem))
    print("RESULT: {}".format("FAIL" if problems else "PASS"))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
