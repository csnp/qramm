# QRAMM Compliance Mapping Framework
**Mapping QRAMM Practices to Federal Compliance Requirements**

Citations corrected on 2026-10-16 against the primary sources listed in the commit; coverage figures are under review.

## Overview

This document provides comprehensive mapping between QRAMM practices and key federal compliance frameworks, enabling organizations to understand how QRAMM implementation supports regulatory compliance for post-quantum cryptography readiness.

## Phase 1 Compliance Frameworks

### 1. NIST Post-Quantum Cryptography Standards
- **FIPS 203**: Module-Lattice-Based Key-Encapsulation Mechanism (ML-KEM)
- **FIPS 204**: Module-Lattice-Based Digital Signature Standard (ML-DSA)  
- **FIPS 205**: Stateless Hash-Based Digital Signature Standard (SLH-DSA)
- **NIST SP 800-131A Rev. 2**: Transitioning the Use of Cryptographic Algorithms (Rev. 3 initial public draft, October 2024, under review)
- **NIST IR 8547 (initial public draft, November 2024)**: Transition to Post-Quantum Cryptography Standards

### 2. CMMC 2.0 (Cybersecurity Maturity Model Certification)
- **Level 1**: Foundational (15 security requirements from FAR 52.204-21)
- **Level 2**: Advanced (110 practices based on NIST SP 800-171)
- **Level 3**: Expert (Level 2 plus 24 selected requirements from NIST SP 800-172)

### 3. FedRAMP (Federal Risk and Authorization Management Program)
- **FedRAMP Low**
- **FedRAMP Moderate**
- **FedRAMP High**

### 4. FISMA (Federal Information Security Management Act)
- **NIST SP 800-53 Rev. 5**: Security and Privacy Controls
- **FIPS 199**: Standards for Security Categorization
- **FIPS 200**: Minimum Security Requirements

### Related model, not a compliance target: PKI Consortium PQCMM
The PKI Consortium's PQC Maturity Model (PQCMM) scores the post-quantum readiness of a product or service, while QRAMM scores an organization. It is listed here as a sibling model, not as a framework QRAMM maps compliance to. See [QRAMM beside PQCMM](pqcmm-comparison.md) for how the two fit together.

---

## Compliance Mapping Structure

### Dimension 1: Cryptographic Visibility & Inventory (CVI)

#### Practice 1.1: Cryptographic Discovery & Inventory Management

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q1.1.1**: How does your organization identify cryptographic assets? | NIST IR 8547 (initial public draft) | CM.L2-3.4.1 "Establish baseline configurations" | CM-8 "System Component Inventory" | NIST SP 800-53 CM-8 |
| **Q1.1.2**: How does your organization document cryptographic assets? | NIST IR 8547 (initial public draft) | CM.L2-3.4.2 "Maintain inventory of organizational systems" | CM-8(1) "Updates During Installation and Removal" | NIST SP 800-53 CM-8(1) |
| **Q1.1.3**: How does your organization govern cryptographic asset ownership and accountability? | NIST SP 800-131A Rev. 2 Section 2 | AC.L2-3.1.1 "Limit system access" | AC-5 "Separation of Duties" | NIST SP 800-53 AC-5 |
| **Q1.1.4**: How does your organization validate cryptographic asset inventory completeness? | NIST IR 8547 (initial public draft) | CA.L2-3.12.1 "Conduct security assessments" | CA-2 "Control Assessments" | NIST SP 800-53 CA-2 |
| **Q1.1.5**: How does your organization ensure cryptographic visibility across third-party and cloud systems? | FIPS 203 | - | SA-9 "External System Services" | NIST SP 800-53 SA-9 |
| **Q1.1.6**: How is cryptographic asset inventory data used for strategic planning? | NIST IR 8547 (initial public draft) | - | PM-9 "Risk Management Strategy" | NIST SP 800-53 PM-9 |
| **Q1.1.7**: How are cryptographic assets prioritized for quantum-resistance upgrades? | NIST SP 800-131A Section 3 "Transition Timeline" | RA.L2-3.11.2 "Scan for vulnerabilities" | RA-3 "Risk Assessment" | NIST SP 800-53 RA-3 |
| **Q1.1.8**: How is cryptographic asset inventory maintained over time? | NIST IR 8547 (initial public draft) | CM.L2-3.4.3 "Track security configurations" | CM-8(2) "Automated Maintenance" | NIST SP 800-53 CM-8(2) |
| **Q1.1.9**: How does your organization include IoT and embedded devices in its cryptographic inventory? | FIPS 203 | SC.L2-3.13.8 "Implement cryptographic mechanisms" | SC-8 "Transmission Confidentiality and Integrity" | NIST SP 800-53 SC-8 |
| **Q1.1.10**: How does your organization stay informed about quantum computing advancements? | - | AT.L2-3.2.1 "Ensure awareness of security risks" | AT-2 "Literacy Training and Awareness" | NIST SP 800-53 AT-2 |

