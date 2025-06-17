# QRAMM Full Assessment Framework
**Quantum Readiness Assurance Maturity Model - Complete 120-Question Evaluation**

## Overview

The QRAMM Full Assessment is a comprehensive evaluation framework designed to measure organizational readiness for quantum computing threats across four critical dimensions. This assessment provides detailed insights into your organization's current capabilities and guides strategic planning for quantum-safe transformation.

**Assessment Structure:**
- **4 Dimensions:** CVI, SGRM, DPE, ITR
- **12 Practices:** 3 practices per dimension
- **120 Questions:** 10 questions per practice
- **5 Maturity Levels:** From Basic (1) to Optimizing (5)
- **2 Assessment Streams:** Foundation (60%) and Advanced (40%) per practice

## Instructions

For each question, select the option that best describes your organization's current state. Consider the explanation and evidence indicators when making your selection. Be honest and realistic in your assessments to ensure accurate results.


## Table of Contents

### Dimension 1: Cryptographic Visibility & Inventory (CVI)
- Practice 1.1: Cryptographic Discovery & Inventory Management
- Practice 1.2: Vulnerability Assessment & Classification  
- Practice 1.3: Cryptographic Dependency Mapping

### Dimension 2: Strategic Governance & Risk Management (SGRM)
- Practice 2.1: Leadership & Strategic Commitment
- Practice 2.2: Policy & Governance Framework
- Practice 2.3: Risk Management Integration

### Dimension 3: Data Protection Engineering (DPE)
- Practice 3.1: Data Classification & Protection Strategy
- Practice 3.2: Cryptographic Implementation
- Practice 3.3: Lifecycle Management

### Dimension 4: Implementation & Technical Readiness (ITR)
- Practice 4.1: Technology Infrastructure Assessment
- Practice 4.2: Integration Planning & Implementation
- Practice 4.3: Operational Readiness & Maintenance

---

# Dimension 1: Cryptographic Visibility & Inventory (CVI)

*Understanding and cataloging organizational capabilities*

## Practice 1.1: Cryptographic Discovery & Inventory Management

**Outcome**: A comprehensive, accurate, and up-to-date inventory of all cryptographic assets (algorithms, keys, certificates, and implementations) that clearly identifies quantum-vulnerable components and their business context, enabling prioritized migration planning.

## Stream A: Foundation (60%)

#### Level 1 - Basic

---

**Question**: How does your organization identify cryptographic assets?

**Explanation**: This assesses how your organization locates and identifies cryptographic assets including algorithms (e.g., RSA, AES), protocols (e.g., TLS, SSH), key sizes, Certificate Authorities (CA), Key Management Systems (KMS), Hardware Security Modules (HSM), and implementation details across all systems, applications, and infrastructure.

**Options**:


1. **Basic**: No formal cryptographic asset identification process exists

2. **Developing**: Manual inventory covering only known high-value systems

3. **Established**: Automated discovery implemented for portions of infrastructure

4. **Advanced**: Comprehensive automated discovery with validation across all environments

**Evidence to Look For**:


- Documentation of known cryptographic implementations in critical systems, including algorithm types and key sizes

- Use of automated network scanning tools that identify TLS implementations across the infrastructure

- Integrated tools identifying cryptography in applications, networks, hardware, and cloud services

- Advanced dashboards providing an up-to-date and comprehensive view of the cryptographic landscape

#### Level 2 - Developing

---

**Question**: How does your organization document cryptographic assets?

**Explanation**: This examines how systematically you document identified cryptographic assets, including the level of detail captured (algorithms, key sizes, expiration dates) and how this information is maintained.

**Options**:


1. **Basic**: No standardized documentation exists

2. **Developing**: Basic spreadsheet tracking that captures limited attributes

3. **Established**: Structured database with standardized templates

4. **Advanced**: Centralized asset management platform with automated updates and risk scoring

**Evidence to Look For**:


- Documented inventory process covering high-value systems that specifies implementation details (e.g., RSA-2048, AES-128)

- Structured database documenting algorithms, key sizes, protocols, certificate details, and quantum vulnerability assessments

- Automated tools updating documentation based on discovery results

- Comprehensive metadata including algorithm types, key sizes, expiration dates, and risk ratings

#### Level 3 - Established

---

**Question**: How does your organization govern cryptographic asset ownership and accountability?

**Explanation**: This examines whether your organization has clear, enforceable ownership of cryptographic assets—ensuring someone is responsible for maintaining inventory accuracy, supporting migration planning, and responding to vulnerabilities across all systems and environments.

**Options**:


1. **Basic**: No formal assignment of ownership or accountability for cryptographic assets

2. **Developing**: Ownership of cryptographic assets is informally assigned for critical systems or managed by individual teams

3. **Established**: Ownership roles are formally defined across the organization, with documented responsibilities and coverage tracking

4. **Advanced**: Cryptographic ownership is embedded into asset governance processes, with automated assignment, accountability metrics, and cross-functional oversight

**Evidence to Look For**:


- Documentation of assigned crypto owners for a subset of high-value systems

- Ownership mapping integrated into inventory or Configuration Management Database (CMDB)

- Assigned accountability for lifecycle tasks (e.g., key rotation, renewal, algorithm upgrades)

- Accountability metrics tracked for timeliness of remediation, renewal, or migration actions

#### Level 4 - Advanced

---

**Question**: How does your organization validate cryptographic asset inventory completeness?

**Explanation**: This examines how you ensure your cryptographic asset inventory is accurate and comprehensive, without significant gaps or outdated information about algorithms, key sizes, or implementations.

**Options**:


1. **Basic**: No validation of inventory completeness

2. **Developing**: Periodic manual sampling of selected systems to verify inventory accuracy

3. **Established**: Regular automated verification scans with a formal reconciliation process to address discrepancies

4. **Advanced**: Continuous monitoring with anomaly detection and completeness analytics that automatically identifies potential gaps in the cryptographic inventory

**Evidence to Look For**:


- Spreadsheet annotations showing updates or corrections based on manual review

- Metrics tracking inventory accuracy and completeness (e.g., percentage of systems scanned, number of discrepancies found)

- Machine learning or rule-based analytics identifying trends in inventory coverage and data quality

- Real-time validation integrated into DevOps, CI/CD, or system provisioning pipelines

#### Level 5 - Optimizing

---

**Question**: How does your organization ensure cryptographic visibility across third-party and cloud systems?

**Explanation**: This examines your organization's ability to identify, document, and monitor how cryptography is implemented within third-party services (e.g., SaaS platforms, cloud workloads, managed services) to ensure quantum-vulnerable components are not overlooked during risk assessment and migration planning.

**Options**:


1. **Basic**: No visibility into cryptographic usage in third-party services or cloud environments

2. **Developing**: Visibility is manually assessed for select vendors or critical cloud services

3. **Established**: Cryptographic visibility is routinely evaluated and documented across third-party and cloud environments using structured methods

4. **Advanced**: Continuous visibility into cryptographic usage across all external environments is maintained using automated tools, contractual controls, and integration with inventory systems

**Evidence to Look For**:



- Reviews of TLS settings or certificate usage in cloud-facing systems

- Cloud Security Posture Management (CSPM) tools identifying crypto parameters in cloud environments

- Real-time scanning or API-based monitoring of cryptographic configurations in multi-cloud or SaaS environments

- Contractual obligations for vendors to report cryptographic changes and vulnerabilities

## Stream B: Advanced (40%)

#### Level 1 - Basic

---

**Question**: How is cryptographic asset inventory data used for strategic planning?

**Explanation**: This examines whether and how cryptographic asset information influences organizational security planning and resource allocation for quantum readiness.

**Options**:


1. **Basic**: No strategic use of inventory data

2. **Developing**: Basic reports generated for compliance purposes only

3. **Established**: Structured analysis guides resource allocation and security planning

4. **Advanced**: Advanced analytics drive quantum readiness strategy with ROI modeling

**Evidence to Look For**:


- Basic reporting capability for cryptographic assets, including algorithm types and key sizes

- Integration of asset data into project planning, architecture, or security roadmaps

- Defined KPIs (e.g., percentage of PQC-ready assets, cost per migrated system, risk reduction per dollar spent) are tracked and used to inform executive decision-making

- Inventory data linked to threat intelligence, business impact scoring, and refresh cycle planning

#### Level 2 - Developing

---

**Question**: How are cryptographic assets prioritized for quantum-resistance upgrades?

**Explanation**: This examines how you determine which cryptographic assets should be addressed first in your quantum readiness efforts, based on vulnerability, importance, and other factors.

**Options**:


1. **Basic**: No prioritization process exists

2. **Developing**: Criticality ratings based on system importance only

3. **Established**: Multi-factor risk scoring based on algorithm type, key size, long-term data sensitivity, and exposure

4. **Advanced**: Advanced prioritization model incorporating business impact, resource constraints, dependencies, and data protection timeframes

**Evidence to Look For**:


- Documentation of prioritization criteria and the systems prioritized for upgrade

- Quantum risk register tracking asset-level vulnerability and exposure

- Cross-functional prioritization criteria agreed upon by business and security teams

- Simulation results or scenario modeling of quantum decryption impacts on key systems

### Level 3 - Established

**Question**: How is cryptographic asset inventory maintained over time?

**Explanation**: This examines your processes for keeping cryptographic asset inventory information current as systems change, certificates are renewed, and new applications are deployed.

**Options**:


1. **Basic**: No maintenance process exists

2. **Developing**: Manual updates during major system changes only

3. **Established**: Scheduled automated refresh with change management integration

4. **Advanced**: Real-time inventory updates with change verification and historical versioning

**Evidence to Look For**:


- Automated discovery tools integrated with CI/CD pipelines and asset management systems

- Scheduled re-scans or audits to detect new or modified cryptographic implementations

- Change management processes requiring cryptographic inventory updates upon deployment

- Version-controlled inventory logs with timestamps and responsible owner annotations

### Level 4 - Advanced

**Question**: How does your organization include IoT and embedded devices in its cryptographic inventory and quantum readiness planning?

**Explanation**: This evaluates whether and how your organization identifies and manages cryptographic implementations in IoT and embedded devices—systems that often rely on hardcoded, legacy, or constrained cryptography.

**Options**:


1. **Basic**: IoT and embedded devices are not included in cryptographic inventory or transition planning

2. **Developing**: Manual list exists for critical IoT or embedded systems, but cryptographic details are incomplete or outdated

3. **Established**: IoT and embedded devices are systematically inventoried with crypto attributes (e.g., algorithm, key size), and included in quantum upgrade plans

**Evidence to Look For**:


- Inventory entries for IoT/embedded devices that specify algorithms, key lengths, and firmware crypto libraries

- Assessment reports identifying quantum-vulnerable protocols used in constrained or legacy devices

- Migration plans that include device upgrade feasibility and hardware limitations for cryptographic changes

- Use of embedded device scanning tools or firmware analysis to discover cryptographic implementations

#### Level 5 - Optimizing

---

**Question**: How does your organization stay informed about quantum computing and cryptanalysis advancements?

**Explanation**: This assesses how your organization monitors developments in quantum computing, cryptanalysis, and cryptographic standards that may affect the accuracy of your cryptographic inventory or the vulnerability status of deployed algorithms, focusing on ongoing awareness and information gathering—particularly as a foundation for discovery, risk assessment, and planning.

**Options**:


1. **Basic**: No monitoring process exists

2. **Developing**: Manual reviews of standards bodies or industry publications occur occasionally but are not systematic

3. **Established**: Structured monitoring process tracks cryptographic research, algorithm deprecation, and quantum milestones using defined sources and schedules

4. **Advanced**: Continuous monitoring with automated alerting and integration into asset inventories, allowing near real-time updates when cryptographic standards or threat models evolve

**Evidence to Look For**:


- List of monitored sources (e.g., NIST, IACR, ETSI, arXiv) for cryptographic and quantum updates

- Scheduled review cycles or internal briefings on cryptographic standards and research

- Subscriptions to automated alerts or newsletters tracking algorithm deprecation and quantum milestones

- Tooling or dashboards that flag relevant changes in cryptographic threat landscapes

## Practice 1.2: Vulnerability Assessment & Classification

**Outcome**: A systematic approach to identifying, assessing, and classifying cryptographic vulnerabilities to quantum attacks, enabling risk-based prioritization and effective mitigation planning.

## Stream A: Foundation (60%)

#### Level 1 - Basic

---

**Question**: How does your organization assess quantum vulnerability of cryptographic assets?

**Explanation**: This examines your approach to evaluating how susceptible your cryptographic implementations are to quantum attacks (the weaknesses in the cryptography) based on algorithm types, key sizes, and implementation details.

**Options**:


1. **Basic**: No vulnerability assessment process exists

2. **Developing**: Basic identification of commonly known vulnerable algorithms

3. **Established**: Structured assessment methodology with vulnerability classification based on algorithm type, key size, and implementation

4. **Advanced**: Comprehensive risk-based assessment with technical validation and detailed algorithm-specific analysis

**Evidence to Look For**:


- Inventory annotated with algorithm types, key lengths, and known quantum vulnerabilities

- Use of industry standards (e.g., NIST, ETSI) to classify algorithm susceptibility

- Automated tools scanning code, configurations, and certificates for weak cryptographic implementations

- Evidence of in-depth assessment covering various cryptographic contexts (e.g., key exchange, signatures, encryption)

#### Level 2 - Developing

---

**Question**: How does your organization classify quantum vulnerability severity?

**Explanation**: This evaluates how your organization prioritizes the urgency of addressing quantum vulnerabilities by considering factors such as key establishment vs digital signatures, algorithm, key size, implementation context, data exposure, and the long-term sensitivity of protected data.

**Options**:


1. **Basic**: No method in place to classify quantum vulnerabilities

2. **Developing**: General high/medium/low ratings with minimal or informal criteria

3. **Established**: Formal classification framework using defined factors like algorithm, key size, data sensitivity, exposure, and protection duration

4. **Advanced**: Quantitative risk scoring model combining technical vulnerability with business impact metrics

**Evidence to Look For**:


- Asset inventory annotated with data exposure levels (e.g., public-facing)

- Documentation of data retention needs tied to sensitivity and protection timeframes

- Reports linking crypto weaknesses to business functions and data types

- Scoring model combining technical risk, data exposure, and longevity needs

#### Level 3 - Established

---

**Question**: How does your organization validate vulnerability findings?

**Explanation**: This examines your approach to verifying that identified cryptographic vulnerabilities are accurate and properly characterized in terms of algorithm types, key sizes, and implementation details.

**Options**:


1. **Basic**: No validation process exists

2. **Developing**: Manual review of vulnerability assessments by security team

3. **Established**: Structured validation methodology with technical testing of algorithm implementations

4. **Advanced**: Automated validation with multiple assessment techniques and cryptographic expertise

**Evidence to Look For**:


- Comparison of scan results across multiple tools to identify false positives or gaps

- Use of cryptographic linting or static analysis tools during code reviews to confirm proper implementation

- Tracking how often flagged vulnerabilities are reclassified or dismissed after deeper inspection

- Internal guidelines defining when a finding requires expert cryptographic review versus automated confirmation

### Level 4 - Advanced

**Question**: How does your organization integrate emerging quantum threats into planning and strategy?

**Explanation**: This evaluates how your organization uses insights from quantum computing and cryptanalysis developments to shape cryptographic roadmaps, prioritize asset upgrades, and inform long-term risk mitigation strategies.

**Options**:


1. **Basic**: No planning or strategy considers quantum threat developments

2. **Developing**: Strategic plans are occasionally updated in response to major quantum-related announcements or standard changes

3. **Established**: Quantum threat developments are regularly factored into cryptographic planning, with updates to migration timelines, policies, and coordination with key vendors

4. **Advanced**: Quantum threat scenarios drive ongoing strategy refinement using impact modeling, vendor quantum-readiness tracking, and alignment with business risk and data protection timelines

**Evidence to Look For**:


- Meeting minutes or strategy documentation showing use of quantum threat scenarios in planning

- Vendor assessments or questionnaires tracking quantum-readiness milestones

- Migration plans that adjust timelines based on evolving quantum risk forecasts

- Modeling or simulations used to prioritize systems based on quantum impact and business risk

### Level 5 - Optimizing

**Question**: How does your organization contribute to (quantum) cryptanalysis and mitigation research?

**Explanation**: This examines your organization’s role in advancing the broader field of classical and post-quantum cryptographic research—such as algorithm analysis, vulnerability assessment, and mitigation strategies—through collaboration, knowledge sharing, or original research.

**Options**:


1. **Basic**: No involvement in external research or knowledge-sharing efforts

2. **Developing**: Participation in industry working groups or forums and shared lessons learned on algorithm vulnerabilities

3. **Established**: Active collaboration with academic or industry partners on research related to cryptanalysis or mitigation

4. **Advanced**: Original research, tools, or publications that contribute to advancing cryptography or cryptanalysis practices

**Evidence to Look For**:


- Published papers or blog posts analyzing quantum risks in specific cryptographic algorithms

- Open-source tools or datasets released for vulnerability testing or analysis

- Sponsorship of research grants, internships, or academic projects on post-quantum security

- Internal lab results or testbed simulations exploring weaknesses in legacy protocols or modeling attacks on cryptosystems

## Stream B: Advanced (40%)

#### Level 1 - Basic

---

**Question**: How are vulnerability findings communicated to stakeholders?

**Explanation**: This assesses how effectively your organization shares information about quantum-related cryptographic vulnerabilities with relevant internal stakeholders—including technical teams, system owners, and executives.

**Options**:


1. **Basic**: No formal communication process exists

2. **Developing**: Vulnerability reports shared with technical teams listing affected systems and algorithms

3. **Established**: Structured reporting tailored to different stakeholder groups with contextual information about algorithm risks

4. **Advanced**: Comprehensive communication strategy with executive dashboards showing vulnerability metrics and trends

**Evidence to Look For**:


- Tailored reports or dashboards summarizing vulnerabilities by business unit or stakeholder type

