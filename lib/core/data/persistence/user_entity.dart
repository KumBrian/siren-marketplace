import '../../domain/models/user.dart';

class UserEntity {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final String role;
  final double rating;
  final int reviewCount;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.role,
    required this.rating,
    required this.reviewCount,
  });

  factory UserEntity.fromMap(Map<String, dynamic> map) => UserEntity(
    id: map['id'] as String,
    name: map['name'] as String,
    email: map['email'] as String? ?? '',
    phone: map['phone'] as String? ?? '',
    avatarUrl: map['avatar_url'] as String? ?? '',
    role: map['role'] as String? ?? 'buyer',
    rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
    reviewCount: map['review_count'] as int? ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'avatar_url': avatarUrl,
    'role': role,
    'rating': rating,
    'review_count': reviewCount,
  };

  User toDomain() => User(
    id: id,
    name: name,
    email: email,
    phone: phone,
    avatarUrl: avatarUrl,
    role: role,
    rating: rating,
    reviewCount: reviewCount,
  );

  static UserEntity fromDomain(User u) => UserEntity(
    id: u.id,
    name: u.name,
    email: u.email,
    phone: u.phone,
    avatarUrl: u.avatarUrl,
    role: u.role,
    rating: u.rating,
    reviewCount: u.reviewCount,
  );
}
