import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/buyer/data/models/buyer.dart';
import 'package:siren_marketplace/features/fisher/data/offer_repositories.dart';
import 'package:siren_marketplace/features/fisher/logic/catch_bloc/catch_bloc.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/offer_actions.dart';

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

// NEW: Data structure to hold data dependencies for the UI
class OfferTransactionData {
  final Buyer? buyer;
  final Offer? previousOffer;

  const OfferTransactionData({this.buyer, this.previousOffer});
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
  final UserRepository _userRepository = UserRepository();
  final OfferRepository _offerRepository = OfferRepository();

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
    // 1. Fetch Buyer Details

    // 🆕 Use the raw map retrieval method
    final Map<String, dynamic>? buyerMap = await _userRepository.getUserMapById(
      offer.buyerId,
    );

    Buyer? buyer;
    if (buyerMap != null) {
      // 🆕 Use the clean Buyer.fromMap factory to assemble the model
      buyer = Buyer.fromMap(buyerMap);

      // NOTE: This factory should handle populating base AppUser fields.
      // If you need the Buyer with default empty lists, Buyer.fromMap does this.
    }

    // 2. Fetch Previous Counter Offer (MUST use raw map and conversion)
    Offer? previousOffer;
    if (offer.previousOfferId != null) {
      // 🆕 Use getOfferMapById to fetch the raw map
      final previousOfferMap = await _offerRepository.getOfferMapById(
        offer.previousOfferId!,
      );

      if (previousOfferMap != null) {
        // ⚠️ ASSUMPTION: Offer.fromMap can assemble the model from the map.
        // This is correct as per your new repository pattern.
        previousOffer = Offer.fromMap(previousOfferMap);
      }
    }

    return OfferTransactionData(buyer: buyer, previousOffer: previousOffer);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Listen to the CatchesBloc for the current Offer data
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

        // 2. Use FutureBuilder to fetch dependent data (Buyer, Previous Offer)
        return FutureBuilder<OfferTransactionData>(
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
            final Offer? previousCounterOffer = transactionData?.previousOffer;

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
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
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

                    // Action buttons (Accept, Reject, Counter)
                    OfferActions(offer: selectedOffer, formKey: _formKey),
                    const SizedBox(height: 16),

                    // Conditional rendering for the Previous Counter-Offer
                    if (previousCounterOffer != null) ...[
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
                              value:
                                  "${previousCounterOffer.weight.toInt()} Kg",
                            ),
                            InfoRow(
                              label: "Price",
                              value:
                                  "${previousCounterOffer.price.toInt()} CFA",
                            ),
                            InfoRow(
                              label: "Price Per Kg",
                              value:
                                  "${previousCounterOffer.pricePerKg.toInt()} CFA",
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
