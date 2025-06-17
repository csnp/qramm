# Dimension 1: Cryptographic Visibility & Inventory (CVI)
**Understanding and cataloging cryptographic assets across the organization**

## Overview

Dimension 1 focuses on establishing comprehensive visibility into your organization's cryptographic landscape. This foundational dimension evaluates your ability to discover, inventory, assess, and map cryptographic assets across all systems, applications, and infrastructure. Without this visibility, organizations cannot effectively plan quantum-safe transitions or understand their risk exposure.

**Strategic Importance**: The transition to post-quantum cryptography requires organizations to understand exactly what cryptographic assets they have, where they're located, how vulnerable they are to quantum attacks, and how they're interconnected. This dimension provides the foundation for all quantum readiness activities.

## Core Practices

### Practice 1.1: Cryptographic Discovery & Inventory Management

**Outcome**: A comprehensive, accurate, and up-to-date inventory of all cryptographic assets (algorithms, keys, certificates, and implementations) that clearly identifies quantum-vulnerable components and their business context, enabling prioritized migration planning.

#### Stream A: Foundation (60%)

##### Level 1 - Basic
**Question**: How does your organization identify cryptographic assets?

**Explanation**: This assesses how your organization locates and identifies cryptographic assets including algorithms (e.g., RSA, AES), protocols (e.g., TLS, SSH), key sizes, Certificate Authorities (CA), Key Management Systems (KMS), Hardware Security Modules (HSM), and implementation details across all systems, applications, and infrastructure.

**Options**:
- No formal cryptographic asset identification process exists
- Manual inventory covering only known high-value systems
- Automated discovery implemented for portions of infrastructure
- Comprehensive automated discovery with validation across all environments

**Evidence to Look For**:
- Documentation of known cryptographic implementations in critical systems, including algorithm types and key sizes
- Use of automated network scanning tools that identify TLS implementations across the infrastructure
- Integrated tools identifying cryptography in applications, networks, hardware, and cloud services
- Advanced dashboards providing an up-to-date and comprehensive view of the cryptographic landscape

##### Level 2 - Developing
**Question**: How does your organization document cryptographic assets?

**Explanation**: This examines how systematically you document identified cryptographic assets, including the level of detail captured (algorithms, key sizes, expiration dates) and how this information is maintained.

**Options**:
- No standardized documentation exists
- Basic spreadsheet tracking that captures limited attributes
- Structured database with standardized templates
- Centralized asset management platform with automated updates and risk scoring

**Evidence to Look For**:
- Documented inventory process covering high-value systems that specifies implementation details (e.g., RSA-2048, AES-128)
- Structured database documenting algorithms, key sizes, protocols, certificate details, and quantum vulnerability assessments
- Automated tools updating documentation based on discovery results
- Comprehensive metadata including algorithm types, key sizes, expiration dates, and risk ratings

##### Level 3 - Established
**Question**: How does your organization govern cryptographic asset ownership and accountability?

**Explanation**: This examines whether your organization has clear, enforceable ownership of cryptographic assets—ensuring someone is responsible for maintaining inventory accuracy, supporting migration planning, and responding to vulnerabilities across all systems and environments.

**Options**:
- No formal assignment of ownership or accountability for cryptographic assets
- Ownership of cryptographic assets is informally assigned for critical systems or managed by individual teams
- Ownership roles are formally defined across the organization, with documented responsibilities and coverage tracking
- Cryptographic ownership is embedded into asset governance processes, with automated assignment, accountability metrics, and cross-functional oversight

**Evidence to Look For**:
- Documentation of assigned crypto owners for a subset of high-value systems
- Ownership mapping integrated into inventory or Configuration Management Database (CMDB)
- Assigned accountability for lifecycle tasks (e.g., key rotation, renewal, algorithm upgrades)
- Accountability metrics tracked for timeliness of remediation, renewal, or migration actions

##### Level 4 - Advanced
**Question**: How does your organization validate cryptographic asset inventory completeness?

