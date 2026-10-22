#!/usr/bin/env bash
# Tests scripts/check-top-strengths.py against the repository files and
# against fixture copies of the repository.
#
# Usage:
#   scripts/test-check-top-strengths.sh
#
# Cases 2 to 21 copy the checker into a new temporary directory laid out
# like the repository (scripts/ and toolkit/), so that the checker treats
# that directory as the repository root. The workbook there is the toolkit
# workbook, or a copy of it with text replaced in its XML parts. The
# overview there has "- **Top Strengths**: " and the text a case gives on
# its fourth line.
#
# Cases:
#   1. The repository files: exit 0, RESULT: PASS, three entries, the
#      threshold 3.6 and the maximum 4 read from the workbook, and a PASS
#      line for each rule.
#   2. The Top Strengths text that toolkit/toolkit-overview.md had before
#      it named the score: exit 1, a FAIL line for each of the three rules
#      that names line 4.
#   3. The Top Strengths text of the repository overview: exit 0, a PASS
#      line for each rule that names line 4.
#   4. "UP TO 3", 3.60 and "out of 4.0": exit 0.
#   5. The text of case 3 with 3.5 in place of 3.6: exit 1, one FAIL line,
#      which names 3.6.
#   6. A workbook whose three marks test 3.5, with the text of case 5:
#      exit 0, threshold 3.5.
#   7. That workbook with the text of case 3: exit 1, a FAIL line that
#      names 3.5.
#   8. A workbook whose three marks test 4, with a text whose only 4 is in
#      "out of 4": exit 1, a FAIL line that names 4.
#   9. That workbook with a text that also says "its score is 4": exit 0.
#  10. A workbook whose B39 tests 3.5: exit 1, a FAIL line that gives the
#      three thresholds, and the overview is not checked.
#  11. A workbook whose C40 tests B35: exit 1, a FAIL line for C40.
#  12. A workbook whose C44 gives the score in A40: exit 1, a FAIL line for
#      C44.
#  13. A workbook whose B35 tests ISTEXT in place of ISNUMBER: exit 1, a
#      FAIL line for B35.
#  14. A workbook whose C34 reads "Top Practices": exit 1, a FAIL line for
#      C34.
#  15. A workbook whose B35 has spaces and a line break outside its quoted
#      text: exit 0.
#  16. A workbook with no sheet named Scorecard: exit 1.
#  17. An overview whose only Top Strengths line is in a fenced code block:
#      exit 1, a FAIL line that says no line outside one has it.
#  18. No overview: exit 1, a FAIL line that says it cannot be read (No
#      such file or directory).
#  19. An overview with a byte that is not UTF-8: exit 1, a FAIL line that
#      says it cannot be read (not UTF-8 text).
#  20. No workbook: exit 1, a FAIL line that says it cannot be read (No
#      such file or directory), and the overview is not checked.
#  21. A text file in place of the workbook: exit 1, a FAIL line that says
#      it cannot be read (not a workbook).
#
# The temporary directory is made under .tmp-tests/ at the repository root,
# and the cleanup removes only a directory under it.
#
# Exit status: 0 when every case passes, 1 when any case fails.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
root="$(dirname "$here")"
checker="$here/check-top-strengths.py"
toolkit="toolkit/QRAMM_Assessment_Toolkit.xlsx"
overview_path="toolkit/toolkit-overview.md"

tmp_root="$(cd "$here/.." && pwd -P)/.tmp-tests"
mkdir -p "$tmp_root"
work="$(mktemp -d "$tmp_root/check-top-strengths.XXXXXX")"
cleanup() {
  case "$work" in
    "$tmp_root"/?*) rm -rf -- "$work" ;;
    *) exit 1 ;;
  esac
  rmdir "$tmp_root" 2> /dev/null || true
}
trap cleanup EXIT

failed=0

# The Top Strengths text of toolkit/toolkit-overview.md before it named the
# score, and the text it has now.
before='Automatically identifies your highest-scoring practices with specific achievements'
now='Up to three of your highest-scoring practices, each named with its score out of 4. A practice is listed only when its score is 3.6 or more.'

