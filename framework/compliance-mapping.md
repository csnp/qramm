# QRAMM Compliance Mapping Framework
**Mapping QRAMM Practices to Federal Compliance Requirements**

## Overview

This document provides comprehensive mapping between QRAMM practices and key federal compliance frameworks, enabling organizations to understand how QRAMM implementation supports regulatory compliance for post-quantum cryptography readiness.

## Phase 1 Compliance Frameworks

### 1. NIST Post-Quantum Cryptography Standards
- **FIPS 203**: Module-Lattice-Based Key-Encapsulation Mechanism (ML-KEM)
- **FIPS 204**: Module-Lattice-Based Digital Signature Standard (ML-DSA)  
- **FIPS 205**: Stateless Hash-Based Digital Signature Standard (SLH-DSA)
- **NIST SP 800-131A Rev. 2**: Transitioning the Use of Cryptographic Algorithms
- **NIST IR 8547**: Transition to Post-Quantum Cryptography Standards

### 2. CMMC 2.0 (Cybersecurity Maturity Model Certification)
- **Level 1**: Foundational (17 practices)
- **Level 2**: Advanced (110 practices based on NIST SP 800-171)
- **Level 3**: Expert (110+ practices based on NIST SP 800-172)

### 3. FedRAMP (Federal Risk and Authorization Management Program)
- **FedRAMP Low**: 125 controls
- **FedRAMP Moderate**: 325 controls
- **FedRAMP High**: 421 controls

### 4. FISMA (Federal Information Security Management Act)
- **NIST SP 800-53 Rev. 5**: Security and Privacy Controls
- **FIPS 199**: Standards for Security Categorization
- **FIPS 200**: Minimum Security Requirements

---

## Compliance Mapping Structure

### Dimension 1: Cryptographic Visibility & Inventory (CVI)

#### Practice 1.1: Cryptographic Discovery & Inventory Management

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q1.1.1**: How does your organization identify cryptographic assets? | NIST IR 8547 Section 3.1 "Inventory Systems" | CM.L2-3.4.1 "Establish baseline configurations" | CM-8 "Information System Component Inventory" | NIST SP 800-53 CM-8 |
| **Q1.1.2**: How does your organization document cryptographic assets? | NIST IR 8547 Section 3.2 "Document Dependencies" | CM.L2-3.4.2 "Maintain inventory of organizational systems" | CM-8(1) "Updates During Installations" | NIST SP 800-53 CM-8(1) |
| **Q1.1.3**: How does your organization govern cryptographic asset ownership and accountability? | NIST SP 800-131A Rev. 2 Section 2 | AC.L2-3.1.1 "Limit system access" | AC-5 "Separation of Duties" | NIST SP 800-53 AC-5 |
| **Q1.1.4**: How does your organization validate cryptographic asset inventory completeness? | NIST IR 8547 Section 4.1 "Validation" | CA.L2-3.12.1 "Conduct security assessments" | CA-2 "Security Assessments" | NIST SP 800-53 CA-2 |
| **Q1.1.5**: How does your organization ensure cryptographic visibility across third-party and cloud systems? | FIPS 203 Section 8 "Implementation Guidance" | SR.L2-3.14.1 "Identify supply chain elements" | SA-9 "External System Services" | NIST SP 800-53 SA-9 |
| **Q1.1.6**: How is cryptographic asset inventory data used for strategic planning? | NIST IR 8547 Section 5 "Migration Planning" | PM.L2-3.11.1 "Assess security risks" | PM-9 "Risk Management Strategy" | NIST SP 800-53 PM-9 |
| **Q1.1.7**: How are cryptographic assets prioritized for quantum-resistance upgrades? | NIST SP 800-131A Section 3 "Transition Timeline" | RA.L2-3.11.2 "Scan for vulnerabilities" | RA-3 "Risk Assessment" | NIST SP 800-53 RA-3 |
| **Q1.1.8**: How is cryptographic asset inventory maintained over time? | NIST IR 8547 Section 3.3 "Continuous Monitoring" | CM.L2-3.4.3 "Track security configurations" | CM-8(2) "Automated Maintenance" | NIST SP 800-53 CM-8(2) |
| **Q1.1.9**: How does your organization include IoT and embedded devices in its cryptographic inventory? | FIPS 203 Section 9 "Constrained Environments" | SC.L2-3.13.8 "Implement cryptographic mechanisms" | SC-8 "Transmission Confidentiality" | NIST SP 800-53 SC-8 |
| **Q1.1.10**: How does your organization stay informed about quantum computing advancements? | NIST PQC Project Updates | AT.L2-3.2.1 "Ensure awareness of security risks" | AT-2 "Security Awareness Training" | NIST SP 800-53 AT-2 |

