#!/usr/bin/env bash
# Checks QRAMM framework documents before they are merged.
#
# Usage:
#   scripts/check-framework-docs.sh [--no-network] [file ...]
#
# With no file arguments, the documents in DEFAULT_DOCS (inside the Python
# block below) are checked: README.md, every Markdown document the README
# links, every Markdown file in a directory the README links, and the
# toolkit's copies of the question documents. Add a document to that list,
# in sorted order, when the README starts to link it or when a new framework
# document is written, so that it inherits these checks.
# scripts/test-check-framework-docs-defaults.sh fails when a document the
# README links is missing from the list.
#
# Checks, for every file:
#   writing    No em dashes, no emoji, none of the banned superlatives.
#   practices  Every "Practice N.N" names a practice that exists in
#              framework/qramm-overview.md. When a name follows in
#              parentheses it must match the overview, and every question
#              number cited after it must belong to that practice in
#              framework/Complete_QRAMM_Questions.md.
#   links      Every relative link resolves to a file in the repository, and
#              every external http(s) URL answers 200 (skipped with
#              --no-network).
#
# Extra checks for framework/pqcmm-comparison.md (any file with that name):
#   pqcmm      The first table whose header names "PQCMM level" lists each
#              level 0 to 5 exactly once, the document cites the PQCMM levels
#              page and a fetch date, and at least one practice is referenced.
#              With network, each level name, and each quoted summary in the
#              table's second column, must still appear on the PQCMM levels
#              page.
#
# Extra checks for framework/compliance-mapping.md (any file with that name):
#   nist       In every table whose header has a "NIST PQC" column, each row
#              that starts with a question number (**Qn.n.n**) has a NIST PQC
#              cell that is "-" or names a publication number: FIPS n, NIST
#              SP n-n, NIST IR n or OMB M-nn-nn. A label such as "NIST
#              Testing Guide" names no publication and fails.
#
# An empty file argument fails with "no file name given".
#
# Exit status: 0 when every check passes, 1 when any check fails, 2 on a
# usage error. --help (or -h) prints the usage line and this text on stderr
# and exits 2.
set -euo pipefail

usage="usage: bash scripts/check-framework-docs.sh [--no-network] [file ...]"
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
import html
import os
import re
import sys
import urllib.error
import urllib.request

DEFAULT_DOCS = [
    "README.md",
    "docs/faq.md",
    "docs/overview.md",
    "docs/toolkit-visuals.md",
    "framework/Complete_QRAMM_Questions.md",
    "framework/compliance-coverage-summary.md",
    "framework/compliance-mapping.md",
    "framework/full-assessment.md",
    "framework/maturity-levels.md",
    "framework/pqcmm-comparison.md",
    "framework/qramm-overview.md",
    "framework/scoring-methodology.md",
    "implementation/getting-started.md",
    "templates/asset-inventory-template.md",
    "templates/evidence-collection-template.md",
    "templates/executive-report-template.md",
    "templates/vendor-questionnaire-template.md",
    "toolkit/assessment/Complete_QRAMM_Questions.md",
    "toolkit/assessment/full-assessment.md",
    "toolkit/toolkit-overview.md",
]

PQCMM_DOC = "framework/pqcmm-comparison.md"
PQCMM_LEVELS_URL = "https://pkic.org/wg/pqc/pqcmm/levels/"

MAPPING_DOC = "framework/compliance-mapping.md"
NIST_COLUMN = "NIST PQC"
NIST_PUBLICATION = re.compile(
    r"\b(?:FIPS \d+|NIST SP \d+-\d+|NIST IR \d+|OMB M-\d{2}-\d{2})"
)

BANNED_PHRASES = [
    "industry-leading",
    "industry leading",
    "world-class",
    "world class",
    "best-in-class",
    "best in class",
    "cutting-edge",
    "cutting edge",
    "state-of-the-art",
    "state of the art",
    "leading-edge",
    "next-generation",
    "revolutionary",
    "game-changing",
    "game changer",
    "groundbreaking",
    "unparalleled",
    "unmatched",
    "why this matters",
]

