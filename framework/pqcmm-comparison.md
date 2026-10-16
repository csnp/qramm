# QRAMM beside PQCMM
**How the Quantum Readiness Assurance Maturity Model and the PKI Consortium's PQC Maturity Model fit together**

This comparison was written by the QRAMM maintainers at CSNP. It was written without the authors of the PQC Maturity Model (PQCMM) at the PKI Consortium (PKIC). They have not reviewed it, and nothing here is their view or carries their endorsement. It is our side's draft, written to start a conversation with them, and we expect it to change after that conversation.

The PQCMM text quoted below comes from the PKI Consortium's own pages, fetched 2026-10-16. If those pages change, this document should change with them.

## 1. Two models, two different subjects

PQCMM scores a product or a service. QRAMM scores an organization.

- **PQCMM** asks how ready one product or service is for post-quantum cryptography (PQC). In the PKI Consortium's words, it "evaluates the post-quantum readiness of products and services in the supply chain" and is "explicitly product and service-centric" ([PQCMM overview](https://pkic.org/wg/pqc/pqcmm/)). It has six levels, numbered 0 to 5.
- **QRAMM** asks how ready your organization is: whether you know where your cryptography is, whether leadership and policy support the change, how you protect your data, and whether your teams can carry out and test the change. It has 4 dimensions, 12 practices, 5 maturity levels and 120 questions ([QRAMM overview](qramm-overview.md)).

The two are complementary, not competing. An organization uses QRAMM to look at itself, and PQCMM to look at each product it buys or ships. A product's PQCMM level is evidence the organization can use when it answers some of its own QRAMM questions. Section 2 shows where.

**The level numbers do not line up.** A product at PQCMM Level 3 says nothing about whether the organization using it is at QRAMM Level 3. The two models also use the word "Advanced" for different levels: in PQCMM it is Level 3, and in QRAMM it is Level 4 ([QRAMM maturity levels](maturity-levels.md)). When you report a level, name the model with it.

