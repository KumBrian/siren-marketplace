import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum Role { fisher, buyer, unknown }

class Catch {
  final String name;
  final String datePosted;
  final String catchId;
  final List<String> images;
  final String size;
  final double initialWeight;
  final double availableWeight;
  final double pricePerKg;
  final double total;
  final List<FisherOffer> offers;
  final List<ConversationPreview> messages;
  final Species species;

  const Catch({
    required this.name,
    required this.datePosted,
    required this.catchId,
    required this.images,
    required this.size,
    required this.initialWeight,
    required this.availableWeight,
    required this.pricePerKg,
    required this.total,
    required this.offers,
    required this.messages,
    required this.species,
  });

  /// Safe double parser
  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  factory Catch.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Catch.empty;

    return Catch(
      name: json['name']?.toString() ?? "",
      datePosted: json['date_posted']?.toString() ?? "",
      catchId: json['catch_id']?.toString() ?? "",
      images: (json['images'] is List)
          ? List<String>.from(
              (json['images'] as List).map((e) => e?.toString() ?? ""),
            )
          : [],
      size: json['size']?.toString() ?? "",
      initialWeight: _toDouble(json['initial_weight']),
      availableWeight: _toDouble(json['available_weight']),
      pricePerKg: _toDouble(json['price_per_kg']),
      total: _toDouble(json['total']),
      offers: (json['offers'] is List)
          ? List<FisherOffer>.from(
              (json['offers'] as List).map((e) => FisherOffer.fromJson(e)),
            )
          : [],
      messages: (json['messages'] is List)
          ? List<ConversationPreview>.from(
              (json['messages'] as List).map(
                (e) => ConversationPreview.fromJson(e),
              ),
            )
          : [],
      species: Species.fromJson(json['species']),
    );
  }

  static const empty = Catch(
    name: "",
    datePosted: "",
    catchId: "",
    images: [],
    size: "",
    initialWeight: 0,
    availableWeight: 0,
    pricePerKg: 0,
    total: 0,
    offers: [],
    messages: [],
    species: Species(id: "", name: ""),
  );

  bool get isEmpty => identical(this, Catch.empty);

  bool get isNotEmpty => !isEmpty;
}

extension CatchExtensions on Catch {
  /// Returns the number of days left until expiry (7 days after posting).
  int get daysLeft {
    try {
      final postedDate = DateTime.parse(datePosted);
      final expiryDate = postedDate.add(const Duration(days: 7));
      final now = DateTime.now();

      final diff = expiryDate.difference(now).inDays;

      return diff > 0 ? diff : 0; // never negative
    } catch (_) {
      return 0; // fallback if date parsing fails
    }
  }

  /// Returns a display string
  String get daysLeftLabel {
    final left = daysLeft;
    if (left == 0) return "Expired";
    if (left == 1) return "1 day left";
    return "$left days left";
  }
}

extension DateFormatting on String {
  /// Format the string as "Apr 15, 2025 - 6:30"
  String toFormattedDate() {
    try {
      final date = DateTime.parse(this);
      return DateFormat("MMM d, yyyy - H:mm").format(date);
    } catch (_) {
      return this; // fallback to raw string if parsing fails
    }
  }
}

enum OfferStatus { pending, accepted, rejected, completed }

OfferStatus offerStatusFromString(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return OfferStatus.pending;
    case 'accepted':
      return OfferStatus.accepted;
    case 'rejected':
      return OfferStatus.rejected;
    case 'completed':
      return OfferStatus.completed;
    default:
      throw Exception('Unknown offer status: $status');
  }
}

String offerStatusToString(OfferStatus status) {
  return status.name; // Dart 2.15+ enum name
}

class FisherOffer {
  final String userId;
  final String name;
  final String clientAvatar;
  final String dateCreated;
  final String offerId;
  final OfferStatus status;
  final double pricePerKg;
  final double price;
  final double weight;
  final double fisherRating;
  final FisherOffer? previousCounterOffer;