**Explanation**: This examines how you ensure your cryptographic asset inventory is accurate and comprehensive, without significant gaps or outdated information about algorithms, key sizes, or implementations.

**Options**:
- No validation of inventory completeness
- Periodic manual sampling of selected systems to verify inventory accuracy
- Regular automated verification scans with a formal reconciliation process to address discrepancies
- Continuous monitoring with anomaly detection and completeness analytics that automatically identifies potential gaps in the cryptographic inventory

**Evidence to Look For**:
- Spreadsheet annotations showing updates or corrections based on manual review
- Metrics tracking inventory accuracy and completeness (e.g., percentage of systems scanned, number of discrepancies found)
- Machine learning or rule-based analytics identifying trends in inventory coverage and data quality
- Real-time validation integrated into DevOps, CI/CD, or system provisioning pipelines

##### Level 5 - Optimizing
**Question**: How does your organization ensure cryptographic visibility across third-party and cloud systems?

**Explanation**: This examines your organization's ability to identify, document, and monitor how cryptography is implemented within third-party services (e.g., SaaS platforms, cloud workloads, managed services) to ensure quantum-vulnerable components are not overlooked during risk assessment and migration planning.

**Options**:
- No visibility into cryptographic usage in third-party services or cloud environments
- Visibility is manually assessed for select vendors or critical cloud services
- Cryptographic visibility is routinely evaluated and documented across third-party and cloud environments using structured methods
- Continuous visibility into cryptographic usage across all external environments is maintained using automated tools, contractual controls, and integration with inventory systems

**Evidence to Look For**:
- Reviews of TLS settings or certificate usage in cloud-facing systems
- Cloud Security Posture Management (CSPM) tools identifying crypto parameters in cloud environments
- Real-time scanning or API-based monitoring of cryptographic configurations in multi-cloud or SaaS environments
- Contractual obligations for vendors to report cryptographic changes and vulnerabilities

#### Stream B: Advanced (40%)

##### Level 1 - Basic
**Question**: How is cryptographic asset inventory data used for strategic planning?

**Explanation**: This examines whether and how cryptographic asset information influences organizational security planning and resource allocation for quantum readiness.

**Options**:
- No strategic use of inventory data
- Basic reports generated for compliance purposes only
- Structured analysis guides resource allocation and security planning
- Advanced analytics drive quantum readiness strategy with ROI modeling

**Evidence to Look For**:
- Basic reporting capability for cryptographic assets, including algorithm types and key sizes
- Integration of asset data into project planning, architecture, or security roadmaps
- Defined KPIs (e.g., percentage of PQC-ready assets, cost per migrated system, risk reduction per dollar spent) are tracked and used to inform executive decision-making
- Inventory data linked to threat intelligence, business impact scoring, and refresh cycle planning

##### Level 2 - Developing
**Question**: How are cryptographic assets prioritized for quantum-resistance upgrades?

**Explanation**: This examines how you determine which cryptographic assets should be addressed first in your quantum readiness efforts, based on vulnerability, importance, and other factors.

**Options**:
- No prioritization process exists
- Criticality ratings based on system importance only
- Multi-factor risk scoring based on algorithm type, key size, long-term data sensitivity, and exposure
- Advanced prioritization model incorporating business impact, resource constraints, dependencies, and data protection timeframes

**Evidence to Look For**:
- Documentation of prioritization criteria and the systems prioritized for upgrade
- Quantum risk register tracking asset-level vulnerability and exposure
- Cross-functional prioritization criteria agreed upon by business and security teams
- Simulation results or scenario modeling of quantum decryption impacts on key systems

##### Level 3 - Established
**Question**: How is cryptographic asset inventory maintained over time?

**Explanation**: This examines your processes for keeping cryptographic asset inventory information current as systems change, certificates are renewed, and new applications are deployed.

**Options**:
- No maintenance process exists
- Manual updates during major system changes only
- Scheduled automated refresh with change management integration
- Real-time inventory updates with change verification and historical versioning

