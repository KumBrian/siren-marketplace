import 'package:equatable/equatable.dart';

import '../enums/user_role.dart';
import '../value_objects/rating.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? phone;
  final Rating rating;
  final int reviewCount;
  final UserRole currentRole;

  const User({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.phone,
    required this.rating,
    required this.reviewCount,
    required this.currentRole,
  });

  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;
  bool get hasRatings => reviewCount > 0;
  bool get hasPhone => phone != null && phone!.isNotEmpty;

  String get displayRating => hasRatings
      ? '${rating.value.toStringAsFixed(1)} (${reviewCount})'
      : 'No reviews yet';

  User copyWith({
    String? name,
    String? avatarUrl,
    String? phone,
    Rating? rating,
    int? reviewCount,
    UserRole? currentRole,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
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
    phone,
    rating,
    reviewCount,
    currentRole,
  ];
}