- Established communication cadence (e.g., monthly reviews, executive briefings) for crypto risk updates

- Documentation or workflows defining how vulnerability findings are escalated and tracked across teams

- Stakeholder-specific risk impact summaries that link crypto issues to business functions or compliance needs

#### Level 2 - Developing

---

**Question**: How does your organization assess the quantum vulnerability of cryptographic mechanisms used for data authenticity and long-term integrity?

**Explanation**: This examines whether your organization evaluates the post-quantum risks to digital signatures and message authentication mechanisms used to verify authenticity and protect the integrity of data over time. 

**Options**:


1. **Basic**: No assessment of authenticity or integrity mechanisms under quantum threat

2. **Developing**: Informal review of signature algorithms and MACs in critical systems

3. **Established**: Structured evaluation of signing and integrity mechanisms by algorithm, key size, and data lifetime

4. **Advanced**: Comprehensive vulnerability assessment of all long-term integrity and authenticity controls, including exposure modeling and risk scoring

**Evidence to Look For**:


- Inventory of signing and MAC mechanisms used for software updates, logs, backups, and document workflows

- Assessment reports evaluating digital signature algorithms (e.g., RSA, ECDSA) used in firmware, code signing, and archival documents

- Identification of long-lived integrity mechanisms in backup and archival systems, including signing or hashing methods

- Risk modeling or prioritization documents that score authenticity and integrity protections based on algorithm type and data retention period

#### Level 3 - Established

---

**Question**: How does your organization validate the correctness and secure configuration of deployed cryptographic implementations?

**Explanation**: This assesses whether your organization verifies that deployed cryptographic functions are implemented according to specifications, use secure parameters (e.g., key sizes, cipher modes), and conform to standards.

**Options**:


1. **Basic**: No validation of deployed cryptographic implementations

2. **Developing**: Ad-hoc manual checks of cryptographic configurations in selected systems

3. **Established**: Structured validation process reviewing algorithm correctness, key sizes, and configuration settings

4. **Advanced**: Automated and continuous validation of cryptographic use across systems, including detection of library misuse, insecure modes, and deprecated protocols

**Evidence to Look For**:


- Application of cryptographic configuration testing tools (e.g., testssl.sh, cryptographic linters, or fuzzers)

- Cryptographic implementation review as part of secure code review or architecture review process

- Scan reports identifying insecure modes (e.g., ECB), deprecated protocols, or weak key lengths in production systems

- Defined cryptographic secure coding patterns or APIs enforced across teams to standardize secure usage

#### Level 4 - Advanced

---

**Question**: How does your organization assess trends in cryptographic vulnerabilities over time?

**Explanation**: This examines whether your organization tracks how cryptographic vulnerabilities evolve due to system changes, algorithm deprecation, or quantum computing progress—and whether this information is used to monitor readiness and guide remediation priorities.

**Options**:


1. **Basic**: No tracking or analysis of changes in cryptographic vulnerability posture

2. **Developing**: Informal or occasional reviews noting major algorithm or system changes

3. **Established**: Regular analysis using defined metrics to track algorithm usage, crypto upgrades, and exposure trends

4. **Advanced**: Continuous trend monitoring with predictive analytics tied to system changes, quantum advancements, and deprecation timelines

**Evidence to Look For**:


- Reports comparing algorithm usage or key sizes across inventory snapshots

- Metrics dashboards tracking adoption of PQC-ready algorithms or phase-out of deprecated ones

- Trend analysis presentations linking system upgrades to reductions in quantum-exposed components

- Forecast models projecting algorithm viability against quantum computing milestones

### Level 5 - Optimizing

**Question**: How does your organization apply quantum vulnerability insights to improve cryptographic practices and standards?

**Explanation**: This examines how insights gained from quantum-focused cryptographic assessments—such as algorithm weaknesses, misconfigurations, or systemic gaps—are used to improve implementation practices, internal standards, and future decision-making.

**Options**:


1. **Basic**: No process exists to apply findings from vulnerability assessments

2. **Developing**: Lessons from significant vulnerabilities occasionally lead to manual updates in practices

3. **Established**: Structured process to review assessment findings and update standards, guidance, or configurations

4. **Advanced**: Continuous improvement loop with automated feedback into coding patterns, policy updates, and tool configurations based on recurring issues

**Evidence to Look For**:


- Post-assessment reviews resulting in updates to internal cryptographic configuration baselines

- Documentation showing revisions to approved algorithm lists based on assessment trends

- Change logs for secure coding guidelines reflecting common implementation issues

- Automated rule updates in static analysis or CI/CD tools based on recurring crypto misuse patterns

## Practice 1.3: Cryptographic Dependency Mapping

**Outcome**: A comprehensive understanding of how cryptographic components are interconnected throughout the organization, enabling coordinated migration planning that maintains system functionality while transitioning to quantum-resistant algorithms.

## Stream A: Foundation (60%)

#### Level 1 - Basic

---

**Question**: How does your organization identify and map cryptographic dependencies across systems and services?

**Explanation**: This assesses your ability to discover and document how cryptographic implementations connect systems, applications, services, and devices—such as shared keys, certificates, protocols, or libraries.

**Options**:


1. **Basic**: No process exists to identify cryptographic dependencies between systems

2. **Developing**: Manual identification of direct dependencies in known critical systems

3. **Established**: Structured methodology to map cryptographic dependencies across systems, protocols, and services, including indirect relationships

4. **Advanced**: Automated discovery and mapping of all cryptographic dependencies, including dynamic connections, shared libraries, and multi-system flows

**Evidence to Look For**:


- Dependency diagrams or architecture maps showing crypto relationships

- Outputs from automated tools detecting shared crypto usage (e.g., libraries, APIs)

- Inter-service crypto dependency documentation (e.g., mutual TLS or shared key use)

- Change logs showing impact analysis based on dependency mapping

#### Level 2 - Developing

---

**Question**: How does your organization document and maintain cryptographic dependencies between systems and services?

**Explanation**: This examines whether and how your organization records cryptographic interdependencies—such as shared certificates, keys, protocols, or algorithm implementations—across systems, applications, and services. 

**Options**:


1. **Basic**: No formal documentation of cryptographic dependencies

2. **Developing**: Informal or manual records of direct dependencies

3. **Established**: Structured documentation using standardized formats to capture algorithms, key types, and inter-system relationships

4. **Advanced**: Centralized and continuously maintained dependency database with metadata for algorithms, certificates, relationship types, and system roles

**Evidence to Look For**:


- Spreadsheet or database capturing system-to-system cryptographic links with associated key types or algorithms

- Standardized templates used to record dependencies, including fields for protocol versions and certificate usage

- Metadata schema or taxonomy defining relationship types (e.g., client-server, mutual TLS, shared CA)

- Integration of cryptographic dependency data into CMDBs, architecture tools, or asset management platforms

#### Level 3 - Established

---

**Question**: How does your organization analyze the impact of cryptographic changes across dependent systems and services?

**Explanation**: This examines whether your organization performs impact analysis to understand how cryptographic changes—such as algorithm upgrades, key rotations, or certificate transitions—affect interconnected systems, services, and workflows.

**Options**:


1. **Basic**: No process exists to assess the impact of cryptographic changes on dependent systems

2. **Developing**: Informal or ad-hoc assessments of major dependencies when changes are planned

3. **Established**: Structured methodology to evaluate the effects of algorithm, certificate, or key changes across known dependencies

4. **Advanced**: Comprehensive modeling and scenario analysis to predict system-wide impacts of cryptographic transitions, including business and operational consequences

**Evidence to Look For**:


- Impact assessment reports mapping systems affected by planned cryptographic upgrades or deprecations

- Dependency heatmaps or risk diagrams highlighting systems linked by shared crypto assets (e.g., certificates, libraries)

- Change approval workflows requiring cryptographic impact analysis before rollout (e.g., certificate rotations, TLS changes)

- Scenario models simulating algorithm migration or protocol changes and identifying potential disruptions

#### Level 4 - Advanced

---

**Question**: How does your organization validate the accuracy and completeness of cryptographic dependency mapping?

**Explanation**: This examines whether your organization has a formal process to verify that its cryptographic dependency maps reflect real and complete relationships between systems, including methods for technical validation, detection of missing or outdated links, and ongoing updates to reflect infrastructure changes.

**Options**:


1. **Basic**: No process exists to verify cryptographic dependency data

2. **Developing**: Manual spot-checks of selected dependencies in critical systems

3. **Established**: Structured validation process using technical methods to confirm system-to-system cryptographic relationships

4. **Advanced**: Automated validation with continuous monitoring and detection of missing or outdated dependencies across all environments

**Evidence to Look For**:


- Logs or reports from automated tools detecting previously undocumented cryptographic dependencies

- Validation scripts comparing documented dependencies against actual traffic or configuration data (e.g., TLS connections, key usage logs)

- Audit records of manual or peer reviews confirming dependency records for high-risk systems

- Dashboards or alerts flagging mismatches between expected and observed cryptographic relationships

#### Level 5 - Optimizing

---

**Question**: How does your organization keep cryptographic dependency information current as systems evolve?

**Explanation**: This examines how your organization ensures that cryptographic dependency records stay accurate over time as systems, certificates, keys, or protocols change, including processes for updating records in response to infrastructure change and the use of automation for continuous visibility.

**Options**:


1. **Basic**: No process exists to update cryptographic dependency information over time

2. **Developing**: Dependency records are updated manually when major changes are noticed or reported

3. **Established**: Regular updates are performed through scheduled reviews and integrated with change management processes

4. **Advanced**: Dependency information is continuously updated using automated discovery, monitoring, and integration with asset and configuration systems

**Evidence to Look For**:


- Scheduled reviews or audits that include validation and updates of cryptographic dependency documentation

- Automated tools that detect new or modified cryptographic relationships and update dependency records in real time

- Version-controlled repository or database showing historical changes to cryptographic dependencies

- Dashboards or metrics tracking update frequency and data freshness of dependency records

## Stream B: Advanced (40%)

#### Level 1 - Basic

---

**Question: **How is cryptographic dependency information used to inform migration planning and operational risk management?

**Explanation: **This assesses whether your organization uses knowledge of cryptographic interdependencies—such as shared certificates, protocol chains, or API relationships—to guide transition sequencing, prevent cascading failures, and prioritize mitigation efforts.

**Options**:


1. **Basic**: Dependency data is not used in planning or risk discussions

2. **Developing**: Known critical dependencies are considered during informal planning

3. **Established**: Structured transition planning uses documented dependencies to guide sequencing and risk evaluation

4. **Advanced**: Dependency models are integrated into simulation tools and strategic risk assessments for quantum transition

**Evidence to Look For**:


- Migration plans that include sequencing steps based on documented cryptographic dependencies

- Risk assessments or threat models highlighting cascading failure potential from shared cryptographic components

- Change approval workflows requiring dependency impact analysis for key rotations or algorithm upgrades

- Dependency-aware fallback or rollback procedures defined in migration playbooks

### Level 2 - Developing

**Question**: How does your organization manage cryptographic dependencies in software build systems and code-signing infrastructure?

**Explanation**: This examines how your organization identifies and coordinates cryptographic components used across CI/CD pipelines, code-signing tools, package repositories, and update mechanisms—ensuring these trust relationships are tracked, validated, and upgraded as part of the quantum transition strategy.

**Options**:


1. **Basic**: Cryptographic use in build systems or code-signing infrastructure is not tracked

2. **Developing**: Some known dependencies (e.g., code-signing certificates) are documented, but not consistently updated or mapped

3. **Established**: Cryptographic dependencies across CI/CD pipelines and signing systems are documented and reviewed as part of upgrade planning

4. **Advanced**: Dependency-aware tooling continuously monitors and validates signing workflows, with cryptographic upgrade paths coordinated across software delivery systems

**Evidence to Look For**:


- Inventory of signing algorithms, keys, and certificates used in software release pipelines

- Documentation of cryptographic trust paths across CI/CD systems, package repositories, and update verification mechanisms

- Build scripts or DevSecOps pipelines configured to enforce approved cryptographic parameters for signing and verification

- Migration plans addressing post-quantum signing algorithm adoption across code-signing services, firmware signing tools, and CI/CD integrations

#### Level 3 - Established

---

**Question**: How does your organization assess cryptographic dependencies and transition constraints in operational technology (OT) and industrial control environments?

**Explanation**: This examines whether your organization identifies and maps cryptographic relationships across OT, Supervisory Control and Data Acquisition (SCADA), Industrial Control Systems (ICS), and industrial systems—including fixed-function protocols (e.g., MODBUS, DNP3, OPC-UA), hardware cryptography limitations, and long lifecycle constraints—to plan safe and effective quantum-resilient transitions.

**Options**:


1. **Basic**: No assessment of cryptographic dependencies or constraints in OT or industrial systems

2. **Developing**: Some OT systems are reviewed manually for cryptographic use, but dependencies and limitations are undocumented

3. **Established**: OT and industrial crypto dependencies are documented, including protocol use and upgrade limitations

4. **Advanced**: Cryptographic transition plans for OT systems include detailed dependency maps, hardware constraints, and coordinated timelines with operational risk modeling

**Evidence to Look For**:


- System inventories listing industrial protocols (e.g., MODBUS, DNP3, OPC-UA) alongside their cryptographic implementations and known limitations

- Architecture diagrams mapping cryptographic trust relationships between controllers, sensors, gateways, and industrial networks

- Assessment reports evaluating firmware or embedded hardware support for quantum-resistant algorithms

- Operational risk analyses modeling the impact of cryptographic algorithm changes on industrial safety, availability, or compliance

#### Level 4 - Advanced

---

**Question: **How are cryptographic dependencies evaluated for architectural complexity and transition fragility?

**Explanation: **This assesses whether your organization evaluates how tightly coupled cryptographic components are across systems, and how susceptible the architecture is to cascading failures or upgrade bottlenecks during quantum-safe transitions.

**Options**:


1. **Basic**: No evaluation of cryptographic complexity or fragility

2. **Developing**: Informal review of major dependencies without complexity analysis

3. **Established**: Structured assessment of dependency complexity and upgrade risk

4. **Advanced**: Simulations and metrics guide architecture hardening and migration design

**Evidence to Look For**:


- Crypto dependency diagrams annotated with shared libraries, protocols, or trust anchors that highlight upgrade bottlenecks

- Architecture review records identifying fragile crypto trust paths or legacy chokepoints

- Complexity scores or dashboards tracking depth of cryptographic chains, shared asset reuse, and decoupling progress

- Logs showing crypto-related changes that triggered cascading impacts across services


### Level 5 - Optimizing

**Question**: How are cryptographic dependencies tracked across CI/CD pipelines, shared libraries, and external APIs?

**Explanation**: Explanation: This assesses whether your organization identifies and manages cryptographic interdependencies introduced through development workflows, software components, or third-party interfaces, which may impact the timing or feasibility of quantum-resilient transitions.

**Options**:


1. **Basic**: No visibility into cryptographic use across pipelines, libraries, or APIs

2. **Developing**: Some known crypto dependencies are documented, but tracking is manual or incomplete

3. **Established**: Dependency tracking is structured and includes libraries, signing workflows, and key interfaces

4. **Advanced**: Continuous monitoring tracks cryptographic components across build systems, shared code, and third-party integrations

**Evidence to Look For**:


- Dependency files or manifests (e.g. SBOMs) listing cryptographic libraries and algorithms

- Documentation of cryptographic interfaces to third-party APIs or managed services

- Security controls in pipelines enforcing approved cryptographic algorithms for code signing and deployment

- Automated tooling output showing real-time tracking or alerts on cryptographic changes in builds or dependencies


- ---

#  Dimension 2: Strategic Governance & Risk Management (SGRM)

*Understanding and cataloging organizational capabilities*

## Practice 2.1: Executive Leadership & Policy Management

**Outcome**: Clear leadership direction and robust policy framework for quantum risk management with appropriate governance structures.

## Stream A: Foundation (60%)

#### Level 1 - Basic

---

**Question**: How is quantum risk oversight structured at the executive level?

**Explanation**: This examines how your organization has established leadership responsibility and accountability for quantum computing risks, including the governance structures that provide oversight of quantum readiness initiatives.

**Options**:


1. **Basic**: No formal quantum risk oversight exists

2. **Developing**: Quantum risks managed within existing security governance

3. **Established**: Dedicated quantum readiness steering committee established

4. **Advanced**: Board-level quantum security governance with executive accountability

**Evidence to Look For**:


- Executive charters or board minutes explicitly referencing quantum computing risks

- Organizational charts or role definitions showing a named executive or officer responsible for quantum readiness

- Governance frameworks or steering committee documents detailing mandates to oversee cryptographic transitions and quantum-safe planning

- Strategic plans or roadmaps with timelines for achieving post-quantum cryptographic readiness approved by executive or board-level governance bodies

### Level 2 - Developing

**Question**: How comprehensive is your quantum risk policy framework?

**Explanation**: This assesses the maturity of your organization's policy structure specifically addressing quantum computing risks, including the scope, depth, and implementation of policies that guide quantum readiness activities.

**Options**:


1. **Basic**: No policies exist that mention or address quantum computing risks.

2. **Developing**: Quantum risks are briefly acknowledged in existing cybersecurity or risk management policies, without dedicated guidance or implementation details.

3. **Established**: Dedicated quantum risk policy documents exist, covering risk recognition, impact assessment, and transition planning guidelines.

4. **Advanced**: Comprehensive quantum policy framework governs organization-wide activities, is regularly updated, and includes mandates for technical, legal, vendor, and audit requirements related to quantum readiness.

**Evidence to Look For**:


- Policy documents explicitly naming quantum computing threats and outlining potential impact scenarios

- Organization-wide requirements for departments and vendors to follow quantum-safe cryptographic standards or assessment checklists

- Integration of quantum risks into existing enterprise risk management (ERM), business continuity, or compliance frameworks

- Inclusion of quantum-safe transition mandates in enterprise cryptographic or cybersecurity standards

