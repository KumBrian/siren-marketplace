import 'package:flutter_test/flutter_test.dart';
import 'package:siren_marketplace/core/domain/value_objects/rating.dart';

void main() {
  group('Rating Value Object', () {
    group('Construction', () {
      test('creates rating from valid value', () {
        final rating = Rating.fromValue(4.5);

        expect(rating.value, 4.5);
      });

      test('creates minimum rating', () {
        final rating = Rating.fromValue(0.0);

        expect(rating.value, 0.0);
      });

      test('creates maximum rating', () {
        final rating = Rating.fromValue(5.0);

        expect(rating.value, 5.0);
      });

      test('throws on rating below minimum', () {
        expect(() => Rating.fromValue(-0.1), throwsA(isA<ArgumentError>()));
      });

      test('throws on rating above maximum', () {
        expect(() => Rating.fromValue(5.1), throwsA(isA<ArgumentError>()));
      });
    });

    group('Equality', () {
      test('two ratings with same value are equal', () {
        final r1 = Rating.fromValue(4.5);
        final r2 = Rating.fromValue(4.5);

        expect(r1, equals(r2));
        expect(r1.hashCode, equals(r2.hashCode));
      });

      test('two ratings with different values are not equal', () {
        final r1 = Rating.fromValue(4.5);
        final r2 = Rating.fromValue(3.5);

        expect(r1, isNot(equals(r2)));
      });
    });

    group('Edge Cases', () {
      test('handles fractional ratings correctly', () {
        final rating = Rating.fromValue(4.7);

        expect(rating.value, 4.7);
      });

      test('handles whole number ratings', () {
        final rating = Rating.fromValue(4.0);

        expect(rating.value, 4.0);
      });
    });
  });
}