**Which versions are compared.** The [PQCMM version history](https://pkic.org/wg/pqc/pqcmm/version-history/) page, fetched 2026-10-16, names "PQCMM Version 1.0.0", released May 8, 2026, as the current version. Its revision log also lists "Release 1.0.1 (June 2026)", which renamed Level 2 from "Basic" to "Foundational". The level names quoted below use "Foundational". Question 1 in section 5 asks the authors which version string applies. The QRAMM side is the framework in this repository, [QRAMM overview](qramm-overview.md) document version 1.1.

## 2. PQCMM levels beside QRAMM practices

The middle column quotes each level's summary from the PQCMM levels page, https://pkic.org/wg/pqc/pqcmm/levels/, fetched 2026-10-16. Each level also has detailed criteria on its own page; the summary is the short form.

The right column lists the QRAMM practices, with question numbers from [the 120 questions](Complete_QRAMM_Questions.md), where a product at that level gives your organization evidence to cite in its answer. A product's level is never the whole answer to a QRAMM question, because QRAMM asks about your organization, not about one product.

PQCMM levels are cumulative. In PQCMM's words, "a product at Level 3 must satisfy every requirement from Levels 1 and 2 as well." So a product at a higher level also gives the evidence listed for the levels below it.

| PQCMM level | What the PQCMM levels page says | QRAMM practices this level gives evidence for |
|---|---|---|
| Level 0: None | "PQC might be in the preparation phase, but no quantum-safe algorithms have matured into the product." | None yet. Record the product as a gap under Practice 2.3 (Third-Party & Supply Chain Risk Management), questions 51 and 58, which ask how you assess vendor readiness and which systems could delay your own transition. |
| Level 1: Initial | "PQC algorithms are available but for testing and evaluation only; not production-ready." | Practice 4.3 (Testing & Validation Capabilities), questions 111 and 113: your team can start pilot and performance testing with the product's quantum-safe feature. This is not yet evidence of anything you can run in production. |
| Level 2: Foundational | "At least one quantum-safe algorithm is available in production and meets relevant standards." | Practice 4.2 (Implementation Capability Development), questions 103 and 105: you can deploy a standards-based quantum-safe option. Then, depending on what the product protects, Practice 3.3 (Transit Security & Protocol Management), question 81, for data in transit, or Practice 3.2 (Storage Security & Encryption Management), questions 72 and 74, for stored data. |
| Level 3: Advanced | "Cryptographic inventory (SBOM/CBOM) is in place, and the product supports crypto agility." | Practice 1.1 (Cryptographic Discovery & Inventory Management), questions 4 and 5: the vendor's inventory covers cryptography you cannot see from outside the product. Practice 1.3 (Cryptographic Dependency Mapping), questions 21 and 30: the software bill of materials (SBOM) shows which cryptographic libraries the product depends on. Practice 4.1 (Infrastructure Assessment & Planning), questions 91 and 94: a product that lets you switch algorithms through configuration is less likely to block your upgrade. Practice 3.1 (Data Classification & Protection Requirements), question 61: at this level the vendor also lists which of the product's data flows are at risk from harvest now, decrypt later. |
| Level 4: Managed | "Legacy algorithms are eliminated or isolated; hybrid support is available." | Practice 3.3 (Transit Security & Protocol Management), questions 84 and 90: the product can turn off every algorithm that is not quantum-safe, which helps prevent downgrade attacks, and it documents its hybrid modes, which helps you plan for compatibility. Practice 4.2 (Implementation Capability Development), question 108: a tested configuration with no legacy algorithms lowers the risk of your transition. Practice 3.2 (Storage Security & Encryption Management), question 71: this level asks for symmetric and hash strengths suited to data that must stay protected for a long time. Practice 1.1 (Cryptographic Discovery & Inventory Management), question 2: this level adds a cryptographic bill of materials (CBOM) you can keep with your own inventory. |
| Level 5: Optimized | "Quantum-safe is the default; performance is benchmarked and the implementation independently verified." | Practice 4.3 (Testing & Validation Capabilities), questions 113 and 114: the vendor's benchmarks and independent verification are assurance evidence you can keep on file. Practice 2.2 (Risk Assessment & Compliance Management), questions 46 and 50: independent verification, such as FIPS 140 validation, supports your compliance and audit work. |

A few terms from the table, in plain words:

- **Crypto agility** means a product can switch from one algorithm to another through configuration, without being rebuilt.
- **Harvest now, decrypt later** means someone records encrypted data today and keeps it until a quantum computer can decrypt it. Data that must stay secret for many years is at risk now, not only later.
- **Hybrid** means a classical algorithm and a quantum-safe algorithm are used together, so the protection holds as long as either one is not broken.
- **SBOM and CBOM**: a software bill of materials lists the components inside a product; a cryptographic bill of materials lists the cryptography it uses, such as algorithms and key sizes.

The Level 3 summary mentions "SBOM/CBOM". The detailed Level 3 criteria ask for a full cryptographic inventory and an SBOM, and the detailed Level 4 criteria add the CBOM, which is why the table places the CBOM at Level 4. Question 2 in section 5 asks the authors about this.

### Your own inventory

A vendor's inventory covers the vendor's product. Practice 1.1 (Cryptographic Discovery & Inventory Management) and Practice 1.3 (Cryptographic Dependency Mapping) also ask about the code your own organization writes or receives as source. For that code, [CryptoScan](https://github.com/csnp/cryptoscan), the open source scanner CSNP maintains for QRAMM Dimension 1, can write what it finds as a CycloneDX 1.6 CBOM:

```
cryptoscan scan ./your-project --format cbom --include-quantum-safe -o cbom.json
```

The `--include-quantum-safe` flag keeps algorithms that need no change (such as AES-256) in the file, so the CBOM lists all of the cryptography found rather than only what needs work. CryptoScan reads source code and configuration and skips compiled binaries, so it cannot see inside a product you buy. For those products, the vendor's inventory at PQCMM Level 3 and its CBOM at Level 4 fill the gap.

## 3. What each model does that the other does not

**PQCMM gives buyers and vendors a shared scale for one product.**

- A buyer can name a PQCMM level in a request for proposal or a contract. PQCMM publishes guidance on [procurement](https://pkic.org/wg/pqc/pqcmm/adoption/procurement/) and [example contract clauses](https://pkic.org/wg/pqc/pqcmm/adoption/contract-clauses/).
- It defines three ways to back a claim: self-assessment by the vendor, third-party assessment, and certification by the PKI Consortium.
- Its level pages list the evidence an assessor must record, such as how a CBOM was produced and whether a configuration with no legacy algorithms was tested.
- QRAMM does not score products. Its [vendor questionnaire template](../templates/vendor-questionnaire-template.md) helps you ask vendors about their readiness, but it does not give a product a level.

**QRAMM covers the organization around the products.**

- **Governance.** Practice 2.1 (Executive Leadership & Policy Management) asks how leadership oversees quantum risk, what policy is in place, and how the work is funded.
- **Data classification.** Practice 3.1 (Data Classification & Protection Requirements) asks which of your data needs quantum-resistant protection, and for how long. PQCMM Level 3 asks a vendor which data flows in its product are at risk; only you can say which of your data matters most.
- **Supply-chain practice.** Practice 2.3 (Third-Party & Supply Chain Risk Management) asks how you assess, contract with and audit your vendors. PQCMM gives you a scale to measure each vendor's product; QRAMM asks whether you use a scale like it, consistently, across all of your suppliers.
- **People and testing.** Practice 4.2 (Implementation Capability Development) and Practice 4.3 (Testing & Validation Capabilities) ask whether your own teams can carry out the change and test it.

PQCMM also leaves an organization's own public key infrastructure to a different PKI Consortium model. Its overview says it "excludes the assessment of an organization's internal public key infrastructure operations or governance, which is covered by the PKI Maturity Model" ([PKI Maturity Model](https://pkic.org/wg/pkimm/model/)).

## 4. How one team uses both

1. **Assess your organization with QRAMM.** Start with the quick assessment at [qramm.org](https://qramm.org), then use the [assessment toolkit](../toolkit/QRAMM_Assessment_Toolkit.xlsx) for all 120 questions.
2. **Ask for a PQCMM level for each product you buy.** List the products that use cryptography, ask each vendor for its PQCMM level and the evidence behind it, and record the answers under Practice 2.3 (Third-Party & Supply Chain Risk Management), questions 51 and 57. PQCMM's own Level 2 page suggests Level 2 as the minimum for new purchases of systems with a long service life, and Level 3 for regulated industries or wherever supply-chain visibility is itself a requirement.
3. **Assess each product you ship with PQCMM.** If your organization also builds products, assess each one against the PQCMM levels. The inventory work overlaps: the scan you run for QRAMM Dimension 1 is a starting point for each product's own cryptographic inventory.
4. **Bring the product levels back into QRAMM.** A product at a low level is a QRAMM finding: a possible upgrade blocker under Practice 4.1 (Infrastructure Assessment & Planning), question 94, and a supply-chain risk under Practice 2.3 (Third-Party & Supply Chain Risk Management), question 58.
5. **Report each level with its model.** Write "QRAMM Level 2" or "PQCMM Level 3", never only "Level 3", so nobody mistakes a product's score for an organization's score.

## 5. Open questions for the PQCMM authors

These are the questions we would like to ask the PQCMM authors. Their answers will shape the next version of this document.

1. **Version.** The version history page names 1.0.0 as the current version and also lists release 1.0.1 (June 2026). Which version string should an assessment cite today, and is the level text quoted above the text of that version?
2. **Where the CBOM starts.** The Level 3 summary mentions "SBOM/CBOM", while the detailed criteria ask for an SBOM at Level 3 and add the CBOM at Level 4. Is a CBOM expected at Level 3, or only from Level 4?
3. **Shared words for levels.** QRAMM and PQCMM both use "Advanced", at different levels, and the PKI Consortium also maintains the PKI Maturity Model for organizations. Would the working group be open to aligning level names, or to a short note on how to report an organization's level and a product's level side by side?
4. **CBOM evidence.** The Level 4 assessment record asks for the name and version of the tool that generated a CBOM. Does the working group plan to name a CBOM format or a minimum set of fields?
5. **Review of this mapping.** Would the working group be willing to review the table in section 2, so that a later version of this document can say whether its authors agree with it?

---

**Status**: draft for discussion with the PQCMM authors, not reviewed by them
**PQCMM pages last checked**: 2026-10-16
**Questions or corrections**: [qramm@csnp.org](mailto:qramm@csnp.org)
