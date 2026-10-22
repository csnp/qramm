#!/usr/bin/env bash
# Tests scripts/check-profile-multiplier.py against the repository documents
# and workbook, against fixture documents that give other multiplier ranges,
# and against copies of the workbook that calculate the multiplier
# differently.
#
# Usage:
#   scripts/test-check-profile-multiplier.sh
#
# Cases 7 to 10, 44 to 46, 49 to 52 and 57 to 60 copy the checker and the toolkit
# workbook into a new temporary directory laid out like the repository
# (scripts/ and toolkit/), edit the copy of the workbook, and run the
# checker there. Cases 15, 17, 38 to 43, 47 and 48 make the same copies and
# pass the copy of the workbook to the repository's checker as a document.
# Cases 53 to 56 copy only the checker into such a directory, put a file
# that cannot be read as a workbook, or no file, in place of the toolkit
# workbook, and run the checker there.
#
# Cases:
#   1. No file arguments (the documents in DOCUMENTS): exit 0, RESULT: PASS,
#      the lowest and highest multiplier read from the workbook are listed
#      as 1.00 and 1.50, and the checklist's line 18 and the Welcome!H9 text
#      of both workbooks each give a PASS line.
#   2. The toolkit overview's earlier wording, "a profile multiplier
#      (0.8-1.5x)": exit 1, one FAIL line that gives 0.8 to 1.5 and the
#      workbook's 1.00 to 1.50.
#   3. The range written as "(1.0-1.5x)", "1.00 - 1.50", "from 1.00 to
#      1.50.", "between 1.00 and 1.50" and "(1.0x to 1.5x range)", on lines
#      that say "multiplier", "Multiplier" or "ProfileMultiplier": exit 0,
#      five PASS lines.
#   4. The ranges "between 0.80 and 1.50", "1.00 to 2.00" and "0.8x-1.5x":
#      exit 1, a FAIL line for each.
#   5. Other ranges on a line that does not say "multiplier" and inside a
#      fenced code block, whole numbers ("3-9") on a line that does, and the
#      workbook's range on one line: exit 0, one PASS line.
#   6. A document that names the multiplier but gives no range: exit 1, a
#      FAIL line that says so.
#   7. A workbook whose risk values of 1.0 are 0.8: the lowest multiplier is
#      listed as 0.80, "between 1.00 and 1.50" fails and "(0.8-1.5x)"
#      passes.
#   8. A workbook whose risk values of 1.0 are 1.005: the lowest multiplier,
#      1.005, is listed rounded half up to 1.01.
#   9. A workbook whose ProfileMultiplier formula leaves out the factor for
#      the answer in D17: exit 1, one FAIL line that says the formula is not
#      a sum of risk value times factor terms.
#  10. A workbook in which the organization size answers carry the factor
#      0.15, as the geographic scope answers do: exit 1, one FAIL line that
#      says the rows cannot be grouped into profile questions by factor.
#  11. An option such as --help: exit 2, usage on stderr, then the checker's
#      header text.
#  12. -h: exit 2, usage on stderr, then the checker's header text.
#  13. An unknown option, --verbose: exit 2, and on stderr only
#      "unknown option: --verbose" and the usage line.
#  14. Where the fixtures were written: the directory is under .tmp-tests/
#      at the repository root and holds the fixture of case 2.
#  15. A copy of the workbook whose Welcome!H9 text gives the earlier
#      "(0.8x – 1.5x)", with an en dash: exit 1, one FAIL line that names
#      Welcome!H9 line 12 and gives 0.8 to 1.5.
#  16. Ranges written with an en dash, "(0.8x – 1.5x)", "1.00 – 1.50" and
#      "1.0–1.5": exit 1, a FAIL line for the first and a PASS line for each
#      of the others.
#  17. A copy of the workbook whose Welcome!H9 text gives no range: exit 1,
#      a FAIL line that says the workbook gives no multiplier range.
#  18. A text file whose name ends in .xlsx: exit 1, a FAIL line that says
#      it is not a zip file.
#  19. An empty file argument: exit 1, "FAIL '': no file name given", no
#      "cannot read" line.
#  20. A zip archive whose name ends in .xlsx and that holds only a text
#      file: exit 1, a FAIL line that says it is not a workbook, then
#      RESULT: FAIL.
#  21. A workbook whose sheet XML part does not parse: exit 1, a FAIL line
#      that says it is not a workbook.
#  22. A workbook with a text cell whose shared-string index is past the end
#      of the shared string table: exit 1, a FAIL line that says it is not a
#      workbook.
#  23. A workbook whose relationship for its sheet has no Target attribute.
#  24. A workbook whose sheet XML declares the unknown encoding "bogus".
#  25. A workbook whose xl/workbook.xml entry gives compression method 6
#      (implode), which zipfile does not support.
#  26. A workbook whose sheet entry gives compression method 8 (deflate) but
#      holds bytes that are not deflate data.
#  27. A workbook whose xl/workbook.xml entry has the encrypted flag that
#      zip -P sets (general purpose flag bit 0).
#  28. A workbook whose sheet entry gives compression method 93 (Zstandard)
#      but holds bytes that are not Zstandard data.
#  Cases 23 to 28, and case 30 below, pass the workbook and then a text
#  document that gives the workbook's range: exit 1, nothing on stderr, one
#  FAIL line, which says the workbook is not a workbook, a PASS line for the
#  text document, and RESULT: FAIL as the last line.
#  29. A text document with a Latin-1 byte, then a document that gives the
#      workbook's range: exit 1, no traceback, a FAIL line that says the
#      first is not UTF-8 text, a PASS line for the second, then
#      RESULT: FAIL.
#  30. A workbook whose sheet entry gives compression method 12 (bzip2) but
#      holds bytes that are not bzip2 data.
#  31. A .xlsx document that does not exist, then a document that gives the
#      workbook's range: exit 1, nothing on stderr, a FAIL line that gives
#      the reason "No such file or directory", a PASS line for the second,
#      then RESULT: FAIL.
#  32. A workbook whose sheet entry holds bytes that do not match the CRC-32
#      its headers give.
#  33. A workbook whose first entry gives another file name in its local
#      file header than in the central directory.
#  Cases 32 and 33 are zip archives that zipfile.is_zipfile() accepts.
#  zipfile raises BadZipFile when it reads the damaged entry. They pass the
#  workbook and then a text document that gives the workbook's range, and
#  expect the results of cases 23 to 28.
#  34. A zip archive whose zip64 end of central directory locator gives two
#      disks, which zipfile does not open, then a text document that gives
#      the workbook's range: exit 1, nothing on stderr, one FAIL line, which
#      says the archive is not a zip file, a PASS line for the text document,
#      and RESULT: FAIL as the last line. zipfile.is_zipfile() returns False
#      for this archive in Python 3.13.12 and 3.14.3, and raises BadZipFile
#      for it in Python 3.9.6.
#  35. Under the en_US.UTF-8 locale, a file name argument that holds the
#      byte 0xff, which is not valid UTF-8, and names no file, then a
#      document that gives the workbook's range: exit 1, no traceback, the
#      name printed with the byte as \xff on its == line and in a FAIL line
#      that says it cannot be read, a PASS line for the second document,
#      then RESULT: FAIL.
#  36. Under the en_US.ISO8859-1 locale, a file name argument that is valid
#      UTF-8 and holds the character U+65E5, which ISO-8859-1 cannot encode,
#      and names no file, then a document that gives the workbook's range:
#      exit 1, nothing on stderr, the name printed with the character as
#      \u65e5 on its == line and in a FAIL line that says it cannot be
#      read, a PASS line for the second document, then RESULT: FAIL. The
#      case is skipped, with a line that says so, when python3 -I does not
#      decode file names as UTF-8 and write stdout as ISO-8859-1 under that
#      locale on this machine.
#  37. A workbook whose end of central directory record gives a central
#      directory offset 1000 bytes past the end of the file, then a text
#      document that gives the workbook's range: the results of cases 23 to
#      28. zipfile.is_zipfile() accepts this archive, and zipfile raises
#      OSError(22, "Invalid argument") when it reads the first entry.
#  38. A copy of the workbook whose text cell Welcome!H9 stores its shared
#      string index 1820 written as +1820.
#  39. A copy whose Welcome!H9 stores the index written as " 1820", a space
#      followed by 1820.
#  40. A copy whose Welcome!H9 stores the index written as "1820 ", 1820
#      followed by a space.
#  41. A copy whose Welcome!H9 stores the index written as 18_20.
#  42. A copy whose Welcome!H9 stores the index written with the
#      ARABIC-INDIC digits U+0661, U+0668, U+0662 and U+0660.
#  43. A copy whose Welcome!H9 stores -1 in place of the index 1820.
#  Cases 38 to 43 pass the copy and then a text document that gives the
#  workbook's range, and expect the results of cases 23 to 28: the copy
#  fails as the workbook of case 22, whose index is past the end of the
#  shared string table, does. int() strips whitespace from the start and
#  end of text, reads a leading sign, allows an underscore between two
#  digits and reads the other Unicode decimal digits, so it reads the index
#  of cases 38 to 42 as 1820, and -1 as the index of the last shared string.
#  44. A workbook whose RiskMatrix cell Data!M3 stores its shared string
#      index 16 written as +16.
#  45. A workbook whose Data!M3 stores 99999999, past the end of the shared
#      string table, in place of the index 16.
#  46. Under the en_US.ISO8859-1 locale, a workbook whose Data!M3 stores the
#      index written with the ARABIC-INDIC digits U+0661 and U+0666.
#  Cases 44 to 46 run a copy of the checker beside the workbook with a text
#  document that gives the workbook's range: exit 1, nothing on stderr, one
#  FAIL line, which names the workbook and Data!M3 and gives the index as
#  written, with each character outside ASCII as a backslash escape
#  (\u0661\u0666 for the digits of case 46), no document checked, and
#  RESULT: FAIL as the last line.
#  Cases 47 to 52 run under the en_US.ISO8859-1 locale, under which python3
#  writes stdout as ISO-8859-1. That encoding has no byte for U+65E5 and
#  U+672C, the sheet name the cases give, or for the ARABIC-INDIC digits
#  U+0663 and U+0667. Each case expects nothing on stderr and each such
#  character printed as a backslash escape, such as \u65e5. The cases are
#  skipped, with a line that says so, when python3 -I does not write stdout
#  as ISO-8859-1 under that locale on this machine.
#  47. A copy of the workbook whose Welcome sheet is named U+65E5 U+672C:
#      exit 0, one PASS line, "PASS \u65e5\u672c!H9 line 12: 1.00 to
#      1.50", then RESULT: PASS.
#  48. A copy whose Welcome sheet is named that way and whose H9 text gives
#      the earlier "(0.8x – 1.5x)": exit 1, one FAIL line, which names
#      \u65e5\u672c!H9 line 12 and gives 0.8 to 1.5, then RESULT: FAIL.
#  49. A workbook whose Data sheet is named U+65E5 U+672C, in
#      xl/workbook.xml and in the RiskMatrix defined name, with a text
#      document that gives the workbook's range: exit 0, the == line gives
#      RiskMatrix as \u65e5\u672c!M2:O30, a PASS line for the document, then
#      RESULT: PASS.
#  50. A workbook whose Data sheet is named that way and whose Data!M3
#      stores its shared string index written as +16: the results of case
#      44, with the cell named \u65e5\u672c!M3.
#  51. A workbook whose Data!M3 has the r attribute M followed by U+0663,
#      which the checker reads as M3, and stores +16: the results of case
#      44, with the cell named Data!M\u0663.
#  52. A workbook whose ProfileMultiplier formula gives the answer D17 as D1
#      followed by U+0667, with a text document that gives the workbook's
#      range: exit 0, the answers line "answers: D9, D11, D13, D15,
#      D1\u0667", a PASS line for the document, then RESULT: PASS.
#  53. A toolkit workbook that is a text file, the line "not a workbook": a
#      FAIL line that says it is not a zip file.
#  54. No toolkit workbook: a FAIL line that gives the reason "No such file
#      or directory".
#  55. A toolkit workbook that is a zip archive that holds only a text file:
#      a FAIL line that says it is not a workbook.
#  56. A toolkit workbook that is a zip archive whose xl/workbook.xml entry
#      holds bytes that do not match the CRC-32 its headers give: a FAIL
#      line that says it is not a workbook.
#  Cases 53 to 56 run the copy of the checker with a text document that
#  gives the workbook's range: exit 1, nothing on stderr, one FAIL line,
#  which names the toolkit workbook and gives the reason, no == line, so no
#  document checked, and RESULT: FAIL as the last line.
#  57. A workbook whose ProfileMultiplier formula rounds to 28 places, more
#      digits than the 28 of the default decimal context once the integer
#      digit is counted: exit 0, nothing on stderr, the lowest and highest
#      multiplier listed with 28 places, a PASS line for a text document
#      that gives 1.00 to 1.50, then RESULT: PASS.
#  58. A workbook whose formula rounds to 1000000 places: the results of
#      case 57, with zeros added to the multipliers up to 28 places only.
#  59. A workbook whose formula rounds to 34 places and whose risk values
#      of 1.0 are 1.0 followed by 33 zeros and a 5: exit 1, nothing on
#      stderr, the lowest multiplier, 1 + 5 * 10^-35, listed rounded half
#      up to 34 places, and a FAIL line for the document that gives 1.00 to
#      1.50.
#  60. A workbook whose factor 0.10, the factor of the organization size
#      answers in RiskMatrix rows 27 to 30, is written as
#      1E-100000000000000000: exit 1, nothing on stderr, a FAIL line for
#      each of those rows that says its factor and risk value are not both
#      numbers, no == line, so no document checked, and RESULT: FAIL as the
#      last line. Decimal() reads that text, and an exact sum with it has
#      10^17 decimal places or more.
#
# The temporary directory is made under .tmp-tests/ at the repository root,
# and the cleanup removes only a directory under it.
#
# Exit status: 0 when every case passes, 1 when any case fails.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
root="$(dirname "$here")"
checker="$here/check-profile-multiplier.py"
toolkit="toolkit/QRAMM_Assessment_Toolkit.xlsx"

