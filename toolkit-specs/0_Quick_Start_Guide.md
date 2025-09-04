# QRAMM Excel Toolkit - Quick Start Guide

## What You're Building
An Excel assessment tool that evaluates organizational quantum computing readiness across 120 questions, providing automated scoring, compliance mapping, and actionable insights.

## Essential Files
1. **QRAMM_120_questions.xlsx** - Your source for all question content
2. **1_QRAMM_Structure_and_Logic.md** - System architecture and scoring logic
3. **2_QRAMM_Data_Tables_and_Values.md** - All reference data to copy
4. **3_QRAMM_Key_Formulas_and_Calculations.md** - Every formula you need
5. **4_QRAMM_Compliance_Mapping_Details.md** - Detailed framework mappings for all 120 questions

## Build Order

### Phase 1: Foundation (2 hours)
1. Create new workbook with 9 tabs (see Structure doc)
2. Build Data tab with all tables from doc #2
3. Define ALL named ranges before proceeding
4. Hide the Data tab

### Phase 2: Profile System (1 hour)
1. Create Profile tab with organization inputs
2. Implement ProfileMultiplier calculation (critical!)
3. Test with different organization profiles
4. This multiplier affects ALL scoring - must work perfectly

### Phase 3: Assessment Tabs (3 hours)
1. Build template for one dimension tab
2. Copy questions from QRAMM_120_questions.xlsx
3. Implement scoring formulas from doc #3
4. Replicate for all 4 dimensions
5. Test scoring aggregation

### Phase 4: Results Dashboard (2 hours)
1. Create Scorecard tab layout
2. Implement overall scoring
3. Add radar and donut charts
4. Build dynamic recommendations
5. Test with various score combinations

### Phase 5: Compliance Mapping (1 hour)
1. Create Compliance tab structure
2. Add compliance mapping data from doc #5
3. Implement framework scoring formulas
4. Add gap analysis calculations
5. Test with sample data

### Phase 6: Polish (1 hour)
1. Apply consistent formatting
2. Add data validation
3. Protect formulas
4. Test all edge cases
5. Optimize file size

## Critical Success Factors

### The ProfileMultiplier
- This is THE most important calculation
- It adjusts all scores based on organization risk
- Range: 0.8 to 1.5
- Must be calculated before any scoring

### Scoring Hierarchy
```
Question (1-4) → Practice (avg) → Dimension (avg) → Overall (avg × multiplier)
```

### Empty Answer Handling
- Empty answers must not break averages
- Use IF statements to exclude zeros
- Test with partially completed assessments

### Named Ranges
- Define all ranges BEFORE building formulas
- Use structured table references where possible
- This prevents formula errors later

## Common Pitfalls to Avoid

1. **Forgetting ProfileMultiplier** - All scores must be adjusted
2. **Including empty answers in averages** - Will skew results
3. **Hard-coding values** - Use Data tab references
4. **Circular references** - Check calculation order
5. **Missing data validation** - Users need guided input

## Testing Checklist

Before delivery, verify:
- [ ] ProfileMultiplier calculates correctly (0.8-1.5 range)
- [ ] Empty assessment shows "Not Started" not errors
- [ ] Partial completion calculates correct averages
- [ ] All charts update automatically
- [ ] Recommendations change based on scores
- [ ] Compliance mapping reflects actual answers
- [ ] File size under 10MB
- [ ] Opens quickly in Excel 2016+

## Color Scheme
- Primary: #1E3A5F (dark blue)
- Secondary: #4A90E2 (light blue)
- Success: #28A745 (green)
- Warning: #FFC107 (yellow)
- Danger: #DC3545 (red)

## Delivery Format
1. QRAMM_Toolkit_v1.0.xlsx (protected version)
2. QRAMM_Toolkit_Unlocked.xlsx (for review)
3. Brief technical notes on any deviations

## Remember
You're building for executives and security teams. The tool must be:
- Intuitive without training
- Visually professional
- Technically accurate
- Fast and responsive

Focus on functionality over fancy features. The math must be perfect.