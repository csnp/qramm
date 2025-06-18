# Dimension 3: Data Protection Engineering (DPE)
**Technical implementation of quantum-safe data protection measures**

## Overview

Dimension 3 focuses on the technical aspects of protecting data against quantum threats throughout its entire lifecycle. This dimension evaluates data classification, protection requirements, storage security, encryption management, and transit security implementations. Effective data protection engineering ensures that sensitive information remains secure against both current and future quantum computing capabilities.

**Strategic Importance**: With quantum computers potentially capable of breaking current encryption standards, organizations must implement quantum-safe data protection that maintains confidentiality, integrity, and availability throughout the expected lifetime of their data assets.

## Core Practices

### Practice 3.1: Data Classification & Protection Requirements

**Outcome**: A comprehensive data protection framework that aligns protection measures with data sensitivity and quantum risk levels across the entire data lifecycle.

#### Stream A: Implementation & Controls (60%)

##### Level 1 - Basic
**Question**: How does your organization identify data requiring quantum-resistant protection?

**Explanation**: This examines how your organization identifies sensitive or long-lived data that may require protection against evolving threats, including the future risks posed by quantum computing.

**Options**:
- No data identification process exists
- Manual identification of sensitive data types in high-value or regulated systems
- Structured classification using protection timeframes and long-term confidentiality tags
- Automated discovery and classification with integrated quantum risk scoring

**Evidence to Look For**:
- Data classification records explicitly linking certain datasets to protection lifespans that exceed the projected arrival of practical quantum threats
- Documentation showing the use of Mosca's Theorem or equivalent models to determine which data requires quantum-resistant protection based on retention needs
- Metadata schemas or tagging conventions that flag long-term sensitive data (e.g., financial contracts, patient records) for enhanced cryptographic safeguards
- Output from data discovery tools identifying high-value fields (e.g., national IDs, legal documents) tagged for long-duration confidentiality

##### Level 2 - Developing
**Question**: How does your organization classify data based on quantum risk?

**Explanation**: This examines your approach to categorizing data assets according to their vulnerability to quantum computing threats, considering factors like protection timeframe, sensitivity, and business impact.

**Options**:
- No classification system exists
- Basic sensitivity levels defined without considering quantum-specific threats
- Structured classification incorporating protection duration and sensitivity to quantum risk
- Automated classification system with integrated quantum risk scoring and exposure modeling

**Evidence to Look For**:
- Classification policies that define protection levels based on data sensitivity and retention periods in a post-quantum context
- Use of scoring models or matrices that rank data risk by quantum exposure, business impact, and cryptographic vulnerability
- Documentation showing how classification criteria are adjusted based on updates to the projected quantum computing timeline
- Automated tools that tag or sort datasets by protection timeframe, cryptographic algorithm used, and exposure window

##### Level 3 - Established
**Question**: How does your organization implement quantum-resistant controls?

**Explanation**: This examines how your organization deploys cryptographic safeguards that protect data against quantum computing threats, including algorithm selection, key management, and control validation.

**Options**:
- No specific controls implemented
- Hybrid algorithms of classical and quantum-resistant cryptography applied to select high-sensitivity data
- Structured control framework aligned with data classifications and quantum protection needs that determines how hybrid algorithms are applied
- Automated enforcement of quantum-resistant controls across all data states with continuous validation

**Evidence to Look For**:
- Implementation records showing post-quantum or hybrid algorithms applied to specific systems or datasets classified as quantum-sensitive
- Methodology documents mapping cryptographic control types to data categories and required protection durations
- Deployment diagrams or architecture reviews confirming the presence of PQC-based protections for data at rest, in transit, and in use
- Configuration templates or control libraries that enforce algorithm and key-type selection based on classification tags

##### Level 4 - Advanced
**Question**: How does your organization validate protection controls?

**Explanation**: This examines your approach to verifying that quantum-resistant data protection controls are correctly implemented and delivering the intended level of security across different environments.

**Options**:
- No validation process exists
- Manual testing of protection controls with limited coverage or frequency
- Structured validation process using tools and regular test schedules for all implemented controls
- Continuous automated validation integrated with control monitoring and quantum-aware threat modeling

**Evidence to Look For**:
- Validation procedures describing how post-quantum encryption or signing controls are tested across environments and control types
- Test plans and result logs confirming correct implementation of hybrid algorithms in production or staging systems
- Tool output or reports verifying that controls enforce required key lengths, algorithms, and modes aligned with classification levels
- Integration of validation results into dashboards or ticketing systems for automated tracking and incident handling

