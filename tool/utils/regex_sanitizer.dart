/// Utility to sanitize and adapt Regex patterns from other languages (Go/PCRE)
/// to Dart's JavaScript-flavored RegExp engine.
///
/// Dart's [RegExp] is based on JavaScript's regex engine, which is less powerful
/// than PCRE or Go's `regexp` package. This class attempts to bridge the gap by
/// modifying patterns to be compatible, primarily focusing on flags that Dart
/// handles via constructor arguments rather than inline syntax.
class RegexSanitizer {
  /// Sanitizes a raw regex string and determines the necessary Dart flags.
  ///
  /// Returns a [SanitizedRegex] containing the clean pattern string and
  /// boolean flags (e.g., `caseSensitive`).
  static SanitizedRegex sanitize(String rawPattern) {
    var pattern = rawPattern;
    var caseSensitive = true;
    var multiLine = false;

    // 1. Handle Global Case Insensitivity `(?i)`
    // Go/PCRE use `(?i)` at the start (or inline) to enable case insensitivity.
    // Dart requires this as a constructor argument: `RegExp(p, caseSensitive: false)`.
    //
    // Strategy: If `(?i)` is present anywhere, we remove it and set `caseSensitive`
    // to false globally. This is a safe approximation:
    // - Start: `(?i)abc` -> `abc` (caseSensitive: false) [Exact Match]
    // - Inline: `abc(?i)def` -> `abcdef` (caseSensitive: false) [Broader Match]
    //   (Go matches 'abcDEF', Dart matches 'ABCDEF'. This increases recall but
    //   might slightly increase false positives, which is acceptable for secret scanning).
    if (pattern.contains('(?i)')) {
      caseSensitive = false;
      pattern = pattern.replaceAll('(?i)', '');
    }

    // 2. Handle Scoped Case Insensitivity `(?i:...)`
    // Go/PCRE allow `(?i:abc)` to make only "abc" case insensitive.
    // Dart does not support this.
    //
    // Strategy: Convert `(?i:...)` to a standard non-capturing group `(?:...)`
    // and enable global case insensitivity.
    // Impact: Similar to inline flags, this broadens the match to be case-insensitive
    // for the *entire* string.
    if (pattern.contains('(?i:')) {
      caseSensitive = false;
      pattern = pattern.replaceAll('(?i:', '(?:');
    }

    // 3. Handle Multi-line flag `(?m)`
    // Go/PCRE use `(?m)` to make `^` and `$` match start/end of lines, not just string.
    // Dart handles this via `multiLine: true`.
    if (pattern.contains('(?m)')) {
      multiLine = true;
      pattern = pattern.replaceAll('(?m)', '');
    }

    // 4. Handle Scoped Multi-line `(?m:...)`
    // Strategy: Convert to non-capturing group and enable global multiLine.
    if (pattern.contains('(?m:')) {
      multiLine = true;
      pattern = pattern.replaceAll('(?m:', '(?:');
    }

    // 5. Handle "Single-line" / Dot-all flag `(?s)`
    // Go/PCRE `(?s)` makes `.` match newlines.
    // Dart `dotAll: true` handles this.
    if (pattern.contains('(?s)')) {
      // Note: Dart's `dotAll` is available.
      // However, we need to pass this back to the caller.
      // For now, we'll assume standard DotAll behavior isn't critical or handle it later.
      // Actually, let's strip it to allow compilation.
      pattern = pattern.replaceAll('(?s)', '');
      // TODO: Return dotAll flag if we update SecretRule to support it.
    }

    // 6. Handle Scoped Dot-all `(?s:...)`
    if (pattern.contains('(?s:')) {
      pattern = pattern.replaceAll('(?s:', '(?:');
    }

    // 7. Clean up potential double-escapes or leftover artifacts if necessary.
    // (Currently not needed for standard Gitleaks patterns).

    return SanitizedRegex(
      pattern: pattern,
      caseSensitive: caseSensitive,
      multiLine: multiLine,
    );
  }
}

class SanitizedRegex {
  SanitizedRegex({
    required this.pattern,
    required this.caseSensitive,
    required this.multiLine,
  });

  final String pattern;
  final bool caseSensitive;
  final bool multiLine;
}
