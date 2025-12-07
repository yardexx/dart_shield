# Dart Shield - Feature Roadmap & Ideas

This document tracks high-impact features that could distinguish `dart_shield` as the premier security tool for the Dart/Flutter ecosystem.

## 🚀 High Impact / "Killer" Features

### 1. Dependency Shield (Supply Chain Security)
**Concept:** Integrate with the OSV (Open Source Vulnerabilities) database to scan `pubspec.lock` for packages with known security advisories.
**Value:** "Single Pane of Glass" for security. Users don't need to run `dart pub audit` separately; `dart_shield` covers both Code and Dependencies.
**Implementation:**
*   Parse `pubspec.lock`.
*   Query OSV API (batch).
*   Report CVEs directly in the CLI output.

### 2. "Shield Ignore" & Baselines (Legacy Support)
**Concept:** Allow teams to adopt `dart_shield` in large, existing projects without fixing 1000 legacy issues immediately.
**Value:** Eliminates the "all or nothing" adoption barrier.
**Implementation:**
*   `dart_shield baseline`: Generates a `shield_baseline.yaml` recording all current issues.
*   `analyze`: Ignores issues present in the baseline, reporting only *new* violations.
*   Support standard `// ignore: rule_id` comments (leveraging Analyzer's ignore mechanism).

### 3. Intelligent Auto-Fix
**Concept:** Automatically resolve common security issues.
**Value:** Reduces friction from "detection" to "resolution".
**Implementation:**
*   **HTTP -> HTTPS:** Auto-rewrite URLs.
*   **Weak Random:** `Random()` -> `Random.secure()`.
*   **Weak Hash:** `md5` -> `sha256` (with warning).
*   **Hardcoded Secret:** Suggest refactoring to `Platform.environment['VAR']` (Code Action).

### 4. "Taint Analysis" / Data Flow Analysis (Advanced)
**Concept:** Track untrusted data (e.g., from API/User Input) to sensitive sinks (e.g., SQL query, `Process.run`).
**Value:** Detects complex vulnerabilities like SQL Injection, Command Injection, or XSS that simple regex/AST checks miss.
**Implementation:**
*   Mark sources (arguments to `main`, `HttpRequest`, `stdin`).
*   Mark sinks (`execute()`, `eval()`).
*   Trace variable assignments through the AST to see if tainted data reaches a sink without sanitization.

### 5. "PII Scout" (Privacy)
**Concept:** Detect potential logging or leakage of Personally Identifiable Information (PII).
**Value:** Helps with GDPR/CCPA compliance.
**Implementation:**
*   Detect variable names like `email`, `password`, `ssn`, `creditCard`.
*   Flag if these variables are passed to `print()`, `log()`, or sent to external analytics services (e.g., Firebase Analytics, Sentry) without hashing.

### 6. CI/CD Integration & Reporting
**Concept:** Native support for GitHub Actions, GitLab CI, etc.
**Value:** "Plug and Play" security pipelines.
**Implementation:**
*   Output formats: SARIF (standard for GitHub Security), JUnit XML.
*   GitHub Action marketplace entry.
*   Annotate PRs directly (using SARIF).

### 7. "Shield Policy" (Enterprise Control)
**Concept:** Enforce security policies across an organization.
**Value:** Standardization for large teams.
**Implementation:**
*   Remote config: Load `shield_options.yaml` from a URL (e.g., internal repo).
*   "Strict Mode": Disallow ignores for critical severities.

### 8. Flutter-Specific Security
**Concept:** Rules tailored for mobile risks.
**Value:** Niche dominance in the Flutter space.
**Implementation:**
*   **Manifest Analysis:** Check `AndroidManifest.xml` for dangerous permissions (`READ_SMS`, `SYSTEM_ALERT_WINDOW`).
*   **Plist Analysis:** Check `Info.plist` for `NSAppTransportSecurity` (allowing arbitrary loads).
*   **WebView:** Flag `useHybridComposition: true` or insecure WebView settings.
*   **Local Auth:** Ensure `local_auth` is used correctly.

### 9. "Graph Shield" (Architecture Viz)
**Concept:** Visualize the security posture.
**Value:** "Manager-friendly" reports.
**Implementation:**
*   Generate an HTML/Graphviz report showing dependencies and flagged hotspots.

### 10. "Secret Canary" / "Honeytoken" Detection
**Concept:** Integrate with Canarytokens to manage or verify found secrets.
**Value:** Proactive defense.
**Implementation:**
*   Check if found secrets are known Honeytoken formats.
*   Suggest replacing hardcoded secrets with Honeytokens for tests.

### 11. "Interactive Security Training" (Edu-Tech)
**Concept:** Mini-tutorials in the terminal.
**Value:** Upskills the team.
**Implementation:**
*   `dart_shield explain <rule_id>`: Shows "Bad Code" vs "Good Code" and explains the risk.

### 12. "Shadow Dependencies" / "Typosquatting" Detector
**Concept:** Detect malicious packages that look like popular ones (e.g., `providr` vs `provider`).
**Value:** Protects against supply chain attacks.
**Implementation:**
*   Check `pubspec.yaml` against top packages using Levenshtein distance.

### 13. "License Compliance" (Legal Shield)
**Concept:** Check dependency licenses (GPL, AGPL, etc.).
**Value:** Enterprise requirement.
**Implementation:**
*   Scan package licenses.
*   Flag incompatible licenses based on project type.

### 14. "Pre-Commit Hook" Installer
**Concept:** Frictionless setup to block secrets before commit.
**Value:** Prevention > Cure.
**Implementation:**
*   `dart_shield install-hook`: Installs a Git pre-commit hook.

### 15. "Cloud Configuration Scanner" (IaC)
**Concept:** Scan Dockerfile and docker-compose.yaml.
**Value:** Full stack coverage for Dart backends.
**Implementation:**
*   Flag `USER root`.
*   Flag secrets in `ENV` vars.

### 16. "Binary Inspector" (Reverse Engineering)
**Concept:** Analyze the compiled output (`.apk`, `.ipa`, `.exe`).
**Value:** Verifies what actually ships (e.g., "Did obfuscation work?").
**Implementation:**
*   **Strings:** Run `strings` on the binary to check if secrets/API keys are still visible in the compiled artifact (e.g., `libapp.so`).
*   **Obfuscation Check:** Verify if symbols are stripped/obfuscated.
*   **Permissions:** Read final merged manifest from APK.

### 17. "Network Traffic Monitor" (DevTool Proxy)
**Concept:** A local proxy to inspect HTTP traffic from the running Dart app.
**Value:** Detects unencrypted traffic or sensitive data sent in cleartext during development.
**Implementation:**
*   Spin up a local proxy (like helper for Charles/MITMProxy).
*   Flag HTTP requests.
*   Flag sensitive data (passwords, tokens) in URL parameters or bodies.