**Evidence to Look For**:
- Automated discovery tools integrated with CI/CD pipelines and asset management systems
- Scheduled re-scans or audits to detect new or modified cryptographic implementations
- Change management processes requiring cryptographic inventory updates upon deployment
- Version-controlled inventory logs with timestamps and responsible owner annotations

##### Level 4 - Advanced
**Question**: How does your organization include IoT and embedded devices in its cryptographic inventory and quantum readiness planning?

**Explanation**: This evaluates whether and how your organization identifies and manages cryptographic implementations in IoT and embedded devices—systems that often rely on hardcoded, legacy, or constrained cryptography.

**Options**:
- IoT and embedded devices are not included in cryptographic inventory or transition planning
- Manual list exists for critical IoT or embedded systems, but cryptographic details are incomplete or outdated
- IoT and embedded devices are systematically inventoried with crypto attributes (e.g., algorithm, key size), and included in quantum upgrade plans

**Evidence to Look For**:
- Inventory entries for IoT/embedded devices that specify algorithms, key lengths, and firmware crypto libraries
- Assessment reports identifying quantum-vulnerable protocols used in constrained or legacy devices
- Migration plans that include device upgrade feasibility and hardware limitations for cryptographic changes
- Use of embedded device scanning tools or firmware analysis to discover cryptographic implementations

##### Level 5 - Optimizing
**Question**: How does your organization stay informed about quantum computing and cryptanalysis advancements?

**Explanation**: This assesses how your organization monitors developments in quantum computing, cryptanalysis, and cryptographic standards that may affect the accuracy of your cryptographic inventory or the vulnerability status of deployed algorithms, focusing on ongoing awareness and information gathering—particularly as a foundation for discovery, risk assessment, and planning.

**Options**:
- No monitoring process exists
- Manual reviews of standards bodies or industry publications occur occasionally but are not systematic
- Structured monitoring process tracks cryptographic research, algorithm deprecation, and quantum milestones using defined sources and schedules
- Continuous monitoring with automated alerting and integration into asset inventories, allowing near real-time updates when cryptographic standards or threat models evolve

**Evidence to Look For**:
- List of monitored sources (e.g., NIST, IACR, ETSI, arXiv) for cryptographic and quantum updates
- Scheduled review cycles or internal briefings on cryptographic standards and research
- Subscriptions to automated alerts or newsletters tracking algorithm deprecation and quantum milestones
- Tooling or dashboards that flag relevant changes in cryptographic threat landscapes

### Practice 1.2: Vulnerability Assessment & Classification

**Outcome**: A systematic approach to identifying, assessing, and classifying cryptographic vulnerabilities to quantum attacks, enabling risk-based prioritization and effective mitigation planning.

#### Stream A: Foundation (60%)

##### Level 1 - Basic
**Question**: How does your organization assess quantum vulnerability of cryptographic assets?

**Explanation**: This examines your approach to evaluating how susceptible your cryptographic implementations are to quantum attacks (the weaknesses in the cryptography) based on algorithm types, key sizes, and implementation details.

**Options**:
- No vulnerability assessment process exists
- Basic identification of commonly known vulnerable algorithms
- Structured assessment methodology with vulnerability classification based on algorithm type, key size, and implementation
- Comprehensive risk-based assessment with technical validation and detailed algorithm-specific analysis

**Evidence to Look For**:
- Inventory annotated with algorithm types, key lengths, and known quantum vulnerabilities
- Use of industry standards (e.g., NIST, ETSI) to classify algorithm susceptibility
- Automated tools scanning code, configurations, and certificates for weak cryptographic implementations
- Evidence of in-depth assessment covering various cryptographic contexts (e.g., key exchange, signatures, encryption)

##### Level 2 - Developing
**Question**: How does your organization classify quantum vulnerability severity?

