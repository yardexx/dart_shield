import 'package:dart_shield/src/utils/shannon_entropy.dart';
import 'package:test/test.dart';

void main() {
  group('ShannonEntropy', () {
    test('returns 0.0 for empty string', () {
      expect(ShannonEntropy.calculate(''), 0.0);
    });

    test('returns 0.0 for string with identical characters', () {
      expect(ShannonEntropy.calculate('aaaaa'), 0.0);
    });

    test('calculates entropy for simple binary string', () {
      // "01" -> 2 symbols, equal probability (0.5)
      // - [0.5 * log2(0.5) + 0.5 * log2(0.5)]
      // - [-0.5 + -0.5] = -(-1) = 1.0 bit
      expect(ShannonEntropy.calculate('01'), closeTo(1.0, 0.0001));
    });

    test('calculates higher entropy for more diverse set', () {
      // "abcd" -> 4 distinct symbols, each 0.25 prob
      // log2(4) = 2 bits
      expect(ShannonEntropy.calculate('abcd'), closeTo(2.0, 0.0001));
    });

    test('is case sensitive', () {
      // "Aa" -> 2 distinct symbols
      expect(ShannonEntropy.calculate('Aa'), closeTo(1.0, 0.0001));
      // "aa" -> 1 distinct symbol
      expect(ShannonEntropy.calculate('aa'), 0.0);
    });

    test('calculates entropy for typical API key examples', () {
      // Low entropy string
      final low = ShannonEntropy.calculate('password123');

      // High entropy string (simulated API key)
      final high = ShannonEntropy.calculate('7Fz92xK1qM4bJ8vR');

      expect(high, greaterThan(low));
    });
  });
}
