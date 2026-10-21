# QRAMM Scoring Methodology
**Comprehensive Evaluation and Interpretation Framework**

## Overview

The QRAMM scoring methodology provides a systematic approach to evaluating organizational quantum readiness across all four dimensions. This document outlines the scoring calculations, interpretation guidelines, and analysis frameworks that enable organizations to understand their current capabilities and prioritize improvement efforts.

## Scoring Structure

The QRAMM Assessment Toolkit workbook, [`toolkit/QRAMM_Assessment_Toolkit.xlsx`](../toolkit/QRAMM_Assessment_Toolkit.xlsx), is the reference for how QRAMM scores are calculated. This section describes the calculation that workbook performs.

### Assessment Question Scoring

Each assessment question uses a **4-point scale** corresponding to the response options:

- **Score 1**: Lowest capability level (typically "No process exists" or equivalent)
- **Score 2**: Basic capability level (typically informal or limited processes)
- **Score 3**: Intermediate capability level (typically structured or systematic approaches)
- **Score 4**: Highest capability level (typically advanced or comprehensive implementations)

A question with no answer is left out of the calculation. It does not count as zero.

### Practice-Level Scoring

Each practice contains **10 questions**: 5 in Stream A (Foundation) and 5 in Stream B (Advanced). Foundation answers count for 60 percent of the practice score and Advanced answers for 40 percent.

**Practice Score Calculation:**
```
Practice Score = (average of the answered Foundation questions × 0.6)
               + (average of the answered Advanced questions × 0.4)
```

Each average uses only the questions that have an answer. A practice has a score once at least one Foundation question and at least one Advanced question are answered. Until then the toolkit shows "-" for that practice.

**Example Calculation:**
- Stream A (Foundation) scores: 3, 2, 3, 4, 2, average 2.8
- Stream B (Advanced) scores: 2, 3, 2, 3, 1, average 2.2
- Practice Score = (2.8 × 0.6) + (2.2 × 0.4) = 1.68 + 0.88 = 2.56

### Dimension-Level Scoring

Each dimension contains **3 practices**. The dimension score is the weighted sum of its three practice scores. Each practice has a fixed weight, and the three weights in a dimension add up to 1.00.

**Dimension Score Calculation:**
```
Dimension Score = (Practice 1 Score × Weight 1)
                + (Practice 2 Score × Weight 2)
                + (Practice 3 Score × Weight 3)
```

**Practice weights:**

| Dimension | First practice | Second practice | Third practice |
|-----------|----------------|-----------------|----------------|
| 1. Cryptographic Visibility & Inventory (CVI) | 1.1: 0.35 | 1.2: 0.35 | 1.3: 0.30 |
| 2. Strategic Governance & Risk Management (SGRM) | 2.1: 0.40 | 2.2: 0.35 | 2.3: 0.25 |
| 3. Data Protection Engineering (DPE) | 3.1: 0.40 | 3.2: 0.35 | 3.3: 0.25 |
| 4. Implementation & Technical Readiness (ITR) | 4.1: 0.35 | 4.2: 0.35 | 4.3: 0.30 |

A dimension has a score once all three of its practices have a score. Because each practice carries a fixed share, a strong practice can lift the dimension score while another practice stays low. Read the practice scores, not only the dimension score, to find gaps.

**Example Calculation:**
- Practice 1.1 Score: 3.2 (weight 0.35)
- Practice 1.2 Score: 2.8 (weight 0.35)
- Practice 1.3 Score: 3.5 (weight 0.30)
- Dimension 1 Score = (3.2 × 0.35) + (2.8 × 0.35) + (3.5 × 0.30) = 1.12 + 0.98 + 1.05 = 3.15

### Overall QRAMM Score

The overall organizational score is the average of the four dimension scores. The organization profile does not change it.

**Overall QRAMM Score Calculation:**
```
Overall Score = (Dimension 1 + Dimension 2 + Dimension 3 + Dimension 4) ÷ 4
```

The toolkit shows an overall score once all four dimensions have a score.

**Example Calculation:**
- Dimension 1 (CVI): 3.15
- Dimension 2 (SGRM): 3.1
- Dimension 3 (DPE): 2.5
- Dimension 4 (ITR): 2.9
- Overall QRAMM Score = (3.15 + 3.1 + 2.5 + 2.9) ÷ 4 = 2.9125

### Profile-adjusted score

The toolkit also shows a profile-adjusted score for each dimension. It is the dimension score multiplied by a profile multiplier between 1.00 and 1.50. The multiplier comes from five answers on the toolkit's Profile tab, and it is higher for organizations with more exposure to quantum risk.

