# Release smoke test: qramm

Manual pre-release walkthrough. Run this before every release of the
framework documents or the toolkit workbooks. Use real keyboard and mouse
input, not synthetic events. Record the actual output, not a summary.

The repository has no build step and no package.json. The runnable code is
the checkers and their test scripts under `scripts/`. They need bash and
python3 and use the Python standard library only.

## 1. Checkers and test scripts

Run from the repository root.

- [ ] Each checker ends with `RESULT: PASS` and exits 0:

  ```
  bash scripts/check-framework-docs.sh
  bash scripts/check-spec-passwords.sh
  bash scripts/check-published-toolkit.sh
  for checker in scripts/check-*.py; do python3 -I "$checker"; done
  ```

  `check-framework-docs.sh` fetches every external URL. Without network
  access, add `--no-network` and follow the README links by hand in step 3.
  A LinkedIn link that answers 999 is listed under its document as not
  verified and does not fail the run; open those links in step 3.
  `check-published-toolkit.sh` fetches the two workbooks from qramm.org;
  without network access, skip it and compare the downloads by hand in
  step 3.
- [ ] Each test script ends with `RESULT: PASS` and exits 0:

  ```
  for test in scripts/test-check-*.sh; do bash "$test"; done
  bash scripts/test-questions-workbook.sh
  ```

  `test-questions-workbook.sh` checks that the blank
  `toolkit-specs/QRAMM_120_questions.xlsx` shows `-` on its Scoring
  Dashboard and that no cell text carries Markdown source.

- [ ] `git status` shows no new files afterwards. The test scripts write
  their fixtures under `.tmp-tests/` and remove them when they exit.
- [ ] `--help` on each checker prints a usage line and the checker's header
  text on stderr.

## 2. Workbooks

Open both files in Excel or LibreOffice Calc.

- [ ] `toolkit/QRAMM_Assessment_Toolkit.xlsx` (blank): the Scorecard shows
  `-` for every dimension score and the overall score,
  `Incomplete Assessment` for every maturity level, and `-` for each of the
  three Top Strengths and Top Area for Improvement entries. The Compliance
  sheet shows `-` for the overall score and its category list. No cell
  shows an error such as `#DIV/0!` or `#N/A`
  (`python3 -I scripts/check-workbook-errors.py` lists the visible cells
  that store one).
- [ ] Answer one question on a Dimension sheet, then clear it again: the
  Scorecard returns to `-` and `Incomplete Assessment`.
- [ ] `toolkit/Sample_Assessment.xlsx`: the Scorecard shows the scores that
  the worked example in `framework/scoring-methodology.md` gives
  (`python3 -I scripts/check-scoring-example.py` compares the saved values).
- [ ] Every sheet tab opens, and no sheet asks for a password.

## 3. Website and links

- [ ] Take the quick assessment at https://qramm.org/quick-assessment.html
  from start to finish with the keyboard only, and check that a score is
  shown at the end.
- [ ] Follow every link in `README.md` on GitHub. Each one opens the page or
  section it names.
- [ ] Open each link that `check-framework-docs.sh` lists as not verified in
  a browser. Each one opens the page it names.
- [ ] Download both workbooks from the "Download the toolkit" and "Sample
  assessment" links in `README.md`.
- [ ] The workbooks downloaded from qramm.org are the files in `toolkit/`:
  `bash scripts/check-published-toolkit.sh` ends with `RESULT: PASS`.

## 4. Audience fit

CSNP serves non-technical and vulnerable users.

- [ ] Plain language in the README, the toolkit overview and the workbook
  Welcome sheet: no unexplained jargon.
- [ ] No placeholder or invented numbers in documents or workbooks. Every
  score or statistic traces to the methodology or the sample assessment.

## 5. Security

- [ ] No secrets or credential files in the committed files.
- [ ] The toolkit specs record no password
  (`bash scripts/check-spec-passwords.sh` passes).

## Result

- Date:
- Tester:
- Verdict: PASS / FAIL
- Notes:
