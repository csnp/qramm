# QRAMM Excel Toolkit - Structure and Logic

## Workbook Structure

### Tabs (in order)
1. **Welcome** - Landing page with navigation buttons
2. **Profile** - Organization details and risk multiplier calculation
3. **Dimension 1 - CVI** - Critical Vulnerability Identification (30 questions)
4. **Dimension 2 - SGRM** - Strategic Governance & Risk Management (30 questions)
5. **Dimension 3 - DPE** - Data Protection & Encryption (30 questions)
6. **Dimension 4 - ITR** - Infrastructure & Technical Readiness (30 questions)
7. **Scorecard** - Results dashboard with charts and insights
8. **Compliance** - Framework mapping (NIST, CMMC, ISO, etc.)
9. **Data** (HIDDEN) - All reference tables

### Question Source
Use **QRAMM_120_questions.xlsx** for all question text, options, and explanations.

## Core Scoring Logic

Sections 1 to 4 below, and the Key Named Ranges section, match the shipped workbook `toolkit/QRAMM_Assessment_Toolkit.xlsx`.

### 1. Individual Question Scoring
- Each question has 4 answer options, and each option's text starts with its score
- Scores: 1 (Basic), 2 (Developing), 3 (Established), 4 (Advanced)
- Question score = `INT(LEFT(answer, 1))`
- Empty answers are left out of the averages (an empty answer is not a 0)

### 2. Aggregation Hierarchy
```
Question Score (1-4)
  ↓
Practice Score = AVG(answered Foundation questions) × 0.6
               + AVG(answered Advanced questions) × 0.4
  ↓
Dimension Score = SUM(Practice Score × Practice Weight) over 3 practices
  ↓
Overall Score = AVG(4 dimension scores)

Adjusted Dimension Score = Dimension Score × ProfileMultiplier
Adjusted Overall Score = AVG(4 adjusted dimension scores)
```

- Each practice has 5 Foundation questions and 5 Advanced questions. A practice shows "-" until at least one question in each stream is answered.
- Practice weights come from `PracticeData` (Data!U2:W14). Each dimension's three weights add up to 1.00:
  - CVI: 0.35, 0.35, 0.30
  - SGRM: 0.40, 0.35, 0.25
  - DPE: 0.40, 0.35, 0.25
  - ITR: 0.35, 0.35, 0.30
- A dimension shows "-" until all three of its practices have a score, and the overall score shows "-" until all four dimensions have a score.
- The overall score and the maturity levels use the unadjusted scores. ProfileMultiplier is used only for the adjusted scores, which can be higher than 4.

### 3. Profile Multiplier Calculation
The ProfileMultiplier sets the adjusted dimension scores based on organizational risk factors. Each profile answer has a factor and a risk value in `RiskMatrix` (Data!M2:O30):

```excel
ProfileMultiplier = ROUND(
    IndustryRisk × 0.30 +
    DataSensitivity × 0.25 +
    RegulatoryReqs × 0.20 +
    GeographicScope × 0.15 +
    OrgSize × 0.10,
    2)
```

The factors add up to 1.00 and every risk value is 1.0, 1.3 or 1.5, so the multiplier runs from 1.00 to 1.50. It shows "-" until all five profile answers are set.

**Risk Factor Values:**
- Industry (Profile!D9): Financial Services, Healthcare, Defense/Military = 1.5; Technology, Energy/Utilities = 1.3; Manufacturing, Retail, Government, Education, Telecommunications, Transportation, Other = 1.0
- Data Sensitivity (Profile!D15): Highly Classified/Secret = 1.5; Confidential/Sensitive = 1.3; Internal Use Only, Public/Non-sensitive = 1.0
- Regulatory (Profile!D17): Multiple Major Frameworks = 1.5; Single Major Framework = 1.3; Industry Standards Only, Minimal Requirements = 1.0
- Geographic (Profile!D13): Global (10+ countries) = 1.5; Multi-region (3-9 countries) = 1.3; Regional (2 countries), Single Country = 1.0
- Org Size (Profile!D11): Fortune 500/Global Enterprise = 1.5; Large Enterprise (1000+ employees) = 1.3; Mid-Market (100-999 employees), Small Business (<100 employees) = 1.0

