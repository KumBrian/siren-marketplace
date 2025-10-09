import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// --- NEW IMPORTS ---
import 'package:siren_marketplace/bloc/cubits/fisher_cubit/fisher_cubit.dart';
import 'package:siren_marketplace/components/fisher_offer_actions.dart';
import 'package:siren_marketplace/components/info_table.dart';
import 'package:siren_marketplace/components/section_header.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';

// --- Helper Extension for finding element in Iterable ---
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

class FisherOfferDetails extends StatefulWidget {
  const FisherOfferDetails({super.key, required this.offerId});

  final String offerId;

  @override
  State<FisherOfferDetails> createState() => _FisherOfferDetailsState();
}

class _FisherOfferDetailsState extends State<FisherOfferDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    super.dispose();
  }

  // UPDATE: Return type changed from FisherOffer to the unified Offer
  Offer? _getOfferFromState(Fisher? fisher) {
    if (fisher == null) return null;

    // The logic remains correct: flatten all offers from all catches and find the one that matches offerId
    return fisher.catches
        .expand((c) => c.offers)
        .firstWhereOrNull((offer) => offer.offerId == widget.offerId);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Listen to the FisherCubit to get the latest Fisher data
    return BlocBuilder<FisherCubit, Fisher?>(
      builder: (context, fisherState) {
        // Find the unified Offer
        final Offer? selectedOffer = _getOfferFromState(fisherState);

        // Handle Loading / Data Not Available
        if (fisherState == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Handle Offer Not Found
        if (selectedOffer == null) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop()),
              title: const Text("Offer Details"),
            ),
            body: const Center(child: Text("Offer not found.")),
          );
        }

        // The Offer is found, proceed with the UI
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
              children: [
                OfferHeader(offer: selectedOffer),
                const SizedBox(height: 16),

                const SectionHeader("Current Offer"),
                const SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: InfoTable(
                    rows: [
                      // Ensure the values are correctly formatted (e.g., using toInt() or toStringAsFixed(0))
                      InfoRow(
                        label: "Weight",
                        value: "${selectedOffer.weight.toStringAsFixed(1)} Kg",
                      ),
                      InfoRow(
                        label: "Price/Kg",
                        value: "${selectedOffer.pricePerKg.toInt()} CFA",
                      ),
                      InfoRow(
                        label: "Price",
                        value: "${selectedOffer.price.toInt()} CFA",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Ensure FisherOfferActions expects the unified Offer type
                FisherOfferActions(offer: selectedOffer, formKey: _formKey),
                const SizedBox(height: 16),

                if (selectedOffer.previousCounterOffer != null) ...[
                  const SectionHeader("Last Counter-Offer"),
                  const SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: InfoTable(
                      rows: [
                        // Safely access fields on the previousCounterOffer
                        InfoRow(
                          label: "Weight",
                          value:
                              "${selectedOffer.previousCounterOffer!.weight.toInt()} Kg",
                        ),
                        InfoRow(
                          label: "Price",
                          value:
                              "${selectedOffer.previousCounterOffer!.price.toInt()} CFA",
                        ),
                        InfoRow(
                          label: "Price Per Kg",
                          value:
                              "${selectedOffer.previousCounterOffer!.pricePerKg.toInt()} CFA",
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

class OfferHeader extends StatelessWidget {
  final Offer offer; // UPDATE: Changed type to the unified Offer

  const OfferHeader({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    // Accessing client details using the unified Offer fields (clientName, clientAvatar, clientRating, clientReviewCount)

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(offer.clientAvatar),
          onBackgroundImageError: (exception, stackTrace) =>
              const AssetImage("assets/images/user-profile.png"), // Fallback
        ),
        const SizedBox(width: 10), // Replaced spacing: 10
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offer.clientName, // UPDATE: Use clientName
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
                    // UPDATE: Use clientRating
                    style: const TextStyle(
                      color: AppColors.textBlue,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    " (${offer.clientReviewCount} Reviews)",
                    // UPDATE: Use clientReviewCount
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