#### Practice 1.2: Vulnerability Assessment & Classification

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q1.2.1**: How does your organization identify quantum-vulnerable cryptographic algorithms? | NIST SP 800-131A Table 1 "Deprecated Algorithms" | RA.L2-3.11.1 "Identify and evaluate risk" | RA-5 "Vulnerability Monitoring and Scanning" | NIST SP 800-53 RA-5 |
| **Q1.2.2**: How are quantum-vulnerable systems classified based on their criticality? | FIPS 199 "Security Categorization" | RA.L2-3.11.3 "Remediate vulnerabilities" | RA-2 "Security Categorization" | NIST SP 800-53 RA-2 |
| **Q1.2.3**: How does your organization track updates to threat assessments? | NIST IR 8547 (initial public draft) | SI.L2-3.14.1 "Monitor security information" | SI-5 "Security Alerts, Advisories, and Directives" | NIST SP 800-53 SI-5 |
| **Q1.2.4**: How does your organization evaluate the effectiveness of vulnerability classification? | - | CA.L2-3.12.3 "Monitor security controls" | CA-7 "Continuous Monitoring" | NIST SP 800-53 CA-7 |
| **Q1.2.5**: How does your organization assess the business impact of cryptographic vulnerabilities? | FIPS 199 "Impact Assessment" | RA.L2-3.11.2 "Scan for vulnerabilities" | RA-3(1) "Supply Chain Risk Assessment" | NIST SP 800-53 RA-3(1) |
| **Q1.2.6**: How does your organization assess quantum vulnerability of data authenticity mechanisms? | FIPS 204 "Digital Signatures" | SC.L2-3.13.11 "Employ cryptographic hashing" | SC-13 "Cryptographic Protection" | NIST SP 800-53 SC-13 |
| **Q1.2.7**: How does your organization validate cryptographic implementation correctness? | FIPS 140-3 "Cryptographic Module Validation" | SC.L2-3.13.10 "Establish cryptographic key management" | SC-12 "Cryptographic Key Establishment and Management" | NIST SP 800-53 SC-12 |
| **Q1.2.8**: How does your organization assess trends in cryptographic vulnerabilities? | - | CA.L2-3.12.2 "Develop security plans" | CA-5 "Plan of Action and Milestones" | NIST SP 800-53 CA-5 |
| **Q1.2.9**: How does your organization apply quantum vulnerability insights? | NIST IR 8547 (initial public draft) | - | CA-7(3) "Trend Analyses" | NIST SP 800-53 CA-7(3) |
| **Q1.2.10**: How does your organization prioritize systems for stakeholder communication? | - | IR.L2-3.6.1 "Establish incident response" | IR-6 "Incident Reporting" | NIST SP 800-53 IR-6 |

