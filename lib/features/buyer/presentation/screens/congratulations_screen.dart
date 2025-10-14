import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/buyer/data/models/buyer.dart';
import 'package:siren_marketplace/features/buyer/logic/buyer_cubit/buyer_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

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

// lib/screens/buyer_congratulations_screen.dart

// ... (existing imports and class definition)

class _BuyerCongratulationsScreenState
    extends State<BuyerCongratulationsScreen> {
  Future<void> _makePhoneCall(String phoneNumber) async {
    // ... (implementation remains the same)
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch phone dialer for $phoneNumber'),
            backgroundColor: AppColors.fail500,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 FIX: Corrected the BlocBuilder to use the base state type BuyerState
    return BlocBuilder<BuyerCubit, BuyerState>(
      builder: (context, state) {
        // Renamed 'buyerState' to 'state' for clarity

        // 1. Handle Loading/Initial/Error States
        if (state is BuyerLoading || state is BuyerInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is BuyerError) {
          return Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: Center(
              child: Text('Error loading buyer data: ${state.message}'),
            ),
          );
        }

        // 2. 🎯 FIX: Safely extract the Buyer object from the BuyerLoaded state
        // This is where 'madeOffers' becomes accessible.
        final Buyer buyer = (state as BuyerLoaded).buyer;

        // 3. Find the specific offer from the buyer's list of madeOffers
        final Offer? offer = buyer.madeOffers.firstWhereOrNull(
          (o) => o.id == widget.offerId,
        );

        // 4. Handle Offer Not Found (Critical Failure)
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

        // 5. Ensure the offer was actually accepted to show congratulations
        if (offer.status != OfferStatus.accepted) {
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

        // 6. Define placeholder data for Call/Message (Assuming denormalized data is available)
        const String fisherPhoneNumber = '+237677123456';

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
                Text(
                  "Your offer for the catch from ${offer.fisherName} has been accepted!",
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textGray,
                  ),
                ),
                const SizedBox(height: 16),

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
                  children: [
                    Expanded(
                      child: CustomButton(
                        title: "Message",
                        onPressed: () {
                          context.push(
                            "/buyer/chat/${offer.fisherId}/${offer.catchId}",
                          );
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
                          _makePhoneCall(fisherPhoneNumber);
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
