import 'package:flutter_test/flutter_test.dart';
import 'package:siren_marketplace/core/domain/value_objects/offer_terms.dart';
import 'package:siren_marketplace/core/domain/value_objects/price.dart';
import 'package:siren_marketplace/core/domain/value_objects/weight.dart';

void main() {
  group('OfferTerms Value Object', () {
    group('Construction', () {
      test('creates offer terms with weight and price', () {
        final weight = Weight.fromKg(5.0);
        final price = Price.fromAmount(25000);

        final terms = OfferTerms.create(weight: weight, totalPrice: price);

        expect(terms.weight, equals(weight));
        expect(terms.totalPrice, equals(price));
      });

      test('calculates price per kg correctly', () {
        final weight = Weight.fromKg(5.0);
        final price = Price.fromAmount(25000);

        final terms = OfferTerms.create(weight: weight, totalPrice: price);

        // 25000 / 5 = 5000 per kg
        expect(terms.pricePerKg.amountPerKg, 5000);
      });

      test('handles fractional weight correctly', () {
        final weight = Weight.fromKg(2.5);
        final price = Price.fromAmount(12500);

        final terms = OfferTerms.create(weight: weight, totalPrice: price);

        // 12500 / 2.5 = 5000 per kg
        expect(terms.pricePerKg.amountPerKg, 5000);
      });

      test('throws on zero weight', () {
        final weight = Weight.fromGrams(0);
        final price = Price.fromAmount(25000);

        expect(
          () => OfferTerms.create(weight: weight, totalPrice: price),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Equality', () {
      test('two terms with same values are equal', () {
        final weight = Weight.fromKg(5.0);
        final price = Price.fromAmount(25000);

        final terms1 = OfferTerms.create(weight: weight, totalPrice: price);
        final terms2 = OfferTerms.create(weight: weight, totalPrice: price);

        expect(terms1, equals(terms2));
        expect(terms1.hashCode, equals(terms2.hashCode));
      });

      test('two terms with different weights are not equal', () {
        final terms1 = OfferTerms.create(
          weight: Weight.fromKg(5.0),
          totalPrice: Price.fromAmount(25000),
        );
        final terms2 = OfferTerms.create(
          weight: Weight.fromKg(6.0),
          totalPrice: Price.fromAmount(25000),
        );

        expect(terms1, isNot(equals(terms2)));
      });

      test('two terms with different prices are not equal', () {
        final terms1 = OfferTerms.create(
          weight: Weight.fromKg(5.0),
          totalPrice: Price.fromAmount(25000),
        );
        final terms2 = OfferTerms.create(
          weight: Weight.fromKg(5.0),
          totalPrice: Price.fromAmount(30000),
        );

        expect(terms1, isNot(equals(terms2)));
      });
    });

    group('Price Calculations', () {
      test('price per kg is consistent', () {
        final terms = OfferTerms.create(
          weight: Weight.fromKg(10.0),
          totalPrice: Price.fromAmount(100000),
        );

        expect(terms.pricePerKg.amountPerKg, 10000);
      });

      test('handles large weights', () {
        final terms = OfferTerms.create(
          weight: Weight.fromKg(100.0),
          totalPrice: Price.fromAmount(500000),
        );

        expect(terms.pricePerKg.amountPerKg, 5000);
      });

      test('handles small weights', () {
        final terms = OfferTerms.create(
          weight: Weight.fromKg(0.5),
          totalPrice: Price.fromAmount(2500),
        );

        expect(terms.pricePerKg.amountPerKg, 5000);
      });
    });
  });
}
