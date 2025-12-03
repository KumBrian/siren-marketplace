import 'package:intl/intl.dart';
import 'package:siren_marketplace/core/domain/enums/catch_status.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';

UserRole roleFromString(String s) => UserRole.values.firstWhere(
  (e) => e.name == s,
  orElse: () => UserRole.unknown,
);

String roleToString(UserRole r) => r.name;

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
      return OfferStatus.pending;
  }
}

String offerStatusToString(OfferStatus status) => status.name;

CatchStatus catchStatusFromString(String status) {
  switch (status.toLowerCase()) {
    case 'available':
      return CatchStatus.available;
    case 'sold':
      return CatchStatus.soldOut;
    case 'expired':
      return CatchStatus.expired;
    case 'removed':
      return CatchStatus.removed;
    default:
      return CatchStatus.available;
  }
}

String catchStatusToString(CatchStatus status) => status.name;

String formatPrice(num price) {
  return NumberFormat.currency(
    locale: 'en_CM',
    symbol: 'CFA',
    decimalDigits: 0,
    customPattern: '###,### CFA',
  ).format(price);
}

String formatWeight(int weightInGrams) {
  final weightInKg = weightInGrams / 1000;
  final weightString = "${weightInKg.toStringAsFixed(1)} Kg";
  return weightString;
}