##### Level 5 - Optimizing
**Question**: How does your organization tailor data protection requirements for constrained or specialized environments?

**Explanation**: This examines whether your protection requirements account for platform-specific constraints—such as limited hardware, fragmented protocols, or cloud-native designs—especially in IoT, embedded, industrial, or multi-cloud systems.

**Options**:
- No distinction is made for environment-specific protection needs
- Ad-hoc adjustments to protection requirements in constrained systems
- Defined protection profiles per environment (e.g., cloud, IoT, OT) with risk-based exceptions
- Centralized policy engine that enforces environment-aware protection requirements and supports automated updates

**Evidence to Look For**:
- Protection requirement documents that differentiate environments by hardware or software constraints
- Profiles or templates specifying what algorithms, key sizes, or formats are acceptable in IoT, mobile, or cloud systems
- Assessment reports evaluating feasibility of PQC enforcement in embedded systems or bandwidth-constrained devices
- Policy exception handling procedures that justify trade-offs for non-standard environments (e.g., LoRaWAN, legacy RTOS)

#### Stream B: Strategy & Innovation (40%)

##### Level 1 - Basic
**Question**: How does your organization define protection strategies based on data lifecycle and retention needs?

**Explanation**: This examines your organization's strategic approach to aligning quantum-resistant protections with data lifecycles—ensuring that encryption and integrity controls remain valid for the duration the data must remain secure or verifiable.

**Options**:
- No strategy exists to align protection with data lifecycle or retention needs
- Retention durations are tracked, but not tied to protection strength or algorithm choice
- Strategy maps data types to protection durations based on classification and quantum risk
- Lifecycle-driven protection strategies with automated tagging, enforcement, and retirement policies

**Evidence to Look For**:
- Documentation linking data protection durations to classification levels and cryptographic control choices
- Mapping of backup/archive data to protection requirements based on expected confidentiality or authenticity needs
- Procedures for retiring, reclassifying, or re-encrypting long-lived data as quantum capabilities evolve
- Integration with data governance tools that apply or enforce protection policies over time based on lifecycle events

##### Level 2 - Developing
**Question**: How does your organization define protection strategies for unstructured or semi-structured data?

**Explanation**: This examines whether your data protection strategy explicitly addresses hard-to-classify data types—such as email, documents, collaboration tools, messaging logs, or data lakes—which may contain quantum-sensitive information.

**Options**:
- No strategy exists for protecting unstructured or semi-structured data
- General protections applied without specific quantum-related considerations
- Strategy defines classification and protection guidelines for unstructured data formats
- Quantum-risk-aware tools and policies are applied to unstructured data discovery, tagging, and control enforcement

**Evidence to Look For**:
- Protection strategies that include categories like email, messaging data, fileshares, or long-lived archives
- Use of discovery tools that classify or tag unstructured data with quantum-relevant metadata
- Risk assessments showing potential exposure from unstructured sources (e.g., email archives with PII or legal records)
- Policies requiring reclassification or re-encryption of older archives as quantum risk increases

##### Level 3 - Established
**Question**: How does your organization measure the effectiveness of data protection controls?

**Explanation**: This examines your approach to assessing whether applied data protection controls meet their intended objectives—such as correctly aligning with data classifications and minimizing residual risk.

**Options**:
- No measurement process exists for protection control effectiveness
- Manual tracking of basic coverage metrics for critical systems
- Structured measurement framework assessing protection adequacy by classification, algorithm, and data state
- Automated effectiveness monitoring with analytics to identify protection gaps, misalignments, and future risks

**Evidence to Look For**:
- Metrics tracking control implementation coverage across classification tiers and data states (rest, transit, in use)
- Evidence of recurring reviews or simulations that assess whether protections continue to meet data protection requirements over time
- Analysis reports identifying residual risks, coverage gaps, or exceptions where protections fall short of policy or control intent
- Dashboards showing trends in encryption use, key lifecycle enforcement, or classification-to-control alignment across systems

##### Level 4 - Advanced
**Question**: How does your organization identify opportunities to improve data protection controls?

**Explanation**: This examines how your organization uncovers new protection gaps or improvement areas—through testing, quantum threat updates, performance analysis, or feedback from control validation and classification alignment.

