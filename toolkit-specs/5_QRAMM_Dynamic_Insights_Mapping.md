# QRAMM Dynamic Insights Mapping
*All text mappings for strengths, weaknesses, and contextual recommendations*

## Practice Strength Descriptions (Score ≥ 3.6)

| Practice ID | Practice Name | Strength Description |
|-------------|---------------|---------------------|
| CVI-1 | Cryptographic Discovery | Comprehensive cryptographic asset inventory with automated discovery, real-time updates, and complete visibility across all environments |
| CVI-2 | Vulnerability Assessment | Advanced quantum threat detection with continuous monitoring, automated risk scoring, and proactive vulnerability remediation |
| CVI-3 | Dependency Mapping | Complete cryptographic dependency visualization with impact analysis, migration planning, and automated relationship tracking |
| SGRM-1 | Leadership & Governance | Strong executive commitment with dedicated quantum security team, board-level oversight, and strategic investment |
| SGRM-2 | Policy Framework | Comprehensive quantum security policies with clear accountability, regular updates, and organization-wide enforcement |
| SGRM-3 | Risk Management | Integrated quantum risk framework with quantified impacts, continuous monitoring, and data-driven decision making |
| DPE-1 | Data Classification | Strategic data categorization with quantum risk scoring, automated classification, and protection requirement mapping |
| DPE-2 | PQC Implementation | Advanced quantum-safe cryptography deployment with algorithm agility, performance optimization, and seamless integration |
| DPE-3 | Lifecycle Management | Mature crypto lifecycle processes with automated rotation, certificate management, and smooth algorithm transitions |
| ITR-1 | Infrastructure Assessment | Thorough infrastructure evaluation with detailed gap analysis, modernization roadmap, and resource optimization |
| ITR-2 | Implementation Planning | Strategic quantum transition planning with phased approach, risk mitigation, and minimal business disruption |
| ITR-3 | Operational Readiness | Excellent operational capabilities with 24/7 monitoring, incident response, and continuous improvement culture |

## Practice Weakness Descriptions (Score < 2.6)

| Practice ID | Practice Name | Weakness Description | Risk Level |
|-------------|---------------|---------------------|------------|
| CVI-1 | Cryptographic Discovery | Limited or no cryptographic asset visibility creating dangerous blind spots for quantum threats | HIGH |
| CVI-2 | Vulnerability Assessment | Inadequate quantum threat assessment leaving organization exposed to "harvest now, decrypt later" attacks | CRITICAL |
| CVI-3 | Dependency Mapping | Poor understanding of cryptographic dependencies preventing effective migration planning | HIGH |
| SGRM-1 | Leadership & Governance | Lack of executive awareness and commitment resulting in insufficient resources and priority | HIGH |
| SGRM-2 | Policy Framework | Missing or outdated policies creating confusion and inconsistent quantum security practices | MODERATE |
| SGRM-3 | Risk Management | No quantum risk integration leaving organization unprepared for cryptographic failures | CRITICAL |
| DPE-1 | Data Classification | Poor data categorization preventing appropriate quantum protection measures | HIGH |
| DPE-2 | PQC Implementation | No quantum-safe cryptography deployment leaving sensitive data vulnerable | CRITICAL |
| DPE-3 | Lifecycle Management | Manual or ad-hoc processes creating security gaps during transitions | HIGH |
| ITR-1 | Infrastructure Assessment | Unknown infrastructure readiness blocking quantum security initiatives | MODERATE |
| ITR-2 | Implementation Planning | No transition strategy risking failed implementations and business disruption | HIGH |
| ITR-3 | Operational Readiness | Inadequate operational capabilities preventing effective quantum security management | HIGH |

## Quick Win Actions by Score Range

