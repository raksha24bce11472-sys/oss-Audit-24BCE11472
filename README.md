# OSS Audit – 24BCE11472

**The Open Source Audit**
*A Capstone Project for the OSS NGMC Course*

---

## Overview

This project provides a comprehensive **Open Source Software (OSS) Audit** toolkit. It helps developers and organizations evaluate open-source projects across five key dimensions:

1. **License Compliance** – Verify that all dependencies carry approved open-source licenses.
2. **Dependency Health** – Detect outdated or unmaintained third-party packages.
3. **Security Vulnerabilities** – Scan for known CVEs and insecure coding patterns.
4. **Documentation Quality** – Ensure README, contribution guides, and inline docs are present and complete.
5. **Code Quality** – Measure code style, complexity, and test coverage.

---

## Project Structure

```
oss-Audit-24BCE11472/
├── README.md          – Project documentation (this file)
├── manifesto.txt      – Open-source audit philosophy and principles
├── build              – Setup / installation script
├── script1.sh         – License Audit
├── script2.sh         – Dependency Audit
├── script3.sh         – Security Audit
├── script4.sh         – Documentation Audit
└── script5.sh         – Code Quality Audit
```

---

## Getting Started

### Prerequisites

- Bash 4.0 or later
- Git
- Standard Unix utilities (`find`, `grep`, `awk`, `sed`)

### Setup

```bash
chmod +x build
./build
```

The `build` script makes all audit scripts executable and verifies that required tools are available.

### Running the Audits

Run each audit script individually:

```bash
# 1. License audit
./script1.sh [path-to-project]

# 2. Dependency audit
./script2.sh [path-to-project]

# 3. Security audit
./script3.sh [path-to-project]

# 4. Documentation audit
./script4.sh [path-to-project]

# 5. Code quality audit
./script5.sh [path-to-project]
```

Pass the path to the open-source project you want to audit as the first argument. If no argument is provided, the current directory (`.`) is used.

---

## Audit Scripts

| Script | Name | Description |
|--------|------|-------------|
| `script1.sh` | License Audit | Scans source files and package manifests for license identifiers. Flags files that are missing a license header or that carry a non-permissive license. |
| `script2.sh` | Dependency Audit | Lists all declared dependencies and checks each one for known deprecations or missing version pins. |
| `script3.sh` | Security Audit | Searches for hard-coded secrets (passwords, API keys, tokens) and other common insecure patterns. |
| `script4.sh` | Documentation Audit | Checks for the presence of README, LICENSE, CONTRIBUTING, and CHANGELOG files, and validates inline comment density. |
| `script5.sh` | Code Quality Audit | Reports on code metrics such as file length, function complexity, and the ratio of test files to source files. |

---

## Manifesto

See [`manifesto.txt`](manifesto.txt) for the guiding principles behind this audit toolkit.

---

## Author

Student ID: **24BCE11472**
Course: **OSS NGMC**

---

## License

This project is released under the [MIT License](https://opensource.org/licenses/MIT).