**Options**:
- No process exists for identifying improvements to protection controls
- Improvements are made on an ad-hoc basis in response to specific issues
- Structured process exists to evaluate improvements through testing, technology tracking, and design review
- Automated tools and analytics continuously identify protection improvement opportunities based on risk, performance, and cryptographic readiness

**Evidence to Look For**:
- Use of control performance data (e.g., latency, coverage, algorithm mismatch) to trigger enhancement reviews
- Meeting records or logs where control misalignment with classification requirements led to improvement recommendations
- Tracking of protection gaps that emerged from new data types, system changes, or cryptographic agility limitations
- Output from analytics or simulation tools that flag protection drift, algorithm expiry risk, or control performance degradation

##### Level 5 - Optimizing
**Question**: How does your organization assess the performance of data protection controls?

**Explanation**: This examines how your organization tests and monitors the performance of encryption, key management, and related protection mechanisms—including their impact on system efficiency, usability, and operational feasibility across environments.

**Options**:
- No performance testing or monitoring of data protection controls exists
- Informal performance observations are made during implementation or deployment
- Structured performance testing is conducted to evaluate protection control impact across key environments
- Ongoing performance monitoring and benchmarking inform protection control tuning, design decisions, and trade-offs

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
- No symmetric encryption controls are implemented for stored data
- Standard encryption is applied but key sizes are not quantum-resistant and storage systems lack support for future upgrades
- Symmetric encryption with quantum-resistant key sizes is used and storage platforms support upgrades to algorithms or key lengths
- Symmetric encryption controls are enforced through automated policies with built-in cryptographic agility for key size updates and algorithm evolution

**Evidence to Look For**:
- Encryption policies requiring AES-256 or equivalent quantum-resilient symmetric encryption for sensitive stored data
- System design documents showing that storage platforms can accommodate longer keys or alternative encryption modes
- Configuration management tools that enforce approved encryption standards and flag legacy key sizes
- Procedures for re-encryption or key upgrade of stored data as new symmetric standards or threats emerge

##### Level 2 - Developing
**Question**: How does your organization manage encryption keys for stored data in an agile manner?

**Explanation**: This examines your organization's approach to the lifecycle management of encryption keys for data at rest, including generation, storage, rotation, retirement, and readiness to adapt to quantum-safe key types or wrapping mechanisms.

**Options**:
- No formal key management process exists for stored data
- Keys are manually handled with limited support for rotation or upgrades
- Structured key management system supports key generation, secure storage, and rotation
- Automated key lifecycle management is implemented with cryptographic agility for key formats, wrapping, and dynamic upgrades

**Evidence to Look For**:
- Key management policies that specify secure key generation, storage, rotation, and retirement processes
- Use of HSMs, KMS platforms, or cryptographic libraries that support modular or policy-driven key lifecycle control
- Automation or orchestration systems that enforce key rotation schedules and flag expired, unused, or misconfigured keys
- Evidence of role-based or environment-specific key management rules (e.g., different lifecycles for archive vs. operational data)

##### Level 3 - Established
**Question**: How does your organization ensure strong, adaptable protection and recoverability for backup and archived data?

**Explanation**: This examines your organization's approach to securing backup and archived data over extended retention periods, including the use of encryption, key management practices, and recovery validation that can support evolving cryptographic requirements.

**Options**:
- No cryptographic protections are applied to backup or archived data
- Backups are encrypted, but protection does not account for long-term retention needs or future cryptographic changes
- Structured framework applies strong encryption and retention-aware protection policies to backup and archival systems
- Backup systems enforce encryption and key lifecycle policies that support long-term recoverability and cryptographic adaptability

**Evidence to Look For**:
- Retention policies identifying data classes that require protection beyond standard operational timeframes
- Backup system configurations showing integration with key management systems that support lifecycle controls and algorithm updates
- Recovery testing results demonstrating that long-term encrypted backups remain accessible and verifiable after changes to encryption algorithms or key policies
- Architecture reviews or platform support confirmations showing that backup systems can accommodate changes to key size, encryption mode, or wrapping formats

##### Level 4 - Advanced
**Question**: How does your organization ensure long-term cryptographic integrity of stored and archived data?

**Explanation**: This examines how your organization applies integrity protections—such as digital signatures, hashes, and time-stamps—to detect tampering in stored or archived data and ensure those mechanisms remain effective over the full data retention period.

