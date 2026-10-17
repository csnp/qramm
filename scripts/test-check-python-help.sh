#!/usr/bin/env bash
# Tests --help and -h on each Python checker, scripts/check-*.py, run with
# python3 -I and with python3 -OO -I. Each checker's header text is its
# module docstring, and the -OO option removes docstrings.
#
# Usage:
#   scripts/test-check-python-help.sh
#
# Cases, for each checker and each of --help and -h:
#   1. python3 -I: exit 2, nothing on stdout, and on stderr a usage line that
#      names the checker, a blank line and the checker's header text.
#   2. python3 -OO -I: exit 2, nothing on stdout, no traceback, and on stderr
#      only the usage line from case 1.
#
# The temporary directory is made under .tmp-tests/ at the repository root,
# and the cleanup removes only a directory under it.
#
# Exit status: 0 when every case passes, 1 when any case fails.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

tmp_root="$(cd "$here/.." && pwd -P)/.tmp-tests"
mkdir -p "$tmp_root"
work="$(mktemp -d "$tmp_root/check-python-help.XXXXXX")"
cleanup() {
  case "$work" in
    "$tmp_root"/?*) rm -rf -- "$work" ;;
    *) exit 1 ;;
  esac
  rmdir "$tmp_root" 2> /dev/null || true
}
trap cleanup EXIT

failed=0

# Runs python3 with the given options and arguments. Sets out, err and status.
run_python() {
  status=0
  python3 "$@" > "$work/out" 2> "$work/err" || status=$?
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

# Runs one case: $1 is its title, the rest are python3 options and arguments.
# Leaves the result in out, err and status for the expect lines that follow.
start_case() {
  echo "$1"
  shift
  case_failed="$failed"
  failed=0
  run_python "$@"
}

end_case() {
  [ "$failed" -eq 0 ] || show_output
  failed=$((failed | case_failed))
}

# Prints the module docstring of the checker at $1 without its leading and
# trailing whitespace, as the checkers print it.
header_text() {
  python3 -I - "$1" <<'PY'
import ast
import sys

with open(sys.argv[1], encoding="utf-8") as fh:
    print(ast.get_docstring(ast.parse(fh.read()), clean=False).strip())
PY
}

# Succeeds when $1 is a usage line for $2, a path such as
# scripts/check-scoring-example.py.
is_usage_line() {
  case "$1" in
    "usage: python3 -I $2" | "usage: python3 -I $2 "*) return 0 ;;
    *) return 1 ;;
  esac
}

for checker in "$here"/check-*.py; do
  script="scripts/$(basename "$checker")"
  header="$(header_text "$checker")"
  for option in --help -h; do
    start_case "case 1: python3 -I $script $option" -I "$checker" "$option"
    usage="${err%%$'\n'*}"
    expected="$(printf '%s\n\n%s' "$usage" "$header")"
    expect "exit status is 2" '[ "$status" -eq 2 ]'
    expect "nothing on stdout" '[ -z "$out" ]'
    expect "first stderr line is the usage line" 'is_usage_line "$usage" "$script"'
    expect "stderr is the usage line, a blank line and the header text" \
      '[ "$err" = "$expected" ]'
    end_case

    start_case "case 2: python3 -OO -I $script $option" -OO -I "$checker" "$option"
    expect "exit status is 2" '[ "$status" -eq 2 ]'
    expect "nothing on stdout" '[ -z "$out" ]'
    expect "no traceback on stderr" '! printf "%s\n" "$err" | grep -q "^Traceback"'
    expect "stderr is only the usage line" '[ "$err" = "$usage" ]'
    end_case
  done
done

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
