# QRAMM Full Assessment Framework
**Quantum Readiness Assurance Maturity Model - Complete 120-Question Evaluation**

## Overview

The QRAMM Full Assessment is a comprehensive evaluation framework designed to measure organizational readiness for quantum computing threats across four critical dimensions. This assessment provides detailed insights into your organization's current capabilities and guides strategic planning for quantum-safe transformation.

**Assessment Structure:**
- **4 Dimensions:** CVI, SGRM, DPE, ITR
- **12 Practices:** 3 practices per dimension
- **120 Questions:** 10 questions per practice
- **4 Maturity Levels:** From Basic (1) to Advanced (4)
- **2 Assessment Streams:** Foundation (60%) and Advanced (40%) per practice

## Instructions

For each question, select the option that best describes your organization's current state. Consider the explanation and evidence indicators when making your selection. Be honest and realistic in your assessments to ensure accurate results.

---

# Dimension 1: Cryptographic Visibility & Inventory (CVI)

## Practice 1.1: Cryptographic Discovery & Inventory Management

**Outcome**: A comprehensive, accurate, and up-to-date inventory of all cryptographic assets (algorithms, keys, certificates, and implementations) that clearly identifies quantum-vulnerable components and their business context, enabling prioritized migration planning.

### Question 1.1.1: How does your organization identify cryptographic assets?

**Explanation**: This assesses how your organization locates and identifies cryptographic assets including algorithms (e.g., RSA, AES), protocols (e.g., TLS, SSH), key sizes, Certificate Authorities (CA), Key Management Systems (KMS), Hardware Security Modules (HSM), and implementation details across all systems, applications, and infrastructure.

**Options**:
- **Level 1 - Basic**: No formal cryptographic asset identification process exists
- **Level 2 - Developing**: Manual inventory covering only known high-value systems
- **Level 3 - Established**: Automated discovery implemented for portions of infrastructure
- **Level 4 - Advanced**: Comprehensive automated discovery with validation across all environments

**Evidence to Look For**:
- Documentation of known cryptographic implementations in critical systems, including algorithm types and key sizes
- Use of automated network scanning tools that identify TLS implementations across the infrastructure
- Integrated tools identifying cryptography in applications, networks, hardware, and cloud services
- Advanced dashboards providing an up-to-date and comprehensive view of the cryptographic landscape

### Question 1.1.2: How does your organization document cryptographic assets?

**Explanation**: This examines how systematically you document identified cryptographic assets, including the level of detail captured (algorithms, key sizes, expiration dates) and how this information is maintained.

**Options**:
- **Level 1 - Basic**: No standardized documentation exists
- **Level 2 - Developing**: Basic spreadsheet tracking that captures limited attributes
- **Level 3 - Established**: Structured database with standardized templates
- **Level 4 - Advanced**: Centralized asset management platform with automated updates and risk scoring

**Evidence to Look For**:
- Documented inventory process covering high-value systems that specifies implementation details (e.g., RSA-2048, AES-128)
- Structured database documenting algorithms, key sizes, protocols, certificate details, and quantum vulnerability assessments
- Automated tools updating documentation based on discovery results
- Comprehensive metadata including algorithm types, key sizes, expiration dates, and risk ratings

### Question 1.1.3: How does your organization govern cryptographic asset ownership and accountability?

**Explanation**: This examines whether your organization has clear, enforceable ownership of cryptographic assets—ensuring someone is responsible for maintaining inventory accuracy, supporting migration planning, and responding to vulnerabilities across all systems and environments.

**Options**:
- **Level 1 - Basic**: No formal assignment of ownership or accountability for cryptographic assets
- **Level 2 - Developing**: Ownership of cryptographic assets is informally assigned for critical systems or managed by individual teams
- **Level 3 - Established**: Ownership roles are formally defined across the organization, with documented responsibilities and coverage tracking
- **Level 4 - Advanced**: Cryptographic ownership is embedded into asset governance processes, with automated assignment, accountability metrics, and cross-functional oversight

**Evidence to Look For**:
- Documentation of assigned crypto owners for a subset of high-value systems
- Ownership mapping integrated into inventory or Configuration Management Database (CMDB)
- Assigned accountability for lifecycle tasks (e.g., key rotation, renewal, algorithm upgrades)
- Accountability metrics tracked for timeliness of remediation, renewal, or migration actions

### Question 1.1.4: How does your organization validate cryptographic asset inventory completeness?

**Explanation**: This examines how you ensure your cryptographic asset inventory is accurate and comprehensive, without significant gaps or outdated information about algorithms, key sizes, or implementations.

**Options**:
- **Level 1 - Basic**: No validation of inventory completeness
- **Level 2 - Developing**: Periodic manual sampling of selected systems to verify inventory accuracy
- **Level 3 - Established**: Regular automated verification scans with a formal reconciliation process to address discrepancies
- **Level 4 - Advanced**: Continuous monitoring with anomaly detection and completeness analytics that automatically identifies potential gaps in the cryptographic inventory

**Evidence to Look For**:
- Spreadsheet annotations showing updates or corrections based on manual review
- Metrics tracking inventory accuracy and completeness (e.g., percentage of systems scanned, number of discrepancies found)
- Machine learning or rule-based analytics identifying trends in inventory coverage and data quality
- Real-time validation integrated into DevOps, CI/CD, or system provisioning pipelines

*[The full assessment would continue with all 120 questions following this same 4-level pattern...]*

---

## Maturity Level Definitions

| Level | Name | Description |
|-------|------|-------------|
| **1** | **Basic** | Initial awareness and ad-hoc practices |
| **2** | **Developing** | Structured approaches beginning to emerge |
| **3** | **Established** | Systematic and consistent practices |
| **4** | **Advanced** | Optimized processes with continuous improvement |

## Scoring Methodology

The QRAMM assessment uses a 4-point scale where:
- Each question is scored from 1-4 based on the selected maturity level
- Practice scores are calculated as the average of all questions within that practice
- Dimension scores are calculated as the average of all practices within that dimension
- Overall QRAMM score is calculated as the average of all four dimension scores

## Assessment Completion

This framework provides the structure for conducting a comprehensive quantum readiness assessment. For the complete 120-question assessment, please visit [https://csnp.github.io/qramm](https://csnp.github.io/qramm) or contact [qramm@csnp.org](mailto:qramm@csnp.org) for implementation guidance.

---

**Note**: This document shows the assessment framework structure. The complete 120-question assessment contains all questions across all four dimensions (CVI, SGRM, DPE, ITR) and twelve practices, each following the same 4-level maturity structure demonstrated above.
