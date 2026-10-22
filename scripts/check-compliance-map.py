#!/usr/bin/env python3
"""Checks that the toolkit workbooks carry the compliance mapping in the spec.

Usage:
    python3 -I scripts/check-compliance-map.py [workbook ...]

toolkit-specs/4_QRAMM_Compliance_Mapping_Details.md gives, for each of the
120 questions, a control and a relevance weight in eight frameworks, or "-"
where the question maps to nothing. The workbooks store the same mapping in
the range named ComplianceMap (Question_ID, Framework, Helper Column,
Control_ID, Category, Weight). With no arguments this script checks the
workbooks in WORKBOOKS; with arguments it checks those files instead (paths
relative to the repository root, or absolute). For each workbook:

    1. Every question and framework in the spec has exactly one row in the
       map, and the map has no other rows.
    2. The row's Control_ID is text equal to the spec's control. A
       Control_ID stored as a number fails, as a number cannot keep a CIS v8
       safeguard such as 3.10 apart from 3.1.
    3. The row's Weight is the spec's weight. A "-" in the spec matches a
       row whose Control_ID is "-" and whose Weight is empty. A Weight
       stored as the logical value TRUE or FALSE fails, as it is not a
       number.
    4. The row's Category, when it is not "-", has a name in each range the
       Compliance sheet's category cells look names up in, for example
       VLOOKUP(_xlfn.CONCAT($M$4,TRIM(E63)),Data!$BG$3:$BH$108,2,FALSE).
       The key is the framework followed by the category, as that formula
       builds it, and is matched without regard to case, as VLOOKUP
       matches. A category with no name there shows as its bare label in
       the Compliance sheet.

The script reads stored cell values and the formula text of the Compliance
sheet, and uses the Python standard library only.

Exit status: 0 when the workbooks pass checks 1 to 4, 1 when they do not or
a workbook cannot be read, 2 on a usage error. An empty workbook argument
fails with "no file name given". A file name is printed with each byte that
the file system encoding cannot decode, and each character that the encoding
of stdout cannot encode, as a backslash escape, such as \\xff for the byte
0xff and \\u65e5 for the character U+65E5. A FAIL line, such as one that
quotes a Control_ID, and the PASS line that names the ranges the category
names are looked up in are printed with each character that the encoding of
stdout cannot encode as a backslash escape too, such as \\u2192 for U+2192.
--help (or -h) prints the usage line and this text on stderr and exits 2.
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
# the entry, for data that does not decompress: zlib.error for deflate,
# lzma.LZMAError for LZMA and compression.zstd.ZstdError for Zstandard. bz2
# raises OSError instead. EOFError: an entry whose compressed size runs past
# the end of the file, when zipfile reaches the end of the file as it reads
# the entry. Python 3.13.12 and 3.14.3 raise zipfile.BadZipFile for such an
# entry before reading it, except when a later central directory header
# gives the same local header offset: zipfile then only warns and reads on.
ENTRY_ERRORS = (RuntimeError, zlib.error, EOFError)
if lzma is not None:
    ENTRY_ERRORS += (lzma.LZMAError,)
if zstd is not None:
    ENTRY_ERRORS += (zstd.ZstdError,)

# The errors check_workbook() and check_category_names() report as a
# workbook that cannot be read, each as the problem unreadable() gives.
READ_ERRORS = (OSError, KeyError, ValueError, zipfile.BadZipFile, ET.ParseError) + ENTRY_ERRORS

SPEC = "toolkit-specs/4_QRAMM_Compliance_Mapping_Details.md"

WORKBOOKS = [
    "toolkit/QRAMM_Assessment_Toolkit.xlsx",
    "toolkit/Sample_Assessment.xlsx",
]

MAP_NAME = "ComplianceMap"

COMPLIANCE_SHEET = "Compliance"

# Spec table column -> framework name in the workbook map.
FRAMEWORKS = [
    ("NIST CSF", "NIST CSF 2.0"),
    ("NIST PQC", "NIST PQC"),
    ("CMMC", "CMMC 2.0"),
    ("FISMA", "FISMA"),
    ("FedRAMP", "FedRAMP"),
    ("ISO", "ISO 27001"),
    ("SOC2", "SOC2"),
    ("CIS", "CIS v8"),
]

QUESTIONS = 120

# Offsets of the columns read from each row of the map.
QUESTION_COLUMN = 0
FRAMEWORK_COLUMN = 1
CONTROL_COLUMN = 3
CATEGORY_COLUMN = 4
WEIGHT_COLUMN = 5
MAP_WIDTH = 6

MAIN_NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
REL_NS = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
PKG_REL_NS = "http://schemas.openxmlformats.org/package/2006/relationships"

SPEC_ROW = re.compile(r"^\|\s*(Q\d+):")
# [0-9], not \d: in a str pattern \d also matches the other Unicode decimal
# digits, such as U+0663 (ARABIC-INDIC DIGIT THREE), and float() reads them
# too, so a spec weight written with U+0661, a period and U+0660 is not a
# weight. For the same reason an r attribute such as A followed by U+0663
# is not a cell reference, and a range such as Data!$AV$ followed by U+0663
# and :$BA$962 is not a cell range.
SPEC_CELL = re.compile(r"^(.+?) \(([0-9]+(?:\.[0-9]+)?)\)$")
CELL_REF = re.compile(r"([A-Z]+)([0-9]+)")
DIGITS = re.compile(r"[0-9]+")
RANGE_REF = re.compile(r"'?(.+?)'?!\$?([A-Z]+)\$?([0-9]+):\$?([A-Z]+)\$?([0-9]+)")
NAME_LOOKUP = re.compile(
    r"VLOOKUP\(_xlfn\.CONCAT\(\$M\$4,TRIM\(\$?[A-Z]+\$?[0-9]+\)\),"
    r"('?)(.+?)\1!\$?([A-Z]+)\$?([0-9]+):\$?([A-Z]+)\$?([0-9]+),2,FALSE\)"
)
TOLERANCE = 1e-9

USAGE = "usage: python3 -I scripts/check-compliance-map.py [workbook ...]"


def ns(prefix, tag):
    return "{%s}%s" % (prefix, tag)


def column_number(letters):
    number = 0
    for letter in letters:
        number = number * 26 + ord(letter) - ord("A") + 1
    return number


def column_letters(number):
    letters = ""
    while number:
        number, rest = divmod(number - 1, 26)
        letters = chr(ord("A") + rest) + letters
    return letters


def read_spec(path, problems):
    """(question, framework) -> (line number, control or None, weight or None)."""
    with open(path, encoding="utf-8") as fh:
        lines = fh.read().splitlines()
    spec = {}
    header = None
    for number, line in enumerate(lines, 1):
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if cells and cells[0] == "Question":
            header = cells[1:]
            continue
        match = SPEC_ROW.match(line)
        if not match:
            continue
        question = match.group(1)
        if header != [column for column, _ in FRAMEWORKS]:
            problems.append(
                "{} line {}: the table header does not list {}".format(
                    SPEC, number, " | ".join(column for column, _ in FRAMEWORKS)
                )
            )
            continue
        if len(cells) != len(FRAMEWORKS) + 1:
            problems.append(
                "{} line {}: {} has {} cells, expected {}".format(
                    SPEC, number, question, len(cells), len(FRAMEWORKS) + 1
                )
            )
            continue
        for (column, framework), cell in zip(FRAMEWORKS, cells[1:]):
            key = (question, framework)
            if key in spec:
                problems.append(
                    "{} line {}: {} {} is also given on line {}".format(
                        SPEC, number, question, column, spec[key][0]
                    )
                )
                continue
            if cell == "-":
                spec[key] = (number, None, None)
                continue
            parsed = SPEC_CELL.match(cell)
            if not parsed:
                problems.append(
                    "{} line {}: {} {} is \"{}\", expected \"<control> (<weight>)\" "
                    "or \"-\"".format(SPEC, number, question, column, cell)
                )
                continue
            spec[key] = (number, parsed.group(1), float(parsed.group(2)))
    for index in range(1, QUESTIONS + 1):
        question = "Q{}".format(index)
        for column, framework in FRAMEWORKS:
            if (question, framework) not in spec:
                problems.append("{}: no {} cell for {}".format(SPEC, column, question))
    return spec


def shared_strings(book):
    try:
        root = ET.fromstring(book.read("xl/sharedStrings.xml"))
    except KeyError:
        return []
    return [
        "".join(node.text or "" for node in item.iter(ns(MAIN_NS, "t")))
        for item in root.iter(ns(MAIN_NS, "si"))
    ]


def sheet_parts(book, workbook):
    """Sheet name -> sheet part path. Raises ValueError for a sheet whose
    Relationship element has no Target attribute."""
    rels = ET.fromstring(book.read("xl/_rels/workbook.xml.rels"))
    targets = {
        rel.get("Id"): rel.get("Target")
        for rel in rels.iter(ns(PKG_REL_NS, "Relationship"))
    }
    paths = {}
    for sheet in workbook.iter(ns(MAIN_NS, "sheet")):
        rel_id = sheet.get(ns(REL_NS, "id"))
        target = targets[rel_id]
        if target is None:
            raise ValueError(
                "xl/_rels/workbook.xml.rels has a Relationship element with "
                "Id {} and no Target attribute".format(rel_id)
            )
        paths[sheet.get("name")] = target.lstrip("/") if target.startswith("/") else "xl/" + target
    return paths


def map_range(book):
    """(sheet part path, sheet name, first column, first row, last row)."""
    workbook = ET.fromstring(book.read("xl/workbook.xml"))
    paths = sheet_parts(book, workbook)
    for node in workbook.iter(ns(MAIN_NS, "definedName")):
        if node.get("name") != MAP_NAME or node.get("localSheetId") is not None:
            continue
        match = RANGE_REF.fullmatch((node.text or "").strip())
        if not match:
            raise ValueError("{} is not a cell range: {}".format(MAP_NAME, node.text))
        sheet = match.group(1).replace("''", "'")
        first, last = column_number(match.group(2)), column_number(match.group(4))
        if last - first + 1 != MAP_WIDTH:
            raise ValueError(
                "{} is {} columns wide, expected {}".format(MAP_NAME, last - first + 1, MAP_WIDTH)
            )
        if sheet not in paths:
            raise ValueError("{} names sheet '{}', which is not in the workbook".format(MAP_NAME, sheet))
        return paths[sheet], sheet, first, int(match.group(3)), int(match.group(5))
    raise ValueError("the workbook has no defined name {}".format(MAP_NAME))


def ascii_int(text):
    """int(text), except that text other than one or more of the digits 0
    to 9 raises ValueError, as int() does for text such as "x". The
    workbook writes its numbers with the digits 0 to 9. int() also reads
    every Unicode decimal digit, such as U+0663 (ARABIC-INDIC DIGIT THREE)
    as 3, allows an underscore between two digits, so it reads 0_3 as 3,
    and strips whitespace from the start and end of text and reads a
    leading sign, so it reads " 3" and +3 as 3."""
    if not DIGITS.fullmatch(text):
        raise ValueError("invalid literal for int() with base 10: {!r}".format(text))
    return int(text)


def ascii_float(text):
    """float(text), except that text with a character outside ASCII, an
    underscore, whitespace at its start or end, or a leading sign raises
    ValueError, as float() does for text such as "x". The workbook writes
    its numbers with the digits 0 to 9. float() also reads every Unicode
    decimal digit, such as U+0661 (ARABIC-INDIC DIGIT ONE) as 1, allows an
    underscore between two digits, so it reads 0_1 as 1, and strips
    whitespace from the start and end of text and reads a leading sign, so
    it reads " 1 " and +1 as 1.0."""
    if not text.isascii() or "_" in text or text != text.strip() or text.startswith(("+", "-")):
        raise ValueError("could not convert string to float: {!r}".format(text))
    return float(text)


class Logical:
    """The stored value of a cell whose t attribute is "b": the logical
    value TRUE (stored as 1) or FALSE (stored as 0). It is not a number, so
    it is kept apart from the floats cell_value() gives for numbers."""

    __slots__ = ("value",)

    def __init__(self, value):
        self.value = value

    def __eq__(self, other):
        return isinstance(other, Logical) and other.value == self.value

    def __hash__(self):
        return hash((Logical, self.value))

    def __str__(self):
        return "TRUE" if self.value else "FALSE"


def cell_value(node, strings, part):
    """Stored value of a cell: str, float, Logical, or None when it is
    empty. part is the part path of the sheet that holds the cell. Raises
    ValueError for a shared string index that is not one of the shared
    strings, as ascii_int() does for an index that is not one or more of
    the digits 0 to 9, such as "x", 7_14 or +714, as ascii_float() does
    for the value of a cell stored as a number, such as "x", a value that
    holds a digit other than 0 to 9 or an underscore, one with whitespace
    at its start or end, such as " 1 ", or one with a leading sign, such
    as +1, and for the value of a cell stored as a logical value that is
    not 0 or 1."""
    value = node.find(ns(MAIN_NS, "v"))
    kind = node.get("t")
    if kind == "inlineStr":
        return "".join(t.text or "" for t in node.iter(ns(MAIN_NS, "t")))
    if value is None or value.text is None:
        return None
    if kind == "s":
        index = ascii_int(value.text)
        if not 0 <= index < len(strings):
            raise ValueError(
                "{} cell {} gives shared string index {}, and the workbook has {} "
                "shared strings".format(part, node.get("r"), index, len(strings))
            )
        return strings[index]
    if kind in ("str", "e"):
        return value.text
    if kind == "b":
        if value.text not in ("0", "1"):
            raise ValueError(
                "{} cell {} gives logical value {!r}, which is not 0 or 1".format(
                    part, node.get("r"), value.text
                )
            )
        return Logical(value.text == "1")
    return ascii_float(value.text)


def read_block(book, part, strings, first, width, top, bottom):
    """{row number: {offset: value}} for rows top to bottom and the width
    columns from column number first of the sheet part. Raises ValueError
    for a row element of the part with no r attribute, as ascii_int() does
    for an r that is not one or more of the digits 0 to 9, such as "x", 0_3
    or " 3", and for a c element of a row in that range whose r attribute
    is missing or is not a cell reference."""
    root = ET.fromstring(book.read(part))
    rows = {number: {} for number in range(top, bottom + 1)}
    for row in root.iter(ns(MAIN_NS, "row")):
        # A row element with no r attribute does not give its row number,
        # so this script cannot tell whether the row is one of top to bottom.
        reference = row.get("r")
        if reference is None:
            raise ValueError("{} has a row element with no r attribute".format(part))
        number = ascii_int(reference)
        if number not in rows:
            continue
        for node in row.iter(ns(MAIN_NS, "c")):
            # A c element with no r attribute does not give its column, so
            # this script cannot tell whether the cell is in the range.
            cell = node.get("r")
            if cell is None:
                raise ValueError("{} has a c element with no r attribute in row {}".format(part, number))
            match = CELL_REF.fullmatch(cell)
            if not match:
                raise ValueError(
                    "{} has a c element in row {} whose r attribute {} is not "
                    "a cell reference".format(part, number, cell)
                )
            offset = column_number(match.group(1)) - first
            if 0 <= offset < width:
                rows[number][offset] = cell_value(node, strings, part)
    return rows


def read_map(path):
    """(sheet name, first column, list of (row number, {offset: value}))."""
    with zipfile.ZipFile(path) as book:
        strings = shared_strings(book)
        part, sheet, first, top, bottom = map_range(book)
        rows = read_block(book, part, strings, first, MAP_WIDTH, top, bottom)
    return sheet, first, sorted(rows.items())


def as_text(value):
    """The text Excel makes of a stored value, as CONCAT and TRIM do."""
    if isinstance(value, float):
        return "{:.15g}".format(value)
    if isinstance(value, Logical):
        return str(value)
    return value


def excel_trim(text):
    """Excel's TRIM: no leading or trailing spaces, single inner spaces."""
    return re.sub(" +", " ", text).strip(" ")


