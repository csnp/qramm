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
reader does not see it. The script reads a cell's column from the r
attribute of its c element, a cell reference such as A1: one or more of
the letters A to Z, then one or more of the digits 0 to 9. When a c
element in a sheet and row that are not hidden has no r attribute, or an
r attribute, such as 1A, M1x or M followed by U+0661 (ARABIC-INDIC DIGIT
ONE), that is not a cell reference, the script cannot tell whether the
cell's column is hidden, and the workbook fails as not a workbook. The
script reads the hidden columns of a sheet from its col elements whose
hidden attribute is 1 or true: the min and max attributes of each give the
first and last column of a hidden range, as one or more of the digits 0
to 9. When such a col element in a sheet that is not hidden has no min or
max attribute, or one, such as x, 1_3 or 13 written with U+0661 and U+0663
(ARABIC-INDIC DIGIT ONE and THREE), that is not one or more of the digits
0 to 9, the script cannot tell which columns are hidden, and the workbook
fails as not a workbook.

The script reads the sheet, row, column and cell elements of a workbook in
the namespace the Transitional Open XML format uses for them,
http://schemas.openxmlformats.org/spreadsheetml/2006/main, or in the one
the Strict Open XML format uses, http://purl.oclc.org/ooxml/spreadsheetml/main.
A workbook whose xl/workbook.xml has no sheet element in either namespace
fails as not a workbook. So does a workbook whose xl/workbook.xml,
xl/_rels/workbook.xml.rels or part of a sheet that is not hidden has an
XML declaration that names an encoding Python has no codec for, such as
x-bogus, or a multi-byte encoding the XML parser does not read, such as
shift_jis.

The script uses the Python standard library only. Exit status: 0 when no
workbook stores an error value in a visible cell, 1 when one does or a
workbook cannot be read, 2 on a usage error. An empty workbook argument
fails with "no file name given". A file name is printed with each byte that
the file system encoding cannot decode, and each character that the encoding
of stdout cannot encode, as a backslash escape, such as \\xff for the byte
0xff and \\u65e5 for the character U+65E5. A FAIL line, such as one that
quotes a sheet name or a formula, is printed with each character that the
encoding of stdout cannot encode as a backslash escape too, such as \\u2192
for U+2192. A file name and a FAIL line are printed with each control
character, U+0000 to U+001F and U+007F to U+009F, as a backslash escape
as well, such as \\n for a line feed in the r attribute of a c element, so
that each problem is printed on one line. --help (or -h) prints the usage
line and this text on stderr and exits 2. Any other argument that starts
with "-", such as --verbose or --, is an unknown option: each one is named
on stderr on a line of its own, such as "unknown option: --verbose", before
the usage line, and the exit status is 2.
"""

import os
import re
import sys
import xml.etree.ElementTree as ET
import xml.parsers.expat
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
# The namespaces the Strict Open XML format uses for SpreadsheetML elements
# and for the r:id attribute of a sheet element, each mapped to the one the
# Transitional format uses in its place. read_xml() reads a name in one of
# them as the name in the Transitional namespace. Both formats use
# PKG_REL_NS for the Relationship elements.
STRICT_NS = {
    "http://purl.oclc.org/ooxml/spreadsheetml/main": MAIN_NS,
    "http://purl.oclc.org/ooxml/officeDocument/relationships": REL_NS,
}

# [0-9], not \d: in a str pattern \d also matches the other Unicode decimal
# digits, such as U+0661 (ARABIC-INDIC DIGIT ONE), and an r attribute such
# as M followed by U+0661 is not a cell reference.
CELL_REF = re.compile(r"([A-Z]+)([0-9]+)")
# The min or max attribute of a col element, a column number. column_bound()
# says why it reads one with this pattern and not with int() alone.
DIGITS = re.compile(r"[0-9]+")

# The C0 and C1 control characters and DEL, which printable() writes as
# backslash escapes, and the escapes it writes for three of them.
CONTROL = re.compile("[\x00-\x1f\x7f-\x9f]")
CONTROL_ESCAPES = {"\n": "\\n", "\r": "\\r", "\t": "\\t"}

USAGE = "usage: python3 -I scripts/check-workbook-errors.py [workbook ...]"


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


def column_number(letters):
    number = 0
    for letter in letters:
        number = number * 26 + ord(letter) - ord("A") + 1
    return number


def transitional(name):
    """name, an element or attribute name such as {namespace}sheet, with a
    namespace of STRICT_NS replaced by the one STRICT_NS gives for it."""
    if name.startswith("{"):
        namespace, _, local = name[1:].partition("}")
        if namespace in STRICT_NS:
            return ns(STRICT_NS[namespace], local)
    return name


def read_xml(book, part):
    """The root element of the part path part of book, with each element and
    attribute name replaced by what transitional() gives for it."""
    root = parse_xml(book.read(part))
    for node in root.iter():
        node.tag = transitional(node.tag)
        node.attrib = {transitional(name): value for name, value in node.attrib.items()}
    return root


def sheets(book):
    """List of (name, part path, hidden) in workbook order. Raises ValueError
    for a sheet whose Relationship element has no Target attribute, and when
    xl/workbook.xml has no sheet element that read_xml() reads in MAIN_NS."""
    workbook = read_xml(book, "xl/workbook.xml")
    rels = parse_xml(book.read("xl/_rels/workbook.xml.rels"))
    targets = {
        rel.get("Id"): rel.get("Target")
        for rel in rels.iter(ns(PKG_REL_NS, "Relationship"))
    }
    found = []
    for sheet in workbook.iter(ns(MAIN_NS, "sheet")):
        rel_id = sheet.get(ns(REL_NS, "id"))
        target = targets[rel_id]
        if target is None:
            raise ValueError(
                "xl/_rels/workbook.xml.rels has a Relationship element with "
                "Id {} and no Target attribute".format(rel_id)
            )
        part = target.lstrip("/") if target.startswith("/") else "xl/" + target
        hidden = sheet.get("state") in ("hidden", "veryHidden")
        found.append((sheet.get("name"), part, hidden))
    if not found:
        # A workbook whose sheet elements are in a namespace this script
        # does not read would otherwise pass with no cell checked.
        raise ValueError(
            "xl/workbook.xml has no sheet element in a namespace the script reads"
        )
    return found


def hidden_columns(root, part):
    """List of (first, last) column numbers of the hidden column ranges of
    root, the sheet read from the part path part. Raises ValueError for a
    hidden col element with no min or no max attribute, or with a min or
    max that is not one or more of the digits 0 to 9, such as "x", as
    column_bound() does."""
    ranges = []
    for col in root.iter(ns(MAIN_NS, "col")):
        if col.get("hidden") in ("1", "true"):
            ranges.append((column_bound(col, "min", part), column_bound(col, "max", part)))
    return ranges


def column_bound(col, name, part):
    """The attribute name, min or max, of the hidden col element col, as a
    number. part is the part path of the sheet that holds col. Raises
    ValueError for a col element with no such attribute, and for one whose
    attribute is not one or more of the digits 0 to 9, such as x, 1_3 or 13
    written with U+0661 and U+0663 (ARABIC-INDIC DIGIT ONE and THREE).
    int() reads each of the last two as 13: it reads every Unicode decimal
    digit, and allows an underscore between two digits."""
    value = col.get(name)
    if value is None:
        raise ValueError("{} has a hidden col element with no {} attribute".format(part, name))
    if not DIGITS.fullmatch(value):
        raise ValueError(
            "{} has a hidden col element whose {} attribute {!r} is not one or "
            "more of the digits 0 to 9".format(part, name, value)
        )
    return int(value)


def cell_column(cell, row, part):
    """The column number of the c element cell, read from its r attribute.
    row is the row element that holds cell, and part the part path of the
    sheet. Raises ValueError for a c element whose r attribute is missing or
    is not a cell reference, such as 1A or M1x."""
    # The file format makes the r attribute of a c element optional, but a
    # c element without one does not give its column, so this script cannot
    # tell whether the cell is in a hidden column.
    reference = cell.get("r")
    # fullmatch, as an r attribute such as M1x starts with the cell
    # reference M1 but is not one.
    match = CELL_REF.fullmatch(reference) if reference is not None else None
    if match:
        return column_number(match.group(1))
    # The r attribute of a row element is optional too; the message names
    # the row by that attribute unless it is missing or empty.
    where = " in row {}".format(row.get("r")) if row.get("r") else ""
    if reference is None:
        raise ValueError("{} has a c element with no r attribute{}".format(part, where))
    raise ValueError(
        "{} has a c element{} whose r attribute {} is not a cell "
        "reference".format(part, where, reference)
    )


def formula_text(cell):
    """The cell's formula with whitespace runs collapsed, or "no formula"."""
    node = cell.find(ns(MAIN_NS, "f"))
    if node is None or not (node.text or "").strip():
        return "no formula"
    return " ".join(node.text.split())


