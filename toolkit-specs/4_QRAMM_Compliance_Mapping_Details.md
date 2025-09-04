# QRAMM Excel Toolkit - Detailed Compliance Mapping

## Overview
This document provides the detailed compliance mapping for all 120 QRAMM questions to major security frameworks, with special emphasis on quantum readiness and post-quantum cryptography standards.

## Compliance Mapping Structure

Each question maps to multiple frameworks with relevance weights (0.0-1.0):
- 1.0 = Direct mapping, core requirement
- 0.8 = Strong alignment, important control
- 0.6 = Moderate alignment, supporting control
- 0.4 = Indirect alignment, related practice
- 0.2 = Minimal alignment, general relevance

## Framework Abbreviations
- NIST CSF = NIST Cybersecurity Framework 2.0
- NIST PQC = NIST Post-Quantum Cryptography Standards
- CMMC = Cybersecurity Maturity Model Certification 2.0
- FISMA = Federal Information Security Modernization Act
- FedRAMP = Federal Risk and Authorization Management Program
- ISO = ISO 27001/27002:2022
- SOC2 = SOC 2 Trust Services Criteria
- CIS = CIS Critical Security Controls v8

## Dimension 1 - Critical Vulnerability Identification (CVI)

### Practice 1.1: Asset Discovery & Classification (Q1-Q10)

| Question | NIST CSF | NIST PQC | CMMC | FISMA | FedRAMP | ISO | SOC2 | CIS |
|----------|----------|----------|-------|--------|---------|-----|------|-----|
| Q1: Automated asset discovery | ID.AM-1 (1.0) | - | AC.L1-3.1.1 (0.8) | SI-12 (0.8) | CM-8 (1.0) | A.8.1.1 (1.0) | CC6.1 (0.8) | 1.1 (1.0) |
| Q2: Asset classification schema | ID.AM-5 (1.0) | - | AC.L2-3.1.3 (0.8) | RA-2 (1.0) | RA-2 (1.0) | A.8.2.1 (1.0) | CC6.2 (0.8) | 2.1 (0.8) |
| Q3: Crypto inventory tracking | ID.AM-2 (1.0) | 1.1.1 (1.0) | SC.L2-3.13.11 (1.0) | SC-13 (1.0) | SC-13 (1.0) | A.8.1.2 (0.8) | CC6.1 (0.6) | 3.11 (1.0) |
| Q4: Hardware inventory | ID.AM-1 (1.0) | - | CM.L2-3.4.1 (1.0) | CM-8 (1.0) | CM-8a (1.0) | A.8.1.1 (1.0) | CC6.1 (1.0) | 1.1 (1.0) |
| Q5: Software inventory | ID.AM-2 (1.0) | - | CM.L2-3.4.2 (1.0) | CM-8 (1.0) | CM-8b (1.0) | A.8.1.2 (1.0) | CC6.1 (1.0) | 2.1 (1.0) |
| Q6: Network mapping | ID.AM-3 (1.0) | - | AC.L1-3.1.2 (0.8) | CM-8 (0.8) | CM-8 (0.8) | A.13.1.1 (1.0) | CC6.6 (0.8) | 12.1 (1.0) |
| Q7: Data flow mapping | ID.AM-3 (1.0) | - | SC.L2-3.13.8 (0.8) | SC-7 (1.0) | SC-7 (1.0) | A.13.2.1 (1.0) | CC6.6 (1.0) | 13.1 (0.8) |
| Q8: Critical asset identification | ID.BE-4 (1.0) | 1.1.2 (1.0) | RA.L2-3.11.1 (1.0) | RA-2 (1.0) | RA-2 (1.0) | A.5.1.1 (1.0) | CC3.2 (1.0) | 13.1 (0.8) |
| Q9: Third-party asset tracking | ID.SC-1 (1.0) | - | CM.L2-3.4.3 (0.8) | SA-4 (1.0) | SA-4 (1.0) | A.15.1.1 (1.0) | CC9.1 (1.0) | 15.1 (1.0) |
| Q10: Asset lifecycle management | ID.AM-4 (1.0) | - | CM.L2-3.4.4 (0.8) | CM-3 (1.0) | CM-3 (1.0) | A.8.1.3 (1.0) | CC6.1 (0.8) | 2.7 (0.8) |

### Practice 1.2: Vulnerability Scanning & Analysis (Q11-Q20)

