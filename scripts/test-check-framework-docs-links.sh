#!/usr/bin/env bash
# Tests the links check of scripts/check-framework-docs.sh on URLs at the end
# of italic and bold text.
#
# Usage:
#   scripts/test-check-framework-docs-links.sh [checker]
#
# checker defaults to check-framework-docs.sh next to this script. Fixtures
# are written to a new temporary directory and given to the checker by
# absolute path. The checker is run with its network checks on, and every
# URL in the fixtures points at a web server this script starts on
# 127.0.0.1. The server holds one page, /page, so it answers 200 for /page
# and 404 for /page* and /missing. no_proxy is set to "*" for the checker so
# that an http_proxy setting does not send those requests to a proxy.
#
# Cases:
#   1. An italic sentence that ends with the URL of /page and the closing
#      asterisk: exit 0, PASS links (1 external URLs), RESULT: PASS, nothing
#      on stderr.
#   2. Bold text that ends with the URL of /page, the closing asterisks and
#      a period: exit 0, PASS links (1 external URLs).
#   3. An italic sentence that ends with the URL of /missing and the closing
#      asterisk: exit 1, FAIL links, a line that names the URL without the
#      asterisk and the 404 answer, RESULT: FAIL.
#   4. Where the fixtures were written: the directory is under .tmp-tests/
#      at the repository root and holds the fixture of case 1.
#
# The temporary directory is made under .tmp-tests/ at the repository root,
# and the cleanup removes only a directory under it.
#
# Exit status: 0 when every case passes, 1 when any case fails or the web
# server does not start.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
repo="$(cd "$here/.." && pwd -P)"
checker="${1:-$here/check-framework-docs.sh}"
if [ ! -f "$checker" ]; then
  echo "checker not found: $checker" >&2
  exit 1
fi

tmp_root="$repo/.tmp-tests"
mkdir -p "$tmp_root"
work="$(mktemp -d "$tmp_root/check-framework-docs-links.XXXXXX")"
server_pid=""
cleanup() {
  if [ -n "$server_pid" ]; then
    kill "$server_pid" 2> /dev/null || true
    wait "$server_pid" 2> /dev/null || true
  fi
  case "$work" in
    "$tmp_root"/?*) rm -rf -- "$work" ;;
    *) exit 1 ;;
  esac
  rmdir "$tmp_root" 2> /dev/null || true
}
trap cleanup EXIT

# The server listens on a port the system picks and names it in its first
# line of output.
mkdir -p "$work/site"
printf 'page\n' > "$work/site/page"
: > "$work/server.out"
python3 -I -u -m http.server 0 --bind 127.0.0.1 --directory "$work/site" \
  > "$work/server.out" 2> "$work/server.err" &
server_pid=$!
port=""
for _ in $(seq 100); do
  port="$(sed -n 's/^Serving HTTP on 127\.0\.0\.1 port \([0-9][0-9]*\) .*/\1/p' "$work/server.out")"
  [ -n "$port" ] && break
  kill -0 "$server_pid" 2> /dev/null || break
  sleep 0.1
done
if [ -z "$port" ]; then
  echo "could not start a web server on 127.0.0.1" >&2
  sed 's/^/  /' "$work/server.err" >&2
  exit 1
fi
base="http://127.0.0.1:$port"

failed=0

# Writes a heading, a blank line and then each remaining argument as a line to
# the Markdown file $1, so the first of those lines is line 3.
write_doc() {
  local file="$1"
  shift
  mkdir -p "$(dirname "$file")"
  {
    printf '# Links\n\n'
    printf '%s\n' "$@"
  } > "$file"
}

# Runs the checker on the given files with its network checks on. Sets out,
# err and status.
run_checker() {
  status=0
  no_proxy='*' bash "$checker" "$@" > "$work/out" 2> "$work/err" || status=$?
  out="$(cat "$work/out")"
  err="$(cat "$work/err")"
}

expect() {
  local name="$1" condition="$2"
  if eval "$condition"; then
    echo "  ok   $name"
  else
    echo "  FAIL $name"
    failed=1
  fi
}

show_output() {
  echo "  -- stdout --"
  printf '%s\n' "$out" | sed 's/^/  /'
  echo "  -- stderr --"
  printf '%s\n' "$err" | sed 's/^/  /'
}

echo "case 1: a URL at the end of an italic sentence"
write_doc "$work/italic/doc.md" \
  "*This page is part of a test. For more information, visit $base/page*"
run_checker "$work/italic/doc.md"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "links check passes with 1 external URL" \
  'printf "%s\n" "$out" | grep -qxF "  PASS links (1 external URLs)"'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
expect "stderr is empty" '[ -z "$err" ]'
[ "$failed" -eq 0 ] || show_output

echo "case 2: a URL at the end of bold text, then a period"
case_failed="$failed"
failed=0
write_doc "$work/bold/doc.md" "**For more information, visit $base/page**."
run_checker "$work/bold/doc.md"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "links check passes with 1 external URL" \
  'printf "%s\n" "$out" | grep -qxF "  PASS links (1 external URLs)"'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 3: the URL of a missing page at the end of an italic sentence"
case_failed="$failed"
failed=0
write_doc "$work/missing/doc.md" "*For more information, visit $base/missing*"
run_checker "$work/missing/doc.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "links check fails" 'printf "%s\n" "$out" | grep -q "^  FAIL links"'
expect "problem names the URL without the asterisk and the 404 answer" \
  'printf "%s\n" "$out" | grep -qxF "    line 3: $base/missing answered 404, expected 200"'
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 4: where the fixtures were written"
case_failed="$failed"
failed=0
expect "fixtures directory is under .tmp-tests/ at the repository root" \
  'case "$work" in "$repo"/.tmp-tests/?*) true ;; *) false ;; esac'
expect "the fixture of case 1 is in it" '[ -f "$work/italic/doc.md" ]'
[ "$failed" -eq 0 ] || echo "  -- fixtures directory: $work"
failed=$((failed | case_failed))

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