#### Practice 1.2: Vulnerability Assessment & Classification

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q1.2.1**: How does your organization identify quantum-vulnerable cryptographic algorithms? | NIST SP 800-131A Table 1 "Deprecated Algorithms" | RA.L2-3.11.1 "Identify and evaluate risk" | RA-5 "Vulnerability Scanning" | NIST SP 800-53 RA-5 |
| **Q1.2.2**: How are quantum-vulnerable systems classified based on their criticality? | FIPS 199 "Security Categorization" | RA.L2-3.11.3 "Remediate vulnerabilities" | RA-2 "Security Categorization" | NIST SP 800-53 RA-2 |
| **Q1.2.3**: How does your organization track updates to threat assessments? | NIST IR 8547 Section 2 "Threat Model" | SI.L2-3.14.1 "Monitor security information" | SI-5 "Security Alerts" | NIST SP 800-53 SI-5 |
| **Q1.2.4**: How does your organization evaluate the effectiveness of vulnerability classification? | NIST Framework Core "Evaluate" | CA.L2-3.12.3 "Monitor security controls" | CA-7 "Continuous Monitoring" | NIST SP 800-53 CA-7 |
| **Q1.2.5**: How does your organization assess the business impact of cryptographic vulnerabilities? | FIPS 199 "Impact Assessment" | RA.L2-3.11.2 "Scan for vulnerabilities" | RA-3(1) "Supply Chain Risk" | NIST SP 800-53 RA-3(1) |
| **Q1.2.6**: How does your organization assess quantum vulnerability of data authenticity mechanisms? | FIPS 204 "Digital Signatures" | SC.L2-3.13.11 "Employ cryptographic hashing" | SC-13 "Cryptographic Protection" | NIST SP 800-53 SC-13 |
| **Q1.2.7**: How does your organization validate cryptographic implementation correctness? | FIPS 140-3 "Cryptographic Module Validation" | SC.L2-3.13.10 "Establish cryptographic key management" | SC-12 "Cryptographic Key Management" | NIST SP 800-53 SC-12 |
| **Q1.2.8**: How does your organization assess trends in cryptographic vulnerabilities? | NIST Vulnerability Database | CA.L2-3.12.2 "Develop security plans" | CA-5 "Plan of Action" | NIST SP 800-53 CA-5 |
| **Q1.2.9**: How does your organization apply quantum vulnerability insights? | NIST IR 8547 Section 6 "Lessons Learned" | CA.L3-3.12.4 "Analyze assessment results" | CA-7(3) "Trend Analyses" | NIST SP 800-53 CA-7(3) |
| **Q1.2.10**: How does your organization prioritize systems for stakeholder communication? | NIST CSF "Communicate" | IR.L2-3.6.1 "Establish incident response" | IR-6 "Incident Reporting" | NIST SP 800-53 IR-6 |

