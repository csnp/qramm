#!/usr/bin/env python3
"""Checks that no tracked workbook carries a protection password.

Usage:
    python3 -I scripts/check-workbook-protection.py [workbook ...]

A password applied to a sheet, a range of cells or a workbook is stored in
the attributes of a protection element inside the workbook's .xlsx package,
not in the specs, so scripts/check-spec-passwords.sh, which reads the
specs, does not find it. This script reads those elements.

With no workbook arguments it reads every tracked file whose name ends in
.xlsx, as git ls-files lists them; with arguments it reads those files
instead (paths relative to the repository root, or absolute). The case of
the letters in a file name's extension is ignored. A file whose name ends
in one of OTHER_FORMATS, the extensions .xls, .xlt, .xla, .xlsm, .xltm,
.xlam, .xlsb, .xltx, .ods, .ots, .fods and .numbers of spreadsheet formats
the script does not read, fails instead of being skipped.

With no workbook arguments the script needs a git checkout to list the
tracked files; in a copy that is not one (for example a downloaded archive)
it fails with a one-line message that says so. Pass the files to check as
arguments there instead. It also fails when git lists no tracked file whose
name ends in .xlsx or in one of OTHER_FORMATS, so it cannot pass by reading
nothing.

A workbook is read as a zip package. A file that is not a readable zip
package fails, and an encrypted workbook is not one: it is stored in a
compound file that holds the encrypted package. The script reads every part
whose name starts with xl/ and ends in .xml, with the letters in either
case, and a package with no such part fails as not a workbook. A part that
is not well-formed XML fails, and so does a part whose XML declaration
names an encoding that the XML parser cannot use, such as x-bogus, which
Python does not know, or shift_jis, a multi-byte encoding. So does a part
with a document type declaration (<!DOCTYPE), which is not read further,
so the entities it declares are not expanded.

In each part it reads every element whose local name is sheetProtection,
workbookProtection, protectedRange or fileSharing, in any namespace or in
none, so with or without a namespace prefix. An attribute of such an
element is an on/off setting when it is in no namespace, ON_OFF gives its
name for the element, and its value is true, false, 1 or 0, with any
spaces, tabs, carriage returns or line feeds around it ignored. An element
whose attributes are all on/off settings passes and is counted, as
protection without a password is allowed. Any other attribute fails, so a
password or a password hash fails whatever its attribute is called. ON_OFF
holds the attributes of type xsd:boolean that the SpreadsheetML schema of
ECMA-376 Part 1 gives each element. It gives the protectedRange element
none, and makes its sqref and name attributes required, so a protectedRange
element that has them fails.

For each element that fails, the script prints the file, the part, the
element's local name and the names of the attributes that are not on/off
settings; an attribute in a namespace is named by its local name followed
by "in a namespace". It never prints an attribute value. A workbook that
passes gets a PASS line that gives the number of protection elements it
has. After the last file, a line gives the number of files checked and the
totals of protection elements that pass and that fail.

The script uses the Python standard library only. Exit status: 0 when every
file passes, 1 when one fails or the script cannot list the tracked files
or finds none, 2 on a usage error. An empty workbook argument fails with
"no file name given". A file name is printed with each byte that the file
system encoding cannot decode as a backslash escape, such as \\xff for the
byte 0xff. A file or part name is printed with each character that is not
printable, such as a line feed, and each character that the encoding of
stdout cannot encode as a backslash escape too, such as \\n for a line feed
and \\u65e5 for the character U+65E5. --help (or -h) prints the usage line
and this text on stderr and exits 2. Any other argument that starts with
"-", such as --verbose or --, is an unknown option: each one is named on
stderr on a line of its own, such as "unknown option: --verbose", before
the usage line, and the exit status is 2.
"""

import os
import re
import subprocess
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