#### Practice 1.3: Cryptographic Dependency Mapping

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q1.3.1**: How does your organization identify cryptographic dependencies? | NIST IR 8547 Section 3.2 | CM.L2-3.4.9 "Control configuration changes" | CM-4 "Impact Analyses" | NIST SP 800-53 CM-4 |
| **Q1.3.2**: How does your organization document cryptographic dependencies? | NIST SP 800-160 Vol. 1 | - | RA-9 "Criticality Analysis" | NIST SP 800-53 RA-9 |
| **Q1.3.3**: How does your organization analyze impact of cryptographic changes? | FIPS 200 "Change Impact" | CM.L2-3.4.4 "Analyze security impact" | CM-4(1) "Separate Test Environments" | NIST SP 800-53 CM-4(1) |
| **Q1.3.4**: How does your organization validate dependency mapping accuracy? | NIST IR 8547 Section 4.2 | - | CA-2(1) "Independent Assessors" | NIST SP 800-53 CA-2(1) |
| **Q1.3.5**: How does your organization keep dependency information current? | - | CM.L2-3.4.5 "Define configuration baselines" | CM-2 "Baseline Configuration" | NIST SP 800-53 CM-2 |
| **Q1.3.6**: How is dependency information used for migration planning? | NIST IR 8547 (initial public draft) | - | PM-30 "Supply Chain Risk Management Strategy" | NIST SP 800-53 PM-30 |
| **Q1.3.7**: How does your organization manage dependencies in build systems? | NIST SP 800-218 "SSDF" | - | SA-15 "Development Process, Standards, and Tools" | NIST SP 800-53 SA-15 |
| **Q1.3.8**: How does your organization assess OT dependencies? | NIST SP 800-82 Rev. 3 | - | SC-40 "Wireless Link Protection" | NIST SP 800-53 SC-40 |
| **Q1.3.9**: How are dependencies evaluated for architectural complexity? | NIST SP 800-160 Vol. 2 | - | SA-15(3) "Criticality Analysis" | NIST SP 800-53 SA-15(3) |
| **Q1.3.10**: How are dependencies tracked across CI/CD pipelines? | NIST SP 800-218 Section 3 | - | SA-11 "Developer Testing and Evaluation" | NIST SP 800-53 SA-11 |

---

### Dimension 2: Strategic Governance & Risk Management (SGRM)

#### Practice 2.1: Executive Leadership & Policy Management

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q2.1.1**: How is quantum risk oversight structured at the executive level? | OMB M-23-02 | - | PM-2 "Information Security Program Leadership Role" | NIST SP 800-53 PM-2 |
| **Q2.1.2**: How comprehensive is your quantum risk policy framework? | NIST IR 8547 (initial public draft) | - | PL-1 "Policy and Procedures" | NIST SP 800-53 PL-1 |
| **Q2.1.3**: How are quantum security initiatives funded and resourced? | OMB M-23-02 | - | PM-3 "Information Security and Privacy Resources" | NIST SP 800-53 PM-3 |
| **Q2.1.4**: How do you measure quantum risk governance effectiveness? | - | CA.L2-3.12.3 "Monitor security controls" | PM-6 "Measures of Performance" | NIST SP 800-53 PM-6 |
| **Q2.1.5**: How does leadership drive quantum security innovation? | - | - | PM-31 "Continuous Monitoring Strategy" | NIST SP 800-53 PM-31 |
| **Q2.1.6**: How is quantum risk integrated into organizational strategy? | OMB M-23-02 | - | PM-9 "Risk Management Strategy" | NIST SP 800-53 PM-9 |
| **Q2.1.7**: How are quantum security policies reviewed and maintained? | NIST IR 8547 (initial public draft) | - | PL-1 "Policy and Procedures" | NIST SP 800-53 PL-1 |
| **Q2.1.8**: How is executive leadership kept informed? | OMB M-23-02 | - | PM-14 "Testing, Training, and Monitoring" | NIST SP 800-53 PM-14 |
| **Q2.1.9**: How do you monitor progress across quantum readiness? | - | - | PM-6 "Measures of Performance" | NIST SP 800-53 PM-6 |
| **Q2.1.10**: How does your organization contribute to industry standards? | - | - | PM-15 "Security and Privacy Groups and Associations" | NIST SP 800-53 PM-15 |