**Explanation**: This evaluates how your organization prioritizes the urgency of addressing quantum vulnerabilities by considering factors such as key establishment vs digital signatures, algorithm, key size, implementation context, data exposure, and the long-term sensitivity of protected data.

**Options**:
- No method in place to classify quantum vulnerabilities
- General high/medium/low ratings with minimal or informal criteria
- Formal classification framework using defined factors like algorithm, key size, data sensitivity, exposure, and protection duration
- Quantitative risk scoring model combining technical vulnerability with business impact metrics

**Evidence to Look For**:
- Asset inventory annotated with data exposure levels (e.g., public-facing)
- Documentation of data retention needs tied to sensitivity and protection timeframes
- Reports linking crypto weaknesses to business functions and data types
- Scoring model combining technical risk, data exposure, and longevity needs

##### Level 3 - Established
**Question**: How does your organization validate vulnerability findings?

**Explanation**: This examines your approach to verifying that identified cryptographic vulnerabilities are accurate and properly characterized in terms of algorithm types, key sizes, and implementation details.

**Options**:
- No validation process exists
- Manual review of vulnerability assessments by security team
- Structured validation methodology with technical testing of algorithm implementations
- Automated validation with multiple assessment techniques and cryptographic expertise

**Evidence to Look For**:
- Comparison of scan results across multiple tools to identify false positives or gaps
- Use of cryptographic linting or static analysis tools during code reviews to confirm proper implementation
- Tracking how often flagged vulnerabilities are reclassified or dismissed after deeper inspection
- Internal guidelines defining when a finding requires expert cryptographic review versus automated confirmation

##### Level 4 - Advanced
**Question**: How does your organization integrate emerging quantum threats into planning and strategy?

**Explanation**: This evaluates how your organization uses insights from quantum computing and cryptanalysis developments to shape cryptographic roadmaps, prioritize asset upgrades, and inform long-term risk mitigation strategies.

**Options**:
- No planning or strategy considers quantum threat developments
- Strategic plans are occasionally updated in response to major quantum-related announcements or standard changes
- Quantum threat developments are regularly factored into cryptographic planning, with updates to migration timelines, policies, and coordination with key vendors
- Quantum threat scenarios drive ongoing strategy refinement using impact modeling, vendor quantum-readiness tracking, and alignment with business risk and data protection timelines

**Evidence to Look For**:
- Meeting minutes or strategy documentation showing use of quantum threat scenarios in planning
- Vendor assessments or questionnaires tracking quantum-readiness milestones
- Migration plans that adjust timelines based on evolving quantum risk forecasts
- Modeling or simulations used to prioritize systems based on quantum impact and business risk

##### Level 5 - Optimizing
**Question**: How does your organization contribute to (quantum) cryptanalysis and mitigation research?

**Explanation**: This examines your organization's role in advancing the broader field of classical and post-quantum cryptographic research—such as algorithm analysis, vulnerability assessment, and mitigation strategies—through collaboration, knowledge sharing, or original research.

**Options**:
- No involvement in external research or knowledge-sharing efforts
- Participation in industry working groups or forums and shared lessons learned on algorithm vulnerabilities
- Active collaboration with academic or industry partners on research related to cryptanalysis or mitigation
- Original research, tools, or publications that contribute to advancing cryptography or cryptanalysis practices

**Evidence to Look For**:
- Published papers or blog posts analyzing quantum risks in specific cryptographic algorithms
- Open-source tools or datasets released for vulnerability testing or analysis
- Sponsorship of research grants, internships, or academic projects on post-quantum security
- Internal lab results or testbed simulations exploring weaknesses in legacy protocols or modeling attacks on cryptosystems

#### Stream B: Advanced (40%)

##### Level 1 - Basic
**Question**: How are vulnerability findings communicated to stakeholders?

**Explanation**: This assesses how effectively your organization shares information about quantum-related cryptographic vulnerabilities with relevant internal stakeholders—including technical teams, system owners, and executives.

