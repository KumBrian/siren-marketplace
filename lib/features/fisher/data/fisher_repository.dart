import 'package:siren_marketplace/core/data/database/database_helper.dart';

import 'models/fisher.dart';

/// Repository responsible for retrieving [`Fisher`] domain data.
///
/// This layer abstracts the underlying data source.
/// Currently backed by the local SQLite database via [`DatabaseHelper`],
/// but intentionally structured so it can be swapped with a remote API
/// implementation without changing the consumer-facing contract.
///
/// When the backend API goes live, replace the DB interactions inside
/// this repository with HTTP clients or service layer calls.
/// The method signatures can remain stable, maintaining full upstream
/// compatibility.
class FisherRepository {
  /// Local database service used for querying Fisher data.
  final DatabaseHelper dbHelper;

  /// Creates an instance of [FisherRepository] with the provided
  /// local database helper.
  FisherRepository({required this.dbHelper});

  /// Retrieves a single [Fisher] by its unique [id].
  ///
  /// The method performs a direct user lookup from the local DB.
  /// If no matching record is found, an [Exception] is thrown.
  ///
  /// **Future API Migration Path**
  /// - Replace the DB lookup with an HTTP GET request:
  ///   `GET /fishers/{id}`
  /// - Maintain this return signature to avoid upstream refactoring.
  ///
  /// Throws:
  /// - [Exception] if the Fisher does not exist in local storage.
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
