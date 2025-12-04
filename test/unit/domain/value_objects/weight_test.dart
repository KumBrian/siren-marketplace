import 'package:flutter_test/flutter_test.dart';
import 'package:siren_marketplace/core/domain/value_objects/weight.dart';

void main() {
  group('Weight Value Object', () {
    group('Construction', () {
      test('creates weight from grams', () {
        final weight = Weight.fromGrams(1000);

        expect(weight.grams, 1000);
        expect(weight.kilograms, 1.0);
      });

      test('creates weight from kilograms', () {
        final weight = Weight.fromKg(2.5);

        expect(weight.kilograms, 2.5);
        expect(weight.grams, 2500);
      });

      test('handles zero weight', () {
        final weight = Weight.fromGrams(0);

        expect(weight.grams, 0);
        expect(weight.kilograms, 0.0);
        expect(weight.isZero, true);
      });

      test('handles fractional kilograms correctly', () {
        final weight = Weight.fromKg(1.5);

        expect(weight.grams, 1500);
        expect(weight.kilograms, 1.5);
      });
    });

    group('Arithmetic Operations', () {
      test('addition works correctly', () {
        final w1 = Weight.fromGrams(500);
        final w2 = Weight.fromGrams(300);
        final result = w1 + w2;

        expect(result.grams, 800);
        expect(result.kilograms, 0.8);
      });

      test('subtraction works correctly', () {
        final w1 = Weight.fromGrams(500);
        final w2 = Weight.fromGrams(300);
        final result = w1 - w2;

        expect(result.grams, 200);
        expect(result.kilograms, 0.2);
      });

      test('subtraction resulting in zero works', () {
        final w1 = Weight.fromGrams(500);
        final w2 = Weight.fromGrams(500);
        final result = w1 - w2;

        expect(result.grams, 0);
        expect(result.isZero, true);
      });

      test('subtraction throws when result would be negative', () {
        final w1 = Weight.fromGrams(300);
        final w2 = Weight.fromGrams(500);

        expect(() => w1 - w2, throwsA(isA<ArgumentError>()));
      });
    });

    group('Comparison Operations', () {
      test('greater than operator works', () {
        final w1 = Weight.fromGrams(500);
        final w2 = Weight.fromGrams(300);

        expect(w1 > w2, true);
        expect(w2 > w1, false);
      });

      test('less than operator works', () {
        final w1 = Weight.fromGrams(300);
        final w2 = Weight.fromGrams(500);

        expect(w1 < w2, true);
        expect(w2 < w1, false);
      });

      test('greater than or equal operator works', () {
        final w1 = Weight.fromGrams(500);
        final w2 = Weight.fromGrams(500);
        final w3 = Weight.fromGrams(300);

        expect(w1 >= w2, true);
        expect(w1 >= w3, true);
        expect(w3 >= w1, false);
      });

      test('less than or equal operator works', () {
        final w1 = Weight.fromGrams(300);
        final w2 = Weight.fromGrams(300);
        final w3 = Weight.fromGrams(500);

        expect(w1 <= w2, true);
        expect(w1 <= w3, true);
        expect(w3 <= w1, false);
      });
    });

    group('Equality', () {
      test('two weights with same grams are equal', () {
        final w1 = Weight.fromGrams(1000);
        final w2 = Weight.fromGrams(1000);

        expect(w1, equals(w2));
        expect(w1.hashCode, equals(w2.hashCode));
      });

      test('two weights with different grams are not equal', () {
        final w1 = Weight.fromGrams(1000);
        final w2 = Weight.fromGrams(2000);

        expect(w1, isNot(equals(w2)));
      });

      test('weight from grams equals weight from kg with same value', () {
        final w1 = Weight.fromGrams(1000);
        final w2 = Weight.fromKg(1.0);

        expect(w1, equals(w2));
      });
    });

    group('Edge Cases', () {
      test('very large weights work correctly', () {
        final weight = Weight.fromKg(1000.0);

        expect(weight.kilograms, 1000.0);
        expect(weight.grams, 1000000);
      });

      test('very small weights work correctly', () {
        final weight = Weight.fromGrams(1);

        expect(weight.grams, 1);
        expect(weight.kilograms, 0.001);
      });

      test('isZero returns false for non-zero weights', () {
        final weight = Weight.fromGrams(1);

        expect(weight.isZero, false);
      });
    });
  });
}
