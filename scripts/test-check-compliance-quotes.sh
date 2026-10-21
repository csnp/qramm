#!/usr/bin/env bash
# Tests scripts/check-compliance-quotes.py against the repository documents
# and against documents written for each case.
#
# Usage:
#   scripts/test-check-compliance-quotes.sh
#
# Cases 2 to 5 write a document to a new temporary directory and give it to
# the checker by absolute path. Cases 2 to 4 build it from rows of the
# repository spec, and the spec line numbers in their expected FAIL lines are
# read from the spec.
#
# Cases:
#   1. The repository documents: exit 0, a PASS line for each document,
#      RESULT: PASS.
#   2. A document that quotes Q1 to Q3 with three cells changed: a different
#      control (Q1 CMMC is AC.L1-3.1.1), a control where the spec gives "-"
#      (Q2 NIST PQC) and a different weight (Q3 CMMC): exit 1, those 3 FAIL
#      lines and no others.
#   3. A document that quotes the spec's Q1 row as written, with its name,
#      inside a fenced code block, and the Q4 row with the number alone:
#      exit 0, PASS 2 quoted rows.
#   4. A document that quotes Q121 and a Q2 row with a cell missing: exit 1,
#      a FAIL line for each.
#   5. A document whose only question rows sit under another header: exit 1,
#      a FAIL line that says it quotes no row.
#   6. A document that does not exist: exit 1, a FAIL line that says it
#      cannot be read.
#   7. An option such as --help: exit 2, usage on stderr, then the checker's
#      header text.
#   8. An empty document argument: exit 1, "FAIL '': no file name given",
#      no "cannot read" line.
#   9. Under the en_US.UTF-8 locale, a document argument that holds the byte
#      0xff, which is not valid UTF-8, and names no file, then the vision
#      summary: exit 1, no traceback, the name printed with the byte as \xff
#      on its == line and in a FAIL line that says it cannot be read, a PASS
#      line for the vision summary, then RESULT: FAIL.
#  10. Under the en_US.ISO8859-1 locale, a document argument that is valid
#      UTF-8 and holds the character U+65E5, which ISO-8859-1 cannot encode,
#      and names no file, then the vision summary: exit 1, nothing on
#      stderr, the name printed with the character as \u65e5 on its == line
#      and in a FAIL line that says it cannot be read (No such file or
#      directory), a PASS line for the vision summary, then RESULT: FAIL.
#      The case is skipped, with a line that says so, when python3 -I does
#      not decode file names as UTF-8 and write stdout as ISO-8859-1 under
#      that locale on this machine.
#  11. A document that quotes the spec's Q1 row as written and has a Latin-1
#      byte on its last line, then the vision summary: exit 1, nothing on
#      stderr, one FAIL line, which says the document is not UTF-8 text, a
#      PASS line for the vision summary, then RESULT: FAIL.
#
# The temporary directory is made under .tmp-tests/ at the repository root,
# and the cleanup removes only a directory under it.
#
# Exit status: 0 when every case passes, 1 when any case fails.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
root="$(dirname "$here")"
checker="$here/check-compliance-quotes.py"
spec="toolkit-specs/4_QRAMM_Compliance_Mapping_Details.md"
header='| Question | NIST CSF | NIST PQC | CMMC | FISMA | FedRAMP | ISO | SOC2 | CIS |'
rule='|----------|----------|----------|------|-------|---------|-----|------|-----|'

tmp_root="$(cd "$here/.." && pwd -P)/.tmp-tests"
mkdir -p "$tmp_root"
work="$(mktemp -d "$tmp_root/check-compliance-quotes.XXXXXX")"
cleanup() {
  case "$work" in
    "$tmp_root"/?*) rm -rf -- "$work" ;;
    *) exit 1 ;;
  esac
  rmdir "$tmp_root" 2> /dev/null || true
}
trap cleanup EXIT

failed=0

# Prints the spec row for question $1 (Q1, Q2, ...).
spec_row() {
  grep "^| $1: " "$root/$spec"
}