# Writes $1, a copy of the toolkit workbook in which, for each pair of the
# remaining arguments, every occurrence of the first in the XML parts under
# xl/ is replaced by the second. Fails when one of the first arguments is in
# none of those parts.
make_copy() {
  python3 -I - "$root/$toolkit" "$@" <<'PY'
import sys
import zipfile

source, target = sys.argv[1:3]
pairs = list(zip(sys.argv[3::2], sys.argv[4::2]))
found = {old: 0 for old, _ in pairs}
with zipfile.ZipFile(source) as book, zipfile.ZipFile(target, "w") as copy:
    for info in book.infolist():
        data = book.read(info.filename)
        if info.filename.startswith("xl/") and info.filename.endswith(".xml"):
            text = data.decode("utf-8")
            for old, new in pairs:
                found[old] += text.count(old)
                text = text.replace(old, new)
            data = text.encode("utf-8")
        copy.writestr(info, data)
for old, count in found.items():
    if not count:
        print("make_copy: not in {}: {}".format(source, old), file=sys.stderr)
sys.exit(0 if all(found.values()) else 1)
PY
}

# Prints the lines of a fixture overview whose fourth line is the Top
# Strengths line with the text $1.
overview() {
  printf '%s\n' \
    '# Toolkit overview' \
    '' \
    '### Highlights and Recommendations' \
    "- **Top Strengths**: $1" \
    '- **Areas for Improvement**: Pinpoints lowest-scoring practices'
}

# Lays out a copy of the repository at $work/$1 with the checker, a copy of
# the workbook $2 unless $2 is empty, and an overview whose Top Strengths
# text is $3 when a third argument is given. Sets layout to its path.
make_layout() {
  layout="$work/$1"
  mkdir -p "$layout/scripts" "$layout/toolkit"
  cp "$checker" "$layout/scripts/check-top-strengths.py"
  if [ -n "$2" ]; then
    cp "$2" "$layout/$toolkit"
  fi
  if [ "$#" -ge 3 ]; then
    overview "$3" > "$layout/$overview_path"
  fi
}

