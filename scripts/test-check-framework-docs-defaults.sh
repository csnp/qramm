#!/usr/bin/env bash
# Tests the default file list of scripts/check-framework-docs.sh, and how the
# documents in that list link a withdrawn document.
#
# Usage:
#   scripts/test-check-framework-docs-defaults.sh
#
# The checker is check-framework-docs.sh next to this script, and README.md is
# the one in the repository above it. DEFAULT_DOCS is read out of the checker
# with sed. The checker is run with --no-network. Fixtures and output are
# written to a new temporary directory under .tmp-tests/ at the repository
# root, and the cleanup removes only a directory under it.
#
# A Markdown document is withdrawn when the first line that is not blank after
# its first line starts with "Withdrawn ", such as "Withdrawn October 31,
# 2026". A line that links a withdrawn document has to say so: "withdrawn",
# in any letter case, is part of its text.
#
# Cases:
#   1. A fixture README with a .md link that has an anchor, a directory link,
#      an external link, a mailto link, a link to a file that is not Markdown
#      and a .md link inside a fenced code block: the link reader returns the
#      .md target without its anchor and the directory, and nothing else.
#   2. README.md itself and every relative .md link target in README.md are in
#      DEFAULT_DOCS.
#   3. For every relative link in README.md to a directory, each tracked .md
#      file in that directory is in DEFAULT_DOCS.
#   4. DEFAULT_DOCS is sorted, has no duplicates, and every entry is a tracked
#      file.
#   5. The checker run with no file arguments exits 0, checks one file per
#      DEFAULT_DOCS entry, has no FAIL line, and its last line is
#      RESULT: PASS.
#   6. Fixture documents: old.md is withdrawn; new.md is not, though a later
#      line of it starts with "Withdrawn ". new.md links old.md, and a
#      fixture README links old.md on a line that does not say "withdrawn",
#      on a line that says "Withdrawn" and inside a fenced code block, and
#      links new.md and an external URL that ends in old.md: the
#      withdrawn-link reader lists the README line that does not say
#      "withdrawn" and the new.md line, and nothing else.
#   7. Every line of a DEFAULT_DOCS document, outside fenced code blocks,
#      that links a withdrawn document says "withdrawn".
#
# Exit status: 0 when every case passes, 1 when any case fails.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
repo="$(cd "$here/.." && pwd -P)"
checker="$here/check-framework-docs.sh"
readme="$repo/README.md"
for file in "$checker" "$readme"; do
  if [ ! -f "$file" ]; then
    echo "not found: $file" >&2
    exit 1
  fi
done

tmp_root="$repo/.tmp-tests"
mkdir -p "$tmp_root"
work="$(mktemp -d "$tmp_root/check-framework-docs-defaults.XXXXXX")"
cleanup() {
  case "$work" in
    "$tmp_root"/?*) rm -rf -- "$work" ;;
    *) exit 1 ;;
  esac
  rmdir "$tmp_root" 2> /dev/null || true
}
trap cleanup EXIT

failed=0

expect() {
  local name="$1" condition="$2"
  if eval "$condition"; then
    echo "  ok   $name"
  else
    echo "  FAIL $name"
    failed=1
  fi
}

# Prints "md <path>" for each relative .md link target in the Markdown file
# $1 and "dir <path>" for each relative link to a directory, outside fenced
# code blocks, once each, in order of first appearance. Paths are relative to
# the directory of $1, without the anchor.
read_links() {
  python3 -I - "$1" <<'PY'
import os
import re
import sys

source = os.path.abspath(sys.argv[1])
base = os.path.dirname(source)
seen = []
fenced = False
with open(source, encoding="utf-8") as fh:
    for line in fh:
        if line.lstrip().startswith("```"):
            fenced = not fenced
            continue
        if fenced:
            continue
        for target in re.findall(r"\]\(([^)\s]+)\)", line):
            if re.match(r"^[a-z]+:", target) or target.startswith("#"):
                continue
            local = target.split("#", 1)[0]
            path = os.path.normpath(os.path.join(base, local))
            if local.endswith(".md"):
                kind = "md"
            elif local.endswith("/") or os.path.isdir(path):
                kind = "dir"
            else:
                continue
            item = "{} {}".format(kind, os.path.relpath(path, base))
            if item not in seen:
                seen.append(item)
                print(item)
PY
}