EM_DASH = "—"

# Emoji and pictograph blocks, plus the joiner and presentation selector that
# build emoji sequences. Box drawing and arrows are not in these ranges.
EMOJI_RANGES = [
    (0x1F000, 0x1FAFF),
    (0x2600, 0x27BF),
    (0x2B00, 0x2BFF),
    (0xFE0F, 0xFE0F),
    (0x200D, 0x200D),
]

PRACTICE_REF = re.compile(
    r"Practice (\d+\.\d+)(?: \(([^)]+)\))?((?:,? questions? [\d, and]+)?)"
)


def is_emoji(ch):
    cp = ord(ch)
    return any(lo <= cp <= hi for lo, hi in EMOJI_RANGES)


def load_practices(root):
    """Practice id -> name, from the framework overview."""
    path = os.path.join(root, "framework/qramm-overview.md")
    with open(path, encoding="utf-8") as fh:
        text = fh.read()
    return {
        m.group(1): m.group(2).strip()
        for m in re.finditer(r"^- \*\*(\d+\.\d+) ([^*]+)\*\*", text, re.M)
    }


def load_questions(root):
    """Practice id -> set of question numbers, from the question bank."""
    path = os.path.join(root, "framework/Complete_QRAMM_Questions.md")
    result = {}
    current = None
    with open(path, encoding="utf-8") as fh:
        for line in fh:
            heading = re.match(r"^### Practice (\d+\.\d+):", line)
            if heading:
                current = heading.group(1)
                result[current] = set()
                continue
            question = re.match(r"^(\d+)\. ", line)
            if question and current:
                result[current].add(int(question.group(1)))
    return result


def strip_code(lines):
    """Yield (line number, text) outside fenced code blocks."""
    fenced = False
    for number, line in enumerate(lines, 1):
        if line.lstrip().startswith("```"):
            fenced = not fenced
            continue
        if not fenced:
            yield number, line


