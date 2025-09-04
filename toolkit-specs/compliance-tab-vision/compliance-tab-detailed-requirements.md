# QRAMM Compliance Tab - Detailed Vision & Requirements

## Overview
The Compliance tab is designed to bridge the gap between QRAMM assessments and industry compliance frameworks. It helps organizations understand how their quantum readiness maturity translates to compliance with existing frameworks like NIST CSF, ISO 27001, SOC 2, etc.

## Core Functionality

### 1. Framework Selection
- **Purpose**: Allow users to select which compliance framework they want to map their QRAMM results against
- **Frameworks to Include**:
  - NIST CSF 2.0
  - ISO 27001:2022
  - SOC 2
  - CMMC 2.0
  - PCI DSS 4.0
  - Custom (user-defined)

### 2. Mapping Engine
The heart of the compliance tab is the mapping between QRAMM practices and framework controls.

#### How It Works:
1. **Pre-built Mappings**: Each QRAMM practice (120 questions across 12 practices) has pre-defined mappings to framework controls
2. **Weighted Scoring**: Each mapping has a weight (0-100%) indicating how much the QRAMM practice contributes to that framework control
3. **Confidence Levels**: Each mapping has a confidence indicator (High/Medium/Low) showing how direct the relationship is

#### Example Mapping:
```
QRAMM Practice: CVI.1.1 (Cryptographic Discovery & Inventory)
Maps to:
- NIST CSF ID.AM-2 (85% weight, High confidence)
- ISO 27001 A.8.1 (80% weight, High confidence)
- SOC 2 CC6.1 (70% weight, Medium confidence)
```

### 3. Scoring Calculation

The compliance score is calculated as:
1. For each framework control, sum the weighted contributions from all mapped QRAMM practices
2. If a control has multiple QRAMM mappings, the total cannot exceed 100%
3. Overall compliance = (Sum of all control scores) / (Total number of controls)

### 4. Gap Analysis

The gap analysis shows:
- **Covered Controls**: Framework controls with adequate QRAMM coverage (>70% default threshold)
- **Partial Controls**: Controls with some coverage (30-70%)
- **Gap Controls**: Controls with little/no QRAMM coverage (<30%)

### 5. User Adjustments

Users should be able to:
1. **Adjust Weights**: Modify the mapping weights based on their interpretation
2. **Add/Remove Mappings**: Create custom mappings or remove irrelevant ones
3. **Set Thresholds**: Define what constitutes "adequate" coverage
4. **Save Templates**: Save custom mapping configurations for reuse

## Data Structure Needed

### Mapping Table Structure:
```
| QRAMM_Practice_ID | Framework_ID | Control_ID | Weight | Confidence | Notes |
|-------------------|--------------|------------|--------|------------|-------|
| CVI.1.1          | NIST_CSF_2.0 | ID.AM-2    | 85     | High       | ...   |
| CVI.1.1          | ISO_27001    | A.8.1      | 80     | High       | ...   |
```

### Framework Controls Table:
```
| Framework_ID  | Control_ID | Control_Name | Control_Description | Category |
|--------------|------------|--------------|---------------------|----------|
| NIST_CSF_2.0 | ID.AM-2    | Software...  | Organization...     | Identify |
```

## Key Features for End Users

### 1. Executive View
- Overall compliance percentage
- Number of controls covered/gaps
- Priority gaps requiring attention
- Compliance trend over time

### 2. Detailed Mapping View
- See exactly which QRAMM practices map to which controls
- Understand the rationale behind mappings
- Adjust mappings based on organizational context

### 3. Gap Remediation
- For each gap, show which QRAMM practices need improvement
- Provide guidance on how improving QRAMM scores will impact compliance
- Priority ranking of gaps based on risk/importance

### 4. Reporting
- Generate compliance reports for different audiences
- Export mapping tables for documentation
- Create evidence packages for auditors

## Implementation Considerations

1. **Pre-populate Common Mappings**: Start with expert-validated mappings for major frameworks
2. **Allow Customization**: Every organization interprets frameworks differently
3. **Provide Rationale**: Include notes explaining why mappings exist
4. **Version Control**: Track framework versions (e.g., NIST CSF 1.1 vs 2.0)
5. **Validation Rules**: Ensure weights don't exceed logical limits

## User Workflow

1. Complete QRAMM assessment
2. Navigate to Compliance tab
3. Select target framework(s)
4. Review automated mapping and scores
5. Adjust mappings if needed
6. Analyze gaps
7. Generate compliance report
8. Use insights to prioritize improvements

## Value Proposition

This tab answers critical questions:
- "How does our quantum readiness translate to traditional compliance?"
- "Which compliance gaps are addressed by improving quantum readiness?"
- "Where do we need additional controls beyond QRAMM?"
- "How can we demonstrate quantum preparedness to auditors?"

The Compliance tab transforms QRAMM from a specialized assessment into a bridge to existing compliance programs, making quantum readiness actionable within current governance structures.