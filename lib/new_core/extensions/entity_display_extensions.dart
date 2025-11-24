// lib/core/extensions/entity_display_extensions.dart

import 'package:intl/intl.dart';

import '../domain/entities/catch.dart';
import '../domain/entities/offer.dart';
import '../domain/entities/order.dart';
import '../domain/entities/review.dart';
import '../domain/entities/user.dart';
import '../domain/enums/catch_status.dart';
import '../domain/enums/offer_status.dart';
import '../domain/enums/order_status.dart';

/// Extensions to make new entities display exactly like old models in UI
/// This keeps all your existing widgets working without changes!

// =============================================================================
// CATCH DISPLAY EXTENSIONS
// =============================================================================

extension CatchDisplay on Catch {
  /// Format price for display (e.g., "\$15.00")
  String get displayPrice => '\$${totalPrice.major.toStringAsFixed(2)}';

  /// Format price per kg (e.g., "\$15.00/kg")
  String get displayPricePerKg => '\$${pricePerKg.major.toStringAsFixed(2)}/kg';

  /// Format weight in kg (e.g., "5.0kg" or "5kg")
  String get displayWeight =>
      '${availableWeight.kilograms.toStringAsFixed(1)}kg';

  /// Format initial weight
  String get displayInitialWeight =>
      '${initialWeight.kilograms.toStringAsFixed(1)}kg';

  /// Get numeric values (compatible with old int-based UI)
  int get numericPrice => totalPrice.amount;
  int get numericPricePerKg => pricePerKg.amountPerKg;
  int get numericWeight => availableWeight.grams;
  int get numericInitialWeight => initialWeight.grams;

  /// Format date posted (e.g., "2 days ago")
  String get displayDatePosted {
    final now = DateTime.now();
    final difference = now.difference(datePosted);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Format date as string (e.g., "Jan 15, 2024")
  String get formattedDate => DateFormat('MMM dd, yyyy').format(datePosted);

  /// Get status as string (compatible with old String-based status)
  String get statusString => status.name;

  /// Get status display name (e.g., "Available", "Sold Out")
  String get statusDisplay => status.displayName;

  /// Get species name
  String get speciesName => species.name;

  /// Get primary image URL or empty string
  String get imageUrl => primaryImage ?? '';

  /// Check if sold out (for UI conditionals)
  bool get isSoldOutDisplay => status == CatchStatus.soldOut;

  /// Check if expired (for UI conditionals)
  bool get isExpiredDisplay => status == CatchStatus.expired;
}

// =============================================================================
// OFFER DISPLAY EXTENSIONS
// =============================================================================

extension OfferDisplay on Offer {
  /// Format current price (e.g., "\$70.00")
  String get displayPrice =>
      '\$${currentTerms.totalPrice.major.toStringAsFixed(2)}';

  /// Format current price per kg
  String get displayPricePerKg =>
      '\$${currentTerms.pricePerKg.major.toStringAsFixed(2)}/kg';

  /// Format current weight
  String get displayWeight =>
      '${currentTerms.weight.kilograms.toStringAsFixed(1)}kg';

  /// Get numeric values (compatible with old UI)
  int get numericPrice => currentTerms.totalPrice.amount;
  int get numericPricePerKg => currentTerms.pricePerKg.amountPerKg;
  int get numericWeight => currentTerms.weight.grams;

  /// Previous offer values (for counter offer comparison)
  String? get displayPreviousPrice {
    if (previousTerms == null) return null;
    return '\$${previousTerms!.totalPrice.major.toStringAsFixed(2)}';
  }

  String? get displayPreviousWeight {
    if (previousTerms == null) return null;
    return '${previousTerms!.weight.kilograms.toStringAsFixed(1)}kg';
  }

  int? get numericPreviousPrice => previousTerms?.totalPrice.amount;
  int? get numericPreviousWeight => previousTerms?.weight.grams;

  /// Format dates
  String get displayDateCreated =>
      DateFormat('MMM dd, yyyy').format(dateCreated);
  String get displayDateUpdated =>
      DateFormat('MMM dd, yyyy').format(dateUpdated);

  /// Time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(dateUpdated);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Get status as string
  String get statusString => status.name;

  /// Get status display name
  String get statusDisplay => status.displayName;