#### Level 3 - Established

---

**Question**: How are quantum security initiatives funded and resourced?

**Explanation**: This examines how your organization allocates financial resources and personnel to quantum readiness initiatives, including the maturity of budgeting processes and investment tracking for quantum security efforts.

**Options**:


1. **Basic**: No dedicated funding allocated

2. **Developing**: Project-by-project funding requests

3. **Established**: Annual budget with defined allocation

4. **Advanced**: Multi-year investment program with return-on-investment (ROI) tracking

**Evidence to Look For**:


- Budget planning documents or spreadsheets listing quantum risk mitigation or post-quantum cryptography as a distinct cost center or line item

- Formal resource requests or internal memos justifying one-off quantum-related initiatives (e.g., pilot assessments, tooling evaluations)

- Annual financial plans or board-approved budgets allocating specific amounts to cryptographic modernization or quantum-safe upgrades

- Documentation of ROI modeling, impact forecasts, or long-term cost planning for quantum transition efforts

#### Level 4 - Advanced

---

**Question**: How do you measure quantum risk governance effectiveness?

**Explanation**: This assesses your organization's ability to evaluate the performance of quantum security governance activities, including metrics, analytics, and continuous improvement practices.

**Options**:


1. **Basic**: No effectiveness measurements in place

2. **Developing**: Informal or manual compliance tracking

3. **Established**: Formal metrics framework used across key governance areas

4. **Advanced**: Automated reporting with real-time dashboards and trend analysis

**Evidence to Look For**:


- Audit findings or internal review results that assess the implementation and governance of quantum risk-related activities

- Defined key performance indicators (KPIs) or key risk indicators (KRIs) related to quantum security within governance documentation

- Dashboards or visualization tools used to track adoption of post-quantum cryptography, remediation status, or policy compliance

- Automated tools or GRC (Governance, Risk, and Compliance) platforms integrating quantum risk-specific controls, reporting, and escalation workflows

#### Level 5 - Optimizing

---

**Question**: How does leadership drive quantum security innovation?

**Explanation**: This evaluates how actively and intentionally your organization's leadership promotes innovation in quantum security, including funding or guiding R&D efforts, fostering a culture of experimentation, supporting strategic partnerships, and incentivizing novel approaches to address emerging quantum risks.

**Options**:


1. **Basic**: No innovation direction provided

2. **Developing**: Leadership monitors industry trends with limited internal activity

3. **Established**: Leadership supports structured research and development programs

4. **Advanced**: Leadership champions a dedicated innovation function with external collaborations and continuous advancement

**Evidence to Look For**:


- Executive sponsorship of quantum research initiatives, pilots, or grants internally or through external partners (e.g., universities, consortia, or startups)

- Innovation charters, working groups, or labs specifically focused on cryptographic modernization or quantum security experimentation

- Budget allocations or strategic plans specifically earmarked for exploratory or pre-commercial quantum security technologies

- Recognition or incentive programs that reward staff contributions to quantum-safe innovation (e.g., hackathons, patents, innovation KPIs)

## Stream B: Advanced (40%)

#### Level 1 - Basic

---

**Question: **How is quantum risk integrated into organizational strategy and long-term planning?

**Explanation:** This assesses how quantum computing risks and opportunities are embedded in strategic decision-making across business functions, including their inclusion in long-term roadmaps, corporate risk frameworks, and transformation initiatives beyond just security governance.

**Options**:


1. **Basic**: No strategic integration of quantum risk

2. **Developing**: Quantum risk considered during IT or security planning only

3. **Established**: Quantum risk integrated into enterprise risk and business planning cycles

4. **Advanced**: Quantum considerations influence cross-business strategy, investment, and innovation planning

**Evidence to Look For**:


- Strategic planning documents (e.g., OKRs, roadmaps, risk registers) referencing quantum threats or timelines

- Enterprise risk management (ERM) documentation showing alignment of quantum threats with organizational risk appetite and mitigation goals

- Business continuity or digital transformation initiatives explicitly accounting for quantum-related disruption or readiness requirements

- Cross-functional strategic planning meetings, minutes, or charters discussing quantum readiness implications across units (e.g., legal, R&D, product)

#### Level 2 - Developing

---

**Question: **How are quantum security policies reviewed and maintained over time?

**Explanation: **This assesses your organization's ability to ensure quantum-related policies remain current, accurate, and actionable as threats evolve and mitigation strategies advance.

**Options**:


1. **Basic**: No process for reviewing or updating quantum-related policies

2. **Developing**: Manual reviews conducted annually with limited scope or documentation

3. **Established**: Structured quarterly review process with stakeholder input and documented revisions

4. **Advanced**: Automated and continuous policy maintenance integrated with threat intelligence and compliance triggers

**Evidence to Look For**:


- Documented policy review schedule specifying frequency and responsible roles for quantum-related updates

- Change logs showing version history and rationale for updates to quantum risk policies

- Integration with automated tooling or GRC platforms that track compliance or threat data and recommend or initiate policy updates

- Training materials or rollout communications linked to recent policy revisions, showing that updates are operationalized across the organization

### Level 3 - Established

**Question**: How is executive leadership kept informed and prepared to guide quantum security strategy?

**Explanation**: This assesses your organization’s approach to ensuring executive leaders not only understand quantum computing threats, but are equipped to make informed decisions about cryptographic agility (the ability to quickly and seamlessly transition cryptographic algorithms, key sizes, and implementations), funding, migration prioritization, and incident response.

**Options**:


1. **Basic**: No awareness or education program exists for leadership

2. **Developing**: Annual briefings on quantum computing developments are conducted

3. **Established**: Regular education programs with role-specific content and strategic implications

4. **Advanced**: Executive simulations, dashboards, and decision-support tools are in place to enable quantum-resilient leadership

**Evidence to Look For**:


- Executive-specific quantum security awareness materials, tailored by role (e.g., CFO, CISO, Board, Legal)

- Leadership dashboards or scorecards showing quantum readiness metrics, remediation timelines, and cryptographic agility posture

- Communication workflows or escalation procedures linking cryptographic events (e.g., deprecated algorithm detection) to executive-level decision-making

- Leadership role definitions or accountability documents referencing decision-making responsibilities tied to quantum resilience (e.g., funding sign-off, vendor policy enforcement)

#### Level 4 - Advanced

---

**Question**: How do you monitor and manage progress across your quantum readiness program and cryptographic transition activities?

**Explanation**: This assesses your organization's approach to tracking the advancement of quantum readiness initiatives across all relevant domains—cryptographic remediation, policy implementation, vendor upgrades, and workforce enablement.

**Options**:


1. **Basic**: No tracking or progress monitoring in place

2. **Developing**: Manual milestone tracking performed on select activities

3. **Established**: Comprehensive dashboards used to track progress across multiple quantum readiness workstreams

4. **Advanced**: Real-time automated tracking with integration into crypto inventory, DevSecOps pipelines, and resource planning

**Evidence to Look For**:


- Executive or board-level reporting that summarizes quantum security posture in business-impact terms (e.g., cost per remediated system, risk reduced)

- Project trackers or dashboards showing status of cryptographic migration tasks, categorized by system criticality, algorithm, or exposure

- Cross-stream reporting tools integrating progress from policy, vendor, asset, and infrastructure readiness tracks

- Metrics and KPIs aligned to readiness milestones (e.g., % PQC-ready assets, % vendors assessed, % policies implemented)

#### Level 5 - Optimizing

---

**Question**: How does your organization contribute to shaping industry-wide quantum security and cryptographic agility practices?

**Explanation**: This assesses your organization's contributions to industry knowledge sharing, standards development, and thought leadership in quantum security and cryptographic transition planning—including efforts to drive interoperability, agility, and preparedness across sectors.

**Options**:


1. **Basic**: No involvement in industry quantum security or cryptographic agility initiatives

2. **Developing**: Passive participation in industry working groups or forums related to PQC, cryptographic agility, or interoperability

3. **Established**: Active contributions to industry standards, knowledge-sharing sessions, or multi-stakeholder planning for cryptographic agility and PQC migration

4. **Advanced**: Leadership in shaping quantum security and cryptographic agility practices through published methodologies, toolkits, and coordination across sectors or regulators

**Evidence to Look For**:


- Membership in organizations like NIST, ETSI, ISO, IETF, or QSC and contributions to their standards

- Participation in cross-sector exercises (e.g., financial or healthcare quantum risk pilots)

- Published maturity models, playbooks, or cryptographic transition architectures

- White papers, blogs, or public presentations on cryptographic transition strategies

## Practice 2.2: Risk Assessment & Compliance Management

**Outcome**: Systematic approach to identifying, assessing, and mitigating quantum risks with clear alignment to compliance requirements.

## Stream A: Foundation (60%)

#### Level 1 - Basic

---

**Question**: How comprehensive is your quantum risk assessment methodology?

**Explanation**: This examines your organization's approach to identifying and evaluating quantum computing risks, including structured assessment frameworks, risk categorization, prioritization methods, and how the results inform cryptographic agility and transition planning.

**Options**:


1. **Basic**: No formal quantum risk assessment methodology exists

2. **Developing**: Informal or ad hoc quantum risk identification is performed without structured categorization or prioritization

3. **Established**: Structured quantum risk assessment framework is implemented with defined risk categories, scoring methods, and linkage to cryptographic planning

4. **Advanced**: An automated and continuously updated quantum risk analysis system informs cryptographic agility, asset prioritization, and strategic transition planning

**Evidence to Look For**:


- Risk assessment documentation outlining methodology, data sources, and scoring models specific to quantum computing threats

- Defined quantum-specific risk categories based on algorithm type, key size, asset exposure, data retention requirements, and business criticality

- Application of Mosca’s Theorem or equivalent models to prioritize cryptographic migration timelines

- Use of automated tools or platforms that continuously assess quantum vulnerability based on threat intelligence, algorithm deprecation updates, or system changes

### Level 2 - Developing

**Question**: How automated is your quantum risk monitoring and integration into cryptographic transition planning?

**Explanation**: This assesses your organization's capabilities for continuously monitoring quantum computing threats and their impact on cryptographic assets, and how this surveillance is integrated into cryptographic agility planning and transition execution.

**Options**:


1. **Basic**: No automated monitoring or integration with cryptographic planning exists

2. **Developing**: Tracking tools are used manually to observe quantum computing developments

3. **Established**: Comprehensive monitoring system captures quantum threat signals and informs cryptographic exposure tracking

4. **Advanced**: An AI-supported platform continuously monitors quantum risk indicators and dynamically adjusts cryptographic transition priorities

**Evidence to Look For**:


- Quantum-aware alerting systems that trigger reviews or mitigation actions when defined thresholds are met (e.g., progress in quantum hardware benchmarks, PQC standardization updates)

- Automated linkage between monitoring outputs and cryptographic inventory or asset risk scoring, showing which systems are most exposed to emerging quantum threats

- Documentation of monitoring policies and escalation procedures that specify roles, data sources, thresholds, and update cycles for quantum threat indicators

- Use of predictive analytics or AI-driven modeling that projects cryptographic risk exposure over time using quantum computing trajectories and cryptanalytic breakthroughs

#### Level 3 - Established

---

**Question**: How do you quantify quantum risk exposure?

**Explanation**: This examines your organization's methods for measuring the potential impact of quantum computing threats, including structured risk scoring, data sensitivity analysis, and the use of quantitative models to support cryptographic agility planning and business-aligned prioritization.

**Options**:


1. **Basic**: No formal quantification of quantum risk exposure exists

2. **Developing**: Informal impact assessments are performed without consistent scoring methods

3. **Established**: Structured scoring methodology is used to evaluate exposure based on algorithm strength, data sensitivity, and asset value

4. **Advanced**: An automated modeling system is used to quantify risk exposure across assets, factoring in cryptographic agility, business impact, and data protection timelines

**Evidence to Look For**:


- Documentation showing use of scoring models that combine algorithm type, key size, data sensitivity and exposure, and projected protection lifespan

- Quantified assessments of critical systems that incorporate Mosca’s Theorem to evaluate urgency for quantum-safe migration

- Business impact modeling reports linking cryptographic vulnerabilities to revenue streams, regulatory risk, or operational disruption

- Integration of quantum risk exposure scores into cryptographic agility planning or executive decision-making frameworks

### Level 4 - Advanced

**Question**: How do you validate the effectiveness of quantum risk controls?

**Explanation**: This examines your organization's approach to verifying whether quantum-related risk mitigation controls—such as cryptographic upgrades, monitoring systems, and vendor safeguards—are functioning as intended and delivering the expected reduction in quantum risk exposure. 

**Options**:


1. **Basic**: No validation process exists for quantum risk controls

2. **Developing**: Testing of selected controls is performed manually and inconsistently

3. **Established**: Regular assessments are conducted using defined effectiveness metrics, procedures, and responsible roles

4. **Advanced**: Continuous and automated validation of quantum risk controls is implemented across domains with feedback loops into strategy and cryptographic agility planning

**Evidence to Look For**:


- Defined validation methodology outlining how technical and procedural quantum risk controls are tested for coverage, reliability, and residual risk

- Reports documenting regular testing of quantum-secure cryptographic implementations and tracking control outcomes

- Integration of control validation into CI/CD pipelines, vendor reviews, or cryptographic lifecycle governance for early detection of configuration drift or enforcement gaps

- Use of automated tools to continuously test cryptographic enforcement points (e.g., deprecated algorithm blocking, PQC fallback mechanisms, quantum-safe cipher suite enforcement)

#### Level 5 - Optimizing

---

**Question**: How do you update your quantum risk assessment methodology as new threats and cryptographic developments emerge?

**Explanation**: This examines your organization's ability to evolve its quantum risk assessment framework in response to advances in quantum computing, cryptanalysis, and PQC research—ensuring that risk models, prioritization criteria, and cryptographic agility planning remain current and effective.

**Options**:


1. **Basic**: No update process exists

2. **Developing**: Annual assessment updates performed based on informal review of new threats

3. **Established**: Quarterly revisions conducted with structured input from research and intelligence sources

4. **Advanced**: Monthly integration of quantum threat analysis and cryptographic transition insights into a dynamic, automated risk assessment framework

**Evidence to Look For**:


- Documented process for integrating threat intelligence on PQC breakages, lattice attacks, or hybrid scheme vulnerabilities into risk models

- Version-controlled risk framework with tracked revisions based on NIST PQC standardization or cryptanalysis developments

- Use of quantum-aware scoring factors such as data lifespan, adversary capability growth, and cryptographic downgrade risks

- Reports showing periodic reassessment of PQC migration priorities based on new quantum threat modeling scenarios

## Stream B: Advanced (40%)

#### Level 1 - Basic

---

**Question**: How mature is your quantum security compliance program?

**Explanation**: This assesses your organization’s approach to tracking and enforcing compliance with cryptographic standards and regulatory expectations related to quantum computing—covering PQC readiness, algorithm deprecation, cryptographic agility controls, and coverage of high-risk domains like HSMs, supply chain signing, and PKI modernization.

**Options**:


1. **Basic**: No quantum-specific compliance program or requirements exist

2. **Developing**: Informal or ad hoc compliance checks are conducted without consistent documentation

3. **Established**: Structured compliance framework governs quantum cryptographic controls and is reviewed regularly

4. **Advanced**: Quantum compliance is continuously monitored and enforced through automated tools integrated with policy, PKI, and DevSecOps processes

**Evidence to Look For**:


- Audit reports verifying HSM compatibility with approved PQC algorithms and flagging unsupported devices

- PKI policy documents covering hybrid certificates, short lifetimes, and post-quantum revocation practices

- CI/CD pipeline scripts enforcing PQ-safe cryptographic configurations at build and test stages

- Attestations confirming use of PQC algorithms in code signing and software release workflows

### Level 2 - Developing

**Question**: How does your organization adapt cryptographic practices in response to evolving quantum security standards and regulatory requirements?

**Explanation**: This examines your organization's ability to track changes in quantum-related regulations and standards (e.g., NIST, ETSI), and update internal controls, cryptographic configurations, and transition plans accordingly to maintain compliance and agility.

**Options**:


1. **Basic**: No process exists to track or adapt to quantum-related regulatory changes

2. **Developing**: Ad hoc reviews of major PQC guidance are conducted with limited updates to practices

3. **Established**: Structured tracking and impact analysis informs scheduled updates to cryptographic policies and controls

4. **Advanced**: Regulatory intelligence feeds are integrated into crypto control systems, triggering change workflows and agility simulations across systems

**Evidence to Look For**:


- Centralized log or tracker mapping changes in quantum-secure cryptography regulations to internal control requirements and timelines

- Recorded change management processes that revise PKI certificate profiles or HSM configurations based on external PQC requirements

- Mapping between post-quantum algorithm mandates and deployment plans across constrained environments (e.g., IoT/OT readiness adjustments)

- Reports showing periodic reviews of PQC vendor solutions or cloud services for compliance alignment and agility under changing standards

#### Level 3 - Established

---

**Question**: How do you track and map compliance across quantum-relevant controls and systems?

**Explanation**: This examines your organization's ability to trace quantum security compliance requirements to specific systems, policies, and enforcement controls—ensuring coverage, accountability, and auditability across the enterprise.

**Options**:


1. **Basic**: No mapping or tracking of quantum compliance requirements exists

2. **Developing**: Quantum compliance documentation is maintained manually with limited structure

3. **Established**: Compliance requirements are tracked through a structured system, linking them to policies, controls, and asset owners

4. **Advanced**: Compliance mapping is automated, with tooling that traces requirements to cryptographic enforcement points and flags misalignments

**Evidence to Look For**:


- Tagged cryptographic inventory showing which systems are governed by which regulatory or standards-based obligations (e.g., NIST, FIPS mandates)

- Compliance traceability matrix tying post-quantum controls (e.g., hybrid cryptography rollout, HSM migration) to internal policies and audit checkpoints

- Internal audit logs or reports validating coverage of quantum-related controls across high-risk domains like PKI, CI/CD, or third-party integrations

