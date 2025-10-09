import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // NEW IMPORT
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/buyer_cubit/buyer_cubit.dart'; // NEW IMPORT
import 'package:siren_marketplace/components/buyer_offer_actions.dart';
import 'package:siren_marketplace/components/info_table.dart';
import 'package:siren_marketplace/components/section_header.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';
// REMOVED: import 'package:siren_marketplace/data/offer_data.dart';

// --- Helper Extension (Assuming it's in your types.dart or another accessible file) ---
extension IterableExtensions<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
// ---

class BuyerOfferDetails extends StatefulWidget {
  const BuyerOfferDetails({super.key, required this.offerId});

  final String offerId;

  @override
  State<BuyerOfferDetails> createState() => _BuyerOfferDetailsState();
}

class _BuyerOfferDetailsState extends State<BuyerOfferDetails> {
  // REMOVED: late final BuyerOffer selectedOffer;
  // REMOVED: initState where mock data was loaded

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuyerCubit, Buyer?>(
      builder: (context, buyerState) {
        // 1. Handle Loading/Null State
        if (buyerState == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Find the specific offer from the buyer's list of madeOffers
        final Offer? selectedOffer = buyerState.madeOffers.firstWhereOrNull(
          (offer) => offer.offerId == widget.offerId,
        );

        // 3. Handle Offer Not Found
        if (selectedOffer == null) {
          return Scaffold(
            appBar: AppBar(
              leading: const BackButton(),
              title: const Text("Offer Details"),
            ),
            body: const Center(
              child: Text(
                "Offer not found.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        final offer = selectedOffer;

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
              // Replaced spacing: 16
              children: [
                BuyerOfferHeader(offer: offer),
                const SizedBox(height: 16),

                const SectionHeader("Current Offer"),
                const SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: InfoTable(
                    rows: [
                      InfoRow(
                        label: "Weight",
                        value: "${offer.weight.toInt()} Kg",
                      ),
                      InfoRow(
                        label: "Price Per Kg",
                        value: "${offer.pricePerKg.toInt()} CFA",
                      ),
                      InfoRow(
                        label: "Total",
                        value: "${offer.price.toInt()} CFA",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                FisherDetails(offer: offer),
                const SizedBox(height: 16),

                BuyerOfferActions(offer: offer, formKey: _formKey),
                const SizedBox(height: 16),

                if (offer.previousCounterOffer != null) ...[
                  const SectionHeader("Last Counter-Offer"),
                  const SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: InfoTable(
                      rows: [
                        InfoRow(
                          label: "Weight",
                          value:
                              "${offer.previousCounterOffer?.weight.toInt()} Kg",
                        ),
                        InfoRow(
                          label: "Price Per Kg",
                          value:
                              "${offer.previousCounterOffer?.pricePerKg.toInt()} CFA",
                        ),
                        InfoRow(
                          label: "Total",
                          value:
                              "${offer.previousCounterOffer?.price.toInt()} CFA",
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- Component Updates (Using unified Offer and standard sizing) ---

class BuyerOfferHeader extends StatelessWidget {
  final Offer offer; // Changed type to unified Offer

  const BuyerOfferHeader({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      // Replaced spacing: 10
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
        const SizedBox(width: 10), // Replaced spacing: 10
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            // Replaced spacing: 8
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                offer.catchName, // Field name remains correct
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textBlue,
                ),
              ),
              const SizedBox(height: 8), // Replaced spacing: 8
              Row(
                // Replaced spacing: 8
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
                  const SizedBox(width: 8), // Replaced spacing: 8
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
  final Offer offer; // Changed type to unified Offer

  const FisherDetails({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      // Replaced spacing: 10
      children: [
        CircleAvatar(
          radius: 30,
          // clientAvatar, clientName, clientRating, clientReviewCount
          // now correctly reference the Fisher's details when viewing a Buyer's offer
          backgroundImage: NetworkImage(offer.clientAvatar),
        ),
        const SizedBox(width: 10), // Replaced spacing: 10
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // Replaced spacing: 8
            children: [
              Text(
                offer.clientName,
                // Using unified clientName (which is the Fisher's name here)
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textBlue,
                ),
              ),
              const SizedBox(height: 8), // Replaced spacing: 8
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: AppColors.shellOrange,
                    size: 16,
                  ),
                  Text(
                    offer.clientRating.toStringAsFixed(1),
                    // Using unified clientRating
                    style: const TextStyle(
                      color: AppColors.textBlue,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    " (${offer.clientReviewCount} Reviews)",
                    // Using unified clientReviewCount
                    style: const TextStyle(
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
