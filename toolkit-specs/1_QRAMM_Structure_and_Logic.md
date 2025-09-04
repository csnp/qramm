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

### 1. Individual Question Scoring
- Each question has 4 answer options
- Scores: 1 (Basic), 2 (Developing), 3 (Established), 4 (Advanced)
- Empty answers = 0 (not counted in averages)

### 2. Aggregation Hierarchy
```
Question Score (1-4)
  ↓
Practice Average = AVG(10 questions per practice)
  ↓
Dimension Score = AVG(3 practices per dimension)
  ↓
Overall Score = AVG(4 dimension scores) × ProfileMultiplier
```

### 3. Profile Multiplier Calculation
The ProfileMultiplier adjusts all scores based on organizational risk factors:

```excel
ProfileMultiplier = ROUND(
    IndustryRisk × 0.30 +
    DataSensitivity × 0.25 +
    RegulatoryReqs × 0.20 +
    GeographicScope × 0.15 +
    OrgSize × 0.10,
    2)
```

**Risk Factor Values:**
- Industry: Finance/Healthcare/Defense = 1.5, Tech/Energy = 1.3, Other = 1.0
- Data Sensitivity: Highly Classified = 1.5, Confidential = 1.3, Public = 1.0
- Regulatory: Multiple = 1.5, Single = 1.3, None = 1.0
- Geographic: Global = 1.5, Multi-region = 1.3, Single = 1.0
- Org Size: Fortune 500 = 1.5, Large = 1.3, SMB = 1.0

### 4. Maturity Level Mapping
```excel
=LOOKUP(Score, {0, 1.6, 2.6, 3.6, 4.0}, 
    {"Basic", "Developing", "Established", "Advanced", "Optimizing"})
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
ProfileMultiplier = Profile!K20
Dim1_Score = 'Dimension 1 - CVI'!E46
Dim2_Score = 'Dimension 2 - SGRM'!E46
Dim3_Score = 'Dimension 3 - DPE'!E46
Dim4_Score = 'Dimension 4 - ITR'!E46
Overall_Score = Scorecard!B3
```

### Data Validation Lists
```
AnswerOptions = Data!$A$2:$A$5
Industries = Data!$B$2:$B$13
OrgSizes = Data!$C$2:$C$5
GeoScope = Data!$D$2:$D$5
DataLevels = Data!$E$2:$E$5
```

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