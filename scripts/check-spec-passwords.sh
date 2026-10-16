#!/usr/bin/env bash
# Checks that the toolkit specs do not record a password.
#
# Usage:
#   scripts/check-spec-passwords.sh [file ...]
#
# With no file arguments, every tracked Markdown file under toolkit-specs/ is
# checked. Pass files to check those instead (for example a copy outside the
# repository).
#
# Check, for every file:
#   passwords  A line carrying "Password:" (any case, with or without list
#              markers, bold or code formatting) must have the value None.
#              Sheet and workbook protection in the toolkit is applied without
#              a password, so any other value, including an empty one, fails.
#              Values are never printed, only the file and line number.
#
# The check fails when a given file does not exist, and when no tracked
# Markdown file is found under toolkit-specs/, so it cannot pass by reading
# nothing.
#
# Exit status: 0 when every check passes, 1 when any check fails, 2 on a
# usage error.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

exec python3 -I - "$repo_root" "$@" <<'PY'
import os
import re
import subprocess
import sys

SPECS_DIR = "toolkit-specs"

# "Password" followed by a colon, allowing Markdown emphasis or code marks
# around the word and around the colon.
PASSWORD_LINE = re.compile(r"password[*_`]*\s*:[*_`]*(.*)$", re.I)

ALLOWED_VALUE = "None"


def tracked_specs(root):
    """Tracked Markdown files under toolkit-specs/, as absolute paths."""
    output = subprocess.run(
        ["git", "-C", root, "ls-files", "-z", "--", SPECS_DIR + "/*.md"],
        check=True,
        capture_output=True,
    ).stdout.decode("utf-8")
    return [os.path.join(root, name) for name in output.split("\0") if name]


def check_passwords(lines):
    """Return (problems, password lines seen). Problems never carry a value."""
    problems = []
    seen = 0
    for number, line in enumerate(lines, 1):
        m = PASSWORD_LINE.search(line)
        if not m:
            continue
        seen += 1
        value = m.group(1).strip().strip("*_`").strip()
        if value != ALLOWED_VALUE:
            problems.append(
                "line {}: Password line has a value other than {} "
                "(value not shown)".format(number, ALLOWED_VALUE)
            )
    return problems, seen


def main(argv):
    root = os.path.realpath(argv[0])
    args = argv[1:]
    unknown = [a for a in args if a.startswith("-")]
    if unknown:
        print("unknown option: {}".format(" ".join(unknown)), file=sys.stderr)
        return 2
    files = args or tracked_specs(root)

    if not files:
        print("FAIL no tracked Markdown files under {}/".format(SPECS_DIR))
        print("RESULT: FAIL")
        return 1

    failed = False
    total_seen = 0
    for given in files:
        path = os.path.realpath(given)
        rel = os.path.relpath(path, root)
        label = path if rel.startswith("..") else rel
        if not os.path.isfile(path):
            print("== {}".format(label))
            print("  FAIL file: not found")
            failed = True
            continue
        with open(path, encoding="utf-8") as fh:
            lines = fh.read().splitlines()
        problems, seen = check_passwords(lines)
        total_seen += seen
        if problems:
            failed = True
            print("== {}".format(label))
            print("  FAIL passwords ({} Password lines)".format(seen))
            for problem in problems:
                print("    {}".format(problem))

    print(
        "{} files checked, {} Password lines found".format(len(files), total_seen)
    )
    print("RESULT: {}".format("FAIL" if failed else "PASS"))
    return 1 if failed else 0


sys.exit(main(sys.argv[1:]))
PY