tmp_root="$root/.tmp-tests"
mkdir -p "$tmp_root"
work="$(mktemp -d "$tmp_root/check-profile-multiplier.XXXXXX")"
cleanup() {
  case "$work" in
    "$tmp_root"/?*) rm -rf -- "$work" ;;
    *) exit 1 ;;
  esac
  rmdir "$tmp_root" 2> /dev/null || true
}
trap cleanup EXIT

failed=0

# Lays out a copy of the checker at $1, in $1/scripts/, beside an empty
# toolkit/ directory.
copy_checker() {
  mkdir -p "$1/scripts" "$1/toolkit"
  cp "$checker" "$1/scripts/check-profile-multiplier.py"
}

# Lays out a copy of the checker at $1, with a copy of the toolkit workbook
# in which every "$2" in its XML parts under xl/ is replaced by "$3", then
# every "$4" by "$5", and so on for each further pair of arguments. Fails
# when no such part of the workbook contains "$2", or "$4" and so on.
make_copy() {
  local dir="$1"
  shift
  copy_checker "$dir"
  python3 -I - "$root/$toolkit" "$dir/$toolkit" "$@" <<'PY'
import sys
import zipfile

source, target = sys.argv[1:3]
pairs = list(zip(sys.argv[3::2], sys.argv[4::2]))
found = [0] * len(pairs)
with zipfile.ZipFile(source) as book, zipfile.ZipFile(target, "w") as copy:
    for info in book.infolist():
        data = book.read(info.filename)
        if info.filename.startswith("xl/") and info.filename.endswith(".xml"):
            text = data.decode("utf-8")
            for number, (old, new) in enumerate(pairs):
                found[number] += text.count(old)
                text = text.replace(old, new)
            data = text.encode("utf-8")
        copy.writestr(info, data)
sys.exit(0 if all(found) else 1)
PY
}