**Adjusted score calculation:**
```
Adjusted Dimension Score = Dimension Score × Profile Multiplier
```

**Profile multiplier calculation:**

Each profile answer has a risk value of 1.0, 1.3 or 1.5, and each of the five profile questions has a fixed factor:

| Profile question | Factor | Risk value 1.5 | Risk value 1.3 | Risk value 1.0 |
|------------------|--------|----------------|----------------|----------------|
| Industry | 0.30 | Financial Services, Healthcare, Defense/Military | Technology, Energy/Utilities | Manufacturing, Retail, Government, Education, Telecommunications, Transportation, Other |
| Data sensitivity | 0.25 | Highly Classified/Secret | Confidential/Sensitive | Internal Use Only, Public/Non-sensitive |
| Regulatory requirements | 0.20 | Multiple Major Frameworks | Single Major Framework | Industry Standards Only, Minimal Requirements |
| Geographic scope | 0.15 | Global (10+ countries) | Multi-region (3-9 countries) | Regional (2 countries), Single Country |
| Organization size | 0.10 | Fortune 500/Global Enterprise | Large Enterprise (1000+ employees) | Mid-Market (100-999 employees), Small Business (under 100 employees) |

```
Profile Multiplier = sum of (risk value × factor) for the five answers,
                     rounded to 2 decimal places
```

The factors add up to 1.00, so the multiplier is 1.00 when every answer has a risk value of 1.0 and 1.50 when every answer has a risk value of 1.5. The toolkit calculates it once all five profile questions are answered.

**How to read the adjusted score:**
- It can be higher than 4, the top of the question scale. A dimension score of 3.4 with a multiplier of 1.5 gives an adjusted score of 5.1. In the sample assessment, Dimension 4 has a score of 3.958 and an adjusted score of 3.958 × 1.23 = 4.86834.
- It is not a maturity level. Maturity levels and the overall QRAMM score use the unadjusted scores.
- It is not a headline figure. Report the overall score, the dimension scores and their maturity levels as the result of an assessment. The adjusted score shows the same dimension score scaled by the organization's risk profile.
- The toolkit's Scorecard also shows an adjusted overall score, the average of the four adjusted dimension scores. The same points apply to it.

### Worked example from the sample assessment

The toolkit ships with a completed sample assessment. The example below follows Dimension 1 of that sample from its answers to its scores. The script `scripts/check-scoring-example.py` checks the practice scores, the dimension score and the multiplier shown here against the values saved in the sample workbook.

Worked example from [`toolkit/Sample_Assessment.xlsx`](../toolkit/Sample_Assessment.xlsx), Dimension 1 (CVI):

```text
Profile: Healthcare, Confidential/Sensitive data, Minimal Requirements,
         Regional (2 countries), Mid-Market (100-999 employees)

Practice 1.1   Foundation answers 3, 2, 2, 2, 4   average 2.6
               Advanced answers   1, 4, 4, 4, 4   average 3.4
Practice 1.2   Foundation answers 4, 2, 3, 3, 1   average 2.6
               Advanced answers   1, 1, 2, 3, 1   average 1.6
Practice 1.3   Foundation answers 2, 3, 4, 2, 3   average 2.8
               Advanced answers   1, 4, 2, 3, 1   average 2.2

Practice 1.1 score  = 2.6 × 0.6 + 3.4 × 0.4                    = 2.92
Practice 1.2 score  = 2.6 × 0.6 + 1.6 × 0.4                    = 2.2
Practice 1.3 score  = 2.8 × 0.6 + 2.2 × 0.4                    = 2.56
CVI score           = 2.92 × 0.35 + 2.2 × 0.35 + 2.56 × 0.30  = 2.56

Profile sum         = 1.5 × 0.30 + 1.3 × 0.25 + 1.0 × 0.20
                      + 1.0 × 0.15 + 1.0 × 0.10                = 1.225
Profile multiplier  = 1.225 rounded to 2 decimal places        = 1.23
Adjusted CVI score  = 2.56 × 1.23                              = 3.1488
```

The CVI score of 2.56 falls in the Established range in the table below.

## Maturity Level Interpretation

### Score Ranges and Maturity Levels

