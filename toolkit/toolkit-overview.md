# Our Mission
Our mission is to provide organizations with an effective and measurable way to evaluate and enhance their quantum resilience and cryptographic readiness for the post-quantum era. Developed under the CyberSecurity NonProfit (CSNP), QRAMM aims to enable organizations to confidently assess, plan, and implement quantum-safe security measures through a comprehensive self-assessment model that drives continuous improvement.

## Overview
The Quantum Readiness Assurance Maturity Model (QRAMM) is a framework designed to help organizations measure and improve their quantum readiness and cryptographic security capabilities. As quantum computing advances threaten current encryption standards, this toolkit provides a structured approach to assess your organization's current maturity level and identify critical areas requiring quantum-safe transformation.

## Framework Structure
QRAMM evaluates four critical dimensions:

1. **Cryptographic Visibility & Inventory (CVI)**
2. **Strategic Governance & Risk Management (SGRM)**
3. **Data Protection Engineering (DPE)**
4. **Implementation & Technical Readiness (ITR)**

Each dimension contains 3 specialized practices, totaling 12 core practices. Each practice is assessed through two streams:

- **Stream A (Foundation)**: Core capabilities essential for quantum readiness (60% weight)
- **Stream B (Advanced)**: Advanced capabilities and optimization opportunities (40% weight)

## Scoring System
The QRAMM toolkit uses a comprehensive scoring system that calculates both raw and weighted scores:

### Raw Scores
The Scorecard labels each raw dimension score and the raw overall score with one of four maturity levels:

- **Below 1.5**: Basic - Initial awareness and ad-hoc practices
- **1.5 to below 2.5**: Developing - Structured approaches beginning to emerge
- **2.5 to below 3.5**: Established - Systematic and consistent practices
- **3.5 to 4.0**: Advanced - Optimized processes with continuous improvement