# Runs the checker at $1 with the remaining arguments. Sets out, err and
# status.
run_checker() {
  local checker_path="$1"
  shift
  status=0
  python3 -I "$checker_path" "$@" > "$work/out" 2> "$work/err" || status=$?
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

pass_count() {
  printf '%s\n' "$out" | grep -c '^  PASS' || true
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

# Runs one case: $1 is its title, $2 the checker, the rest are checker
# arguments. Leaves the result in out, err and status for the expect lines
# that follow.
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

start_case "case 1: repository documents and workbook" "$checker"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
expect "workbook answers are listed" 'has_line "  answers: D9, D11, D13, D15, D17"'
expect "workbook range is 1.00 to 1.50" 'has_line "  lowest 1.00, highest 1.50"'
expect "no FAIL lines" '[ "$(fail_count)" -eq 0 ]'
expect "the checklist is checked" \
  "has_line '== toolkit-specs/MASTER_PLAN_Document_Checklist.md against $toolkit'"
expect "PASS line for the checklist's line 18" 'has_line "  PASS line 18: 1.00 to 1.50"'
expect "the text of both workbooks is checked" \
  "has_line '== $toolkit against $toolkit' && has_line '== toolkit/Sample_Assessment.xlsx against $toolkit'"
expect "a PASS line for Welcome!H9 in each workbook" \
  '[ "$(printf "%s\n" "$out" | grep -c -x -F "  PASS Welcome!H9 line 12: 1.00 to 1.50")" -eq 2 ]'
end_case

printf '%s\n' \
  'The Organization Profile Tab captures this context through a profile multiplier (0.8-1.5x) that adjusts raw scores based on:' \
  > "$work/old.md"
start_case "case 2: the toolkit overview's earlier wording" "$checker" "$work/old.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line gives 0.8 to 1.5 and the workbook range" \
  "has_fail 'old.md line 1: the multiplier range is 0.8 to 1.5 here, but $toolkit calculates 1.00 to 1.50'"
end_case

printf '%s\n' \
  'The profile multiplier (1.0-1.5x) adjusts the dimension scores.' \
  'A Multiplier of 1.00 - 1.50 applies.' \
  'The multiplier runs from 1.00 to 1.50.' \
  'It is a profile multiplier between 1.00 and 1.50, set on the Profile tab.' \
  '- [ ] ProfileMultiplier calculates correctly (1.0x to 1.5x range)' \
  > "$work/forms.md"
start_case "case 3: the workbook's range in five forms" "$checker" "$work/forms.md"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
expect "five PASS lines" '[ "$(pass_count)" -eq 5 ]'
expect "PASS line for (1.0-1.5x)" 'has_line "  PASS line 1: 1.0 to 1.5"'
expect "PASS line for 1.00 - 1.50" 'has_line "  PASS line 2: 1.00 to 1.50"'
expect "PASS line for from 1.00 to 1.50." 'has_line "  PASS line 3: 1.00 to 1.50"'
expect "PASS line for between 1.00 and 1.50" 'has_line "  PASS line 4: 1.00 to 1.50"'
expect "PASS line for (1.0x to 1.5x range)" 'has_line "  PASS line 5: 1.0 to 1.5"'
end_case

printf '%s\n' \
  'The profile multiplier is between 0.80 and 1.50.' \
  'The multiplier runs from 1.00 to 2.00.' \
  'A profile multiplier (0.8x-1.5x) adjusts the scores.' \
  > "$work/wrong.md"
start_case "case 4: other ranges" "$checker" "$work/wrong.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "three FAIL lines" '[ "$(fail_count)" -eq 3 ]'
expect "FAIL line for between 0.80 and 1.50" \
  "has_fail 'wrong.md line 1: the multiplier range is 0.80 to 1.50 here, but $toolkit calculates 1.00 to 1.50'"
expect "FAIL line for 1.00 to 2.00" \
  "has_fail 'wrong.md line 2: the multiplier range is 1.00 to 2.00 here, but $toolkit calculates 1.00 to 1.50'"
expect "FAIL line for 0.8x-1.5x" \
  "has_fail 'wrong.md line 3: the multiplier range is 0.8 to 1.5 here, but $toolkit calculates 1.00 to 1.50'"
end_case

printf '%s\n' \
  'Answers are scored from 1.0 to 4.0, and adjusted scores can reach 6.0.' \
  '```' \
  'Profile multiplier: 0.8-1.5' \
  '```' \
  'A Multi-region (3-9 countries) answer raises the multiplier.' \
  'The profile multiplier is between 1.00 and 1.50.' \
  > "$work/skipped.md"
start_case "case 5: ranges that are not multiplier ranges" "$checker" "$work/skipped.md"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
expect "one PASS line, for line 6" \
  '[ "$(pass_count)" -eq 1 ] && has_line "  PASS line 6: 1.00 to 1.50"'
end_case

printf '%s\n' \
  'The Organization Profile Tab captures this context through a profile multiplier.' \
  'Each answer carries a risk value of 1.0, 1.3 or 1.5.' \
  > "$work/norange.md"
start_case "case 6: no multiplier range" "$checker" "$work/norange.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says there is no range" 'has_fail "norange.md: gives no multiplier range"'
end_case

printf '%s\n' \
  'The Organization Profile Tab captures this context through a profile multiplier between 1.00 and 1.50 that adjusts raw scores based on:' \
  > "$work/new.md"

make_copy "$work/low" '> 1.0 <' '> 0.8 <'
start_case "case 7: workbook whose risk values of 1.0 are 0.8" \
  "$work/low/scripts/check-profile-multiplier.py" "$work/new.md" "$work/old.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "workbook range is 0.80 to 1.50" 'has_line "  lowest 0.80, highest 1.50"'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line for between 1.00 and 1.50" \
  "has_fail 'new.md line 1: the multiplier range is 1.00 to 1.50 here, but $toolkit calculates 0.80 to 1.50'"
expect "PASS line for (0.8-1.5x)" 'has_line "  PASS line 1: 0.8 to 1.5"'
end_case

make_copy "$work/half" '> 1.0 <' '> 1.005 <'
start_case "case 8: workbook whose risk values of 1.0 are 1.005" \
  "$work/half/scripts/check-profile-multiplier.py" "$work/new.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "workbook range is 1.01 to 1.50" 'has_line "  lowest 1.01, highest 1.50"'
expect "FAIL line for between 1.00 and 1.50" \
  "has_fail 'new.md line 1: the multiplier range is 1.00 to 1.50 here, but $toolkit calculates 1.01 to 1.50'"
end_case

make_copy "$work/noterm" \
  'VLOOKUP(D17, RiskMatrix, 3, FALSE) * VLOOKUP(D17, RiskMatrix, 2, FALSE)' \
  'VLOOKUP(D17, RiskMatrix, 3, FALSE)'
start_case "case 9: formula without the factor for D17" \
  "$work/noterm/scripts/check-profile-multiplier.py" "$work/new.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says the formula has another form" \
  "has_fail '$toolkit: Profile!D21 (ProfileMultiplier) is not ROUND of a sum of VLOOKUP(answer, RiskMatrix, 3, FALSE) * VLOOKUP(answer, RiskMatrix, 2, FALSE) terms'"
expect "no document is checked" '[ "$(pass_count)" -eq 0 ]'
end_case

make_copy "$work/shared" '> 0.10 <' '> 0.15 <'
start_case "case 10: two profile questions with the factor 0.15" \
  "$work/shared/scripts/check-profile-multiplier.py" "$work/new.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says the rows cannot be grouped" \
  "has_fail '$toolkit: RiskMatrix has 4 different factors but Profile!D21 adds 5 answers, so its rows cannot be grouped into profile questions by factor'"
end_case

start_case "case 11: option argument" "$checker" --help
expect "exit status is 2" '[ "$status" -eq 2 ]'
expect "usage on stderr" 'printf "%s\n" "$err" | grep -q "^usage:"'
expect "header text on stderr" \
  'printf "%s\n" "$err" | grep -qx "Checks that documents giving the range of the QRAMM profile multiplier"'
end_case

start_case "case 12: -h" "$checker" -h
expect "exit status is 2" '[ "$status" -eq 2 ]'
expect "usage on stderr" 'printf "%s\n" "$err" | grep -q "^usage:"'
expect "header text on stderr" \
  'printf "%s\n" "$err" | grep -qx "Checks that documents giving the range of the QRAMM profile multiplier"'
end_case

start_case "case 13: unknown option" "$checker" --verbose
expect "exit status is 2" '[ "$status" -eq 2 ]'
expected="$(printf '%s\n' "unknown option: --verbose" \
  "usage: python3 -I scripts/check-profile-multiplier.py [file ...]")"
expect "only the option and the usage line on stderr" '[ "$err" = "$expected" ]'
end_case

echo "case 14: where the fixtures were written"
case_failed="$failed"
failed=0
expect "fixtures directory is under .tmp-tests/ at the repository root" \
  'case "$work" in "$root"/.tmp-tests/?*) true ;; *) false ;; esac'
expect "the fixture of case 2 is in it" '[ -f "$work/old.md" ]'
[ "$failed" -eq 0 ] || echo "  -- fixtures directory: $work"
failed=$((failed | case_failed))

make_copy "$work/oldtext" \
  'multiplier between 1.00 and 1.50, adjusted by' \
  'multiplier (0.8x – 1.5x), adjusted by'
start_case "case 15: workbook whose Welcome!H9 text gives the earlier range" \
  "$checker" "$work/oldtext/$toolkit"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line names Welcome!H9 line 12 and gives 0.8 to 1.5" \
  "has_fail 'oldtext/$toolkit Welcome!H9 line 12: the multiplier range is 0.8 to 1.5 here, but $toolkit calculates 1.00 to 1.50'"
end_case

printf '%s\n' \
  'A profile multiplier (0.8x – 1.5x) adjusts the scores.' \
  'The multiplier runs 1.00 – 1.50, set on the Profile tab.' \
  'The multiplier is 1.0–1.5.' \
  > "$work/endash.md"
start_case "case 16: ranges written with an en dash" "$checker" "$work/endash.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line for (0.8x – 1.5x)" \
  "has_fail 'endash.md line 1: the multiplier range is 0.8 to 1.5 here, but $toolkit calculates 1.00 to 1.50'"
expect "two PASS lines" '[ "$(pass_count)" -eq 2 ]'
expect "PASS line for 1.00 – 1.50" 'has_line "  PASS line 2: 1.00 to 1.50"'
expect "PASS line for 1.0–1.5" 'has_line "  PASS line 3: 1.0 to 1.5"'
end_case

make_copy "$work/norangebook" \
  'multiplier between 1.00 and 1.50, adjusted by' \
  'multiplier, adjusted by'
start_case "case 17: workbook whose text gives no multiplier range" \
  "$checker" "$work/norangebook/$toolkit"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says there is no range" \
  "has_fail 'norangebook/$toolkit: gives no multiplier range'"
end_case

printf '%s\n' 'The profile multiplier is between 1.00 and 1.50.' > "$work/text.xlsx"
start_case "case 18: a text file whose name ends in .xlsx" "$checker" "$work/text.xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says it is not a zip file" \
  "has_fail 'text.xlsx: cannot read (not a zip file)'"
end_case

start_case "case 19: an empty file argument" "$checker" ""
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL says no file name was given" \
  'printf "%s\n" "$out" | grep -qxF "  FAIL '"''"': no file name given"'
expect "no cannot read line" '! printf "%s\n" "$out" | grep -q "cannot read"'
end_case

# Writes a zip archive at $1 with one entry per remaining argument, each of
# the form name=content.
make_zip() {
  python3 -I - "$@" <<'PY'
import sys
import zipfile

with zipfile.ZipFile(sys.argv[1], "w") as book:
    for entry in sys.argv[2:]:
        name, _, content = entry.partition("=")
        book.writestr(name, content)
PY
}

main_ns='http://schemas.openxmlformats.org/spreadsheetml/2006/main'
rel_ns='http://schemas.openxmlformats.org/officeDocument/2006/relationships'
pkg_rel_ns='http://schemas.openxmlformats.org/package/2006/relationships'
book_xml="xl/workbook.xml=<workbook xmlns=\"$main_ns\" xmlns:r=\"$rel_ns\"><sheets><sheet name=\"Notes\" sheetId=\"1\" r:id=\"rId1\"/></sheets></workbook>"
rels_xml="xl/_rels/workbook.xml.rels=<Relationships xmlns=\"$pkg_rel_ns\"><Relationship Id=\"rId1\" Target=\"worksheets/sheet1.xml\"/></Relationships>"
strings_xml="xl/sharedStrings.xml=<sst xmlns=\"$main_ns\"><si><t>The profile multiplier is between 1.00 and 1.50.</t></si></sst>"

make_zip "$work/notabook.xlsx" 'note.txt=note'
start_case "case 20: a zip archive that is not a workbook" "$checker" "$work/notabook.xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says it is not a workbook" \
  "has_fail 'notabook.xlsx: cannot read (not a workbook)'"
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

make_zip "$work/badxml.xlsx" "$book_xml" "$rels_xml" "$strings_xml" \
  "xl/worksheets/sheet1.xml=<worksheet xmlns=\"$main_ns\"><sheetData>"
start_case "case 21: a workbook whose sheet XML does not parse" "$checker" "$work/badxml.xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says it is not a workbook" \
  "has_fail 'badxml.xlsx: cannot read (not a workbook)'"
end_case

make_zip "$work/badindex.xlsx" "$book_xml" "$rels_xml" "$strings_xml" \
  "xl/worksheets/sheet1.xml=<worksheet xmlns=\"$main_ns\"><sheetData><row r=\"1\"><c r=\"A1\" t=\"s\"><v>5</v></c></row></sheetData></worksheet>"
start_case "case 22: a shared-string index past the end of the table" "$checker" "$work/badindex.xlsx"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says it is not a workbook" \
  "has_fail 'badindex.xlsx: cannot read (not a workbook)'"
end_case

# Sets the compression method ($3) and the general purpose flags ($4) that
# both headers of the entry $2 give in the zip archive at $1, and leaves the
# bytes stored for the entry as they are.
set_entry() {
  python3 -I - "$@" <<'PY'
import struct
import sys
import zipfile

path, name = sys.argv[1:3]
method, flags = int(sys.argv[3]), int(sys.argv[4])
with zipfile.ZipFile(path) as book:
    infos = book.infolist()
with open(path, "rb") as fh:
    data = bytearray(fh.read())
# The archive has no comment, so its last 22 bytes are the end of central
# directory record, which ends with the central directory's offset and a
# 2-byte comment length.
(directory,) = struct.unpack_from("<I", data, len(data) - 6)
found = 0
for info in infos:
    if info.filename == name:
        found += 1
        struct.pack_into("<HH", data, info.header_offset + 6, flags, method)
        struct.pack_into("<HH", data, directory + 8, flags, method)
    names, extra, comment = struct.unpack_from("<HHH", data, directory + 28)
    directory += 46 + names + extra + comment
with open(path, "wb") as fh:
    fh.write(data)
sys.exit(0 if found else 1)
PY
}

# Expectations for cases 23 to 28, 30, 32, 33 and 37 to 43: $1 is the
# workbook's file name, or the end of its path.
expect_not_a_workbook() {
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "no traceback on stderr" '[ -z "$err" ]'
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line says it is not a workbook" \
    "has_fail '$1: cannot read (not a workbook)'"
  expect "the document after it is checked" \
    '[ "$(pass_count)" -eq 1 ] && has_line "  PASS line 1: 1.00 to 1.50"'
  expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
}

sheet_xml="xl/worksheets/sheet1.xml=<worksheet xmlns=\"$main_ns\"><sheetData><row r=\"1\"><c r=\"A1\" t=\"s\"><v>0</v></c></row></sheetData></worksheet>"

make_zip "$work/notarget.xlsx" "$book_xml" \
  "xl/_rels/workbook.xml.rels=<Relationships xmlns=\"$pkg_rel_ns\"><Relationship Id=\"rId1\"/></Relationships>" \
  "$strings_xml" "$sheet_xml"
start_case "case 23: a relationship without a Target" \
  "$checker" "$work/notarget.xlsx" "$work/new.md"
expect_not_a_workbook notarget.xlsx
end_case

make_zip "$work/encoding.xlsx" "$book_xml" "$rels_xml" "$strings_xml" \
  "xl/worksheets/sheet1.xml=<?xml version=\"1.0\" encoding=\"bogus\"?>${sheet_xml#*=}"
start_case "case 24: XML that declares an unknown encoding" \
  "$checker" "$work/encoding.xlsx" "$work/new.md"
expect_not_a_workbook encoding.xlsx
end_case

make_zip "$work/method.xlsx" "$book_xml" "$rels_xml" "$strings_xml" "$sheet_xml"
set_entry "$work/method.xlsx" xl/workbook.xml 6 0
start_case "case 25: a compression method zipfile does not support" \
  "$checker" "$work/method.xlsx" "$work/new.md"
expect_not_a_workbook method.xlsx
end_case

make_zip "$work/deflate.xlsx" "$book_xml" "$rels_xml" "$strings_xml" \
  "xl/worksheets/sheet1.xml=not deflate data"
set_entry "$work/deflate.xlsx" xl/worksheets/sheet1.xml 8 0
start_case "case 26: deflate data that does not decompress" \
  "$checker" "$work/deflate.xlsx" "$work/new.md"
expect_not_a_workbook deflate.xlsx
end_case

make_zip "$work/encrypted.xlsx" "$book_xml" "$rels_xml" "$strings_xml" "$sheet_xml"
set_entry "$work/encrypted.xlsx" xl/workbook.xml 0 1
start_case "case 27: an encrypted entry" \
  "$checker" "$work/encrypted.xlsx" "$work/new.md"
expect_not_a_workbook encrypted.xlsx
end_case

make_zip "$work/zstd.xlsx" "$book_xml" "$rels_xml" "$strings_xml" \
  "xl/worksheets/sheet1.xml=not zstd data"
set_entry "$work/zstd.xlsx" xl/worksheets/sheet1.xml 93 0
start_case "case 28: Zstandard data that does not decompress" \
  "$checker" "$work/zstd.xlsx" "$work/new.md"
expect_not_a_workbook zstd.xlsx
end_case

# \351 is e with an acute accent in Latin-1, and not valid UTF-8 here.
printf 'The profile multiplier is between 1.00 and 1.50, caf\351.\n' > "$work/latin1.md"
start_case "case 29: a text document that is not UTF-8" "$checker" "$work/latin1.md" "$work/new.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says it is not UTF-8 text" \
  "has_fail 'latin1.md: cannot read (not UTF-8 text)'"
expect "the next document is checked" \
  "has_line '== $work/new.md against $toolkit' && has_line '  PASS line 1: 1.00 to 1.50'"
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

make_zip "$work/bzip2.xlsx" "$book_xml" "$rels_xml" "$strings_xml" \
  "xl/worksheets/sheet1.xml=not bzip2 data"
set_entry "$work/bzip2.xlsx" xl/worksheets/sheet1.xml 12 0
start_case "case 30: bzip2 data that does not decompress" \
  "$checker" "$work/bzip2.xlsx" "$work/new.md"
expect_not_a_workbook bzip2.xlsx
end_case

start_case "case 31: a .xlsx document that does not exist" \
  "$checker" "$work/missing.xlsx" "$work/new.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line gives the reason No such file or directory" \
  "has_fail 'missing.xlsx: cannot read (No such file or directory)'"
expect "the next document is checked" \
  "has_line '== $work/new.md against $toolkit' && has_line '  PASS line 1: 1.00 to 1.50'"
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

# Replaces the first "$2" in the bytes of the zip archive at $1 with "$3",
# which has the same length, and changes nothing else. Fails when the
# archive does not hold "$2" or when "$3" has another length.
replace_first() {
  python3 -I - "$@" <<'PY'
import sys

path = sys.argv[1]
old, new = sys.argv[2].encode("utf-8"), sys.argv[3].encode("utf-8")
with open(path, "rb") as fh:
    data = fh.read()
if old not in data or len(new) != len(old):
    sys.exit(1)
with open(path, "wb") as fh:
    fh.write(data.replace(old, new, 1))
PY
}

# Puts a zip64 end of central directory locator that gives two disks just
# before the end of central directory record of the zip archive at $1.
give_two_disks() {
  python3 -I - "$1" <<'PY'
import struct
import sys

path = sys.argv[1]
with open(path, "rb") as fh:
    data = fh.read()
# The archive has no comment, so its last 22 bytes are the end of central
# directory record. The locator is its signature, the disk that holds the
# zip64 end of central directory record, that record's offset and the
# number of disks.
locator = struct.pack("<4sLQL", b"PK\x06\x07", 0, 0, 2)
with open(path, "wb") as fh:
    fh.write(data[:-22] + locator + data[-22:])
PY
}

# The cell reference is changed in the stored sheet data, so only the CRC-32
# check fails: the cell still holds the text that gives the range.
make_zip "$work/badcrc.xlsx" "$book_xml" "$rels_xml" "$strings_xml" "$sheet_xml"
replace_first "$work/badcrc.xlsx" 'r="A1"' 'r="B1"'
start_case "case 32: an entry whose data does not match its CRC-32" \
  "$checker" "$work/badcrc.xlsx" "$work/new.md"
expect_not_a_workbook badcrc.xlsx
end_case

# The first entry is xl/workbook.xml, so the first copy of its name is the
# one in its local file header.
make_zip "$work/badname.xlsx" "$book_xml" "$rels_xml" "$strings_xml" "$sheet_xml"
replace_first "$work/badname.xlsx" xl/workbook.xml xl/workbook.xmm
start_case "case 33: a local file header that gives another file name" \
  "$checker" "$work/badname.xlsx" "$work/new.md"
expect_not_a_workbook badname.xlsx
end_case

make_zip "$work/twodisk.xlsx" "$book_xml" "$rels_xml" "$strings_xml" "$sheet_xml"
give_two_disks "$work/twodisk.xlsx"
start_case "case 34: a zip64 locator that gives two disks" \
  "$checker" "$work/twodisk.xlsx" "$work/new.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says it is not a zip file" \
  "has_fail 'twodisk.xlsx: cannot read (not a zip file)'"
expect "the document after it is checked" \
  '[ "$(pass_count)" -eq 1 ] && has_line "  PASS line 1: 1.00 to 1.50"'
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

# \377 is the byte 0xff, which is not valid UTF-8, so Python holds it as a
# lone surrogate. Under en_US.UTF-8 printing that raises UnicodeEncodeError;
# the C, C.UTF-8 and UTF-8 locales write the byte as it is. The checker is
# expected to print \xff in either case. No file is made with this name.
LC_ALL=en_US.UTF-8 start_case "case 35: a file name argument that is not UTF-8" \
  "$checker" "$work/bad$(printf '\377').md" "$work/new.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "no traceback on stderr" '[ -z "$err" ]'
expect "the name is printed with the byte as \\xff" \
  "has_line '== $work/bad\\xff.md against $toolkit'"
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line says the file cannot be read and gives the byte as \\xff" \
  "has_fail '$work/bad\\xff.md: cannot read ('"
expect "the next document is checked" \
  "has_line '== $work/new.md against $toolkit' && has_line '  PASS line 1: 1.00 to 1.50'"
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

# \346\227\245 is U+65E5 encoded as UTF-8. Under en_US.ISO8859-1 on macOS,
# python3 decodes the name as UTF-8 and writes stdout as ISO-8859-1, which
# has no byte for U+65E5, so printing the name as it is raises
# UnicodeEncodeError. The checker is expected to print \u65e5 in its place.
# No file is made with this name.
title="case 36: a file name argument that stdout's encoding cannot hold"
probe="$(LC_ALL=en_US.ISO8859-1 python3 -I -c 'import codecs, sys; print(codecs.lookup(sys.getfilesystemencoding()).name, codecs.lookup(sys.stdout.encoding).name)' 2>&1 || true)"
if [ "$probe" = "utf-8 iso8859-1" ]; then
  LC_ALL=en_US.ISO8859-1 start_case "$title" \
    "$checker" "$work/$(printf '\346\227\245').md" "$work/new.md"
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "no traceback on stderr" '[ -z "$err" ]'
  expect "the name is printed with the character as \\u65e5" \
    "has_line '== $work/\\u65e5.md against $toolkit'"
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line says the file cannot be read and gives the character as \\u65e5" \
    "has_fail '$work/\\u65e5.md: cannot read (No such file or directory)'"
  expect "the next document is checked" \
    "has_line '== $work/new.md against $toolkit' && has_line '  PASS line 1: 1.00 to 1.50'"
  expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
  end_case
else
  echo "$title"
  echo "  skip python3 does not decode file names as UTF-8 and write stdout as ISO-8859-1 under en_US.ISO8859-1 here ($probe)"
fi

# Sets the central directory offset that the end of central directory record
# of the zip archive at $1 gives to 1000 bytes past the end of the file.
move_directory_offset() {
  python3 -I - "$1" <<'PY'
import struct
import sys

path = sys.argv[1]
with open(path, "rb") as fh:
    data = bytearray(fh.read())
# The archive has no comment, so its last 22 bytes are the end of central
# directory record, which ends with the central directory's offset and a
# 2-byte comment length.
struct.pack_into("<I", data, len(data) - 6, len(data) + 1000)
with open(path, "wb") as fh:
    fh.write(data)
PY
}

make_zip "$work/badoffset.xlsx" "$book_xml" "$rels_xml" "$strings_xml" "$sheet_xml"
move_directory_offset "$work/badoffset.xlsx"
start_case "case 37: a central directory offset past the end of the file" \
  "$checker" "$work/badoffset.xlsx" "$work/new.md"
expect_not_a_workbook badoffset.xlsx
end_case

# The text cell Welcome!H9 of the toolkit workbook stores the shared string
# index 1820, the index of the text that gives the multiplier range.
h9='<c r="H9" s="205" t="s"><v>1820</v>'

make_copy "$work/plusindex" "$h9" '<c r="H9" s="205" t="s"><v>+1820</v>'
start_case "case 38: a shared string index written with a plus sign" \
  "$checker" "$work/plusindex/$toolkit" "$work/new.md"
expect_not_a_workbook "plusindex/$toolkit"
end_case

make_copy "$work/spaceindex" "$h9" '<c r="H9" s="205" t="s"><v> 1820</v>'
start_case "case 39: a shared string index written after a space" \
  "$checker" "$work/spaceindex/$toolkit" "$work/new.md"
expect_not_a_workbook "spaceindex/$toolkit"
end_case

make_copy "$work/indexspace" "$h9" '<c r="H9" s="205" t="s"><v>1820 </v>'
start_case "case 40: a shared string index written before a space" \
  "$checker" "$work/indexspace/$toolkit" "$work/new.md"
expect_not_a_workbook "indexspace/$toolkit"
end_case

make_copy "$work/underscoreindex" "$h9" '<c r="H9" s="205" t="s"><v>18_20</v>'
start_case "case 41: a shared string index written with an underscore" \
  "$checker" "$work/underscoreindex/$toolkit" "$work/new.md"
expect_not_a_workbook "underscoreindex/$toolkit"
end_case

# \331\241\331\250\331\242\331\240 is U+0661, U+0668, U+0662 and U+0660
# (ARABIC-INDIC DIGIT ONE, EIGHT, TWO and ZERO) encoded as UTF-8.
make_copy "$work/arabicindex" "$h9" \
  "<c r=\"H9\" s=\"205\" t=\"s\"><v>$(printf '\331\241\331\250\331\242\331\240')</v>"
start_case "case 42: a shared string index written with ARABIC-INDIC digits" \
  "$checker" "$work/arabicindex/$toolkit" "$work/new.md"
expect_not_a_workbook "arabicindex/$toolkit"
end_case

make_copy "$work/negativeindex" "$h9" '<c r="H9" s="205" t="s"><v>-1</v>'
start_case "case 43: a negative shared string index" \
  "$checker" "$work/negativeindex/$toolkit" "$work/new.md"
expect_not_a_workbook "negativeindex/$toolkit"
end_case

# The cell Data!M3, the first answer row of RiskMatrix (Data!M2:O30), stores
# the shared string index 16.
m3='<c r="M3" s="4" t="s"><v>16</v></c>'
strings_count="$(python3 -I - "$root/$toolkit" <<'PY'
import sys
import xml.etree.ElementTree as ET
import zipfile

with zipfile.ZipFile(sys.argv[1]) as book:
    table = ET.fromstring(book.read("xl/sharedStrings.xml"))
main = "{http://schemas.openxmlformats.org/spreadsheetml/2006/main}si"
print(sum(1 for _ in table.iter(main)))
PY
)"

# Expects the results of cases 44 to 46, 50 and 51, where $1 is the text the
# FAIL line gives after the name of the cell, and $2 the name of the cell as
# printed, Data!M3 when not given.
expect_matrix_cell_fails() {
  expected="  FAIL $toolkit: RiskMatrix cell ${2:-Data!M3}: $1"
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "nothing on stderr" '[ -z "$err" ]'
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line names the workbook and the RiskMatrix cell" 'has_line "$expected"'
  expect "no document is checked" '[ "$(pass_count)" -eq 0 ]'
  expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
}

make_copy "$work/plusmatrix" "$m3" '<c r="M3" s="4" t="s"><v>+16</v></c>'
start_case "case 44: a RiskMatrix shared string index written with a plus sign" \
  "$work/plusmatrix/scripts/check-profile-multiplier.py" "$work/new.md"
expect_matrix_cell_fails "shared string index '+16' is not one or more of the digits 0 to 9"
end_case

make_copy "$work/pastmatrix" "$m3" '<c r="M3" s="4" t="s"><v>99999999</v></c>'
start_case "case 45: a RiskMatrix shared string index past the end of the table" \
  "$work/pastmatrix/scripts/check-profile-multiplier.py" "$work/new.md"
expect_matrix_cell_fails \
  "shared string index 99999999 is past the end of the shared string table, which has $strings_count strings"
end_case

# \331\241\331\246 is U+0661 and U+0666 (ARABIC-INDIC DIGIT ONE and SIX)
# encoded as UTF-8.
make_copy "$work/arabicmatrix" "$m3" \
  "<c r=\"M3\" s=\"4\" t=\"s\"><v>$(printf '\331\241\331\246')</v></c>"
LC_ALL=en_US.ISO8859-1 start_case \
  "case 46: a RiskMatrix shared string index written with ARABIC-INDIC digits" \
  "$work/arabicmatrix/scripts/check-profile-multiplier.py" "$work/new.md"
expect_matrix_cell_fails \
  "shared string index '\\u0661\\u0666' is not one or more of the digits 0 to 9"
end_case

# The encoding python3 -I writes stdout in under en_US.ISO8859-1 on this
# machine. Cases 47 to 52 need ISO-8859-1.
latin1_probe="$(LC_ALL=en_US.ISO8859-1 python3 -I -c 'import codecs, sys; print(codecs.lookup(sys.stdout.encoding).name)' 2>&1 || true)"

# Runs the case titled $1 with the checker and arguments that follow under
# the en_US.ISO8859-1 locale, as start_case does. When python3 -I does not
# write stdout as ISO-8859-1 under that locale here, prints the title and a
# line that says the case is skipped, and returns 1 instead.
start_latin1_case() {
  if [ "$latin1_probe" != "iso8859-1" ]; then
    echo "$1"
    echo "  skip python3 does not write stdout as ISO-8859-1 under en_US.ISO8859-1 here ($latin1_probe)"
    return 1
  fi
  LC_ALL=en_US.ISO8859-1 start_case "$@"
  return 0
}

# \346\227\245\346\234\254 is U+65E5 U+672C encoded as UTF-8, a sheet name
# that ISO-8859-1 has no bytes for. The checker is expected to print it as
# \u65e5\u672c.
sheet_name="$(printf '\346\227\245\346\234\254')"
sheet_shown='\u65e5\u672c'

make_copy "$work/welcomename" '<sheet name="Welcome"' "<sheet name=\"$sheet_name\""
if start_latin1_case "case 47: a range in a sheet whose name stdout's encoding cannot hold" \
  "$checker" "$work/welcomename/$toolkit"; then
  expect "exit status is 0" '[ "$status" -eq 0 ]'
  expect "nothing on stderr" '[ -z "$err" ]'
  expect "one PASS line" '[ "$(pass_count)" -eq 1 ]'
  expect "PASS line gives the sheet name as $sheet_shown" \
    "has_line '  PASS $sheet_shown!H9 line 12: 1.00 to 1.50'"
  expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
  end_case
fi

make_copy "$work/welcomenamerange" '<sheet name="Welcome"' "<sheet name=\"$sheet_name\"" \
  'multiplier between 1.00 and 1.50, adjusted by' \
  'multiplier (0.8x – 1.5x), adjusted by'
if start_latin1_case "case 48: a wrong range in a sheet whose name stdout's encoding cannot hold" \
  "$checker" "$work/welcomenamerange/$toolkit"; then
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "nothing on stderr" '[ -z "$err" ]'
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line gives the sheet name as $sheet_shown and 0.8 to 1.5" \
    "has_fail 'welcomenamerange/$toolkit $sheet_shown!H9 line 12: the multiplier range is 0.8 to 1.5 here, but $toolkit calculates 1.00 to 1.50'"
  expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
  end_case
fi

# The Data sheet holds RiskMatrix, Data!M2:O30. These pairs rename it in
# xl/workbook.xml and in the RiskMatrix defined name.
data_renamed=(
  '<sheet name="Data"' "<sheet name=\"$sheet_name\""
  '>Data!$M$2:$O$30<' ">$sheet_name!\$M\$2:\$O\$30<"
)

make_copy "$work/dataname" "${data_renamed[@]}"
if start_latin1_case "case 49: a RiskMatrix sheet whose name stdout's encoding cannot hold" \
  "$work/dataname/scripts/check-profile-multiplier.py" "$work/new.md"; then
  expect "exit status is 0" '[ "$status" -eq 0 ]'
  expect "nothing on stderr" '[ -z "$err" ]'
  expect "the == line gives RiskMatrix as $sheet_shown!M2:O30" \
    "has_line '== $toolkit ProfileMultiplier (Profile!D21), RiskMatrix ($sheet_shown!M2:O30)'"
  expect "the document is checked" \
    '[ "$(pass_count)" -eq 1 ] && has_line "  PASS line 1: 1.00 to 1.50"'
  expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
  end_case
fi

make_copy "$work/datanameplus" "${data_renamed[@]}" \
  "$m3" '<c r="M3" s="4" t="s"><v>+16</v></c>'
if start_latin1_case "case 50: a bad RiskMatrix cell in a sheet whose name stdout's encoding cannot hold" \
  "$work/datanameplus/scripts/check-profile-multiplier.py" "$work/new.md"; then
  expect_matrix_cell_fails \
    "shared string index '+16' is not one or more of the digits 0 to 9" "$sheet_shown!M3"
  end_case
fi

# \331\243 is U+0663 (ARABIC-INDIC DIGIT THREE) encoded as UTF-8.
make_copy "$work/arabicref" "$m3" \
  "<c r=\"M$(printf '\331\243')\" s=\"4\" t=\"s\"><v>+16</v></c>"
if start_latin1_case "case 51: a bad RiskMatrix cell whose reference stdout's encoding cannot hold" \
  "$work/arabicref/scripts/check-profile-multiplier.py" "$work/new.md"; then
  expect_matrix_cell_fails \
    "shared string index '+16' is not one or more of the digits 0 to 9" 'Data!M\u0663'
  end_case
fi

# \331\247 is U+0667 (ARABIC-INDIC DIGIT SEVEN) encoded as UTF-8. The term
# of the ProfileMultiplier formula for the answer in D17 is changed to read
# D1 followed by it.
seven="$(printf '\331\247')"
make_copy "$work/arabicanswer" \
  'VLOOKUP(D17, RiskMatrix, 3, FALSE) * VLOOKUP(D17, RiskMatrix, 2, FALSE)' \
  "VLOOKUP(D1$seven, RiskMatrix, 3, FALSE) * VLOOKUP(D1$seven, RiskMatrix, 2, FALSE)"
if start_latin1_case "case 52: an answer whose reference stdout's encoding cannot hold" \
  "$work/arabicanswer/scripts/check-profile-multiplier.py" "$work/new.md"; then
  expect "exit status is 0" '[ "$status" -eq 0 ]'
  expect "nothing on stderr" '[ -z "$err" ]'
  expect "the answers line gives D1\\u0667" \
    "has_line '  answers: D9, D11, D13, D15, D1\\u0667'"
  expect "the document is checked" \
    '[ "$(pass_count)" -eq 1 ] && has_line "  PASS line 1: 1.00 to 1.50"'
  expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
  end_case
fi

# Expects the results of cases 53 to 56, where $1 is the reason the FAIL line
# gives.
expect_toolkit_unreadable() {
  expected="  FAIL $toolkit: cannot read ($1)"
  expect "exit status is 1" '[ "$status" -eq 1 ]'
  expect "nothing on stderr" '[ -z "$err" ]'
  expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
  expect "FAIL line names the toolkit workbook and gives the reason" 'has_line "$expected"'
  expect "no == line, so no document is checked" '! printf "%s\n" "$out" | grep -q "^=="'
  expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
}

copy_checker "$work/textbook"
printf '%s\n' 'not a workbook' > "$work/textbook/$toolkit"
start_case "case 53: a toolkit workbook that is a text file" \
  "$work/textbook/scripts/check-profile-multiplier.py" "$work/new.md"
expect_toolkit_unreadable "not a zip file"
end_case

copy_checker "$work/nobook"
start_case "case 54: no toolkit workbook" \
  "$work/nobook/scripts/check-profile-multiplier.py" "$work/new.md"
expect_toolkit_unreadable "No such file or directory"
end_case

copy_checker "$work/zipbook"
make_zip "$work/zipbook/$toolkit" 'note.txt=note'
start_case "case 55: a toolkit workbook that is a zip archive of a text file" \
  "$work/zipbook/scripts/check-profile-multiplier.py" "$work/new.md"
expect_toolkit_unreadable "not a workbook"
end_case

# The sheet name is changed in the stored data of xl/workbook.xml, the first
# entry the checker reads, so only the CRC-32 check fails.
copy_checker "$work/crcbook"
make_zip "$work/crcbook/$toolkit" "$book_xml" "$rels_xml" "$strings_xml" "$sheet_xml"
replace_first "$work/crcbook/$toolkit" 'name="Notes"' 'name="Notez"'
start_case "case 56: a toolkit workbook whose xl/workbook.xml does not match its CRC-32" \
  "$work/crcbook/scripts/check-profile-multiplier.py" "$work/new.md"
expect_toolkit_unreadable "not a workbook"
end_case

# The end of the ProfileMultiplier formula, where ROUND gives its places.
# The formula's lines end in CR LF.
round_end=$'VLOOKUP(D17, RiskMatrix, 2, FALSE),\r\n    2),"-")'
round_to() {
  printf 'VLOOKUP(D17, RiskMatrix, 2, FALSE),\r\n    %s),"-")' "$1"
}
zeros28="0000000000000000000000000000"

make_copy "$work/round28" "$round_end" "$(round_to 28)"
start_case "case 57: a ProfileMultiplier formula that rounds to 28 places" \
  "$work/round28/scripts/check-profile-multiplier.py" "$work/new.md"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "nothing on stderr" '[ -z "$err" ]'
expect "workbook range is listed with 28 places" \
  'has_line "  lowest 1.$zeros28, highest 1.5${zeros28#0}"'
expect "PASS line for between 1.00 and 1.50" 'has_line "  PASS line 1: 1.00 to 1.50"'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
end_case

make_copy "$work/roundmillion" "$round_end" "$(round_to 1000000)"
start_case "case 58: a ProfileMultiplier formula that rounds to 1000000 places" \
  "$work/roundmillion/scripts/check-profile-multiplier.py" "$work/new.md"
expect "exit status is 0" '[ "$status" -eq 0 ]'
expect "nothing on stderr" '[ -z "$err" ]'
expect "workbook range is listed with 28 places" \
  'has_line "  lowest 1.$zeros28, highest 1.5${zeros28#0}"'
expect "PASS line for between 1.00 and 1.50" 'has_line "  PASS line 1: 1.00 to 1.50"'
expect "last line is RESULT: PASS" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: PASS" ]'
end_case

make_copy "$work/round34" "$round_end" "$(round_to 34)" \
  '> 1.0 <' "> 1.0${zeros28}000005 <"
start_case "case 59: a formula that rounds to 34 places, risk values 1 + 5 * 10^-35" \
  "$work/round34/scripts/check-profile-multiplier.py" "$work/new.md"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "nothing on stderr" '[ -z "$err" ]'
expect "lowest multiplier is rounded half up to 34 places" \
  'has_line "  lowest 1.${zeros28}000001, highest 1.5${zeros28#0}"'
expect "one FAIL line" '[ "$(fail_count)" -eq 1 ]'
expect "FAIL line for between 1.00 and 1.50" \
  "has_fail 'new.md line 1: the multiplier range is 1.00 to 1.50 here, but $toolkit calculates 1.${zeros28}000001 to 1.5${zeros28#0}'"
end_case

make_copy "$work/exponent" '> 0.10 <' '> 1E-100000000000000000 <'
start_case "case 60: a RiskMatrix factor written as 1E-100000000000000000" \
  "$work/exponent/scripts/check-profile-multiplier.py" "$work/new.md"
expected="  FAIL $toolkit: RiskMatrix row 27 (Fortune 500/Global Enterprise): factor ' 1E-100000000000000000 ' and risk value ' 1.5 ' are not both numbers"
expect "exit status is 1" '[ "$status" -eq 1 ]'
expect "nothing on stderr" '[ -z "$err" ]'
expect "a FAIL line for each of rows 27 to 30, which carry that factor" \
  '[ "$(fail_count)" -eq 4 ] && [ "$(printf "%s\n" "$out" | grep -c " are not both numbers$")" -eq 4 ]'
expect "FAIL line names row 27 and gives its factor and risk value as written" \
  'has_line "$expected"'
expect "no == line, so no document is checked" '! printf "%s\n" "$out" | grep -q "^=="'
expect "last line is RESULT: FAIL" '[ "$(printf "%s\n" "$out" | tail -n 1)" = "RESULT: FAIL" ]'
end_case

if [ "$failed" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
exit "$failed"
