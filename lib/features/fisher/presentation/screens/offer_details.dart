import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/buyer/data/models/buyer.dart';
import 'package:siren_marketplace/features/fisher/logic/catch_bloc/catch_bloc.dart';
import 'package:siren_marketplace/features/fisher/logic/offer_bloc/offer_bloc.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/offer_actions.dart'; // Import for dialog helpers

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

// Assumed file: transaction_models.dart or similar

/// Holds the necessary historical negotiation details for display.
class PreviousOfferDetails {
  final double price;
  final double weight;
  final double pricePerKg;

  const PreviousOfferDetails({
    required this.price,
    required this.weight,
    required this.pricePerKg,
  });
}

/// Update the main transaction data wrapper to use the new simple class
class OfferTransactionData {
  final Buyer? buyer;
  final PreviousOfferDetails? previousDetails; // ⬅️ NEW FIELD TYPE

  const OfferTransactionData({this.buyer, this.previousDetails});
}

class FisherOfferDetails extends StatefulWidget {
  const FisherOfferDetails({super.key, required this.offerId});

  final String offerId;

  @override
  State<FisherOfferDetails> createState() => _FisherOfferDetailsState();
}

class _FisherOfferDetailsState extends State<FisherOfferDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // NEW: Repositories for fetching dependent data
  final UserRepository _userRepository = sl<UserRepository>();

  @override
  void dispose() {
    super.dispose();
  }

  // UPDATED: Finds the Offer from the CatchesLoaded state
  Offer? _getOfferFromState(CatchesState catchesState) {
    if (catchesState is! CatchesLoaded) return null;

    return catchesState.catches
        .expand((c) => c.offers)
        .firstWhereOrNull((offer) => offer.id == widget.offerId);
  }

  Future<OfferTransactionData> _loadTransactionData(Offer offer) async {
    final Map<String, dynamic>? buyerMap = await _userRepository.getUserMapById(
      offer.buyerId,
    );

    Buyer? buyer;
    if (buyerMap != null) {
      buyer = Buyer.fromMap(buyerMap);
    }

    PreviousOfferDetails? previousDetails;

    final hasPreviousNegotiation =
        offer.previousPrice != null &&
        offer.previousWeight != null &&
        offer.previousPricePerKg != null;

    if (hasPreviousNegotiation) {
      previousDetails = PreviousOfferDetails(
        price: offer.previousPrice!,
        weight: offer.previousWeight!,
        pricePerKg: offer.previousPricePerKg!,
      );
    }

    // 3. Return the updated transaction data
    return OfferTransactionData(
      buyer: buyer,
      previousDetails: previousDetails, // ⬅️ Passing the simple object
    );
  }

  // NEW METHOD: Handles the final success UI and navigation logic
  void _handleOfferAcceptSuccess(String orderId) {
    // 1. Show the success dialog with the navigation button
    showActionSuccessDialog(
      context,
      message: 'Offer successfully accepted!',
      autoCloseSeconds: 2,
    );
    context.read<CatchesBloc>().add(LoadCatches());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatchesBloc, CatchesState>(
      builder: (context, catchesState) {
        if (catchesState is CatchesLoading || catchesState is CatchesInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final Offer? selectedOffer = _getOfferFromState(catchesState);

        if (selectedOffer == null) {
          final errorMessage = catchesState is CatchesError
              ? "Error loading offers: ${catchesState.message}"
              : "Offer with ID ${widget.offerId} not found.";

          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop()),
              title: const Text("Offer Details"),
            ),
            body: Center(child: Text(errorMessage)),
          );
        }

        return BlocListener<OffersBloc, OffersState>(
          listener: (context, offerState) {
            // 1. Close the loading dialog opened by _handleAccept
            if (offerState is OfferActionSuccess ||
                offerState is OfferActionFailure) {
              if (Navigator.of(context).canPop()) {
                // Ensure we pop the loading dialog/modal
                Navigator.of(context).pop();
              }
            }

            if (offerState is OfferActionSuccess) {
              if (offerState.action == 'Accept') {
                // ⚠️ FIX 2: Check for null or empty orderId before calling the success handler.
                final String? orderId = offerState.orderId;

                if (orderId != null && orderId.isNotEmpty) {
                  _handleOfferAcceptSuccess(orderId);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '❌ Offer accepted, but failed to retrieve Order ID. Please check the orders list.',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.read<CatchesBloc>().add(LoadCatches());
                }
              } else {
                // For Counter or Reject, just show Snackbar and reload the catches
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '✅ Offer ${offerState.action}ed successfully!',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                context.read<CatchesBloc>().add(LoadCatches());
              }
            } else if (offerState is OfferActionFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '❌ ${offerState.action} failed: ${offerState.error}',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              // Reload catches to ensure the UI reflects the current state if the action failed
              context.read<CatchesBloc>().add(LoadCatches());
            }
          },
          child: FutureBuilder<OfferTransactionData>(
            key: ValueKey('${selectedOffer.id}-${selectedOffer.dateCreated}'),
            future: _loadTransactionData(selectedOffer),
            builder: (context, snapshot) {
              // Handle loading of dependent data
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final transactionData = snapshot.data;

              final Buyer? buyer = transactionData?.buyer;
              final PreviousOfferDetails? previous =
                  transactionData?.previousDetails;

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
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pass the fetched Buyer data
                      OfferHeader(offer: selectedOffer, buyer: buyer),
                      const SizedBox(height: 16),

                      const SectionHeader("Current Offer"),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.gray200),
                        ),
                        child: InfoTable(
                          rows: [
                            InfoRow(
                              label: "Total Weight",
                              value:
                                  "${selectedOffer.weight.toStringAsFixed(1)} Kg",
                            ),
                            InfoRow(
                              label: "Price/Kg",
                              value: formatPrice(selectedOffer.pricePerKg),
                            ),
                            InfoRow(
                              label: "Total",
                              value: formatPrice(selectedOffer.price),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Action buttons (Accept, Reject, Counter)
                      OfferActions(offer: selectedOffer, formKey: _formKey),
                      const SizedBox(height: 16),

                      // Conditional rendering for the Previous Counter-Offer
                      if (previous != null) ...[
                        const SectionHeader("Last Counter-Offer"),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.gray200),
                          ),
                          child: InfoTable(
                            rows: [
                              // Use the found previousCounterOffer data
                              InfoRow(
                                label: "Weight",
                                // ⚠️ FIX: Use toStringAsFixed for weights
                                value:
                                    "${previous.weight.toStringAsFixed(1)} Kg",
                              ),
                              InfoRow(
                                label: "Price",
                                // ⚠️ FIX: Use formatPrice for currency
                                value: formatPrice(previous.price),
                              ),
                              InfoRow(
                                label: "Price Per Kg",
                                // ⚠️ FIX: Use formatPrice for currency
                                value: formatPrice(previous.pricePerKg),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// --- OfferHeader (Updated to use the fetched Buyer data) ---
class OfferHeader extends StatelessWidget {
  final Offer offer;
  final Buyer? buyer; // NEW: The fetched buyer details

  const OfferHeader({super.key, required this.offer, this.buyer});

  @override
  Widget build(BuildContext context) {
    // Safely access data from the fetched Buyer, falling back to basic Offer fields
    // if the Buyer data could not be found (e.g., deleted account, DB error)
    final clientName = buyer?.name ?? 'Buyer (ID: ${offer.buyerId})';
    final clientAvatar = buyer?.avatarUrl ?? "assets/images/user-profile.png";
    final clientRating = buyer?.rating ?? 0.0;
    final clientReviewCount = buyer?.reviewCount ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 30,
          // Use AssetImage if the avatar is a local path, NetworkImage otherwise
          backgroundImage: clientAvatar.startsWith('http')
              ? NetworkImage(clientAvatar) as ImageProvider
              : AssetImage(clientAvatar),
          onBackgroundImageError: (exception, stackTrace) =>
              const AssetImage("assets/images/user-profile.png"), // Fallback
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                clientName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textBlue,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: AppColors.shellOrange,
                    size: 16,
                  ),
                  Text(
                    clientRating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.textBlue,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    " ($clientReviewCount Reviews)",
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
