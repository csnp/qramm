# QRAMM Excel Toolkit - Key Formulas and Calculations

## Profile Tab Formulas

### Profile Multiplier Calculation (Cell K20)
```excel
=ROUND(
    VLOOKUP(B5, RiskMatrix, 3, FALSE) * VLOOKUP(B5, RiskMatrix, 2, FALSE) +
    VLOOKUP(B9, RiskMatrix, 3, FALSE) * VLOOKUP(B9, RiskMatrix, 2, FALSE) +
    VLOOKUP(B11, RiskMatrix, 3, FALSE) * VLOOKUP(B11, RiskMatrix, 2, FALSE) +
    VLOOKUP(B7, RiskMatrix, 3, FALSE) * VLOOKUP(B7, RiskMatrix, 2, FALSE) +
    VLOOKUP(B6, RiskMatrix, 3, FALSE) * VLOOKUP(B6, RiskMatrix, 2, FALSE),
    2)
```

### Regulatory Requirement Score (Cell B11)
```excel
=IF(COUNTIF(D5:D14, TRUE) >= 3, "Multiple Major Frameworks",
    IF(COUNTIF(D5:D14, TRUE) >= 1, "Single Major Framework",
        "Minimal Requirements"))
```

## Question Tab Formulas (Dimensions 1-4)

### Individual Question Score (Column D, starting at D5)
```excel
=IF(C5="", "", MATCH(C5, AnswerOptions, 0))
```

### Practice Score Calculation (E15, E25, E35)
```excel
=IF(COUNTIF(D5:D14, ">0") = 0, "",
    AVERAGE(IF(D5:D14>0, D5:D14)))
```

### Weighted Practice Score (F15, F25, F35)
```excel
=IF(E15="", "", E15 * VLOOKUP("CVI_1", PracticeData, 3, FALSE))
```

### Dimension Score (E46)
```excel
=IF(COUNTIF(E15:E35, ">0") = 0, "",
    AVERAGE(IF(E15:E35>0, E15:E35)))
```

### Adjusted Dimension Score (F46)
```excel
=IF(E46="", "", E46 * ProfileMultiplier)
```

### Progress Percentage (H2)
```excel
=COUNTIF(C5:C34, "<>""") / 30
```

### Questions Remaining (H3)
```excel
=30 - COUNTIF(C5:C34, "<>""")
```

## Scorecard Tab Formulas

### Overall Maturity Score (B3)
```excel
=IF(COUNTIF(Dim1_Score:Dim4_Score, ">0") = 0, "Not Started",
    AVERAGE(IF({Dim1_Score;Dim2_Score;Dim3_Score;Dim4_Score}>0,
        {Dim1_Score;Dim2_Score;Dim3_Score;Dim4_Score})))
```

### Maturity Level Text (B4)
```excel
=IF(ISNUMBER(B3),
    LOOKUP(B3, {0,1.6,2.6,3.6,4.0}, 
        {"Basic","Developing","Established","Advanced","Optimizing"}),
    "")
```

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