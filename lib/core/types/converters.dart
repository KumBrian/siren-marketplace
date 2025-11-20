import 'package:intl/intl.dart';

import 'enum.dart';

Role roleFromString(String s) =>
    Role.values.firstWhere((e) => e.name == s, orElse: () => Role.unknown);

String roleToString(Role r) => r.name;

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
      return CatchStatus.sold;
    case 'draft':
      return CatchStatus.draft;
    case 'processing':
      return CatchStatus.processing;
    default:
      return CatchStatus.draft;
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
