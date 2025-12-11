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
      uid: "55bcb79a-d06e-4f41-b89e-f243763e64ab",
      name: "Prawn",
      image: "assets/shrimp-species/prawn.png",
      scientificName: "Panaeus Monodon",
    ),
    const SpeciesModel(
      id: "grey-shrimp",
      uid: "4d244dab-7fe8-4e8c-8a4a-9b6643842625",
      name: "Grey Shrimp",
      image: "assets/shrimp-species/grey-shrimp.png",
      scientificName: "Crevette Grise",
    ),
    const SpeciesModel(
      id: "pink-shrimp",
      uid: "06264f8b-70df-4903-854c-d7477315bda4",
      name: "Pink Shrimp",
      image: "assets/shrimp-species/pink-shrimp.png",
      scientificName: "Crevette Rose",
    ),
    const SpeciesModel(
      id: "tiger-shrimp",
      uid: "34b34061-f620-48d0-bcdb-45c207032011",
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
