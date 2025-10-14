import 'package:siren_marketplace/core/data/database/database_helper.dart';

import 'models/fisher.dart';

class FisherRepository {
  final DatabaseHelper dbHelper = DatabaseHelper();

  Future<Fisher> getFisherById(String id) async {
    final userMap = await dbHelper.getUserMapById(id);
    if (userMap == null) {
      throw Exception("Fisher not found: $id");
    }
    return Fisher(
      id: userMap['id'] as String,
      name: userMap['name'] as String,
      avatarUrl: userMap['avatar_url'] as String? ?? '',
      rating: (userMap['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: userMap['review_count'] as int? ?? 0,
    );
  }
}
