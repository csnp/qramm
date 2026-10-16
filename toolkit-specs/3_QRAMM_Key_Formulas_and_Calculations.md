# QRAMM Excel Toolkit - Key Formulas and Calculations

The Profile Tab Formulas, the Question Tab Formulas, and the overall score, adjusted overall score and Maturity Level Text sections under Scorecard Tab Formulas match the shipped workbook `toolkit/QRAMM_Assessment_Toolkit.xlsx`: the same cells and the same formulas, with line breaks and spacing aside. The other formulas in this document come from the original build plan. They have not been checked against the workbook, and some of them use names or cells the workbook does not have (for example `Dim1_Score`).

## Profile Tab Formulas

### Profile Multiplier Calculation (Cell D21, named ProfileMultiplier)
```excel
=IFERROR(ROUND(
    VLOOKUP(D9, RiskMatrix, 3, FALSE) * VLOOKUP(D9, RiskMatrix, 2, FALSE) +
    VLOOKUP(D11, RiskMatrix, 3, FALSE) * VLOOKUP(D11, RiskMatrix, 2, FALSE) +
    VLOOKUP(D13, RiskMatrix, 3, FALSE) * VLOOKUP(D13, RiskMatrix, 2, FALSE) +
    VLOOKUP(D15, RiskMatrix, 3, FALSE) * VLOOKUP(D15, RiskMatrix, 2, FALSE) +
    VLOOKUP(D17, RiskMatrix, 3, FALSE) * VLOOKUP(D17, RiskMatrix, 2, FALSE),
    2),"-")
```

The inputs are industry (D9), organization size (D11), geographic scope (D13), data sensitivity (D15) and regulatory requirements (D17). `RiskMatrix` column 2 is the factor (0.30, 0.10, 0.15, 0.25 and 0.20 for those five inputs) and column 3 is the risk value (1.0, 1.3 or 1.5). The result runs from 1.00 to 1.50, and it is "-" until all five inputs are set.

### Regulatory requirements (cell D17)
D17 is a dropdown that uses the `RegulatoryReqs` list. It has no formula.

## Question Tab Formulas (Dimensions 1-4)

### Individual Question Score (Column I, starting at I9)
The answer is in column G, and each answer option's text starts with its score.
```excel
=IFERROR(IF(G9="","",INT(LEFT(G9,1))),"")
```

### Practice Score Calculation (L7, L64, L121)
Foundation questions are worth 60 percent and Advanced questions 40 percent. Each average uses only answered questions. L7 for the first practice:
```excel
=IFERROR(
    IF(COUNTIF(I9:I32, ">0") = 0, "", AVERAGE(IF(I9:I29>0, I9:I29))) * 0.6
  + IF(COUNTIF(I37:I57, ">0") = 0, "", AVERAGE(IF(I37:I57>0, I37:I57))) * 0.4,
"-")
```
L64 and L121 follow the same pattern for the second and third practices. When a stream has no answer, the practice score is "-".

### Weighted Practice Score (N7, N64, N121)
```excel
=IF(L7="-", "-", L7 * VLOOKUP(TRIM(B6), PracticeData, 3, FALSE))
```

### Dimension Score (L5, named CVI_Score, SGRM_Score, DPE_Score or ITR_Score)
```excel
=IFERROR(N7+N64+N121,"-")
```

### Adjusted Dimension Score (N5, named CVI_Score_Adj, SGRM_Score_Adj, DPE_Score_Adj or ITR_Score_Adj)
```excel
=IFERROR(L5*ProfileMultiplier,"-")
```
The adjusted score can be higher than 4.

### Answered questions (N2)
```excel
=COUNTIFS(I7:I171,">0",I7:I171,"<>Rating")
```
The percent complete for the whole assessment is Welcome!J5 (named PctComplete), the sum of the four N2 cells divided by 120 and rounded to 2 decimal places.

## Scorecard Tab Formulas

### Overall score (E14)
E9:E12 hold the four dimension scores. The overall score is not multiplied by ProfileMultiplier.
```excel
=IF(COUNTIF(E9:E12,"=-")>0,"-",AVERAGE(E9:E12))
```

### Adjusted overall score (F14)
F9:F12 hold the four adjusted dimension scores.
```excel
=IF(COUNTIF(F9:F12,"=-")>0,"-",AVERAGE(F9:F12))
```

### Maturity Level Text (H14, and H9:H12 for the dimensions)
```excel
=IFS(E14="-", "Incomplete Assessment", E14>=3.5,"Advanced",E14>=2.5,"Established",E14>=1.5,"Developing",1=1,"Basic")
```
There is no "Optimizing" label: a score of 4.0 is "Advanced".

### Top Strength Practice (D8)
```excel
=IF(MAX(PracticeScores) = 0, "Complete assessment first",
    INDEX(PracticeData[Practice_Name],
        MATCH(MAX(PracticeScores), PracticeScores, 0)))
```

### Top Weakness Practice (D9)
```excel
=IF(MIN(IF(PracticeScores>0, PracticeScores, 4)) = 4, "Complete assessment first",
    INDEX(PracticeData[Practice_Name],
        MATCH(MIN(IF(PracticeScores>0, PracticeScores, 4)), PracticeScores, 0)))
```

### Industry Benchmark Comparison (F8)
```excel
=IFERROR(
    VLOOKUP(Profile!B5 & "_" & Profile!B6, Benchmarks, 2, FALSE),
    VLOOKUP("Other_All", Benchmarks, 2, FALSE))
```

