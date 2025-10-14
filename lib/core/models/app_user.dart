import 'package:equatable/equatable.dart';

import '../types/converters.dart' show roleFromString;
import '../types/enum.dart' show Role;

class AppUser extends Equatable {
  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final int reviewCount;
  final Role role;

  const AppUser({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.reviewCount,
    required this.role,
  });

  @override
  List<Object> get props => [id, name, avatarUrl, rating, reviewCount, role];

  // Convert to Map for DB insertion (used by Fisher/Buyer toMap)
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'avatar_url': avatarUrl,
    'rating': rating,
    'review_count': reviewCount,
    'role': role.name,
  };

  // Create from Map (DB query)
  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
    id: m['id'] as String,
    name: m['name'] as String,
    avatarUrl: m['avatar_url'] as String? ?? '',
    rating: (m['rating'] as num?)?.toDouble() ?? 0.0,
    reviewCount: (m['review_count'] as int?) ?? 0,
    role: roleFromString(m['role'] as String? ?? 'unknown'),
  );

  // Placeholder for when a full object is needed but only ID/Role is known
  factory AppUser.empty() => const AppUser(
    id: '',
    name: 'Unknown',
    avatarUrl: '',
    rating: 0,
    reviewCount: 0,
    role: Role.unknown,
  );
}
