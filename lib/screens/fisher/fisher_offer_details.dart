import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/components/fisher_offer_actions.dart';
import 'package:siren_marketplace/components/info_table.dart';
import 'package:siren_marketplace/components/section_header.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';
import 'package:siren_marketplace/data/catch_data.dart';

class FisherOfferDetails extends StatefulWidget {
  const FisherOfferDetails({super.key, required this.offerId});

  final String offerId;

  @override
  State<FisherOfferDetails> createState() => _FisherOfferDetailsState();
}

class _FisherOfferDetailsState extends State<FisherOfferDetails> {
  late final FisherOffer selectedOffer;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    selectedOffer = sampleCatches
        .expand((c) => c.offers)
        .firstWhere((offer) => offer.offerId == widget.offerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: const Text(
          "Offer Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textBlue,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            OfferHeader(offer: selectedOffer),

            const SectionHeader("Current Offer"),
            InfoTable(
              rows: [
                InfoRow(label: "Weight", value: selectedOffer.weight),
                InfoRow(label: "Price", value: selectedOffer.price),
                InfoRow(label: "Price Per Kg", value: selectedOffer.pricePerKg),
              ],
            ),

            FisherOfferActions(offer: selectedOffer, formKey: _formKey),

            if (selectedOffer.previousCounterOffer != null) ...[
              const SectionHeader("Last Counter-Offer"),
              InfoTable(
                rows: [
                  InfoRow(
                    label: "Weight",
                    value: selectedOffer.previousCounterOffer!.weight,
                  ),
                  InfoRow(
                    label: "Price",
                    value: selectedOffer.previousCounterOffer!.price,
                  ),
                  InfoRow(
                    label: "Price Per Kg",
                    value: selectedOffer.previousCounterOffer!.pricePerKg,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class OfferHeader extends StatelessWidget {
  final FisherOffer offer;

  const OfferHeader({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage(offer.clientAvatar),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                offer.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textBlue,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: AppColors.shellOrange,
                    size: 16,
                  ),
                  Text(
                    "${offer.fisherRating}",
                    style: const TextStyle(
                      color: AppColors.textBlue,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const Text(
                    " (128 Reviews)",
                    style: TextStyle(
                      color: AppColors.textBlue,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
