#!/usr/bin/env python3
"""
Script to add the 6 missing questions to complete the 120-question assessment
"""

def add_missing_questions():
    # Read the current assessment
    with open('/Users/decimai/workspace/qramm-repo/assessment/full-assessment.md', 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Missing question 1.3.9
    question_1_3_9 = """### Question 1.3.9: How does your organization evaluate cryptographic dependencies for architectural complexity and transition fragility?

**Explanation**: This assesses whether your organization evaluates how tightly coupled cryptographic components are across systems, and how susceptible the architecture is to cascading failures or upgrade bottlenecks during quantum-safe transitions.

**Options**:
- No evaluation of cryptographic complexity or fragility
- Informal review of major dependencies without complexity analysis
- Structured assessment of dependency complexity and upgrade risk
- Simulations and metrics guide architecture hardening and migration design

**Evidence to Look For**:
- Crypto dependency diagrams annotated with shared libraries, protocols, or trust anchors that highlight upgrade bottlenecks
- Architecture review records identifying fragile crypto trust paths or legacy chokepoints
- Complexity scores or dashboards tracking depth of cryptographic chains, shared asset reuse, and decoupling progress
- Logs showing crypto-related changes that triggered cascading impacts across services

"""

    # Missing question 1.3.10
    question_1_3_10 = """### Question 1.3.10: How does your organization optimize cryptographic dependencies for migration efficiency and system resilience?

**Explanation**: This examines how your organization designs and refactors cryptographic dependencies to enable efficient quantum-safe transitions while maintaining system resilience and minimizing migration complexity.

**Options**:
- No optimization of cryptographic dependencies for migration efficiency
- Ad-hoc decoupling efforts when migration bottlenecks are encountered
- Systematic optimization of crypto dependencies to reduce migration complexity and improve resilience
- Automated dependency optimization with continuous monitoring and improvement of migration readiness

**Evidence to Look For**:
- Architecture refactoring projects aimed at reducing cryptographic coupling and migration bottlenecks
- Design patterns or guidelines that promote cryptographic agility and modular dependency structures
- Metrics tracking dependency optimization progress and migration efficiency improvements
- Automated tools that analyze and recommend dependency optimizations for quantum-safe transitions

"""

    # Missing question 2.1.9
    question_2_1_9 = """### Question 2.1.9: How does your organization integrate quantum readiness considerations into enterprise architecture and technology planning?

**Explanation**: This examines how quantum security requirements and cryptographic agility are systematically incorporated into enterprise architecture decisions, technology roadmaps, and strategic planning processes.

**Options**:
- Quantum readiness considerations are not integrated into architecture or technology planning
- Quantum requirements are considered informally during major architecture decisions
- Quantum readiness is systematically integrated into enterprise architecture and technology planning processes
- Quantum security drives architecture and technology decisions with automated assessment and optimization

**Evidence to Look For**:
- Architecture review processes that include quantum readiness and cryptographic agility requirements
- Technology roadmaps that explicitly account for quantum-safe transitions and implementation timelines
- Architecture standards and patterns that promote cryptographic agility and quantum readiness
- Enterprise architecture artifacts that document quantum security requirements and compliance mapping

"""

    # Missing question 2.1.10
    question_2_1_10 = """### Question 2.1.10: How does your organization foster a culture of quantum security awareness and continuous learning?

**Explanation**: This assesses how your organization builds and maintains organizational capability for quantum security through culture development, continuous learning, knowledge sharing, and workforce development initiatives.

**Options**:
- No quantum security culture or learning initiatives exist
- Basic awareness training provided with limited reinforcement or follow-up
- Structured culture and learning programs promote quantum security awareness and capability development
- Comprehensive culture of quantum security excellence with continuous learning, innovation, and knowledge leadership

**Evidence to Look For**:
- Quantum security awareness training programs for different organizational roles and levels
- Internal knowledge sharing forums, workshops, or communities of practice focused on quantum readiness
- Career development paths and competency frameworks that include quantum security skills
- Recognition and incentive programs that reward quantum security contributions and learning

"""

    # Missing question 2.3.10
    question_2_3_10 = """### Question 2.3.10: How does your organization build resilient supply chain architectures that minimize quantum risk exposure?

**Explanation**: This examines how your organization designs supply chain relationships and technical architectures to minimize quantum-related risks, including vendor diversification, cryptographic isolation, and supply chain resilience strategies.

**Options**:
- No consideration of quantum risks in supply chain architecture design
- Basic vendor diversification with limited quantum-specific considerations
- Structured supply chain architecture that explicitly addresses quantum risks and vendor dependencies
- Resilient supply chain architecture with quantum-aware design, automated risk monitoring, and adaptive response capabilities

**Evidence to Look For**:
- Supply chain architecture documents that address quantum risk exposure and mitigation strategies
- Vendor diversification strategies that consider quantum readiness and cryptographic capabilities
- Technical isolation mechanisms that limit quantum risk propagation across supply chain relationships
- Supply chain resilience planning that includes quantum threat scenarios and response strategies

"""

    # Missing question 3.2.10
    question_3_2_10 = """### Question 3.2.10: How does your organization integrate storage security with broader data lifecycle and quantum readiness strategies?

**Explanation**: This examines how your organization aligns storage security measures with comprehensive data protection strategies and quantum readiness planning to ensure consistent protection across the entire data lifecycle.

**Options**:
- Storage security operates independently without integration with broader data protection strategies
- Basic coordination between storage security and data lifecycle management
- Storage security is systematically integrated with data lifecycle and quantum readiness strategies
- Comprehensive integration of storage security with adaptive data protection and quantum readiness across all environments

**Evidence to Look For**:
- Data lifecycle policies that explicitly address storage security requirements and quantum protection needs
- Integration between storage security controls and broader data protection governance frameworks
- Coordination between storage security teams and quantum readiness initiatives across the organization
- Unified metrics and reporting that track storage security effectiveness within broader data protection objectives

"""

    # Find insertion points and add the questions
    
    # Add 1.3.9 and 1.3.10 after the current 1.3.8
    pattern_1_3 = r"(### Question 1\.3\.8:.*?\n\n)---"
    replacement_1_3 = r"\1" + question_1_3_9 + "\n" + question_1_3_10 + "\n---"
    content = re.sub(pattern_1_3, replacement_1_3, content, flags=re.DOTALL)
    
    # Add 2.1.9 and 2.1.10 after the current 2.1.8
    pattern_2_1 = r"(### Question 2\.1\.8:.*?\n\n)(## Practice 2\.2:)"
    replacement_2_1 = r"\1" + question_2_1_9 + "\n" + question_2_1_10 + "\n" + r"\2"
    content = re.sub(pattern_2_1, replacement_2_1, content, flags=re.DOTALL)
    
    # Add 2.3.10 after the current 2.3.9
    pattern_2_3 = r"(### Question 2\.3\.9:.*?\n\n)---"
    replacement_2_3 = r"\1" + question_2_3_10 + "\n---"
    content = re.sub(pattern_2_3, replacement_2_3, content, flags=re.DOTALL)
    
    # Add 3.2.10 after the current 3.2.9
    pattern_3_2 = r"(### Question 3\.2\.9:.*?\n\n)(## Practice 3\.3:)"
    replacement_3_2 = r"\1" + question_3_2_10 + "\n" + r"\2"
    content = re.sub(pattern_3_2, replacement_3_2, content, flags=re.DOTALL)
    
    # Write the updated content
    with open('/Users/decimai/workspace/qramm-repo/assessment/full-assessment.md', 'w', encoding='utf-8') as f:
        f.write(content)
    
    print("✅ Added 6 missing questions to complete 120-question assessment")
    return content

if __name__ == "__main__":
    import re
    add_missing_questions()