def check_sheet(name, part, root, label, problems):
    """Adds a problem per visible error cell. Returns the number of visible
    cells with a formula. Raises ValueError for a c element in a row that is
    not hidden whose r attribute is missing or is not a cell reference."""
    hidden = hidden_columns(root, part)
    formulas = 0
    for row in root.iter(ns(MAIN_NS, "row")):
        if row.get("hidden") in ("1", "true"):
            continue
        for cell in row.iter(ns(MAIN_NS, "c")):
            column = cell_column(cell, row, part)
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
                root = read_xml(book, part)
                formulas += check_sheet(name, part, root, label, problems)
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
    # LookupError: its subclass KeyError, for a part the archive does not
    # hold or a sheet r:id no Relationship element gives, and LookupError
    # itself, which ElementTree raises for an XML declaration that names an
    # encoding Python does not know, such as x-bogus. A multi-byte encoding
    # that Python knows, such as shift_jis, raises ValueError instead.
    except (zipfile.BadZipFile, LookupError, ET.ParseError, ValueError) as error:
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


def control_escape(match):
    """The backslash escape for the control character match matched: \\n,
    \\r or \\t, or \\x and two hex digits, such as \\x1b for U+001B."""
    char = match.group()
    return CONTROL_ESCAPES.get(char, "\\x{:02x}".format(ord(char)))


def printable(text):
    """text with each control character, U+0000 to U+001F and U+007F to
    U+009F, written as a backslash escape, such as \\n for a line feed, and
    each character the encoding of stdout cannot encode written as a
    backslash escape, such as \\u2192 for U+2192. Text quoted from a
    workbook, such as the r attribute of a c element, can hold a line feed,
    which would otherwise end the FAIL line and start one of the workbook's
    choosing. Under en_US.ISO8859-1 on macOS, the encoding of stdout is
    ISO-8859-1, so text quoted from a workbook, such as a sheet name or a
    formula that holds U+2192, can hold a character that print() cannot
    encode."""
    text = CONTROL.sub(control_escape, text)
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
    unknown = [arg for arg in argv if arg.startswith("-")]
    if unknown:
        for arg in unknown:
            print("unknown option: {}".format(arg), file=sys.stderr)
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