def read_name_lookups(path):
    """[(range, {key: name})], one for each distinct range the Compliance
    sheet's category cells look names up in. The key is the stored value of
    the range's first column, casefolded; the name is the stored value of
    its second column. When a key repeats, the first row's name is kept, as
    VLOOKUP returns the first match."""
    with zipfile.ZipFile(path) as book:
        strings = shared_strings(book)
        workbook = ET.fromstring(book.read("xl/workbook.xml"))
        paths = sheet_parts(book, workbook)
        if COMPLIANCE_SHEET not in paths:
            raise ValueError("the workbook has no sheet {}".format(COMPLIANCE_SHEET))
        root = ET.fromstring(book.read(paths[COMPLIANCE_SHEET]))
        ranges = []
        for node in root.iter(ns(MAIN_NS, "f")):
            for match in NAME_LOOKUP.finditer(node.text or ""):
                found = (match.group(2).replace("''", "'"),) + match.group(3, 4, 5, 6)
                if found not in ranges:
                    ranges.append(found)
        if not ranges:
            raise ValueError("the {} sheet has no category name lookup".format(COMPLIANCE_SHEET))
        lookups = []
        for sheet, first_letters, top, last_letters, bottom in ranges:
            label = "{}!{}{}:{}{}".format(sheet, first_letters, top, last_letters, bottom)
            if sheet not in paths:
                raise ValueError("{} names sheet '{}', which is not in the workbook".format(label, sheet))
            first = column_number(first_letters)
            if column_number(last_letters) - first + 1 < 2:
                raise ValueError("{} is narrower than 2 columns".format(label))
            rows = read_block(book, paths[sheet], strings, first, 2, int(top), int(bottom))
            names = {}
            for _, values in sorted(rows.items()):
                key = values.get(0)
                if key is not None:
                    names.setdefault(as_text(key).casefold(), values.get(1))
            lookups.append((label, names))
    return lookups


