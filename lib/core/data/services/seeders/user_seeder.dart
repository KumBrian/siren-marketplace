import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/user.dart';
import 'package:siren_marketplace/core/domain/repositories/i_user_repository.dart';
import 'package:siren_marketplace/core/domain/value_objects/rating.dart';
import 'seeder_data.dart';

class UserSeeder {
  Future<void> seed() async {
    final repository = sl<IUserRepository>();
    // We can check if users exist by checking one of them
    final exists = await repository.exists('fisher_id_1');

    if (!exists) {
      for (final map in SeederData.userMaps) {
        final user = User(
          id: map['id'],
          name: map['name'],
          avatarUrl: map['avatar_url'],
          rating: Rating.fromValue(map['rating']),
          reviewCount: map['review_count'],
          currentRole: map['role'],
        );
        await repository.create(user);
      }
      print('Users seeded (simulated).');
    } else {
      print('Users exist. Skipping.');
    }
  }
}