#### Practice 1.3: Cryptographic Dependency Mapping

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q1.3.1**: How does your organization identify cryptographic dependencies? | NIST IR 8547 Section 3.2 | CM.L2-3.4.9 "Control configuration changes" | CM-4 "Security Impact Analysis" | NIST SP 800-53 CM-4 |
| **Q1.3.2**: How does your organization document cryptographic dependencies? | NIST SP 800-160 Vol. 1 | SA.L2-3.14.2 "Develop supply chain risk plan" | SA-14 "Supply Chain Protection" | NIST SP 800-53 SA-14 |
| **Q1.3.3**: How does your organization analyze impact of cryptographic changes? | FIPS 200 "Change Impact" | CM.L2-3.4.4 "Analyze security impact" | CM-4(1) "Separate Test Environments" | NIST SP 800-53 CM-4(1) |
| **Q1.3.4**: How does your organization validate dependency mapping accuracy? | NIST IR 8547 Section 4.2 | CA.L3-3.12.5 "Develop remediation plans" | CA-2(1) "Independent Assessors" | NIST SP 800-53 CA-2(1) |
| **Q1.3.5**: How does your organization keep dependency information current? | NIST CSF "Maintain" | CM.L2-3.4.5 "Define configuration baselines" | CM-2 "Baseline Configuration" | NIST SP 800-53 CM-2 |
| **Q1.3.6**: How is dependency information used for migration planning? | NIST IR 8547 Section 5.2 | PM.L3-3.11.3 "Manage supply chain risk" | PM-30 "Supply Chain Risk Management" | NIST SP 800-53 PM-30 |
| **Q1.3.7**: How does your organization manage dependencies in build systems? | NIST SP 800-218 "SSDF" | SA.L2-3.14.1 "Identify critical systems" | SA-15 "Development Process" | NIST SP 800-53 SA-15 |
| **Q1.3.8**: How does your organization assess OT dependencies? | NIST SP 800-82 Rev. 3 | SC.L3-3.13.15 "Protect CUI in OT" | SC-40 "Wireless Link Protection" | NIST SP 800-53 SC-40 |
| **Q1.3.9**: How are dependencies evaluated for architectural complexity? | NIST SP 800-160 Vol. 2 | SA.L3-3.14.7 "Assess supply chain" | SA-15(3) "Criticality Analysis" | NIST SP 800-53 SA-15(3) |
| **Q1.3.10**: How are dependencies tracked across CI/CD pipelines? | NIST SP 800-218 Section 3 | SA.L3-3.14.6 "Develop secure code" | SA-11 "Developer Testing" | NIST SP 800-53 SA-11 |

---

### Dimension 2: Strategic Governance & Risk Management (SGRM)

#### Practice 2.1: Executive Leadership & Policy Management

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q2.1.1**: How is quantum risk oversight structured at the executive level? | M-23-02 Section 1 "Leadership" | PM.L2-3.11.1 "Assess security risks" | PM-2 "Senior Information Security Officer" | NIST SP 800-53 PM-2 |
| **Q2.1.2**: How comprehensive is your quantum risk policy framework? | NIST IR 8547 Section 7 "Policy" | PL.L2-3.12.1 "Develop security plans" | PL-1 "Security Planning Policy" | NIST SP 800-53 PL-1 |
| **Q2.1.3**: How are quantum security initiatives funded and resourced? | M-23-02 Section 4 "Resources" | PM.L2-3.11.2 "Manage security risks" | PM-3 "Information Security Resources" | NIST SP 800-53 PM-3 |
| **Q2.1.4**: How do you measure quantum risk governance effectiveness? | NIST CSF "Measure" | CA.L2-3.12.3 "Monitor security controls" | PM-6 "Information Security Measures" | NIST SP 800-53 PM-6 |
| **Q2.1.5**: How does leadership drive quantum security innovation? | NIST NCCoE PQC Migration | PM.L3-3.11.4 "Advanced risk management" | PM-31 "Continuous Improvement" | NIST SP 800-53 PM-31 |
| **Q2.1.6**: How is quantum risk integrated into organizational strategy? | M-23-02 Section 2 "Integration" | PM.L2-3.11.1 "Risk management strategy" | PM-9 "Risk Management Strategy" | NIST SP 800-53 PM-9 |
| **Q2.1.7**: How are quantum security policies reviewed and maintained? | NIST IR 8547 Section 7.2 | PL.L2-3.12.3 "Update security plans" | PL-1(1) "Policy Review" | NIST SP 800-53 PL-1(1) |
| **Q2.1.8**: How is executive leadership kept informed? | M-23-02 Section 3 "Reporting" | PM.L3-3.11.5 "Executive reporting" | PM-14 "Testing Program" | NIST SP 800-53 PM-14 |
| **Q2.1.9**: How do you monitor progress across quantum readiness? | NIST PQC Migration Playbook | CA.L3-3.12.4 "Analyze assessment results" | PM-6(1) "Performance Measures" | NIST SP 800-53 PM-6(1) |
| **Q2.1.10**: How does your organization contribute to industry standards? | NIST PQC Standardization | PM.L3-3.11.6 "External participation" | PM-15 "Contacts with Groups" | NIST SP 800-53 PM-15 |