def show(value):
    if value is None:
        return "empty"
    if isinstance(value, float):
        return "{:.15g}".format(value)
    if isinstance(value, Logical):
        return "the logical value {}".format(value)
    return value


def show_control(value):
    if isinstance(value, float):
        return "the number {}".format(show(value))
    return show(value)


def is_zip_file(path):
    """zipfile.is_zipfile(path), or False where that raises BadZipFile, as it
    does in Python 3.9.6 for an archive whose zip64 locator gives two disks."""
    try:
        return zipfile.is_zipfile(path)
    except zipfile.BadZipFile:
        return False


def reason(error, path):
    """The reason given for the workbook at path when reading it raised
    error. An operating system error gives its description, such as "No such
    file or directory", as str() of it repeats the path the way repr()
    writes it, with a byte that is not UTF-8 as \\udcff. An error with no
    description, such as the OSError bz2 raises for data that does not
    decompress, gives str() of it. An operating system error for a zip
    archive that zipfile.is_zipfile() accepts gives "not a workbook" instead
    of its description: zipfile.is_zipfile() accepts only a file it can
    open, so the error was raised while reading the archive, as when zipfile
    raises OSError(22, "Invalid argument") on seeking to an entry at the
    negative offset it works out from an end of central directory record
    that gives a central directory offset past the end of the file. An
    error in ENTRY_ERRORS, which zipfile raises for an entry it cannot read,
    such as the zlib.error for an entry stored with the deflate method whose
    data does not decompress, gives "not a workbook" too."""
    if isinstance(error, ENTRY_ERRORS):
        return "not a workbook"
    if isinstance(error, OSError) and error.strerror:
        if is_zip_file(path):
            return "not a workbook"
        return error.strerror
    return str(error)


