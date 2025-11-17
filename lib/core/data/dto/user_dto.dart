import '../../domain/models/user.dart';

class UserDTO {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final String role;
  final double rating;
  final int reviewCount;

  UserDTO({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.role,
    required this.rating,
    required this.reviewCount,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) => UserDTO(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String? ?? '',
    phone: json['phone'] as String? ?? '',
    avatarUrl: json['avatar_url'] as String? ?? '',
    role: json['role'] as String? ?? 'buyer',
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    reviewCount: json['review_count'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
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

  static UserDTO fromDomain(User u) => UserDTO(
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
