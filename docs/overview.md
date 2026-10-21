# QRAMM overview

This page describes QRAMM in more depth: who it helps, how the framework is built, how it is scored, and which standards it maps to. For a short introduction, see the [README](../README.md).

## Executive Summary

The **Quantum Readiness Assurance Maturity Model (QRAMM)** is an evidence-based framework designed to help enterprises systematically prepare for the quantum computing threat to current cryptographic systems. Developed by cybersecurity experts at CyberSecurity NonProfit (CSNP), QRAMM provides the structured approach organizations need to:

- **Assess** current quantum vulnerability across all cryptographic assets
- **Plan** strategic transition to quantum-safe cryptography
- **Implement** post-quantum security measures with minimal disruption
- **Validate** quantum readiness through continuous monitoring

With quantum computers capable of breaking RSA-2048 encryption expected within 5-10 years, organizations must act now to protect long-term sensitive data and maintain business continuity.

## Business Value Proposition

### For Executive Leadership
- **Clear ROI**: Quantifiable risk reduction and compliance assurance
- **Competitive Advantage**: Early adoption positions your organization as a security leader
- **Board-Ready Reporting**: Executive dashboards and maturity visualizations
- **Regulatory Compliance**: Meet emerging quantum security requirements

### For Security Professionals
- **Coverage**: Framework addressing all aspects of quantum readiness
- **Technical Depth**: Detailed implementation guidance and best practices
- **Tool Integration**: Compatible with existing security infrastructure
- **Community Support**: Active community of practitioners and experts

### For Compliance Teams
- **Standards Alignment**: Full compatibility with NIST, ISO, and industry standards
- **Audit Trail**: Complete documentation for regulatory assessments
- **Risk Frameworks**: Integrated with enterprise risk management
- **Evidence Collection**: Systematic approach to compliance demonstration

## The Quantum Threat Timeline

<div align="center">

| Timeline | Event | Impact |
|----------|-------|---------|
| **2024-2025** | Initial assessments begin | Organizations start quantum readiness journey |
| **2026-2028** | NIST standards adoption | Regulatory requirements emerge |
| **2029-2032** | Quantum computers emerge | Current encryption vulnerable |
| **2033+** | Widespread quantum computing | Unprepared organizations at severe risk |

**CRITICAL: Data encrypted today can be harvested now and decrypted later**

</div>

## QRAMM Framework Architecture

### Four Integrated Dimensions

#### **Dimension 1: Cryptographic Visibility & Inventory (CVI)**
*Foundation: Understanding and cataloging cryptographic assets across the organization*

**What It Does**: CVI establishes visibility into your cryptographic landscape, discovering every algorithm, key, certificate, and protocol across all systems. It transforms invisible cryptographic dependencies into a manageable asset inventory.

**Why It's Critical**: Without knowing what cryptographic assets you have and where they're deployed, planning a quantum-safe transition becomes impossible. CVI enables proactive, risk-based planning instead of reactive scrambling.

**Key Value**: 
- Discovers hidden quantum vulnerabilities in legacy systems and third-party components
- Maps cryptographic dependencies to prevent migration failures
- Enables data-driven prioritization based on actual risk
- Identifies compliance gaps before they become violations

**Practice Areas**:
- **Practice 1.1**: Cryptographic Discovery & Inventory Management
- **Practice 1.2**: Vulnerability Assessment & Classification  
- **Practice 1.3**: Cryptographic Dependency Mapping

#### **Dimension 2: Strategic Governance & Risk Management (SGRM)**
*Leadership: Leadership commitment and systematic risk management for quantum threats*

**What It Does**: SGRM establishes the organizational foundation for quantum readiness through executive leadership, policies, and integrated risk management. It transforms quantum security from an IT project into a strategic business imperative.

**Why It's Critical**: Quantum-safe transformation requires years of sustained effort, significant investment, and enterprise-wide coordination. Without executive commitment and governance, initiatives fail to secure resources and organizational authority.

**Key Value**:
- Establishes board-level accountability for quantum security
- Secures dedicated funding for multi-year transformation
- Breaks down organizational silos for coordinated response
- Aligns quantum readiness with regulatory compliance
- Extends governance to supply chain partners

**Practice Areas**:
- **Practice 2.1**: Executive Leadership & Policy Management
- **Practice 2.2**: Risk Assessment & Compliance Management
- **Practice 2.3**: Third-Party & Supply Chain Risk Management