| Question | NIST CSF | NIST PQC | CMMC | FISMA | FedRAMP | ISO | SOC2 | CIS |
|----------|----------|----------|-------|--------|---------|-----|------|-----|
| Q11: Continuous vulnerability scanning | ID.RA-1 (1.0) | - | RA.L2-3.11.2 (1.0) | RA-5 (1.0) | RA-5 (1.0) | A.12.6.1 (1.0) | CC7.1 (1.0) | 7.1 (1.0) |
| Q12: Crypto vulnerability assessment | ID.RA-1 (1.0) | 2.1.1 (1.0) | SC.L2-3.13.11 (1.0) | SC-13 (1.0) | SC-13 (1.0) | A.18.2.3 (0.8) | CC6.1 (0.8) | 3.11 (1.0) |
| Q13: Quantum threat assessment | ID.RA-3 (1.0) | 2.1.2 (1.0) | RA.L2-3.11.3 (0.8) | RA-3 (1.0) | RA-3 (1.0) | A.12.6.1 (0.6) | CC7.2 (0.8) | 18.1 (0.6) |
| Q14: Supply chain vulnerability | ID.SC-2 (1.0) | - | SR.L2-3.12.1 (1.0) | SA-12 (1.0) | SA-12 (1.0) | A.15.2.1 (1.0) | CC9.2 (1.0) | 15.2 (1.0) |
| Q15: Zero-day monitoring | DE.CM-8 (1.0) | - | SI.L2-3.14.3 (0.8) | SI-5 (1.0) | SI-5 (1.0) | A.12.6.1 (0.8) | CC7.1 (0.8) | 7.5 (0.8) |
| Q16: Vulnerability prioritization | ID.RA-5 (1.0) | - | RA.L2-3.11.2 (1.0) | RA-5 (1.0) | RA-5b (1.0) | A.12.6.1 (1.0) | CC7.1 (1.0) | 7.2 (1.0) |
| Q17: False positive management | ID.RA-1 (0.8) | - | CA.L2-3.12.3 (0.6) | CA-7 (0.8) | CA-7 (0.8) | A.12.6.1 (0.6) | CC7.1 (0.6) | 7.1 (0.6) |
| Q18: Vulnerability database | ID.RA-1 (1.0) | - | RA.L2-3.11.2 (0.8) | SI-5 (1.0) | SI-5 (1.0) | A.12.6.1 (0.8) | CC7.1 (0.8) | 7.4 (0.8) |
| Q19: Penetration testing | ID.RA-1 (1.0) | - | CA.L3-3.12.2 (1.0) | CA-8 (1.0) | CA-8 (1.0) | A.18.2.1 (1.0) | CC7.1 (1.0) | 18.1 (1.0) |
| Q20: Red team exercises | ID.RA-1 (0.8) | - | CA.L3-3.12.4 (1.0) | CA-8 (1.0) | CA-8 (1.0) | A.18.2.1 (0.8) | CC7.1 (0.8) | 18.2 (1.0) |

### Practice 1.3: Risk Prioritization & Tracking (Q21-Q30)

| Question | NIST CSF | NIST PQC | CMMC | FISMA | FedRAMP | ISO | SOC2 | CIS |
|----------|----------|----------|-------|--------|---------|-----|------|-----|
| Q21: Risk scoring methodology | ID.RA-4 (1.0) | - | RA.L2-3.11.1 (1.0) | RA-3 (1.0) | RA-3 (1.0) | A.5.1.2 (1.0) | CC3.2 (1.0) | 1.4 (0.8) |
| Q22: Quantum risk modeling | ID.RA-3 (1.0) | 3.1.1 (1.0) | RA.L2-3.11.3 (0.8) | RA-3 (1.0) | RA-3 (1.0) | A.5.1.2 (0.8) | CC3.2 (0.8) | 1.4 (0.6) |
| Q23: Risk treatment plans | ID.RM-2 (1.0) | - | RA.L2-3.11.1 (1.0) | RA-3 (1.0) | RA-3c (1.0) | A.6.1.3 (1.0) | CC3.3 (1.0) | 1.5 (0.8) |
| Q24: Risk register maintenance | ID.RM-1 (1.0) | - | RA.L2-3.11.1 (0.8) | PM-9 (1.0) | PM-9 (1.0) | A.6.1.4 (1.0) | CC3.2 (1.0) | 1.4 (0.8) |
| Q25: Remediation tracking | RS.MI-3 (1.0) | - | RM.L2-3.11.3 (1.0) | CA-5 (1.0) | CA-5 (1.0) | A.16.1.6 (1.0) | CC7.3 (1.0) | 7.3 (1.0) |
| Q26: Risk acceptance process | ID.RM-3 (1.0) | - | RA.L2-3.11.1 (0.8) | RA-3 (1.0) | RA-3d (1.0) | A.6.1.3 (1.0) | CC3.3 (1.0) | 1.5 (0.8) |
| Q27: Continuous risk monitoring | DE.CM-1 (1.0) | - | CA.L2-3.12.1 (1.0) | CA-7 (1.0) | CA-7 (1.0) | A.6.1.5 (1.0) | CC7.1 (1.0) | 7.1 (0.8) |
| Q28: Risk metrics and KPIs | ID.RM-1 (1.0) | - | CA.L2-3.12.3 (0.8) | PM-6 (1.0) | PM-6 (1.0) | A.6.1.4 (0.8) | CC4.1 (1.0) | 1.7 (0.8) |
| Q29: Third-party risk tracking | ID.SC-3 (1.0) | - | SR.L2-3.12.1 (1.0) | SA-9 (1.0) | SA-9 (1.0) | A.15.2.2 (1.0) | CC9.2 (1.0) | 15.2 (1.0) |
| Q30: Emerging threat intelligence | ID.RA-2 (1.0) | 3.1.2 (1.0) | PM.L2-3.11.1 (0.8) | PM-16 (1.0) | PM-16 (1.0) | A.6.1.2 (0.8) | CC7.2 (0.8) | 1.3 (0.8) |