**Options**:
- No formal communication process exists
- Vulnerability reports shared with technical teams listing affected systems and algorithms
- Structured reporting tailored to different stakeholder groups with contextual information about algorithm risks
- Comprehensive communication strategy with executive dashboards showing vulnerability metrics and trends

**Evidence to Look For**:
- Tailored reports or dashboards summarizing vulnerabilities by business unit or stakeholder type
- Established communication cadence (e.g., monthly reviews, executive briefings) for crypto risk updates
- Documentation or workflows defining how vulnerability findings are escalated and tracked across teams
- Stakeholder-specific risk impact summaries that link crypto issues to business functions or compliance needs

##### Level 2 - Developing
**Question**: How does your organization assess the quantum vulnerability of cryptographic mechanisms used for data authenticity and long-term integrity?

**Explanation**: This examines whether your organization evaluates the post-quantum risks to digital signatures and message authentication mechanisms used to verify authenticity and protect the integrity of data over time.

**Options**:
- No assessment of authenticity or integrity mechanisms under quantum threat
- Informal review of signature algorithms and MACs in critical systems
- Structured evaluation of signing and integrity mechanisms by algorithm, key size, and data lifetime
- Comprehensive vulnerability assessment of all long-term integrity and authenticity controls, including exposure modeling and risk scoring

**Evidence to Look For**:
- Inventory of signing and MAC mechanisms used for software updates, logs, backups, and document workflows
- Assessment reports evaluating digital signature algorithms (e.g., RSA, ECDSA) used in firmware, code signing, and archival documents
- Identification of long-lived integrity mechanisms in backup and archival systems, including signing or hashing methods
- Risk modeling or prioritization documents that score authenticity and integrity protections based on algorithm type and data retention period

##### Level 3 - Established
**Question**: How does your organization validate the correctness and secure configuration of deployed cryptographic implementations?

**Explanation**: This assesses whether your organization verifies that deployed cryptographic functions are implemented according to specifications, use secure parameters (e.g., key sizes, cipher modes), and conform to standards.

**Options**:
- No validation of deployed cryptographic implementations
- Ad-hoc manual checks of cryptographic configurations in selected systems
- Structured validation process reviewing algorithm correctness, key sizes, and configuration settings
- Automated and continuous validation of cryptographic use across systems, including detection of library misuse, insecure modes, and deprecated protocols

**Evidence to Look For**:
- Application of cryptographic configuration testing tools (e.g., testssl.sh, cryptographic linters, or fuzzers)
- Cryptographic implementation review as part of secure code review or architecture review process
- Scan reports identifying insecure modes (e.g., ECB), deprecated protocols, or weak key lengths in production systems
- Defined cryptographic secure coding patterns or APIs enforced across teams to standardize secure usage

##### Level 4 - Advanced
**Question**: How does your organization assess trends in cryptographic vulnerabilities over time?

**Explanation**: This examines whether your organization tracks how cryptographic vulnerabilities evolve due to system changes, algorithm deprecation, or quantum computing progress—and whether this information is used to monitor readiness and guide remediation priorities.

**Options**:
- No tracking or analysis of changes in cryptographic vulnerability posture
- Informal or occasional reviews noting major algorithm or system changes
- Regular analysis using defined metrics to track algorithm usage, crypto upgrades, and exposure trends
- Continuous trend monitoring with predictive analytics tied to system changes, quantum advancements, and deprecation timelines

**Evidence to Look For**:
- Reports comparing algorithm usage or key sizes across inventory snapshots
- Metrics dashboards tracking adoption of PQC-ready algorithms or phase-out of deprecated ones
- Trend analysis presentations linking system upgrades to reductions in quantum-exposed components
- Forecast models projecting algorithm viability against quantum computing milestones

##### Level 5 - Optimizing
**Question**: How does your organization apply quantum vulnerability insights to improve cryptographic practices and standards?

**Explanation**: This examines how insights gained from quantum-focused cryptographic assessments—such as algorithm weaknesses, misconfigurations, or systemic gaps—are used to improve implementation practices, internal standards, and future decision-making.

