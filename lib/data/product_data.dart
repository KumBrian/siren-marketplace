import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';
import 'package:siren_marketplace/data/seller_data.dart';

// 10 Products
final List<Product> sampleProducts = [
  Product(
    id: "p1",
    name: "Premium Tiger Shrimps",
    totalPrice: 850000,
    species: kSpecies.firstWhere((s) => s.id == "tiger-shrimp"),
    averageSize: 12.5,
    // cm (double)
    availableWeight: 85.0,
    pricePerKg: 10000.0,
    datePosted: "2025-09-25T08:30:00Z",
    seller: sampleSellers[0],
    images: [
      "https://picsum.photos/seed/tiger1/800/600",
      "https://picsum.photos/seed/tiger2/800/600",
    ],
  ),

  Product(
    id: "p2",
    name: "Pink Shrimp Delight",
    totalPrice: 520000,
    species: kSpecies.firstWhere((s) => s.id == "pink-shrimp"),
    averageSize: 9.0,
    availableWeight: 65.0,
    pricePerKg: 8000.0,
    datePosted: "2025-09-27T10:00:00Z",
    seller: sampleSellers[1],
    images: [
      "https://picsum.photos/seed/pink1/800/600",
      "https://picsum.photos/seed/pink2/800/600",
    ],
  ),

  Product(
    id: "p3",
    name: "Grey Shrimp Pack",
    totalPrice: 420000,
    species: kSpecies.firstWhere((s) => s.id == "grey-shrimp"),
    averageSize: 8.0,
    availableWeight: 60.0,
    pricePerKg: 7000.0,
    datePosted: "2025-09-28T12:15:00Z",
    seller: sampleSellers[2],
    images: [
      "https://picsum.photos/seed/grey1/800/600",
      "https://picsum.photos/seed/grey2/800/600",
    ],
  ),

  Product(
    id: "p4",
    name: "Live Small Prawns",
    totalPrice: 300000,
    species: kSpecies.firstWhere((s) => s.id == "small-prawn"),
    averageSize: "small",
    // prawn -> string
    availableWeight: 50.0,
    pricePerKg: 6000.0,
    datePosted: "2025-09-29T15:00:00Z",
    seller: sampleSellers[3],
    images: [
      "https://picsum.photos/seed/prawn1/800/600",
      "https://picsum.photos/seed/prawn2/800/600",
    ],
  ),

  Product(
    id: "p5",
    name: "Large Freshwater Prawns",
    totalPrice: 950000,
    species: kSpecies.firstWhere((s) => s.id == "large-prawn"),
    averageSize: "large",
    availableWeight: 95.0,
    pricePerKg: 10000.0,
    datePosted: "2025-09-30T09:45:00Z",
    seller: sampleSellers[0],
    images: [
      "https://picsum.photos/seed/prawnLarge1/800/600",
      "https://picsum.photos/seed/prawnLarge2/800/600",
    ],
  ),

  Product(
    id: "p6",
    name: "Shrimp Combo Pack",
    totalPrice: 624000,
    species: kSpecies.firstWhere((s) => s.id == "pink-shrimp"),
    averageSize: 9.5,
    availableWeight: 78.0,
    pricePerKg: 8000.0,
    datePosted: "2025-10-01T11:20:00Z",
    seller: sampleSellers[1],
    images: [
      "https://picsum.photos/seed/combo1/800/600",
      "https://picsum.photos/seed/combo2/800/600",
    ],
  ),

  Product(
    id: "p7",
    name: "Tiger Shrimp King Size",
    totalPrice: 1100000,
    species: kSpecies.firstWhere((s) => s.id == "tiger-shrimp"),
    averageSize: 16.0,
    availableWeight: 110.0,
    pricePerKg: 10000.0,
    datePosted: "2025-10-02T08:00:00Z",
    seller: sampleSellers[2],
    images: [
      "https://picsum.photos/seed/tigerX1/800/600",
      "https://picsum.photos/seed/tigerX2/800/600",
    ],
  ),

  Product(
    id: "p8",
    name: "Frozen Grey Shrimps",
    totalPrice: 480000,
    species: kSpecies.firstWhere((s) => s.id == "grey-shrimp"),
    averageSize: 7.0,
    availableWeight: 80.0,
    pricePerKg: 6000.0,
    datePosted: "2025-10-03T13:30:00Z",
    seller: sampleSellers[3],
    images: [
      "https://picsum.photos/seed/frozen1/800/600",
      "https://picsum.photos/seed/frozen2/800/600",
    ],
  ),

  Product(
    id: "p9",
    name: "Deluxe Prawn Box",
    totalPrice: 720000,
    species: kSpecies.firstWhere((s) => s.id == "large-prawn"),
    averageSize: "medium",
    // prawn -> string (varied intentionally)
    availableWeight: 90.0,
    pricePerKg: 8000.0,
    datePosted: "2025-10-04T09:10:00Z",
    seller: sampleSellers[0],
    images: [
      "https://picsum.photos/seed/deluxe1/800/600",
      "https://picsum.photos/seed/deluxe2/800/600",
    ],
  ),

  Product(
    id: "p10",
    name: "Budget Shrimp Box",
    totalPrice: 300000,
    species: kSpecies.firstWhere((s) => s.id == "pink-shrimp"),
    averageSize: 6.5,
    availableWeight: 50.0,
    pricePerKg: 6000.0,
    datePosted: "2025-10-05T14:20:00Z",
    seller: sampleSellers[4],
    images: [
      "https://picsum.photos/seed/budget1/800/600",
      "https://picsum.photos/seed/budget2/800/600",
    ],
  ),
];