#### **Dimension 3: Data Protection Engineering (DPE)**
*Protection: Technical implementation of quantum-safe data protection measures*

**What It Does**: DPE implements the technical controls that protect sensitive information against quantum threats across all data states: at rest, in transit, and in use. It delivers real security through quantum-resistant encryption and key management.

**Why It's Critical**: Data is the target. Current encryption will become vulnerable to quantum decryption, threatening everything from financial records to healthcare data. DPE addresses the "harvest now, decrypt later" threat.

**Key Value**:
- Protects long-term sensitive data against future quantum threats
- Replaces vulnerable algorithms before they fail
- Establishes cryptographic agility for evolving standards
- Maintains operational efficiency with optimized implementations
- Ensures compliance with data protection regulations

**Practice Areas**:
- **Practice 3.1**: Data Classification & Protection Requirements
- **Practice 3.2**: Storage Security & Encryption Management
- **Practice 3.3**: Transit Security & Protocol Management

#### **Dimension 4: Implementation & Technical Readiness (ITR)**
*Execution: Execution capabilities for quantum-safe technology deployment*

**What It Does**: ITR bridges the gap between planning and reality, ensuring successful deployment, integration, and maintenance of quantum-resistant technologies. It transforms strategic intentions into operational systems while maintaining business continuity.

**Why It's Critical**: A strategy fails without effective implementation. ITR prevents common failures (from performance problems to integration issues) that derail quantum initiatives. It makes the difference between talking about quantum security and achieving it.

**Key Value**:
- Prevents implementation failures through systematic planning
- Manages complex integrations between new and legacy systems
- Optimizes performance to maintain operational efficiency
- Builds organizational capabilities for long-term success
- Ensures smooth transitions without business disruption

**Practice Areas**:
- **Practice 4.1**: Technology Infrastructure Assessment
- **Practice 4.2**: Integration Planning and Implementation
- **Practice 4.3**: Operational Readiness and Maintenance

### Five-Level Maturity Model

| Level | Name | Characteristics | Typical Organizations |
|-------|------|-----------------|----------------------|
| **1** | **Basic** | Ad-hoc practices, limited awareness | Most organizations today |
| **2** | **Developing** | Initial structured approach emerging | Security-conscious enterprises |
| **3** | **Established** | Systematic implementation organization-wide | Industry leaders |
| **4** | **Advanced** | Optimized processes, continuous improvement | High-security sectors |
| **5** | **Optimizing** | Industry leadership, innovation driver | Global security pioneers |

## Implementation Roadmap

### Phase 1: Discovery & Assessment (3-6 months)
- Complete QRAMM assessment across all dimensions
- Identify cryptographic assets and vulnerabilities
- Establish baseline maturity levels
- Develop executive briefing materials

### Phase 2: Planning & Prioritization (2-4 months)
- Create quantum readiness strategy
- Prioritize critical systems and data
- Allocate resources and budget
- Obtain executive approval

### Phase 3: Pilot Implementation (6-12 months)
- Deploy quantum-safe technologies in test environments
- Validate performance and compatibility
- Refine processes and procedures
- Build organizational capabilities

### Phase 4: Enterprise Rollout (12-24 months)
- Systematic deployment across organization
- Continuous monitoring and optimization
- Regular maturity reassessment
- Industry collaboration and knowledge sharing

## Scoring System & Methodology

### Assessment Structure
- **120 Total Questions**: Complete assessment framework
- **30 Questions per Dimension**: In-depth evaluation of each area
- **10 Questions per Practice**: Detailed assessment of 12 practices
- **4 Answer Options**: Each question has 4 options mapping to 5 maturity levels

### Scoring Calculation
The toolkit workbook calculates the scores. The [Scoring Methodology](../framework/scoring-methodology.md) describes that calculation in full, with the practice weights and a worked example.

Each question is scored from 1 to 4, the number of the selected option. A question with no answer is left out of the calculation. A practice score combines the average of the answered Foundation questions (60 percent) and the average of the answered Advanced questions (40 percent):

```
Practice Score = (average of the answered Foundation questions × 0.6)
               + (average of the answered Advanced questions × 0.4)
```