## Dimension 2 - Strategic Governance & Risk Management (SGRM)

### Practice 2.1: Governance Structure & Leadership (Q31-Q40)

| Question | NIST CSF | NIST PQC | CMMC | FISMA | FedRAMP | ISO | SOC2 | CIS |
|----------|----------|----------|-------|--------|---------|-----|------|-----|
| Q31: Board oversight | GV.OC-1 (1.0) | - | CA.L2-3.12.1 (0.6) | PM-1 (1.0) | PM-1 (1.0) | A.5.1.1 (1.0) | CC1.1 (1.0) | 1.1 (0.8) |
| Q32: Security leadership roles | GV.OC-2 (1.0) | - | CA.L2-3.12.1 (0.8) | PM-2 (1.0) | PM-2 (1.0) | A.5.1.1 (1.0) | CC1.2 (1.0) | 1.2 (1.0) |
| Q33: Quantum governance body | GV.OC-1 (1.0) | 4.1.1 (1.0) | CA.L2-3.12.1 (0.6) | PM-1 (0.8) | PM-1 (0.8) | A.5.1.1 (0.8) | CC1.1 (0.8) | 1.1 (0.6) |
| Q34: Risk committee charter | GV.OC-3 (1.0) | - | CA.L2-3.12.1 (0.8) | PM-9 (1.0) | PM-9 (1.0) | A.5.1.1 (1.0) | CC1.3 (1.0) | 1.1 (0.8) |
| Q35: Policy framework | GV.PO-1 (1.0) | - | CA.L2-3.12.1 (1.0) | PL-1 (1.0) | PL-1 (1.0) | A.5.2.1 (1.0) | CC1.4 (1.0) | 1.3 (1.0) |
| Q36: Accountability matrix | GV.RR-1 (1.0) | - | CA.L2-3.12.1 (0.8) | PM-2 (1.0) | PM-2 (1.0) | A.5.3.1 (1.0) | CC1.2 (1.0) | 1.2 (0.8) |
| Q37: Budget allocation | GV.RM-1 (1.0) | - | CA.L2-3.12.1 (0.6) | PM-3 (1.0) | PM-3 (1.0) | A.5.1.1 (0.8) | CC1.5 (1.0) | 1.6 (0.8) |
| Q38: Strategic planning | GV.SP-1 (1.0) | 4.1.2 (1.0) | CA.L2-3.12.1 (0.8) | PM-8 (1.0) | PM-8 (1.0) | A.5.1.2 (1.0) | CC2.1 (1.0) | 1.1 (0.8) |
| Q39: Performance measurement | GV.MT-1 (1.0) | - | CA.L2-3.12.3 (1.0) | PM-6 (1.0) | PM-6 (1.0) | A.9.1.1 (1.0) | CC4.1 (1.0) | 1.7 (1.0) |
| Q40: Executive reporting | GV.OC-3 (1.0) | - | CA.L2-3.12.3 (0.8) | CA-7 (1.0) | CA-7 (1.0) | A.9.1.3 (1.0) | CC4.2 (1.0) | 1.8 (0.8) |

### Practice 2.2: Risk Management Framework (Q41-Q50)