| Score Range | Maturity Level | Interpretation |
|-------------|----------------|----------------|
| Below 1.5 | **Level 1: Basic** | Initial awareness and ad-hoc practices |
| 1.5 to below 2.5 | **Level 2: Developing** | Structured approaches beginning to emerge |
| 2.5 to below 3.5 | **Level 3: Established** | Systematic and consistent practices |
| 3.5 to 4.0 | **Level 4: Advanced** | Optimized processes with continuous improvement |

The toolkit's Scorecard labels each dimension score and the overall score with these four levels, using the unadjusted scores. A dimension or overall score of 4.0 is labelled Advanced. The Scorecard's Maturity Distribution chart (Scorecard!L21:M25) sorts the 12 practice scores into the same four levels with the same cut-offs, so a practice score of 4 is counted as Advanced. The chart's fifth category, Incomplete Assessment, counts the practices that do not have a score yet.

### Detailed Maturity Level Descriptions

#### Level 1: Basic (below 1.5)
**Characteristics:**
- Limited awareness of quantum threats and their implications
- Ad-hoc or informal approaches to cryptographic management
- Reactive rather than proactive security measures
- Minimal documentation or systematic processes

**Typical Organizational State:**
- Beginning to recognize quantum threats as a future concern
- Cryptographic assets managed informally without comprehensive inventory
- Leadership awareness limited to high-level threat briefings
- No formal quantum readiness planning or resource allocation

**Immediate Priorities:**
- Establish basic cryptographic asset visibility
- Develop foundational policies and governance structures
- Build executive awareness and commitment
- Create initial quantum readiness planning processes

#### Level 2: Developing (1.5 to below 2.5)
**Characteristics:**
- Growing awareness and initial systematic approaches
- Basic processes documented but not fully implemented
- Some organizational structure for quantum readiness
- Limited but increasing investment in quantum-safe capabilities

**Typical Organizational State:**
- Formal recognition of quantum threats in security strategies
- Basic cryptographic inventory covering critical systems
- Initial policy frameworks addressing quantum risks
- Project-level funding for quantum readiness activities

**Key Focus Areas:**
- Expand cryptographic visibility across all systems
- Develop comprehensive risk assessment capabilities
- Strengthen governance structures and policy frameworks
- Build technical capabilities for quantum-safe implementations

#### Level 3: Established (2.5 to below 3.5)
**Characteristics:**
- Systematic and consistent quantum readiness practices
- Comprehensive processes with regular execution
- Integrated approach across multiple organizational functions
- Sustained investment with measurable progress

**Typical Organizational State:**
- Complete cryptographic asset inventory with vulnerability classification
- Established governance structures with clear accountability
- Systematic risk assessment and prioritization processes
- Ongoing quantum-safe implementation projects with progress tracking

**Optimization Opportunities:**
- Enhance automation and continuous monitoring capabilities
- Develop advanced analytics and predictive modeling
- Expand third-party and supply chain risk management
- Strengthen integration with business planning and operations

#### Level 4: Advanced (3.5 to 4.0)
**Characteristics:**
- Optimized processes with continuous improvement
- Advanced analytics and predictive capabilities
- Proactive risk management with scenario planning
- Mature practices with measurable outcomes

**Typical Organizational State:**
- Automated cryptographic discovery and vulnerability management
- Advanced risk modeling with business impact quantification
- Comprehensive vendor and supply chain quantum readiness programs
- Integrated quantum readiness across all business functions

**Strategic Focus:**
- Drive innovation in quantum security practices
- Contribute to industry standards and best practices
- Develop new capabilities and technologies
- Establish thought leadership in quantum readiness

#### Level 5: Optimizing
The toolkit does not assign this level to a dimension score or the overall score, and its Maturity Distribution chart counts a practice score of 4 as Advanced.

**Characteristics:**
- Mature practices with continuous innovation
- Comprehensive integration across all organizational aspects
- Significant contribution to industry knowledge and standards
- Strategic advantage through quantum readiness leadership

**Typical Organizational State:**
- Fully automated and intelligent quantum risk management
- Industry leadership in quantum security innovation
- Comprehensive quantum-safe ecosystem including partners and suppliers
- Recognition as a quantum readiness thought leader and standard setter

## Assessment Analysis Framework

### Gap Analysis

**Primary Gap Identification:**
1. **Practice-Level Gaps**: Identify practices scoring below organizational targets
2. **Stream-Level Gaps**: Compare Foundation (Stream A) vs Advanced (Stream B) capabilities
3. **Dimension-Level Gaps**: Identify dimensions requiring focused improvement
4. **Question-Level Gaps**: Pinpoint specific capability deficiencies