- Mapping tables or dashboards linking cryptographic systems (e.g., TLS endpoints, signing services) to PQC compliance controls and enforcement requirements

#### Level 4 - Advanced

---

**Question**: How do you measure cryptographic remediation progress for regulated domains?

**Explanation**: This assesses your organization’s ability to track and measure progress on closing quantum security compliance gaps across high-risk, regulated domains such as PKI infrastructure, TLS endpoints, code signing workflows, and software supply chain protections. 

**Options**:


1. **Basic**: No formal tracking of remediation progress for cryptographic systems in regulated domains exists

2. **Developing**: Informal milestone tracking is performed manually for select domains like PKI or TLS

3. **Established**: Structured tracking system monitors remediation progress across regulated cryptographic domains, linked to controls and policies

4. **Advanced**: Real-time platform integrates cryptographic remediation metrics across PKI, TLS, code signing, and supply chain, with dashboards, alerts, and audit traceability

**Evidence to Look For**:


- Project trackers or spreadsheets tied to asset inventory, showing remediation milestones and responsible owners

- Internal audit or GRC reports showing progress metrics across cryptographic domains and identification of lagging areas

- Alerts or risk indicators for non-remediated systems using deprecated or unapproved algorithms (e.g., RSA, ECC)

- Scripts or automation workflows used to scan, tag, and track remediation status of cryptographic enforcement points across infrastructure

#### Level 5 - Optimizing

---

**Question**: How do you ensure quantum security requirements are integrated into audits and control testing?

**Explanation**: This assesses your organization’s ability to operationalize quantum readiness by embedding quantum security controls into audit procedures and technical control testing. 

**Options**:


1. **Basic**: Quantum-related controls are not included in audit scopes or security testing

2. **Developing**: Manual or ad hoc testing of quantum-related controls occurs during general security reviews

3. **Established**: Quantum security requirements are embedded in audit plans and control testing procedures across regulated and cryptographic systems

4. **Advanced**: Automated testing of quantum-related enforcement points and audit criteria is integrated into CI/CD, control libraries, and third-party assurance processes

**Evidence to Look For**:


- Control testing reports that document verification of quantum-safe cryptographic configurations (e.g., NIST-approved PQC algorithms, shortened key lifetimes)

- CI/CD scripts or runtime scanners that flag cryptographic misconfigurations, including fallback usage or downgrade paths

- Results from penetration tests or config audits showing quantum-relevant vulnerabilities and their remediation

- Inclusion of PQC enforcement checks in third-party risk assessments or SOC audit mappings

## Practice 2.3: Third-Party & Supply Chain Risk Management

**Outcome**: Comprehensive approach to identifying and managing quantum-related risks in the supply chain and vendor ecosystem.

## Stream A: Foundation (60%)

#### Level 1 - Basic

---

**Question**: How comprehensive is your assessment of vendor quantum readiness and cryptographic agility?

**Explanation**: This assesses your organization's approach to evaluating the quantum readiness of vendors and service providers—focusing on their ability to adopt post-quantum cryptography (PQC), manage cryptographic agility, and secure high-risk domains such as code signing, TLS endpoints, HSM compatibility, and supply chain workflows.

**Options**:


1. **Basic**: No evaluation of vendor quantum readiness or cryptographic agility is performed

2. **Developing**: Vendors are asked basic security questions, with occasional reference to PQC readiness

3. **Established**: Structured assessment framework evaluates vendor quantum readiness, agility posture, and coverage of key cryptographic systems

4. **Advanced**: Quantum readiness is monitored using automated tools or vendor risk platforms where critical exposure warrants it

**Evidence to Look For**:


- Vendor assessment templates with questions on PQC adoption timelines, hybrid algorithm support, key lifecycle governance, and fallback mechanisms for deprecated algorithms

- Completed evaluations or scorecards rating vendor cryptographic agility and PQC posture across systems like TLS endpoints, signing workflows, and HSM-backed services

- Contractual clauses or onboarding checklists requiring vendors to disclose PQ algorithm compatibility for data-in-transit and code-signing processes

- Use of third-party risk tools or continuous monitoring platforms that surface crypto-related exposures (e.g., unsupported key lengths, weak cipher suites, no PQ roadmap)

#### Level 2 - Developing

---

**Question**: How do you manage quantum security and cryptographic agility requirements for vendors handling sensitive systems?

**Explanation**: This assesses your organization's approach to establishing, communicating, and verifying vendor requirements related to post-quantum cryptography and cryptographic agility—particularly for vendors that manage or support cryptographically sensitive systems such as TLS endpoints, code signing infrastructure, firmware updates, HSMs, and PKI components.

**Options**:


1. **Basic**: No defined quantum or cryptographic agility requirements are communicated to vendors

2. **Developing**: Contracts include basic security clauses referencing quantum readiness or PQC transition

3. **Established**: Structured requirement framework covers quantum-safe controls, cryptoagility posture, and applies to critical vendor systems

4. **Advanced**: Automated verification and enforcement of quantum and agility requirements are built into procurement, onboarding, and vendor monitoring processes

**Evidence to Look For**:


- Vendor requirement templates including PQC readiness, cryptographic agility plans, and enforcement for TLS, signing, or HSM interfaces

- Role-based requirement matrices linking specific controls (e.g., short-lived certs, algorithm agility) to vendor service types and risk tiers

- Language in master service agreements (MSAs) or data processing agreements (DPAs) enforcing hybrid cert support, agility timelines, or fallback protections

- Evidence that post-contract vendor reviews test for control implementation (e.g., PQ algorithm usage, key rotation support, firmware signing compatibility)

#### Level 3 - Established

---

**Question**: How do you audit vendor controls for quantum security in critical systems?

**Explanation**: This assesses your organization’s approach to verifying that vendors have implemented effective quantum-safe and cryptographic agility controls across high-risk systems such as code signing infrastructure, TLS endpoints, HSM configurations, CI/CD pipelines, and PKI integrations.

**Options**:


1. **Basic**: No audit or validation of vendor controls related to quantum security is performed

2. **Developing**: Vendor-provided attestations or security reviews include limited references to quantum-relevant controls

3. **Established**: Structured audits validate post-quantum controls in high-risk vendor domains, with standardized checklists and escalation paths

4. **Advanced**: Technical verification of PQC and agility controls is integrated into vendor assurance processes for critical systems (e.g., code signing, PKI, CI/CD), with enforcement tied to contract terms or tooling

**Evidence to Look For**:


- Audit reports or security assessments examining vendor enforcement of PQC algorithms in TLS certificates, APIs, or endpoints

- Checklists or evaluation templates covering PQ readiness across code signing systems, firmware updates, or secure email gateways

- Evidence of HSM validation (e.g., PQC support compatibility, key generation constraints) during third-party security reviews

- Vendor documentation or test results demonstrating PQ-safe CI/CD pipelines (e.g., PQ signing keys, deprecated algorithm rejection)

#### Level 4 - Advanced

---

**Question**: How does your organization enforce and validate vendor cryptographic agility under real-world constraints?

**Explanation**: **:** This examines your organization’s oversight of whether vendors can reliably perform cryptographic agility operations under realistic operational, hardware, and deployment constraints, including bandwidth limitations, embedded environments, or downtime-sensitive systems.

**Options**:


1. **Basic**: No validation or enforcement of vendor cryptographic agility is performed

2. **Developing**: Vendors provide attestations or documentation of cryptographic agility capabilities without verification

3. **Established**: Vendor agility operations are validated through structured tests or review of agility enforcement in critical systems

4. **Advanced**: Vendors are contractually required to demonstrate live agility operations under constrained conditions, with enforcement integrated into onboarding, monitoring, and assurance processes

**Evidence to Look For**:


- Vendor test results demonstrating cryptographic agility operations in constrained or legacy systems (e.g., mobile apps, firmware, embedded controllers)

- Evidence of contractual obligations requiring support for algorithm upgrades, key rotation, and rollback testing

- Assurance reports or onboarding checklists showing cryptographic agility scenarios tested during vendor evaluation

- CI/CD pipeline integration logs or attestation reports confirming agility enforcement across third-party code or services

#### Level 5 - Optimizing

---

**Question**:How do you evaluate vendor support for hardware dependencies? 

**Explanation**: This assesses your organization's ability to evaluate whether vendors use and support secure hardware components—including HSMs, TPMs, and cryptographic accelerators—that can accommodate evolving cryptographic requirements, such as key lifecycle management, secure key generation, agility under algorithm deprecations, and compatibility with future cryptographic transitions.

**Options**:


1. **Basic**: No evaluation of vendors’ hardware security capabilities is performed

2. **Developing**: Vendors self-attest to basic hardware use

3. **Established**: Structured assessments verify vendor support for hardware-backed key generation and cryptographic operations

4. **Advanced**: Vendor reviews include formal validation of hardware compatibility with PQC implementation plans, cryptographic agility requirements, and integration into DevSecOps and cryptographic lifecycle workflows

**Evidence to Look For**:


- Vendor questionnaires or technical due diligence checklists confirming HSM or TPM support for PQC-compatible key storage, signing, or key exchange functions

- Documentation of hardware certification that includes post-quantum algorithm modules or firmware upgrade paths

- Security architecture diagrams showing how the vendor’s systems manage key rotation, hybrid certs, or fallback enforcement using secure hardware

- Audit reports or test results demonstrating the vendor’s ability to update cryptographic libraries and hardware integrations in response to PQC deprecation or algorithm updates

## Stream B: Advanced (40%)

#### Level 1 - Basic

---

**Question**: How does your organization assess and manage quantum-related risks across its supply chain? 

**Explanation**: This assesses your organization’s maturity in identifying, evaluating, and mitigating quantum computing risks within its vendor ecosystem and broader supply chain—focusing on structured frameworks, assessment methodologies, and the ability to adapt to evolving threats.

**Options**:


1. **Basic**: No supply chain risk assessment or management for quantum threats exists

2. **Developing**: Informal or ad hoc identification of vendors or systems with quantum exposure

3. **Established**: Structured risk management framework is in place for assessing quantum vulnerabilities in the supply chain

4. **Advanced**: Advanced modeling and dynamic risk scoring are used to assess and respond to quantum threats across the supply chain

**Evidence to Look For**:


- Supply chain inventory or mapping identifying quantum-vulnerable dependencies (e.g., cryptographic hardware, key management paths)

- Risk assessment framework tailored to supply chain quantum exposures, including algorithm and lifecycle constraints

- Categorization of vendors or systems based on quantum readiness, criticality, or cryptographic dependencies

- Simulation results modeling quantum-related supply chain disruptions or propagation impacts

#### Level 2 - Developing

---

**Question**: How does your organization perform technical evaluation of quantum risk across individual supply chain vendors and components?

**Explanation**: This examines how your organization conducts detailed, component-level quantum risk assessments within the supply chain—focusing on the depth of analysis, evaluation techniques, and ability to detect cryptographic vulnerabilities or lifecycle constraints at the vendor and product level.

**Options**:


1. **Basic**: No technical evaluation of quantum risks is performed for supply chain components

2. **Developing**: Basic reviews are conducted for select vendors or services without standardized analysis

3. **Established**: Structured risk evaluation is applied to vendors and components using defined criteria, scoring, and technical cryptographic review

4. **Advanced**: Technical risk analysis is automated and adaptive, incorporating telemetry, cryptographic exposure mapping, and supply chain intelligence feeds

**Evidence to Look For**:


- Cryptographic risk assessment reports or scorecards for individual vendors, platforms, firmware, or services

- Risk models incorporating technical details such as hardcoded algorithms, upgrade feasibility, or key handling limitations

- Vendor-specific reports showing assessment of TLS endpoints, signing mechanisms, firmware cryptography, or dependency trees

- Automated tools or dashboards that map technical quantum exposure across supply chain elements using configuration, telemetry, or SBOM data

### Level 3 - Established

**Question**: How do you identify and prioritize supply chain systems that could delay or block enterprise cryptographic transitions?

**Explanation**: This assesses your organization's ability to uncover, evaluate, and triage third-party systems or services that may inhibit or slow cryptographic modernization efforts, including vendors lacking PQC support, hardware-bound systems that cannot adopt new key types, or service providers that cannot handle changes to certificate lifetimes, key lengths, or algorithms.

**Options**:


1. **Basic**: No process exists to identify supply chain systems that block or delay cryptographic transitions

2. **Developing**: Systems are identified reactively during cryptographic implementation or vendor onboarding

3. **Established**: Structured process identifies, assesses, and prioritizes systems and vendors that lack support for PQC, algorithm agility, or required crypto changes

4. **Advanced**: Cryptographic blockers in the supply chain are continuously tracked, risk-scored, and integrated into transition roadmaps and vendor engagement strategies

**Evidence to Look For**:


- Inventory or mapping of third-party systems that perform cryptographic functions (e.g., TLS termination, code signing, firmware delivery)

- Tools or dashboards that flag systems with known blockers (e.g., fixed HSM profiles, legacy PKI stacks, hardcoded algorithms) and link them to cryptographic transition milestones

- Structured tiered supply chain reviews that include questions on post-quantum readiness, fallback mechanisms, and hardware constraints

- Transition plans that identify and sequence remediation based on criticality of vendor/system crypto compatibility

#### Level 4 - Advanced

---

**Question**: How does your organization evaluate fallback or downgrade risks in supply chain cryptographic protocols?

**Explanation**: This examines your organization’s ability to identify and assess downgrade paths or fallback mechanisms in vendor-supplied cryptographic protocols that could undermine post-quantum security, such as legacy cipher support, weak default configurations, or disabled algorithm negotiation.

**Options**:


1. **Basic**: No evaluation of fallback or downgrade risks in vendor cryptographic protocols is performed

2. **Developing**: Fallback risks are informally noted during vendor security reviews

3. **Established**: Structured assessments identify downgrade mechanisms in critical vendor protocols and systems

4. **Advanced**: Fallback risk detection is automated and integrated into vendor assurance and transition planning processes

**Evidence to Look For**:


- Vendor assessments identifying support for legacy algorithms, insecure cipher suites, or weak protocol defaults in TLS or firmware update services

- Technical documentation or penetration test results showing downgrade paths in vendor cryptographic implementations

- Risk registers or exception logs referencing fallback exposure in vendor systems (e.g., firmware rollbacks, dual-stack support)

- Tools or dashboards that scan vendor endpoints for weak protocol configurations or fallback acceptance (e.g., TLS downgrade probes)

#### Level 5 - Optimizing

---

**Question**: How does your organization improve vendor risk practices?

**Explanation**: This assesses your organization's contributions to advancing vendor risk management practices for quantum security, including innovation, standardization, and collaboration to strengthen cryptographic readiness across the broader supply chain.

**Options**:


1. **Basic**: Basic practices are followed with no focus on continuous improvement

2. **Developing**: Industry best practices are informally adopted without customization or feedback loops

3. **Established**: Regular contributions are made to refine vendor risk methodologies and apply lessons learned across engagements

4. **Advanced**: Novel approaches to quantum vendor risk management are developed, shared, and adopted across industries or standards bodies

**Evidence to Look For**:


- Published guidance, case studies, or tooling contributions related to quantum vendor risk management

- Participation in industry forums or working groups focused on post-quantum supply chain security

- Internal innovation programs or retrospectives aimed at improving vendor cryptographic assurance

- Recognition, adoption, or citation of your vendor risk practices in external frameworks, toolkits, or standards


- ---

#  Dimension 3: Data Protection Engineering (DPE)

*Understanding and cataloging organizational capabilities*

#  Dimension 3: Data Protection Engineering (DPE)

*Understanding and cataloging organizational capabilities*

## Purpose

Design and implement quantum-resistant data protection controls throughout the data lifecycle.

## Strategic Value

Ensures long-term protection of sensitive data against quantum threats

Creates alignment between data sensitivity and appropriate quantum-resistant controls

Establishes protection for data at rest, in transit, and in use

Supports compliance with data protection regulations in a post-quantum environment

Enables cryptographic agility across all data protection mechanisms

Maintains data usability while transitioning to quantum-resistant algorithms

## Practice Areas

### Practice 3.1: Data Classification & Protection Requirements

**Outcome**: A comprehensive data protection framework that aligns protection measures with data sensitivity and quantum risk levels across the entire data lifecycle.

#### Stream A: Implementation & Controls (60%)

##### Level 1 - Basic

**Question**: How does your organization identify data requiring quantum-resistant protection?

**Explanation**: This examines how your organization identifies sensitive or long-lived data that may require protection against evolving threats, including the future risks posed by quantum computing.

**Options**:


1. **Basic**: No data identification process exists

2. **Developing**: Manual identification of sensitive data types in high-value or regulated systems

3. **Established**: Structured classification using protection timeframes and long-term confidentiality tags

4. **Advanced**: Automated discovery and classification with integrated quantum risk scoring

**Evidence to Look For**:


- Data classification records explicitly linking certain datasets to protection lifespans that exceed the projected arrival of practical quantum threats

- Documentation showing the use of Mosca’s Theorem or equivalent models to determine which data requires quantum-resistant protection based on retention needs

- Metadata schemas or tagging conventions that flag long-term sensitive data (e.g., financial contracts, patient records) for enhanced cryptographic safeguards

- Output from data discovery tools identifying high-value fields (e.g., national IDs, legal documents) tagged for long-duration confidentiality

##### Level 2 - Developing

**Question**: How does your organization classify data based on quantum risk?

**Explanation**: This examines your approach to categorizing data assets according to their vulnerability to quantum computing threats, considering factors like protection timeframe, sensitivity, and business impact.

**Options**:


1. **Basic**: No classification system exists

2. **Developing**: Basic sensitivity levels defined without considering quantum-specific threats

3. **Established**: Structured classification incorporating protection duration and sensitivity to quantum risk

4. **Advanced**: Automated classification system with integrated quantum risk scoring and exposure modeling

**Evidence to Look For**:


- Classification policies that define protection levels based on data sensitivity and retention periods in a post-quantum context