| Question | NIST CSF | NIST PQC | CMMC | FISMA | FedRAMP | ISO | SOC2 | CIS |
|----------|----------|----------|-------|--------|---------|-----|------|-----|
| Q41: Risk management framework | ID.RM-1 (1.0) | - | RA.L2-3.11.1 (1.0) | PM-9 (1.0) | PM-9 (1.0) | A.6.1.1 (1.0) | CC3.1 (1.0) | 1.4 (1.0) |
| Q42: Risk appetite definition | ID.RM-2 (1.0) | - | RA.L2-3.11.1 (0.8) | PM-9 (1.0) | PM-9 (1.0) | A.6.1.2 (1.0) | CC3.2 (1.0) | 1.5 (0.8) |
| Q43: Quantum risk scenarios | ID.RA-3 (1.0) | 4.2.1 (1.0) | RA.L2-3.11.3 (0.8) | RA-3 (1.0) | RA-3 (1.0) | A.6.1.2 (0.8) | CC3.2 (0.8) | 1.4 (0.6) |
| Q44: Risk assessment process | ID.RA-1 (1.0) | - | RA.L2-3.11.1 (1.0) | RA-3 (1.0) | RA-3 (1.0) | A.6.1.3 (1.0) | CC3.2 (1.0) | 1.4 (1.0) |
| Q45: Control effectiveness | PR.IP-2 (1.0) | - | CA.L2-3.12.2 (1.0) | CA-2 (1.0) | CA-2 (1.0) | A.6.1.3 (1.0) | CC3.3 (1.0) | 1.5 (0.8) |
| Q46: Risk monitoring tools | DE.CM-1 (1.0) | - | CA.L2-3.12.1 (1.0) | CA-7 (1.0) | CA-7 (1.0) | A.6.1.5 (1.0) | CC7.1 (1.0) | 7.1 (0.8) |
| Q47: Risk communication | ID.RM-3 (1.0) | - | CA.L2-3.12.3 (0.8) | CA-7 (1.0) | CA-7 (1.0) | A.6.1.4 (1.0) | CC3.4 (1.0) | 1.8 (0.8) |
| Q48: Incident risk analysis | RS.AN-5 (1.0) | - | IR.L2-3.6.2 (1.0) | IR-4 (1.0) | IR-4 (1.0) | A.16.1.4 (1.0) | CC7.3 (1.0) | 16.5 (0.8) |
| Q49: Business continuity integration | ID.BE-5 (1.0) | - | CP.L2-3.11.1 (1.0) | CP-2 (1.0) | CP-2 (1.0) | A.17.1.1 (1.0) | CC9.1 (1.0) | 11.1 (1.0) |
| Q50: Risk aggregation | ID.RM-1 (1.0) | - | RA.L2-3.11.1 (0.8) | PM-9 (1.0) | PM-9 (1.0) | A.6.1.4 (1.0) | CC3.2 (1.0) | 1.4 (0.8) |

### Practice 2.3: Compliance & Audit (Q51-Q60)

| Question | NIST CSF | NIST PQC | CMMC | FISMA | FedRAMP | ISO | SOC2 | CIS |
|----------|----------|----------|-------|--------|---------|-----|------|-----|
| Q51: Compliance framework | GV.PO-2 (1.0) | - | CA.L2-3.12.4 (1.0) | CA-1 (1.0) | CA-1 (1.0) | A.18.1.1 (1.0) | CC2.1 (1.0) | 1.3 (0.8) |
| Q52: Regulatory tracking | ID.GV-3 (1.0) | - | CA.L2-3.12.4 (0.8) | PL-1 (1.0) | PL-1 (1.0) | A.18.1.1 (1.0) | CC2.2 (1.0) | 1.3 (0.8) |
| Q53: Audit program | PR.IP-1 (1.0) | - | CA.L2-3.12.1 (1.0) | CA-2 (1.0) | CA-2 (1.0) | A.18.2.1 (1.0) | CC5.1 (1.0) | 1.9 (1.0) |
| Q54: Control testing | PR.DS-6 (1.0) | - | CA.L2-3.12.2 (1.0) | CA-2 (1.0) | CA-2 (1.0) | A.18.2.2 (1.0) | CC5.2 (1.0) | 1.9 (0.8) |
| Q55: Audit findings tracking | RS.MI-3 (1.0) | - | CA.L2-3.12.3 (1.0) | CA-5 (1.0) | CA-5 (1.0) | A.18.2.3 (1.0) | CC5.3 (1.0) | 1.10 (0.8) |
| Q56: Compliance monitoring | DE.CM-6 (1.0) | - | CA.L2-3.12.1 (1.0) | CA-7 (1.0) | CA-7 (1.0) | A.18.2.2 (1.0) | CC5.2 (1.0) | 1.9 (0.8) |
| Q57: Evidence management | PR.IP-1 (1.0) | - | CA.L2-3.12.4 (0.8) | CA-2 (1.0) | CA-2 (1.0) | A.18.1.3 (1.0) | CC5.3 (1.0) | 1.9 (0.8) |
| Q58: External audit coordination | GV.OV-3 (1.0) | - | CA.L2-3.12.1 (0.8) | CA-2 (1.0) | CA-2 (1.0) | A.18.2.1 (1.0) | CC5.1 (1.0) | 1.9 (0.8) |
| Q59: Compliance reporting | GV.OC-3 (1.0) | - | CA.L2-3.12.3 (1.0) | CA-6 (1.0) | CA-6 (1.0) | A.18.1.4 (1.0) | CC5.4 (1.0) | 1.10 (0.8) |
| Q60: Continuous improvement | PR.IP-7 (1.0) | - | CA.L2-3.12.4 (0.8) | CA-7 (1.0) | CA-7 (1.0) | A.18.2.3 (1.0) | CC2.3 (1.0) | 1.11 (0.8) |

## Dimension 3 - Data Protection & Encryption (DPE)

