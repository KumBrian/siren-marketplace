import 'package:flutter_test/flutter_test.dart';
import 'package:siren_marketplace/core/domain/value_objects/price.dart';

void main() {
  group('Price Value Object', () {
    group('Construction', () {
      test('creates price from amount', () {
        final price = Price.fromAmount(50000);

        expect(price.amount, 50000);
      });

      test('handles zero price', () {
        final price = Price.fromAmount(0);

        expect(price.amount, 0);
        expect(price.isZero, true);
      });

      test('throws on negative amount', () {
        expect(() => Price.fromAmount(-100), throwsA(isA<ArgumentError>()));
      });
    });

    group('Arithmetic Operations', () {
      test('addition works correctly', () {
        final p1 = Price.fromAmount(1000);
        final p2 = Price.fromAmount(500);
        final result = p1 + p2;

        expect(result.amount, 1500);
      });

      test('subtraction works correctly', () {
        final p1 = Price.fromAmount(1000);
        final p2 = Price.fromAmount(300);
        final result = p1 - p2;

        expect(result.amount, 700);
      });

      test('subtraction resulting in zero works', () {
        final p1 = Price.fromAmount(1000);
        final p2 = Price.fromAmount(1000);
        final result = p1 - p2;

        expect(result.amount, 0);
        expect(result.isZero, true);
      });

      test('subtraction throws when result would be negative', () {
        final p1 = Price.fromAmount(300);
        final p2 = Price.fromAmount(500);

        expect(() => p1 - p2, throwsA(isA<ArgumentError>()));
      });
    });

    group('Comparison Operations', () {
      test('greater than operator works', () {
        final p1 = Price.fromAmount(1000);
        final p2 = Price.fromAmount(500);

        expect(p1 > p2, true);
        expect(p2 > p1, false);
      });

      test('less than operator works', () {
        final p1 = Price.fromAmount(500);
        final p2 = Price.fromAmount(1000);

        expect(p1 < p2, true);
        expect(p2 < p1, false);
      });

      test('greater than or equal operator works', () {
        final p1 = Price.fromAmount(1000);
        final p2 = Price.fromAmount(1000);
        final p3 = Price.fromAmount(500);

        expect(p1 >= p2, true);
        expect(p1 >= p3, true);
        expect(p3 >= p1, false);
      });

      test('less than or equal operator works', () {
        final p1 = Price.fromAmount(500);
        final p2 = Price.fromAmount(500);
        final p3 = Price.fromAmount(1000);

        expect(p1 <= p2, true);
        expect(p1 <= p3, true);
        expect(p3 <= p1, false);
      });
    });

    group('Equality', () {
      test('two prices with same amount are equal', () {
        final p1 = Price.fromAmount(50000);
        final p2 = Price.fromAmount(50000);

        expect(p1, equals(p2));
        expect(p1.hashCode, equals(p2.hashCode));
      });

      test('two prices with different amounts are not equal', () {
        final p1 = Price.fromAmount(50000);
        final p2 = Price.fromAmount(60000);

        expect(p1, isNot(equals(p2)));
      });
    });

    group('Edge Cases', () {
      test('very large prices work correctly', () {
        final price = Price.fromAmount(1000000000);

        expect(price.amount, 1000000000);
      });

      test('isZero returns false for non-zero prices', () {
        final price = Price.fromAmount(1);

        expect(price.isZero, false);
      });
    });
  });
}
