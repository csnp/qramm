#!/usr/bin/env bash
# Tests scripts/check-spec-passwords.sh in and outside a git checkout.
#
# Usage:
#   scripts/test-check-spec-passwords.sh [checker]
#
# checker defaults to check-spec-passwords.sh next to this script. Each case
# copies it into a new temporary directory laid out like the repository
# (scripts/ and toolkit-specs/), so the checker treats that directory as the
# repository root. GIT_CEILING_DIRECTORIES stops git from finding a checkout
# above the temporary directory.
#
# Cases:
#   1. Not a git checkout, no file arguments: exit 1, one FAIL line that says
#      it is not a git checkout and to pass the files as arguments, a
#      RESULT: FAIL line, nothing on stderr, no Python traceback.
#   2. Not a git checkout, the spec file as an argument: exit 0, RESULT: PASS.
#   3. A git checkout with the spec file tracked, no file arguments: exit 0,
#      1 file checked, RESULT: PASS.
#   4-6. Case 1 again with LANG, LC_ALL and LANGUAGE set to German, French
#      and Spanish, so git prints its messages in that language: the same
#      results as case 1. A language is skipped, with a line that says so,
#      when git prints its message untranslated for it on this machine.
#
# Exit status: 0 when every case passes, 1 when any case fails.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
checker="${1:-$here/check-spec-passwords.sh}"
if [ ! -f "$checker" ]; then
  echo "checker not found: $checker" >&2
  exit 1
fi

work="$(mktemp -d "${TMPDIR:-/tmp}/check-spec-passwords.XXXXXX")"
work="$(cd "$work" && pwd -P)"
trap 'rm -rf "$work"' EXIT
export GIT_CEILING_DIRECTORIES="$work"

failed=0

# Lays out a copy of the repository at $1 with one spec file that passes.
make_copy() {
  mkdir -p "$1/scripts" "$1/toolkit-specs"
  cp "$checker" "$1/scripts/check-spec-passwords.sh"
  printf '# Spec\n\n- Password: None\n' > "$1/toolkit-specs/spec.md"
}

# Runs the checker in copy $1 with the remaining arguments. Sets out, err
# and status.
run_checker() {
  local copy="$1"
  shift
  status=0
  (cd "$copy" && bash scripts/check-spec-passwords.sh "$@") \
    > "$work/out" 2> "$work/err" || status=$?
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

# Checks a run with no file arguments in a copy that is not a git checkout.
expect_not_a_checkout() {
  local fail_lines
  fail_lines="$(printf '%s\n' "$out" | grep -c '^FAIL' || true)"
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "one FAIL line" '[ "$fail_lines" -eq 1 ]'
  expect "FAIL line says not a git checkout" \
    'printf "%s\n" "$out" | grep "^FAIL" | grep -q "not a git checkout"'
  expect "FAIL line says to pass the files as arguments" \
    'printf "%s\n" "$out" | grep "^FAIL" | grep -q "pass the files to check as arguments"'
  expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
  expect "stderr is empty" '[ -z "$err" ]'
  expect "no traceback" '! printf "%s\n%s\n" "$out" "$err" | grep -q Traceback'
}

echo "case 1: not a git checkout, no file arguments"
make_copy "$work/plain"
run_checker "$work/plain"
expect_not_a_checkout
[ "$failed" -eq 0 ] || show_output

echo "case 2: not a git checkout, file given as an argument"
case_failed="$failed"
failed=0
run_checker "$work/plain" toolkit-specs/spec.md
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

echo "case 3: git checkout, no file arguments"
case_failed="$failed"
failed=0
make_copy "$work/checkout"
git -C "$work/checkout" init -q
git -C "$work/checkout" add toolkit-specs/spec.md
run_checker "$work/checkout"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "one file checked" 'printf "%s\n" "$out" | grep -q "^1 files checked"'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
[ "$failed" -eq 0 ] || show_output
failed=$((failed | case_failed))

case_number=4
for locale in de_DE.UTF-8 fr_FR.UTF-8 es_ES.UTF-8; do
  language="${locale%%_*}"
  echo "case $case_number: not a git checkout, no file arguments, LANG=$locale"
  case_number=$((case_number + 1))
  probe="$(LANG="$locale" LC_ALL="$locale" LANGUAGE="$language" \
    git -C "$work/plain" ls-files 2>&1 > /dev/null || true)"
  if printf '%s\n' "$probe" | grep -q "not a git repository"; then
    echo "  skip git prints this message untranslated for $locale here"
    continue
  fi
  case_failed="$failed"
  failed=0
  LANG="$locale" LC_ALL="$locale" LANGUAGE="$language" run_checker "$work/plain"
  expect_not_a_checkout
  [ "$failed" -eq 0 ] || show_output
  failed=$((failed | case_failed))
done

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