### 4. Maturity Level Mapping
The Scorecard labels each dimension score and the overall score (Scorecard!H9:H12 and H14). These labels have no "Optimizing": a dimension or overall score of 4.0 is "Advanced". The Scorecard's Maturity Distribution chart (Scorecard!L21:M25) sorts the 12 practice scores with the same cut-offs (1.5, 2.5 and 3.5) and counts a practice score of 4 as "Advanced"; its fifth category, "Incomplete Assessment", counts the practices that do not have a score yet.
```excel
=IFS(Score="-", "Incomplete Assessment",
     Score>=3.5, "Advanced",
     Score>=2.5, "Established",
     Score>=1.5, "Developing",
     1=1, "Basic")
```

### 5. Gap Analysis
- Gap = 4.0 - CurrentScore
- Priority = Gap × Practice Weight × ProfileMultiplier

## Dimension Structure

Each dimension contains:
- 3 Practices (10 questions each)
- Practice scoring summary
- Dimension-level insights

### Dimension 1 - CVI (Critical Vulnerability Identification)
1. Asset Discovery & Classification (Q1-10)
2. Vulnerability Scanning & Analysis (Q11-20)
3. Risk Prioritization & Tracking (Q21-30)

### Dimension 2 - SGRM (Strategic Governance & Risk Management)
1. Governance Structure & Leadership (Q31-40)
2. Risk Management Framework (Q41-50)
3. Compliance & Audit (Q51-60)

### Dimension 3 - DPE (Data Protection & Encryption)
1. Encryption Implementation (Q61-70)
2. Key Management Systems (Q71-80)
3. Data Classification & Handling (Q81-90)

### Dimension 4 - ITR (Infrastructure & Technical Readiness)
1. Network Security Architecture (Q91-100)
2. System Hardening & Updates (Q101-110)
3. Incident Response & Recovery (Q111-120)

## Compliance Mapping Logic

Each question maps to multiple frameworks with relevance weights:

### Framework Readiness Calculation
```excel
FrameworkScore = SUMPRODUCT(QuestionScores, RelevanceWeights) / SUM(RelevanceWeights)
```

### Supported Frameworks
1. NIST Cybersecurity Framework
2. ISO 27001/27002
3. CMMC 2.0
4. SOC 2
5. PCI DSS
6. HIPAA Security Rule
7. GDPR Article 32
8. CIS Critical Controls
9. COBIT 2019
10. ENISA Quantum Readiness

## Key Named Ranges

### Global Score References
```
ProfileMultiplier = Profile!$D$21
CVI_1_Score = 'Dimension 1 - CVI'!$L$7
CVI_2_Score = 'Dimension 1 - CVI'!$L$64
CVI_3_Score = 'Dimension 1 - CVI'!$L$121
CVI_Score = 'Dimension 1 - CVI'!$L$5
CVI_Score_Adj = 'Dimension 1 - CVI'!$N$5
SGRM_Score = 'Dimension 2 - SGRM'!$L$5
SGRM_Score_Adj = 'Dimension 2 - SGRM'!$N$5
DPE_Score = 'Dimension 3 - DPE'!$L$5
DPE_Score_Adj = 'Dimension 3 - DPE'!$N$5
ITR_Score = 'Dimension 4 - ITR'!$L$5
ITR_Score_Adj = 'Dimension 4 - ITR'!$N$5
PctComplete = Welcome!$J$5
PracticeData = Data!$U$2:$W$14
RiskMatrix = Data!$M$2:$O$30
```

The practice score names follow the same pattern on every dimension tab: `<DIM>_1_Score` is L7, `<DIM>_2_Score` is L64 and `<DIM>_3_Score` is L121. The overall score has no defined name: it is Scorecard!E14, and the adjusted overall score is Scorecard!F14.

### Data Validation Lists
```
AnswerOptions = Data!$A$2:$A$5
Industries = Data!$C$2:$C$13
OrgSizes = Data!$E$2:$E$5
GeoScope = Data!$G$2:$G$5
RegulatoryReqs = Data!$K$2:$K$5
```

Profile!D15 (data sensitivity) uses a list validation that refers to Data!$I$2:$I$5 directly; that list has no defined name.

## Special Calculations

### Top Strengths/Weaknesses
```excel
=INDEX(PracticeNames, MATCH(LARGE(PracticeScores, 1), PracticeScores, 0))
=INDEX(PracticeNames, MATCH(SMALL(PracticeScores, 1), PracticeScores, 0))
```

### Progress Tracking
```excel
=COUNTIF(DimensionRange, "<>""") / 30
```

### Industry Benchmark
```excel
=VLOOKUP(Industry & "_" & OrgSize, BenchmarkTable, 2, FALSE)
```