# The errors other than OSError that zipfile raises, with Python 3.14.3, as
# it reads a file that is not a readable zip package. zipfile.BadZipFile: a
# file that is not a zip archive, such as a text file or a compound file, or
# an entry whose sizes run past the end of the file. RuntimeError: an entry
# whose flags mark it as encrypted; its subclass NotImplementedError: an
# entry compressed with a method zipfile does not support, such as PPMd.
# zlib.error, lzma.LZMAError and compression.zstd.ZstdError: deflate, LZMA
# or Zstandard data that does not decompress. EOFError: an entry whose sizes
# run past the end of the file when a second central directory header gives
# the same local header offset, so that zipfile reads on to the end of the
# file. ValueError: an entry name that is not UTF-8 though the entry's flags
# say it is (UnicodeDecodeError is a subclass).
PACKAGE_ERRORS = (zipfile.BadZipFile, RuntimeError, zlib.error, EOFError, ValueError)
if lzma is not None:
    PACKAGE_ERRORS += (lzma.LZMAError,)
if zstd is not None:
    PACKAGE_ERRORS += (zstd.ZstdError,)

WORKBOOK_EXTENSION = ".xlsx"

OTHER_FORMATS = (
    ".xls",
    ".xlt",
    ".xla",
    ".xlsm",
    ".xltm",
    ".xlam",
    ".xlsb",
    ".xltx",
    ".ods",
    ".ots",
    ".fods",
    ".numbers",
)

# For each protection element, the attributes of type xsd:boolean of its
# complex type in sml.xsd, the SpreadsheetML schema of ECMA-376 Part 1 (5th
# edition, 2016), in the order the schema gives them. sheetProtection has
# the type CT_SheetProtection in a worksheet, dialog sheet or macro sheet
# and CT_ChartsheetProtection, whose content attribute is added at the end,
# in a chart sheet. The others have the types CT_WorkbookProtection,
# CT_ProtectedRange and CT_FileSharing. The Transitional schema of
# ECMA-376 Part 4 adds attributes to these types, such as password and
# workbookPassword, none of them of type xsd:boolean.
ON_OFF = {
    "sheetProtection": (
        "sheet",
        "objects",
        "scenarios",
        "formatCells",
        "formatColumns",
        "formatRows",
        "insertColumns",
        "insertRows",
        "insertHyperlinks",
        "deleteColumns",
        "deleteRows",
        "selectLockedCells",
        "sort",
        "autoFilter",
        "pivotTables",
        "selectUnlockedCells",
        "content",
    ),
    "workbookProtection": ("lockStructure", "lockWindows", "lockRevision"),
    "protectedRange": (),
    "fileSharing": ("readOnlyRecommended",),
}

# The values of an on/off setting, the literals of xsd:boolean, and the
# white space that xsd:boolean ignores around them.
ON_OFF_VALUES = ("true", "false", "1", "0")
XML_SPACE = " \t\r\n"

# A part read for protection elements. re.ASCII, so IGNORECASE matches only
# the ASCII letters in either case.
PART = re.compile(r"xl/.*\.xml", re.ASCII | re.IGNORECASE | re.DOTALL)

USAGE = "usage: python3 -I scripts/check-workbook-protection.py [workbook ...]"


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


class GitListError(Exception):
    """git could not list the tracked files. The message is one line."""


class PackageError(Exception):
    """A file is not a readable zip package."""


def untranslated_env():
    """The environment, set so git prints its messages untranslated.

    git built with translations prints its messages in the language the
    environment selects, so the "not a git repository" match in
    tracked_files needs the C locale. LANG is set as well as LC_ALL, as in
    scripts/check-spec-passwords.sh.
    """
    return dict(os.environ, LC_ALL="C", LANG="C")


def tracked_files(root):
    """The tracked files under root, as paths relative to root.

    Raises GitListError when git cannot list them, for example in a copy of
    the repository that is not a git checkout.
    """
    try:
        result = subprocess.run(
            ["git", "-C", root, "ls-files", "-z"],
            capture_output=True,
            env=untranslated_env(),
        )
    except OSError as err:
        raise GitListError("git could not be run ({})".format(err.strerror or err))
    if result.returncode != 0:
        detail = result.stderr.decode("utf-8", "replace").strip().splitlines()
        if detail and "not a git repository" in detail[0]:
            raise GitListError("not a git checkout")
        raise GitListError(
            "git ls-files exited {}{}".format(
                result.returncode, ": " + detail[0] if detail else ""
            )
        )
    return [os.fsdecode(name) for name in result.stdout.split(b"\0") if name]