  /// Check status (for UI conditionals)
  bool get isPendingDisplay => status == OfferStatus.pending;
  bool get isAcceptedDisplay => status == OfferStatus.accepted;
  bool get isRejectedDisplay => status == OfferStatus.rejected;

  /// Waiting for role display
  String? get waitingForDisplay => waitingFor?.displayName;
}

// =============================================================================
// ORDER DISPLAY EXTENSIONS
// =============================================================================

extension OrderDisplay on Order {
  /// Format price
  String get displayPrice => '\$${terms.totalPrice.major.toStringAsFixed(2)}';

  /// Format price per kg
  String get displayPricePerKg =>
      '\$${terms.pricePerKg.major.toStringAsFixed(2)}/kg';

  /// Format weight
  String get displayWeight => '${terms.weight.kilograms.toStringAsFixed(1)}kg';

  /// Get numeric values
  int get numericPrice => terms.totalPrice.amount;
  int get numericPricePerKg => terms.pricePerKg.amountPerKg;
  int get numericWeight => terms.weight.grams;

  /// Format dates
  String get displayDateCreated =>
      DateFormat('MMM dd, yyyy').format(dateCreated);
  String get displayDateUpdated =>
      DateFormat('MMM dd, yyyy').format(dateUpdated);

  /// Time since creation
  String get timeSinceCreation {
    final now = DateTime.now();
    final difference = now.difference(dateCreated);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Get status as string
  String get statusString => status.name;

  /// Get status display name
  String get statusDisplay => status.displayName;

  /// Check status (for UI conditionals)
  bool get isActiveDisplay => status == OrderStatus.active;
  bool get isCompletedDisplay => status == OrderStatus.completed;
  bool get isCancelledDisplay => status == OrderStatus.cancelled;

  /// Review status display
  String get reviewStatusDisplay {
    if (hasReviewFromFisher && hasReviewFromBuyer) {
      return 'Both reviewed';
    } else if (hasReviewFromFisher) {
      return 'Fisher reviewed';
    } else if (hasReviewFromBuyer) {
      return 'Buyer reviewed';
    } else {
      return 'Not reviewed';
    }
  }
}

// =============================================================================
// USER DISPLAY EXTENSIONS
// =============================================================================

extension UserDisplay on User {
  /// Format rating (e.g., "4.5")
  String get displayRating => rating.value.toStringAsFixed(1);

  /// Format rating with stars (e.g., "4.5 ★")
  String get displayRatingWithStar => '${displayRating} ★';

  /// Format rating with review count (e.g., "4.5 (12 reviews)")
  String get displayRatingWithCount {
    if (reviewCount == 0) return 'No reviews';
    return '$displayRating ($reviewCount review${reviewCount > 1 ? 's' : ''})';
  }

  /// Get numeric rating (compatible with old double-based UI)
  double get numericRating => rating.value;

  /// Get role as string
  String get roleString => currentRole.name;

  /// Get role display name
  String get roleDisplay => currentRole.displayName;

  /// Check if fisher
  bool get isFisherDisplay => currentRole.isFisher;

  /// Check if buyer
  bool get isBuyerDisplay => currentRole.isBuyer;

  /// Get avatar with fallback
  String get avatarDisplay => avatarUrl ?? '';

  /// Get initials for avatar placeholder
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

// =============================================================================
// REVIEW DISPLAY EXTENSIONS
// =============================================================================

extension ReviewDisplay on Review {
  /// Format rating (e.g., "4.5")
  String get displayRating => rating.value.toStringAsFixed(1);

  /// Format rating with stars
  String get displayRatingWithStar => '$displayRating ★';

  /// Get numeric rating
  double get numericRating => rating.value;

  /// Format timestamp
  String get displayTimestamp => DateFormat('MMM dd, yyyy').format(timestamp);

  /// Time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Get comment or default text
  String get displayComment => comment ?? 'No comment provided';

  /// Check if has comment
  bool get hasCommentDisplay => comment != null && comment!.isNotEmpty;
}

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/// Format price from int (amount in cents) to display string
String formatPrice(int amount) {
  return '\$${(amount / 100).toStringAsFixed(2)}';
}

/// Format weight from grams to kg display string
String formatWeight(int grams) {
  return '${(grams / 1000).toStringAsFixed(1)}kg';
}

/// Format date to relative time
String formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays > 0) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
  } else {
    return 'Just now';
  }
}