#### Practice 2.2: Risk Assessment & Compliance Management

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q2.2.1**: How does your organization assess quantum computing risk? | NIST IR 8547 Section 2 | RA.L2-3.11.1 "Identify and evaluate risk" | RA-3 "Risk Assessment" | NIST SP 800-53 RA-3 |
| **Q2.2.2**: How does your organization manage quantum compliance requirements? | OMB M-23-02 | CA.L2-3.12.1 "Conduct assessments" | CA-1 "Policy and Procedures" | NIST SP 800-53 CA-1 |
| **Q2.2.3**: How does your organization integrate quantum risk into ERM? | - | RA.L2-3.11.2 "Vulnerability identification" | RA-7 "Risk Response" | NIST SP 800-53 RA-7 |
| **Q2.2.4**: How does your organization validate quantum risk assessments? | NIST SP 800-30 Rev. 1 | CA.L2-3.12.2 "Develop remediation plans" | CA-2(2) "Specialized Assessments" | NIST SP 800-53 CA-2(2) |
| **Q2.2.5**: How does your organization address quantum risk in BCP? | NIST SP 800-34 Rev. 1 | - | CP-2 "Contingency Plan" | NIST SP 800-53 CP-2 |
| **Q2.2.6**: How does your organization model quantum threat scenarios? | - | - | RA-3(2) "Use of All-source Intelligence" | NIST SP 800-53 RA-3(2) |
| **Q2.2.7**: How does your organization ensure multi-jurisdiction compliance? | - | - | CA-1 "Policy and Procedures" | NIST SP 800-53 CA-1 |
| **Q2.2.8**: How does your organization integrate quantum risk into operations? | - | - | RA-9 "Criticality Analysis" | NIST SP 800-53 RA-9 |
| **Q2.2.9**: How does your organization measure risk mitigation effectiveness? | NIST SP 800-55 Rev. 1 | - | PM-6 "Measures of Performance" | NIST SP 800-53 PM-6 |
| **Q2.2.10**: How does your organization contribute to standards development? | - | - | PM-31 "Continuous Monitoring Strategy" | NIST SP 800-53 PM-31 |

#### Practice 2.3: Third-Party & Supply Chain Risk Management

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q2.3.1**: How does your organization assess third-party quantum risk? | NIST SP 800-161 Rev. 1 | - | SR-1 "Policy and Procedures" | NIST SP 800-53 SR-1 |
| **Q2.3.2**: How does your organization incorporate quantum security into contracts? | OMB M-23-02 | - | SR-5 "Acquisition Strategies, Tools, and Methods" | NIST SP 800-53 SR-5 |
| **Q2.3.3**: How does your organization monitor third-party readiness? | - | - | SR-6 "Supplier Assessments and Reviews" | NIST SP 800-53 SR-6 |
| **Q2.3.4**: How does your organization validate third-party claims? | NIST SP 800-161 Section 3 | - | SR-6(1) "Testing and Analysis" | NIST SP 800-53 SR-6(1) |
| **Q2.3.5**: How does your organization manage critical third-party risks? | - | - | SR-8 "Notification Agreements" | NIST SP 800-53 SR-8 |
| **Q2.3.6**: How does your organization assess multi-tier dependencies? | NIST SP 800-161 Appendix F | - | SR-3(2) "Limitation of Harm" | NIST SP 800-53 SR-3(2) |
| **Q2.3.7**: How does your organization enforce quantum requirements in SLAs? | OMB M-23-02 | - | SR-5(1) "Adequate Supply" | NIST SP 800-53 SR-5(1) |
| **Q2.3.8**: How does your organization collaborate on risk mitigation? | - | - | SR-10 "Inspection of Systems or Components" | NIST SP 800-53 SR-10 |
| **Q2.3.9**: How does your organization assess third-party maturity? | NIST SP 800-161 Section 4 | - | SR-6 "Supplier Assessments and Reviews" | NIST SP 800-53 SR-6 |
| **Q2.3.10**: How does your organization drive ecosystem improvements? | - | - | SR-11 "Component Authenticity" | NIST SP 800-53 SR-11 |

---

### Dimension 3: Data Protection Engineering (DPE)

