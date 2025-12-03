import 'package:siren_marketplace/core/domain/enums/user_role.dart';

class SeederData {
  // Dummy Avatars
  static final List<String> avatarUrls = List.generate(
    10,
    (index) => 'https://i.pravatar.cc/150?img=${index + 1}',
  );

  // Dummy Catch Images
  static final List<String> catchImageUrls = List.generate(
    10,
    (index) => 'https://picsum.photos/400/300?random=${500 + index}',
  );

  static const List<String> markets = [
    'Yopwe',
    'Douala Port',
    'Down Beach Limbe',
    'Kribi Hub',
    'Edea Market',
  ];

  static final List<Map<String, dynamic>> userMaps = [
    {
      'id': 'fisher_id_1',
      'name': 'Captain Jack',
      'avatar_url': avatarUrls[0],
      'rating': 4.8,
      'review_count': 124,
      'role': UserRole.fisher,
    },
    {
      'id': 'fisher_id_2',
      'name': 'Ocean Master',
      'avatar_url': avatarUrls[1],
      'rating': 4.5,
      'review_count': 90,
      'role': UserRole.fisher,
    },
    {
      'id': 'buyer_id_1',
      'name': 'Seafood Buyer Co',
      'avatar_url': avatarUrls[2],
      'rating': 4.9,
      'review_count': 210,
      'role': UserRole.buyer,
    },
    {
      'id': 'buyer_id_2',
      'name': 'Market Pro Supply',
      'avatar_url': avatarUrls[3],
      'rating': 4.7,
      'review_count': 150,
      'role': UserRole.buyer,
    },
  ];
}
