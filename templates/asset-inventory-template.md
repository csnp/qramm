# QRAMM Cryptographic Asset Inventory Worksheet

**Purpose**: This worksheet provides a structured template for conducting comprehensive cryptographic asset discovery and risk assessment across your organization.

---

## Asset Discovery Overview

**Organization**: _____________________
**Assessment Period**: _____ to _____
**Assessment Team**: _____________________
**Last Updated**: _____________________

---

## Asset Categories

### Category 1: Network & Communication Assets

| Asset ID | System/Service Name | IP Address/FQDN | Protocol | Algorithm | Key Size | Certificate Details | Risk Level | Owner | Notes |
|----------|-------------------|-----------------|----------|-----------|----------|-------------------|------------|-------|-------|
| NET-001 | | | | | | | | | |
| NET-002 | | | | | | | | | |
| NET-003 | | | | | | | | | |
| NET-004 | | | | | | | | | |
| NET-005 | | | | | | | | | |

**Common Protocols**: TLS, SSH, VPN, IPSec, HTTPS, FTPS

### Category 2: Application & Database Assets

| Asset ID | Application Name | Database Type | Connection Method | Encryption Algorithm | Key Management | Data Sensitivity | Risk Level | Owner | Notes |
|----------|-----------------|---------------|-------------------|-------------------|---------------|-----------------|------------|-------|-------|
| APP-001 | | | | | | | | | |
| APP-002 | | | | | | | | | |
| APP-003 | | | | | | | | | |
| APP-004 | | | | | | | | | |
| APP-005 | | | | | | | | | |

**Common Implementations**: Database encryption, API security, file encryption, messaging

### Category 3: PKI & Certificate Assets

| Asset ID | Certificate Type | Subject/CN | Issuing CA | Algorithm | Key Size | Expiration Date | Risk Level | Owner | Notes |
|----------|------------------|------------|------------|-----------|----------|----------------|------------|-------|-------|
| PKI-001 | | | | | | | | | |
| PKI-002 | | | | | | | | | |
| PKI-003 | | | | | | | | | |
| PKI-004 | | | | | | | | | |
| PKI-005 | | | | | | | | | |

**Certificate Types**: SSL/TLS, Code Signing, Email (S/MIME), User Authentication, Root CA

### Category 4: Hardware Security Modules (HSM) & Key Management

| Asset ID | HSM/KMS Name | Vendor/Model | Algorithms Supported | Key Types | Usage | Quantum Support | Risk Level | Owner | Notes |
|----------|--------------|--------------|-------------------|-----------|-------|-----------------|------------|-------|-------|
| HSM-001 | | | | | | | | | |
| HSM-002 | | | | | | | | | |
| HSM-003 | | | | | | | | | |
| HSM-004 | | | | | | | | | |
| HSM-005 | | | | | | | | | |

**Key Types**: RSA, ECDSA, AES, DES/3DES, DSA

### Category 5: IoT & Embedded Systems

| Asset ID | Device Type | Location | Communication Protocol | Encryption Method | Update Capability | Quantum Vulnerability | Risk Level | Owner | Notes |
|----------|-------------|----------|----------------------|-------------------|-------------------|---------------------|------------|-------|-------|
| IOT-001 | | | | | | | | | |
| IOT-002 | | | | | | | | | |
| IOT-003 | | | | | | | | | |
| IOT-004 | | | | | | | | | |
| IOT-005 | | | | | | | | | |

**Device Types**: Sensors, Controllers, Gateways, Smart devices, Industrial systems

### Category 6: Cloud & SaaS Services

| Asset ID | Service Name | Provider | Service Type | Encryption in Transit | Encryption at Rest | Key Management | Risk Level | Owner | Notes |
|----------|--------------|----------|--------------|---------------------|-------------------|---------------|------------|-------|-------|
| CLD-001 | | | | | | | | | |
| CLD-002 | | | | | | | | | |
| CLD-003 | | | | | | | | | |
| CLD-004 | | | | | | | | | |
| CLD-005 | | | | | | | | | |

**Service Types**: IaaS, PaaS, SaaS, Storage, Database, Analytics

---

## Risk Assessment Matrix

### Quantum Vulnerability Scoring