#### Practice 2.2: Risk Assessment & Compliance Management

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q2.2.1**: How does your organization assess quantum computing risk? | NIST IR 8547 Section 2 | RA.L2-3.11.1 "Identify and evaluate risk" | RA-3 "Risk Assessment" | NIST SP 800-53 RA-3 |
| **Q2.2.2**: How does your organization manage quantum compliance requirements? | M-23-02 Compliance Timeline | CA.L2-3.12.1 "Conduct assessments" | CA-1 "Assessment Policy" | NIST SP 800-53 CA-1 |
| **Q2.2.3**: How does your organization integrate quantum risk into ERM? | NIST RMF Integration | RA.L2-3.11.2 "Vulnerability identification" | RA-7 "Risk Response" | NIST SP 800-53 RA-7 |
| **Q2.2.4**: How does your organization validate quantum risk assessments? | NIST SP 800-30 Rev. 1 | CA.L2-3.12.2 "Develop remediation plans" | CA-2(2) "Specialized Assessments" | NIST SP 800-53 CA-2(2) |
| **Q2.2.5**: How does your organization address quantum risk in BCP? | NIST SP 800-34 Rev. 1 | CP.L2-3.11.1 "Contingency planning" | CP-2 "Contingency Plan" | NIST SP 800-53 CP-2 |
| **Q2.2.6**: How does your organization model quantum threat scenarios? | NIST Threat Modeling | RA.L3-3.11.4 "Advanced threat analysis" | RA-3(2) "Threat Modeling" | NIST SP 800-53 RA-3(2) |
| **Q2.2.7**: How does your organization ensure multi-jurisdiction compliance? | NIST International Alignment | CA.L3-3.12.5 "Cross-framework mapping" | CA-1(1) "Multi-Framework" | NIST SP 800-53 CA-1(1) |
| **Q2.2.8**: How does your organization integrate quantum risk into operations? | NIST CSF Implementation | RA.L3-3.11.5 "Operational risk integration" | RA-9 "Criticality Analysis" | NIST SP 800-53 RA-9 |
| **Q2.2.9**: How does your organization measure risk mitigation effectiveness? | NIST SP 800-55 Rev. 1 | CA.L3-3.12.6 "Effectiveness measurement" | PM-6 "Performance Measures" | NIST SP 800-53 PM-6 |
| **Q2.2.10**: How does your organization contribute to standards development? | NIST PQC Contributions | PM.L3-3.11.7 "Standards participation" | PM-31(1) "Standards Body" | NIST SP 800-53 PM-31(1) |