### Practice 3.1: Encryption Implementation (Q61-Q70)

| Question | NIST CSF | NIST PQC | CMMC | FISMA | FedRAMP | ISO | SOC2 | CIS |
|----------|----------|----------|-------|--------|---------|-----|------|-----|
| Q61: Encryption at rest | PR.DS-1 (1.0) | 5.1.1 (1.0) | SC.L2-3.13.16 (1.0) | SC-28 (1.0) | SC-28 (1.0) | A.8.2.3 (1.0) | CC6.1 (1.0) | 3.11 (1.0) |
| Q62: Encryption in transit | PR.DS-2 (1.0) | 5.1.2 (1.0) | SC.L2-3.13.8 (1.0) | SC-8 (1.0) | SC-8 (1.0) | A.8.2.3 (1.0) | CC6.1 (1.0) | 3.13 (1.0) |
| Q63: Quantum-safe algorithms | PR.DS-1 (1.0) | 5.1.3 (1.0) | SC.L2-3.13.11 (0.8) | SC-13 (1.0) | SC-13 (1.0) | A.8.2.3 (0.8) | CC6.1 (0.8) | 3.11 (0.8) |
| Q64: Algorithm agility | PR.DS-5 (1.0) | 5.1.4 (1.0) | SC.L2-3.13.11 (0.8) | SC-13 (1.0) | SC-13 (1.0) | A.8.2.3 (0.8) | CC6.7 (0.8) | 3.11 (0.6) |
| Q65: Encryption standards | PR.DS-1 (1.0) | 5.1.5 (1.0) | SC.L2-3.13.11 (1.0) | SC-13 (1.0) | SC-13 (1.0) | A.8.2.3 (1.0) | CC6.1 (1.0) | 3.11 (1.0) |
| Q66: Certificate management | PR.DS-3 (1.0) | - | IA.L2-3.5.3 (1.0) | IA-5 (1.0) | IA-5 (1.0) | A.9.1.2 (1.0) | CC6.1 (1.0) | 3.12 (1.0) |
| Q67: Encryption performance | PR.DS-1 (0.8) | 5.1.6 (0.8) | SC.L2-3.13.11 (0.6) | SC-13 (0.8) | SC-13 (0.8) | A.8.2.3 (0.6) | CC6.1 (0.6) | 3.11 (0.6) |
| Q68: Legacy system encryption | PR.DS-1 (1.0) | 5.1.7 (1.0) | SC.L2-3.13.16 (0.8) | SC-28 (1.0) | SC-28 (1.0) | A.8.2.3 (0.8) | CC6.1 (0.8) | 3.11 (0.8) |
| Q69: Encryption monitoring | DE.CM-3 (1.0) | - | SC.L2-3.13.11 (0.8) | SI-4 (1.0) | SI-4 (1.0) | A.12.4.1 (1.0) | CC7.1 (1.0) | 8.1 (0.8) |
| Q70: Encryption exceptions | PR.DS-1 (0.8) | - | SC.L2-3.13.11 (0.8) | SC-13 (1.0) | SC-13 (1.0) | A.8.2.3 (0.8) | CC6.1 (0.8) | 3.11 (0.8) |

### Practice 3.2: Key Management Systems (Q71-Q80)

| Question | NIST CSF | NIST PQC | CMMC | FISMA | FedRAMP | ISO | SOC2 | CIS |
|----------|----------|----------|-------|--------|---------|-----|------|-----|
| Q71: Key lifecycle management | PR.AC-1 (1.0) | 5.2.1 (1.0) | SC.L2-3.13.10 (1.0) | SC-12 (1.0) | SC-12 (1.0) | A.10.1.2 (1.0) | CC6.1 (1.0) | 3.11 (1.0) |
| Q72: HSM implementation | PR.DS-1 (1.0) | 5.2.2 (1.0) | SC.L3-3.13.11 (1.0) | SC-13 (1.0) | SC-13 (1.0) | A.10.1.2 (1.0) | CC6.1 (1.0) | 3.11 (0.8) |
| Q73: Key rotation policies | PR.AC-1 (1.0) | 5.2.3 (1.0) | SC.L2-3.13.10 (1.0) | SC-12 (1.0) | SC-12 (1.0) | A.10.1.2 (1.0) | CC6.1 (1.0) | 3.11 (1.0) |
| Q74: Quantum key distribution | PR.DS-1 (0.8) | 5.2.4 (1.0) | SC.L3-3.13.11 (0.6) | SC-13 (0.8) | SC-13 (0.8) | A.10.1.2 (0.6) | CC6.1 (0.6) | 3.11 (0.6) |
| Q75: Key escrow and recovery | PR.AC-1 (1.0) | - | SC.L2-3.13.10 (1.0) | SC-12 (1.0) | SC-12 (1.0) | A.10.1.2 (1.0) | CC6.1 (1.0) | 3.11 (0.8) |
| Q76: Multi-party key control | PR.AC-4 (1.0) | 5.2.5 (0.8) | SC.L3-3.13.10 (0.8) | SC-12 (1.0) | SC-12 (1.0) | A.10.1.2 (0.8) | CC6.3 (0.8) | 3.11 (0.6) |
| Q77: Key usage auditing | DE.AE-3 (1.0) | - | AU.L2-3.3.1 (1.0) | AU-2 (1.0) | AU-2 (1.0) | A.12.4.1 (1.0) | CC7.1 (1.0) | 8.2 (1.0) |
| Q78: Crypto-period management | PR.AC-1 (1.0) | 5.2.6 (1.0) | SC.L2-3.13.10 (1.0) | SC-12 (1.0) | SC-12 (1.0) | A.10.1.2 (1.0) | CC6.1 (1.0) | 3.11 (0.8) |
| Q79: Key compromise procedures | RS.MI-3 (1.0) | - | IR.L2-3.6.1 (1.0) | IR-4 (1.0) | IR-4 (1.0) | A.16.1.5 (1.0) | CC7.3 (1.0) | 16.3 (0.8) |
| Q80: Centralized key management | PR.DS-1 (1.0) | 5.2.7 (1.0) | SC.L2-3.13.10 (1.0) | SC-12 (1.0) | SC-12 (1.0) | A.10.1.2 (1.0) | CC6.1 (1.0) | 3.11 (1.0) |

