# QRAMM Vendor Assessment Questionnaire Template

**Purpose**: This comprehensive questionnaire template helps organizations evaluate vendor quantum readiness capabilities and roadmaps across all QRAMM dimensions.

## Vendor Information

**Company Name**: _____________________
**Primary Contact**: _____________________
**Assessment Date**: _____________________
**Reviewer**: _____________________

---

## Section 1: Cryptographic Visibility & Inventory (CVI)

### 1.1 Cryptographic Asset Management

1. **Does your organization maintain a comprehensive inventory of all cryptographic implementations in your products/services?**
   - [ ] No formal inventory exists
   - [ ] Basic inventory for critical systems only
   - [ ] Comprehensive inventory with regular updates
   - [ ] Automated inventory with real-time monitoring

2. **What cryptographic algorithms are currently used in your products/services?** (Check all that apply)
   - [ ] RSA (specify key sizes: ________)
   - [ ] ECDSA/ECDH (specify curves: ________)
   - [ ] AES (specify key sizes: ________)
   - [ ] SHA family (specify versions: ________)
   - [ ] Other: _______________

3. **Do you have a roadmap for transitioning to post-quantum cryptographic (PQC) algorithms?**
   - [ ] No roadmap exists
   - [ ] Roadmap in development
   - [ ] Roadmap established with timeline
   - [ ] PQC implementation already in progress

### 1.2 Quantum Risk Assessment

4. **Have you assessed which of your cryptographic implementations are vulnerable to quantum attacks?**
   - [ ] No assessment conducted
   - [ ] Limited assessment for high-risk systems
   - [ ] Comprehensive assessment across all systems
   - [ ] Continuous assessment with automated monitoring

5. **What is your target timeline for becoming quantum-safe?**
   - [ ] No timeline established
   - [ ] 5+ years
   - [ ] 3-5 years
   - [ ] 1-3 years
   - [ ] Already quantum-safe

---

## Section 2: Strategic Governance & Risk Management (SGRM)

### 2.1 Executive Leadership & Governance

6. **Is quantum security risk formally recognized and managed at the executive level?**
   - [ ] Not recognized at executive level
   - [ ] Informal awareness exists
   - [ ] Formal recognition with basic governance
   - [ ] Comprehensive governance with dedicated leadership

7. **Do you have dedicated budget allocation for quantum readiness initiatives?**
   - [ ] No dedicated budget
   - [ ] Ad-hoc funding as needed
   - [ ] Annual budget allocation
   - [ ] Multi-year investment program

### 2.2 Risk Management & Compliance

8. **Do you have policies specifically addressing quantum computing threats?**
   - [ ] No quantum-specific policies
   - [ ] General security policies mention quantum risks
   - [ ] Dedicated quantum risk policies exist
   - [ ] Comprehensive quantum security framework

9. **Are quantum risks integrated into your enterprise risk management processes?**
   - [ ] Not integrated
   - [ ] Informal consideration
   - [ ] Formally integrated with basic processes
   - [ ] Fully integrated with automated monitoring

---

## Section 3: Data Protection Engineering (DPE)

### 3.1 Data Classification & Protection

10. **Do you classify data based on quantum computing impact and protection requirements?**
    - [ ] No quantum-aware classification
    - [ ] Basic sensitivity classification only
    - [ ] Quantum risk incorporated into classification
    - [ ] Comprehensive quantum-aware classification system

11. **Have you implemented quantum-resistant protection for sensitive data?**
    - [ ] No quantum-resistant protections
    - [ ] Limited implementation for critical data
    - [ ] Systematic implementation across sensitive data
    - [ ] Comprehensive quantum-resistant protection

### 3.2 Cryptographic Implementation

12. **What post-quantum cryptographic algorithms have you evaluated or implemented?**
    - [ ] None evaluated
    - [ ] Evaluation in progress
    - [ ] Pilot implementations conducted
    - [ ] Production implementations deployed

13. **Can your systems support hybrid cryptographic approaches (classical + post-quantum)?**
    - [ ] No hybrid support
    - [ ] Limited hybrid capability
    - [ ] Comprehensive hybrid support in development
    - [ ] Full hybrid support implemented