#### Practice 2.3: Third-Party & Supply Chain Risk Management

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q2.3.1**: How does your organization assess third-party quantum risk? | NIST SP 800-161 Rev. 1 | SR.L2-3.14.1 "Identify supply chain elements" | SR-1 "Supply Chain Policy" | NIST SP 800-53 SR-1 |
| **Q2.3.2**: How does your organization incorporate quantum security into contracts? | M-23-02 Section 5 "Contracts" | SR.L2-3.14.2 "Supply chain risk plan" | SR-5 "Acquisition Strategies" | NIST SP 800-53 SR-5 |
| **Q2.3.3**: How does your organization monitor third-party readiness? | NIST C-SCRM Practices | SR.L2-3.14.3 "Monitor supply chain" | SR-6 "Supplier Assessments" | NIST SP 800-53 SR-6 |
| **Q2.3.4**: How does your organization validate third-party claims? | NIST SP 800-161 Section 3 | SR.L2-3.14.4 "Validate suppliers" | SR-6(1) "Testing/Validation" | NIST SP 800-53 SR-6(1) |
| **Q2.3.5**: How does your organization manage critical third-party risks? | NIST Critical Software | SR.L2-3.14.5 "Manage critical suppliers" | SR-8 "Notification Agreements" | NIST SP 800-53 SR-8 |
| **Q2.3.6**: How does your organization assess multi-tier dependencies? | NIST SP 800-161 Appendix F | SR.L3-3.14.6 "Multi-tier assessment" | SR-3(2) "Sub-tier Flow Down" | NIST SP 800-53 SR-3(2) |
| **Q2.3.7**: How does your organization enforce quantum requirements in SLAs? | M-23-02 Section 5.2 | SR.L3-3.14.7 "Contract enforcement" | SR-5(1) "SLA Requirements" | NIST SP 800-53 SR-5(1) |
| **Q2.3.8**: How does your organization collaborate on risk mitigation? | NIST NCCoE Collaboration | SR.L3-3.14.8 "Collaborative mitigation" | SR-10 "Improvement Process" | NIST SP 800-53 SR-10 |
| **Q2.3.9**: How does your organization assess third-party maturity? | NIST SP 800-161 Section 4 | SR.L3-3.14.9 "Maturity assessment" | SR-6(2) "Maturity Ratings" | NIST SP 800-53 SR-6(2) |
| **Q2.3.10**: How does your organization drive ecosystem improvements? | NIST Supply Chain CoE | SR.L3-3.14.10 "Ecosystem leadership" | SR-11 "Component Testing" | NIST SP 800-53 SR-11 |

---

### Dimension 3: Data Protection Engineering (DPE)

#### Practice 3.1: Data Classification & Protection Requirements

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q3.1.1**: How does your organization classify data based on quantum risk? | FIPS 199 + Quantum Timeline | SC.L2-3.13.1 "Information protection" | SC-28 "Protection at Rest" | NIST SP 800-53 SC-28 |
| **Q3.1.2**: How does your organization define quantum protection requirements? | FIPS 203/204/205 Requirements | SC.L2-3.13.8 "Cryptographic mechanisms" | SC-13 "Cryptographic Protection" | NIST SP 800-53 SC-13 |
| **Q3.1.3**: How does your organization implement quantum-resistant controls? | NIST PQC Implementation Guide | SC.L2-3.13.11 "Employ FIPS crypto" | SC-13(1) "FIPS Validated" | NIST SP 800-53 SC-13(1) |
| **Q3.1.4**: How does your organization validate protection effectiveness? | NIST SP 800-175B Rev. 1 | CA.L2-3.12.3 "Monitor controls" | SC-13(2) "NIST Approved" | NIST SP 800-53 SC-13(2) |
| **Q3.1.5**: How does your organization maintain protection over time? | NIST Crypto Agility | SC.L2-3.13.10 "Key management" | SC-12 "Key Management" | NIST SP 800-53 SC-12 |
| **Q3.1.6**: How does your organization protect long-term confidential data? | M-23-02 Long-term Protection | SC.L3-3.13.16 "CUI at rest" | SC-28(1) "Cryptographic Protection" | NIST SP 800-53 SC-28(1) |
| **Q3.1.7**: How does your organization protect regulatory data? | NIST SP 800-171 Rev. 3 | SC.L2-3.13.1 "CUI protection" | SC-7 "Boundary Protection" | NIST SP 800-53 SC-7 |
| **Q3.1.8**: How does your organization manage cryptographic metadata? | NIST SP 800-57 Part 1 Rev. 5 | SC.L3-3.13.14 "Metadata protection" | SC-28(3) "Metadata" | NIST SP 800-53 SC-28(3) |
| **Q3.1.9**: How does your organization handle data transformation protection? | FIPS 203 Processing | SC.L3-3.13.15 "Processing protection" | SC-8(3) "Security Attributes" | NIST SP 800-53 SC-8(3) |
| **Q3.1.10**: How does your organization advance protection practices? | NIST PQC Research | SC.L3-3.13.17 "Advanced crypto" | SC-13(3) "Innovation" | NIST SP 800-53 SC-13(3) |

