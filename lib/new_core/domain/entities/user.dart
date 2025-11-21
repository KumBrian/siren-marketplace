import 'package:equatable/equatable.dart';

import '../enums/user_role.dart';
import '../value_objects/rating.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final Rating rating;
  final int reviewCount;
  final UserRole currentRole;

  const User({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.rating,
    required this.reviewCount,
    required this.currentRole,
  });

  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;
  bool get hasRatings => reviewCount > 0;

  String get displayRating => hasRatings
      ? '${rating.value.toStringAsFixed(1)} (${reviewCount})'
      : 'No reviews yet';

  User copyWith({
    String? name,
    String? avatarUrl,
    Rating? rating,
    int? reviewCount,
    UserRole? currentRole,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      currentRole: currentRole ?? this.currentRole,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    avatarUrl,
    rating,
    reviewCount,
    currentRole,
  ];
}
