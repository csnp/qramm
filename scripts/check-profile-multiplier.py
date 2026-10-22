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
A RiskMatrix cell whose shared string index is not one or more of the
digits 0 to 9, or is past the end of the shared string table, fails with a
line that names the cell. The lowest multiplier adds each factor times the
lowest risk value in its group, and the highest adds each factor times the
highest. Both are rounded to the decimal places the formula's ROUND gives,
with halves rounded up.

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
not, the workbook does not have the form described above or a file cannot
be read, 2 on a usage error. An empty file argument fails with "no file
name given", and a text document whose bytes are not UTF-8 fails with
"not UTF-8 text". A file name is printed with each byte that the file
system encoding cannot decode, and each character that the encoding of
stdout cannot encode, as a backslash escape, such as \\xff for the byte
0xff and \\u65e5 for the character U+65E5. --help (or -h) prints the usage
line and this text on stderr and exits 2.
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
# A shared string index. [0-9], not \d: in a str pattern \d also matches the
# other Unicode decimal digits, such as U+0661 (ARABIC-INDIC DIGIT ONE), and
# int() reads them too.
INDEX = re.compile(r"[0-9]+")

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
    """Text of a cell: its shared or inline string, or its stored value.
    Raises IndexError for a shared string index past the end of strings,
    and ValueError for one that is not one or more of the digits 0 to 9.
    int() strips whitespace from the start and end of text, reads a leading
    sign, allows an underscore between two digits and reads the other
    Unicode decimal digits, so it reads " 1820", +1820, 18_20 and 1820
    written with ARABIC-INDIC digits as 1820, and -1 as the index of the
    last shared string. The message of either error gives the index as
    written, with each character outside ASCII as a backslash escape, so
    that it can be printed whatever the encoding of stdout."""
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
                "shared string index {} is not one or more of the digits 0 "
                "to 9".format(ascii(value.text))
            )
        if int(value.text) >= len(strings):
            raise IndexError(
                "shared string index {} is past the end of the shared string "
                "table, which has {} strings".format(value.text, len(strings))
            )
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
    sheet = reference.rsplit("!", 1)[0]
    before = len(problems)
    groups = {}
    for row in range(top, bottom + 1):
        texts = []
        for column in range(left, left + 3):
            cell = cells.get((row, column))
            try:
                texts.append(cell_text(cell, strings))
            except (IndexError, ValueError) as error:
                problems.append(
                    "{}: {} cell {}!{}: {}".format(
                        WORKBOOK, MATRIX, sheet, cell.get("r"), error
                    )
                )
        if len(texts) < 3:
            continue
        category, factor, value = texts
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


def is_zip_file(path):
    """zipfile.is_zipfile(path), or False where that raises BadZipFile, as it
    does in Python 3.9.6 for an archive whose zip64 locator gives two disks."""
    try:
        return zipfile.is_zipfile(path)
    except zipfile.BadZipFile:
        return False


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


def check_document(name, parts, lowest, highest, problems):
    """name is the document's file name as printed. parts is a list of
    (place, lines): place is "" for a text file and Sheet!Cell for each text
    cell of a workbook."""
    stated = 0
    for place, lines in parts:
        where = place + " " if place else ""
        for number, low, high in stated_ranges(lines):
            stated += 1
            if (Decimal(low), Decimal(high)) != (lowest, highest):
                problems.append(
                    "{} {}line {}: the multiplier range is {} to {} here, but {} "
                    "calculates {} to {}".format(
                        name, where, number, low, high, WORKBOOK, lowest, highest
                    )
                )
            else:
                print("  PASS {}line {}: {} to {}".format(where, number, low, high))
    if not stated:
        problems.append("{}: gives no multiplier range".format(name))


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
            name = shown(path)
            print("== {} against {}".format(name or "''", WORKBOOK))
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
                if is_workbook and (
                    error.errno is None or is_zip_file(os.path.join(root, path))
                ):
                    # bzip2 data that does not decompress. bz2 raises
                    # OSError("Invalid data stream"), which has no errno and
                    # so no strerror to give as the reason. Or a zip archive
                    # that zipfile.is_zipfile() accepts, which it does only
                    # for a file it can open, so the error was raised while
                    # reading the archive: zipfile raises OSError(22,
                    # "Invalid argument") when it seeks to an entry at the
                    # negative offset it works out from an end of central
                    # directory record that gives a central directory offset
                    # past the end of the file.
                    problems.append("{}: cannot read (not a workbook)".format(name))
                    continue
                problems.append("{}: cannot read ({})".format(name, error.strerror))
                continue
            except zipfile.BadZipFile:
                # zipfile raises BadZipFile for a file that is not a zip
                # archive, and also when it reads an entry of a zip archive
                # whose data does not match its CRC-32 or whose local file
                # header gives another file name than the central directory.
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
                # A zip archive that is not a readable workbook. A missing part
                # or relationship Target, an encrypted entry, a compression
                # method zipfile does not support, deflate, LZMA or Zstandard
                # data that does not decompress, XML that does not parse or
                # declares an unknown encoding, and a shared-string index past
                # the end of the table each raise a different error type.
                # cell_text() raises ValueError for a shared-string index that
                # is not one or more of the digits 0 to 9.
                problems.append("{}: cannot read (not a workbook)".format(name))
                continue
            check_document(name, parts, lowest, highest, problems)

    for problem in problems:
        print("  FAIL {}".format(problem))
    print("RESULT: {}".format("FAIL" if problems else "PASS"))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
