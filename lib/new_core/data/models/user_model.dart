class UserModel {
  final String id;
  final String name;
  final String? avatarUrl;
  final double rating;
  final int reviewCount;
  final String currentRole; // 'fisher' or 'buyer'

  const UserModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.rating,
    required this.reviewCount,
    required this.currentRole,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatar_url': avatarUrl,
    'rating': rating,
    'review_count': reviewCount,
    'role': currentRole,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    name: json['name'] as String,
    avatarUrl: json['avatar_url'] as String?,
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
    currentRole: json['role'] as String? ?? 'buyer',
  );

  // SQLite mapping (snake_case)
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'avatar_url': avatarUrl,
    'rating': rating,
    'review_count': reviewCount,
    'role': currentRole,
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
