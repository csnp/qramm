#!/usr/bin/env bash
# Tests --help, -h and unknown options on each Python checker,
# scripts/check-*.py. --help and -h are run with python3 -I and with
# python3 -OO -I. Each checker's header text is its module docstring, and the
# -OO option removes docstrings.
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
# Cases, for each checker:
#   3. --bogus --json --: exit 2, nothing on stdout, and on stderr
#      "unknown option: --bogus", "unknown option: --json" and
#      "unknown option: --", then, for a checker whose usage line names no
#      argument, "this checker takes no arguments", then the usage line.
#   4. README.md, an empty argument and --bogus: exit 2, nothing on stdout.
#      For a checker that takes files, stderr is "unknown option: --bogus"
#      and the usage line. For a checker whose usage line names no argument,
#      stderr is "unexpected argument: README.md", "unexpected argument: ''",
#      "unknown option: --bogus", "this checker takes no arguments" and the
#      usage line.
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

  # A checker whose usage line names no argument takes none.
  if [ "$usage" = "usage: python3 -I $script" ]; then
    takes_none="this checker takes no arguments"$'\n'
  else
    takes_none=""
  fi

  start_case "case 3: python3 -I $script --bogus --json --" -I "$checker" --bogus --json --
  expected="$(printf 'unknown option: %s\n' --bogus --json --)"$'\n'"$takes_none$usage"
  expect "exit status is 2" '[ "$status" -eq 2 ]'
  expect "nothing on stdout" '[ -z "$out" ]'
  expect "stderr names each option on a line of its own, then the usage line" \
    '[ "$err" = "$expected" ]'
  end_case

  start_case "case 4: python3 -I $script README.md '' --bogus" -I "$checker" README.md "" --bogus
  if [ -n "$takes_none" ]; then
    expected="unexpected argument: README.md"$'\n'"unexpected argument: ''"
    expected+=$'\n'"unknown option: --bogus"$'\n'"$takes_none$usage"
  else
    expected="unknown option: --bogus"$'\n'"$usage"
  fi
  expect "exit status is 2" '[ "$status" -eq 2 ]'
  expect "nothing on stdout" '[ -z "$out" ]'
  expect "stderr names the rejected arguments, then the usage line" \
    '[ "$err" = "$expected" ]'
  end_case
done

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