### Practice 3.3: Data Classification & Handling (Q81-Q90)

| Question | NIST CSF | NIST PQC | CMMC | FISMA | FedRAMP | ISO | SOC2 | CIS |
|----------|----------|----------|-------|--------|---------|-----|------|-----|
| Q81: Data classification scheme | ID.AM-5 (1.0) | - | MP.L2-3.8.1 (1.0) | RA-2 (1.0) | RA-2 (1.0) | A.8.2.1 (1.0) | CC6.2 (1.0) | 3.1 (1.0) |
| Q82: Automated classification | ID.AM-5 (1.0) | - | MP.L2-3.8.1 (0.8) | RA-2 (1.0) | RA-2 (1.0) | A.8.2.1 (0.8) | CC6.2 (0.8) | 3.1 (0.8) |
| Q83: Data labeling | PR.DS-3 (1.0) | - | MP.L2-3.8.2 (1.0) | MP-3 (1.0) | MP-3 (1.0) | A.8.2.2 (1.0) | CC6.2 (1.0) | 3.2 (0.8) |
| Q84: Handling procedures | PR.DS-3 (1.0) | - | MP.L2-3.8.3 (1.0) | MP-1 (1.0) | MP-1 (1.0) | A.8.2.3 (1.0) | CC6.2 (1.0) | 3.3 (1.0) |
| Q85: Data retention policies | PR.IP-6 (1.0) | - | MP.L2-3.8.1 (0.8) | MP-6 (1.0) | MP-6 (1.0) | A.8.3.1 (1.0) | CC6.5 (1.0) | 3.4 (0.8) |
| Q86: Secure data disposal | PR.IP-6 (1.0) | - | MP.L2-3.8.3 (1.0) | MP-6 (1.0) | MP-6 (1.0) | A.8.3.2 (1.0) | CC6.5 (1.0) | 3.6 (1.0) |
| Q87: Cross-border transfers | PR.PT-2 (1.0) | - | MP.L2-3.8.7 (0.8) | MP-5 (1.0) | MP-5 (1.0) | A.8.2.3 (0.8) | CC6.4 (1.0) | 3.3 (0.6) |
| Q88: Data loss prevention | PR.DS-5 (1.0) | - | SC.L2-3.13.2 (1.0) | SC-7 (1.0) | SC-7 (1.0) | A.8.3.1 (1.0) | CC6.6 (1.0) | 3.7 (1.0) |
| Q89: Privacy controls | PR.PT-1 (1.0) | - | MP.L2-3.8.1 (0.8) | AC-1 (1.0) | AC-1 (1.0) | A.18.1.4 (1.0) | P1.1 (1.0) | 3.8 (0.8) |
| Q90: Data sovereignty | PR.PT-2 (1.0) | - | MP.L2-3.8.7 (0.8) | MP-5 (1.0) | MP-5 (1.0) | A.18.1.4 (1.0) | CC6.4 (1.0) | 3.3 (0.6) |

## Dimension 4 - Infrastructure & Technical Readiness (ITR)

### Practice 4.1: Network Security Architecture (Q91-Q100)

