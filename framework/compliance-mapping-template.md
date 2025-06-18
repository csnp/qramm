# QRAMM Compliance Mapping Template
**Structure for Adding New Compliance Framework Mappings**

## Overview

This template provides the structure for mapping QRAMM practices to additional compliance frameworks. Use this template when adding Phase 2 (FFIEC, HIPAA, ISO 27001) or Phase 3 (PCI-DSS, SOC 2, GDPR/NIS2) frameworks.

## Template Structure

### Framework Header

```markdown
### [Framework Name] ([Acronym])
- **Version**: [Version number and date]
- **Scope**: [What the framework covers]
- **Authority**: [Governing body]
- **Key Requirements**: [List main requirement categories]
```

### Practice Mapping Table

```markdown
| QRAMM Question | [Framework Section] | Requirement ID | Requirement Description | Mapping Strength |
|----------------|-------------------|----------------|------------------------|------------------|
| **Q#.#.#**: [Question text] | [Section name] | [ID] | [Brief description] | ●●● Direct |
```

### Mapping Strength Legend

- **●●● Direct**: QRAMM practice directly satisfies the requirement
- **●●○ Strong**: Substantially addresses with minor gaps  
- **●○○ Partial**: Partially addresses the requirement
- **○○○ Supporting**: Provides supporting evidence only

## Example: Adding HIPAA Mapping

### HIPAA (Health Insurance Portability and Accountability Act)
- **Version**: HIPAA Security Rule (45 CFR Part 164)
- **Scope**: Protection of electronic protected health information (ePHI)
- **Authority**: U.S. Department of Health and Human Services
- **Key Requirements**: Administrative, Physical, Technical Safeguards

#### Practice 1.1: Cryptographic Discovery & Inventory Management

| QRAMM Question | HIPAA Section | Requirement ID | Requirement Description | Mapping Strength |
|----------------|---------------|----------------|------------------------|------------------|
| **Q1.1.1**: How does your organization identify cryptographic assets? | Technical Safeguards | §164.312(a)(2)(iv) | Encryption and decryption | ●●○ Strong |
| **Q1.1.2**: How does your organization document cryptographic assets? | Administrative Safeguards | §164.316(b)(1) | Documentation | ●●● Direct |

## Mapping Process

### Step 1: Analyze Framework Requirements
1. Review official framework documentation
2. Identify cryptography-related requirements
3. Note quantum-specific guidance (if any)
4. Identify evidence requirements

### Step 2: Map to QRAMM Practices
1. Match framework requirements to QRAMM questions
2. Determine mapping strength
3. Note any gaps or additional requirements
4. Document evidence needs

### Step 3: Validate Mappings
1. Review with compliance experts
2. Test with actual assessments
3. Update based on feedback
4. Document assumptions

## Framework-Specific Considerations

### Financial Frameworks (FFIEC, PCI-DSS)
- Focus on data protection and key management
- Emphasize vendor/third-party requirements
- Include transaction integrity

### Healthcare Frameworks (HIPAA, HITECH)
- Emphasize long-term data protection
- Include patient data considerations
- Address medical device security

### International Frameworks (ISO 27001, GDPR)
- Consider jurisdictional differences
- Include privacy requirements
- Address cross-border data flows

### Service Provider Frameworks (SOC 2, FedRAMP)
- Focus on operational controls
- Include continuous monitoring
- Emphasize customer data isolation

## Evidence Mapping Template

```markdown
### Evidence Requirements for [Framework]

| QRAMM Practice | Required Evidence | Framework Requirement | Collection Method |
|----------------|-------------------|----------------------|-------------------|
| Practice #.# | [Evidence type] | [Requirement ID] | [How to collect] |
```

## Compliance Report Template

```markdown
# [Framework] Compliance Assessment via QRAMM

## Executive Summary
- Overall compliance score: [%]
- Critical gaps identified: [#]
- Remediation priority: [High/Medium/Low]

## Detailed Findings

### Dimension 1: CVI
- Compliance coverage: [%]
- Key gaps: [List]
- Recommendations: [List]

[Continue for all dimensions...]
```

## Maintenance Guidelines

### Quarterly Updates
- Review framework updates
- Update mappings for new requirements
- Add new evidence requirements
- Update scoring methodology

### Annual Review
- Comprehensive mapping validation
- Framework version updates
- Industry feedback incorporation
- Tool integration updates

## Integration with QRAMM Toolkit

When adding new framework mappings:

1. **Update compliance-mapping.md** with full mappings
2. **Update toolkit configuration** to include new framework
3. **Add framework-specific report templates**
4. **Update evidence collection templates**
5. **Test automated mapping generation**

---

*For questions about adding new compliance mappings, contact: qramm@csnp.org*