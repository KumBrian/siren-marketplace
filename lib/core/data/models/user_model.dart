import 'package:siren_marketplace/core/domain/entities/user.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/value_objects/rating.dart';

class UserModel extends User {
  // Primitives for JSON serialization (not stored as fields to avoid conflict)
  // final double rating; // specific to model logic if needed, but we use super.rating
  // final String currentRole; // use super.currentRole

  UserModel({
    required super.id,
    required super.name,
    String? avatarUrl,
    required double rating,
    required int reviewCount,
    required String currentRole,
  }) : super(
         avatarUrl: avatarUrl,
         rating: Rating.fromValue(rating),
         reviewCount: reviewCount,
         currentRole: UserRole.values.firstWhere(
           (e) => e.name == currentRole,
           orElse: () => UserRole.buyer,
         ),
       );

  // Custom factory to handle the logic cleanly
  factory UserModel.create({
    required String id,
    required String name,
    String? avatarUrl,
    required double rating,
    required int reviewCount,
    required String currentRole,
  }) {
    // Helper to map role
    final roleEnum = UserRole.values.firstWhere(
      (e) => e.name == currentRole,
      orElse: () => UserRole.buyer,
    );

    return UserModel._(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      rating: Rating.fromValue(rating),
      reviewCount: reviewCount,
      currentRole: roleEnum,
    );
  }

  // Private constructor passing directly to super
  const UserModel._({
    required String id,
    required String name,
    String? avatarUrl,
    required Rating rating,
    required int reviewCount,
    required UserRole currentRole,
  }) : super(
         id: id,
         name: name,
         avatarUrl: avatarUrl,
         rating: rating,
         reviewCount: reviewCount,
         currentRole: currentRole,
       );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar_url': avatarUrl,
    'rating': rating.value,
    'review_count': reviewCount,
    'role': currentRole.name,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle id which can be int or string
    final id = json['id'];
    final idString = id != null ? id.toString() : '';

    // Build name from firstName/lastName if 'name' field is missing
    final name =
        json['name'] as String? ??
        '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim();

    return UserModel(
      id: idString,
      name: name.isNotEmpty ? name : 'Unknown User',
      avatarUrl:
          json['avatar_url'] as String? ?? json['profilePictureUrl'] as String?,
      rating:
          (json['rating'] as num?)?.toDouble() ??
          (json['averageRating'] as num?)?.toDouble() ??
          0.0,
      reviewCount:
          (json['review_count'] as num?)?.toInt() ??
          (json['totalReviews'] as num?)?.toInt() ??
          0,
      currentRole: json['role'] as String? ?? 'buyer',
    );
  }

  // SQLite mapping (snake_case)
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'avatar_url': avatarUrl,
    'rating': rating.value,
    'review_count': reviewCount,
    'role': currentRole.name,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'] as String,
    name: map['name'] as String,
    avatarUrl: map['avatar_url'] as String?,
    rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
    reviewCount: (map['review_count'] as num?)?.toInt() ?? 0,
    currentRole: map['role'] as String? ?? 'buyer',
  );
}
