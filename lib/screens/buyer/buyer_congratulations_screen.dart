import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // NEW IMPORT
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/buyer_cubit/buyer_cubit.dart'; // NEW IMPORT
import 'package:siren_marketplace/components/custom_button.dart';
import 'package:siren_marketplace/components/info_table.dart';
import 'package:siren_marketplace/components/section_header.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';
// REMOVED: import 'package:siren_marketplace/data/catch_data.dart';

// --- Helper Extension (For safe retrieval) ---
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

class BuyerCongratulationsScreen extends StatefulWidget {
  const BuyerCongratulationsScreen({super.key, required this.offerId});

  final String offerId;

  @override
  State<BuyerCongratulationsScreen> createState() =>
      _BuyerCongratulationsScreenState();
}

class _BuyerCongratulationsScreenState
    extends State<BuyerCongratulationsScreen> {
  // REMOVED: final catches = sampleCatches;
  // REMOVED: late final FisherOffer offer;
  // REMOVED: late final Catch selectedCatch;
  // REMOVED: initState for local data loading

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
        final Offer? offer = buyerState.madeOffers.firstWhereOrNull(
          (o) => o.offerId == widget.offerId,
        );

        // 3. Handle Offer Not Found (Critical Failure)
        if (offer == null) {
          return Scaffold(
            appBar: AppBar(
              leading: const BackButton(),
              title: const Text("Error"),
            ),
            body: const Center(
              child: Text(
                "Offer not found or invalid link.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        // Ensure the offer was actually accepted to show congratulations
        if (offer.status != OfferStatus.accepted) {
          // Maybe navigate back or show a different screen/message
          return Scaffold(
            appBar: AppBar(
              leading: const BackButton(),
              title: const Text("Offer Status"),
            ),
            body: Center(
              child: Text(
                "Offer status is ${offer.status.name.capitalize()} (Not Accepted).",
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
                // Use catchName from the unified Offer object
                SectionHeader(offer.catchName),
                const Divider(color: AppColors.gray200),
                InfoTable(
                  rows: [
                    InfoRow(label: "Weight", value: offer.weight, suffix: "Kg"),
                    InfoRow(label: "Total", value: offer.price, suffix: "CFA"),
                  ],
                ),

                const SizedBox(height: 40),
                Row(
                  // Removed spacing: 8
                  children: [
                    Expanded(
                      child: CustomButton(
                        title: "Message",
                        onPressed: () {
                          // TODO: Navigate to message screen with Fisher/Catch details
                        },
                        icon: Icons.chat_bubble_outline_rounded,
                        bordered: true,
                      ),
                    ),
                    const SizedBox(width: 8), // Replaced spacing: 8
                    Expanded(
                      child: CustomButton(
                        title: "Call",
                        onPressed: () {
                          // TODO: Implement call functionality
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
