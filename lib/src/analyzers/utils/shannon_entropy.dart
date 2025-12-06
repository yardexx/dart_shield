import 'dart:math';

/// Utility to calculate the Shannon Entropy of a string.
///
/// Shannon Entropy provides a measure of the "randomness" or information
/// density of a string. It is measured in bits.
///
/// - A string with all identical characters (e.g., "aaaaa") has an entropy
///   of 0.
/// - A string with a uniform distribution of unique characters has high
///   entropy.
///
/// This is useful for detecting high-entropy secrets like API keys or tokens
/// versus low-entropy strings like "password123" or "example_string".
class ShannonEntropy {
  static double calculate(String input) {
    if (input.isEmpty) return 0;

    final frequency = <int, int>{};
    for (final codeUnit in input.codeUnits) {
      frequency[codeUnit] = (frequency[codeUnit] ?? 0) + 1;
    }

    final length = input.length;
    var entropy = 0.0;

    for (final count in frequency.values) {
      final probability = count / length;
      entropy -= probability * (log(probability) / ln2);
    }

    return entropy;
  }
}