# Prints the spec line number of the row for question $1.
spec_line() {
  grep -n "^| $1: " "$root/$spec" | cut -d: -f1
}

# Runs the checker with the given arguments. Sets out, err and status.
run_checker() {
  status=0
  python3 -I "$checker" "$@" > "$work/out" 2> "$work/err" || status=$?
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

has_fail() {
  printf '%s\n' "$out" | grep '^  FAIL' | grep -q -F -- "$1"
}

fail_count() {
  printf '%s\n' "$out" | grep -c '^  FAIL' || true
}

has_line() {
  printf '%s\n' "$out" | grep -q -x -F -- "$1"
}

show_output() {
  echo "  -- stdout --"
  printf '%s\n' "$out" | sed 's/^/  /'
  echo "  -- stderr --"
  printf '%s\n' "$err" | sed 's/^/  /'
}

# Runs one case: $1 is its title, the rest are checker arguments. Leaves the
# result in out, err and status for the expect lines that follow.
start_case() {
  echo "$1"
  shift
  case_failed="$failed"
  failed=0
  run_checker "$@"
}

end_case() {
  [ "$failed" -eq 0 ] || show_output
  failed=$((failed | case_failed))
}

start_case "case 1: repository documents"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "PASS line for the vision summary" \
  'printf "%s\n" "$out" | grep -q -x "  PASS 1 quoted row"'
expect "no FAIL lines" '[ "$(fail_count)" -eq 0 ]'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
end_case

doc="$work/changed.md"
{
  echo "$header"
  echo "$rule"
  spec_row Q1 | sed 's/| AC\.L1-b\.1\.i (0\.8) |/| AC.L1-3.1.1 (0.8) |/'
  spec_row Q2 | sed 's/^\(| Q2: [^|]*| [^|]*\)| - |/\1| FIPS 203 (1.0) |/'
  spec_row Q3 | sed 's/| SC\.L2-3\.13\.11 (1\.0) |/| SC.L2-3.13.11 (0.6) |/'
} > "$doc"
start_case "case 2: document with three cells changed" "$doc"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "3 FAIL lines" '[ "$(fail_count)" -eq 3 ]'
expect "Q1 CMMC control" \
  "has_fail '$doc line 3: Q1 CMMC is AC.L1-3.1.1 (0.8), the spec gives AC.L1-b.1.i (0.8) (line $(spec_line Q1))'"
expect "Q2 NIST PQC control where the spec gives -" \
  "has_fail '$doc line 4: Q2 NIST PQC is FIPS 203 (1.0), the spec gives - (line $(spec_line Q2))'"
expect "Q3 CMMC weight" \
  "has_fail '$doc line 5: Q3 CMMC is SC.L2-3.13.11 (0.6), the spec gives SC.L2-3.13.11 (1.0) (line $(spec_line Q3))'"
end_case

doc="$work/forms.md"
{
  echo '```'
  echo "$header"
  echo "$rule"
  spec_row Q1
  spec_row Q4 | sed 's/^| Q4: [^|]*|/| Q4 |/'
  echo '```'
} > "$doc"
start_case "case 3: named row in a code block and a row with the number alone" "$doc"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "PASS 2 quoted rows" 'printf "%s\n" "$out" | grep -q -x "  PASS 2 quoted rows"'
end_case

doc="$work/shape.md"
{
  echo "$header"
  echo "$rule"
  spec_row Q1 | sed 's/^| Q1: [^|]*|/| Q121 |/'
  spec_row Q2 | sed 's/| 2\.1 (0\.8) |$/|/'
} > "$doc"
start_case "case 4: unknown question and a missing cell" "$doc"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "2 FAIL lines" '[ "$(fail_count)" -eq 2 ]'
expect "Q121 is not a question" "has_fail '$doc line 3: Q121 is not a question in $spec'"
expect "Q2 has a cell missing" "has_fail '$doc line 4: Q2 has 8 cells, expected 9'"
end_case

doc="$work/other.md"
{
  echo '| Question | CMMC |'
  echo '|----------|------|'
  echo '| Q1 | AC.L1-3.1.1 (0.8) |'
} > "$doc"
start_case "case 5: question rows under another header" "$doc"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "1 FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says it quotes no row" "has_fail '$doc: quotes no row of $spec'"
end_case

start_case "case 6: document that does not exist" "toolkit-specs/missing.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line says it cannot be read" "has_fail 'toolkit-specs/missing.md: cannot read'"
end_case

start_case "case 7: option argument" --help
expect "exit status is 2" '[ "$status" -eq 2 ]'
expect "usage on stderr" 'printf "%s\n" "$err" | grep -q "^usage:"'
expect "header text on stderr" \
  'printf "%s\n" "$err" | grep -qx "Checks that documents quoting rows of the compliance mapping spec quote"'
end_case

start_case "case 8: an empty document argument" ""
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL says no file name was given" \
  'printf "%s\n" "$out" | grep -qxF "  FAIL '"''"': no file name given"'
expect "no cannot read line" '! printf "%s\n" "$out" | grep -q "cannot read"'
end_case

# \377 is the byte 0xff, which is not valid UTF-8, so Python holds it as a
# lone surrogate. Under en_US.UTF-8 printing that raises UnicodeEncodeError;
# the C, C.UTF-8 and UTF-8 locales write the byte as it is. The checker is
# expected to print \xff in either case. No file is made with this name.
summary="toolkit-specs/compliance-tab-vision/compliance-vision-summary.md"
LC_ALL=en_US.UTF-8 start_case "case 9: a document argument that is not UTF-8" \
  "$work/bad$(printf '\377').md" "$summary"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "the name is printed with the byte as \\xff" \
  "has_line '== $work/bad\\xff.md against $spec'"
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says the document cannot be read and gives the byte as \\xff" \
  "has_fail '$work/bad\\xff.md: cannot read ('"
expect "the vision summary is checked" \
  "has_line '== $summary against $spec' && has_line '  PASS 1 quoted row'"
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

# \346\227\245 is U+65E5 encoded as UTF-8. Under en_US.ISO8859-1 on macOS,
# python3 decodes the name as UTF-8 and writes stdout as ISO-8859-1, which
# has no byte for U+65E5, so printing the name as it is raises
# UnicodeEncodeError. The checker is expected to print \u65e5 in its place.
# No file is made with this name.
title="case 10: a document argument that stdout's encoding cannot hold"
probe="$(LC_ALL=en_US.ISO8859-1 python3 -I -c 'import codecs, sys; print(codecs.lookup(sys.getfilesystemencoding()).name, codecs.lookup(sys.stdout.encoding).name)' 2>&1 || true)"
if [ "$probe" = "utf-8 iso8859-1" ]; then
  LC_ALL=en_US.ISO8859-1 start_case "$title" \
    "$work/$(printf '\346\227\245').md" "$summary"
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "no traceback on stderr" '[ -z "$err" ]'
  expect "the name is printed with the character as \\u65e5" \
    "has_line '== $work/\\u65e5.md against $spec'"
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line says the document cannot be read and gives the character as \\u65e5" \
    "has_line '  FAIL $work/\\u65e5.md: cannot read (No such file or directory)'"
  expect "the vision summary is checked" \
    "has_line '== $summary against $spec' && has_line '  PASS 1 quoted row'"
  expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
  end_case
else
  echo "$title"
  echo "  skip python3 does not decode file names as UTF-8 and write stdout as ISO-8859-1 under en_US.ISO8859-1 here ($probe)"
fi

# \351 is e with an acute accent in Latin-1, and not valid UTF-8 here.
{
  printf '%s\n' "$header" "$rule" "$(spec_row Q1)"
  printf '\nNotes from the caf\351.\n'
} > "$work/latin1.md"
start_case "case 11: a document that is not UTF-8" "$work/latin1.md" "$summary"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says it is not UTF-8 text" \
  "has_line '  FAIL $work/latin1.md: cannot read (not UTF-8 text)'"
expect "the vision summary is checked" \
  "has_line '== $summary against $spec' && has_line '  PASS 1 quoted row'"
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
