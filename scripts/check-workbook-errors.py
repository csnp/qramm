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
fails with "no file name given". A file name is printed with each byte that
the file system encoding cannot decode, and each character that the encoding
of stdout cannot encode, as a backslash escape, such as \\xff for the byte
0xff and \\u65e5 for the character U+65E5. A FAIL line, such as one that
quotes a sheet name or a formula, is printed with each character that the
encoding of stdout cannot encode as a backslash escape too, such as \\u2192
for U+2192. --help (or -h) prints the usage line and this text on stderr
and exits 2.
"""

import os
import re
import sys
import xml.etree.ElementTree as ET
import zipfile
import zlib

try:
    import lzma
except ImportError:
    lzma = None
try:
    # New in Python 3.14.
    from compression import zstd
except ImportError:
    zstd = None

# The errors other than OSError and zipfile.BadZipFile that zipfile raises
# for an entry of a zip archive that it cannot read. RuntimeError: an entry
# whose flags mark it as encrypted, or a compression method whose module
# this Python lacks. NotImplementedError, a subclass of RuntimeError: a
# compression method zipfile does not support, such as 98 (PPMd), or 93
# (Zstandard) before Python 3.14. The error of the module that decompresses
# the entry, for data that does not decompress: zlib.error for deflate, the
# method a .xlsx file usually stores its entries with, lzma.LZMAError for
# LZMA and compression.zstd.ZstdError for Zstandard. bz2 raises OSError
# instead. EOFError: an entry whose compressed size runs past the end of the
# file, when zipfile reaches the end of the file as it reads the entry.
# Python 3.13.12 and 3.14.3 raise zipfile.BadZipFile for such an entry
# before reading it, except when a later central directory header gives the
# same local header offset: zipfile then only warns and reads on.
ENTRY_ERRORS = (RuntimeError, zlib.error, EOFError)
if lzma is not None:
    ENTRY_ERRORS += (lzma.LZMAError,)
if zstd is not None:
    ENTRY_ERRORS += (zstd.ZstdError,)

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
    """label is the workbook's file name as printed; path is the file read."""
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
        if error.errno is None or is_zip_file(path):
            # bzip2 data that does not decompress. bz2 raises
            # OSError("Invalid data stream"), which has no errno and so no
            # strerror to give as the reason. Or a zip archive that
            # zipfile.is_zipfile() accepts, which it does only for a file it
            # can open, so the error was raised while reading the archive:
            # zipfile raises OSError(22, "Invalid argument") when it seeks to
            # an entry at the negative offset it works out from an end of
            # central directory record that gives a central directory offset
            # past the end of the file.
            problems.append("{}: cannot read (not a workbook)".format(label))
            return
        problems.append("{}: cannot read ({})".format(label, error.strerror))
        return
    except ENTRY_ERRORS:
        problems.append("{}: cannot read (not a workbook)".format(label))
        return
    except (zipfile.BadZipFile, KeyError, ET.ParseError, ValueError) as error:
        problems.append("{}: not a workbook ({})".format(label, error))
        return
    if len(problems) == before:
        print("  PASS {} visible formula cells, none stores an error value".format(formulas))


def is_zip_file(path):
    """zipfile.is_zipfile(path), or False where that raises BadZipFile, as it
    does in Python 3.9.6 for an archive whose zip64 locator gives two disks."""
    try:
        return zipfile.is_zipfile(path)
    except zipfile.BadZipFile:
        return False


def printable(text):
    """text with each character the encoding of stdout cannot encode written
    as a backslash escape, such as \\u2192 for U+2192. Under en_US.ISO8859-1
    on macOS, the encoding of stdout is ISO-8859-1, so text quoted from a
    workbook, such as a sheet name or a formula that holds U+2192, can hold a
    character that print() cannot encode."""
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
        # python3 -OO removes the module docstring, so __doc__ is None there.
        if __doc__:
            print(file=sys.stderr)
            print(__doc__.strip(), file=sys.stderr)
        return 2
    if any(arg.startswith("-") for arg in argv):
        print(USAGE, file=sys.stderr)
        return 2
    root = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))

    problems = []
    for label in argv or WORKBOOKS:
        name = shown(label)
        print("== {}".format(name or "''"))
        if not label:
            problems.append("'': no file name given")
            continue
        check_workbook(name, os.path.join(root, label), problems)

    for problem in problems:
        # A problem can quote a workbook's text, such as a sheet name or a
        # formula.
        print(printable("  FAIL {}".format(problem)))
    print("RESULT: {}".format("FAIL" if problems else "PASS"))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
