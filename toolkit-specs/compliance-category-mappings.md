# QRAMM Compliance Category Mappings - Response for Contractor

## Question 1: Category Coverage - Individual Category Names and Mappings

### NIST Cybersecurity Framework (CSF) 2.0 Categories

The NIST CSF uses a hierarchical structure with Functions and Categories:

**Functions (Top Level):**
- **GV** = GOVERN (Governance)
- **ID** = IDENTIFY
- **PR** = PROTECT  
- **DE** = DETECT
- **RS** = RESPOND
- **RC** = RECOVER

**Categories (Second Level) - Examples from the mappings:**
- **GV.OC** = Organizational Context
- **GV.PO** = Policy
- **GV.RR** = Roles and Responsibilities
- **GV.RM** = Risk Management
- **GV.SP** = Strategic Planning
- **GV.MT** = Measurement and Testing
- **ID.AM** = Asset Management (ID.AM-1, ID.AM-2, etc.)
- **ID.BE** = Business Environment
- **ID.GV** = Governance (under Identify)
- **ID.RA** = Risk Assessment
- **ID.RM** = Risk Management Strategy
- **ID.SC** = Supply Chain Risk Management
- **PR.AC** = Identity Management and Access Control
- **PR.DS** = Data Security
- **PR.IP** = Information Protection Processes
- **PR.PT** = Protective Technology
- **DE.CM** = Security Continuous Monitoring
- **DE.AE** = Anomalies and Events
- **RS.RP** = Response Planning
- **RS.CO** = Communications
- **RS.AN** = Analysis
- **RS.MI** = Mitigation
- **RS.IM** = Improvements
- **RC.RP** = Recovery Planning

### ISO 27001/27002:2022 Categories

ISO uses Annex A controls organized by themes:

**Main Categories:**
- **A.5** = Organizational Controls
- **A.6** = People Controls  
- **A.7** = Physical Controls
- **A.8** = Technological Controls
- **A.9** = Access Control
- **A.10** = Cryptography
- **A.11** = Physical and Environmental Security
- **A.12** = Operations Security
- **A.13** = Communications Security
- **A.14** = System Acquisition, Development and Maintenance
- **A.15** = Supplier Relationships
- **A.16** = Information Security Incident Management
- **A.17** = Business Continuity
- **A.18** = Compliance

**Specific Controls Referenced:**
- A.5.1.1 = Policies for information security
- A.5.2.1 = Information security roles and responsibilities
- A.8.1.1 = Inventory of assets
- A.8.2.1 = Classification of information
- A.8.2.3 = Handling of assets
- A.10.1.2 = Key management
- A.12.6.1 = Management of technical vulnerabilities
- A.13.1.1 = Network controls
- A.15.1.1 = Information security in supplier relationships
- A.16.1.1 = Responsibilities and procedures
- A.18.2.1 = Independent review of information security

### SOC 2 Trust Services Criteria Categories

SOC 2 uses Trust Services Criteria organized as:

**Main Categories:**
- **CC** = Common Criteria (numbered CC1.1 through CC9.2)
  - CC1 = Control Environment
  - CC2 = Communication and Information
  - CC3 = Risk Assessment
  - CC4 = Monitoring Activities
  - CC5 = Control Activities
  - CC6 = Logical and Physical Access Controls
  - CC7 = System Operations
  - CC8 = Change Management
  - CC9 = Risk Mitigation
- **A** = Availability (A1.1, A1.2, etc.)
- **P** = Privacy (P1.1, etc.)
- **C** = Confidentiality (if applicable)
- **PI** = Processing Integrity (if applicable)

### CIS Critical Security Controls v8 Categories

CIS Controls are numbered 1-18:

**Control Categories:**
1. Inventory and Control of Enterprise Assets
2. Inventory and Control of Software Assets
3. Data Protection
4. Secure Configuration of Enterprise Assets and Software
5. Account Management
6. Access Control Management
7. Continuous Vulnerability Management
8. Audit Log Management
9. Email and Web Browser Protections
10. Malware Defenses
11. Data Recovery
12. Network Infrastructure Management
13. Network Monitoring and Defense
14. Security Awareness and Skills Training
15. Service Provider Management
16. Application Software Security
17. Incident Response Management
18. Penetration Testing