| Practice | Score 0-1.5 | Score 1.6-2.5 | Score 2.6-3.5 |
|----------|-------------|---------------|---------------|
| CVI-1 | Run discovery pilot on critical systems (1 week) | Expand discovery to all production (2 weeks) | Automate discovery processes (3 weeks) |
| CVI-2 | Conduct quantum threat briefing (2 days) | Implement basic vulnerability scanning (2 weeks) | Add threat intelligence feeds (3 weeks) |
| CVI-3 | Map top 10 critical dependencies (1 week) | Document all system dependencies (3 weeks) | Implement dependency tracking (4 weeks) |
| SGRM-1 | Schedule executive quantum briefing (3 days) | Form quantum task force (1 week) | Establish steering committee (2 weeks) |
| SGRM-2 | Draft initial quantum policy (1 week) | Review and approve policies (2 weeks) | Implement policy training (3 weeks) |
| SGRM-3 | Add quantum to risk register (3 days) | Quantify quantum risks (2 weeks) | Integrate into ERM (4 weeks) |
| DPE-1 | Classify top 20% of data (1 week) | Expand to 80% coverage (3 weeks) | Automate classification (4 weeks) |
| DPE-2 | Test PQC algorithms (2 weeks) | Pilot on non-critical systems (4 weeks) | Plan production rollout (6 weeks) |
| DPE-3 | Document current processes (1 week) | Define lifecycle procedures (2 weeks) | Implement automation (4 weeks) |
| ITR-1 | Audit critical infrastructure (1 week) | Assess full environment (3 weeks) | Create modernization plan (4 weeks) |
| ITR-2 | Create high-level roadmap (1 week) | Develop detailed plan (3 weeks) | Finalize with stakeholders (4 weeks) |
| ITR-3 | Define operational procedures (1 week) | Train operations team (2 weeks) | Implement monitoring (3 weeks) |

## Business Impact Statements

| Dimension | Low Score Impact | High Score Benefit |
|-----------|------------------|-------------------|
| CVI | Blind to quantum threats, unable to prioritize protection efforts, risk of sudden cryptographic failure | Complete visibility enables proactive protection, efficient resource allocation, and confident decision-making |
| SGRM | Uncoordinated efforts waste resources, compliance failures, lack of accountability for quantum readiness | Strong governance ensures adequate investment, clear accountability, and sustainable quantum security program |
| DPE | Sensitive data exposed to quantum attacks, regulatory non-compliance, potential data breaches | Robust protection maintains confidentiality, ensures compliance, and protects organizational reputation |
| ITR | Technical debt prevents implementation, integration failures, operational disruptions | Modern infrastructure enables smooth transitions, maintains availability, and supports business growth |

## Profile-Based Priority Recommendations

| Industry | Organization Size | Top Priority | Rationale |
|----------|------------------|--------------|-----------|
| Financial Services | Enterprise | DPE + SGRM | Protect transaction data while ensuring governance for regulatory compliance |
| Financial Services | Large/Medium | DPE + CVI | Focus on data protection and understanding cryptographic exposure |
| Financial Services | Small | DPE + ITR | Implement basic protections with managed service providers |
| Healthcare | All Sizes | DPE + SGRM | HIPAA compliance requires both protection and documented governance |
| Government | All Sizes | All Equal | Federal mandates require comprehensive approach across all dimensions |
| Defense | All Sizes | CVI + DPE | Mission-critical systems need immediate visibility and protection |
| Critical Infrastructure | Enterprise/Large | ITR + CVI | Complex systems require infrastructure readiness and asset visibility |
| Technology | All Sizes | ITR + DPE | Technical capability enables faster implementation of protections |
| Retail/Manufacturing | All Sizes | CVI + DPE | Focus on payment systems and intellectual property protection |

## Conditional Display Logic

### Executive Summary Messages
```
IF overall_score < 1.5 AND high_risk_industry:
  "CRITICAL: Your organization faces severe quantum risk exposure requiring immediate executive action"
  
IF overall_score < 2.0 AND compliance_required:
  "WARNING: Current quantum readiness threatens regulatory compliance - urgent improvements needed"
  
IF overall_score < 2.5:
  "CONCERN: Significant gaps in quantum readiness require systematic improvement program"
  
IF overall_score < 3.0:
  "PROGRESS: Foundation in place but continued investment needed for quantum resilience"
  
IF overall_score >= 3.0:
  "STRONG: Organization demonstrates quantum readiness - maintain momentum and industry leadership"
```

### Risk-Adjusted Timeline Recommendations
```
Standard Risk (multiplier < 1.1):
- Year 1: CVI + SGRM foundations
- Year 2: DPE implementation
- Year 3: ITR optimization

Medium Risk (multiplier 1.1-1.3):
- Q1-Q2: CVI + SGRM urgent
- Q3-Q4: DPE deployment
- Year 2: ITR completion

High Risk (multiplier > 1.3):
- Month 1: Executive action + CVI
- Month 2-3: SGRM + critical DPE
- Month 4-6: Full implementation
```

## Implementation Notes

1. Use VLOOKUP or INDEX/MATCH to pull descriptions based on practice scores
2. Combine with profile data for contextual recommendations
3. Update dynamically as assessment progresses
4. Show top 3 strengths and top 3 improvement areas
5. Prioritize quick wins based on effort vs. impact