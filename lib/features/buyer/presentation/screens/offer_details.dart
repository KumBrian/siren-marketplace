import 'package:flutter/material.dart';
import 'package:siren_marketplace/features/shared/presentation/screens/offer_details_screen.dart';

class BuyerOfferDetails extends StatelessWidget {
  final String offerId;

  const BuyerOfferDetails({super.key, required this.offerId});

  @override
  Widget build(BuildContext context) {
    return SharedOfferDetailsScreen(offerId: offerId);
  }
}
