#!/usr/bin/env bash
# Tests the default file list of scripts/check-framework-docs.sh.
#
# Usage:
#   scripts/test-check-framework-docs-defaults.sh
#
# The checker is check-framework-docs.sh next to this script, and README.md is
# the one in the repository above it. DEFAULT_DOCS is read out of the checker
# with sed. The checker is run with --no-network. Fixtures and output are
# written to a new temporary directory.
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

work="$(mktemp -d "${TMPDIR:-/tmp}/check-framework-docs-defaults.XXXXXX")"
work="$(cd "$work" && pwd -P)"
trap 'rm -rf "$work"' EXIT

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

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