| Question | NIST CSF | NIST PQC | CMMC | FISMA | FedRAMP | ISO | SOC2 | CIS |
|----------|----------|----------|-------|--------|---------|-----|------|-----|
| Q91: Network segmentation | PR.AC-5 (1.0) | - | SC.L2-3.13.5 (1.0) | SC-7 (1.0) | SC-7 (1.0) | A.13.1.3 (1.0) | CC6.6 (1.0) | 12.2 (1.0) |
| Q92: Zero trust architecture | PR.AC-4 (1.0) | - | AC.L3-3.1.2 (1.0) | AC-4 (1.0) | AC-4 (1.0) | A.13.1.3 (0.8) | CC6.3 (1.0) | 14.1 (0.8) |
| Q93: Microsegmentation | PR.AC-5 (1.0) | - | SC.L3-3.13.5 (1.0) | SC-7 (1.0) | SC-7 (1.0) | A.13.1.3 (1.0) | CC6.6 (1.0) | 12.2 (0.8) |
| Q94: Network monitoring | DE.CM-1 (1.0) | - | AU.L2-3.3.1 (1.0) | SI-4 (1.0) | SI-4 (1.0) | A.12.4.1 (1.0) | CC7.1 (1.0) | 13.1 (1.0) |
| Q95: Boundary protection | PR.AC-5 (1.0) | - | SC.L1-3.13.1 (1.0) | SC-7 (1.0) | SC-7 (1.0) | A.13.1.1 (1.0) | CC6.6 (1.0) | 12.1 (1.0) |
| Q96: IDS/IPS deployment | DE.CM-1 (1.0) | - | SI.L2-3.14.6 (1.0) | SI-4 (1.0) | SI-4 (1.0) | A.12.4.1 (1.0) | CC7.1 (1.0) | 13.2 (1.0) |
| Q97: VPN security | PR.AC-3 (1.0) | 6.1.1 (0.8) | AC.L2-3.1.12 (1.0) | AC-17 (1.0) | AC-17 (1.0) | A.13.1.1 (1.0) | CC6.6 (1.0) | 12.5 (1.0) |
| Q98: Cloud network security | PR.AC-5 (1.0) | - | SC.L2-3.13.5 (0.8) | SC-7 (1.0) | SC-7 (1.0) | A.13.1.3 (0.8) | CC6.6 (0.8) | 12.6 (0.8) |
| Q99: Software-defined networking | PR.AC-5 (0.8) | - | SC.L3-3.13.5 (0.8) | SC-7 (0.8) | SC-7 (0.8) | A.13.1.3 (0.8) | CC6.6 (0.8) | 12.2 (0.6) |
| Q100: Network access control | PR.AC-3 (1.0) | - | AC.L1-3.1.1 (1.0) | AC-3 (1.0) | AC-3 (1.0) | A.9.1.2 (1.0) | CC6.3 (1.0) | 14.6 (1.0) |

### Practice 4.2: System Hardening & Updates (Q101-Q110)

| Question | NIST CSF | NIST PQC | CMMC | FISMA | FedRAMP | ISO | SOC2 | CIS |
|----------|----------|----------|-------|--------|---------|-----|------|-----|
| Q101: Baseline configurations | PR.IP-1 (1.0) | - | CM.L2-3.4.1 (1.0) | CM-2 (1.0) | CM-2 (1.0) | A.12.1.1 (1.0) | CC7.1 (1.0) | 4.1 (1.0) |
| Q102: Configuration management | PR.IP-1 (1.0) | - | CM.L2-3.4.1 (1.0) | CM-3 (1.0) | CM-3 (1.0) | A.12.1.2 (1.0) | CC7.1 (1.0) | 4.1 (1.0) |
| Q103: Patch management | PR.IP-12 (1.0) | - | SI.L1-3.14.1 (1.0) | SI-2 (1.0) | SI-2 (1.0) | A.12.6.1 (1.0) | CC7.1 (1.0) | 7.3 (1.0) |
| Q104: Automated patching | PR.IP-12 (1.0) | - | SI.L2-3.14.2 (1.0) | SI-2 (1.0) | SI-2 (1.0) | A.12.6.1 (0.8) | CC7.1 (0.8) | 7.3 (0.8) |
| Q105: Security benchmarks | PR.IP-1 (1.0) | - | CM.L2-3.4.2 (1.0) | CM-6 (1.0) | CM-6 (1.0) | A.12.1.1 (1.0) | CC7.1 (1.0) | 5.1 (1.0) |
| Q106: Unnecessary services | PR.IP-1 (1.0) | - | CM.L2-3.4.6 (1.0) | CM-7 (1.0) | CM-7 (1.0) | A.12.5.1 (1.0) | CC7.1 (1.0) | 4.8 (1.0) |
| Q107: Default credentials | PR.AC-1 (1.0) | - | IA.L1-3.5.1 (1.0) | IA-5 (1.0) | IA-5 (1.0) | A.9.2.4 (1.0) | CC6.1 (1.0) | 5.3 (1.0) |
| Q108: System monitoring | DE.CM-8 (1.0) | - | AU.L2-3.3.1 (1.0) | SI-4 (1.0) | SI-4 (1.0) | A.12.4.1 (1.0) | CC7.1 (1.0) | 8.1 (1.0) |
| Q109: Change control | PR.IP-3 (1.0) | - | CM.L2-3.4.3 (1.0) | CM-3 (1.0) | CM-3 (1.0) | A.12.1.2 (1.0) | CC7.1 (1.0) | 11.1 (1.0) |
| Q110: Security testing | PR.IP-2 (1.0) | - | CA.L2-3.12.2 (1.0) | CA-8 (1.0) | CA-8 (1.0) | A.18.2.1 (1.0) | CC7.1 (1.0) | 18.1 (1.0) |

