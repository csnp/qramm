#!/usr/bin/env python3
"""Checks that the toolkit's copies of framework documents match their source.

Usage:
    python3 -I scripts/check-assessment-copies.py

The toolkit directory carries copies of framework documents so that the
toolkit can be read on its own. COPIES lists each source and its copy, as
paths relative to the repository root. Add a pair to it when a new copy is
made. For each pair, the copy must have the same lines as the source. A
relative link in either file is compared by the repository path it resolves
to, so a copy may rewrite a link for its own directory as long as the link
still reaches the same file.

Each difference is reported with the line numbers in both files and the text
of up to MAX_SHOWN non-blank lines from each side.

The script uses the Python standard library only. Exit status: 0 when every
copy matches its source, 1 when one does not, 2 on a usage error. --help
(or -h) prints the usage line and this text on stderr and exits 2. The
script takes no other argument: given one, it names each argument on stderr
on a line of its own, "unknown option: --verbose" for one that starts with
"-" and "unexpected argument: README.md" for any other, then prints "this
checker takes no arguments" and the usage line, and exits 2.
"""

import difflib
import os
import re
import sys

COPIES = [
    ("framework/full-assessment.md", "toolkit/assessment/full-assessment.md"),
    (
        "framework/Complete_QRAMM_Questions.md",
        "toolkit/assessment/Complete_QRAMM_Questions.md",
    ),
]

MAX_SHOWN = 5

LINK = re.compile(r"\]\(([^)\s]+)\)")

USAGE = "usage: python3 -I scripts/check-assessment-copies.py"


def resolve_links(root, relative, line):
    """The line with each relative link target replaced by its repository path."""
    base = os.path.dirname(os.path.join(root, relative))

    def resolve(match):
        target = match.group(1)
        if re.match(r"^[a-z]+:", target) or target.startswith("#"):
            return match.group(0)
        path, sep, anchor = target.partition("#")
        resolved = os.path.relpath(os.path.normpath(os.path.join(base, path)), root)
        return "]({}{}{})".format(resolved, sep, anchor)

    return LINK.sub(resolve, line)


def read_lines(root, relative):
    with open(os.path.join(root, relative), encoding="utf-8") as fh:
        return fh.read().splitlines()


def span(start, end):
    """The 0-based half-open range start to end as 1-based line numbers."""
    if end - start == 1:
        return "line {}".format(end)
    return "lines {}-{}".format(start + 1, end)


def shown(label, lines, start, end):
    """Indented "label N: text" lines for the non-blank lines in the range."""
    numbered = [(n + 1, lines[n]) for n in range(start, end) if lines[n].strip()]
    out = [
        "         {} {}: {}".format(label, number, text)
        for number, text in numbered[:MAX_SHOWN]
    ]
    if len(numbered) > MAX_SHOWN:
        out.append("         ... {} more".format(len(numbered) - MAX_SHOWN))
    return out


def compare(root, source, copy, problems):
    """Adds a problem for each run of lines where copy differs from source."""
    source_lines = read_lines(root, source)
    copy_lines = read_lines(root, copy)
    matcher = difflib.SequenceMatcher(
        None,
        [resolve_links(root, source, line) for line in source_lines],
        [resolve_links(root, copy, line) for line in copy_lines],
        autojunk=False,
    )
    count = 0
    for tag, i1, i2, j1, j2 in matcher.get_opcodes():
        if tag == "equal":
            continue
        count += 1
        if tag == "delete":
            head = "{}: {} {} {} missing (after copy line {})".format(
                copy, source, span(i1, i2), "is" if i2 - i1 == 1 else "are", j1
            )
        elif tag == "insert":
            head = "{} {}: not in {} (after source line {})".format(
                copy, span(j1, j2), source, i1
            )
        else:
            head = "{} {}: differ from {} {}".format(
                copy, span(j1, j2), source, span(i1, i2)
            )
        detail = shown("source", source_lines, i1, i2)
        detail += shown("copy", copy_lines, j1, j2)
        problems.append("\n".join([head] + detail))
    return count


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
    for source, copy in COPIES:
        print("== {} against {}".format(copy, source))
        try:
            differences = compare(root, source, copy, problems)
        except OSError as error:
            problems.append(
                "{}: cannot read ({})".format(
                    os.path.relpath(error.filename, root), error.strerror
                )
            )
            continue
        if differences == 0:
            print("  PASS same lines as {}".format(source))

    for problem in problems:
        print("  FAIL {}".format(problem))
    print("RESULT: {}".format("FAIL" if problems else "PASS"))
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