#### Practice 3.1: Data Classification & Protection Requirements

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q3.1.1**: How does your organization classify data based on quantum risk? | FIPS 199 + Quantum Timeline | SC.L2-3.13.1 "Information protection" | SC-28 "Protection of Information at Rest" | NIST SP 800-53 SC-28 |
| **Q3.1.2**: How does your organization define quantum protection requirements? | FIPS 203/204/205 Requirements | SC.L2-3.13.8 "Cryptographic mechanisms" | SC-13 "Cryptographic Protection" | NIST SP 800-53 SC-13 |
| **Q3.1.3**: How does your organization implement quantum-resistant controls? | - | SC.L2-3.13.11 "Employ FIPS crypto" | SC-13 "Cryptographic Protection" | NIST SP 800-53 SC-13 |
| **Q3.1.4**: How does your organization validate protection effectiveness? | NIST SP 800-175B Rev. 1 | CA.L2-3.12.3 "Monitor controls" | SC-13 "Cryptographic Protection" | NIST SP 800-53 SC-13 |
| **Q3.1.5**: How does your organization maintain protection over time? | - | SC.L2-3.13.10 "Key management" | SC-12 "Cryptographic Key Establishment and Management" | NIST SP 800-53 SC-12 |
| **Q3.1.6**: How does your organization protect long-term confidential data? | OMB M-23-02 | - | SC-28(1) "Cryptographic Protection" | NIST SP 800-53 SC-28(1) |
| **Q3.1.7**: How does your organization protect regulatory data? | NIST SP 800-171 Rev. 3 | SC.L2-3.13.1 "CUI protection" | SC-7 "Boundary Protection" | NIST SP 800-53 SC-7 |
| **Q3.1.8**: How does your organization manage cryptographic metadata? | NIST SP 800-57 Part 1 Rev. 5 | - | SC-28(3) "Cryptographic Keys" | NIST SP 800-53 SC-28(3) |
| **Q3.1.9**: How does your organization handle data transformation protection? | FIPS 203 | - | SC-8(3) "Cryptographic Protection for Message Externals" | NIST SP 800-53 SC-8(3) |
| **Q3.1.10**: How does your organization advance protection practices? | - | - | SC-13 "Cryptographic Protection" | NIST SP 800-53 SC-13 |

#### Practice 3.2: Storage Security & Encryption Management

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q3.2.1**: How does your organization protect data at rest from quantum threats? | FIPS 203 ML-KEM | SC.L2-3.13.16 "Protect CUI at rest" | SC-28 "Protection of Information at Rest" | NIST SP 800-53 SC-28 |
| **Q3.2.2**: How does your organization manage encryption keys? | NIST SP 800-57 Part 1 | SC.L2-3.13.10 "Key management" | SC-12 "Cryptographic Key Establishment and Management" | NIST SP 800-53 SC-12 |
| **Q3.2.3**: How does your organization ensure storage compliance? | FIPS 140-3 Level 2+ | SC.L2-3.13.11 "FIPS validated crypto" | SC-13 "Cryptographic Protection" | NIST SP 800-53 SC-13 |
| **Q3.2.4**: How does your organization validate storage security? | NIST SP 800-175B | CA.L2-3.12.1 "Security assessments" | SC-28(2) "Offline Storage" | NIST SP 800-53 SC-28(2) |
| **Q3.2.5**: How does your organization maintain storage security? | - | MA.L2-3.7.1 "Maintenance activities" | MA-2 "Controlled Maintenance" | NIST SP 800-53 MA-2 |
| **Q3.2.6**: How does your organization protect backup/archive data? | OMB M-23-02 | - | CP-9 "System Backup" | NIST SP 800-53 CP-9 |
| **Q3.2.7**: How does your organization manage distributed storage? | FIPS 203 | - | SC-36 "Distributed Processing and Storage" | NIST SP 800-53 SC-36 |
| **Q3.2.8**: How does your organization ensure HSM integration? | FIPS 140-3 HSM Requirements | - | SC-44 "Detonation Chambers" | NIST SP 800-53 SC-44 |
| **Q3.2.9**: How does your organization implement crypto-agility? | - | - | SC-12(6) "Physical Control of Keys" | NIST SP 800-53 SC-12(6) |
| **Q3.2.10**: How does your organization optimize storage encryption? | - | - | SC-13 "Cryptographic Protection" | NIST SP 800-53 SC-13 |