**Options**:
- No integrity protections are applied to stored or archived data
- Hashing or signing is applied inconsistently without consideration of retention duration or algorithm longevity
- Integrity protections are systematically applied using cryptographic algorithms selected for long-term effectiveness
- Integrity mechanisms are paired with time-stamping or re-signing strategies and support upgrades as cryptographic standards evolve

**Evidence to Look For**:
- Use of digital signatures or hashes to verify authenticity of backups, logs, or archived documents
- Procedures for re-signing or re-hashing stored data as algorithms are deprecated or replaced
- Use of cryptographic libraries or storage platforms that support algorithm agility and integrity reprocessing
- Policies specifying how integrity protections are maintained for data requiring verification many years after creation

##### Level 5 - Optimizing
**Question**: How does your organization test whether storage encryption and key management controls are strong enough for long-term resilience, including future quantum threats?

**Explanation**: This examines your organization's approach to verifying that encryption and key management controls for stored data are correctly implemented and offer sufficient protection against quantum computing threats, including regular testing of algorithm strength, configuration, and cryptographic effectiveness.

**Options**:
- No validation process exists for storage cryptographic protections
- Manual checks are performed on encryption configuration without quantum-specific considerations
- Structured testing process validates encryption algorithms, key sizes, and storage-specific controls against quantum risk factors
- Automated validation processes continuously assess storage protections and flag deviations from quantum-resilient standards

**Evidence to Look For**:
- Testing reports verifying implementation of AES-256, hybrid key wrapping, or authenticated encryption modes
- Tools or scripts used to scan storage platforms for cryptographic misconfigurations or legacy algorithms
- Simulated failure scenarios that test the impact of expired, weak, or misconfigured keys in storage systems
- Validation coverage maps showing which storage environments (e.g., on-prem, cloud, backups) meet quantum-resistant control requirements

#### Stream B: Strategy & Innovation (40%)

##### Level 1 - Basic
**Question**: How is your organization's storage security strategy designed to support long-term data protection and resilience?

**Explanation**: This examines your approach to building a strategic framework for protecting stored data over time, including how your architecture, encryption models, and lifecycle policies account for data retention timelines, algorithm management, and evolving cryptographic requirements.

**Options**:
- No strategic storage protection planning is in place
- General storage encryption guidelines exist, but retention and long-term protection needs are not addressed
- Structured storage security strategy accounts for retention timelines, encryption strength, and business risk
- Storage protection strategy integrates retention-aware encryption, cryptographic lifecycle planning, and agility across storage environments

**Evidence to Look For**:
- Storage security strategy documents that define protection requirements based on data classification and retention duration
- Architecture or system design materials showing support for strong encryption (e.g., AES-256), authenticated encryption, and modular cryptographic controls
- Retention-aware encryption policies that require re-encryption or rekeying for long-lived or archived data
- Integration of encryption lifecycle considerations into broader storage planning, procurement, or system refresh strategies

##### Level 2 - Developing
**Question**: How does your organization assess the upgrade and cryptographic support constraints of storage systems?

**Explanation**: This examines your organization's ability to evaluate whether storage platforms can support current and future encryption requirements, considering factors such as key size support, algorithm agility, re-encryption feasibility, and performance or architectural limitations.

**Options**:
- No assessment of storage system compatibility with encryption requirements exists
- Informal assessments are performed for select systems only
- Structured process evaluates cryptographic capabilities, upgrade feasibility, and rekeying constraints across storage platforms
- Cryptographic support and upgrade limitations are routinely evaluated and integrated into refresh planning, procurement, and protection strategies

**Evidence to Look For**:
- Inventory of storage platforms annotated with supported encryption modes, key sizes, and known limitations
- Architecture diagrams identifying whether systems can support quantum-resistant key sizes for symmetric algorithms, authenticated encryption, or algorithm migration
- Assessment reports evaluating re-encryption feasibility, key length support, or performance limitations in legacy storage
- Tracking of vendor support for quantum-safe encryption, cryptographic agility, and key management integration in storage systems

##### Level 3 - Established
**Question**: How does your organization measure the effectiveness of encryption and key management controls used to protect stored data?

**Explanation**: This examines how your organization evaluates whether its storage security controls—such as encryption strength, key lifecycle enforcement, and protection coverage—are correctly implemented and sufficient to meet both current security needs and long-term data protection requirements, including emerging threats like quantum decryption.