- Use of scoring models or matrices that rank data risk by quantum exposure, business impact, and cryptographic vulnerability

- Documentation showing how classification criteria are adjusted based on updates to the projected quantum computing timeline

- Automated tools that tag or sort datasets by protection timeframe, cryptographic algorithm used, and exposure window

##### Level 3 - Established

**Question**: How does your organization implement quantum-resistant controls?

**Explanation**: This examines how your organization deploys cryptographic safeguards that protect data against quantum computing threats, including algorithm selection, key management, and control validation.

**Options**:


1. **Basic**: No specific controls implemented

2. **Developing**: Hybrid algorithms of classical and quantum-resistant cryptography applied to select high-sensitivity data

3. **Established**: Structured control framework aligned with data classifications and quantum protection needs that determines how hybrid algorithms are applied

4. **Advanced**: Automated enforcement of quantum-resistant controls across all data states with continuous validation

**Evidence to Look For**:


- Implementation records showing post-quantum or hybrid algorithms applied to specific systems or datasets classified as quantum-sensitive

- Methodology documents mapping cryptographic control types to data categories and required protection durations

- Deployment diagrams or architecture reviews confirming the presence of PQC-based protections for data at rest, in transit, and in use

- Configuration templates or control libraries that enforce algorithm and key-type selection based on classification tags

##### Level 4 - Advanced

**Question**: How does your organization validate protection controls?

**Explanation**: This examines your approach to verifying that quantum-resistant data protection controls are correctly implemented and delivering the intended level of security across different environments.

**Options**:


1. **Basic**: No validation process exists

2. **Developing**: Manual testing of protection controls with limited coverage or frequency

3. **Established**: Structured validation process using tools and regular test schedules for all implemented controls

4. **Advanced**: Continuous automated validation integrated with control monitoring and quantum-aware threat modeling

**Evidence to Look For**:


- Validation procedures describing how post-quantum encryption or signing controls are tested across environments and control types

- Test plans and result logs confirming correct implementation of hybrid algorithms in production or staging systems

- Tool output or reports verifying that controls enforce required key lengths, algorithms, and modes aligned with classification levels

- Integration of validation results into dashboards or ticketing systems for automated tracking and incident handling

##### Level 5 - Optimizing

**Question**: How does your organization tailor data protection requirements for constrained or specialized environments?

**Explanation**: This examines whether your protection requirements account for platform-specific constraints—such as limited hardware, fragmented protocols, or cloud-native designs—especially in IoT, embedded, industrial, or multi-cloud systems.

**Options**:


1. **Basic**: No distinction is made for environment-specific protection needs

2. **Developing**: Ad-hoc adjustments to protection requirements in constrained systems

3. **Established**: Defined protection profiles per environment (e.g., cloud, IoT, OT) with risk-based exceptions

4. **Advanced**: Centralized policy engine that enforces environment-aware protection requirements and supports automated updates

**Evidence to Look For**:


- Protection requirement documents that differentiate environments by hardware or software constraints

- Profiles or templates specifying what algorithms, key sizes, or formats are acceptable in IoT, mobile, or cloud systems

- Assessment reports evaluating feasibility of PQC enforcement in embedded systems or bandwidth-constrained devices

- Policy exception handling procedures that justify trade-offs for non-standard environments (e.g., LoRaWAN, legacy RTOS)

#### Stream B: Strategy & Innovation (40%)

##### Level 1 - Basic

**Question**: How does your organization define protection strategies based on data lifecycle and retention needs?

**Explanation**: This examines your organization’s strategic approach to aligning quantum-resistant protections with data lifecycles—ensuring that encryption and integrity controls remain valid for the duration the data must remain secure or verifiable.

**Options**:


1. **Basic**: No strategy exists to align protection with data lifecycle or retention needs

2. **Developing**: Retention durations are tracked, but not tied to protection strength or algorithm choice

3. **Established**: Strategy maps data types to protection durations based on classification and quantum risk

4. **Advanced**: Lifecycle-driven protection strategies with automated tagging, enforcement, and retirement policies

**Evidence to Look For**:


- Documentation linking data protection durations to classification levels and cryptographic control choices

- Mapping of backup/archive data to protection requirements based on expected confidentiality or authenticity needs

- Procedures for retiring, reclassifying, or re-encrypting long-lived data as quantum capabilities evolve

- Integration with data governance tools that apply or enforce protection policies over time based on lifecycle events

##### Level 2 - Developing

**Question**: How does your organization define protection strategies for unstructured or semi-structured data?

**Explanation**: This examines whether your data protection strategy explicitly addresses hard-to-classify data types—such as email, documents, collaboration tools, messaging logs, or data lakes—which may contain quantum-sensitive information.

**Options**:


1. **Basic**: No strategy exists for protecting unstructured or semi-structured data

2. **Developing**: General protections applied without specific quantum-related considerations

3. **Established**: Strategy defines classification and protection guidelines for unstructured data formats

4. **Advanced**: Quantum-risk-aware tools and policies are applied to unstructured data discovery, tagging, and control enforcement

**Evidence to Look For**:


- Protection strategies that include categories like email, messaging data, fileshares, or long-lived archives

- Use of discovery tools that classify or tag unstructured data with quantum-relevant metadata

- Risk assessments showing potential exposure from unstructured sources (e.g., email archives with PII or legal records)

- Policies requiring reclassification or re-encryption of older archives as quantum risk increases

##### Level 3 - Established

**Question**: How does your organization measure the effectiveness of data protection controls?

**Explanation**: This examines your approach to assessing whether applied data protection controls meet their intended objectives—such as correctly aligning with data classifications and minimizing residual risk.

**Options**:


1. **Basic**: No measurement process exists for protection control effectiveness

2. **Developing**: Manual tracking of basic coverage metrics for critical systems

3. **Established**: Structured measurement framework assessing protection adequacy by classification, algorithm, and data state

4. **Advanced**: Automated effectiveness monitoring with analytics to identify protection gaps, misalignments, and future risks

**Evidence to Look For**:


- Metrics tracking control implementation coverage across classification tiers and data states (rest, transit, in use)

- Evidence of recurring reviews or simulations that assess whether protections continue to meet data protection requirements over time

- Analysis reports identifying residual risks, coverage gaps, or exceptions where protections fall short of policy or control intent

- Dashboards showing trends in encryption use, key lifecycle enforcement, or classification-to-control alignment across systems

##### Level 4 - Advanced

**Question**: How does your organization identify opportunities to improve data protection controls?

**Explanation**: This examines how your organization uncovers new protection gaps or improvement areas—through testing, quantum threat updates, performance analysis, or feedback from control validation and classification alignment.

**Options**:


1. **Basic**: No process exists for identifying improvements to protection controls

2. **Developing**: Improvements are made on an ad-hoc basis in response to specific issues

3. **Established**: Structured process exists to evaluate improvements through testing, technology tracking, and design review

4. **Advanced**: Automated tools and analytics continuously identify protection improvement opportunities based on risk, performance, and cryptographic readiness

**Evidence to Look For**:


- Use of control performance data (e.g., latency, coverage, algorithm mismatch) to trigger enhancement reviews

- Meeting records or logs where control misalignment with classification requirements led to improvement recommendations

- Tracking of protection gaps that emerged from new data types, system changes, or cryptographic agility limitations

- Output from analytics or simulation tools that flag protection drift, algorithm expiry risk, or control performance degradation

##### Level 5 - Optimizing

**Question**: How does your organization assess the performance of data protection controls?

**Explanation**: This examines how your organization tests and monitors the performance of encryption, key management, and related protection mechanisms—including their impact on system efficiency, usability, and operational feasibility across environments.

**Options**:


1. **Basic**: No performance testing or monitoring of data protection controls exists

2. **Developing**: Informal performance observations are made during implementation or deployment

3. **Established**: Structured performance testing is conducted to evaluate protection control impact across key environments

4. **Advanced**: Ongoing performance monitoring and benchmarking inform protection control tuning, design decisions, and trade-offs

**Evidence to Look For**:


- Performance test reports comparing encryption or key management overhead to system benchmarks or baseline configurations

- Defined thresholds or performance budgets for latency, memory usage, or throughput related to data protection mechanisms

- Simulation or testbed results showing how protection control choices impact performance in representative workloads

- Analysis reports that identify performance bottlenecks tied to specific protection implementations or configuration states

### Practice 3.2: Storage Security & Encryption Management

**Outcome**: Robust storage security measures that ensure data confidentiality and integrity remains protected against quantum attacks throughout the data's storage lifetime.

#### Stream A: Implementation & Controls (60%)

##### Level 1 - Basic

**Question**: How does your organization ensure that symmetric encryption for sensitive stored data is secure against quantum algorithms?

**Explanation**: This examines how your organization applies and validates symmetric encryption controls for data at rest, ensuring that key sizes, encryption algorithms, and system design provide sufficient security against quantum computing threats and can be updated over time.

**Options**:


1. **Basic**: No symmetric encryption controls are implemented for stored data

2. **Developing**: Standard encryption is applied but key sizes are not quantum-resistant and storage systems lack support for future upgrades

3. **Established**: Symmetric encryption with quantum-resistant key sizes is used and storage platforms support upgrades to algorithms or key lengths

4. **Advanced**: Symmetric encryption controls are enforced through automated policies with built-in cryptographic agility for key size updates and algorithm evolution

**Evidence to Look For**:


- Encryption policies requiring AES-256 or equivalent quantum-resilient symmetric encryption for sensitive stored data

- System design documents showing that storage platforms can accommodate longer keys or alternative encryption modes

- Configuration management tools that enforce approved encryption standards and flag legacy key sizes

- Procedures for re-encryption or key upgrade of stored data as new symmetric standards or threats emerge

##### Level 2 - Developing

**Question**: How does your organization manage encryption keys for stored data in an agile manner?

**Explanation**:This examines your organization’s approach to the lifecycle management of encryption keys for data at rest, including generation, storage, rotation, retirement, and readiness to adapt to quantum-safe key types or wrapping mechanisms.

**Options**:


1. **Basic**: No formal key management process exists for stored data

2. **Developing**: Keys are manually handled with limited support for rotation or upgrades

3. **Established**: Structured key management system supports key generation, secure storage, and rotation

4. **Advanced**: Automated key lifecycle management is implemented with cryptographic agility for key formats, wrapping, and dynamic upgrades

**Evidence to Look For**:


- Key management policies that specify secure key generation, storage, rotation, and retirement processes

- Use of HSMs, KMS platforms, or cryptographic libraries that support modular or policy-driven key lifecycle control

- Automation or orchestration systems that enforce key rotation schedules and flag expired, unused, or misconfigured keys

- Evidence of role-based or environment-specific key management rules (e.g., different lifecycles for archive vs. operational data)

##### Level 3 - Established

**Question**: How does your organization ensure strong, adaptable protection and recoverability for backup and archived data?

**Explanation**: This examines your organization’s approach to securing backup and archived data over extended retention periods, including the use of encryption, key management practices, and recovery validation that can support evolving cryptographic requirements.

**Options**:


1. **Basic**: No cryptographic protections are applied to backup or archived data

2. **Developing**: Backups are encrypted, but protection does not account for long-term retention needs or future cryptographic changes

3. **Established**: Structured framework applies strong encryption and retention-aware protection policies to backup and archival systems

4. **Advanced**: Backup systems enforce encryption and key lifecycle policies that support long-term recoverability and cryptographic adaptability

**Evidence to Look For**:


- Retention policies identifying data classes that require protection beyond standard operational timeframes

- Backup system configurations showing integration with key management systems that support lifecycle controls and algorithm updates

- Recovery testing results demonstrating that long-term encrypted backups remain accessible and verifiable after changes to encryption algorithms or key policies

- Architecture reviews or platform support confirmations showing that backup systems can accommodate changes to key size, encryption mode, or wrapping formats

##### Level 4 - Advanced

**Question**: How does your organization ensure long-term cryptographic integrity of stored and archived data?

**Explanation**: This examines how your organization applies integrity protections—such as digital signatures, hashes, and time-stamps—to detect tampering in stored or archived data and ensure those mechanisms remain effective over the full data retention period.

**Options**:


1. **Basic**: No integrity protections are applied to stored or archived data

2. **Developing**: Hashing or signing is applied inconsistently without consideration of retention duration or algorithm longevity

3. **Established**: Integrity protections are systematically applied using cryptographic algorithms selected for long-term effectiveness

4. **Advanced**: Integrity mechanisms are paired with time-stamping or re-signing strategies and support upgrades as cryptographic standards evolve

**Evidence to Look For**:


- Use of digital signatures or hashes to verify authenticity of backups, logs, or archived documents

- Procedures for re-signing or re-hashing stored data as algorithms are deprecated or replaced

- Use of cryptographic libraries or storage platforms that support algorithm agility and integrity reprocessing

- Policies specifying how integrity protections are maintained for data requiring verification many years after creation

##### Level 5 - Optimizing

**Question**: How does your organization test whether storage encryption and key management controls are strong enough for long-term resilience, including future quantum threats?

**Explanation**: This examines your organization's approach to verifying that encryption and key management controls for stored data are correctly implemented and offer sufficient protection against quantum computing threats, including regular testing of algorithm strength, configuration, and cryptographic effectiveness.

**Options**:


1. **Basic**: No validation process exists for storage cryptographic protections

2. **Developing**: Manual checks are performed on encryption configuration without quantum-specific considerations

3. **Established**: Structured testing process validates encryption algorithms, key sizes, and storage-specific controls against quantum risk factors

4. **Advanced**: Automated validation processes continuously assess storage protections and flag deviations from quantum-resilient standards

**Evidence to Look For**:


- Testing reports verifying implementation of AES-256, hybrid key wrapping, or authenticated encryption modes

- Tools or scripts used to scan storage platforms for cryptographic misconfigurations or legacy algorithms

- Simulated failure scenarios that test the impact of expired, weak, or misconfigured keys in storage systems

- Validation coverage maps showing which storage environments (e.g., on-prem, cloud, backups) meet quantum-resistant control requirements

#### Stream B: Strategy & Innovation (40%)

##### Level 1 - Basic

**Question**: How is your organization’s storage security strategy designed to support long-term data protection and resilience?

**Explanation**: This examines your approach to building a strategic framework for protecting stored data over time, including how your architecture, encryption models, and lifecycle policies account for data retention timelines, algorithm management, and evolving cryptographic requirements.

**Options**:


1. **Basic**: No strategic storage protection planning is in place

2. **Developing**: General storage encryption guidelines exist, but retention and long-term protection needs are not addressed

3. **Established**: Structured storage security strategy accounts for retention timelines, encryption strength, and business risk

4. **Advanced**: Storage protection strategy integrates retention-aware encryption, cryptographic lifecycle planning, and agility across storage environments

**Evidence to Look For**:


- Storage security strategy documents that define protection requirements based on data classification and retention duration

- Architecture or system design materials showing support for strong encryption (e.g., AES-256), authenticated encryption, and modular cryptographic controls

- Retention-aware encryption policies that require re-encryption or rekeying for long-lived or archived data

- Integration of encryption lifecycle considerations into broader storage planning, procurement, or system refresh strategies

##### Level 2 - Developing

**Question**: How does your organization assess the upgrade and cryptographic support constraints of storage systems?

**Explanation**: This examines your organization’s ability to evaluate whether storage platforms can support current and future encryption requirements, considering factors such as key size support, algorithm agility, re-encryption feasibility, and performance or architectural limitations.

**Options**:


1. **Basic**: No assessment of storage system compatibility with encryption requirements exists

2. **Developing**: Informal assessments are performed for select systems only

3. **Established**: Structured process evaluates cryptographic capabilities, upgrade feasibility, and rekeying constraints across storage platforms

4. **Advanced**: Cryptographic support and upgrade limitations are routinely evaluated and integrated into refresh planning, procurement, and protection strategies

**Evidence to Look For**:


- Inventory of storage platforms annotated with supported encryption modes, key sizes, and known limitations

- Architecture diagrams identifying whether systems can support quantum-resistant key sizes for symmetric algorithms, authenticated encryption, or algorithm migration

- Assessment reports evaluating re-encryption feasibility, key length support, or performance limitations in legacy storage

- Tracking of vendor support for quantum-safe encryption, cryptographic agility, and key management integration in storage systems

##### Level 3 - Established

**Question**: How does your organization measure the effectiveness of encryption and key management controls used to protect stored data?

**Explanation**: This examines how your organization evaluates whether its storage security controls—such as encryption strength, key lifecycle enforcement, and protection coverage—are correctly implemented and sufficient to meet both current security needs and long-term data protection requirements, including emerging threats like quantum decryption.

**Options**:


1. **Basic**: No measurement process exists for evaluating storage security controls

2. **Developing**: Manual tracking of encryption and key use with limited assessment of adequacy or coverage

3. **Established**: Structured measurement framework assesses control effectiveness by algorithm strength, coverage, and retention alignment

4. **Advanced**: Effectiveness metrics are integrated into ongoing review processes and used to adjust protections based on control performance, risk, and cryptographic evolution

**Evidence to Look For**:


- Metrics tracking algorithm use, key sizes, and encryption mode coverage across storage systems

- Assessment reports linking data retention or classification to encryption strength and key management practices

- Audit logs or monitoring outputs identifying expired, weak, or misconfigured encryption for stored data

- Trend analysis of encryption posture across backup, archive, and primary storage environments

##### Level 4 - Advanced

**Question**: How does your organization identify opportunities to improve the security of encryption and key management for stored data?

**Explanation**: This examines how your organization detects and evaluates potential improvements to storage encryption and key lifecycle controls, including response to control weaknesses, emerging threats, and evolving requirements such as retention timelines or cryptographic standards.

**Options**:


1. **Basic**: No process exists for identifying improvements to storage encryption or key management

2. **Developing**: Improvements are made informally in response to known weaknesses or incidents

3. **Established**: Structured process is used to evaluate encryption and key management improvements through testing, benchmarking, or architectural review

