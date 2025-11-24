import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/value_objects/rating.dart';
import '../models/user_model.dart';

class UserMapper {
  /// Convert domain entity to data model
  static UserModel toModel(User entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      avatarUrl: entity.avatarUrl,
      rating: entity.rating.value,
      reviewCount: entity.reviewCount,
      currentRole: entity.currentRole.name,
    );
  }

  /// Convert data model to domain entity
  static User toEntity(UserModel model) {
    return User(
      id: model.id,
      name: model.name,
      avatarUrl: model.avatarUrl,
      rating: Rating.fromValue(model.rating),
      reviewCount: model.reviewCount,
      currentRole: _parseRole(model.currentRole),
    );
  }

  static UserRole _parseRole(String role) {
    return UserRole.values.firstWhere(
      (r) => r.name == role,
      orElse: () => UserRole.buyer,
    );
  }
}