**Options**:
- No process exists to apply findings from vulnerability assessments
- Lessons from significant vulnerabilities occasionally lead to manual updates in practices
- Structured process to review assessment findings and update standards, guidance, or configurations
- Continuous improvement loop with automated feedback into coding patterns, policy updates, and tool configurations based on recurring issues

**Evidence to Look For**:
- Post-assessment reviews resulting in updates to internal cryptographic configuration baselines
- Documentation showing revisions to approved algorithm lists based on assessment trends
- Change logs for secure coding guidelines reflecting common implementation issues
- Automated rule updates in static analysis or CI/CD tools based on recurring crypto misuse patterns

### Practice 1.3: Cryptographic Dependency Mapping

**Outcome**: A comprehensive understanding of how cryptographic components are interconnected throughout the organization, enabling coordinated migration planning that maintains system functionality while transitioning to quantum-resistant algorithms.

#### Stream A: Foundation (60%)

##### Level 1 - Basic
**Question**: How does your organization identify and map cryptographic dependencies across systems and services?

**Explanation**: This assesses your ability to discover and document how cryptographic implementations connect systems, applications, services, and devices—such as shared keys, certificates, protocols, or libraries.

**Options**:
- No process exists to identify cryptographic dependencies between systems
- Manual identification of direct dependencies in known critical systems
- Structured methodology to map cryptographic dependencies across systems, protocols, and services, including indirect relationships
- Automated discovery and mapping of all cryptographic dependencies, including dynamic connections, shared libraries, and multi-system flows

**Evidence to Look For**:
- Dependency diagrams or architecture maps showing crypto relationships
- Outputs from automated tools detecting shared crypto usage (e.g., libraries, APIs)
- Inter-service crypto dependency documentation (e.g., mutual TLS or shared key use)
- Change logs showing impact analysis based on dependency mapping

##### Level 2 - Developing
**Question**: How does your organization document and maintain cryptographic dependencies between systems and services?

**Explanation**: This examines whether and how your organization records cryptographic interdependencies—such as shared certificates, keys, protocols, or algorithm implementations—across systems, applications, and services.

**Options**:
- No formal documentation of cryptographic dependencies
- Informal or manual records of direct dependencies
- Structured documentation using standardized formats to capture algorithms, key types, and inter-system relationships
- Centralized and continuously maintained dependency database with metadata for algorithms, certificates, relationship types, and system roles

**Evidence to Look For**:
- Spreadsheet or database capturing system-to-system cryptographic links with associated key types or algorithms
- Standardized templates used to record dependencies, including fields for protocol versions and certificate usage
- Metadata schema or taxonomy defining relationship types (e.g., client-server, mutual TLS, shared CA)
- Integration of cryptographic dependency data into CMDBs, architecture tools, or asset management platforms

##### Level 3 - Established
**Question**: How does your organization analyze the impact of cryptographic changes across dependent systems and services?

**Explanation**: This examines whether your organization performs impact analysis to understand how cryptographic changes—such as algorithm upgrades, key rotations, or certificate transitions—affect interconnected systems, services, and workflows.

**Options**:
- No process exists to assess the impact of cryptographic changes on dependent systems
- Informal or ad-hoc assessments of major dependencies when changes are planned
- Structured methodology to evaluate the effects of algorithm, certificate, or key changes across known dependencies
- Comprehensive modeling and scenario analysis to predict system-wide impacts of cryptographic transitions, including business and operational consequences

**Evidence to Look For**:
- Impact assessment reports mapping systems affected by planned cryptographic upgrades or deprecations
- Dependency heatmaps or risk diagrams highlighting systems linked by shared crypto assets (e.g., certificates, libraries)
- Change approval workflows requiring cryptographic impact analysis before rollout (e.g., certificate rotations, TLS changes)
- Scenario models simulating algorithm migration or protocol changes and identifying potential disruptions