# Reads Markdown file names from the file $2, one per line, each relative to
# the directory $1. For each line of those files, outside fenced code blocks,
# whose text does not hold "withdrawn" in any letter case, prints
# "<name>:<line number>: <target>" for each relative link on it to a
# withdrawn Markdown document, with the target as it is written. Line numbers
# count lines the way the checker does.
withdrawn_links() {
  python3 -I - "$1" "$2" <<'PY'
import os
import re
import sys


def withdrawn(path):
    with open(path, encoding="utf-8") as fh:
        lines = fh.read().splitlines()
    for line in lines[1:]:
        if line.strip():
            return line.startswith("Withdrawn ")
    return False


root = sys.argv[1]
with open(sys.argv[2], encoding="utf-8") as fh:
    names = [name for name in fh.read().splitlines() if name]
for name in names:
    source = os.path.join(root, name)
    base = os.path.dirname(source)
    fenced = False
    with open(source, encoding="utf-8") as fh:
        lines = fh.read().splitlines()
    for number, line in enumerate(lines, 1):
        if line.lstrip().startswith("```"):
            fenced = not fenced
            continue
        if fenced or "withdrawn" in line.lower():
            continue
        for target in re.findall(r"\]\(([^)\s]+)\)", line):
            if re.match(r"^[a-z]+:", target) or target.startswith("#"):
                continue
            path = os.path.normpath(os.path.join(base, target.split("#", 1)[0]))
            if path.endswith(".md") and os.path.isfile(path) and withdrawn(path):
                print("{}:{}: {}".format(name, number, target))
PY
}

# Prints the entries of DEFAULT_DOCS in the checker, one per line.
default_docs() {
  sed -n '/^DEFAULT_DOCS/,/^]/p' "$checker" | sed -n 's/^ *"\([^"]*\)",* *$/\1/p'
}

# Prints each line of file $1 that is not a line of file $2.
missing_from() {
  grep -vxF -f "$2" "$1" || true
}

default_docs > "$work/defaults"

echo "case 1: the link reader on a fixture README"
mkdir -p "$work/fixture/docs" "$work/fixture/sub"
printf '# Fixture\n' > "$work/fixture/docs/a.md"
printf 'text\n' > "$work/fixture/LICENSE"
{
  printf '# Fixture\n\n'
  printf 'Read [a](docs/a.md#part) and [sub](sub/), [site](https://example.org/b.md),\n'
  printf '[mail](mailto:someone@example.org), [license](LICENSE) and [top](#fixture).\n\n'
  printf '```\n[code](docs/code.md)\n```\n'
} > "$work/fixture/README.md"
read_links "$work/fixture/README.md" > "$work/fixture-links"
printf 'md docs/a.md\ndir sub\n' > "$work/fixture-expected"
expect "returns the .md target and the directory only" \
  'diff -u "$work/fixture-expected" "$work/fixture-links" > "$work/fixture-diff"'
[ "$failed" -eq 0 ] || sed 's/^/    /' "$work/fixture-diff"

echo "case 2: README.md and its .md link targets are in DEFAULT_DOCS"
case_failed="$failed"
failed=0
read_links "$readme" > "$work/links"
{
  echo "README.md"
  sed -n 's/^md //p' "$work/links"
} > "$work/linked"
missing_from "$work/linked" "$work/defaults" > "$work/missing-linked"
expect "README.md has at least one relative .md link" \
  '[ "$(wc -l < "$work/linked")" -gt 1 ]'
expect "every one is in DEFAULT_DOCS" '[ ! -s "$work/missing-linked" ]'
if [ -s "$work/missing-linked" ]; then
  echo "    not in DEFAULT_DOCS ($(wc -l < "$work/missing-linked" | tr -d ' ') files):"
  sed 's/^/      /' "$work/missing-linked"
fi
failed=$((failed | case_failed))

echo "case 3: Markdown files in directories README.md links are in DEFAULT_DOCS"
case_failed="$failed"
failed=0
: > "$work/in-dirs"
sed -n 's/^dir //p' "$work/links" | while IFS= read -r dir; do
  git -C "$repo" ls-files -- "$dir" | grep '\.md$' >> "$work/in-dirs" || true
done
missing_from "$work/in-dirs" "$work/defaults" > "$work/missing-in-dirs"
expect "every one is in DEFAULT_DOCS" '[ ! -s "$work/missing-in-dirs" ]'
if [ -s "$work/missing-in-dirs" ]; then
  echo "    not in DEFAULT_DOCS ($(wc -l < "$work/missing-in-dirs" | tr -d ' ') files):"
  sed 's/^/      /' "$work/missing-in-dirs"
