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