def is_workbook(name):
    return name.lower().endswith(WORKBOOK_EXTENSION)


def is_other_format(name):
    return name.lower().endswith(OTHER_FORMATS)


def is_zip_file(path):
    """zipfile.is_zipfile(path), or False where that raises BadZipFile
    instead of returning False."""
    try:
        return zipfile.is_zipfile(path)
    except zipfile.BadZipFile:
        return False


def xml_parts(path):
    """List of (name, bytes) of each entry of the zip package at path whose
    name PART matches, in the order of the archive. Raises PackageError when
    path is not a readable zip package, and OSError when it cannot be read
    for another reason, such as a file that does not exist."""
    try:
        with zipfile.ZipFile(path) as book:
            return [
                (info.filename, book.read(info))
                for info in book.infolist()
                if PART.fullmatch(info.filename)
            ]
    except OSError as error:
        if error.errno is None or is_zip_file(path):
            # bz2 raises OSError("Invalid data stream"), which has no errno,
            # for bzip2 data that does not decompress. And zipfile raises
            # OSError(22, "Invalid argument") as it reads an archive whose
            # end of central directory record gives a central directory
            # offset past the end of the file; is_zipfile() accepts only a
            # file it can open.
            raise PackageError() from error
        raise
    except PACKAGE_ERRORS as error:
        raise PackageError() from error


def local_name(name):
    """name, an element or attribute name as ElementTree gives it, without
    the {namespace} in front of it."""
    return name.rpartition("}")[2]


def attribute_label(name):
    """The attribute name name as printed. A name in a namespace, which
    ElementTree gives as {namespace}local, is printed as "local in a
    namespace", as the namespace is the value of an xmlns attribute."""
    if name.startswith("{"):
        return "{} in a namespace".format(local_name(name))
    return name


def judge(element, local):
    """(others, values): lists of the names of the attributes of element, a
    protection element whose local name is local, that are not on/off
    settings. others holds those that ON_OFF does not give for local or
    that are in a namespace, as attribute_label() prints them; values holds
    those that ON_OFF gives whose value is not one of ON_OFF_VALUES."""
    others = []
    values = []
    for name, value in element.attrib.items():
        if name not in ON_OFF[local]:
            others.append(attribute_label(name))
        elif value.strip(XML_SPACE) not in ON_OFF_VALUES:
            values.append(name)
    return others, values


def described(names, one, many):
    """one, or many when names has more than one name, then the names."""
    return "{}: {}".format(one if len(names) == 1 else many, ", ".join(names))


def check_workbook(name, path, counts):
    """Problems for the workbook at path, printed as name. Adds the number of
    protection elements that pass and that fail to counts["passed"] and
    counts["failed"], and prints a PASS line when there is no problem."""
    try:
        parts = xml_parts(path)
    except PackageError:
        return ["{}: not a readable zip package".format(name)]
    except OSError as error:
        return ["{}: cannot read ({})".format(name, error.strerror)]
    if not parts:
        return [
            "{}: no part whose name starts with xl/ and ends in .xml "
            "(not a workbook)".format(name)
        ]

    problems = []
    passed = 0
    for part, data in parts:
        where = "{}: {}".format(name, printable(part))
        try:
            root = parse_xml(data)
        except DoctypeError as error:
            line, column = error.position
            problems.append(
                "{}: has a document type declaration (line {}, column {}), "
                "which a workbook part does not carry".format(where, line, column)
            )
            continue
        except ET.ParseError as error:
            line, column = error.position
            problems.append(
                "{}: not well-formed XML (line {}, column {})".format(where, line, column)
            )
            continue
        except (LookupError, ValueError):
            # ElementTree raises LookupError for an encoding name that Python
            # does not know, such as x-bogus, or that is not a text encoding,
            # such as base64, and ValueError for a multi-byte encoding, such
            # as shift_jis, which pyexpat cannot use.
            problems.append(
                "{}: the XML declaration names an encoding that the XML parser "
                "cannot use".format(where)
            )
            continue
        for element in root.iter():
            local = local_name(element.tag)
            if local not in ON_OFF:
                continue
            others, values = judge(element, local)
            if not others and not values:
                passed += 1
                continue
            counts["failed"] += 1
            if others:
                problems.append(
                    "{}: {} {} ({} not shown)".format(
                        where,
                        local,
                        described(
                            others,
                            "has an attribute that is not an on/off setting",
                            "has attributes that are not on/off settings",
                        ),
                        "value" if len(others) == 1 else "values",
                    )
                )
            if values:
                problems.append(
                    "{}: {} {} ({} not shown)".format(
                        where,
                        local,
                        described(
                            values,
                            "has an on/off attribute whose value is not true, false, 1 or 0",
                            "has on/off attributes whose values are not true, false, 1 or 0",
                        ),
                        "value" if len(values) == 1 else "values",
                    )
                )
    counts["passed"] += passed
    if not problems:
        print(
            "  PASS {} protection elements in {} parts, none with an attribute "
            "other than an on/off setting".format(passed, len(parts))
        )
    return problems


