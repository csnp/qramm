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
#   passwords  A line that records a password must have the value None. The
#              shapes recognised are "password" (any case, with or without
#              list markers, bold or code formatting) followed by a colon, an
#              equals sign, a fullwidth colon (U+FF1A) or a fullwidth equals
#              sign (U+FF1D), and the sentence forms "password is set to" and
#              "password was set to". The value is the rest of the line,
#              without the white space and formatting marks around it. If
#              sheet or workbook protection is added to the toolkit, it is
#              applied without a password, so any value other than None,
#              including an empty one, fails.
#              Values are never printed, only the file and line number.
#              A line that contains "password" (any case) in no recognised
#              shape is not judged, and the summary line counts it.
#
# The check fails when a given file does not exist, is a directory or is not
# UTF-8 text, and when no tracked Markdown file is found under toolkit-specs/,
# so it cannot pass by reading nothing. With no file arguments it needs a git
# checkout to list the tracked files; in a copy that is not one (for example a
# downloaded archive) it fails with a one-line message that says so. Pass the
# files to check as arguments there instead.
#
# An empty file argument fails with "no file name given".
#
# Exit status: 0 when every check passes, 1 when any check fails or a file
# cannot be read, 2 on a usage error. --help (or -h) prints the usage line and
# this text on stderr and exits 2.
set -euo pipefail

usage="usage: bash scripts/check-spec-passwords.sh [file ...]"
for arg in "$@"; do
  case "$arg" in
    -h | --help)
      {
        printf '%s\n\n' "$usage"
        awk 'NR > 1 && /^#/ { sub(/^# ?/, ""); print; next } NR > 1 { exit }' \
          "${BASH_SOURCE[0]}"
      } >&2
      exit 2
      ;;
  esac
done

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

exec python3 -I - "$repo_root" "$@" <<'PY'
import os
import re
import subprocess
import sys

SPECS_DIR = "toolkit-specs"

# The separators that can follow "Password": a colon, an equals sign, a
# fullwidth colon (U+FF1A) and a fullwidth equals sign (U+FF1D).
SEPARATORS = ":=\N{FULLWIDTH COLON}\N{FULLWIDTH EQUALS SIGN}"

# "Password" followed by one of SEPARATORS, or by "is set to" or "was set
# to", allowing Markdown emphasis or code marks around the word and around
# the separator. The value is the rest of the line.
PASSWORD_LINE = re.compile(
    r"password[*_`]*(?:\s*[" + SEPARATORS + r"]|\s+(?:is|was)\s+set\s+to\b)"
    r"[*_`]*(.*)$",
    re.I,
)

# A mention of a password. A line with one that PASSWORD_LINE does not match
# is counted, not judged.
PASSWORD_MENTION = re.compile(r"password", re.I)

ALLOWED_VALUE = "None"


class GitListError(Exception):
    """git could not list the tracked files. The message is one line."""


def untranslated_env():
    """The environment, set so git prints its messages untranslated.

    git built with translations prints its messages in the language the
    environment selects, so the "not a git repository" match in
    tracked_specs needs the C locale. LANG is set as well as LC_ALL: git
    2.53 from Homebrew on macOS translates by LANG when LC_ALL=C is set.
    """
    return dict(os.environ, LC_ALL="C", LANG="C")


def tracked_specs(root):
    """Tracked Markdown files under toolkit-specs/, as absolute paths.

    Raises GitListError when git cannot list them, for example in a copy of
    the repository that is not a git checkout.
    """
    try:
        result = subprocess.run(
            ["git", "-C", root, "ls-files", "-z", "--", SPECS_DIR + "/*.md"],
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
    output = result.stdout.decode("utf-8")
    return [os.path.join(root, name) for name in output.split("\0") if name]


def check_passwords(lines):
    """Return (problems, password lines seen, other lines that mention a
    password). Problems never carry a value."""
    problems = []
    seen = 0
    unjudged = 0
    for number, line in enumerate(lines, 1):
        m = PASSWORD_LINE.search(line)
        if not m:
            if PASSWORD_MENTION.search(line):
                unjudged += 1
            continue
        seen += 1
        value = m.group(1).strip().strip("*_`").strip()
        if value != ALLOWED_VALUE:
            problems.append(
                "line {}: Password line has a value other than {} "
                "(value not shown)".format(number, ALLOWED_VALUE)
            )
    return problems, seen, unjudged


def main(argv):
    root = os.path.realpath(argv[0])
    args = argv[1:]
    unknown = [a for a in args if a.startswith("-")]
    if unknown:
        print("unknown option: {}".format(" ".join(unknown)), file=sys.stderr)
        print("usage: bash scripts/check-spec-passwords.sh [file ...]", file=sys.stderr)
        return 2
    if args:
        files = args
    else:
        try:
            files = tracked_specs(root)
        except GitListError as err:
            print(
                "FAIL cannot list tracked files under {}/: {}; "
                "pass the files to check as arguments".format(SPECS_DIR, err)
            )
            print("RESULT: FAIL")
            return 1

    if not files:
        print("FAIL no tracked Markdown files under {}/".format(SPECS_DIR))
        print("RESULT: FAIL")
        return 1

    failed = False
    total_seen = 0
    total_unjudged = 0
    for given in files:
        if not given:
            print("== ''")
            print("  FAIL file: no file name given")
            failed = True
            continue
        path = os.path.realpath(given)
        rel = os.path.relpath(path, root)
        label = path if rel.startswith("..") else rel
        if os.path.isdir(path):
            print("== {}".format(label))
            print("  FAIL file: is a directory")
            failed = True
            continue
        if not os.path.isfile(path):
            print("== {}".format(label))
            print("  FAIL file: not found")
            failed = True
            continue
        try:
            with open(path, encoding="utf-8") as fh:
                lines = fh.read().splitlines()
        except OSError as error:
            print("== {}".format(label))
            print("  FAIL file: cannot read ({})".format(error.strerror))
            failed = True
            continue
        except UnicodeDecodeError:
            # A file whose bytes are not UTF-8.
            print("== {}".format(label))
            print("  FAIL file: cannot read (not UTF-8 text)")
            failed = True
            continue
        problems, seen, unjudged = check_passwords(lines)
        total_seen += seen
        total_unjudged += unjudged
        if problems:
            failed = True
            print("== {}".format(label))
            print("  FAIL passwords ({} Password lines)".format(seen))
            for problem in problems:
                print("    {}".format(problem))

    print(
        "{} files checked, {} Password lines found, {} other lines mention a "
        "password (not judged)".format(len(files), total_seen, total_unjudged)
    )
    print("RESULT: {}".format("FAIL" if failed else "PASS"))
    return 1 if failed else 0


sys.exit(main(sys.argv[1:]))
PY
