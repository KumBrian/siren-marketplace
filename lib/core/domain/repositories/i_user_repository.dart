import '../entities/user.dart';
import '../enums/user_role.dart';
import '../value_objects/rating.dart';

abstract class IUserRepository {
  /// Fetch user by ID
  Future<User?> getById(String userId);

  /// Fetch multiple users by IDs
  Future<List<User>> getByIds(List<String> userIds);

  /// Update user's current role
  Future<void> updateRole(String userId, UserRole role);

  /// Update user's aggregate rating
  Future<void> updateRating({
    required String userId,
    required Rating rating,
    required int reviewCount,
  });

  /// Update user profile
  Future<void> update(User user);

  /// Check if user exists
  Future<bool> exists(String userId);

  /// Create a new user
  Future<void> create(User user);

  /// Get the first user with role fisher (for demo/dev purposes)
  Future<User?> getFirstFisher();

  /// Get the first user with role buyer (for demo/dev purposes)
  Future<User?> getFirstBuyer();

  /// Save user to local cache only (no API call)
  Future<void> saveLocal(User user);
}
