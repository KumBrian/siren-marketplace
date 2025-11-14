import 'package:siren_marketplace/core/data/database/database_helper.dart';
import 'package:siren_marketplace/core/models/app_user.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:sqflite/sqflite.dart';

/// Repository responsible for managing user data.
///
/// This class abstracts all persistence operations related to `AppUser`,
/// currently backed by a local SQLite database through [DatabaseHelper].
/// The design anticipates future migration to remote API calls; when that
/// transition happens, the method signatures should remain stable, and the
/// internal data source can be swapped without affecting calling layers.
class UserRepository {
  /// Creates a new instance of [UserRepository] with an injected database helper.
  UserRepository({required this.dbHelper});

  /// Provides access to the underlying SQLite helper used for persistence.
  final DatabaseHelper dbHelper;

  /// Inserts or replaces a user record in the local database.
  ///
  /// In the future API-based implementation, this method should be updated
  /// to send a `POST` or `PUT` request to the remote backend while maintaining
  /// the same contract for higher layers.
  Future<void> insertUser(AppUser user) async {
    final db = await dbHelper.database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Calculates the new average rating and updates the user record.
  ///
  /// This method is crucial for ensuring user profiles reflect their current
  /// aggregated scores after a new review is submitted.
  Future<void> updateUserRating({
    required String userId,
    required double newRatingValue,
  }) async {
    // 1. Get the current user data
    final userMap = await getUserMapById(userId);
    if (userMap == null) return;

    final AppUser currentUser = AppUser.fromMap(userMap);

    // 2. Get the existing rating metrics
    final double currentTotalRating =
        currentUser.rating * currentUser.reviewCount;
    final int newReviewCount = currentUser.reviewCount + 1;

    // 3. Calculate the new total and average
    final double newTotalRating = currentTotalRating + newRatingValue;
    final double newAverageRating = newTotalRating / newReviewCount;

    // 4. Update the database using the specialized helper method
    await dbHelper.updateUserRatingMetrics(
      userId: userId,
      newAverageRating: newAverageRating,
      newReviewCount: newReviewCount,
    );
  }

  /// Retrieves all user entries as raw map objects.
  ///
  /// Used primarily during seeding operations to determine whether the local
  /// table already contains records. This can later map to a paginated
  /// `/users` list endpoint in an API-driven architecture.
  Future<List<Map<String, dynamic>>> getAllUserMaps() async {
    final db = await dbHelper.database;
    return await db.query('users');
  }

  /// Fetches the first user with the role `fisher`, returning the raw map.
  ///
  /// This logic assumes there is at most one active fisher of interest.
  /// When using a remote API later, this would likely map to a filtered
  /// query such as `/users?role=fisher&limit=1`.
  Future<Map<String, dynamic>?> getFirstFisherMap() async {
    final db = await dbHelper.database;
    final data = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: [Role.fisher.name],
      limit: 1,
    );

    if (data.isEmpty) return null;
    return data.first;
  }

  /// Fetches the first user with the role `buyer`, returning the raw map.
  ///
  /// Future API equivalent: `/users?role=buyer&limit=1`.
  Future<Map<String, dynamic>?> getFirstBuyerMap() async {
    final db = await dbHelper.database;
    final data = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: [Role.buyer.name],
      limit: 1,
    );

    if (data.isEmpty) return null;
    return data.first;
  }

  /// Retrieves a single user by their unique identifier, returning the raw map.
  ///
  /// This should align cleanly with a future API endpoint such as `/users/{id}`.
  Future<Map<String, dynamic>?> getUserMapById(String id) async {
    final db = await dbHelper.database;
    final data = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (data.isEmpty) return null;
    return data.first;
  }

  /// Retrieves all rating entries associated with a particular user.
  ///
  /// Delegates to [DatabaseHelper.getRatingsByUserId].
  /// In a future remote architecture, this becomes an endpoint like
  /// `/users/{id}/ratings`.
  Future<List<Map<String, dynamic>>> getRatingsReceivedByUserId(
    String userId,
  ) async {
    return await dbHelper.getRatingsByUserId(userId);
  }

  /// Updates a user's persisted information using the provided [AppUser] model.
  ///
  /// API equivalent would correspond to sending a `PUT` or `PATCH` request.
  Future<void> updateUser(AppUser user) async {
    final db = await dbHelper.database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  /// Deletes a user from the data source using their unique identifier.
  ///
  /// Remote equivalent maps cleanly to a `DELETE /users/{id}` endpoint.
  Future<void> deleteUser(String id) async {
    final db = await dbHelper.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }
}
