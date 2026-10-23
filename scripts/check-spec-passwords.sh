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
#   passwords  A line that records a password must have the value None.
#              Each line is first normalised: Unicode NFKC, then invisible
#              format characters (Unicode category Cf) are removed, so a
#              fullwidth spelling of a word or separator reads the same as
#              the plain one.
#              Words: "password", "passphrase" and "passcode" (any case, a
#              trailing "s" allowed, with or without list markers, bold or
#              code formatting), and "pwd" and "unlock with".
#              Separators: a colon (:), an equals sign (=), an en dash
#              (U+2013) and an em dash (U+2014). A fullwidth colon or equals
#              sign is read as the plain one after normalising.
#              A line is a Password line when one of the words is followed
#              by a separator, or when "password", "passphrase" or "passcode"
#              is followed by "is set to" or "was set to". "pwd" and "unlock
#              with" count only with a separator after them, because the bare
#              words have ordinary uses (the shell command, "unlock with the
#              Review tab"). The value is the rest of the line, without the
#              white space and formatting marks around it. It is read from
#              the normalised line and from the line as written, and both
#              readings must be None, so None in fullwidth letters fails, and
#              so does a value with a format character in it, such as None
#              followed by Unicode tag characters (U+E0000 to U+E007F), or
#              None with a zero width space (U+200B) or a soft hyphen
#              (U+00AD) inside it. If sheet or workbook protection is added
#              to the toolkit, it is applied without a password, so any
#              value other than None, including an empty one, fails.
#              Any other mention of "password", "passphrase" or "passcode"
#              (any case, also inside a longer word such as
#              "password-protected") fails unless it reads "without a
#              password", "without any password", "no password" or "no
#              passwords" (or the same with passphrase or passcode). Each
#              mention is judged on its own, so one mention in that form does
#              not clear another on the same line. A Password line is judged
#              by its value first, and a mention before the separator is
#              judged the same way. The fix is to write "Password: None", or
#              "without a password".
#              A value written under a word that is not listed here is not
#              read. A password applied to a workbook is not read either;
#              this check reads only the text of the specs.
#              Values are never printed, only the file and line number.
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
# this text on stderr and exits 2. Any other argument that starts with "-",
# such as --verbose or --, is an unknown option: each one is named on stderr
# on a line of its own, such as "unknown option: --verbose", before the usage
# line, and the exit status is 2.
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
import unicodedata

SPECS_DIR = "toolkit-specs"

# The words that name a password. Any mention of one is judged.
WORDS = ("password", "passphrase", "passcode")

# Words that are judged only with a separator after them, because the bare
# words have ordinary uses.
GUARDED_WORDS = ("pwd", "unlock with")

# The separators that can follow a word. A fullwidth colon or equals sign
# becomes the plain one under NFKC, so it needs no entry of its own.
SEPARATORS = (":", "=", "\N{EN DASH}", "\N{EM DASH}")

# The sentence forms that can follow one of WORDS in place of a separator.
SENTENCE_FORMS = ("is set to", "was set to")

# The accepted ways of saying there is no password, with {} for the word.
NO_PASSWORD_FORMS = ("without a {}", "without any {}", "no {}", "no {}s")


def phrase_pattern(phrase):
    """A regex for phrase, with any white space between its words."""
    return re.escape(phrase).replace(r"\ ", r"\s+")


def words_pattern(words):
    """A regex alternation of words, with any white space inside each."""
    return "|".join(map(phrase_pattern, words))


_WORD = r"(?:" + words_pattern(WORDS) + r")s?"
_SEPARATOR = r"\s*[" + "".join(map(re.escape, SEPARATORS)) + r"]"
_SENTENCE = r"\s+(?:" + words_pattern(SENTENCE_FORMS) + r")\b"

# One of WORDS followed by a separator or a sentence form, or one of
# GUARDED_WORDS followed by a separator, allowing Markdown emphasis or code
# marks around the word and around the separator. The group is the rest of
# the line, from the end of the separator or sentence form; value_in reads
# the value from it.
PASSWORD_LINE = re.compile(
    r"(?:" + _WORD + r"[*_`]*(?:" + _SEPARATOR + r"|" + _SENTENCE + r")"
    r"|\b(?:" + words_pattern(GUARDED_WORDS) + r")\b[*_`]*" + _SEPARATOR + r")"
    r"(.*)$",
    re.I,
)

# A mention of one of WORDS, also inside a longer word.
PASSWORD_MENTION = re.compile(words_pattern(WORDS), re.I)

# A mention in one of NO_PASSWORD_FORMS.
NO_PASSWORD = re.compile(
    r"\b(?:"
    + "|".join(
        phrase_pattern(form).replace(
            re.escape("{}"), "(?:" + words_pattern(WORDS) + ")"
        )
        for form in NO_PASSWORD_FORMS
    )
    + r")\b",
    re.I,
)

