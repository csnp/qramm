# QRAMM: Quantum Readiness Assurance Maturity Model

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> Part of the **QRAMM** toolkit by CSNP: [CryptoScan](https://github.com/csnp/cryptoscan), [CryptoDeps](https://github.com/csnp/cryptodeps), [TLS Analyzer](https://github.com/csnp/tls-analyzer). Framework: [qramm.org](https://qramm.org).

[Website](https://qramm.org) · [Toolkit](toolkit/toolkit-overview.md) · [Quick assessment](https://qramm.org/quick-assessment.html)

QRAMM is a free and open framework that helps an organization find out how ready it is for quantum computers and plan its move to quantum-safe cryptography. It looks at four dimensions, places each one on five maturity levels through 120 assessment questions, and comes with an Excel toolkit that does the scoring for you.

Start with [the four dimensions](framework/qramm-overview.md#the-4-dimensions) in the framework overview. They are what you rate your organization against.

CryptoScan automates part of Dimension 1: it inventories the cryptography in a code repository and maps each finding to practice 1.1, 1.2 or 1.3 ([CryptoScan guide](https://qramm.org/learn/cryptoscan-guide.html)):

```bash
go install github.com/csnp/cryptoscan/cmd/cryptoscan@latest
cryptoscan scan .
```

## Open source tools

These tools automate parts of a QRAMM assessment. The [Open Source Tools page](https://qramm.org/open-source-tools.html) has a guide for each one.

### Maintained by CSNP

These are built and maintained alongside the framework, and CSNP stands behind them. They support Dimension 1 (Cryptographic Visibility & Inventory).

| Tool | Description | Repository |
|------|-------------|------------|
| **CryptoScan** | Cryptographic discovery scanner: scans codebases for quantum-vulnerable algorithms with SARIF and CBOM output | [GitHub](https://github.com/csnp/cryptoscan) |
| **TLS Analyzer** | TLS/SSL configuration analyzer: evaluates cipher suites and key exchange, detects hybrid ML-KEM key exchange, and tracks CNSA 2.0 compliance | [GitHub](https://github.com/csnp/tls-analyzer) |
| **CryptoDeps** | Dependency crypto analyzer: identifies quantum-vulnerable algorithms in your software supply chain | [GitHub](https://github.com/csnp/cryptodeps) |

### Community and third-party tools

Tools from the wider community that people using QRAMM may find useful. They are
not maintained by CSNP, are not part of the QRAMM toolkit, and listing one here
is not an endorsement or a security review. Evaluate any of them the same way you
would evaluate any other third-party dependency.

| Tool | Description | Maintainer | Repository |
|------|-------------|------------|------------|
| **pqc-tools** | Finds quantum-vulnerable cryptography in code, writes CycloneDX CBOMs and gives NIST migration guidance. CLI, MCP server and GitHub Action. | quantakrypto | [GitHub](https://github.com/quantakrypto/pqc-tools) |

To propose a tool for this table, open a pull request. Please include the license,
who maintains it, and a link to its documentation.

## The framework

QRAMM looks at four dimensions, each with three practices. The [framework overview](framework/qramm-overview.md) describes every one of them.

1. **Cryptographic Visibility & Inventory (CVI)**: find and list the cryptography your systems use.
2. **Strategic Governance & Risk Management (SGRM)**: leadership, policy and risk management for the move.
3. **Data Protection Engineering (DPE)**: protect data at rest, in transit and in use.
4. **Implementation & Technical Readiness (ITR)**: deploy, integrate and maintain quantum-safe technology.

Your answers place you on [five maturity levels](framework/maturity-levels.md), from Basic to Optimizing. The [scoring methodology](framework/scoring-methodology.md) explains how answers become scores.

## Assessment toolkit

The Excel toolkit holds all 120 questions, scores your answers for you, adjusts the result for your organization's risk profile, and maps it to eight compliance frameworks.

- [Download the toolkit](toolkit/QRAMM_Assessment_Toolkit.xlsx)
- [Sample assessment](toolkit/Sample_Assessment.xlsx), already filled in
- [Toolkit overview](toolkit/toolkit-overview.md)
- [Screenshots of the scorecards and compliance views](docs/toolkit-visuals.md)

## Getting started

1. Take the [quick assessment](https://qramm.org/quick-assessment.html) for a first maturity score in 5 to 10 minutes.
2. Follow the [getting started guide](implementation/getting-started.md) to plan a full assessment.
3. Use the [templates](templates/) for an executive report, asset inventory, vendor questionnaire and evidence collection.

## Compliance mapping

The toolkit maps QRAMM to eight frameworks and standards: NIST PQC, NIST CSF, CMMC, FISMA, FedRAMP, ISO 27001, SOC 2 and CIS Controls ([descriptions](docs/overview.md#regulatory-compliance--standards)). The [compliance mapping](framework/compliance-mapping.md) shows practice by practice how QRAMM supports NIST PQC, CMMC, FedRAMP and FISMA, and the [coverage summary](framework/compliance-coverage-summary.md) gives a quick reference.

## Documentation

- [Overview](docs/overview.md): business value, architecture, roadmap, scoring and standards
- [Frequently asked questions](docs/faq.md)
- [Framework overview](framework/qramm-overview.md)
- [All 120 assessment questions](framework/Complete_QRAMM_Questions.md)
- [Full assessment](framework/full-assessment.md)
- [Maturity levels](framework/maturity-levels.md) and [scoring methodology](framework/scoring-methodology.md)
- [Toolkit overview](toolkit/toolkit-overview.md) and [toolkit screenshots](docs/toolkit-visuals.md)
- [Getting started guide](implementation/getting-started.md)
- [Templates](templates/)

## Contributing

QRAMM welcomes contributions from security professionals, quantum researchers, enterprise architects and compliance specialists. Open an issue or a pull request, or join [GitHub Discussions](https://github.com/csnp/qramm/discussions). For questions about the framework, write to [qramm@csnp.org](mailto:qramm@csnp.org).

QRAMM is written by Emily (Stamm) Fane, author, and Abdel Fane, co-author, of [CyberSecurity NonProfit (CSNP)](https://csnp.org). See [Framework Development](docs/overview.md#framework-development).

## License

QRAMM is released under the [MIT License](LICENSE). To cite it:

```bibtex
@software{qramm2025,
  title = {QRAMM: Quantum Readiness Assurance Maturity Model},
  author = {Fane, Emily and Fane, Abdel},
  organization = {CyberSecurity NonProfit (CSNP)},
  year = {2025},
  url = {https://qramm.org}
}
```

*QRAMM is a trademark of CyberSecurity NonProfit (CSNP)*  
*© 2025 CSNP. All rights reserved.*