##### Level 4 - Advanced
**Question**: How does your organization validate the accuracy and completeness of cryptographic dependency mapping?

**Explanation**: This examines whether your organization has a formal process to verify that its cryptographic dependency maps reflect real and complete relationships between systems, including methods for technical validation, detection of missing or outdated links, and ongoing updates to reflect infrastructure changes.

**Options**:
- No process exists to verify cryptographic dependency data
- Manual spot-checks of selected dependencies in critical systems
- Structured validation process using technical methods to confirm system-to-system cryptographic relationships
- Automated validation with continuous monitoring and detection of missing or outdated dependencies across all environments

**Evidence to Look For**:
- Logs or reports from automated tools detecting previously undocumented cryptographic dependencies
- Validation scripts comparing documented dependencies against actual traffic or configuration data (e.g., TLS connections, key usage logs)
- Audit records of manual or peer reviews confirming dependency records for high-risk systems
- Dashboards or alerts flagging mismatches between expected and observed cryptographic relationships

##### Level 5 - Optimizing
**Question**: How does your organization keep cryptographic dependency information current as systems evolve?

**Explanation**: This examines how your organization ensures that cryptographic dependency records stay accurate over time as systems, certificates, keys, or protocols change, including processes for updating records in response to infrastructure change and the use of automation for continuous visibility.

**Options**:
- No process exists to update cryptographic dependency information over time
- Dependency records are updated manually when major changes are noticed or reported
- Regular updates are performed through scheduled reviews and integrated with change management processes
- Dependency information is continuously updated using automated discovery, monitoring, and integration with asset and configuration systems

**Evidence to Look For**:
- Scheduled reviews or audits that include validation and updates of cryptographic dependency documentation
- Automated tools that detect new or modified cryptographic relationships and update dependency records in real time
- Version-controlled repository or database showing historical changes to cryptographic dependencies
- Dashboards or metrics tracking update frequency and data freshness of dependency records

#### Stream B: Advanced (40%)

##### Level 1 - Basic
**Question**: How is cryptographic dependency information used to inform migration planning and operational risk management?

**Explanation**: This assesses whether your organization uses knowledge of cryptographic interdependencies—such as shared certificates, protocol chains, or API relationships—to guide transition sequencing, prevent cascading failures, and prioritize mitigation efforts.

**Options**:
- Dependency data is not used in planning or risk discussions
- Known critical dependencies are considered during informal planning
- Structured transition planning uses documented dependencies to guide sequencing and risk evaluation
- Dependency models are integrated into simulation tools and strategic risk assessments for quantum transition

**Evidence to Look For**:
- Migration plans that include sequencing steps based on documented cryptographic dependencies
- Risk assessments or threat models highlighting cascading failure potential from shared cryptographic components
- Change approval workflows requiring dependency impact analysis for key rotations or algorithm upgrades
- Dependency-aware fallback or rollback procedures defined in migration playbooks

##### Level 2 - Developing
**Question**: How does your organization manage cryptographic dependencies in software build systems and code-signing infrastructure?

**Explanation**: This examines how your organization identifies and coordinates cryptographic components used across CI/CD pipelines, code-signing tools, package repositories, and update mechanisms—ensuring these trust relationships are tracked, validated, and upgraded as part of the quantum transition strategy.

**Options**:
- Cryptographic use in build systems or code-signing infrastructure is not tracked
- Some known dependencies (e.g., code-signing certificates) are documented, but not consistently updated or mapped
- Cryptographic dependencies across CI/CD pipelines and signing systems are documented and reviewed as part of upgrade planning
- Dependency-aware tooling continuously monitors and validates signing workflows, with cryptographic upgrade paths coordinated across software delivery systems

**Evidence to Look For**:
- Inventory of signing algorithms, keys, and certificates used in software release pipelines
- Documentation of cryptographic trust paths across CI/CD systems, package repositories, and update verification mechanisms
- Build scripts or DevSecOps pipelines configured to enforce approved cryptographic parameters for signing and verification
- Migration plans addressing post-quantum signing algorithm adoption across code-signing services, firmware signing tools, and CI/CD integrations

