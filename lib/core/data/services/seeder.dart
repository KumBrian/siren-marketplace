import 'package:siren_marketplace/core/data/services/seeders/catch_seeder.dart';
import 'package:siren_marketplace/core/data/services/seeders/message_seeder.dart';
import 'package:siren_marketplace/core/data/services/seeders/offer_seeder.dart';
import 'package:siren_marketplace/core/data/services/seeders/order_seeder.dart';
import 'package:siren_marketplace/core/data/services/seeders/review_seeder.dart';
import 'package:siren_marketplace/core/data/services/seeders/user_seeder.dart';

import '../database/database_helper.dart';

class Seeder {
  final UserSeeder _userSeeder = UserSeeder();
  final CatchSeeder _catchSeeder = CatchSeeder();
  final OfferSeeder _offerSeeder = OfferSeeder();
  final OrderSeeder _orderSeeder = OrderSeeder();
  final ReviewSeeder _reviewSeeder = ReviewSeeder();
  late final MessageSeeder _messageSeeder;

  Seeder() {
    _messageSeeder = MessageSeeder(dbHelper: DatabaseHelper());
  }

  Future<void> seedAll() async {
    print('Starting database seeding...');

    await _userSeeder.seed();
    final catches = await _catchSeeder.seed();
    final _ = await _offerSeeder.seed(catches);
    final orders = await _orderSeeder.seed();
    await _reviewSeeder.seed(orders);
    await _messageSeeder.seed(orders);

    print('Database seeding complete.');
  }
}
