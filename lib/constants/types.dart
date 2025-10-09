import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum Role { fisher, buyer, unknown }

enum OfferStatus { pending, accepted, rejected, completed }

enum ChartRange { day, week, month, year }

enum SortBy { newOld, oldNew, highLow, lowHigh, none }

// ---------------------------------------------------------------------------
// UTILITY FUNCTIONS
// ---------------------------------------------------------------------------
OfferStatus offerStatusFromString(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return OfferStatus.pending;
    case 'accepted':
      return OfferStatus.accepted;
    case 'rejected':
    case 'countered': // Add 'countered' if you use it in the flow
      return OfferStatus.rejected;
    case 'completed':
      return OfferStatus.completed;
    default:
      // Consider a less aggressive default like pending or a true 'unknown' status
      throw Exception('Unknown offer status: $status');
  }
}

String offerStatusToString(OfferStatus status) => status.name;

extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return '';
    return this[0].toUpperCase() + substring(1);
  }

  String capitalizeWords() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
}

extension DateFormatting on String {
  String toFormattedDate() {
    try {
      final date = DateTime.parse(this);
      return DateFormat("MMM d, yyyy - H:mm").format(date);
    } catch (_) {
      return this;
    }
  }
}

// ---------------------------------------------------------------------------
// SPECIES
// ---------------------------------------------------------------------------
class Species {
  final String id;
  final String name;

  const Species({required this.id, required this.name});