def page_text(url):
    """Fetch a page and return its visible text with whitespace collapsed."""
    request = urllib.request.Request(
        url, headers={"User-Agent": "qramm-framework-docs-check"}
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        body = response.read().decode("utf-8", "replace")
    body = re.sub(r"<(script|style)\b.*?</\1>", " ", body, flags=re.S)
    body = re.sub(r"<[^>]+>", " ", body)
    return re.sub(r"\s+", " ", html.unescape(body))


def url_status(url):
    request = urllib.request.Request(
        url, headers={"User-Agent": "qramm-framework-docs-check"}
    )
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            return response.status
    except urllib.error.HTTPError as err:
        return err.code
    except (urllib.error.URLError, OSError) as err:
        return "no response ({})".format(err)


def check_writing(lines):
    problems = []
    for number, line in enumerate(lines, 1):
        if EM_DASH in line:
            problems.append("line {}: em dash".format(number))
        emoji = sorted({ch for ch in line if is_emoji(ch)})
        if emoji:
            codes = ", ".join("U+{:04X}".format(ord(ch)) for ch in emoji)
            problems.append("line {}: emoji {}".format(number, codes))
        lower = line.lower()
        for phrase in BANNED_PHRASES:
            if re.search(r"\b" + re.escape(phrase) + r"\b", lower):
                problems.append("line {}: banned phrase '{}'".format(number, phrase))
    return problems


def check_practices(lines, practices, questions):
    problems = []
    count = 0
    for number, line in strip_code(lines):
        for match in PRACTICE_REF.finditer(line):
            count += 1
            pid, name, cited = match.group(1), match.group(2), match.group(3)
            if pid not in practices:
                problems.append(
                    "line {}: Practice {} is not in qramm-overview.md".format(number, pid)
                )
                continue
            if name and name.strip() != practices[pid]:
                problems.append(
                    "line {}: Practice {} is named '{}' here but '{}' in "
                    "qramm-overview.md".format(number, pid, name.strip(), practices[pid])
                )
            for q in (int(n) for n in re.findall(r"\d+", cited or "")):
                if q not in questions.get(pid, set()):
                    problems.append(
                        "line {}: question {} is not part of Practice {}".format(
                            number, q, pid
                        )
                    )
    return problems, count


def check_links(path, lines, root, network):
    problems = []
    external = []
    base = os.path.dirname(path)
    for number, line in strip_code(lines):
        for target in re.findall(r"\]\(([^)\s]+)\)", line):
            if re.match(r"^[a-z]+:", target) or target.startswith("#"):
                continue
            local = target.split("#", 1)[0]
            resolved = os.path.normpath(os.path.join(base, local))
            if not resolved.startswith(root) or not os.path.exists(resolved):
                problems.append(
                    "line {}: relative link '{}' does not resolve".format(number, target)
                )
        for url in re.findall(r"https?://[^\s)<>\]|\"'`]+", line):
            # Leave out sentence punctuation and the asterisks that close
            # italic or bold text, as in "*visit https://qramm.org*".
            url = url.rstrip(".,;:*")
            if url not in [u for _, u in external]:
                external.append((number, url))
    if network:
        for number, url in external:
            status = url_status(url)
            if status != 200:
                problems.append(
                    "line {}: {} answered {}, expected 200".format(number, url, status)
                )
    return problems, len(external)


def split_row(line):
    return [cell.strip() for cell in line.strip().strip("|").split("|")]


def level_table(lines):
    """Rows of the first table whose header names 'PQCMM level'."""
    rows = []
    in_table = False
    for number, line in strip_code(lines):
        if not in_table:
            if line.lstrip().startswith("|") and "pqcmm level" in line.lower():
                in_table = True
            continue
        if not line.lstrip().startswith("|"):
            break
        cells = split_row(line)
        if all(re.fullmatch(r":?-{3,}:?", c) for c in cells if c):
            continue
        rows.append((number, cells))
    return in_table, rows


def check_pqcmm(lines, practice_count, network):
    problems = []
    text = "\n".join(lines)
    if PQCMM_LEVELS_URL not in text:
        problems.append("the PQCMM levels page {} is not cited".format(PQCMM_LEVELS_URL))
    if not re.search(r"fetched (on )?\d{4}-\d{2}-\d{2}", text):
        problems.append("no fetch date in the form 'fetched YYYY-MM-DD'")
    if practice_count == 0:
        problems.append("no QRAMM practice is referenced")

    found, rows = level_table(lines)
    if not found:
        problems.append("no table with a 'PQCMM level' header")
        return problems
    seen = {}
    for number, cells in rows:
        m = re.match(r"^(?:\*\*)?Level (\d+): ([A-Za-z]+)", cells[0])
        if not m:
            problems.append("line {}: first cell is not 'Level N: Name'".format(number))
            continue
        seen.setdefault(int(m.group(1)), []).append((number, m.group(2), cells))
    for level in range(6):
        hits = seen.get(level, [])
        if len(hits) != 1:
            problems.append(
                "PQCMM level {} appears {} times in the level table, expected 1".format(
                    level, len(hits)
                )
            )
    for level in sorted(seen):
        if level > 5:
            problems.append("PQCMM level {} is not a PQCMM level".format(level))

    if network and not problems:
        try:
            page = page_text(PQCMM_LEVELS_URL)
        except (urllib.error.URLError, OSError) as err:
            problems.append("could not fetch {}: {}".format(PQCMM_LEVELS_URL, err))
            return problems
        for level in range(6):
            number, name, cells = seen[level][0]
            if "{} {} {}".format(level, EM_DASH, name) not in page:
                problems.append(
                    "line {}: level name '{}' is not on the PQCMM levels page".format(
                        number, name
                    )
                )
            quotes = re.findall(r"\"([^\"]+)\"", cells[1] if len(cells) > 1 else "")
            if not quotes:
                problems.append("line {}: no quoted PQCMM summary".format(number))
            for quote in quotes:
                if re.sub(r"\s+", " ", quote) not in page:
                    problems.append(
                        "line {}: quote not found on the PQCMM levels page: "
                        "\"{}\"".format(number, quote)
                    )
    return problems


def check_nist(lines):
    """NIST PQC cells of question rows are '-' or name a publication number."""
    problems = []
    rows = 0
    dashes = 0
    column = None
    for number, line in strip_code(lines):
        if not line.lstrip().startswith("|"):
            column = None
            continue
        cells = split_row(line)
        if NIST_COLUMN in cells:
            column = cells.index(NIST_COLUMN)
            continue
        if column is None:
            continue
        question = re.match(r"^\*\*(Q\d+\.\d+\.\d+)\*\*", cells[0])
        if not question:
            continue
        rows += 1
        cell = cells[column] if column < len(cells) else ""
        if cell == "-":
            dashes += 1
        elif not NIST_PUBLICATION.search(cell):
            problems.append(
                "line {}: {} NIST PQC cell '{}' names no publication number; "
                "give a FIPS, NIST SP, NIST IR or OMB number, or '-'".format(
                    number, question.group(1), cell
                )
            )
    if rows == 0:
        problems.append("no question rows under a '{}' column".format(NIST_COLUMN))
    return problems, rows, dashes


def main(argv):
    root = os.path.realpath(argv[0])
    args = argv[1:]
    network = True
    if "--no-network" in args:
        network = False
        args = [a for a in args if a != "--no-network"]
    unknown = [a for a in args if a.startswith("-")]
    if unknown:
        print("unknown option: {}".format(" ".join(unknown)), file=sys.stderr)
        print(
            "usage: bash scripts/check-framework-docs.sh [--no-network] [file ...]",
            file=sys.stderr,
        )
        return 2
    files = args or [os.path.join(root, doc) for doc in DEFAULT_DOCS]

    practices = load_practices(root)
    questions = load_questions(root)
    failed = False

    for given in files:
        if not given:
            print("== ''")
            print("  FAIL file: no file name given")
            failed = True
            continue
        path = os.path.realpath(given)
        rel = os.path.relpath(path, root)
        print("== {}".format(path if rel.startswith("..") else rel))
        if not os.path.isfile(path):
            print("  FAIL file: not found")
            failed = True
            continue
        with open(path, encoding="utf-8") as fh:
            lines = fh.read().splitlines()

        results = []
        results.append(("writing", check_writing(lines), ""))
        practice_problems, practice_count = check_practices(lines, practices, questions)
        results.append(
            ("practices", practice_problems, "{} references".format(practice_count))
        )
        link_problems, url_count = check_links(path, lines, root, network)
        note = "{} external URLs".format(url_count)
        if not network:
            note += ", not fetched (--no-network)"
        results.append(("links", link_problems, note))
        if os.path.basename(path) == os.path.basename(PQCMM_DOC):
            pqcmm_note = "level table and quotes"
            if not network:
                pqcmm_note += ", quotes not compared (--no-network)"
            results.append(("pqcmm", check_pqcmm(lines, practice_count, network), pqcmm_note))
        if os.path.basename(path) == os.path.basename(MAPPING_DOC):
            nist_problems, rows, dashes = check_nist(lines)
            nist_note = "{} question rows, {} with '-'".format(rows, dashes)
            results.append(("nist", nist_problems, nist_note))

        for name, problems, note in results:
            suffix = " ({})".format(note) if note else ""
            if problems:
                failed = True
                print("  FAIL {}{}".format(name, suffix))
                for problem in problems:
                    print("    {}".format(problem))
            else:
                print("  PASS {}{}".format(name, suffix))

    print("RESULT: {}".format("FAIL" if failed else "PASS"))
    return 1 if failed else 0


sys.exit(main(sys.argv[1:]))
PY