### Benchmark Delta (F9)
```excel
=IF(ISNUMBER(B3), B3 - F8, "")
```

### Progress to Next Level (B12)
```excel
=IF(B3 >= 4, "Maximum level achieved",
    TEXT(LOOKUP(B3, {0,1.6,2.6,3.6}, {1.6,2.6,3.6,4.0}) - B3, "0.0") & " points needed")
```

### Dynamic Recommendations (A20:A25)
```excel
=FILTER(Recommendations[Recommendation_Text],
    (Recommendations[Score_Range] = LOOKUP(B3, {0,1.6,2.6,3.6}, 
        {"0.0-1.5","1.6-2.5","2.6-3.5","3.6-4.0"})) *
    ((Recommendations[Recommendation_Type] = "Overall") +
     (Recommendations[Recommendation_Type] = "CVI") * (Dim1_Score < 2.6) +
     (Recommendations[Recommendation_Type] = "SGRM") * (Dim2_Score < 2.6) +
     (Recommendations[Recommendation_Type] = "DPE") * (Dim3_Score < 2.6) +
     (Recommendations[Recommendation_Type] = "ITR") * (Dim4_Score < 2.6)))
```

## Compliance Tab Formulas

### Framework Readiness Score (Column B, starting at B5)
```excel
=IFERROR(
    SUMPRODUCT(
        (ComplianceMap[Framework] = A5) *
        (ComplianceMap[Weight]) *
        (VLOOKUP(ComplianceMap[Question_ID], QuestionScores, 2, FALSE))
    ) / 
    SUMIF(ComplianceMap[Framework], A5, ComplianceMap[Weight]),
    0)
```

### Readiness Percentage (Column C)
```excel
=B5 / 4
```

### Gap Analysis (Column D)
```excel
=4 - B5
```

### Mapped Controls Count (Column E)
```excel
=COUNTIF(ComplianceMap[Framework], A5)
```

### Implementation Priority (Column F)
```excel
=IF(B5 < 2, "Critical",
    IF(B5 < 3, "High",
        IF(B5 < 3.5, "Medium", "Low")))
```

## Chart Formulas

### Radar Chart Data
```excel
Dimension Names: ={"CVI";"SGRM";"DPE";"ITR"}
Dimension Scores: ={Dim1_Score;Dim2_Score;Dim3_Score;Dim4_Score}
Benchmark Scores: ={F8_CVI;F8_SGRM;F8_DPE;F8_ITR}
```

### Maturity Distribution (Donut Chart)
```excel
Basic Count: =COUNTIF(AllPracticeScores, "<1.6")
Developing Count: =COUNTIFS(AllPracticeScores, ">=1.6", AllPracticeScores, "<2.6")
Established Count: =COUNTIFS(AllPracticeScores, ">=2.6", AllPracticeScores, "<3.6")
Advanced Count: =COUNTIFS(AllPracticeScores, ">=3.6", AllPracticeScores, "<4")
Optimizing Count: =COUNTIF(AllPracticeScores, "=4")
```

### Progress Bar
```excel
=COUNTIF(AllQuestions, "<>""") / 120
```

## Conditional Formatting Formulas

### Score-based Color Coding
```excel
=LOOKUP($D5, {0,1,1.6,2.6,3.6,4}, ScoreColors)
```

### Heat Map for Practice Scores
```excel
Cell Rule: =$E15 < 2.6 → Red
Cell Rule: =AND($E15 >= 2.6, $E15 < 3.6) → Yellow
Cell Rule: =$E15 >= 3.6 → Green
```

### Progress Indicator
```excel
=IF(Progress < 0.25, "red",
    IF(Progress < 0.5, "orange",
        IF(Progress < 0.75, "yellow", "green")))
```

## Validation Formulas

### Answer Validation (Column C in dimension tabs)
```excel
Data Validation List: =AnswerOptions
Error Alert: "Please select from: Not Implemented, Partially Implemented, Mostly Implemented, or Fully Implemented"
```

### Profile Field Validation
```excel
Industry: =Industries
Organization Size: =OrgSizes
Geographic Scope: =GeoScope
Data Sensitivity: =DataLevels
```

## Excel 2016 Fallback Formulas

### For FILTER function (Recommendations)
```excel
=IFERROR(
    INDEX(Recommendations[Recommendation_Text],
        SMALL(IF((Recommendations[Score_Range] = ScoreRange) *
                 (Recommendations[Type] = RecommendationType), 
                 ROW(Recommendations[Recommendation_Text]) - ROW(Recommendations[#Headers]),
                 ""), 
              ROW(A1))),
    "")
```

### For XLOOKUP (use VLOOKUP/INDEX-MATCH)
```excel
=IFERROR(
    INDEX(ReturnRange,
        MATCH(LookupValue, LookupRange, 0)),
    DefaultValue)
```

### For LET function (use helper columns)
Instead of:
```excel
=LET(x, ComplexCalculation, IF(x > 0, x * 2, 0))
```
Use helper column:
```excel
Helper Column: =ComplexCalculation
Main Formula: =IF(HelperColumn > 0, HelperColumn * 2, 0)
```

## Performance Optimization Tips

1. Use structured table references instead of absolute references
2. Minimize volatile functions (TODAY, NOW, RAND)
3. Use IFERROR sparingly - check for errors at source
4. Avoid whole-column references (A:A) - use defined ranges
5. Calculate heavy formulas once and reference results
6. Use manual calculation mode during development
7. Keep array formulas to minimum necessary