### Practice 4.3: Incident Response & Recovery (Q111-Q120)

| Question | NIST CSF | NIST PQC | CMMC | FISMA | FedRAMP | ISO | SOC2 | CIS |
|----------|----------|----------|-------|--------|---------|-----|------|-----|
| Q111: Incident response plan | RS.RP-1 (1.0) | - | IR.L2-3.6.1 (1.0) | IR-1 (1.0) | IR-1 (1.0) | A.16.1.1 (1.0) | CC7.3 (1.0) | 16.1 (1.0) |
| Q112: Incident team structure | RS.CO-3 (1.0) | - | IR.L2-3.6.1 (1.0) | IR-7 (1.0) | IR-7 (1.0) | A.16.1.2 (1.0) | CC7.3 (1.0) | 16.2 (1.0) |
| Q113: Detection capabilities | DE.AE-1 (1.0) | - | IR.L2-3.6.1 (1.0) | IR-4 (1.0) | IR-4 (1.0) | A.16.1.4 (1.0) | CC7.2 (1.0) | 16.3 (1.0) |
| Q114: Forensics readiness | RS.AN-1 (1.0) | - | IR.L2-3.6.2 (1.0) | IR-4 (1.0) | IR-4 (1.0) | A.16.1.7 (1.0) | CC7.4 (1.0) | 16.5 (0.8) |
| Q115: Containment procedures | RS.MI-1 (1.0) | - | IR.L2-3.6.1 (1.0) | IR-4 (1.0) | IR-4 (1.0) | A.16.1.5 (1.0) | CC7.3 (1.0) | 16.4 (1.0) |
| Q116: Recovery time objectives | RC.RP-1 (1.0) | - | CP.L2-3.11.2 (1.0) | CP-2 (1.0) | CP-2 (1.0) | A.17.1.1 (1.0) | A1.2 (1.0) | 11.1 (1.0) |
| Q117: Backup and restore | PR.IP-4 (1.0) | - | CP.L2-3.11.1 (1.0) | CP-9 (1.0) | CP-9 (1.0) | A.12.3.1 (1.0) | A1.2 (1.0) | 11.2 (1.0) |
| Q118: Disaster recovery plan | RC.RP-1 (1.0) | - | CP.L2-3.11.2 (1.0) | CP-2 (1.0) | CP-2 (1.0) | A.17.1.2 (1.0) | A1.2 (1.0) | 11.1 (1.0) |
| Q119: Post-incident analysis | RS.IM-1 (1.0) | - | IR.L2-3.6.3 (1.0) | IR-4 (1.0) | IR-4 (1.0) | A.16.1.6 (1.0) | CC7.5 (1.0) | 16.6 (1.0) |
| Q120: Tabletop exercises | RS.RP-1 (0.8) | - | IR.L2-3.6.1 (0.8) | IR-3 (1.0) | IR-3 (1.0) | A.17.1.3 (1.0) | CC7.3 (0.8) | 16.8 (1.0) |

## Weight Calculation Rules

### Framework Readiness Score Formula
```excel
FrameworkScore = SUMPRODUCT(QuestionScores, RelevanceWeights) / SUM(RelevanceWeights)
```

### Priority Calculation for Improvements
1. Questions with weight ≥ 0.8 are HIGH priority for that framework
2. Questions with weight 0.6-0.8 are MEDIUM priority
3. Questions with weight < 0.6 are LOW priority

### Special Considerations
- NIST PQC mappings only apply to cryptography-related questions
- CMMC levels (L1, L2, L3) indicate maturity requirements
- FedRAMP inherits all FISMA controls plus additional requirements
- Industry-specific frameworks (HIPAA, PCI DSS) would require additional mappings

## Implementation Notes

1. Store this mapping in the hidden Data tab as a structured table
2. Use XLOOKUP or INDEX/MATCH to retrieve weights dynamically
3. Create pivot tables for framework gap analysis
4. Enable filtering by framework to show relevant questions
5. Consider implementing a "Framework Focus Mode" that highlights questions most relevant to selected compliance requirements

This compliance mapping ensures organizations can:
- Track readiness for multiple frameworks simultaneously
- Identify control gaps efficiently
- Prioritize improvements based on compliance requirements
- Generate framework-specific reports
- Demonstrate quantum readiness to auditors and regulators