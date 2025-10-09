import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Added for context.pop()
// --- NEW IMPORTS ---
import 'package:siren_marketplace/bloc/cubits/fisher_cubit/fisher_cubit.dart';
import 'package:siren_marketplace/components/custom_button.dart';
import 'package:siren_marketplace/components/info_table.dart';
import 'package:siren_marketplace/components/section_header.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';

// REMOVE: import 'package:siren_marketplace/data/catch_data.dart';

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

// REMOVED/SIMPLIFIED: The custom OfferContext class is no longer necessary
// since the Offer contains the catchName.

class CongratulationsScreen extends StatefulWidget {
  const CongratulationsScreen({super.key, required this.offerId});

  final String offerId;

  @override
  State<CongratulationsScreen> createState() => _CongratulationsScreenState();
}

class _CongratulationsScreenState extends State<CongratulationsScreen> {
  // Helper method to look up the Offer
  Offer? _getOffer(Fisher? fisher) {
    if (fisher == null) return null;

    // Flatten all offers from all catches and find the one that matches offerId
    return fisher.catches
        .expand((c) => c.offers)
        .firstWhereOrNull((offer) => offer.offerId == widget.offerId);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Listen to the FisherCubit to get the latest Fisher data
    return BlocBuilder<FisherCubit, Fisher?>(
      builder: (context, fisherState) {
        final selectedOffer = _getOffer(fisherState);

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
              title: const Text("Congratulations!"),
            ),
            body: const Center(child: Text("Offer details not found.")),
          );
        }

        // Ensure the offer was accepted to show this screen
        if (selectedOffer.status != OfferStatus.accepted) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop()),
              title: const Text("Offer Status"),
            ),
            body: Center(
              child: Text(
                "Offer status is ${selectedOffer.status.name.capitalize()} (Not Accepted).",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () => context.pop()),
            title: const Text(
              "Congratulations!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textBlue,
                fontSize: 24,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Use catchName from the unified Offer
                SectionHeader(selectedOffer.catchName),
                const Divider(color: AppColors.gray200),
                InfoTable(
                  rows: [
                    InfoRow(
                      label: "Weight",
                      value: selectedOffer.weight.toStringAsFixed(1),
                      suffix: "Kg",
                    ),
                    InfoRow(
                      label: "Total",
                      value: selectedOffer.price.toStringAsFixed(0),
                      suffix: "CFA",
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        title: "Message",
                        onPressed: () {
                          // TODO: Navigate to message screen with buyer details
                        },
                        icon: Icons.chat_bubble_outline_rounded,
                        bordered: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomButton(
                        title: "Call",
                        onPressed: () {
                          // TODO: Implement call functionality (e.g., using url_launcher)
                        },
                        icon: Icons.phone_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