**Gap Prioritization Criteria:**
- **Business Impact**: Effect on critical business functions and revenue
- **Risk Exposure**: Quantum vulnerability and potential damage
- **Implementation Complexity**: Resource requirements and technical difficulty
- **Timeline Constraints**: Urgency based on quantum threat progression

### Improvement Planning

**Strategic Improvement Approach:**
1. **Foundation First**: Ensure strong Stream A capabilities before advancing Stream B
2. **Balanced Development**: Address the lowest practice scores in each dimension, since a strong practice can hide a weak one in the weighted dimension score
3. **Risk-Based Prioritization**: Focus on areas with highest quantum vulnerability
4. **Incremental Progress**: Plan staged improvements with measurable milestones

**Resource Allocation Guidelines:**
- **Level 1 to 2**: Focus on basic capability development and process establishment
- **Level 2 to 3**: Invest in systematic implementation and comprehensive coverage
- **Level 3 to 4**: Develop advanced automation and optimization capabilities
- **Level 4 to 5**: Drive innovation and industry leadership initiatives

### Progress Monitoring

**Key Performance Indicators (KPIs):**
- **Overall QRAMM Score**: Organizational quantum readiness level
- **Dimension Scores**: Capability development across core areas
- **Practice Improvement Rate**: Speed of capability advancement
- **Gap Closure Progress**: Reduction in identified capability deficiencies

**Monitoring Frequency:**
- **Quarterly Reviews**: Track progress on improvement initiatives
- **Annual Assessments**: Comprehensive evaluation of quantum readiness advancement
- **Milestone Evaluations**: Targeted assessment following major improvement projects
- **Continuous Monitoring**: Real-time tracking of key quantum readiness metrics

## Interpretation Guidelines

### Score Interpretation Best Practices

**Individual Scores:**
- **Focus on Patterns**: Look for consistent strengths and weaknesses across related questions
- **Consider Context**: Evaluate scores relative to organizational size, complexity, and industry
- **Identify Outliers**: Investigate unusually high or low scores for accuracy and insights
- **Validate Results**: Confirm scores align with observable organizational capabilities

**Comparative Analysis:**
- **Industry Benchmarking**: Compare scores with similar organizations and industry standards
- **Peer Comparison**: Evaluate relative position within competitive landscape
- **Standards Alignment**: Assess conformance with relevant regulatory and compliance requirements
- **Best Practice Gaps**: Identify opportunities to adopt leading practices

### Common Scoring Patterns

**Unbalanced Development:**
- **High Advanced, Low Foundation**: Advanced capabilities without solid foundations
- **High Foundation, Low Advanced**: Strong basics but limited optimization
- **Dimension Imbalances**: Strong performance in some dimensions, weak in others

**Typical Improvement Trajectories:**
- **Technical-First Organizations**: Strong in Dimensions 1 & 3 (CVI & DPE), weaker in 2 & 4 (SGRM & ITR)
- **Governance-Strong Organizations**: Strong in Dimension 2 (SGRM), developing technical capabilities
- **Implementation-Focused Organizations**: Strong in Dimension 4 (ITR), building comprehensive foundations

### Executive Reporting Guidelines

**Executive Summary Structure:**
1. **Overall QRAMM Score and Maturity Level**
2. **Key Strengths and Competitive Advantages**
3. **Critical Gaps and Risk Exposures**
4. **Recommended Priority Actions**
5. **Resource Requirements and Timeline**
6. **Expected Business Outcomes and ROI**

**Dashboard Metrics:**
- **Traffic Light Indicators**: Red/Yellow/Green status for each dimension
- **Progress Tracking**: Improvement trends over time
- **Risk Exposure**: Quantum vulnerability levels and business impact
- **Investment Tracking**: Resource allocation and utilization efficiency

## Advanced Analytics

### Predictive Modeling

**Capability Progression Models:**
- **Linear Progression**: Steady improvement based on consistent investment
- **Accelerated Development**: Rapid advancement through focused initiatives
- **Plateau Analysis**: Identification of potential improvement barriers
- **Breakthrough Opportunities**: Areas where strategic investment can yield disproportionate gains

**Risk Projection Models:**
- **Quantum Threat Timeline**: Integration with quantum computing advancement projections
- **Vulnerability Exposure**: Analysis of current gaps against evolving threat landscape
- **Business Impact Scenarios**: Quantitative assessment of potential quantum-related disruptions
- **Mitigation Effectiveness**: Evaluation of improvement initiatives against risk reduction

### Optimization Analysis