#### Practice 3.2: Storage Security & Encryption Management

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q3.2.1**: How does your organization protect data at rest from quantum threats? | FIPS 203 ML-KEM | SC.L2-3.13.16 "Protect CUI at rest" | SC-28 "Protection at Rest" | NIST SP 800-53 SC-28 |
| **Q3.2.2**: How does your organization manage encryption keys? | NIST SP 800-57 Part 1 | SC.L2-3.13.10 "Key management" | SC-12 "Key Management" | NIST SP 800-53 SC-12 |
| **Q3.2.3**: How does your organization ensure storage compliance? | FIPS 140-3 Level 2+ | SC.L2-3.13.11 "FIPS validated crypto" | SC-13(1) "FIPS Validated" | NIST SP 800-53 SC-13(1) |
| **Q3.2.4**: How does your organization validate storage security? | NIST SP 800-175B | CA.L2-3.12.1 "Security assessments" | SC-28(2) "Offline Storage" | NIST SP 800-53 SC-28(2) |
| **Q3.2.5**: How does your organization maintain storage security? | NIST Maintenance Guide | MA.L2-3.7.1 "Maintenance activities" | MA-2 "Controlled Maintenance" | NIST SP 800-53 MA-2 |
| **Q3.2.6**: How does your organization protect backup/archive data? | M-23-02 Archive Requirements | CP.L2-3.11.2 "Backup CUI" | CP-9 "Information Backup" | NIST SP 800-53 CP-9 |
| **Q3.2.7**: How does your organization manage distributed storage? | FIPS 203 Distributed Systems | SC.L3-3.13.18 "Distributed protection" | SC-36 "Processing Isolation" | NIST SP 800-53 SC-36 |
| **Q3.2.8**: How does your organization ensure HSM integration? | FIPS 140-3 HSM Requirements | SC.L3-3.13.19 "Hardware security" | SC-44 "Detonation Chambers" | NIST SP 800-53 SC-44 |
| **Q3.2.9**: How does your organization implement crypto-agility? | NIST Crypto Agility Guide | SC.L3-3.13.20 "Algorithm agility" | SC-12(6) "Key Agility" | NIST SP 800-53 SC-12(6) |
| **Q3.2.10**: How does your organization optimize storage encryption? | NIST Performance Metrics | SC.L3-3.13.21 "Performance optimization" | SC-13(4) "Performance" | NIST SP 800-53 SC-13(4) |

#### Practice 3.3: Transit Security & Protocol Management

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q3.3.1**: How does your organization protect data in transit? | FIPS 203/204 Transit | SC.L2-3.13.8 "Implement crypto" | SC-8 "Transmission Protection" | NIST SP 800-53 SC-8 |
| **Q3.3.2**: How does your organization manage secure protocols? | NIST SP 800-52 Rev. 2 | SC.L2-3.13.11 "FIPS crypto" | SC-23 "Session Authenticity" | NIST SP 800-53 SC-23 |
| **Q3.3.3**: How does your organization ensure transit compliance? | NIST SP 800-171 Rev. 3 | SC.L2-3.13.1 "Boundary protection" | SC-7 "Boundary Protection" | NIST SP 800-53 SC-7 |
| **Q3.3.4**: How does your organization validate transit security? | NIST SP 800-115 | CA.L2-3.12.3 "Monitor controls" | SC-8(1) "Cryptographic Protection" | NIST SP 800-53 SC-8(1) |
| **Q3.3.5**: How does your organization maintain transit security? | NIST Continuous Monitoring | SI.L2-3.14.1 "Monitor security" | SI-4 "System Monitoring" | NIST SP 800-53 SI-4 |
| **Q3.3.6**: How does your organization protect critical channels? | M-23-02 Critical Systems | SC.L3-3.13.22 "Critical protection" | SC-8(2) "Pre/Post Transmission" | NIST SP 800-53 SC-8(2) |
| **Q3.3.7**: How does your organization manage protocol transitions? | NIST TLS Migration | SC.L3-3.13.23 "Protocol migration" | SC-8(5) "Concealment" | NIST SP 800-53 SC-8(5) |
| **Q3.3.8**: How does your organization ensure end-to-end security? | NIST E2E Guidelines | SC.L3-3.13.24 "E2E protection" | SC-7(21) "Isolation" | NIST SP 800-53 SC-7(21) |
| **Q3.3.9**: How does your organization implement protocol agility? | NIST Protocol Agility | SC.L3-3.13.25 "Protocol agility" | SC-13(5) "Flexibility" | NIST SP 800-53 SC-13(5) |
| **Q3.3.10**: How does your organization advance transit security? | NIST Research Initiatives | SC.L3-3.13.26 "Transit innovation" | SC-8(4) "Concealment" | NIST SP 800-53 SC-8(4) |