  const FisherOffer({
    required this.userId,
    required this.name,
    required this.dateCreated,
    required this.offerId,
    required this.clientAvatar,
    required this.status,
    required this.pricePerKg,
    required this.price,
    required this.weight,
    required this.fisherRating,
    this.previousCounterOffer,
  });

  factory FisherOffer.fromJson(Map<String, dynamic> json) {
    return FisherOffer(
      userId: json['user_id'] as String,
      name: json['name'] as String,
      clientAvatar: json['client_avatar'] as String,
      dateCreated: json['date_created'] as String,
      offerId: json['offer_id'] as String,
      status: offerStatusFromString(json['status'] as String),
      pricePerKg: (json['price_per_kg'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      fisherRating: (json['rating'] as num).toDouble(),
      previousCounterOffer: json['previous_counter_offer'] != null
          ? FisherOffer.fromJson(
              json['previous_counter_offer'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'client_avatar': clientAvatar,
      'date_created': dateCreated,
      'offer_id': offerId,
      'status': offerStatusToString(status),
      'price_per_kg': pricePerKg,
      'price': price,
      'weight': weight,
      'rating': fisherRating,
      'previous_counter_offer': previousCounterOffer?.toJson(),
    };
  }
}

class BuyerOffer {
  final String offerId;
  final String fisherId;
  final String name;
  final String clientAvatar;
  final String dateCreated;
  final OfferStatus status;
  final double pricePerKg;
  final double price;
  final double weight;
  final double fisherRating;
  final int fisherReviewCount;
  final String catchName;
  final List<String> catchImages;
  final BuyerOffer? previousCounterOffer;

  const BuyerOffer({
    required this.offerId,
    required this.fisherId,
    required this.name,
    required this.clientAvatar,
    required this.dateCreated,
    required this.status,
    required this.pricePerKg,
    required this.price,
    required this.weight,
    required this.fisherRating,
    required this.fisherReviewCount,
    required this.catchName,
    required this.catchImages,
    this.previousCounterOffer,
  });
}

extension StringExtensions on String {
  /// Capitalizes the first letter of the string.
  /// If the string is empty, returns an empty string.
  String capitalize() {
    if (isEmpty) return '';
    return this[0].toUpperCase() + substring(1);
  }

  /// Capitalizes the first letter of each word in the string.
  String capitalizeWords() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
}

class ConversationPreview {
  final String messageId;
  final String clientName; // Client’s name
  final String lastMessageTime; // Timestamp of latest message
  final String lastMessage; // Latest message text
  final int unreadCount; // Number of unread messages
  final String avatarPath; // Client avatar

  const ConversationPreview({
    required this.messageId,
    required this.clientName,
    required this.lastMessageTime,
    required this.lastMessage,
    this.unreadCount = 0,
    this.avatarPath = "assets/images/user-profile.png",
  });

  factory ConversationPreview.fromJson(Map<String, dynamic> json) {
    return ConversationPreview(
      messageId: json['messageId'] as String,
      clientName: json['clientName'] as String,
      lastMessageTime: json['lastMessageTime'] as String,
      lastMessage: json['lastMessage'] as String,
      unreadCount: json['unreadCount'] as int? ?? 0,
      avatarPath:
          json['avatarPath'] as String? ?? "assets/images/user-profile.png",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientName': clientName,
      'lastMessageTime': lastMessageTime,
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
      'avatarPath': avatarPath,
    };
  }

  /// Optional: sample data for testing
  factory ConversationPreview.mock({
    String? messageId,
    String? clientName,
    String? lastMessageTime,
    String? lastMessage,
    int? unreadCount,
    String? avatarPath,
  }) {
    return ConversationPreview(
      messageId: messageId ?? "m-0",
      clientName: clientName ?? "John Doe",
      lastMessageTime: lastMessageTime ?? "10:30",
      lastMessage: lastMessage ?? "Hey! Are the catches still available?",
      unreadCount: unreadCount ?? 0,
      avatarPath: avatarPath ?? "assets/images/user-profile.png",
    );
  }
}

class InfoRow {
  InfoRow({
    required this.label,
    required this.value,
    this.editable = false,
    this.onEdit,
    this.suffix,
  });

  final String label;
  final dynamic value;
  final bool editable;
  final String? suffix;
  final VoidCallback? onEdit;
}

class ComponentRow {
  ComponentRow({required this.firstItem, required this.secondItem});

  final Widget firstItem;
  final Widget secondItem;
}

enum ChartRange { day, week, month, year }

enum SortBy { newOld, oldNew, highLow, lowHigh, none }

class Species {
  final String id;
  final String name;

  const Species({required this.id, required this.name});

  factory Species.fromJson(Map<String, dynamic> json) {
    return Species(id: json['id'] as String, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  String toString() => name; // handy for debugging

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Species && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Product {
  final String id;
  final String name;
  final int totalPrice;
  final Species species;
  final dynamic averageSize;
  final double availableWeight;
  final double pricePerKg;
  final String datePosted;
  final Seller seller;
  final List<String> images;

  Product({
    required this.id,
    required this.name,
    required this.totalPrice,
    required this.species,
    required this.averageSize,
    required this.availableWeight,
    required this.pricePerKg,
    required this.datePosted,
    required this.seller,
    required this.images,
  });

  factory Product.empty() {
    return Product(
      id: "",
      name: "",
      totalPrice: 0,
      species: Species(id: "", name: ""),
      averageSize: 0,
      availableWeight: 0,
      pricePerKg: 0,
      datePosted: "",
      seller: Seller.empty(),
      images: [],
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      totalPrice: json['total_price'] as int,
      species: Species.fromJson(json['species'] as Map<String, dynamic>),
      averageSize: json['average_size'],
      availableWeight: json['available_weight'] as double,
      pricePerKg: json['price_per_kg'] as double,
      datePosted: json['date_posted'] as String,
      seller: Seller.fromJson(json['seller'] as Map<String, dynamic>),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

class Seller {
  final String name;
  final String avatarUrl;
  final double rating;
  final int reviewCount;
  final String id;

  Seller({
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.reviewCount,
    required this.id,
  });

  factory Seller.empty() {
    return Seller(name: "", avatarUrl: "", rating: 0, reviewCount: 0, id: "");
  }

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String,
      rating: json['rating'] as double,
      reviewCount: json['review_count'] as int,
      id: json['id'] as String,
    );
  }
}

class Order {
  final String orderId;
  final String productName;
  final OfferStatus status;
  final double weight;
  final String market;
  final double price;
  final List<String> images;
  final String dateCreated;
  final String dateUpdated;
  final Species species;
  final dynamic size;
  final Seller fisher;

  Order({
    required this.orderId,
    required this.productName,
    required this.status,
    required this.weight,
    required this.market,
    required this.price,
    required this.images,
    required this.dateCreated,
    required this.dateUpdated,
    required this.species,
    required this.size,
    required this.fisher,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'] as String,
      productName: json['product_name'] as String,
      status: offerStatusFromString(json['status'] as String),
      weight: json['weight'] as double,
      market: json['market'] as String,
      price: json['price'] as double,
      images: json['images'] as List<String>,
      dateCreated: json['date_created'] as String,
      dateUpdated: json['date_updated'] as String,
      species: Species.fromJson(json['species'] as Map<String, dynamic>),
      size: json['size'],
      fisher: Seller.fromJson(json['fisher'] as Map<String, dynamic>),
    );
  }

  factory Order.empty() {
    return Order(
      orderId: "",
      productName: "",
      status: OfferStatus.pending,
      weight: 0,
      market: "",
      price: 0,
      images: [],
      dateCreated: "",
      dateUpdated: "",
      species: Species(id: "", name: ""),
      size: "",
      fisher: Seller.empty(),
    );
  }
}