4. **Advanced**: Improvement opportunities are identified based on control validation results, monitoring data, and anticipated shifts in cryptographic or operational requirements

**Evidence to Look For**:


- Process documentation outlining how storage security weaknesses are identified and prioritized for improvement

- Records showing use of test environments or validation findings to evaluate new encryption strategies or key handling techniques

- Monitoring reports that flag recurring configuration issues, weak key usage, or performance-related degradation

- Evidence that algorithm, key size, or configuration upgrades are planned in response to long-term data retention or threat horizon considerations

##### Level 5 - Optimizing

**Question**: How does your organization enhance its storage encryption and key management capabilities over time?

**Explanation**: This examines your organization’s approach to advancing storage security by continuously evolving encryption methods, key lifecycle processes, and system capabilities in response to emerging threats, technology advancements, and long-term data protection requirements.

**Options**:


1. **Basic**: No structured enhancement of storage security capabilities is performed

2. **Developing**: Capability updates are applied as needed, without a formal review process

3. **Established**: Enhancements are driven by regular assessments of security needs, system performance, and cryptographic alignment

4. **Advanced**: Storage security capabilities are continuously improved through structured planning, periodic reviews, and targeted adoption of features aligned with evolving data protection needs

**Evidence to Look For**:


- Strategy documents outlining long-term goals for improving storage encryption, key management, and lifecycle enforcement

- Records of research, pilot projects, or POCs evaluating new cryptographic techniques or storage security technologies

- Internal reviews identifying capability gaps and corresponding remediation or enhancement roadmaps

- Adoption of advanced features (e.g., algorithm agility, dynamic rekeying, self-validating storage) in enterprise storage platforms

### Practice 3.3: Transit Security & Protocol Management

**Outcome**: Secure communications infrastructure that protects data in motion using quantum-resistant protocols and controls that maintain confidentiality and integrity.

#### Stream A: Implementation & Controls (60%)

##### Level 1 - Basic

**Question**: How does your organization implement cryptographic protections within data-in-transit protocols?

**Explanation**: This examines how your organization applies cryptographic mechanisms—such as encryption, digital signatures, key exchange, and authentication—within communication protocols to protect data in transit from interception, tampering, or spoofing.

**Options**:


1. **Basic**: No cryptographic protections are applied to data in transit

2. **Developing**: Standard transit protocols with default cryptographic settings are used

3. **Established**: Transit protocols are configured with strong cryptographic settings, aligned with policy and coverage expectations

4. **Advanced**: Cryptographic protections are consistently applied and validated across protocols, with automated configuration enforcement and cryptographic agility support

**Evidence to Look For**:


- Documentation of protocols used for securing data in transit (e.g., TLS 1.2+, IPsec, SSH, QUIC)

- Configuration records enforcing key exchange methods and cipher suites

- Inventory of communication services and whether they support authenticated and encrypted sessions

- Policy documents requiring the use of cryptographic protections for specific communication types (e.g., APIs, file transfers, internal service calls)

##### Level 2 - Developing

**Question**: How does your organization manage secure communication protocols?

**Explanation**: This examines your approach to selecting, configuring, and maintaining communication protocols that provide encryption, authentication, and integrity for data in transit, ensuring they are securely implemented, interoperable, and aligned with organizational requirements.

**Options**:


1. **Basic**: No protocol management exists

2. **Developing**: Secure protocols are used, but configurations vary and are not centrally managed

3. **Established**: Structured protocol management approach ensures standardization and proper configuration across systems

4. **Advanced**: Protocol configurations are centrally managed and continuously enforced using automation and monitoring tools

**Evidence to Look For**:


- Documentation of protocol configuration standards (e.g., required TLS versions, cipher suites, authentication methods)

- Regular reviews or audits of protocol usage and settings across systems and environments

- Decommissioning or mitigation plans for deprecated protocols (e.g., SSL 3.0, TLS 1.0/1.1)

- Procedures for validating interoperability and secure deployment of new protocol versions or services

##### Level 3 - Established

**Question**: How does your organization ensure trusted identity and authentication in secure network communications?

**Explanation**: This examines your approach to enforcing trust models in transit security—ensuring that endpoints are authenticated and that cryptographic protections provide not only encryption but also integrity and verified identity across systems and services.

**Options**:


1. **Basic**: No authentication or identity validation is used in network communications

2. **Developing**: Authentication is implemented using default or self-managed certificates

3. **Established**: Trusted identity is enforced through structured certificate management and authenticated protocol configurations

4. **Advanced**: Authentication and trust models are centrally managed with automated issuance, validation, and revocation across the network environment

**Evidence to Look For**:


- Use of mutual TLS (mTLS), IPsec with IKE authentication, or SSH key verification for high-trust communications

- Documentation of certificate management practices (issuance, renewal, revocation) for network-facing systems

- Configuration of protocols to validate peer identity (e.g., TLS client authentication, signed tokens, validated public keys)

- Tools or platforms used to automate trust policy enforcement and certificate lifecycle monitoring

##### Level 4 - Advanced

**Question**: How does your organization enforce minimum cryptographic standards to prevent downgrade attacks in data-in-transit protocols?

**Explanation**: This examines how your organization ensures that communication protocols reject insecure configurations and prevent fallback to deprecated cryptographic settings—such as weak cipher suites, insecure versions, or unauthenticated channels.

**Options**:


1. **Basic**: No controls exist to prevent the use of insecure or deprecated protocols

2. **Developing**: Protocols support secure options, but fallback to weaker settings is not restricted

3. **Established**: Enforcement mechanisms ensure that insecure protocol versions or ciphers are disabled and downgrade attempts are logged

4. **Advanced**: Centralized controls and monitoring systems detect and block protocol downgrade behavior with real-time enforcement and analytics

**Evidence to Look For**:


- Policies or scanning tools that block use of deprecated protocols (e.g., SSL, TLS 1.0/1.1, anonymous cipher suites)

- Alerts or audit logs identifying downgrade attempts or unauthorized protocol negotiations

- Use of tools such as SMTP MTA-STS, DNSSEC, HSTS, or DANE to enforce authenticated secure connections in email and web communications

- Enforcement of STARTTLS, TLS_FALLBACK_SCSV, or similar mechanisms to prevent stripping or forced fallback

##### Level 5 - Optimizing

**Question**: How does your organization validate the effectiveness of cryptographic protections used in transit protocols?

**Explanation**: This examines your approach to testing and verifying whether the encryption, key exchange, authentication, and integrity protections used in transit protocols are correctly implemented and aligned with security objectives.

**Options**:


1. **Basic**: No validation process exists for cryptographic protections in transit protocols

2. **Developing**: Functional testing is performed, but cryptographic settings and security assumptions are not consistently verified

3. **Established**: Structured validation process tests encryption strength, authentication mechanisms, and protocol configurations across communication channels

4. **Advanced**: Transit security validations are automated, integrated into system testing, and continuously updated to reflect evolving cryptographic requirements

**Evidence to Look For**:


- Validation logs showing detection of weak configurations, protocol downgrade paths, or unauthenticated sessions

- Penetration testing or red team results that include simulated attacks on communication protocols (e.g., STARTTLS stripping, insecure API traffic)

- Integration of protocol validation into CI/CD pipelines, configuration management tools, or change control processes

- Use of scanning tools to detect outdated or vulnerable protocol implementations (e.g., TLS 1.0/1.1, insecure ciphers)

#### Stream B: Strategy & Innovation (40%)

##### Level 1 - Basic

**Question**: How does your organization define its approach to protecting data in transit?

**Explanation**: This examines whether your organization has established a clear, documented foundation for protecting data in transit, including guidance on protocol selection, encryption requirements, and key management responsibilities.

**Options**:


1. **Basic**: No defined approach or documentation exists for securing data in transit

2. **Developing**: Fundamental security guidelines exist, but they are informal or applied inconsistently

3. **Established**: Documented approach guides the use of transit protection protocols and cryptographic settings across the organization

4. **Advanced**: The transit security approach is updated based on evolving requirements, technical assessments, and integration with broader security planning

**Evidence to Look For**:


- Documented policies or standards outlining acceptable encryption protocols and configurations for data in transit

- Strategy documents or guidelines addressing protection of internal and external communication paths

- System or network architecture diagrams indicating where transit protections (e.g., TLS, VPNs) are required

- Defined responsibilities for maintaining protocol security, including certificate or key lifecycle

##### Level 2 - Developing

**Question**: How does your organization prioritize communication channels for enhanced cryptographic protection?

**Explanation**: This examines how your organization determines which systems or communication paths receive stronger transit protections—based on factors such as data sensitivity, threat exposure, business impact, and technical feasibility.

**Options**:


1. **Basic**: No prioritization process exists for securing communication channels

2. **Developing**: General criteria are used to guide which communications should be protected, but prioritization is informal or inconsistent

3. **Established**: Structured prioritization framework evaluates communication paths based on risk, sensitivity, and operational requirements

4. **Advanced**: Multi-factor prioritization model is used to guide deployment of transit protections based on real-time risk, value, and system context

**Evidence to Look For**:


- Documentation of prioritization criteria for protecting communication channels (e.g., public vs. internal, high-volume APIs, executive communications)

- Risk assessments or data flow maps identifying channels with the highest exposure or sensitivity

- Methodology documents outlining how communication systems are ranked or tiered for protection deployment

- Adjustments to protection rollout based on operational constraints (e.g., bandwidth, protocol limitations, dependency mapping)

##### Level 3 - Established

**Question**: How does your organization manage and validate trust anchors for secure communication protocols?

**Explanation**: This examines your approach to managing root certificates, public keys, and trust stores used in transit protocols—ensuring that connections are authenticated against current, trusted authorities and that revocation or compromise is handled effectively.

**Options**:


1. **Basic**: Trust anchors and certificate validation are not actively managed

2. **Developing**: Default or unmanaged trust stores are used, with minimal oversight

3. **Established**: Trust anchors are reviewed and managed using structured procedures for validation, rotation, and revocation

4. **Advanced**: Certificate and trust anchor management is automated, regularly audited, and integrated with real-time revocation and alerting mechanisms

**Evidence to Look For**:


- Inventory or documentation of trusted CAs, certificate chains, or SSH key authorities used in communication protocols

- Policies defining how root and intermediate certificates are validated, approved, and rotated

- Use of certificate management platforms or automation for issuance, renewal, and revocation

- Regular review processes to remove unused or outdated CAs and monitor third-party trust anchor integrity

##### Level 4 - Advanced

**Question**: How does your organization assess and enforce cryptographic protections in third-party or externally managed communication channels?

**Explanation**: This examines your approach to ensuring that cryptographic protections—such as encryption, authentication, and protocol strength—are applied effectively to data in transit even when the communication path is partially or fully controlled by external providers, partners, or vendors.

**Options**:


1. **Basic**: No visibility or validation of cryptographic protections for third-party or vendor-managed communication paths

2. **Developing**: Reliance on third-party assurances or default encryption settings without active validation

3. **Established**: Cryptographic requirements are defined and enforced through contracts, technical assessments, or integration standards

4. **Advanced**: External communication protections are continuously monitored, tested, and governed through security SLAs, audits, and automated trust enforcement

**Evidence to Look For**:


- Contractual or SLA requirements specifying encryption and authentication standards for third-party communications

- Use of tools to scan or test cryptographic posture of APIs, email relays, or SaaS endpoints (e.g., TLS certs, protocol configs)

- Participation in shared protocol management frameworks (e.g., MTA-STS, DANE, mutual TLS) with external partners

- Logs or reports showing validation of encryption and authentication settings for federated, outsourced, or cloud-based services

##### Level 5 - Optimizing

**Question**: How does your organization plan for interoperability and backward compatibility during cryptographic transitions in transit protocols?

**Explanation**: This examines how your organization manages the risks and dependencies associated with upgrading transit-layer cryptography—ensuring that secure communication remains functional across legacy systems, third-party clients, and modern endpoints during algorithm or protocol changes.

**Options**:


1. **Basic**: No consideration is given to interoperability during cryptographic upgrades

2. **Developing**: Compatibility issues are handled informally or reactively during transitions

3. **Established**: Upgrade planning includes documented strategies for backward compatibility

4. **Advanced**: Cryptographic transitions are guided by interoperability testing, staged rollouts, and automated fallback strategies

**Evidence to Look For**:


- Documentation of upgrade plans that assess impact on legacy or third-party systems during cryptographic changes

- Architecture diagrams or configuration files supporting dual-stack (e.g., hybrid) implementations in TLS or VPNs

- Records of internal or vendor-supported interoperability testing for cryptographic transitions (e.g., new TLS libraries, PQ-ready clients)

- Mitigation strategies to handle failures or incompatibility with older clients (e.g., logging, alerts, fallback policies)

## CMMC Alignment

CMMC SC.1.175: Monitor, control, and protect organizational communications

CMMC SC.2.179: Use encrypted sessions for the management of network devices

CMMC MP.3.123: Mark media with necessary security markings and distribution limitations

CMMC RM.2.143: Remediate vulnerabilities in accordance with risk assessments

## Integration with Other Dimensions

**Inputs from CVI**: Cryptographic asset inventory informs protection needs

**Inputs from SGRM**: Risk assessment results guide protection priorities

**Outputs to ITR**: Protection requirements drive implementation planning

**Outputs to ORC**: Protected services inform continuity planning

**Outputs to WOE**: Protection technologies define skills requirements

**Inputs from quantum computing monitoring**: Timeline updates for algorithm transitions

**Outputs to vendor management**: Quantum-resistant requirements for data protection solutions

## Industry-Specific Considerations

**Financial Services**: Payment card data, financial transactions, customer records, long-term financial agreements

**Healthcare**: Protected health information, medical imaging, patient records, lifetime health data repositories

**Government**: Classified information, citizen data, critical communications, national security information

**Manufacturing**: Intellectual property, industrial designs, supply chain data, long-lifecycle product specifications

## Cryptographic Agility Framework

Key management systems designed for algorithm transition

Protocol selection and implementation supporting multiple algorithms

Data format standards facilitating encryption algorithm changes

Performance monitoring during cryptographic transitions

Testing framework for validating cryptographic agility

## Quantum-Resistant Key Management

Extended key lifecycle management for quantum era

Strategies for secure key distribution in post-quantum environment

Hybrid key approaches during transition periods

Key rotation strategies aligned with quantum computing timeline

Secure key storage resistant to retroactive decryption


---

#  Dimension 4: Implementation & Technical Readiness (ITR)

*Understanding and cataloging organizational capabilities*

#  Dimension 4: Implementation & Technical Readiness (ITR)

*Understanding and cataloging organizational capabilities*

## Purpose

Ensure technical capabilities and infrastructure are in place to implement and maintain quantum-resistant solutions.

## Strategic Value

Provides a clear understanding of technical readiness for quantum-safe transition

Establishes frameworks for planning and implementing quantum-resistant solutions

Ensures quality and compliance of quantum-safe implementations

Creates capability for ongoing testing and validation of quantum-resistant solutions

Enables effective cryptographic agility through technical architecture

Addresses performance considerations of post-quantum implementations

## Practice Areas

### Practice 4.1: Infrastructure Assessment & Planning

**Outcome**: A comprehensive understanding of infrastructure readiness and a clear roadmap for implementing quantum-resistant solutions across the technical environment.

#### Stream A: Implementation & Controls (60%)

##### Level 1 - Basic

**Question**: How does your organization assess the cryptographic agility and quantum readiness of its technical infrastructure?

**Explanation**: This examines how your organization evaluates infrastructure components—such as hardware, software platforms, network devices, and cryptographic interfaces—for their ability to support evolving cryptographic requirements, including algorithm upgrades, larger key sizes, and the adoption of quantum-resistant protocols.

**Options**:


1. **Basic**: No infrastructure assessment is performed for cryptographic agility or quantum readiness

2. **Developing**: Ad-hoc reviews identify some cryptographic limitations, but do not evaluate agility or upgrade support

3. **Established**: Structured methodology evaluates infrastructure components for cryptographic agility and upgrade constraints

4. **Advanced**: Continuously updated assessment program identifies cryptographic limitations and supports agile, standards-aligned transition planning

**Evidence to Look For**:


- Assessment documentation identifying systems unable to adapt cryptographic settings (e.g., hardcoded algorithms, fixed cipher suites), support for hybrid cryptography, crypto module upgradability, or protocol negotiation

- Infrastructure maps showing which platforms support modular or configurable cryptographic libraries

- Reports highlighting firmware, embedded systems, or hardware accelerators that limit key size or algorithm changes

- Integration of cryptographic agility assessments into infrastructure lifecycle, procurement, or system design reviews

##### Level 2 - Developing

**Question**: How does your organization plan infrastructure upgrades to support cryptographic agility and quantum readiness?

**Explanation**: This examines how your organization prepares its infrastructure for cryptographic transitions—developing upgrade plans that account for flexibility in algorithm use, compatibility with evolving cryptographic standards, and the future adoption of quantum-resistant algorithms.

**Options**:


1. **Basic**: No planning exists to support cryptographic upgrades or agility

2. **Developing**: Preliminary upgrade planning considers critical systems but lacks cryptographic flexibility or timelines

3. **Established**: Structured upgrade procedures address cryptographic agility and include timelines and dependency mapping

4. **Advanced**: Comprehensive infrastructure upgrade program incorporates algorithm agility, resource alignment, and coordinated rollout scenarios

**Evidence to Look For**:


- Infrastructure planning documents that reference algorithm agility or hybrid cryptographic support as upgrade drivers

- Preliminary migration paths identifying which systems will require cryptographic library or API changes

- Architecture reviews or dependency maps that highlight systems constrained by static cryptographic choices

- Documentation of fallback or coexistence strategies for systems unable to immediately support new cryptographic algorithms

##### Level 3 - Established

**Question**: How does your organization evaluate cryptographic hardware readiness for quantum-era requirements?