# Runs the checker in the layout at $1, or the repository's checker when $1
# is empty. Sets out, err and status.
run_checker() {
  local script="$checker"
  if [ -n "$1" ]; then
    script="$1/scripts/check-top-strengths.py"
  fi
  status=0
  python3 -I "$script" > "$work/out" 2> "$work/err" || status=$?
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

has_line_matching() {
  printf '%s\n' "$out" | grep -q -x -E -- "$1"
}

last_line_is() {
  [ "$(printf '%s\n' "$out" | tail -n 1)" = "$1" ]
}

show_output() {
  echo "  -- stdout --"
  printf '%s\n' "$out" | sed 's/^/  /'
  echo "  -- stderr --"
  printf '%s\n' "$err" | sed 's/^/  /'
}

# Runs one case: $1 is its title and $2 the layout, or empty for the
# repository. Leaves the result in out, err and status for the expect lines
# that follow.
start_case() {
  echo "$1"
  case_failed="$failed"
  failed=0
  run_checker "$2"
}

end_case() {
  [ "$failed" -eq 0 ] || show_output
  failed=$((failed | case_failed))
}

start_case "case 1: repository files" ""
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "last line is RESULT: PASS" 'last_line_is "RESULT: PASS"'
expect "three entries" 'has_line "  3 entries: C36, C40 and C44"'
expect "threshold 3.6" 'has_line "  threshold 3.6"'
expect "maximum 4" 'has_line "  out of 4"'
expect "the overview says up to three" \
  'has_line_matching "  PASS line [0-9]+: up to three"'
expect "the overview gives the threshold" \
  'has_line_matching "  PASS line [0-9]+: threshold 3\.6"'
expect "the overview says out of 4" \
  'has_line_matching "  PASS line [0-9]+: out of 4"'
end_case

make_layout before "$root/$toolkit" "$before"
start_case "case 2: the Top Strengths text the overview had before" "$layout"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line for up to three" \
  'has_fail "$overview_path:4: does not say \"up to three\"; the Scorecard has three Top Strengths entries (C36, C40 and C44)"'
expect "FAIL line for the threshold" \
  'has_fail "$overview_path:4: does not give 3.6, the score from which the Scorecard lists a practice (B35, B39 and B43)"'
expect "FAIL line for the maximum" \
  'has_fail "$overview_path:4: does not say \"out of 4\"; the Scorecard gives each score out of 4 (C36, C40 and C44)"'
expect "three FAIL lines" '[ "$(fail_count)" -eq 3 ]'
expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
end_case

make_layout now "$root/$toolkit" "$now"
start_case "case 3: the Top Strengths text of the repository overview" "$layout"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "PASS line for up to three" 'has_line "  PASS line 4: up to three"'
expect "PASS line for the threshold" 'has_line "  PASS line 4: threshold 3.6"'
expect "PASS line for the maximum" 'has_line "  PASS line 4: out of 4"'
expect "last line is RESULT: PASS" 'last_line_is "RESULT: PASS"'
end_case

make_layout digits "$root/$toolkit" \
  'UP TO 3 practices that score 3.60 or more, each with its score out of 4.0'
start_case "case 4: UP TO 3, 3.60 and out of 4.0" "$layout"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "PASS line for up to three" 'has_line "  PASS line 4: up to three"'
expect "PASS line for the threshold" 'has_line "  PASS line 4: threshold 3.6"'
expect "PASS line for the maximum" 'has_line "  PASS line 4: out of 4"'
end_case

make_layout text-3.5 "$root/$toolkit" "${now/3.6/3.5}"
start_case "case 5: a text that gives 3.5" "$layout"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line for the threshold" \
  'has_fail "$overview_path:4: does not give 3.6, the score from which the Scorecard lists a practice"'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "PASS line for up to three" 'has_line "  PASS line 4: up to three"'
expect "PASS line for the maximum" 'has_line "  PASS line 4: out of 4"'
end_case

make_copy "$work/marks-3.5.xlsx" '&gt;=3.6' '&gt;=3.5'
make_layout marks-3.5 "$work/marks-3.5.xlsx" "${now/3.6/3.5}"
start_case "case 6: marks that test 3.5, and a text that gives 3.5" "$layout"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "threshold 3.5" 'has_line "  threshold 3.5"'
expect "PASS line for the threshold" 'has_line "  PASS line 4: threshold 3.5"'
end_case

make_layout marks-3.5-text-3.6 "$work/marks-3.5.xlsx" "$now"
start_case "case 7: marks that test 3.5, and a text that gives 3.6" "$layout"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line names 3.5" \
  'has_fail "$overview_path:4: does not give 3.5, the score from which the Scorecard lists a practice (B35, B39 and B43)"'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
end_case

make_copy "$work/marks-4.xlsx" '&gt;=3.6' '&gt;=4'
make_layout marks-4 "$work/marks-4.xlsx" \
  'Up to three of your highest-scoring practices, each named with its score out of 4.'
start_case "case 8: marks that test 4, and a text whose only 4 is in out of 4" "$layout"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "threshold 4" 'has_line "  threshold 4"'
expect "FAIL line names 4" \
  'has_fail "$overview_path:4: does not give 4, the score from which the Scorecard lists a practice"'
expect "PASS line for the maximum" 'has_line "  PASS line 4: out of 4"'
end_case

make_layout marks-4-text-4 "$work/marks-4.xlsx" \
  'Up to three of your highest-scoring practices, each named with its score out of 4. A practice is listed only when its score is 4.'
start_case "case 9: marks that test 4, and a text that gives 4" "$layout"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "PASS line for the threshold" 'has_line "  PASS line 4: threshold 4"'
end_case

make_copy "$work/b39-3.5.xlsx" 'A40&gt;=3.6' 'A40&gt;=3.5'
make_layout b39-3.5 "$work/b39-3.5.xlsx" "$now"
start_case "case 10: B39 tests 3.5" "$layout"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line gives the three thresholds" \
  'has_fail "$toolkit: Scorecard!B35, B39 and B43 give different thresholds: B35 3.6, B39 3.5, B43 3.6"'
expect "the overview is not checked" \
  '! has_line "== $overview_path against the Scorecard"'
expect "last line is RESULT: FAIL" 'last_line_is "RESULT: FAIL"'
end_case

make_copy "$work/c40-b35.xlsx" 'IF(B39="","",INDEX' 'IF(B35="","",INDEX'
make_layout c40-b35 "$work/c40-b35.xlsx" "$now"
start_case "case 11: C40 tests B35" "$layout"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line for C40" 'has_fail "$toolkit: Scorecard!C40 tests B35, not B39"'
end_case

make_copy "$work/c44-a40.xlsx" 'FIXED(A44,2)' 'FIXED(A40,2)'
make_layout c44-a40 "$work/c44-a40.xlsx" "$now"
start_case "case 12: C44 gives the score in A40" "$layout"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line for C44" \
  'has_fail "$toolkit: Scorecard!C44 gives the score in A40, and B43 tests the score in A44"'
end_case

make_copy "$work/b35-istext.xlsx" 'ISNUMBER(A36)' 'ISTEXT(A36)'
make_layout b35-istext "$work/b35-istext.xlsx" "$now"
start_case "case 13: B35 tests ISTEXT" "$layout"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line for B35" \
  'has_fail "$toolkit: Scorecard!B35 is not a Top Strengths mark formula (see --help)"'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
end_case

make_copy "$work/c34.xlsx" '<t>Top Strengths</t>' '<t>Top Practices</t>'
make_layout c34 "$work/c34.xlsx" "$now"
start_case "case 14: C34 reads Top Practices" "$layout"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line for C34" \
  'has_fail "$toolkit: Scorecard!C34 does not read \"Top Strengths\""'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
end_case

make_copy "$work/b35-spaces.xlsx" 'IF(AND(ISNUMBER(A36),A36&gt;=3.6)' \
  $'IF( AND(ISNUMBER(A36),\n  A36 &gt;= 3.6 )'
make_layout b35-spaces "$work/b35-spaces.xlsx" "$now"
start_case "case 15: B35 has spaces and a line break outside its quoted text" "$layout"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "threshold 3.6" 'has_line "  threshold 3.6"'
end_case

make_copy "$work/no-scorecard.xlsx" 'name="Scorecard"' 'name="Results"'
make_layout no-scorecard "$work/no-scorecard.xlsx" "$now"
start_case "case 16: no sheet named Scorecard" "$layout"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line for the sheet" 'has_fail "$toolkit: no sheet named Scorecard"'
end_case

make_layout fenced "$root/$toolkit"
printf '%s\n' '# Toolkit overview' '' '```' "- **Top Strengths**: $now" '```' \
  > "$layout/$overview_path"
start_case "case 17: the only Top Strengths line is in a fenced code block" "$layout"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line says no line outside one has it" \
  'has_fail "$overview_path: no line outside fenced code blocks contains \"Top Strengths\""'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
end_case

make_layout no-overview "$root/$toolkit"
start_case "case 18: no overview" "$layout"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line says it cannot be read" \
  'has_fail "$overview_path: cannot read (No such file or directory)"'
end_case

make_layout not-utf-8 "$root/$toolkit" "$now"
printf '\xff\n' >> "$layout/$overview_path"
start_case "case 19: an overview with a byte that is not UTF-8" "$layout"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line says it is not UTF-8 text" \
  'has_fail "$overview_path: cannot read (not UTF-8 text)"'
end_case

make_layout no-workbook "" "$now"
start_case "case 20: no workbook" "$layout"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line says it cannot be read" \
  'has_fail "$toolkit: cannot read (No such file or directory)"'
expect "the overview is not checked" \
  '! has_line "== $overview_path against the Scorecard"'
end_case

make_layout text-workbook "$root/README.md" "$now"
start_case "case 21: a text file in place of the workbook" "$layout"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "FAIL line says it is not a workbook" \
  'has_fail "$toolkit: cannot read (not a workbook)"'
end_case

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
