import 'package:flutter_test/flutter_test.dart';
import 'package:siren_marketplace/core/data/api/models/auth_api_models.dart';

void main() {
  group('AccountApiModel', () {
    test('parses snake_case correctly', () {
      final json = {
        'id': '123',
        'first_name': 'John',
        'last_name': 'Doe',
        'total_reviews': 5,
        'username': 'johndoe',
      };
      final model = AccountApiModel.fromJson(json);
      expect(model.firstName, 'John');
      expect(model.lastName, 'Doe');
      expect(model.totalReviews, 5);
    });

    test('parses camelCase correctly', () {
      final json = {
        'id': '123',
        'firstName': 'Jane',
        'lastName': 'Smith',
        'totalReviews': 10,
        'username': 'janesmith',
      };
      final model = AccountApiModel.fromJson(json);
      expect(model.firstName, 'Jane');
      expect(model.lastName, 'Smith');
      expect(model.totalReviews, 10);
    });

    test('prefers snake_case over camelCase', () {
      final json = {
        'id': '123',
        'first_name': 'Snake',
        'firstName': 'Camel',
        'last_name': 'Case',
        'lastName': 'Case2',
        'username': 'user',
      };
      final model = AccountApiModel.fromJson(json);
      expect(model.firstName, 'Snake');
      expect(model.lastName, 'Case');
    });

    test('handles totalReviews camelCase', () {
      final json = {'id': '123', 'totalReviews': 42, 'username': 'user'};
      final model = AccountApiModel.fromJson(json);
      expect(model.totalReviews, 42);
    });
  });
}
