import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/components/buyer_offer_actions.dart';
import 'package:siren_marketplace/components/info_table.dart';
import 'package:siren_marketplace/components/section_header.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';
import 'package:siren_marketplace/data/offer_data.dart';

class BuyerOfferDetails extends StatefulWidget {
  const BuyerOfferDetails({super.key, required this.offerId});

  final String offerId;

  @override
  State<BuyerOfferDetails> createState() => _BuyerOfferDetailsState();
}

class _BuyerOfferDetailsState extends State<BuyerOfferDetails> {
  late final BuyerOffer selectedOffer;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    selectedOffer = mockOffers.firstWhere(
      (offer) => offer.offerId == widget.offerId,
    );
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
            BuyerOfferHeader(offer: selectedOffer),

            const SectionHeader("Current Offer"),
            InfoTable(
              rows: [
                InfoRow(
                  label: "Weight",
                  value: "${selectedOffer.weight.toInt()} Kg",
                ),
                InfoRow(
                  label: "Price Per Kg",
                  value: "${selectedOffer.pricePerKg.toInt()} CFA",
                ),
                InfoRow(
                  label: "Total",
                  value: "${selectedOffer.price.toInt()} CFA",
                ),
              ],
            ),

            FisherDetails(offer: selectedOffer),

            BuyerOfferActions(offer: selectedOffer, formKey: _formKey),

            if (selectedOffer.previousCounterOffer != null) ...[
              const SectionHeader("Last Counter-Offer"),
              InfoTable(
                rows: [
                  InfoRow(
                    label: "Weight",
                    value:
                        "${selectedOffer.previousCounterOffer?.weight.toInt()} Kg",
                  ),
                  InfoRow(
                    label: "Price Per Kg",
                    value:
                        "${selectedOffer.previousCounterOffer?.pricePerKg.toInt()} CFA",
                  ),
                  InfoRow(
                    label: "Total",
                    value:
                        "${selectedOffer.previousCounterOffer?.price.toInt()} CFA",
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

class BuyerOfferHeader extends StatelessWidget {
  final BuyerOffer offer;

  const BuyerOfferHeader({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        GestureDetector(
          onTap: () {
            final providers = offer.catchImages.map<ImageProvider>((img) {
              return NetworkImage(img);
            }).toList();

            final multiImageProvider = MultiImageProvider(providers);

            // Show image viewer
            showImageViewerPager(
              context,
              multiImageProvider,
              swipeDismissible: true,
              immersive: true,
              useSafeArea: true,
              doubleTapZoomable: true,

              backgroundColor: Colors.black.withValues(alpha: .4),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),

            // round corners
            child: Image.network(
              offer.catchImages.first,
              width: 60,
              height: 60,

              fit: BoxFit.cover,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                offer.catchName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textBlue,
                ),
              ),
              Row(
                spacing: 8,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white),
                      color: AppColors.getStatusColor(offer.status),
                    ),
                  ),
                  // Icon(Icons.person, color: AppColors.white100, size: 60),
                  Text(
                    offer.status.name.capitalize(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getStatusColor(offer.status),
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

class FisherDetails extends StatelessWidget {
  final BuyerOffer offer;

  const FisherDetails({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(offer.clientAvatar),
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
                  Text(
                    " (${offer.fisherReviewCount} Reviews)",
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