**Algorithm Risk Levels**:
- **Critical (4)**: RSA-1024, DSA-1024, ECDSA-256, DES/3DES
- **High (3)**: RSA-2048, DSA-2048, ECDSA-384
- **Medium (2)**: RSA-3072, ECDSA-521, AES-128
- **Low (1)**: AES-256, SHA-256, SHA-3

### Data Sensitivity Classification

**Sensitivity Levels**:
- **Critical (4)**: National security, financial transactions, healthcare records
- **High (3)**: Personal data, business secrets, legal documents  
- **Medium (2)**: Internal communications, operational data
- **Low (1)**: Public information, marketing materials

### Business Impact Assessment

**Impact Levels**:
- **Critical (4)**: Business disruption, regulatory violations, significant financial loss
- **High (3)**: Operational impact, compliance issues, moderate financial loss
- **Medium (2)**: Minor operational impact, limited financial impact
- **Low (1)**: Minimal impact, no regulatory concerns

### Overall Risk Calculation

**Risk Score = (Quantum Vulnerability × Data Sensitivity × Business Impact) / 3**

---

## Summary Statistics

### Asset Summary by Category

| Category | Total Assets | Critical Risk | High Risk | Medium Risk | Low Risk |
|----------|-------------|---------------|-----------|-------------|----------|
| Network & Communication | | | | | |
| Application & Database | | | | | |
| PKI & Certificate | | | | | |
| HSM & Key Management | | | | | |
| IoT & Embedded | | | | | |
| Cloud & SaaS | | | | | |
| **TOTAL** | | | | | |

### Top Risk Assets

| Rank | Asset ID | Asset Name | Risk Score | Primary Risk Factor | Recommended Action |
|------|----------|------------|------------|-------------------|-------------------|
| 1 | | | | | |
| 2 | | | | | |
| 3 | | | | | |
| 4 | | | | | |
| 5 | | | | | |

### Algorithm Distribution

| Algorithm | Count | Percentage | Quantum Vulnerable |
|-----------|-------|------------|-------------------|
| RSA-2048 | | % | Yes |
| RSA-4096 | | % | Yes |
| ECDSA-256 | | % | Yes |
| ECDSA-384 | | % | Yes |
| AES-128 | | % | Partially |
| AES-256 | | % | No |
| SHA-256 | | % | No |
| Other | | % | Varies |

---

## Action Planning

### Immediate Actions (0-6 months)

| Priority | Asset ID | Action Required | Responsible Owner | Target Date | Status |
|----------|----------|----------------|------------------|-------------|--------|
| Critical | | | | | |
| Critical | | | | | |
| High | | | | | |
| High | | | | | |

### Short-term Actions (6-18 months)

| Priority | Asset ID | Action Required | Responsible Owner | Target Date | Status |
|----------|----------|----------------|------------------|-------------|--------|
| High | | | | | |
| Medium | | | | | |
| Medium | | | | | |
| Medium | | | | | |

### Long-term Actions (18+ months)

| Priority | Asset ID | Action Required | Responsible Owner | Target Date | Status |
|----------|----------|----------------|------------------|-------------|--------|
| Medium | | | | | |
| Low | | | | | |
| Low | | | | | |

---

## Validation & Quality Assurance

### Inventory Completeness Checklist

- [ ] All network endpoints scanned
- [ ] All applications assessed  
- [ ] All databases catalogued
- [ ] All certificates inventoried
- [ ] All HSMs/KMS systems documented
- [ ] All IoT devices identified
- [ ] All cloud services evaluated
- [ ] All code signing processes reviewed
- [ ] All backup systems assessed
- [ ] All vendor/third-party systems included

### Data Quality Verification

- [ ] Asset ownership verified
- [ ] Algorithm details confirmed
- [ ] Key sizes validated
- [ ] Certificate expiration dates checked
- [ ] Risk assessments peer-reviewed
- [ ] Business impact assessments validated
- [ ] Remediation timelines realistic
- [ ] Dependencies mapped

---

## Notes & Comments

**Discovery Methodology**: _________________________________________________

**Tools Used**: _________________________________________________

**Challenges Encountered**: _________________________________________________

**Recommendations for Next Assessment**: _________________________________________________

---

**Inventory Completed By**: _____________________
**Review Date**: _____________________
**Next Scheduled Update**: _____________________

---

*This worksheet is part of the QRAMM (Quantum Readiness Assurance Maturity Model) framework. For more information, visit https://csnp.github.io/qramm*