ALLOWED_VALUE = "None"


def normalise(line):
    """The line under Unicode NFKC, without format characters (Cf)."""
    line = unicodedata.normalize("NFKC", line)
    return "".join(c for c in line if unicodedata.category(c) != "Cf")


def value_in(rest):
    """The value in rest, the text after a separator or sentence form,
    without the white space and formatting marks around it."""
    return rest.lstrip("*_`").strip().strip("*_`").strip()


def starts_piece(line, piece, end, first):
    """Whether a character whose NFKD decomposition starts with first starts
    a new piece after line[piece:end], the piece before it: whether first is
    a starter (combining class 0) that does not compose with the last
    character of the NFKC form of that piece. Normalising never moves such a
    starter, and composes nothing after it with anything before it, so a
    line normalises to its text up to the character normalised, followed by
    the rest normalised on its own.

    The piece is copied out of line only after first is found to be a
    starter, so a run of characters whose decomposition starts with a
    combining mark, none of which starts a new piece, does not copy the
    piece once for each character."""
    if unicodedata.combining(first):
        return False
    last = unicodedata.normalize("NFKC", line[piece:end])[-1]
    return unicodedata.normalize("NFKC", last + first) == last + first


def written_rest(line, start):
    """The text of line after its shortest beginning that normalises to start
    characters or more, as written: for a start just after a separator, the
    rest of the line with its format characters and fullwidth letters.

    The line is read in pieces (see starts_piece), so a beginning normalises
    to the whole pieces in it normalised, followed by its part of the last
    piece normalised. The loop adds up the normalised lengths of the whole
    pieces as it goes. It works out the normalised length of the part only
    when that sum and the length of the part after NFKD decomposition,
    which normalising never makes longer, reach start together."""
    before = 0  # normalised length of line[:piece]
    piece = 0  # where the last piece starts
    at_most = 0  # length of line[piece:end] after NFKD decomposition
    end = 0
    while before + at_most < start or before + len(normalise(line[piece:end])) < start:
        decomposed = unicodedata.normalize("NFKD", line[end])
        if end > piece and starts_piece(line, piece, end, decomposed[0]):
            before += len(normalise(line[piece:end]))
            piece = end
            at_most = 0
        at_most += len(decomposed)
        end += 1
    return line[end:]


def unexplained_mentions(text):
    """Whether text mentions a password outside NO_PASSWORD_FORMS."""
    accepted = [m.span() for m in NO_PASSWORD.finditer(text)]
    for mention in PASSWORD_MENTION.finditer(text):
        start, end = mention.span()
        if not any(a <= start and end <= b for a, b in accepted):
            return True
    return False


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
    """Return (problems, password lines seen, other lines that say there is
    no password). Problems never carry a value."""
    problems = []
    seen = 0
    no_password = 0
    unexplained = (
        "line {}: mentions a password in no recognised shape (text not "
        'shown); write "Password: None", or "without a password"'
    )
    for number, written in enumerate(lines, 1):
        line = normalise(written)
        m = PASSWORD_LINE.search(line)
        if not m:
            if unexplained_mentions(line):
                problems.append(unexplained.format(number))
            elif PASSWORD_MENTION.search(line):
                no_password += 1
            continue
        seen += 1
        # The value must be None as written too: normalising reads None in
        # fullwidth letters, or None with format characters inside or after
        # it, as None.
        if (
            value_in(m.group(1)) != ALLOWED_VALUE
            or value_in(written_rest(written, m.start(1))) != ALLOWED_VALUE
        ):
            problems.append(
                "line {}: Password line has a value other than {} "
                "(value not shown)".format(number, ALLOWED_VALUE)
            )
        elif unexplained_mentions(line[: m.start()]):
            problems.append(unexplained.format(number))
    return problems, seen, no_password


def main(argv):
    root = os.path.realpath(argv[0])
    args = argv[1:]
    unknown = [a for a in args if a.startswith("-")]
    if unknown:
        for arg in unknown:
            print("unknown option: {}".format(arg), file=sys.stderr)
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
    total_no_password = 0
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
        problems, seen, no_password = check_passwords(lines)
        total_seen += seen
        total_no_password += no_password
        if problems:
            failed = True
            print("== {}".format(label))
            print("  FAIL passwords ({} Password lines)".format(seen))
            for problem in problems:
                print("    {}".format(problem))

    print(
        "{} files checked, {} Password lines found, {} other lines say there "
        "is no password".format(len(files), total_seen, total_no_password)
    )
    print("RESULT: {}".format("FAIL" if failed else "PASS"))
    return 1 if failed else 0


sys.exit(main(sys.argv[1:]))
PY