**Options**:
- No measurement process exists for evaluating storage security controls
- Manual tracking of encryption and key use with limited assessment of adequacy or coverage
- Structured measurement framework assesses control effectiveness by algorithm strength, coverage, and retention alignment
- Effectiveness metrics are integrated into ongoing review processes and used to adjust protections based on control performance, risk, and cryptographic evolution

**Evidence to Look For**:
- Metrics tracking algorithm use, key sizes, and encryption mode coverage across storage systems
- Assessment reports linking data retention or classification to encryption strength and key management practices
- Audit logs or monitoring outputs identifying expired, weak, or misconfigured encryption for stored data
- Trend analysis of encryption posture across backup, archive, and primary storage environments

##### Level 4 - Advanced
**Question**: How does your organization identify opportunities to improve the security of encryption and key management for stored data?

**Explanation**: This examines how your organization detects and evaluates potential improvements to storage encryption and key lifecycle controls, including response to control weaknesses, emerging threats, and evolving requirements such as retention timelines or cryptographic standards.

**Options**:
- No process exists for identifying improvements to storage encryption or key management
- Improvements are made informally in response to known weaknesses or incidents
- Structured process is used to evaluate encryption and key management improvements through testing, benchmarking, or architectural review
- Improvement opportunities are identified based on control validation results, monitoring data, and anticipated shifts in cryptographic or operational requirements

**Evidence to Look For**:
- Process documentation outlining how storage security weaknesses are identified and prioritized for improvement
- Records showing use of test environments or validation findings to evaluate new encryption strategies or key handling techniques
- Monitoring reports that flag recurring configuration issues, weak key usage, or performance-related degradation
- Evidence that algorithm, key size, or configuration upgrades are planned in response to long-term data retention or threat horizon considerations

##### Level 5 - Optimizing
**Question**: How does your organization enhance its storage encryption and key management capabilities over time?

**Explanation**: This examines your organization's approach to advancing storage security by continuously evolving encryption methods, key lifecycle processes, and system capabilities in response to emerging threats, technology advancements, and long-term data protection requirements.

**Options**:
- No structured enhancement of storage security capabilities is performed
- Capability updates are applied as needed, without a formal review process
- Enhancements are driven by regular assessments of security needs, system performance, and cryptographic alignment
- Storage security capabilities are continuously improved through structured planning, periodic reviews, and targeted adoption of features aligned with evolving data protection needs

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
- No cryptographic protections are applied to data in transit
- Standard transit protocols with default cryptographic settings are used
- Transit protocols are configured with strong cryptographic settings, aligned with policy and coverage expectations
- Cryptographic protections are consistently applied and validated across protocols, with automated configuration enforcement and cryptographic agility support

**Evidence to Look For**:
- Documentation of protocols used for securing data in transit (e.g., TLS 1.2+, IPsec, SSH, QUIC)
- Configuration records enforcing key exchange methods and cipher suites
- Inventory of communication services and whether they support authenticated and encrypted sessions
- Policy documents requiring the use of cryptographic protections for specific communication types (e.g., APIs, file transfers, internal service calls)

##### Level 2 - Developing
**Question**: How does your organization manage secure communication protocols?

**Explanation**: This examines your approach to selecting, configuring, and maintaining communication protocols that provide encryption, authentication, and integrity for data in transit, ensuring they are securely implemented, interoperable, and aligned with organizational requirements.

**Options**:
- No protocol management exists
- Secure protocols are used, but configurations vary and are not centrally managed
- Structured protocol management approach ensures standardization and proper configuration across systems
- Protocol configurations are centrally managed and continuously enforced using automation and monitoring tools

**Evidence to Look For**:
- Documentation of protocol configuration standards (e.g., required TLS versions, cipher suites, authentication methods)
- Regular reviews or audits of protocol usage and settings across systems and environments
- Decommissioning or mitigation plans for deprecated protocols (e.g., SSL 3.0, TLS 1.0/1.1)
- Procedures for validating interoperability and secure deployment of new protocol versions or services

##### Level 3 - Established
**Question**: How does your organization ensure trusted identity and authentication in secure network communications?

**Explanation**: This examines your approach to enforcing trust models in transit security—ensuring that endpoints are authenticated and that cryptographic protections provide not only encryption but also integrity and verified identity across systems and services.