def unreadable(label, error, path, part):
    """The problem reported when reading part, such as "the compliance map",
    of the workbook at path raised error; label is the workbook's file name
    as printed. A file that is not a zip archive gives "cannot read" and the
    description of an operating system error, such as "No such file or
    directory" or "Is a directory", or "not a workbook" and the zipfile
    error, such as "File is not a zip file". Any other error gives "cannot
    read", the part and the reason reason() gives."""
    if not is_zip_file(path):
        if isinstance(error, OSError) and error.strerror:
            return "{}: cannot read ({})".format(label, error.strerror)
        if isinstance(error, zipfile.BadZipFile):
            return "{}: not a workbook ({})".format(label, error)
    return "{}: cannot read {} ({})".format(label, part, reason(error, path))


def check_workbook(label, path, spec, problems):
    """label is the workbook's file name as printed; path is the file read."""
    try:
        sheet, first, rows = read_map(path)
    except READ_ERRORS as error:
        problems.append(unreadable(label, error, path, "the compliance map"))
        return
    control_letters = column_letters(first + CONTROL_COLUMN)
    weight_letters = column_letters(first + WEIGHT_COLUMN)
    seen = {}
    before = len(problems)
    for number, values in rows:
        question = values.get(QUESTION_COLUMN)
        framework = values.get(FRAMEWORK_COLUMN)
        key = (question, framework)
        where = "{} {} {}".format(label, show(question), show(framework))
        if key not in spec:
            problems.append(
                "{} {} row {}: not a question and framework in {}".format(label, sheet, number, SPEC)
            )
            continue
        if key in seen:
            problems.append("{}: on {} rows {} and {}".format(where, sheet, seen[key], number))
            continue
        seen[key] = number
        line, control, weight = spec[key]
        stored_control = values.get(CONTROL_COLUMN)
        stored_weight = values.get(WEIGHT_COLUMN)
        expected_control = "-" if control is None else control
        if stored_control != expected_control:
            problems.append(
                "{}: {}!{}{} is {}, the spec gives {} (line {})".format(
                    where, sheet, control_letters, number,
                    show_control(stored_control), expected_control, line,
                )
            )
        if weight is None:
            weight_ok = stored_weight is None
        else:
            weight_ok = isinstance(stored_weight, float) and abs(stored_weight - weight) <= TOLERANCE
        if not weight_ok:
            problems.append(
                "{}: {}!{}{} is {}, the spec gives {} (line {})".format(
                    where, sheet, weight_letters, number, show(stored_weight),
                    "no weight" if weight is None else "{:g}".format(weight), line,
                )
            )
    for key in sorted(spec, key=lambda item: (int(item[0][1:]), item[1])):
        if key not in seen:
            problems.append(
                "{}: no row for {} {} in {}".format(label, key[0], key[1], MAP_NAME)
            )
    if len(problems) == before:
        print("  PASS {} questions x {} frameworks, {} rows".format(
            QUESTIONS, len(FRAMEWORKS), len(seen)
        ))
    check_category_names(label, path, sheet, first, rows, problems)