**Explanation**: This examines how your organization assesses the ability of its hardware-based cryptographic modules—such as HSMs, TPMs, or offload engines—to support key size expansion, hybrid key management, and future algorithm migration necessary for cryptographic agility and quantum resilience.

**Options**:


1. **Basic**: No evaluation of cryptographic hardware readiness is performed

2. **Developing**: Basic documentation identifies which systems rely on cryptographic hardware, but quantum or agility support is not considered

3. **Established**: Structured assessments verify cryptographic agility features, PQC roadmap alignment, and hardware constraints

4. **Advanced**: Comprehensive evaluation integrates vendor capability tracking, firmware upgrade planning, and fallback scenarios into system architecture and procurement

**Evidence to Look For**:


- Inventory of HSMs and cryptographic hardware modules annotated with supported algorithms, key sizes, and upgradeability

- Vendor documentation or assessments identifying PQC compatibility plans or firmware support timelines

- Architecture reviews showing how hardware modules integrate with key lifecycle management and support fallback mechanisms

- Assessment of bottlenecks caused by non-upgradable or constrained HSMs in key operational paths

##### Level 4 - Advanced

**Question**: How does your organization identify and address cryptographic upgrade blockers in legacy or third-party systems?

**Explanation**: This examines whether your organization actively discovers systems—including legacy applications, third-party platforms, or unmanaged devices—that may delay or prevent adoption of new cryptographic algorithms due to architectural, licensing, or vendor limitations.

**Options**:


1. **Basic**: No process exists to identify or manage upgrade blockers across systems

2. **Developing**: Blockers are discovered reactively during upgrades, without centralized tracking

3. **Established**: Structured assessments and system reviews proactively flag upgrade blockers and inform remediation planning

4. **Advanced**: Upgrade blockers are continuously monitored and integrated into system lifecycle management, procurement, and roadmap planning

**Evidence to Look For**:


- Inventory of known cryptographic upgrade blockers including hardcoded protocols, deprecated libraries, or unmodifiable vendor systems

- Risk or prioritization reports that flag systems lacking cryptographic agility or upgrade paths

- Remediation plans showing workarounds for third-party constraints (e.g., TLS proxies, termination points, vendor engagement)

- Exception workflows for systems where upgrades are not currently feasible

##### Level 5 - Optimizing

**Question**: How does your organization incorporate cryptographic agility requirements into system and software design processes?

**Explanation**: This examines how cryptographic flexibility—such as support for multiple algorithms, pluggable crypto libraries, or hybrid key configurations—is considered and documented during design and architecture phases of new systems, platforms, or software components.

**Options**:


1. **Basic**: Cryptographic design flexibility is not considered in system or software planning

2. **Developing**: Some systems support cryptographic configuration

3. **Established**: Architecture and design standards require support for algorithm agility

4. **Advanced**: Cryptographic agility requirements are embedded into architecture templates, design reviews, and development frameworks across all systems

**Evidence to Look For**:


- Design documents or architecture patterns that specify modular cryptography or hybrid support (e.g., algorithm plug-ins, crypto policies)

- Secure design guidelines requiring use of crypto-abstraction layers or policy-driven cipher configuration

- Developer-facing templates or frameworks that enforce cryptographic decoupling (e.g., avoid hardcoding)

- Integration of cryptographic agility criteria into architecture govern and CI/CD

#### Stream B: Strategy & Innovation (40%)

##### Level 1 - Basic

**Question**: How does your organization plan for cryptographic upgrade sequencing and dependency management?

**Explanation**: This examines how your organization identifies and plans for system, service, and vendor interdependencies that affect the order and coordination of cryptographic upgrades—ensuring upgrades are phased to avoid disruption, misalignment, or security gaps during the quantum transition.

**Options**:


1. **Basic**: No planning is done to manage dependencies or sequence cryptographic upgrades

2. **Developing**: Informal sequencing occurs reactively during transitions, based on known issues

3. **Established**: Structured planning accounts for technical dependencies, interoperability constraints, and critical path systems

4. **Advanced**: Cryptographic upgrade sequencing is driven by modeling tools, dependency maps, and coordination with internal and external stakeholders

**Evidence to Look For**:


- Dependency maps or architecture diagrams showing cryptographic trust relationships and upgrade order

- Transition roadmaps that identify and phase upgrades across systems with shared certificates, libraries, or protocols

- Risk or impact assessments used to prioritize sequencing (e.g., high-value systems first, or gateway systems that enable downstream upgrades)

- Vendor communication plans or SLA amendments aligning upgrade timelines across third-party services

##### Level 2 - Developing

**Question**: How does your organization provide technical environments and tooling to support cryptographic transition planning and implementation?

**Explanation**: This examines whether your organization has established the environments, tools, and cryptographic test infrastructure required to evaluate, prototype, and validate new algorithms, certificate types, key management models, and transition strategies in a controlled setting.

**Options**:


1. **Basic**: No dedicated environments or tools exist for cryptographic testing or transition simulation

2. **Developing**: Ad-hoc test setups are created manually, with limited support for modern cryptographic libraries or PQC experimentation

3. **Established**: Dedicated environments and tooling support cryptographic upgrade validation, protocol testing, and hybrid certificate workflows

4. **Advanced**: Standardized cryptographic test environments are available on demand, with automated test harnesses, toolchains, and CI/CD integrations for crypto transitions

**Evidence to Look For**:


- Cryptographic testbed environments that replicate production infrastructure for PQC and hybrid testing

- Access to libraries (e.g., OpenSSL 3.x, BoringSSL, liboqs, OpenFHE) and cryptographic wrappers in sandboxed or emulated systems

- Test plans or reports showing use of these environments to evaluate compatibility, performance, or fallback behavior

- Automation pipelines that deploy cryptographic test configurations and capture results (e.g., handshake logs, signing outputs)

##### Level 3 - Established

**Question**: How does your organization embed cryptographic agility into system architecture design?

**Explanation**: This examines whether architectural decisions across systems and applications explicitly account for the need to support multiple algorithms, enable seamless cryptographic upgrades, and abstract cryptographic dependencies to minimize transition risks.

**Options**:


1. **Basic**: Cryptographic flexibility is not considered in architectural design decisions

2. **Developing**: Some system designs support algorithm changes, but agility is not standardized across the architecture

3. **Established**: Architectural patterns require cryptographic abstraction and support for algorithm agility, with guidance integrated into system design

4. **Advanced**: Cryptographic agility is a core architectural principle, enforced through design reviews, templates, and automated architecture validation

**Evidence to Look For**:


- Architecture templates or design patterns that enforce modular cryptographic implementations (e.g., policy-driven cipher config, crypto abstraction layers)

- Design review processes or architecture checklists that include cryptographic agility requirements

- Use of interfaces or configuration layers that allow runtime selection or switching of cryptographic algorithms

- Examples of systems using pluggable crypto libraries, hybrid-ready key stores, or dual-algorithm support models

##### Level 4 - Advanced

**Question**: How does your organization define and measure technical milestones for cryptographic transitions?

**Explanation**: This examines whether your organization establishes and tracks concrete, cryptography-specific milestones to guide planning and execution—such as upgrading libraries, introducing hybrid certificates, phasing out weak algorithms, or implementing algorithm agility controls.

**Options**:


1. **Basic**: No technical milestones are defined for cryptographic transition

2. **Developing**: Basic milestones are documented, but not tied to cryptographic risk or agility goals

3. **Established**: Structured cryptographic transition milestones are tracked across systems and aligned to business or regulatory priorities

4. **Advanced**: Cryptographic transition milestones are managed through integrated dashboards with risk-weighted timelines and system-level dependencies

**Evidence to Look For**:


- Cryptographic transition roadmaps showing key milestones like library upgrades, hybrid protocol support, or fallback deprecation

- Tracking systems or dashboards that measure milestone completion across systems or business units

- Milestone definitions linked to risk factors such as key size, algorithm strength, or public exposure

- Revision history showing how cryptographic milestones evolve based on standards updates, test feedback, or vendor readiness

##### Level 5 - Optimizing

**Question**: How does your organization contribute to the development and advancement of technical standards for cryptographic agility and quantum-resistant implementations?

**Explanation**: This examines your organization’s involvement in shaping or advancing cryptographic standards—such as those related to agility, hybrid certificate handling, key management, or post-quantum protocol design.

**Options**:


1. **Basic**: No engagement with cryptographic standards related to agility or quantum resistance

2. **Developing**: Participation in working groups or community discussions, but no technical contribution

3. **Established**: Technical contributions to cryptographic standards or specifications focused on agility or quantum resistance

4. **Advanced**: Leadership role in shaping cryptographic agility or PQC transition standards, including development of reference implementations, testing frameworks, or interoperability models

**Evidence to Look For**:


- Participation in standards bodies (e.g., NIST, IETF, ETSI, ISO) specifically focused on algorithm agility, hybrid certificates, or PQC transition protocols

- Involvement in pilot projects, testbeds, or proofs of concept that validate agile cryptographic standards (e.g., dual-algorithm TLS or certificate chains)

- Open-source code, reference implementations, or deployment feedback influencing agility-related cryptographic standards

- Active participation in interoperability workshops or benchmarking events for post-quantum or agile cryptographic protocols

### Practice 4.2: Implementation Capability Development

**Outcome**: Well-defined technical capabilities and delivery processes to effectively implement quantum-resistant solutions across the organization.

#### Stream A: Implementation & Controls (60%)

##### Level 1 - Basic

**Question**: How does your organization define the technical capabilities required to support quantum-resistant implementation?

**Explanation**: This examines whether your organization has identified the specific skills, technologies, and delivery capabilities needed to implement cryptographic agility and post-quantum upgrades, including where current gaps exist.

**Options**:


1. **Basic**: No capability requirements have been defined for quantum or cryptographic transitions

2. **Developing**: Initial requirements are identified, but coverage is limited and not linked to specific systems or roles

3. **Established**: Structured capability model defines technical roles, tools, and implementation processes needed for quantum-resistant upgrades

4. **Advanced**: Capability requirements are embedded into workforce development, procurement, and delivery planning, with ongoing tracking and refinement

**Evidence to Look For**:


- Capability assessment documents outlining required skills, toolsets, and processes for quantum-resistant implementation

- Mapping of implementation domains (e.g., key management, TLS upgrade, crypto abstraction) to current and needed expertise

- Gap analysis identifying missing tools, process maturity, or technical roles tied to cryptographic agility goals

- Internal documentation describing the technical responsibilities for quantum transitions across delivery teams

##### Level 2 - Developing

**Question**: How does your organization allocate and protect specialized resources for cryptographic implementation and transition efforts?

**Explanation**: This examines whether your organization dedicates and prioritizes the technical resources—such as cryptographic experts, secure environments, and transition-enabling tools—required to support cryptographic upgrades and ensure continuity across agile and post-quantum implementations.

**Options**:


1. **Basic**: No specific resources are allocated for cryptographic implementation or agility-related work

2. **Developing**: Resource needs are documented, but staff or tools are reassigned or under-resourced due to competing priorities

3. **Established**: Dedicated cryptographic implementation teams, tools, and infrastructure are prioritized for transition projects and protected from disruption

4. **Advanced**: Resource prioritization for cryptographic implementation is embedded in strategic planning, with protected capacity across teams, secure environments, and dedicated tooling

**Evidence to Look For**:


- Assignment of dedicated personnel or teams with cryptographic expertise for upgrade and transition activities

- Documentation of resource bottlenecks where cryptographic upgrades were delayed due to competing implementation priorities

- Protected project timelines or environments reserved for cryptographic testing, pilot deployment, or fallback planning

- Tooling or infrastructure (e.g., crypto-aware CI/CD environments, HSM labs, hybrid cert testbeds) allocated and maintained for implementation work

##### Level 3 - Established

**Question**: How does your organization ensure the quality and correctness of cryptographic implementations?

**Explanation**: This examines your organization’s approach to verifying that cryptographic components—such as encryption, key management, and protocol configurations—are implemented securely, follow best practices, and are consistently validated for correctness, resilience, and secure usage across systems.

**Options**:


1. **Basic**: No quality assurance processes are applied to cryptographic implementations

2. **Developing**: Basic code reviews or testing are performed, but cryptographic logic is not systematically verified

3. **Established**: Structured quality program includes cryptographic-specific review, testing, and validation processes across systems

4. **Advanced**: Cryptographic quality is continuously monitored and verified through automated analysis, misuse detection, and secure implementation tooling

**Evidence to Look For**:


- Examples of code reviews or audits focused on cryptographic API usage, key management logic, or secure defaults

- Use of cryptographic analysis tools (e.g., static analyzers, linters, testssl.sh, or protocol fuzzers) to detect insecure configurations or misuse

- Scan reports identifying implementation issues like weak key sizes, hardcoded secrets, or deprecated algorithms

- Integration of cryptographic testing and validation procedures into CI/CD pipelines or security review workflows

##### Level 4 - Advanced

**Question**: How does your organization monitor the operational impact of cryptographic implementations after deployment?

**Explanation**: This examines whether your organization tracks how cryptographic changes—such as new algorithms, larger key sizes, or protocol upgrades—affect system performance, reliability, and user experience, and whether findings are used to inform future implementation improvements.

**Options**:


1. **Basic**: No monitoring is performed after cryptographic changes are deployed

2. **Developing**: Basic monitoring captures performance issues, but is not linked to cryptographic changes

3. **Established**: Structured monitoring processes evaluate the operational effects of cryptographic upgrades and inform remediation

4. **Advanced**: Cryptographic implementation impact is continuously tracked using telemetry, with proactive tuning and adaptive rollout strategies

**Evidence to Look For**:


- Monitoring dashboards or metrics showing latency, throughput, or error rates before and after cryptographic updates (e.g., TLS upgrade, PQC rollout)

- Performance regression reports linked to cryptographic parameters like key length, algorithm type, or certificate format

- Operational logs showing increased failure or handshake time after protocol or algorithm changes

- Documentation of system tuning, rollback, or fallback decisions driven by observed crypto-related degradation

##### Level 5 - Optimizing

**Question**: How does your organization ensure cryptographic implementation libraries, patterns, and tools remain up to date with evolving standards?

**Explanation**: his examines whether your organization maintains its cryptographic development environments, secure coding practices, and supporting tools in line with updated standards, deprecation timelines, and emerging algorithm requirements—ensuring cryptographic changes can be implemented securely over time.

**Options**:


1. **Basic**: No process exists to update cryptographic implementation tools or patterns

2. **Developing**: Updates are applied reactively or informally, without consistent review or tracking

3. **Established**: Structured maintenance processes regularly update crypto libraries, APIs, coding guidance, and implementation templates

4. **Advanced**: Cryptographic libraries, patterns, and tooling are continuously monitored, tested, and updated through automated or lifecycle-integrated processes

**Evidence to Look For**:


- Change logs showing updates to cryptographic libraries or wrappers based on standard deprecations (e.g., NIST, IETF, OpenSSL, BoringSSL)

- Process for tracking algorithm deprecation, new cryptographic recommendations, or secure configuration defaults in development frameworks

- Release notes or integration test reports validating upgrades to cryptographic APIs or library versions

- Use of automated tools (e.g., software composition analysis, dependency scanning) to flag outdated or risky crypto libraries in builds

#### Stream B: Strategy & Innovation (40%)

##### Level 1 - Basic

**Question**: How structured is your delivery process for implementing cryptographic changes?

**Explanation**: This examines whether your organization has established a consistent delivery methodology that is capable of supporting cryptographic transitions—such as algorithm upgrades, certificate changes, or key management enhancements—required for future adoption of quantum-resistant solutions.

**Options**:


1. **Basic**: No defined delivery process exists to support cryptographic transitions

2. **Developing**: Cryptographic changes are delivered informally or within general-purpose project processes, without crypto-specific considerations

3. **Established**: Structured delivery methodology exists that includes cryptographic implementation steps, roles, and transition requirements

4. **Advanced**: Cryptographic transition delivery is supported by a formal, integrated framework designed to accommodate algorithm agility, hybrid models, and PQC migration scenarios

**Evidence to Look For**:


- Documented delivery workflows that include steps for cryptographic rollout or replacement (e.g., certificate updates, algorithm migration, key store changes)

- Templates or checklists for delivering cryptographic components as part of infrastructure or application changes

- Assignments of delivery roles or responsibilities related to cryptographic implementation readiness

- Examples of prior smaller cryptographic upgrades (e.g., TLS version bump, CA migration) used to build delivery muscle for larger transitions

##### Level 2 - Developing

**Question**: How does your organization ensure consistent implementation of cryptographic practices across systems

**Explanation**: This examines whether your organization has established common patterns, standards, and verification methods to ensure cryptographic practices—such as algorithm selection, key management, protocol use, and configuration—are applied uniformly across teams, systems, and environments.

**Options**:


1. **Basic**: No measures are in place to promote consistency in cryptographic implementation

2. **Developing**: Basic guidance or templates exist, but usage is informal and not systematically verified

3. **Established**: Structured program defines and enforces consistent cryptographic practices across systems, supported by review or tooling

4. **Advanced**: Cryptographic consistency is continuously maintained through automated validation, shared modules, and conformance monitoring across the environment

**Evidence to Look For**:


- Standardized cryptographic templates or implementation patterns used across projects and teams

- Guidance documents defining approved algorithm sets, key sizes, or configuration practices

- Audits or reviews identifying inconsistent use of cryptographic settings or libraries across systems

- Use of shared cryptographic libraries or services to enforce implementation consistency

##### Level 3 - Established

**Question**: How does your organization identify and manage risks associated with cryptographic transitions?

**Explanation**: This examines your approach to identifying, assessing, and mitigating risks that arise during cryptographic transitions including technical, architectural, and integration-related risks.

**Options**:


1. **Basic**: No risk management activities are in place for cryptographic transitions

2. **Developing**: Risks are tracked informally during implementation with limited cryptographic specificity

3. **Established**: Structured risk management framework addresses cryptographic implementation risks, including incompatibility, tooling gaps, and fallback failure