fi
failed=$((failed | case_failed))

echo "case 4: DEFAULT_DOCS is sorted, unique and tracked"
case_failed="$failed"
failed=0
LC_ALL=C sort -u "$work/defaults" > "$work/defaults-sorted"
: > "$work/untracked"
while IFS= read -r doc; do
  git -C "$repo" ls-files --error-unmatch -- "$doc" > /dev/null 2>&1 \
    || echo "$doc" >> "$work/untracked"
done < "$work/defaults"
expect "DEFAULT_DOCS has at least one entry" '[ -s "$work/defaults" ]'
expect "sorted with no duplicates" 'cmp -s "$work/defaults" "$work/defaults-sorted"'
expect "every entry is a tracked file" '[ ! -s "$work/untracked" ]'
[ ! -s "$work/untracked" ] || sed 's/^/    untracked: /' "$work/untracked"
failed=$((failed | case_failed))

echo "case 5: the default run passes"
case_failed="$failed"
failed=0
status=0
bash "$checker" --no-network > "$work/out" 2> "$work/err" || status=$?
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "one file checked per DEFAULT_DOCS entry" \
  '[ "$(grep -c "^== " "$work/out")" -eq "$(wc -l < "$work/defaults")" ]'
expect "no FAIL line" '! grep -q "^  FAIL" "$work/out"'
expect "last line is RESULT: PASS" '[ "$(tail -n 1 "$work/out")" = "RESULT: PASS" ]'
if [ "$failed" -ne 0 ]; then
  { grep -E '^== |^  FAIL|^    ' "$work/out" || true; } | sed 's/^/    /' | head -n 40 || true
  sed 's/^/    stderr: /' "$work/err"
fi
failed=$((failed | case_failed))

echo "case 6: the withdrawn-link reader on fixture documents"
case_failed="$failed"
failed=0
mkdir -p "$work/withdrawn/docs"
printf '# Old\n\nWithdrawn October 31, 2026\n\nSee new.md.\n' > "$work/withdrawn/docs/old.md"
{
  printf '# New\n\n'
  printf 'The current document links [the old one](old.md).\n\n'
  printf 'Withdrawn certificates are listed here.\n'
} > "$work/withdrawn/docs/new.md"
{
  printf '# Fixture\n\n'
  printf 'The [old summary](docs/old.md) gives a quick reference.\n'
  printf 'Withdrawn October 31, 2026: [the old summary](docs/old.md#changes).\n'
  printf 'Read [new](docs/new.md#part) and [site](https://example.org/docs/old.md).\n'
  printf '```\n[old](docs/old.md)\n```\n'
} > "$work/withdrawn/README.md"
printf 'README.md\ndocs/new.md\n' > "$work/withdrawn-names"
status=0
withdrawn_links "$work/withdrawn" "$work/withdrawn-names" \
  > "$work/withdrawn-out" 2> "$work/withdrawn-err" || status=$?
printf 'README.md:3: docs/old.md\ndocs/new.md:3: old.md\n' > "$work/withdrawn-expected"
expect "reader exits 0" '[ "$status" -eq 0 ]'
expect "lists the two links on lines that do not say withdrawn, and nothing else" \
  'diff -u "$work/withdrawn-expected" "$work/withdrawn-out" > "$work/withdrawn-diff"'
if [ "$failed" -ne 0 ]; then
  sed 's/^/    /' "$work/withdrawn-diff"
  sed 's/^/    stderr: /' "$work/withdrawn-err"
fi
failed=$((failed | case_failed))

echo "case 7: DEFAULT_DOCS lines that link a withdrawn document say withdrawn"
case_failed="$failed"
failed=0
status=0
withdrawn_links "$repo" "$work/defaults" \
  > "$work/withdrawn-links" 2> "$work/withdrawn-links-err" || status=$?
expect "reader exits 0" '[ "$status" -eq 0 ]'
expect "every such line says withdrawn" '[ ! -s "$work/withdrawn-links" ]'
if [ -s "$work/withdrawn-links" ]; then
  echo "    lines that link a withdrawn document and do not say withdrawn" \
    "($(wc -l < "$work/withdrawn-links" | tr -d ' ')):"
  sed 's/^/      /' "$work/withdrawn-links"
fi
[ "$status" -eq 0 ] || sed 's/^/    stderr: /' "$work/withdrawn-links-err"
failed=$((failed | case_failed))

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
