# QRAMM Excel Toolkit - Data Tables and Values

## Data Tab Structure

Create a hidden "Data" tab containing all reference tables. Use structured tables (Insert > Table) for easier formula references.

## Table 1: Answer Options (A1:A5)
| Answer_Options |
|----------------|
| Not Implemented |
| Partially Implemented |
| Mostly Implemented |
| Fully Implemented |

## Table 2: Industries (B1:B13)
| Industries |
|------------|
| Financial Services |
| Healthcare |
| Defense/Military |
| Technology |
| Energy/Utilities |
| Manufacturing |
| Retail |
| Government |
| Education |
| Telecommunications |
| Transportation |
| Other |

## Table 3: Organization Sizes (C1:C5)
| Org_Sizes |
|-----------|
| Fortune 500/Global Enterprise |
| Large Enterprise (1000+ employees) |
| Mid-Market (100-999 employees) |
| Small Business (<100 employees) |

## Table 4: Geographic Scope (D1:D5)
| Geo_Scope |
|-----------|
| Global (10+ countries) |
| Multi-region (3-9 countries) |
| Regional (2 countries) |
| Single Country |

## Table 5: Data Sensitivity (E1:E5)
| Data_Levels |
|-------------|
| Highly Classified/Secret |
| Confidential/Sensitive |
| Internal Use Only |
| Public/Non-sensitive |

## Table 6: Regulatory Requirements (F1:F5)
| Regulatory_Reqs |
|-----------------|
| Multiple Major Frameworks |
| Single Major Framework |
| Industry Standards Only |
| Minimal Requirements |

## Table 7: Risk Multiplier Matrix (H1:M13)
| Category | Factor | Value |
|----------|--------|-------|
| **Industry Risk** |
| Financial Services | 0.30 | 1.5 |
| Healthcare | 0.30 | 1.5 |
| Defense/Military | 0.30 | 1.5 |
| Technology | 0.30 | 1.3 |
| Energy/Utilities | 0.30 | 1.3 |
| Other Industries | 0.30 | 1.0 |
| **Data Sensitivity** |
| Highly Classified | 0.25 | 1.5 |
| Confidential | 0.25 | 1.3 |
| Internal/Public | 0.25 | 1.0 |
| **Regulatory** |
| Multiple Frameworks | 0.20 | 1.5 |
| Single Framework | 0.20 | 1.3 |
| Minimal/None | 0.20 | 1.0 |
| **Geographic** |
| Global | 0.15 | 1.5 |
| Multi-region | 0.15 | 1.3 |
| Single/Regional | 0.15 | 1.0 |
| **Organization Size** |
| Fortune 500 | 0.10 | 1.5 |
| Large Enterprise | 0.10 | 1.3 |
| SMB | 0.10 | 1.0 |

## Table 8: Maturity Levels (O1:Q6)
| Score_Min | Score_Max | Level |
|-----------|-----------|-------|
| 0.0 | 1.5 | Basic |
| 1.6 | 2.5 | Developing |
| 2.6 | 3.5 | Established |
| 3.6 | 3.9 | Advanced |
| 4.0 | 4.0 | Optimizing |

## Table 9: Practice Names and Weights (S1:U13)
| Practice_ID | Practice_Name | Weight |
|-------------|---------------|--------|
| CVI_1 | Asset Discovery & Classification | 0.35 |
| CVI_2 | Vulnerability Scanning & Analysis | 0.35 |
| CVI_3 | Risk Prioritization & Tracking | 0.30 |
| SGRM_1 | Governance Structure & Leadership | 0.40 |
| SGRM_2 | Risk Management Framework | 0.35 |
| SGRM_3 | Compliance & Audit | 0.25 |
| DPE_1 | Encryption Implementation | 0.40 |
| DPE_2 | Key Management Systems | 0.35 |
| DPE_3 | Data Classification & Handling | 0.25 |
| ITR_1 | Network Security Architecture | 0.35 |
| ITR_2 | System Hardening & Updates | 0.35 |
| ITR_3 | Incident Response & Recovery | 0.30 |

## Table 10: Dimension Metadata (W1:Z5)
| Dim_ID | Dimension_Name | Short_Name | Color |
|--------|----------------|------------|--------|
| 1 | Critical Vulnerability Identification | CVI | #1E3A5F |
| 2 | Strategic Governance & Risk Management | SGRM | #4A90E2 |
| 3 | Data Protection & Encryption | DPE | #28A745 |
| 4 | Infrastructure & Technical Readiness | ITR | #FFC107 |