**Resource Optimization:**
- **Efficiency Analysis**: Cost per improvement point across different dimensions
- **Impact Maximization**: Highest-value improvements for strategic objectives
- **Constraint Management**: Optimal improvement sequencing given resource limitations
- **ROI Modeling**: Financial return on quantum readiness investments

**Strategic Positioning:**
- **Competitive Analysis**: Quantum readiness relative to industry peers
- **Market Advantage**: Potential business benefits from superior quantum preparedness
- **Partnership Opportunities**: Collaboration potential based on complementary capabilities
- **Innovation Leadership**: Opportunities to drive industry advancement

## Quality Assurance

### Assessment Validation

**Consistency Checks:**
- **Internal Consistency**: Verification that related questions have logically consistent scores
- **Evidence Alignment**: Confirmation that scores are supported by documented evidence
- **Cross-Dimension Validation**: Checking for logical relationships between dimension scores
- **Stakeholder Consensus**: Agreement among assessment participants on scoring rationale

**Accuracy Verification:**
- **Documentation Review**: Validation of scores against organizational artifacts
- **Process Observation**: Direct verification of claimed capabilities and processes
- **Technical Testing**: Validation of technical capabilities through hands-on evaluation
- **Third-Party Validation**: Independent verification of assessment results

### Scoring Reliability

**Inter-Rater Reliability:**
- **Multiple Assessors**: Evaluation by different organizational representatives
- **Scoring Calibration**: Training and alignment on scoring criteria interpretation
- **Consensus Building**: Structured discussion to resolve scoring disagreements
- **Quality Review**: Expert review of assessment results for accuracy and completeness

**Temporal Consistency:**
- **Baseline Establishment**: Initial assessment serving as reference point
- **Progress Tracking**: Consistent methodology for measuring improvement over time
- **Regression Analysis**: Identification and investigation of capability decreases
- **Trend Validation**: Confirmation that score changes reflect actual capability evolution

## Implementation Support

### Assessment Facilitation

**Structured Assessment Process:**
1. **Preparation Phase**: Stakeholder identification and documentation gathering
2. **Evaluation Phase**: Systematic scoring across all dimensions and practices
3. **Validation Phase**: Evidence review and consensus building
4. **Analysis Phase**: Gap identification and improvement planning
5. **Reporting Phase**: Results documentation and stakeholder communication

**Facilitation Best Practices:**
- **Multi-Stakeholder Participation**: Include representatives from all relevant functions
- **Evidence-Based Scoring**: Require documentation or demonstration to support scores
- **Collaborative Discussion**: Encourage dialogue to build consensus and understanding
- **Objective Evaluation**: Maintain focus on actual capabilities rather than aspirational goals

### Improvement Planning Support

**Capability Development Roadmaps:**
- **Phased Approach**: Structured progression through maturity levels
- **Quick Wins**: Identification of high-impact, low-effort improvements
- **Strategic Initiatives**: Major capability development programs with long-term impact
- **Continuous Improvement**: Ongoing optimization and advancement processes

**Implementation Guidance:**
- **Best Practice Templates**: Proven approaches for capability development
- **Resource Planning**: Guidance on staffing, budget, and technology requirements
- **Change Management**: Support for organizational transformation initiatives
- **Success Metrics**: KPIs and measurement approaches for tracking progress

---

## Conclusion

The QRAMM scoring methodology provides a comprehensive framework for evaluating and improving organizational quantum readiness. Through systematic scoring, analysis, and improvement planning, organizations can develop the capabilities necessary to thrive in the quantum era.

**Key Success Factors:**
- **Honest Assessment**: Accurate evaluation of current capabilities
- **Balanced Development**: Attention to all dimensions and practices
- **Evidence-Based Scoring**: Objective evaluation supported by documentation
- **Continuous Improvement**: Regular reassessment and capability advancement

**Expected Outcomes:**
- **Clear Understanding**: Comprehensive view of quantum readiness capabilities
- **Prioritized Improvement**: Risk-based focus on highest-impact enhancements
- **Measurable Progress**: Tracking advancement toward quantum resilience
- **Strategic Advantage**: Competitive positioning through superior quantum preparedness

*This scoring methodology enables organizations to transform quantum readiness from an abstract concept into measurable capabilities with clear improvement pathways.*

---

**Document Version**: 1.1  
**Last Updated**: October 16, 2026  
**Authors**: Emily (Stamm) Fane, Abdel Sy Fane  
**Organization**: CyberSecurity NonProfit (CSNP)  
**Framework**: Quantum Readiness Assurance Maturity Model (QRAMM)
