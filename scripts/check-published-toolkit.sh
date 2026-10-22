#!/usr/bin/env bash
# Checks that qramm.org serves the same toolkit workbooks as this repository.
#
# Usage:
#   scripts/check-published-toolkit.sh [--base-url URL] [workbook ...]
#
# The contract this script checks: the workbook a visitor downloads from
# qramm.org is the file in this repository, byte for byte. The workbooks
# under toolkit/ are the source files, and the site serves copies of them.
#
# With no workbook arguments, the workbooks in WORKBOOKS (inside the Python
# block below) are checked: toolkit/QRAMM_Assessment_Toolkit.xlsx and
# toolkit/Sample_Assessment.xlsx. Pass workbooks to check those instead, as
# paths relative to the repository root or as absolute paths.
#
# Check, for every workbook: the file served at the base URL followed by the
# workbook's path relative to the repository root, for example
# https://qramm.org/toolkit/Sample_Assessment.xlsx, has the same length and
# the same sha256 hash as the workbook. The request sends the User-Agent
# qramm-published-toolkit-check, has a timeout of 30 seconds and follows
# redirects. Under the line "== <URL> against <path>" the result is
# "PASS same file" or "FAIL published copy differs", with the length and the
# full sha256 hash of each copy. The contents of a file are never printed.
#
# --base-url sets the site and defaults to https://qramm.org, so by default
# the check needs network access. A file:// URL names a local directory laid
# out like the site instead; scripts/test-check-published-toolkit.sh uses one
# so that it runs without network access.
#
# The check fails when a workbook does not exist or is a directory, when it
# is outside the repository, which leaves it no address on the site, and when
# the served file cannot be fetched; the FAIL line gives the reason. A
# directory fails with "is a directory", in the repository or outside it. An
# empty workbook argument fails with "no file name given".
#
# Exit status: 0 when every check passes, 1 when any check fails, 2 on a
# usage error. --help (or -h) prints the usage line and this text on stderr
# and exits 2. Any other argument that starts with "-", such as --verbose or
# --, is an unknown option: each one is named on stderr on a line of its own,
# such as "unknown option: --verbose", before the usage line, and the exit
# status is 2.
set -euo pipefail

usage="usage: bash scripts/check-published-toolkit.sh [--base-url URL] [workbook ...]"
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
import hashlib
import http.client
import os
import sys
import urllib.error
import urllib.parse
import urllib.request

USAGE = "usage: bash scripts/check-published-toolkit.sh [--base-url URL] [workbook ...]"

# The site the workbooks are published on. A workbook's address there is
# this URL followed by the workbook's path relative to the repository root.
BASE_URL = "https://qramm.org"

# The workbooks checked when no workbook is given, relative to the
# repository root.
WORKBOOKS = ["toolkit/QRAMM_Assessment_Toolkit.xlsx", "toolkit/Sample_Assessment.xlsx"]

USER_AGENT = "qramm-published-toolkit-check"
TIMEOUT_SECONDS = 30
CHUNK_BYTES = 64 * 1024

# What a failed fetch raises: urllib's errors, an incomplete or malformed
# answer, a network or file error, and a URL that urllib cannot parse.
FETCH_ERRORS = (urllib.error.URLError, http.client.HTTPException, OSError, ValueError)


def measure(stream):
    """Return (length, sha256 hex digest) of the bytes read from stream."""
    digest = hashlib.sha256()
    length = 0
    while True:
        chunk = stream.read(CHUNK_BYTES)
        if not chunk:
            break
        digest.update(chunk)
        length += len(chunk)
    return length, digest.hexdigest()


def measure_served(url):
    """Return (length, sha256 hex digest) of the file served at url."""
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request, timeout=TIMEOUT_SECONDS) as response:
        return measure(response)


def fetch_failure(err):
    """Why a fetch failed, as one line without a traceback."""
    if isinstance(err, urllib.error.HTTPError):
        return "answered {}, expected 200".format(err.code)
    if isinstance(err, urllib.error.URLError):
        err = err.reason
    text = getattr(err, "strerror", None) or str(err) or type(err).__name__
    return " ".join(text.split())


def main(argv):
    # A file name or a reason can hold a character that stdout cannot
    # encode; print it as a backslash escape rather than fail.
    sys.stdout.reconfigure(errors="backslashreplace")
    root = os.path.realpath(argv[0])
    base_url = BASE_URL
    workbooks = []
    unknown = []
    args = iter(argv[1:])
    for arg in args:
        if arg == "--base-url":
            base_url = next(args, "")
            if not base_url or base_url.startswith("-"):
                print("--base-url needs a URL", file=sys.stderr)
                print(USAGE, file=sys.stderr)
                return 2
        elif arg.startswith("-"):
            unknown.append(arg)
        else:
            workbooks.append(arg)
    if unknown:
        for arg in unknown:
            print("unknown option: {}".format(arg), file=sys.stderr)
        print(USAGE, file=sys.stderr)
        return 2
    base_url = base_url.rstrip("/")

    failed = False
    for given in workbooks or WORKBOOKS:
        if not given:
            print("== ''")
            print("  FAIL file: no file name given")
            failed = True
            continue
        path = os.path.realpath(os.path.join(root, given))
        rel = os.path.relpath(path, root)
        if rel == os.pardir or rel.startswith(os.pardir + os.sep):
            print("== {}".format(path))
            if os.path.isdir(path):
                print("  FAIL file: is a directory")
            elif os.path.isfile(path):
                print("  FAIL file: not in the repository")
            else:
                print("  FAIL file: not found")
            failed = True
            continue
        url = base_url + "/" + urllib.parse.quote(os.fsencode(rel.replace(os.sep, "/")))
        print("== {} against {}".format(url, rel))
        if os.path.isdir(path):
            print("  FAIL file: is a directory")
            failed = True
            continue
        if not os.path.isfile(path):
            print("  FAIL file: not found")
            failed = True
            continue
        try:
            with open(path, "rb") as fh:
                local = measure(fh)
        except OSError as err:
            print("  FAIL file: cannot read ({})".format(err.strerror or err))
            failed = True
            continue
        try:
            served = measure_served(url)
        except FETCH_ERRORS as err:
            print("  FAIL cannot fetch ({})".format(fetch_failure(err)))
            failed = True
            continue
        if served == local:
            print("  PASS same file ({} bytes, sha256 {})".format(*local))
        else:
            failed = True
            print(
                "  FAIL published copy differs: served {} bytes, sha256 {}; "
                "repository {} bytes, sha256 {}".format(*(served + local))
            )

    print("RESULT: {}".format("FAIL" if failed else "PASS"))
    return 1 if failed else 0


sys.exit(main(sys.argv[1:]))
PY