4. **Advanced**: Cryptographic risk management is integrated with project delivery, including automated tracking, proactive mitigation, and crypto-specific impact modeling

**Evidence to Look For**:


- Risk registers or threat models that include cryptographic-specific risks (e.g., TLS downgrade risk, unsupported key sizes, vendor delay in PQC support)

- Documentation of risk mitigation plans tied to cryptographic rollouts (e.g., test fallback paths, HSM migration delays, cert lifecycle coordination)

- Playbooks or remediation workflows for crypto-specific failure scenarios (e.g., certificate parsing errors, key mismatch, negotiation failure)

- Tracking tools that integrate cryptographic risks into broader project management dashboards

##### Level 4 - Advanced

**Question**: How does your organization track and benchmark cryptographic delivery outcomes across implementation projects?

**Explanation**: This examines whether your organization evaluates cryptographic delivery efforts for consistency, speed, and success across different teams, environments, or vendors to identify systemic issues and improve readiness.

**Options**:


1. **Basic**: No tracking or benchmarking is performed for cryptographic implementation outcomes

2. **Developing**: Delivery success or delay is recorded informally, without standardized metrics

3. **Established**: Structured metrics are used to evaluate cryptographic delivery performance across projects, with comparisons across teams or systems

4. **Advanced**: Cryptographic delivery metrics are continuously tracked, benchmarked, and used to optimize implementation planning, tooling, and rollout strategies

**Evidence to Look For**:


- Tracking reports or dashboards showing timelines, delays, or success rates for cryptographic upgrades (e.g., TLS hardening, cert renewal rollouts, key transitions)

- Comparative delivery performance across systems or units for crypto-relevant work (e.g., latency of hybrid certificate deployment, fallback testing outcomes)

- Documentation of delivery bottlenecks linked to cryptographic factors (e.g., legacy HSMs, firmware delays, vendor integration slowdowns)

- Integration of crypto-specific delivery metrics into overall IT or security KPI dashboards

##### Level 5 - Optimizing

**Question**: How does your organization enforce cryptographic change readiness and agility through its CI/CD and software delivery pipelines?

**Explanation**: This examines whether your organization integrates cryptographic policy enforcement into delivery workflows—ensuring new code, configurations, or services comply with cryptographic agility, key management, and post-quantum preparedness requirements at build and deployment time.

**Options**:


1. **Basic**: No governance or verification in delivery workflows for cryptographic changes

2. **Developing**: Cryptographic requirements are applied manually or inconsistently during implementation

3. **Established**: Delivery pipelines include structured enforcement of cryptographic settings, supported algorithms, and secure usage patterns

4. **Advanced**: Cryptographic readiness is fully integrated into CI/CD with automated policy enforcement, rollback testing, hybrid readiness checks, and agility-aware gating

**Evidence to Look For**:


- CI/CD pipeline rules that enforce allowed algorithms, key lengths, or crypto library versions

- Build scripts that reject deprecated cryptographic configurations or non-hybrid certificate chains

- Rollback simulation that account for cryptographic failure or downgrade scenarios

- Integration of SBOMs or dependency scanners flagging insecure or legacy crypto libraries before deployment

### Practice 4.3: Testing & Validation Capabilities

**Outcome**: Robust testing and validation frameworks that ensure quantum-resistant implementations meet security, performance, and compliance requirements.

#### Stream A: Implementation & Controls (60%)

##### Level 1 - Basic

**Question**: How comprehensive is your testing strategy for cryptographic transitions and quantum-resistant implementations?

**Explanation**: This examines your organization’s approach to preparing for the testing of quantum-resistant and cryptographically agile systems—including test planning, methodologies, and coverage of new algorithms, hybrid mechanisms, and security validation requirements.

**Options**:


1. **Basic**: No testing strategy exists for cryptographic transitions or quantum-resistant implementations

2. **Developing**: Basic test procedures are in place, but do not address cryptographic changes or PQC-specific concerns

3. **Established**: Structured testing framework defines how quantum-safe and agile cryptographic systems will be tested, including algorithm-specific test planning and fallback scenarios

4. **Advanced**: Standards-aligned testing strategy exists that covers quantum-resistant and hybrid implementations, with continuous updates based on emerging requirements and automated testing capabilities

**Evidence to Look For**:


- Documented test strategy or playbooks addressing PQC algorithm testing, hybrid protocol behavior, or fallback handling

- Test planning artifacts that include crypto-specific validation (e.g., key negotiation success, handshake verification, algorithm selection logic)

- Templates for test case development tied to cryptographic transitions (e.g., certificate chain validation, performance under large key sizes)

- Procedures for updating test plans in response to standards, vendor stack changes, or cryptographic policy updates

##### Level 2 - Developing

**Question**: How does your organization validate cryptographic fallback mechanisms and recovery readiness during transition testing?

**Explanation**: This examines whether your organization tests for failure modes, rollback behavior, and recovery scenarios related to cryptographic transitions—such as handshake failure, unsupported algorithms, expired certificates, or hybrid chain parsing issues—before deployment into production environments.

**Options**:


1. **Basic**: No validation of fallback or cryptographic recovery behavior is performed

2. **Developing**: Basic negative test cases are created, but do not represent real-world failure scenarios or critical crypto edge cases

3. **Established**: Structured testing includes rollback paths, fallback scenarios, and resilience under cryptographic failure conditions

4. **Advanced**: Cryptographic transitions are tested using failure injection, downgrade simulation, and automated validation of rollback paths and hybrid interoperability

**Evidence to Look For**:


- Test plans that include failure scenarios like unsupported PQ algorithms, handshake negotiation failures, or HSM key mismatches

- Scripts or tooling used to simulate expired, malformed, or untrusted certificate chains (including hybrid or dual-algorithm formats)

- Use of chaos testing or crypto-specific fault injection to confirm transition resilience

- Metrics tracking test success/failure in cryptographic exception handling or degraded scenarios

##### Level 3 - Established

**Question**: How does your organization test the performance and scalability of cryptographic implementations under realistic and constrained conditions?

**Explanation**: This examines whether your testing strategy includes performance and load testing of cryptographic operations under realistic operational conditions, including constrained devices, high-throughput services, or latency-sensitive systems.

**Options**:


1. **Basic**: No performance testing is performed on cryptographic implementations

2. **Developing**: Basic performance testing is conducted, but does not reflect real-world constraints or cryptographic transition impact

3. **Established**: Structured testing includes performance profiling of cryptographic operations under realistic loads, network conditions, and device constraints

4. **Advanced**: Comprehensive performance testing simulates quantum-era conditions across environments, with automated stress testing, telemetry integration, and continuous profiling

**Evidence to Look For**:


- Test reports showing cryptographic operation latency under expected system load

- Monitoring of CPU, memory, or network impact from cryptographic changes in test environments

- Performance thresholds or SLA limits tied to crypto validation metrics (e.g., TLS negotiation time, handshake completion rate)

- Tests simulating constrained or bandwidth-limited environments (e.g., embedded devices, IoT sensors, mobile clients)

##### Level 4 - Advanced

**Question**: How does your organization generate and manage assurance evidence from cryptographic testing activities?

**Explanation**: This examines whether your testing practices produce reliable, traceable, and meaningful outputs—such as logs, artifacts, and validation records—that demonstrate the correctness, security, and performance of cryptographic transitions to internal and external stakeholders.

**Options**:


1. **Basic**: No structured outputs are generated from cryptographic testing

2. **Developing**: Basic logs or manual notes are captured, but not consistently tied to cryptographic validation requirements

3. **Established**: Structured cryptographic testing produces repeatable, reviewable artifacts (e.g., trace logs, verification reports, test case outputs) aligned to crypto assurance goals

4. **Advanced**: Cryptographic test results are systematically captured, reviewed, and used to generate assurance evidence for internal governance, audits, or external certification

**Evidence to Look For**:


- Traceable logs or signed test results showing cryptographic behavior (e.g., handshake success, algorithm negotiation paths, fallback triggers)

- Artifacts used in internal reviews, red team reports, or vendor crypto validation reports

- Use of test evidence in certification submissions or partner trust documentation

- Mapping of test cases to specific cryptographic transition risks (e.g., expired certificates, malformed hybrid chains, MTU constraints)

##### Level 5 - Optimizing

**Question**: How does your organization adapt cryptographic testing practices in response to evolving threats, implementation risks, and post-quantum developments?

**Explanation**: This examines whether your organization updates and enhances its cryptographic testing scope, tools, and methodologies based on new threat intelligence, protocol changes, PQC migration updates, or observed failures.

**Options**:


1. **Basic**: Testing practices are static and updated only during major reviews

2. **Developing**: Updates are made manually in response to known test failures or external recommendations

3. **Established**: Testing is regularly enhanced based on crypto-specific feedback, standards evolution, and integration results

4. **Advanced**: Testing is proactively updated in response to cryptographic lifecycle changes, vulnerability disclosures, and PQC-related protocol shifts, with formal integration into test maintenance cycles

**Evidence to Look For**:


- Process for incorporating cryptographic vulnerability advisories, TLS downgrade issues, or hybrid certificate parsing failures into test plans

- Integration of threat intelligence (e.g., PQC migration reports, cryptographic downgrade exploits) into testing scenarios

- Procedures for updating test coverage based on failures in partner/vendor ecosystems or open-source crypto stacks

- Version history of test artifacts showing periodic updates and expansion tied to cryptographic change drivers

#### Stream B: Strategy & Innovation (40%)

##### Level 1 - Basic

**Question**: How structured is your validation process for cryptographic transitions?

**Explanation**: This examines whether your organization has a defined process to validate that cryptographic transitions meet functional, security, and performance requirements before deployment.

**Options**:


1. **Basic**: No validation process exists for cryptographic transitions

2. **Developing**: Basic validation steps are performed, but without standardized procedures

3. **Established**: Structured validation framework is used across cryptographic transitions, with defined roles, criteria, and repeatable processes

4. **Advanced**: Cryptographic validation is integrated with deployment workflows, using tooling, traceability, and continuous refinement

**Evidence to Look For**:


- Basic documentation outlining what needs to be validated before cryptographic rollouts (e.g., algorithm correctness, key exchange success, cert chain validation)

- Initial validation procedures for new cryptographic algorithms or protocols

- Examples of internal approvals tied to validation outputs (e.g., handshake success logs, fallback success, integration validation with external systems)

- Evidence that cryptographic validation is coordinated between development, infrastructure, and security teams

##### Level 2 - Developing

**Question**: How does your organization ensure consistent validation practices across cryptographic transitions and systems?

**Explanation**: This examines whether your organization applies standardized validation procedures—such as test criteria, success thresholds, and evaluation methods—consistently across teams, systems, and environments during cryptographic migrations.

**Options**:


1. **Basic**: No consistency measures exist for validation of cryptographic transitions

2. **Developing**: Basic validation procedures are shared informally, but applied inconsistently across teams or systems

3. **Established**: Structured validation framework enforces consistent practices, acceptance criteria, and test case reuse for cryptographic changes

4. **Advanced**: Validation processes are standardized and automatically applied across environments, with tooling to detect deviations and enforce conformance

**Evidence to Look For**:


- Validation playbooks or checklists that are reused across cryptographic implementation teams and environments

- Standard acceptance criteria applied to cryptographic changes (e.g., algorithm fallback, certificate chain parsing)

- Evidence of shared validation templates for different systems (e.g., APIs, edge devices, backend services)

- Audit logs or review records showing discrepancies or validation deviations between systems

##### Level 3 - Established

**Question**: How does your organization ensure validation of cryptographic implementations aligns with regulatory, industry, and internal compliance requirements?

**Explanation**: This examines whether your validation practices for cryptographic transitions are aligned with applicable compliance requirements, such as cryptographic standards, certification frameworks, and sector-specific regulations.

**Options**:


1. **Basic**: No compliance requirements are considered during cryptographic validation

2. **Developing**: Basic validation checks exist, but are not mapped to specific cryptographic compliance obligations

3. **Established**: Structured compliance process ensures cryptographic validation activities meet applicable regulatory and industry requirements

4. **Advanced**: Cryptographic validation is integrated with compliance management systems, with automated checks, evidence collection, and ongoing regulatory alignment

**Evidence to Look For**:


- Mapping of cryptographic validation requirements to external standards or regulations (e.g., FIPS, NIST, ETSI, HIPAA, eIDAS)

- Documentation showing successful cryptographic validation during certification or audit preparation

- Internal compliance dashboards that include cryptographic testing results or exception tracking

- Structured remediation process for validation gaps identified during internal audits or regulatory reviews

##### Level 4 - Advanced

**Question**: How does your organization assess cryptographic weaknesses or downgrade risks in third-party and externally managed systems during implementation testing?

**Explanation**: This examines whether your testing and validation efforts include evaluation of cryptographic risks introduced by external systems—such as APIs, SaaS platforms, or vendor-integrated components—including legacy protocol fallback, insecure defaults, or inconsistent cryptographic controls.

**Options**:


1. **Basic**: No validation is performed on the cryptographic behavior of third-party or externally managed systems

2. **Developing**: Third-party systems are assumed to be secure, with limited cryptographic validation during integration

3. **Established**: Structured cryptographic testing is performed on third-party endpoints and integrations, including downgrade attempts and configuration scanning

4. **Advanced**: Cryptographic behavior of third-party systems is continuously tested and monitored using automated validation, downgrade probes, and integration testing frameworks

**Evidence to Look For**:


- Use of tools like testssl.sh, sslyze, or protocol fuzzers for external cryptographic assessment

- Vendor integration test plans or onboarding checklists requiring crypto posture validation

- Documentation of cryptographic test failures or misalignments from third-party SaaS/API platforms

- Exception tracking or remediation plans triggered by insecure third-party cryptographic behavior

##### Level 5 - Optimizing

**Question**: How does your organization contribute to industry standards or best practices for validating cryptographic implementations?

**Explanation**: This examines whether your organization plays a role in shaping how cryptographic implementations are validated across the industry, including contributions to standards bodies, community initiatives, test frameworks, or validation methodologies.

**Options**:


1. **Basic**: No participation in cryptographic validation standards or best practices

2. **Developing**: Occasional participation in industry groups or review of draft validation guidance

3. **Established**: Active contributions to validation guidance, test frameworks, or community validation efforts

4. **Advanced**: Leadership in developing validation standards, tools, or frameworks adopted by other organizations

**Evidence to Look For**:


- Participation in industry groups or standards bodies focused on cryptographic validation (e.g., NIST, ETSI, ISO, IETF)

- Open-source contributions to cryptographic testing tools, validators, or benchmark suites

- Publication of validation methodologies, test artifacts, or case studies used by peer organizations

- Collaboration with vendors, researchers, or consortia to define shared validation practices or interoperability goals

## CMMC Alignment

CMMC CA.2.159: Develop and implement plans of action designed to correct deficiencies

CMMC CA.3.162: Employ a security assessment of enterprise software that has been developed internally

CMMC CM.2.061: Establish and maintain baseline configurations of organizational systems

CMMC RA.2.142: Scan for vulnerabilities in organizational systems and applications

## Integration with Other Dimensions

**Inputs from CVI**: Cryptographic asset inventory informs implementation scope

**Inputs from SGRM**: Governance requirements guide implementation approach

**Inputs from DPE**: Protection requirements drive implementation specifications

**Outputs to ORC**: Implementation details inform continuity planning

**Outputs to WOE**: Implementation approaches define skills requirements

**Outputs to vendor management**: Technical requirements for quantum-resistant solutions

**Inputs from research**: Performance benchmarks for post-quantum algorithms

## Industry-Specific Considerations

**Financial Services**: Payment systems, transaction processing, financial applications, high-performance trading systems

**Healthcare**: Medical devices, health information systems, clinical applications, resource-constrained medical devices

**Government**: Classified systems, agency applications, public services, cross-agency interoperability

**Manufacturing**: Operational technology, industrial systems, supply chain applications, legacy industrial control systems

## Cryptographic Algorithm Performance Analysis

Performance benchmarking for quantum-resistant algorithms

Resource utilization analysis for different implementation approaches

Impact assessment of larger key sizes and signature lengths

Optimization techniques for constrained environments

Network bandwidth impact analysis for larger cryptographic material

## Implementation Transition Strategies

Phased implementation approaches for mission-critical systems

Hybrid implementation patterns supporting cryptographic agility

Fallback mechanisms for ensuring operational continuity

Algorithm selection frameworks based on system requirements

Testing methodologies for cryptographic transitions

# Alternate Questions

**Question:** How does your organization manage protection requirements for code signing and software supply chain integrity?

**Explanation:** This examines how your organization ensures that post-quantum cryptographic protections are applied to code-signing mechanisms, firmware update systems, and supply chain delivery processes. 

**Options:**

No protection controls exist for code signing or update mechanisms

Basic signing processes are in place, but not quantum-resistant

Structured controls applied to code signing and package validation systems with PQC or hybrid algorithms

Automated enforcement of quantum-safe signing across software supply chains, including rollback protections and key agility

**Evidence to Look For:**

Inventory of code-signing mechanisms and associated keys, including signing tools, firmware pipelines, and CI/CD integration

Documentation of post-quantum or hybrid signing algorithms used in production software and third-party packages

Use of integrity verification systems that support short-lived or agile certificate updates

Integration of PQC enforcement into build systems, developer workflows, or software distribution platforms



---

## Scoring Methodology

The QRAMM assessment uses a 5-point scale where:
- Each question is scored from 1-5 based on the selected maturity level
- Practice scores are calculated as the average of all questions within that practice
- Dimension scores are calculated as the average of all practices within that dimension
- Overall QRAMM score is calculated as the average of all four dimension scores

## Assessment Completion

This complete 120-question assessment provides comprehensive evaluation across all quantum readiness dimensions. For additional implementation guidance, please visit [https://qramm.org](https://qramm.org) or contact [qramm@csnp.org](mailto:qramm@csnp.org).

---

*This assessment is part of the QRAMM (Quantum Readiness Assurance Maturity Model) framework. For more information, visit https://qramm.org*