def check_file(label, root, counts):
    """Problems for the file argument or tracked file label, a path relative
    to root or absolute. Prints the file's == line first."""
    name = shown(label)
    print("== {}".format(name or "''"))
    if not label:
        return ["'': no file name given"]
    if is_other_format(label):
        return [
            "{}: a spreadsheet format the script does not read (it reads .xlsx "
            "files only)".format(name)
        ]
    return check_workbook(name, os.path.join(root, label), counts)


def printable(text):
    """text with each character that is not printable, such as a line feed
    or a tab, and each character that the encoding of stdout cannot encode,
    written as a backslash escape, such as \\n for a line feed, \\t for a tab
    and \\u65e5 for U+65E5. A part name can hold a line feed, which would
    otherwise end the output line it is printed on."""
    text = "".join(
        char if char.isprintable() else char.encode("unicode_escape").decode("ascii")
        for char in text
    )
    # sys.stdout is None when file descriptor 1 is closed, and print() then
    # writes nothing.
    encoding = getattr(sys.stdout, "encoding", None)
    if encoding is None:
        return text
    return text.encode(encoding, "backslashreplace").decode(encoding)


def shown(path):
    """path in a form stdout can encode: the bytes os.fsencode gives back,
    decoded with each byte the file system encoding cannot decode written
    as a backslash escape, such as \\xff for the byte 0xff, then passed
    through printable(). Python holds such a byte of a command-line argument
    as a lone surrogate, which print() cannot encode under a locale such as
    en_US.UTF-8."""
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
    unknown = [arg for arg in argv if arg.startswith("-")]
    if unknown:
        for arg in unknown:
            print("unknown option: {}".format(arg), file=sys.stderr)
        print(USAGE, file=sys.stderr)
        return 2
    root = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))

    if argv:
        files = argv
    else:
        try:
            tracked = tracked_files(root)
        except GitListError as error:
            print(
                printable(
                    "FAIL cannot list the tracked files: {}; pass the files to "
                    "check as arguments".format(error)
                )
            )
            print("RESULT: FAIL")
            return 1
        files = [name for name in tracked if is_workbook(name) or is_other_format(name)]
        if not files:
            print(
                "FAIL no tracked workbook: git ls-files lists no file whose name "
                "ends in {} or in one of OTHER_FORMATS".format(WORKBOOK_EXTENSION)
            )
            print("RESULT: FAIL")
            return 1

    counts = {"passed": 0, "failed": 0}
    failed = False
    for label in files:
        problems = check_file(label, root, counts)
        for problem in problems:
            print(printable("  FAIL {}".format(problem)))
        failed = failed or bool(problems)
    print(
        "{} files checked, {} protection elements with on/off settings only, {} "
        "with an attribute that is not an on/off setting".format(
            len(files), counts["passed"], counts["failed"]
        )
    )
    print("RESULT: {}".format("FAIL" if failed else "PASS"))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