#### Practice 3.3: Transit Security & Protocol Management

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q3.3.1**: How does your organization protect data in transit? | FIPS 203/204 | SC.L2-3.13.8 "Implement crypto" | SC-8 "Transmission Confidentiality and Integrity" | NIST SP 800-53 SC-8 |
| **Q3.3.2**: How does your organization manage secure protocols? | NIST SP 800-52 Rev. 2 | SC.L2-3.13.11 "FIPS crypto" | SC-23 "Session Authenticity" | NIST SP 800-53 SC-23 |
| **Q3.3.3**: How does your organization ensure transit compliance? | NIST SP 800-171 Rev. 3 | SC.L2-3.13.1 "Boundary protection" | SC-7 "Boundary Protection" | NIST SP 800-53 SC-7 |
| **Q3.3.4**: How does your organization validate transit security? | NIST SP 800-115 | CA.L2-3.12.3 "Monitor controls" | SC-8(1) "Cryptographic Protection" | NIST SP 800-53 SC-8(1) |
| **Q3.3.5**: How does your organization maintain transit security? | - | SI.L2-3.14.1 "Monitor security" | SI-4 "System Monitoring" | NIST SP 800-53 SI-4 |
| **Q3.3.6**: How does your organization protect critical channels? | OMB M-23-02 | - | SC-8(2) "Pre- and Post-transmission Handling" | NIST SP 800-53 SC-8(2) |
| **Q3.3.7**: How does your organization manage protocol transitions? | - | - | SC-8(5) "Protected Distribution System" | NIST SP 800-53 SC-8(5) |
| **Q3.3.8**: How does your organization ensure end-to-end security? | - | - | SC-7(21) "Isolation of System Components" | NIST SP 800-53 SC-7(21) |
| **Q3.3.9**: How does your organization implement protocol agility? | - | - | SC-13 "Cryptographic Protection" | NIST SP 800-53 SC-13 |
| **Q3.3.10**: How does your organization advance transit security? | - | - | SC-8(4) "Conceal or Randomize Communications" | NIST SP 800-53 SC-8(4) |

---

### Dimension 4: Implementation & Technical Readiness (ITR)

#### Practice 4.1: Infrastructure Assessment & Planning

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q4.1.1**: How does your organization assess infrastructure readiness? | NIST IR 8547 Section 3 | CM.L2-3.4.1 "Baseline configurations" | CM-2 "Baseline Configuration" | NIST SP 800-53 CM-2 |
| **Q4.1.2**: How does your organization plan infrastructure upgrades? | - | CM.L2-3.4.2 "Configuration management" | CM-3 "Configuration Change Control" | NIST SP 800-53 CM-3 |
| **Q4.1.3**: How does your organization prioritize infrastructure investments? | OMB M-23-02 | - | PM-11 "Mission and Business Process Definition" | NIST SP 800-53 PM-11 |
| **Q4.1.4**: How does your organization validate infrastructure readiness? | - | CA.L2-3.12.1 "Security assessments" | CA-2 "Control Assessments" | NIST SP 800-53 CA-2 |
| **Q4.1.5**: How does your organization maintain infrastructure currency? | - | SI.L2-3.14.2 "Flaw remediation" | SI-2 "Flaw Remediation" | NIST SP 800-53 SI-2 |
| **Q4.1.6**: How does your organization assess performance impacts? | NIST SP 800-175B | - | SC-13 "Cryptographic Protection" | NIST SP 800-53 SC-13 |
| **Q4.1.7**: How does your organization plan hybrid scenarios? | - | - | SC-13 "Cryptographic Protection" | NIST SP 800-53 SC-13 |
| **Q4.1.8**: How does your organization ensure scalability? | - | - | SA-17 "Developer Security and Privacy Architecture and Design" | NIST SP 800-53 SA-17 |
| **Q4.1.9**: How does your organization optimize infrastructure? | - | - | SC-13 "Cryptographic Protection" | NIST SP 800-53 SC-13 |
| **Q4.1.10**: How does your organization contribute to best practices? | - | - | PM-15 "Security and Privacy Groups and Associations" | NIST SP 800-53 PM-15 |

#### Practice 4.2: Implementation Capability Development

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q4.2.1**: How does your organization build implementation skills? | - | AT.L2-3.2.1 "Security awareness" | AT-3 "Role-based Training" | NIST SP 800-53 AT-3 |
| **Q4.2.2**: How does your organization develop implementation processes? | - | - | SA-3 "System Development Life Cycle" | NIST SP 800-53 SA-3 |
| **Q4.2.3**: How does your organization manage implementation resources? | OMB M-23-02 | - | PM-3 "Information Security and Privacy Resources" | NIST SP 800-53 PM-3 |
| **Q4.2.4**: How does your organization ensure implementation quality? | - | - | SA-15 "Development Process, Standards, and Tools" | NIST SP 800-53 SA-15 |
| **Q4.2.5**: How does your organization sustain capabilities? | - | AT.L2-3.2.2 "Training program" | AT-3(3) "Practical Exercises" | NIST SP 800-53 AT-3(3) |
| **Q4.2.6**: How does your organization develop specialized expertise? | - | - | AT-3(5) "Processing Personally Identifiable Information" | NIST SP 800-53 AT-3(5) |
| **Q4.2.7**: How does your organization manage complex integrations? | - | - | SA-8 "Security and Privacy Engineering Principles" | NIST SP 800-53 SA-8 |
| **Q4.2.8**: How does your organization ensure consistency? | - | - | SA-4(9) "Functions, Ports, Protocols, and Services in Use" | NIST SP 800-53 SA-4(9) |
| **Q4.2.9**: How does your organization accelerate implementation? | - | - | SA-11(1) "Static Code Analysis" | NIST SP 800-53 SA-11(1) |
| **Q4.2.10**: How does your organization advance practices? | - | - | PM-31 "Continuous Monitoring Strategy" | NIST SP 800-53 PM-31 |