---

### Dimension 4: Implementation & Technical Readiness (ITR)

#### Practice 4.1: Infrastructure Assessment & Planning

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q4.1.1**: How does your organization assess infrastructure readiness? | NIST IR 8547 Section 3 | CM.L2-3.4.1 "Baseline configurations" | CM-2 "Baseline Configuration" | NIST SP 800-53 CM-2 |
| **Q4.1.2**: How does your organization plan infrastructure upgrades? | NIST PQC Migration Guide | CM.L2-3.4.2 "Configuration management" | CM-3 "Configuration Changes" | NIST SP 800-53 CM-3 |
| **Q4.1.3**: How does your organization prioritize infrastructure investments? | M-23-02 Prioritization | PM.L2-3.11.1 "Risk-based decisions" | PM-11 "Mission/Business Process" | NIST SP 800-53 PM-11 |
| **Q4.1.4**: How does your organization validate infrastructure readiness? | NIST Testing Guide | CA.L2-3.12.1 "Security assessments" | CA-2 "Security Assessments" | NIST SP 800-53 CA-2 |
| **Q4.1.5**: How does your organization maintain infrastructure currency? | NIST Patch Management | SI.L2-3.14.2 "Flaw remediation" | SI-2 "Flaw Remediation" | NIST SP 800-53 SI-2 |
| **Q4.1.6**: How does your organization assess performance impacts? | NIST SP 800-175B | SC.L3-3.13.27 "Performance testing" | SC-13(6) "Performance Testing" | NIST SP 800-53 SC-13(6) |
| **Q4.1.7**: How does your organization plan hybrid scenarios? | NIST Hybrid Guidance | SC.L3-3.13.28 "Hybrid crypto" | SC-13(7) "Hybrid Mode" | NIST SP 800-53 SC-13(7) |
| **Q4.1.8**: How does your organization ensure scalability? | NIST Scalability Guide | SA.L3-3.14.11 "Architecture review" | SA-17 "Architecture" | NIST SP 800-53 SA-17 |
| **Q4.1.9**: How does your organization optimize infrastructure? | NIST Optimization Guide | SC.L3-3.13.29 "Optimization" | SC-13(8) "Optimization" | NIST SP 800-53 SC-13(8) |
| **Q4.1.10**: How does your organization contribute to best practices? | NIST Community Engagement | PM.L3-3.11.8 "Knowledge sharing" | PM-15 "External Contacts" | NIST SP 800-53 PM-15 |