def check_category_names(label, path, sheet, first, rows, problems):
    try:
        lookups = read_name_lookups(path)
    except READ_ERRORS as error:
        problems.append(unreadable(label, error, path, "the category name lookup"))
        return
    category_letters = column_letters(first + CATEGORY_COLUMN)
    named = 0
    before = len(problems)
    for number, values in rows:
        category = values.get(CATEGORY_COLUMN)
        framework = values.get(FRAMEWORK_COLUMN)
        if category is None or framework is None:
            continue
        trimmed = excel_trim(as_text(category))
        if trimmed in ("", "-"):
            continue
        named += 1
        key = (as_text(framework) + trimmed).casefold()
        for range_label, names in lookups:
            if names.get(key) in (None, ""):
                problems.append(
                    "{} {} {}: {}!{}{} is {}, which has no name in {}, the range the {} "
                    "sheet looks category names up in".format(
                        label, show(values.get(QUESTION_COLUMN)), show(framework),
                        sheet, category_letters, number, trimmed, range_label, COMPLIANCE_SHEET,
                    )
                )
    if len(problems) == before:
        # A range label quotes a sheet name from the Compliance sheet's
        # formulas.
        print(printable("  PASS {} rows with a category, each named in {}".format(
            named, ", ".join(range_label for range_label, _ in lookups)
        )))


def printable(text):
    """text with each character the encoding of stdout cannot encode written
    as a backslash escape, such as \\u2192 for U+2192. Under en_US.ISO8859-1
    on macOS, the encoding of stdout is ISO-8859-1, so text quoted from a
    workbook, such as a Control_ID or a sheet name that holds U+2192, can
    hold a character that print() cannot encode."""
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
    workbooks = argv or WORKBOOKS

    problems = []
    try:
        spec = read_spec(os.path.join(root, SPEC), problems)
    except OSError as error:
        print(printable("  FAIL {}: cannot read ({})".format(SPEC, error.strerror)))
        print("RESULT: FAIL")
        return 1

    for label in workbooks:
        name = shown(label)
        print("== {} against {}".format(name or "''", SPEC))
        if not label:
            problems.append("'': no file name given")
            continue
        check_workbook(name, os.path.join(root, label), spec, problems)

    for problem in problems:
        # A problem can quote a workbook's text, such as a Control_ID or a
        # sheet name.
        print(printable("  FAIL {}".format(problem)))
    print("RESULT: {}".format("FAIL" if problems else "PASS"))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