  factory Species.fromJson(Map<String, dynamic> json) {
    return Species(id: json['id'] as String, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

// ---------------------------------------------------------------------------
// USERS (Simplified and Unified)
// ---------------------------------------------------------------------------
/// Base user class for both Fisher and Buyer, providing shared identity details.
abstract class AppUser {
  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final int reviewCount;
  final Role role;

  AppUser({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.reviewCount,
    required this.role,
  });
}

class Fisher extends AppUser {
  final List<Catch> catches;
  final List<Order> orders;
  final List<ConversationPreview> messages;
  final List<Offer> receivedOffers; // All offers received on their catches

  Fisher({
    required super.id,
    required super.name,
    required super.avatarUrl,
    required super.rating,
    required super.reviewCount,
    required this.catches,
    required this.orders,
    required this.messages,
    required this.receivedOffers,
  }) : super(role: Role.fisher);
}

class Buyer extends AppUser {
  final List<Order> orders;
  final List<Offer> madeOffers; // Offers made by buyer
  final List<ConversationPreview> messages;

  Buyer({
    required super.id,
    required super.name,
    required super.avatarUrl,
    required super.rating,
    required super.reviewCount,
    required this.orders,
    required this.madeOffers,
    required this.messages,
  }) : super(role: Role.buyer);
}

// ---------------------------------------------------------------------------
// CATCH
// ---------------------------------------------------------------------------
class Catch {
  final String catchId;
  final String name;
  final String datePosted;
  final String size;
  final double initialWeight;
  final double availableWeight;
  final double pricePerKg;
  final double total;
  final List<String> images;
  final Species species;
  final String market;
  final List<Offer> offers; // Now uses the unified Offer class
  final List<ConversationPreview> messages;
  final Fisher fisher;

  const Catch({
    required this.catchId,
    required this.name,
    required this.datePosted,
    required this.size,
    required this.initialWeight,
    required this.availableWeight,
    required this.pricePerKg,
    required this.total,
    required this.images,
    required this.species,
    required this.market,
    required this.offers,
    required this.messages,
    required this.fisher,
  });

  bool get isExpired {
    try {
      final posted = DateTime.parse(datePosted);
      final expiry = posted.add(const Duration(days: 7));
      return DateTime.now().isAfter(expiry);
    } catch (_) {
      return false;
    }
  }

  bool get isAvailable => !isExpired && availableWeight > 0;

  int get daysLeft {
    try {
      final posted = DateTime.parse(datePosted);
      final expiry = posted.add(const Duration(days: 7));
      final diff = expiry.difference(DateTime.now()).inDays;
      return diff > 0 ? diff : 0;
    } catch (_) {
      return 0;
    }
  }

  String get daysLeftLabel {
    final left = daysLeft;
    if (left == 0) return "Expired";
    if (left == 1) return "1 day left";
    return "$left days left";
  }

  // Existing extension moved to be a method for clarity
  Catch copyWith({List<Offer>? offers, List<ConversationPreview>? messages}) {
    return Catch(
      catchId: catchId,
      name: name,
      datePosted: datePosted,
      size: size,
      initialWeight: initialWeight,
      availableWeight: availableWeight,
      pricePerKg: pricePerKg,
      total: total,
      images: images,
      species: species,
      market: market,
      offers: offers ?? this.offers,
      messages: messages ?? this.messages,
      fisher: fisher,
    );
  }
}

// ---------------------------------------------------------------------------
// OFFERS (Unified)
// ---------------------------------------------------------------------------
/// Represents a price/quantity offer made by a Buyer to a Fisher on a specific Catch.
class Offer {
  final String offerId;
  final String catchId; // Link to the Catch being offered on
  final String fisherId; // The ID of the Catch owner (Seller)
  final String buyerId; // The ID of the Buyer who made the offer

  // --- NEW FIELDS FOR FISHER IDENTITY (Seller) ---
  final String fisherName;
  final String fisherAvatar;
  final double fisherRating;
  final int fisherReviewCount;

  // -----------------------------------------------

  final String
  clientName; // Name of the counterparty (Fisher when viewed by Buyer, Buyer when viewed by Fisher)
  final String clientAvatar;
  final double clientRating;
  final int clientReviewCount;

  final String catchName;
  final List<String> catchImages;

  final String dateCreated;
  final OfferStatus status;
  final double pricePerKg;
  final double price;
  final double weight;

  final Offer? previousCounterOffer;

  const Offer({
    required this.offerId,
    required this.catchId,
    required this.fisherId,
    required this.buyerId,
    // --- NEW FIELDS IN CONSTRUCTOR ---
    required this.fisherName,
    required this.fisherAvatar,
    required this.fisherRating,
    required this.fisherReviewCount,
    // ---------------------------------
    required this.clientName,
    required this.clientAvatar,
    required this.clientRating,
    required this.clientReviewCount,
    required this.catchName,
    required this.catchImages,
    required this.dateCreated,
    required this.status,
    required this.pricePerKg,
    required this.price,
    required this.weight,
    this.previousCounterOffer,
  });

  Map<String, dynamic> toJson() => {
    'offer_id': offerId,
    'catch_id': catchId,
    'fisher_id': fisherId,
    'buyer_id': buyerId,
    // --- NEW FIELDS IN JSON ---
    'fisher_name': fisherName,
    'fisher_avatar': fisherAvatar,
    'fisher_rating': fisherRating,
    'fisher_review_count': fisherReviewCount,
    // --------------------------
    'client_name': clientName,
    'client_avatar': clientAvatar,
    'client_rating': clientRating,
    'client_review_count': clientReviewCount,
    'catch_name': catchName,
    'catch_images': catchImages,
    'date_created': dateCreated,
    'status': offerStatusToString(status),
    'price_per_kg': pricePerKg,
    'price': price,
    'weight': weight,
    'previous_counter_offer': previousCounterOffer?.toJson(),
  };
}

// ---------------------------------------------------------------------------
// ORDERS (Simplified)
// ---------------------------------------------------------------------------
/// An Order is a Catch/Offer combination that has been Accepted/Completed.
class Order {
  final String orderId;
  final Offer offer; // The accepted offer that led to the order
  final Product product; // The product details at the time of order
  final Fisher fisher; // The fisher who fulfilled the order
  final Buyer buyer; // The buyer who placed the order
  final String dateUpdated;

  // Derive all other details (status, weight, price, images, etc.) from Offer/Product

  Order({
    required this.orderId,
    required this.offer,
    required this.product,
    required this.fisher,
    required this.buyer,
    required this.dateUpdated,
  });
}

// ---------------------------------------------------------------------------
// PRODUCT & SELLER (Refined)
// ---------------------------------------------------------------------------
/// Represents the marketable information about a Catch for the Buyer.
class Product {
  final String id; // Should match Catch.catchId
  final String name;
  final int totalPrice; // Total price for the AVAILABLE weight
  final Species species;
  final String market;
  final String averageSize; // Changed dynamic to String for clarity
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
    required this.market,
    required this.averageSize,
    required this.availableWeight,
    required this.pricePerKg,
    required this.datePosted,
    required this.seller,
    required this.images,
  });
}

class Seller {
  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final int reviewCount;

  Seller({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.reviewCount,
  });

  factory Seller.empty() =>
      Seller(id: "", name: "", avatarUrl: "", rating: 0, reviewCount: 0);
}

// ---------------------------------------------------------------------------
// MESSAGES & UI HELPERS (No changes needed)
// ---------------------------------------------------------------------------
class ConversationPreview {
  final String messageId;
  final String clientName;
  final String lastMessageTime;
  final String lastMessage;
  final int unreadCount;
  final String avatarPath;

  const ConversationPreview({
    required this.messageId,
    required this.clientName,
    required this.lastMessageTime,
    required this.lastMessage,
    this.unreadCount = 0,
    this.avatarPath = "assets/images/user-profile.png",
  });
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
  final dynamic value; // Can be String, int, double, Widget, etc.
  final bool editable;
  final String? suffix; // e.g., "kg", "$"
  final VoidCallback? onEdit;
}

class ComponentRow {
  ComponentRow({required this.firstItem, required this.secondItem});

  final Widget firstItem;
  final Widget secondItem;
}

enum Sender { me, other }

class Message {
  final String text;
  final DateTime timestamp;
  final Sender sender;

  Message({required this.text, required this.timestamp, required this.sender});
}