---

## Section 4: Implementation & Technical Readiness (ITR)

### 4.1 Technology Selection & Deployment

14. **What is your approach to selecting post-quantum cryptographic technologies?**
    - [ ] No formal approach
    - [ ] Following industry standards (NIST, etc.)
    - [ ] Comprehensive evaluation framework
    - [ ] Advanced testing and validation program

15. **Do you have test environments for evaluating quantum-safe technologies?**
    - [ ] No test environments
    - [ ] Basic testing capability
    - [ ] Dedicated quantum-safe test environments
    - [ ] Comprehensive testing infrastructure

### 4.2 Integration & Performance

16. **Have you assessed the performance impact of post-quantum algorithms in your systems?**
    - [ ] No performance assessment
    - [ ] Basic performance evaluation
    - [ ] Comprehensive performance testing
    - [ ] Ongoing performance optimization

17. **Can your systems be updated to support new cryptographic algorithms without breaking changes?**
    - [ ] Requires significant breaking changes
    - [ ] Some breaking changes required
    - [ ] Minimal breaking changes
    - [ ] Seamless algorithm updates supported

---

## Section 5: Supply Chain & Dependencies

### 5.1 Third-Party Risk Management

18. **Do you assess quantum readiness of your suppliers and dependencies?**
    - [ ] No supplier assessment
    - [ ] Basic security assessments (non-quantum specific)
    - [ ] Quantum readiness included in assessments
    - [ ] Comprehensive quantum supply chain program

19. **What percentage of your cryptographic dependencies are under your direct control?**
    - [ ] Less than 25%
    - [ ] 25-50%
    - [ ] 50-75%
    - [ ] More than 75%

### 5.2 Vendor Support & Roadmaps

20. **Do your technology vendors provide quantum readiness roadmaps?**
    - [ ] No vendor roadmaps available
    - [ ] Some vendors provide basic information
    - [ ] Most vendors provide roadmaps
    - [ ] All critical vendors have detailed roadmaps

---

## Section 6: Implementation Timeline & Support

### 6.1 Migration Planning

21. **What is your estimated timeline for completing quantum-safe migration?**
    - [ ] No timeline established
    - [ ] 5+ years
    - [ ] 3-5 years
    - [ ] 1-3 years

22. **Do you provide migration support and guidance for customers transitioning to quantum-safe implementations?**
    - [ ] No migration support provided
    - [ ] Basic documentation available
    - [ ] Structured migration guidance and tools
    - [ ] Comprehensive migration support program

### 6.2 Ongoing Support

23. **How will you handle cryptographic agility (ability to quickly change algorithms) in your products/services?**
    - [ ] No cryptographic agility support
    - [ ] Manual configuration changes required
    - [ ] Semi-automated algorithm updates
    - [ ] Fully automated cryptographic agility

24. **Do you commit to providing security updates when new quantum threats are discovered?**
    - [ ] No formal commitment
    - [ ] Best effort basis
    - [ ] Formal commitment with SLA
    - [ ] Proactive security update program

---

## Scoring Guidelines

**Scoring**: Rate each answer from 1-4 points based on maturity level:
- Option 1: 1 point (Basic)
- Option 2: 2 points (Developing) 
- Option 3: 3 points (Established)
- Option 4: 4 points (Advanced)

**Score Interpretation**:
- **72-96 points**: Advanced quantum readiness
- **48-71 points**: Established quantum readiness  
- **24-47 points**: Developing quantum readiness
- **24 points or below**: Basic quantum readiness

---

## Additional Information

**Additional Comments/Notes**:
_________________________________________________
_________________________________________________
_________________________________________________

**Recommended Actions**:
_________________________________________________
_________________________________________________
_________________________________________________

**Next Review Date**: _____________________

---

**Assessment Completed By**: _____________________
**Date**: _____________________
**Signature**: _____________________

---

*This template is part of the QRAMM (Quantum Readiness Assurance Maturity Model) framework. For more information, visit https://csnp.github.io/qramm*