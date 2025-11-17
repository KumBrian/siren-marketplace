class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final String role; // consider using a Role enum at domain layer
  final double rating;
  final int reviewCount;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.role,
    required this.rating,
    required this.reviewCount,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? role,
    double? rating,
    int? reviewCount,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    role: role ?? this.role,
    rating: rating ?? this.rating,
    reviewCount: reviewCount ?? this.reviewCount,
  );
}