**Options**:
- No authentication or identity validation is used in network communications
- Authentication is implemented using default or self-managed certificates
- Trusted identity is enforced through structured certificate management and authenticated protocol configurations
- Authentication and trust models are centrally managed with automated issuance, validation, and revocation across the network environment

**Evidence to Look For**:
- Use of mutual TLS (mTLS), IPsec with IKE authentication, or SSH key verification for high-trust communications
- Documentation of certificate management practices (issuance, renewal, revocation) for network-facing systems
- Configuration of protocols to validate peer identity (e.g., TLS client authentication, signed tokens, validated public keys)
- Tools or platforms used to automate trust policy enforcement and certificate lifecycle monitoring

##### Level 4 - Advanced
**Question**: How does your organization enforce minimum cryptographic standards to prevent downgrade attacks in data-in-transit protocols?

**Explanation**: This examines how your organization ensures that communication protocols reject insecure configurations and prevent fallback to deprecated cryptographic settings—such as weak cipher suites, insecure versions, or unauthenticated channels.

**Options**:
- No controls exist to prevent the use of insecure or deprecated protocols
- Protocols support secure options, but fallback to weaker settings is not restricted
- Enforcement mechanisms ensure that insecure protocol versions or ciphers are disabled and downgrade attempts are logged
- Centralized controls and monitoring systems detect and block protocol downgrade behavior with real-time enforcement and analytics

**Evidence to Look For**:
- Policies or scanning tools that block use of deprecated protocols (e.g., SSL, TLS 1.0/1.1, anonymous cipher suites)
- Alerts or audit logs identifying downgrade attempts or unauthorized protocol negotiations
- Use of tools such as SMTP MTA-STS, DNSSEC, HSTS, or DANE to enforce authenticated secure connections in email and web communications
- Enforcement of STARTTLS, TLS_FALLBACK_SCSV, or similar mechanisms to prevent stripping or forced fallback

##### Level 5 - Optimizing
**Question**: How does your organization validate the effectiveness of cryptographic protections used in transit protocols?

**Explanation**: This examines your approach to testing and verifying whether the encryption, key exchange, authentication, and integrity protections used in transit protocols are correctly implemented and aligned with security objectives.

**Options**:
- No validation process exists for cryptographic protections in transit protocols
- Functional testing is performed, but cryptographic settings and security assumptions are not consistently verified
- Structured validation process tests encryption strength, authentication mechanisms, and protocol configurations across communication channels
- Transit security validations are automated, integrated into system testing, and continuously updated to reflect evolving cryptographic requirements

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
- No defined approach or documentation exists for securing data in transit
- Fundamental security guidelines exist, but they are informal or applied inconsistently
- Documented approach guides the use of transit protection protocols and cryptographic settings across the organization
- The transit security approach is updated based on evolving requirements, technical assessments, and integration with broader security planning

**Evidence to Look For**:
- Documented policies or standards outlining acceptable encryption protocols and configurations for data in transit
- Strategy documents or guidelines addressing protection of internal and external communication paths
- System or network architecture diagrams indicating where transit protections (e.g., TLS, VPNs) are required
- Defined responsibilities for maintaining protocol security, including certificate or key lifecycle

##### Level 2 - Developing
**Question**: How does your organization prioritize communication channels for enhanced cryptographic protection?

**Explanation**: This examines how your organization determines which systems or communication paths receive stronger transit protections—based on factors such as data sensitivity, threat exposure, business impact, and technical feasibility.

**Options**:
- No prioritization process exists for securing communication channels
- General criteria are used to guide which communications should be protected, but prioritization is informal or inconsistent
- Structured prioritization framework evaluates communication paths based on risk, sensitivity, and operational requirements
- Multi-factor prioritization model is used to guide deployment of transit protections based on real-time risk, value, and system context

**Evidence to Look For**:
- Documentation of prioritization criteria for protecting communication channels (e.g., public vs. internal, high-volume APIs, executive communications)
- Risk assessments or data flow maps identifying channels with the highest exposure or sensitivity
- Methodology documents outlining how communication systems are ranked or tiered for protection deployment
- Adjustments to protection rollout based on operational constraints (e.g., bandwidth, protocol limitations, dependency mapping)

##### Level 3 - Established
**Question**: How does your organization manage and validate trust anchors for secure communication protocols?