## Table 11: Industry Benchmarks (AB1:AE25)
| Industry_Size | Avg_Overall | Avg_CVI | Avg_SGRM | Avg_DPE | Avg_ITR |
|---------------|-------------|---------|----------|---------|---------|
| Financial Services_Fortune 500 | 3.2 | 3.4 | 3.5 | 3.1 | 2.9 |
| Financial Services_Large | 2.8 | 2.9 | 3.1 | 2.7 | 2.5 |
| Financial Services_SMB | 2.2 | 2.1 | 2.4 | 2.3 | 2.0 |
| Healthcare_Fortune 500 | 3.0 | 3.2 | 3.3 | 2.9 | 2.7 |
| Healthcare_Large | 2.6 | 2.7 | 2.9 | 2.5 | 2.3 |
| Healthcare_SMB | 2.0 | 1.9 | 2.2 | 2.1 | 1.8 |
| Technology_Fortune 500 | 3.5 | 3.6 | 3.4 | 3.7 | 3.4 |
| Technology_Large | 3.1 | 3.0 | 3.0 | 3.3 | 3.0 |
| Technology_SMB | 2.5 | 2.4 | 2.4 | 2.7 | 2.4 |
| Other_All | 2.3 | 2.2 | 2.5 | 2.3 | 2.1 |

## Table 12: Recommendation Templates (AG1:AH31)
| Score_Range | Recommendation_Type | Recommendation_Text |
|-------------|--------------------|--------------------|
| 0.0-1.5 | Overall | Immediate action required. Your organization shows significant gaps in quantum readiness. Focus on establishing basic security foundations. |
| 1.6-2.5 | Overall | You have basic controls but need systematic improvements. Prioritize high-impact areas and develop a quantum readiness roadmap. |
| 2.6-3.5 | Overall | Good foundation in place. Focus on optimizing existing controls and addressing remaining gaps for quantum resilience. |
| 3.6-4.0 | Overall | Strong quantum readiness. Continue monitoring emerging threats and maintain your security posture. |
| 0.0-2.0 | CVI | Implement comprehensive asset discovery and establish vulnerability management processes. |
| 0.0-2.0 | SGRM | Establish quantum risk governance structure and develop strategic planning capabilities. |
| 0.0-2.0 | DPE | Deploy quantum-resistant encryption and implement robust key management systems. |
| 0.0-2.0 | ITR | Strengthen infrastructure security and develop incident response capabilities. |

## Table 13: Compliance Framework Mappings (AJ1:AM121)
Structure: Question_ID | Framework | Control_ID | Relevance_Weight

Sample entries:
| Question_ID | Framework | Control_ID | Weight |
|-------------|-----------|------------|--------|
| Q1 | NIST CSF | ID.AM-1 | 1.0 |
| Q1 | ISO 27001 | A.8.1.1 | 0.8 |
| Q1 | CMMC | AC.L1-3.1.1 | 0.6 |
| Q2 | NIST CSF | ID.AM-2 | 1.0 |
| Q2 | ISO 27001 | A.8.1.2 | 0.8 |
| ... | ... | ... | ... |

## Table 14: Score Color Thresholds (AO1:AP6)
| Score_Threshold | Color_Code |
|-----------------|------------|
| 1.0 | #FFCDD2 |
| 1.6 | #FFF3CD |
| 2.6 | #D4EDDA |
| 3.6 | #C3E6CB |
| 4.0 | #E1BEE7 |

## Table 15: Chart Data Ranges (AR1:AS5)
| Chart_Type | Data_Range |
|------------|------------|
| Radar_Labels | {"CVI";"SGRM";"DPE";"ITR"} |
| Radar_Values | {Dim1_Score;Dim2_Score;Dim3_Score;Dim4_Score} |
| Progress_Bar | {Questions_Answered/120} |
| Maturity_Donut | COUNTIF by maturity level |

## Critical Named Ranges to Define

```excel
Named Range                Range Reference
-----------                ---------------
AnswerOptions             Data!$A$2:$A$5
Industries                Data!$B$2:$B$13
OrgSizes                  Data!$C$2:$C$5
GeoScope                  Data!$D$2:$D$5
DataLevels                Data!$E$2:$E$5
RiskMatrix                Data!$H$2:$M$13
MaturityLevels            Data!$O$2:$Q$6
PracticeData              Data!$S$2:$U$13
DimensionData             Data!$W$2:$Z$5
Benchmarks                Data!$AB$2:$AE$25
Recommendations           Data!$AG$2:$AH$31
ComplianceMap             Data!$AJ$2:$AM$121
ScoreColors               Data!$AO$2:$AP$6
```