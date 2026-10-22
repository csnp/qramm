#!/usr/bin/env bash
# Tests the links check of scripts/check-framework-docs.sh on URLs at the end
# of italic and bold text, on URLs that answer 999, and on relative links to
# paths outside the repository.
#
# Usage:
#   scripts/test-check-framework-docs-links.sh [checker]
#
# checker defaults to check-framework-docs.sh next to this script. Fixtures
# are written to a new temporary directory and given to the checker by
# absolute path. The checker is run with its network checks on, and every
# URL in the fixtures is answered by a web server this script starts on
# 127.0.0.1. Asked for a path, the server answers 200 for /page and 404 for
# any other path, such as /page* and /missing. In cases 1 to 3 no_proxy is
# set to "*" for the checker so that an http_proxy setting does not send
# those requests to a proxy. In cases 5 and 6 the server is the checker's
# proxy: http_proxy names it and no_proxy is empty, so the checker asks the
# server for the whole URL instead of asking the host the URL names, and
# the server answers 999 to every such request.
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
#   5. URLs on www.linkedin.com and linkedin.com that answer 999: exit 0,
#      PASS links (2 external URLs, 2 not verified), a line for each that
#      names the URL, the 999 answer and "not verified", RESULT: PASS,
#      nothing on stderr, and the server's log holds both requests.
#   6. URLs on linkedin.com.invalid and notlinkedin.com, hosts that only
#      look like LinkedIn's, and on www.linkedin.com, all answering 999:
#      exit 1, FAIL links (3 external URLs, 1 not verified), an "answered
#      999, expected 200" line for each of the first two, the not verified
#      line for the third, RESULT: FAIL, and the server's log holds all
#      three requests.
#   7. Relative links to the directory that holds the repository, to a
#      missing sibling of the repository whose name starts with the
#      repository's name, to a missing file in the repository and to the
#      repository's README.md: exit 1, FAIL links (0 external URLs), "is
#      outside the repository" for the first two, "does not resolve" for the
#      third, no line for the fourth, RESULT: FAIL, nothing on stderr.
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
# line of output, "port N". It logs each request on stderr the way
# python3 -m http.server does. A request for a whole URL, which is how a
# client asks a proxy for a page, is answered 999.
: > "$work/server.out"
python3 -I -u - > "$work/server.out" 2> "$work/server.err" <<'PY' &
import http.server


class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path.startswith("http://"):
            code = 999
        elif self.path == "/page":
            code = 200
        else:
            code = 404
        body = b"page\n" if code == 200 else b""
        self.send_response(code)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


server = http.server.HTTPServer(("127.0.0.1", 0), Handler)
print("port {}".format(server.server_address[1]))
server.serve_forever()
PY
server_pid=$!
port=""
for _ in $(seq 100); do
  port="$(sed -n 's/^port \([0-9][0-9]*\)$/\1/p' "$work/server.out")"
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

# Runs the checker on the given files with its network checks on and the
# server as its http proxy. Sets out, err and status.
run_checker_via_server() {
  status=0
  http_proxy="$base" no_proxy='' bash "$checker" "$@" > "$work/out" 2> "$work/err" \
    || status=$?
  out="$(cat "$work/out")"
  err="$(cat "$work/err")"
}

# True when the server's log shows a request for the whole URL $1 answered
# 999, which means the checker asked the server and not the URL's host.
served() {
  grep -qF "\"GET $1 HTTP/1.1\" 999 " "$work/server.err"
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

echo "case 5: LinkedIn URLs that answer 999"
case_failed="$failed"
failed=0
profile="/in/qramm-test-case-5/"
write_doc "$work/linkedin/doc.md" \
  "Profile: http://www.linkedin.com$profile" \
  "Profile: http://linkedin.com$profile"
run_checker_via_server "$work/linkedin/doc.md"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "links check passes with 2 external URLs, 2 not verified" \
  'printf "%s\n" "$out" | grep -qxF "  PASS links (2 external URLs, 2 not verified)"'
expect "the www.linkedin.com URL is listed as not verified" \
  'printf "%s\n" "$out" | grep -qxF "    line 3: http://www.linkedin.com$profile answered 999, not verified; open it in a browser"'
expect "the linkedin.com URL is listed as not verified" \
  'printf "%s\n" "$out" | grep -qxF "    line 4: http://linkedin.com$profile answered 999, not verified; open it in a browser"'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
expect "stderr is empty" '[ -z "$err" ]'
expect "the server answered both requests" \
  'served "http://www.linkedin.com$profile" && served "http://linkedin.com$profile"'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 6: hosts that only look like LinkedIn's answer 999"
case_failed="$failed"
failed=0
profile="/in/qramm-test-case-6/"
write_doc "$work/lookalike/doc.md" \
  "Profile: http://linkedin.com.invalid$profile" \
  "Profile: http://notlinkedin.com$profile" \
  "Profile: http://www.linkedin.com$profile"
run_checker_via_server "$work/lookalike/doc.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "links check fails with 3 external URLs, 1 not verified" \
  'printf "%s\n" "$out" | grep -qxF "  FAIL links (3 external URLs, 1 not verified)"'
expect "the linkedin.com.invalid URL fails on its 999 answer" \
  'printf "%s\n" "$out" | grep -qxF "    line 3: http://linkedin.com.invalid$profile answered 999, expected 200"'
expect "the notlinkedin.com URL fails on its 999 answer" \
  'printf "%s\n" "$out" | grep -qxF "    line 4: http://notlinkedin.com$profile answered 999, expected 200"'
expect "the www.linkedin.com URL is listed as not verified" \
  'printf "%s\n" "$out" | grep -qxF "    line 5: http://www.linkedin.com$profile answered 999, not verified; open it in a browser"'
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
expect "the server answered all three requests" \
  'served "http://linkedin.com.invalid$profile" && served "http://notlinkedin.com$profile" && served "http://www.linkedin.com$profile"'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 7: relative links outside the repository and inside it"
case_failed="$failed"
failed=0
# From $work/relative, ../../.. is the repository root and ../../../.. the
# directory that holds it.
sibling="$(basename "$repo")-old"
write_doc "$work/relative/doc.md" \
  "[the directory that holds the repository](../../../..)" \
  "[a sibling whose name starts with the repository's](../../../../$sibling/README.md)" \
  "[a missing file](missing.md)" \
  "[the repository README](../../../README.md)"
run_checker "$work/relative/doc.md"
expect "the sibling directory does not exist" '[ ! -e "$(dirname "$repo")/$sibling" ]'
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "links check fails with 0 external URLs" \
  'printf "%s\n" "$out" | grep -qxF "  FAIL links (0 external URLs)"'
expect "the link to the directory that holds the repository is outside it" \
  'printf "%s\n" "$out" | grep -qxF "    line 3: relative link '"'"'../../../..'"'"' is outside the repository"'
expect "the link to the sibling is outside the repository" \
  'printf "%s\n" "$out" | grep -qxF "    line 4: relative link '"'"'../../../../$sibling/README.md'"'"' is outside the repository"'
expect "the missing file does not resolve" \
  'printf "%s\n" "$out" | grep -qxF "    line 5: relative link '"'"'missing.md'"'"' does not resolve"'
expect "the link to the repository README is not listed" \
  '! printf "%s\n" "$out" | grep -q "^    line 6:"'
expect "three problem lines" '[ "$(printf "%s\n" "$out" | grep -c "^    line ")" -eq 3 ]'
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
expect "stderr is empty" '[ -z "$err" ]'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