### CMMC 2.0 Categories

CMMC uses domain-based organization:

**Domains and Practice Codes:**
- **AC** = Access Control (AC.L1, AC.L2, AC.L3)
- **AT** = Awareness and Training
- **AU** = Audit and Accountability
- **CA** = Security Assessment and Authorization
- **CM** = Configuration Management
- **CP** = Contingency Planning
- **IA** = Identification and Authentication
- **IR** = Incident Response
- **MA** = Maintenance
- **MP** = Media Protection
- **PE** = Physical Protection
- **PL** = Planning
- **PM** = Program Management
- **PS** = Personnel Security
- **RA** = Risk Assessment
- **SA** = System and Services Acquisition
- **SC** = System and Communications Protection
- **SI** = System and Information Integrity
- **SR** = Supply Chain Risk Management

### FISMA/FedRAMP Categories

These use NIST SP 800-53 control families:

Same as CMMC categories above, but with additional detail:
- Each control has a number (e.g., SC-13 = Cryptographic Protection)
- Controls can have enhancements (e.g., SC-13(1), SC-13(2))

### GDPR Categories (When applicable)

GDPR doesn't use numbered categories but rather principles:
- **Article 5** = Principles relating to processing
- **Article 25** = Data protection by design and by default
- **Article 32** = Security of processing
- **Article 33** = Notification of breach
- **Article 35** = Data protection impact assessment

## Question 2: Detailed Mapping Section Structure

**CONFIRMED:** Yes, the Detailed Mapping section should be aggregated for each Practice Area, with **12 rows total** (3 practice areas × 4 dimensions):

### Dimension 1 - Critical Vulnerability Identification (CVI)
1. **Practice 1.1**: Asset Discovery & Classification (Q1-Q10)
2. **Practice 1.2**: Vulnerability Scanning & Analysis (Q11-Q20)
3. **Practice 1.3**: Risk Prioritization & Tracking (Q21-Q30)

### Dimension 2 - Strategic Governance & Risk Management (SGRM)
4. **Practice 2.1**: Governance Structure & Leadership (Q31-Q40)
5. **Practice 2.2**: Risk Management Framework (Q41-Q50)
6. **Practice 2.3**: Compliance & Audit (Q51-Q60)

### Dimension 3 - Data Protection & Encryption (DPE)
7. **Practice 3.1**: Encryption Implementation (Q61-Q70)
8. **Practice 3.2**: Key Management Systems (Q71-Q80)
9. **Practice 3.3**: Data Classification & Handling (Q81-Q90)

### Dimension 4 - Infrastructure & Technical Readiness (ITR)
10. **Practice 4.1**: Network Security Architecture (Q91-Q100)
11. **Practice 4.2**: System Hardening & Updates (Q101-Q110)
12. **Practice 4.3**: Incident Response & Recovery (Q111-Q120)

Each row in the Detailed Mapping would aggregate the compliance scores for all 10 questions within that practice area, showing:
- Practice Area Name
- Average compliance score for each framework
- Number of direct mappings vs. partial mappings
- Key compliance gaps identified
- Priority recommendations

## Additional Notes for Implementation

1. **Weight-based scoring**: Each question has a relevance weight (0.0-1.0) for each framework
2. **Aggregation formula**: Practice Area Score = SUMPRODUCT(Question Scores, Relevance Weights) / SUM(Relevance Weights)
3. **Priority indicators**: Questions with weight ≥ 0.8 are HIGH priority for that framework
4. **Special frameworks**: 
   - NIST PQC only applies to cryptography-related questions
   - CMMC levels (L1, L2, L3) indicate increasing maturity requirements
   - FedRAMP inherits all FISMA controls plus additional requirements