**Explanation**: This examines your approach to managing root certificates, public keys, and trust stores used in transit protocols—ensuring that connections are authenticated against current, trusted authorities and that revocation or compromise is handled effectively.

**Options**:
- Trust anchors and certificate validation are not actively managed
- Default or unmanaged trust stores are used, with minimal oversight
- Trust anchors are reviewed and managed using structured procedures for validation, rotation, and revocation
- Certificate and trust anchor management is automated, regularly audited, and integrated with real-time revocation and alerting mechanisms

**Evidence to Look For**:
- Inventory or documentation of trusted CAs, certificate chains, or SSH key authorities used in communication protocols
- Policies defining how root and intermediate certificates are validated, approved, and rotated
- Use of certificate management platforms or automation for issuance, renewal, and revocation
- Regular review processes to remove unused or outdated CAs and monitor third-party trust anchor integrity

##### Level 4 - Advanced
**Question**: How does your organization assess and enforce cryptographic protections in third-party or externally managed communication channels?

**Explanation**: This examines your approach to ensuring that cryptographic protections—such as encryption, authentication, and protocol strength—are applied effectively to data in transit even when the communication path is partially or fully controlled by external providers, partners, or vendors.

**Options**:
- No visibility or validation of cryptographic protections for third-party or vendor-managed communication paths
- Reliance on third-party assurances or default encryption settings without active validation
- Cryptographic requirements are defined and enforced through contracts, technical assessments, or integration standards
- External communication protections are continuously monitored, tested, and governed through security SLAs, audits, and automated trust enforcement

**Evidence to Look For**:
- Contractual or SLA requirements specifying encryption and authentication standards for third-party communications
- Use of tools to scan or test cryptographic posture of APIs, email relays, or SaaS endpoints (e.g., TLS certs, protocol configs)
- Participation in shared protocol management frameworks (e.g., MTA-STS, DANE, mutual TLS) with external partners
- Logs or reports showing validation of encryption and authentication settings for federated, outsourced, or cloud-based services

##### Level 5 - Optimizing
**Question**: How does your organization plan for interoperability and backward compatibility during cryptographic transitions in transit protocols?

**Explanation**: This examines how your organization manages the risks and dependencies associated with upgrading transit-layer cryptography—ensuring that secure communication remains functional across legacy systems, third-party clients, and modern endpoints during algorithm or protocol changes.

**Options**:
- No consideration is given to interoperability during cryptographic upgrades
- Compatibility issues are handled informally or reactively during transitions
- Upgrade planning includes documented strategies for backward compatibility
- Cryptographic transitions are guided by interoperability testing, staged rollouts, and automated fallback strategies

**Evidence to Look For**:
- Documentation of upgrade plans that assess impact on legacy or third-party systems during cryptographic changes
- Architecture diagrams or configuration files supporting dual-stack (e.g., hybrid) implementations in TLS or VPNs
- Records of internal or vendor-supported interoperability testing for cryptographic transitions (e.g., new TLS libraries, PQ-ready clients)
- Mitigation strategies to handle failures or incompatibility with older clients (e.g., logging, alerts, fallback policies)

## Dimension Summary

Dimension 3 provides comprehensive data protection engineering capabilities essential for quantum readiness. Organizations must establish strong capabilities in:

1. **Data Classification & Protection Requirements**: Systematic identification and protection of quantum-sensitive data
2. **Storage Security & Encryption Management**: Quantum-resistant protection for data at rest
3. **Transit Security & Protocol Management**: Secure communications using quantum-safe protocols

Success in this dimension enables organizations to:
- Protect sensitive data against both current and future quantum threats
- Implement systematic data classification aligned with quantum risk timelines
- Deploy quantum-resistant encryption for data at rest and in transit
- Maintain data protection effectiveness throughout evolving cryptographic standards

Strong data protection engineering capabilities ensure that organizations can maintain data confidentiality, integrity, and availability while transitioning to quantum-safe technologies and processes.

---

*This document provides the complete evaluation framework for Dimension 3. For assessment instructions and scoring methodology, refer to the QRAMM Assessment Guide.*

**Document Version**: 1.0  
**Last Updated**: May 30, 2025  
**Authors**: Emily (Stamm) Fane, Abdel Sy Fane  
**Organization**: CyberSecurity NonProfit (CSNP)  
**Framework**: Quantum Readiness Assurance Maturity Model (QRAMM)