A dimension score is the weighted sum of its three practice scores. Each practice has a fixed weight, and the three weights in a dimension add up to 1.00. The weights are listed in the [Scoring Methodology](../framework/scoring-methodology.md#dimension-level-scoring).

```
Dimension Score = (Practice 1 Score × Weight 1)
                + (Practice 2 Score × Weight 2)
                + (Practice 3 Score × Weight 3)
```

The overall score is the average of the four dimension scores:

```
Overall Score = (Dimension 1 + Dimension 2 + Dimension 3 + Dimension 4) ÷ 4
```

The toolkit's Scorecard labels each dimension score and the overall score with a maturity level, using the thresholds below and the unadjusted scores.

### Maturity Thresholds
- **Level 1 (Basic)**: Score below 1.5
- **Level 2 (Developing)**: Score 1.5 to below 2.5
- **Level 3 (Established)**: Score 2.5 to below 3.5
- **Level 4 (Advanced)**: Score 3.5 to 4.0

A dimension or overall score of 4.0 is labelled Advanced. The Scorecard does not label a dimension or overall score Level 5 (Optimizing), and its Maturity Distribution chart sorts the practice scores with the same cut-offs, so a practice score of 4 is counted as Advanced. See [Maturity Level Interpretation](../framework/scoring-methodology.md#maturity-level-interpretation) in the scoring methodology.

## QRAMM Assessment Toolkit

The Excel-based QRAMM Assessment Toolkit is available for download. This toolkit features:
- **Automated Scoring**: Instant calculation of raw and weighted scores across all dimensions
- **Dynamic Scorecards**: Professional visualizations including charts, graphs, and maturity distribution
- **Organization Profile Multiplier**: Risk-adjusted scoring based on your industry and context
- **Compliance Mapping**: Automatic mapping to 8 major frameworks (NIST, CMMC, ISO, etc.)
- **120 Assessment Questions**: Complete coverage across 4 dimensions and 12 practices
- **Executive Reporting**: Board-ready dashboards with benchmarking and recommendations

[**Download the Toolkit**](../toolkit/QRAMM_Assessment_Toolkit.xlsx) | [**View Sample Assessment**](../toolkit/Sample_Assessment.xlsx) | [**Read Toolkit Overview**](../toolkit/toolkit-overview.md) | [**See Toolkit Screenshots**](toolkit-visuals.md)

## Repository Structure

```
qramm/
├── framework/              # Framework documentation
│   ├── qramm-overview.md       # Executive framework summary
│   ├── maturity-levels.md      # 5-level maturity progression
│   ├── scoring-methodology.md  # Scoring system details
│   ├── compliance-mapping.md   # Standards alignment details
│   ├── pqcmm-comparison.md     # QRAMM beside the PKI Consortium PQCMM (product scale)
│   └── Complete_QRAMM_Questions.md  # All 120 assessment questions
├── toolkit/                # Assessment tools
│   ├── QRAMM_Assessment_Toolkit.xlsx  # Main Excel assessment tool
│   ├── Sample_Assessment.xlsx         # Pre-filled example
│   └── toolkit-overview.md            # Feature documentation
├── implementation/         # Implementation guidance
│   └── getting-started.md      # Getting started guide
├── templates/              # Ready-to-use templates
│   ├── executive-report-template.md
│   ├── asset-inventory-template.md
│   ├── vendor-questionnaire-template.md
│   └── evidence-collection-template.md
├── docs/                   # Overview, FAQ and toolkit screenshots
├── assets/                 # Visual assets
│   └── toolkit-visuals/        # Scorecard and compliance screenshots
└── toolkit-specs/          # Technical specifications (internal)
```

## Regulatory Compliance & Standards

### Standards Alignment
The QRAMM Toolkit maps to 8 major frameworks and standards:

| Framework | Description |
|-----------|-------------|
| **NIST PQC** | NIST Post-Quantum Cryptography Standards |
| **NIST CSF** | NIST Cybersecurity Framework |
| **CMMC** | Cybersecurity Maturity Model Certification |
| **FISMA** | Federal Information Security Modernization Act |
| **FedRAMP** | Federal Risk and Authorization Management Program |
| **ISO 27001** | Information security management |
| **SOC 2** | AICPA System and Organization Controls report for service organizations |
| **CIS Controls** | Center for Internet Security Critical Security Controls |

## Framework Development

### Leadership Team

**Emily (Stamm) Fane** - *Author*  
VP of CSNP Board  
[LinkedIn](https://www.linkedin.com/in/emilyfane/)

**Abdel Fane** - *Co-Author*  
Executive Director of CSNP  
[LinkedIn](https://www.linkedin.com/in/abdelsyfane/)

**Organization**: [CyberSecurity NonProfit (CSNP)](https://csnp.org)