#### Practice 4.2: Implementation Capability Development

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q4.2.1**: How does your organization build implementation skills? | NIST Training Resources | AT.L2-3.2.1 "Security awareness" | AT-3 "Security Training" | NIST SP 800-53 AT-3 |
| **Q4.2.2**: How does your organization develop implementation processes? | NIST SDLC Integration | SA.L2-3.14.1 "Development lifecycle" | SA-3 "Lifecycle Development" | NIST SP 800-53 SA-3 |
| **Q4.2.3**: How does your organization manage implementation resources? | M-23-02 Resource Planning | PM.L2-3.11.2 "Resource management" | PM-3 "Information Resources" | NIST SP 800-53 PM-3 |
| **Q4.2.4**: How does your organization ensure implementation quality? | NIST Quality Assurance | SA.L2-3.14.2 "Development standards" | SA-15 "Development Process" | NIST SP 800-53 SA-15 |
| **Q4.2.5**: How does your organization sustain capabilities? | NIST Workforce Development | AT.L2-3.2.2 "Training program" | AT-3(3) "Practical Exercises" | NIST SP 800-53 AT-3(3) |
| **Q4.2.6**: How does your organization develop specialized expertise? | NIST PQC Expertise | AT.L3-3.2.3 "Advanced training" | AT-3(5) "Specialization" | NIST SP 800-53 AT-3(5) |
| **Q4.2.7**: How does your organization manage complex integrations? | NIST Integration Guide | SA.L3-3.14.12 "Complex systems" | SA-8 "Security Engineering" | NIST SP 800-53 SA-8 |
| **Q4.2.8**: How does your organization ensure consistency? | NIST Standards Compliance | SA.L3-3.14.13 "Standardization" | SA-4(9) "Functions" | NIST SP 800-53 SA-4(9) |
| **Q4.2.9**: How does your organization accelerate implementation? | NIST Automation Tools | SA.L3-3.14.14 "Automation" | SA-11(1) "Static Analysis" | NIST SP 800-53 SA-11(1) |
| **Q4.2.10**: How does your organization advance practices? | NIST Innovation Framework | PM.L3-3.11.9 "Innovation program" | PM-31 "Improvement" | NIST SP 800-53 PM-31 |

#### Practice 4.3: Testing & Validation Capabilities

**Compliance Mappings:**

| QRAMM Question | NIST PQC | CMMC 2.0 | FedRAMP | FISMA |
|----------------|----------|----------|---------|--------|
| **Q4.3.1**: How does your organization test implementations? | NIST SP 800-115 | CA.L2-3.12.1 "Security testing" | CA-8 "Penetration Testing" | NIST SP 800-53 CA-8 |
| **Q4.3.2**: How does your organization validate correctness? | FIPS 140-3 CAVP | SC.L2-3.13.11 "FIPS validation" | SC-13(1) "FIPS Validated" | NIST SP 800-53 SC-13(1) |
| **Q4.3.3**: How does your organization test performance? | NIST Performance Testing | SC.L3-3.13.30 "Performance validation" | SC-13(9) "Performance" | NIST SP 800-53 SC-13(9) |
| **Q4.3.4**: How does your organization ensure test coverage? | NIST Test Coverage | CA.L3-3.12.7 "Coverage analysis" | CA-2(2) "Specialized Testing" | NIST SP 800-53 CA-2(2) |
| **Q4.3.5**: How does your organization maintain testing capabilities? | NIST Test Infrastructure | CA.L3-3.12.8 "Test maintenance" | CA-7 "Continuous Monitoring" | NIST SP 800-53 CA-7 |
| **Q4.3.6**: How does your organization test real-world conditions? | NIST Operational Testing | CA.L3-3.12.9 "Operational testing" | CA-8(1) "Independent Testing" | NIST SP 800-53 CA-8(1) |
| **Q4.3.7**: How does your organization validate interoperability? | NIST Interop Testing | SC.L3-3.13.31 "Interoperability" | SC-13(10) "Interop Testing" | NIST SP 800-53 SC-13(10) |
| **Q4.3.8**: How does your organization test migration procedures? | NIST Migration Testing | CM.L3-3.4.10 "Migration testing" | CM-3(2) "Test Changes" | NIST SP 800-53 CM-3(2) |
| **Q4.3.9**: How does your organization automate testing? | NIST Test Automation | CA.L3-3.12.10 "Automated testing" | CA-2(3) "External Testing" | NIST SP 800-53 CA-2(3) |
| **Q4.3.10**: How does your organization advance testing practices? | NIST Test Innovation | CA.L3-3.12.11 "Testing innovation" | CA-8(2) "Red Team" | NIST SP 800-53 CA-8(2) |

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