#### Practice 4.3: Testing & Validation Capabilities

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q4.3.1**: How does your organization test implementations? | NIST SP 800-115 | CA.L2-3.12.1 "Security testing" | CA-8 "Penetration Testing" | NIST SP 800-53 CA-8 |
| **Q4.3.2**: How does your organization validate correctness? | FIPS 140-3 CAVP | SC.L2-3.13.11 "FIPS validation" | SC-13 "Cryptographic Protection" | NIST SP 800-53 SC-13 |
| **Q4.3.3**: How does your organization test performance? | - | - | SC-13 "Cryptographic Protection" | NIST SP 800-53 SC-13 |
| **Q4.3.4**: How does your organization ensure test coverage? | - | - | CA-2(2) "Specialized Assessments" | NIST SP 800-53 CA-2(2) |
| **Q4.3.5**: How does your organization maintain testing capabilities? | - | - | CA-7 "Continuous Monitoring" | NIST SP 800-53 CA-7 |
| **Q4.3.6**: How does your organization test real-world conditions? | - | - | CA-8(1) "Independent Penetration Testing Agent or Team" | NIST SP 800-53 CA-8(1) |
| **Q4.3.7**: How does your organization validate interoperability? | - | - | SC-13 "Cryptographic Protection" | NIST SP 800-53 SC-13 |
| **Q4.3.8**: How does your organization test migration procedures? | - | - | CM-3(2) "Testing, Validation, and Documentation of Changes" | NIST SP 800-53 CM-3(2) |
| **Q4.3.9**: How does your organization automate testing? | - | - | CA-2(3) "Leveraging Results from External Organizations" | NIST SP 800-53 CA-2(3) |
| **Q4.3.10**: How does your organization advance testing practices? | - | - | CA-8(2) "Red Team Exercises" | NIST SP 800-53 CA-8(2) |

---

## Compliance Scoring Methodology

### Mapping Strength Indicators

Each QRAMM practice question is mapped to compliance requirements using the following strength indicators:

- **Direct Mapping** (●●●): QRAMM practice directly satisfies the compliance requirement
- **Strong Mapping** (●●○): QRAMM practice substantially addresses the requirement with minor gaps
- **Partial Mapping** (●○○): QRAMM practice partially addresses the requirement
- **Supporting** (○○○): QRAMM practice provides supporting evidence but doesn't directly satisfy

### Compliance Coverage Calculation

```
Compliance Score = (Direct × 1.0 + Strong × 0.75 + Partial × 0.5 + Supporting × 0.25) / Total Requirements
```

### Evidence Collection

For each mapped requirement, organizations should collect:
1. **Policy Documentation**: Showing governance and management commitment
2. **Technical Evidence**: Configuration files, scan results, architecture diagrams
3. **Process Evidence**: Procedures, workflows, change records
4. **Testing Evidence**: Assessment results, validation reports, remediation tracking

---

## Using This Mapping

### For Compliance Teams
1. Use mappings to identify which QRAMM practices support specific compliance requirements
2. Generate compliance-specific reports using QRAMM assessment results
3. Identify gaps where additional controls may be needed

### For Implementation Teams
1. Prioritize QRAMM practices that satisfy multiple compliance requirements
2. Use evidence requirements to guide documentation efforts
3. Align technical implementations with compliance needs

### For Auditors
1. Reference mappings to understand how QRAMM supports compliance objectives
2. Use QRAMM maturity scores as indicators of control effectiveness
3. Review evidence collection aligned with mapped requirements

---

*This compliance mapping is maintained by the QRAMM team and updated as standards evolve. For the latest version, visit [qramm.org](https://qramm.org)*