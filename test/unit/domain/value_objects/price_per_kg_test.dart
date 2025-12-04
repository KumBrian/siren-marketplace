import 'package:flutter_test/flutter_test.dart';
import 'package:siren_marketplace/core/domain/value_objects/price_per_kg.dart';

void main() {
  group('PricePerKg Value Object', () {
    group('Construction', () {
      test('creates price per kg from amount', () {
        final pricePerKg = PricePerKg.fromAmount(5000);

        expect(pricePerKg.amountPerKg, 5000);
      });

      test('handles zero price', () {
        final pricePerKg = PricePerKg.fromAmount(0);

        expect(pricePerKg.amountPerKg, 0);
      });

      test('throws on negative amount', () {
        expect(
          () => PricePerKg.fromAmount(-100),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Equality', () {
      test('two prices with same amount are equal', () {
        final p1 = PricePerKg.fromAmount(5000);
        final p2 = PricePerKg.fromAmount(5000);

        expect(p1, equals(p2));
        expect(p1.hashCode, equals(p2.hashCode));
      });

      test('two prices with different amounts are not equal', () {
        final p1 = PricePerKg.fromAmount(5000);
        final p2 = PricePerKg.fromAmount(6000);

        expect(p1, isNot(equals(p2)));
      });
    });

    group('Edge Cases', () {
      test('very large prices work correctly', () {
        final pricePerKg = PricePerKg.fromAmount(1000000);

        expect(pricePerKg.amountPerKg, 1000000);
      });

      test('small prices work correctly', () {
        final pricePerKg = PricePerKg.fromAmount(100);

        expect(pricePerKg.amountPerKg, 100);
      });
    });
  });
}