##### Level 3 - Established
**Question**: How does your organization assess cryptographic dependencies and transition constraints in operational technology (OT) and industrial control environments?

**Explanation**: This examines whether your organization identifies and maps cryptographic relationships across OT, Supervisory Control and Data Acquisition (SCADA), Industrial Control Systems (ICS), and industrial systems—including fixed-function protocols (e.g., MODBUS, DNP3, OPC-UA), hardware cryptography limitations, and long lifecycle constraints—to plan safe and effective quantum-resilient transitions.

**Options**:
- No assessment of cryptographic dependencies or constraints in OT or industrial systems
- Some OT systems are reviewed manually for cryptographic use, but dependencies and limitations are undocumented
- OT and industrial crypto dependencies are documented, including protocol use and upgrade limitations
- Cryptographic transition plans for OT systems include detailed dependency maps, hardware constraints, and coordinated timelines with operational risk modeling

**Evidence to Look For**:
- System inventories listing industrial protocols (e.g., MODBUS, DNP3, OPC-UA) alongside their cryptographic implementations and known limitations
- Architecture diagrams mapping cryptographic trust relationships between controllers, sensors, gateways, and industrial networks
- Assessment reports evaluating firmware or embedded hardware support for quantum-resistant algorithms
- Operational risk analyses modeling the impact of cryptographic algorithm changes on industrial safety, availability, or compliance

##### Level 4 - Advanced
**Question**: How are cryptographic dependencies evaluated for architectural complexity and transition fragility?

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

##### Level 5 - Optimizing
**Question**: How are cryptographic dependencies tracked across CI/CD pipelines, shared libraries, and external APIs?

**Explanation**: This assesses whether your organization identifies and manages cryptographic interdependencies introduced through development workflows, software components, or third-party interfaces, which may impact the timing or feasibility of quantum-resilient transitions.

**Options**:
- No visibility into cryptographic use across pipelines, libraries, or APIs
- Some known crypto dependencies are documented, but tracking is manual or incomplete
- Dependency tracking is structured and includes libraries, signing workflows, and key interfaces
- Continuous monitoring tracks cryptographic components across build systems, shared code, and third-party integrations

**Evidence to Look For**:
- Dependency files or manifests (e.g. SBOMs) listing cryptographic libraries and algorithms
- Documentation of cryptographic interfaces to third-party APIs or managed services
- Security controls in pipelines enforcing approved cryptographic algorithms for code signing and deployment
- Automated tooling output showing real-time tracking or alerts on cryptographic changes in builds or dependencies

## Dimension Summary

Dimension 1 provides the foundation for all quantum readiness activities through comprehensive cryptographic visibility and inventory management. Organizations must establish strong capabilities in:

1. **Discovery and Inventory**: Systematic identification and documentation of all cryptographic assets
2. **Vulnerability Assessment**: Risk-based evaluation of quantum vulnerabilities
3. **Dependency Mapping**: Understanding cryptographic interconnections and migration impacts

Success in this dimension enables organizations to:
- Understand their complete cryptographic landscape and quantum risk exposure
- Prioritize quantum-safe migration efforts based on risk and business impact
- Plan coordinated transitions that maintain system functionality
- Track progress and maintain continuous visibility as systems evolve

Without strong capabilities in Dimension 1, organizations cannot effectively plan or execute quantum-safe transitions, making this the foundational dimension for quantum readiness.

---

*This document provides the complete evaluation framework for Dimension 1. For assessment instructions and scoring methodology, refer to the QRAMM Assessment Guide.*

**Document Version**: 1.0  
**Last Updated**: May 30, 2025  
**Authors**: Emily (Stamm) Fane, Abdel Sy Fane  
**Organization**: CyberSecurity NonProfit (CSNP)  
**Framework**: Quantum-Ready Assessment & Maturity Model (QRAMM)
