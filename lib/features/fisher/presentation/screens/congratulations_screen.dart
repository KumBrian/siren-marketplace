import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/buyer/logic/buyer_offer_details_bloc/offer_details_bloc.dart';
import 'package:siren_marketplace/features/fisher/logic/catch_bloc/catch_bloc.dart';

class CongratulationsScreen extends StatefulWidget {
  const CongratulationsScreen({super.key, required this.offerId});

  final String offerId;

  @override
  State<CongratulationsScreen> createState() => _CongratulationsScreenState();
}

class _CongratulationsScreenState extends State<CongratulationsScreen> {
  @override
  void initState() {
    super.initState();
    // 1. Load the specific Offer details
    context.read<OfferDetailsBloc>().add(LoadOfferDetails(widget.offerId));

    // 2. Ensure Catches are loaded to retrieve the Catch name
    // (This assumes CatchesBloc is typically provided higher up, but we trigger the load here)
    context.read<CatchesBloc>().add(LoadCatches());
  }

  // Helper method to find the Catch name
  String _getCatchName(Catch? parentCatch) {
    // Assuming the Catch model has a 'name' property
    return parentCatch?.name ?? "Unknown Catch";
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OfferDetailsBloc, OfferDetailsState>(
      builder: (context, offerState) {
        // --- 1. Handle Offer Loading / Initial State ---
        if (offerState is OfferDetailsLoading ||
            offerState is OfferDetailsInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // --- 2. Handle Offer Error State ---
        if (offerState is OfferDetailsError) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop()),
              title: const Text("Congratulations!"),
            ),
            body: Center(
              child: Text(
                offerState.message,
                style: const TextStyle(color: AppColors.fail500),
              ),
            ),
          );
        }

        // --- 3. Handle Offer Loaded State ---
        if (offerState is OfferDetailsLoaded) {
          final selectedOffer = offerState.offer;

          // Check for correct offer status early
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

          // 4. Use BlocBuilder for CatchesBloc to get the Catch name
          return BlocBuilder<CatchesBloc, CatchesState>(
            builder: (context, catchesState) {
              Catch? parentCatch;
              String catchName = "Loading Catch...";

              if (catchesState is CatchesLoaded) {
                // Find the parent Catch using the catchId from the loaded Offer
                parentCatch = catchesState.catches.firstWhere(
                  (c) => c.id == selectedOffer.catchId,
                  orElse: () => Catch.empty(), // Assuming a default empty Catch
                );
                catchName = _getCatchName(parentCatch);
              } else if (catchesState is CatchesError) {
                catchName = "Error loading catch!";
              }
              // If CatchesLoading, catchName remains "Loading Catch..."

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Use the dynamically retrieved catchName
                      SectionHeader(catchName),
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

        // Default fallback
        return const Scaffold(
          body: Center(child: Text("An unexpected state occurred.")),
        );
      },
    );
  }
}
