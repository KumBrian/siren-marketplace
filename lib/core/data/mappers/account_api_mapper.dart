import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/value_objects/rating.dart';
import '../api/models/auth_api_models.dart';

/// Mapper to convert between AccountApiModel and User domain entity
class AccountApiMapper {
  /// Convert API model to domain entity
  static User toDomain(AccountApiModel apiModel, {UserRole? defaultRole}) {
    // Construct name from first and last name, or fallback to username
    String displayName =
        '${apiModel.firstName ?? ''} ${apiModel.lastName ?? ''}'.trim();
    if (displayName.isEmpty) {
      displayName = apiModel.username ?? 'Unknown User';
    }

    return User(
      id: apiModel.id.toString(), // Convert dynamic ID to String
      name: displayName,
      avatarUrl: apiModel.avatar,
      rating: Rating.fromValue(apiModel.rating ?? 0.0),
      reviewCount: apiModel.totalReviews ?? 0,
      currentRole: _mapRoles(apiModel.roles, defaultRole: defaultRole),
    );
  }

  /// Convert domain entity to API model
  static AccountApiModel toApi(User user) {
    // Split name into first/last? Naive implementation for now.
    // User entity doesn't store email, so use empty for now.
    return AccountApiModel(
      id: user.id,
      firstName: user.name, // Just use full name as first name for now
      email: '',
      avatar: user.avatarUrl,
      rating: user.rating.value,
      roles: [_mapRoleToString(user.currentRole)],
    );
  }

  /// Map API roles list to UserRole enum
  static UserRole _mapRoles(List<String>? roles, {UserRole? defaultRole}) {
    if (roles == null || roles.isEmpty) {
      return defaultRole ?? UserRole.unknown;
    }

    final lowerRoles = roles.map((r) => r.toLowerCase()).toSet();

    if (lowerRoles.contains('fisher') || lowerRoles.contains('fisherman')) {
      return UserRole.fisher;
    }

    if (lowerRoles.contains('buyer')) {
      return UserRole.buyer;
    }

    return defaultRole ?? UserRole.unknown;
  }

  /// Map UserRole enum to API role string
  static String _mapRoleToString(UserRole role) {
    switch (role) {
      case UserRole.fisher:
        return 'fisher';
      case UserRole.buyer:
        return 'buyer';
      case UserRole.unknown:
        return 'unknown';
    }
  }
}