A raw dimension or overall score of 4.0 is labelled Advanced. The Scorecard does not label a dimension or overall score Optimizing, and its Maturity Distribution chart sorts the practice scores with the same cut-offs, so a practice score of 4 is counted as Advanced. See [Maturity Level Interpretation](../framework/scoring-methodology.md#maturity-level-interpretation) in the scoring methodology.

### Weighted Scores
Your organization's unique context affects your target quantum readiness level. The Organization Profile Tab captures this context through a profile multiplier between 1.00 and 1.50 that adjusts raw scores based on:

- **Industry** (factor 0.30): how exposed your sector is to the quantum threat
- **Data sensitivity** (factor 0.25): how critical the data you protect is, and how long it must stay protected
- **Regulatory requirements** (factor 0.20): which compliance frameworks apply to you
- **Geographic scope** (factor 0.15): how many countries you operate in
- **Organization size** (factor 0.10): how large your organization is

Each answer carries a risk value of 1.0, 1.3 or 1.5, and the multiplier is the sum of risk value times factor. The answer options and the full calculation are in the [Scoring Methodology](../framework/scoring-methodology.md#profile-adjusted-score).

For example, a financial institution handling long-term sensitive data would have a higher profile multiplier than a retail business with primarily transactional data, reflecting the greater urgency and rigor required for quantum-safe transformation.

**Note on Weighted Scores**: While raw scores cap at 4.0, weighted scores can exceed 4.0 for high-risk organizations. For example, a healthcare organization with a multiplier of 1.33 and strong dimension scores could see weighted scores like 4.07, 4.54, or even 5.32. An organization with a perfect raw score (4.0) and maximum risk multiplier (1.5) would achieve a weighted score of 6.0, demonstrating exceptional quantum readiness that exceeds standard requirements. This reflects that high-risk organizations must achieve higher standards to adequately address their elevated quantum threat exposure.

This ensures that maturity targets and recommendations align with your organization's specific quantum risk profile and circumstances.

Note - Each question offers four answers, scored 1 to 4. A question you leave blank is left out of the calculation and does not count as zero, as the [Scoring Methodology](../framework/scoring-methodology.md) explains.

## Scorecard Tab Overview
The Scorecard tab provides a comprehensive view of your quantum readiness assessment results:

### Overall Results
- **Overall QRAMM Score**: Combined score across all four dimensions
- **Overall Maturity Level**: Your current quantum readiness maturity level
- **Assessment Completion Status**: Progress tracking across all 120 questions
- **Quantum Risk Timeline**: Estimated timeline for quantum threat relevance to your organization

### Dimension Scoring Summary
For each dimension:

- **Raw Score**: The dimension score calculated from assessment responses, the weighted sum of the dimension's three practice scores (see [Scoring Methodology](../framework/scoring-methodology.md#dimension-level-scoring))
- **Weighted Score**: Profile multiplier-adjusted calculation based on organizational context
- **Maturity Level**: Current dimension maturity level (Basic, Developing, Established or Advanced, from the raw score)
- **Industry Benchmark**: Comparison against similar organizations in your industry
- **Percentage**: Progress toward maximum possible score

### Visual Analytics
The Scorecard provides comprehensive visual insights including:

- **Dimension Scoring Chart**: Bar chart comparing raw scores across all four dimensions
- **Maturity Distribution**: Donut chart showing the percentage of practices at each maturity level
- **Spider/Radar Chart**: Visual comparison of your weighted scores against industry benchmarks

### Highlights and Recommendations
- **Top Strengths**: Automatically identifies your highest-scoring practices with specific achievements
- **Areas for Improvement**: Pinpoints lowest-scoring practices requiring immediate attention
- **Dynamic Recommendations**: Context-specific guidance based on your scores and organizational profile
- **Practice-Level Insights**: Detailed breakdown showing individual practice scores and maturity levels

## Assessment Approach
QRAMM provides two assessment entry points:

### Quick Assessment (12 Questions)
- **Time Investment**: 5-10 minutes
- **Purpose**: Initial quantum readiness baseline
- **Coverage**: 3 key questions per dimension
- **Output**: Executive summary with immediate priorities

### Comprehensive Assessment (120 Questions)
- **Time Investment**: 2-4 hours with stakeholder input
- **Purpose**: Complete quantum readiness evaluation
- **Coverage**: 10 detailed questions per practice (30 per dimension)
- **Output**: Detailed scorecards, gap analysis, compliance mapping, and implementation roadmap

## Compliance Mapping
QRAMM maps to 8 major frameworks and standards:

1. **NIST Post-Quantum Cryptography Standards**: Alignment with NIST's quantum-safe algorithms
2. **NIST Cybersecurity Framework (CSF)**: Core security function alignment
3. **CMMC**: Cybersecurity Maturity Model Certification requirements
4. **FISMA**: Federal Information Security Modernization Act requirements
5. **FedRAMP**: Federal Risk and Authorization Management Program controls
6. **ISO 27001**: Information security management
7. **SOC 2**: AICPA System and Organization Controls report for service organizations
8. **CIS Controls**: Center for Internet Security Critical Security Controls

## Business Value
### Immediate Benefits
- **Risk Visibility**: Clear understanding of quantum vulnerabilities
- **Strategic Planning**: Roadmap for quantum-safe transformation
- **Compliance Readiness**: Alignment with emerging quantum regulations
- **Resource Optimization**: Prioritized investment based on risk

### Long-Term Value
- **Competitive Advantage**: Early quantum readiness positioning
- **Business Continuity**: Protection against quantum-related disruptions
- **Trust Building**: Demonstrated commitment to future-proof security
- **Innovation Platform**: Foundation for quantum-safe business capabilities

## Getting Started
1. **Download the toolkit**: [QRAMM_Assessment_Toolkit.xlsx](QRAMM_Assessment_Toolkit.xlsx) in this repository is the source file. The copy at https://qramm.org/toolkit/QRAMM_Assessment_Toolkit.xlsx should be the same file; scripts/check-published-toolkit.sh compares them.
2. **Complete Organization Profile**: Define your organizational context
3. **Conduct Assessment**: Start with Quick Assessment or go directly to Comprehensive
4. **Review Results**: Analyze scorecard and identify priorities
5. **Plan Improvements**: Use recommendations to build your quantum readiness roadmap
6. **Track Progress**: Regular reassessment to measure advancement

## Support and Resources
- **Framework Documentation**: Comprehensive guides and implementation resources
- **Community Support**: Access to QRAMM user community and forums
- **Professional Services**: Expert facilitation and consulting available
- **Training Programs**: Quantum readiness education and certification

## Contact Information
**Framework Authors:**
- Emily (Stamm) Fane - Strategic Planning & Executive Engagement
- Abdel Sy Fane - Technical Implementation & Risk Assessment

**General Inquiries:** qramm@csnp.org

**Community Resources:**
- GitHub Repository: https://github.com/csnp/qramm
- Discussion Forums: GitHub Discussions
- Issue Tracking: GitHub Issues

---

**QRAMM Version**: 1.1
**Last Updated**: December 2025
**Developed by**: CyberSecurity NonProfit (CSNP)
**Website**: [https://qramm.org](https://qramm.org)