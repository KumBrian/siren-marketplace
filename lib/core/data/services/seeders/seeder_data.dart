import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import '../../models/species_model.dart';

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

  static final List<SpeciesModel> speciesList = [
    const SpeciesModel(
      id: "prawn",
      name: "Prawn",
      image: "assets/shrimp-species/prawn.png",
      scientificName: "Panaeus Monodon",
    ),
    const SpeciesModel(
      id: "grey-shrimp",
      name: "Grey Shrimp",
      image: "assets/shrimp-species/grey-shrimp.png",
      scientificName: "Crevette Grise",
    ),
    const SpeciesModel(
      id: "pink-shrimp",
      name: "Pink Shrimp",
      image: "assets/shrimp-species/pink-shrimp.png",
      scientificName: "Crevette Rose",
    ),
    const SpeciesModel(
      id: "tiger-shrimp",
      name: "Tiger Shrimp",
      image: "assets/shrimp-species/tiger-shrimp.png",
      scientificName: "Crevette Tiger",
    ),
  ];

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
      'rating': 0.0,
      'review_count': 0,
      'role': UserRole.fisher,
    },
    {
      'id': 'fisher_id_2',
      'name': 'Ocean Master',
      'avatar_url': avatarUrls[1],
      'rating': 0.0,
      'review_count': 0,
      'role': UserRole.fisher,
    },
    {
      'id': 'buyer_id_1',
      'name': 'Seafood Buyer Co',
      'avatar_url': avatarUrls[2],
      'rating': 0.0,
      'review_count': 0,
      'role': UserRole.buyer,
    },
    {
      'id': 'buyer_id_2',
      'name': 'Market Pro Supply',
      'avatar_url': avatarUrls[3],
      'rating': 0.0,
      'review_count': 0,
      'role': UserRole.buyer,
    },
  ];
}
