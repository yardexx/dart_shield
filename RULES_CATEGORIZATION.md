# Dart Shield Rule Categorization Concept

This document outlines a proposed categorization for `dart_shield`'s security rules, aligning them with the OWASP Mobile Top 10 (2024) standard. This approach aims to provide a more structured and universally recognized classification for our rules, benefiting both codebase organization and user documentation.

## Goals

*   **Standardization**: Align with an industry-recognized security standard (OWASP Mobile Top 10) to enhance clarity and relevance.
*   **Organization**: Improve code structure by grouping related rules logically.
*   **Documentation**: Provide a clearer, more navigable rulebook for users.

## Proposed Categories and Rule Mapping

Based on existing rules and common security concerns for Dart/Flutter applications, the following categories are proposed:

---

### 1. Cryptography (OWASP Mobile Top 10: M10 - Insufficient Cryptography)

This category focuses on rules designed to identify and flag insecure or weak cryptographic practices within the codebase.

**Existing Rules:**
*   `avoid_weak_hashing.dart` (Detects use of weak hashing algorithms like MD5, SHA-1)
*   `prefer_secure_random.dart` (Flags non-cryptographically secure random number generators)

**Proposed Folder Location:**
`lib/src/analyzers/code/rules/cryptography/`

---

### 2. Network (OWASP Mobile Top 10: M5 - Insecure Communication)

This category covers rules related to the security of data in transit and communication protocols, ensuring secure channels and endpoints.

**Existing Rules:**
*   `prefer_https_over_http.dart` (Warns against using insecure HTTP where HTTPS is preferred)
*   `avoid_hardcoded_urls.dart` (Encourages configurable and secure URL management)

**Proposed Folder Location:**
`lib/src/analyzers/code/rules/network/`

---

### 3. Secrets (OWASP Mobile Top 10: M1 - Improper Credential Usage)

This category addresses the detection of sensitive information, such as API keys, tokens, and credentials, being hardcoded directly into the application.

**Existing Rules:**
*   `avoid_hardcoded_secrets.dart` (Identifies various hardcoded secret patterns)

**Proposed Folder Location:**
`lib/src/analyzers/code/rules/secrets/` (This folder already exists and contains related helper logic, making it a natural fit for this rule.)

---

## Proposed Codebase Restructuring

To implement this categorization, the following steps would be taken in the codebase:

1.  Create new subdirectories within `lib/src/analyzers/code/rules/`:
    *   `cryptography/`
    *   `network/`
2.  Move the respective rule files into their new category-specific folders.
3.  Update `lib/src/analyzers/code/rules/rules.dart` to reflect the new import paths for all moved rules.

## Future Categories

As `dart_shield` evolves, new rules can be introduced and mapped to other relevant OWASP Mobile Top 10 categories, such as:

*   **Storage** (M9: Insecure Data Storage)
*   **Injection** (M4: Insufficient Input/Output Validation)
*   **WebView** (M5: Insecure Communication / M4: Insufficient Input/Output Validation, depending on specific rule)

This structured approach will help in expanding `dart_shield`'s coverage in an organized and industry-recognized manner.
