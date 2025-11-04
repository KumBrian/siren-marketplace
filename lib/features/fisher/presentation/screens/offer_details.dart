import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/buyer/data/models/buyer.dart';
import 'package:siren_marketplace/features/fisher/logic/offers_bloc/offers_bloc.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/offer_actions.dart';
import 'package:siren_marketplace/features/user/logic/bloc/user_bloc.dart'; // Import for dialog helpers

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
  final UserRepository _userRepository = sl<UserRepository>();
  Future<OfferTransactionData>? _transactionDataFuture;

  @override
  void dispose() {
    super.dispose();
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

    return OfferTransactionData(buyer: buyer, previousDetails: previousDetails);
  }

  void _handleOfferAcceptSuccess(String orderId) {
    showActionSuccessDialog(
      context,
      message: 'Offer successfully accepted!',
      autoCloseSeconds: 2,
    );
  }

  bool _hasMarkedAsViewed = false;

  void _markOfferAsViewed(Offer offer, Role role) {
    if (role == Role.fisher &&
        offer.hasUpdateForFisher &&
        !_hasMarkedAsViewed) {
      context.read<OffersBloc>().add(MarkOfferAsViewed(offer, role));
      _hasMarkedAsViewed = true;
    }
  }

  void _dispatchGetOffer() {
    if (widget.offerId.isEmpty) return;
    context.read<OffersBloc>().add(GetOfferById(widget.offerId));
  }

  @override
  void initState() {
    super.initState();
    _dispatchGetOffer();
  }

  @override
  void didUpdateWidget(covariant FisherOfferDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offerId != widget.offerId) {
      _transactionDataFuture = null; // 🎯 Reset Future on ID change
      _dispatchGetOffer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        final Role? role = userState is UserLoaded ? userState.role : null;

        if (role == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return BlocConsumer<OffersBloc, OffersState>(
          listenWhen: (prev, curr) =>
              curr is OfferActionSuccess || curr is OfferActionFailure,
          listener: (context, offerState) {
            // Pop the loading dialog/modal for ANY action completion (Success or Failure)
            if (offerState is OfferActionSuccess ||
                offerState is OfferActionFailure) {
              if (Navigator.of(context).canPop()) {
                // This pop should dismiss the loading dialog shown by _handleAccept
                Navigator.of(context).pop();
              }
            }

            if (offerState is OfferActionSuccess) {
              if (offerState.action == 'Accept' &&
                  offerState.orderId != null &&
                  offerState.orderId!.isNotEmpty) {
                // ✅ This should run AFTER the loading dialog is popped
                _handleOfferAcceptSuccess(offerState.orderId!);
              }
            }
          },
          builder: (context, offersState) {
            if (offersState is OffersLoading || offersState is OffersInitial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // 🎯 FIX 2: Determine the selected offer based on current state
            final Offer? selectedOffer;

            if (offersState is OfferDetailsLoaded) {
              selectedOffer = offersState.offer;
            } else if (offersState is OfferActionSuccess) {
              // Get the offer from the success state after an action
              selectedOffer = offersState.updatedOffer;
            } else {
              selectedOffer = null;
            }

            // 2. Check for the specific details loaded state
            if (selectedOffer == null || selectedOffer.id != widget.offerId) {
              final errorMessage = offersState is OffersError
                  ? "Error loading offers: ${offersState.message}"
                  : "Offer with ID ${widget.offerId} not found or mismatch.";

              return Scaffold(
                appBar: AppBar(
                  leading: BackButton(onPressed: () => context.pop()),
                  title: const Text("Offer Details"),
                ),
                body: Center(child: Text(errorMessage)),
              );
            }

            // ✅ We have the selected offer
            final Offer currentOffer =
                selectedOffer; // Use the determined offer
            _markOfferAsViewed(currentOffer, role);

            if (_transactionDataFuture == null ||
                _transactionDataFuture!.hashCode != currentOffer.hashCode) {
              _transactionDataFuture = _loadTransactionData(currentOffer);
            }

            return FutureBuilder<OfferTransactionData>(
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
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SectionHeader("Current Offer"),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selectedOffer!.status.name.capitalize(),
                                  // Use actual status
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.getStatusColor(
                                      selectedOffer.status,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.only(left: 4),
                                  // Added margin
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white),
                                    color: AppColors.getStatusColor(
                                      selectedOffer.status,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

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
                        const SizedBox(height: 8),

                        // Action buttons (Accept, Reject, Counter)
                        OfferActions(offer: selectedOffer, formKey: _formKey),
                        selectedOffer.status == OfferStatus.rejected
                            ? Row(
                                spacing: 8,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppColors.fail500,
                                    size: 16,
                                  ),
                                  Expanded(
                                    child: Text(
                                      "You have declined this offer. The buyer has been informed.",
                                      softWrap: true,
                                      style: TextStyle(
                                        color: AppColors.fail500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),

                        // Buyer Details,
                        const SizedBox(height: 8),

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
                        const SizedBox(height: 8),
                        OfferHeader(offer: selectedOffer, buyer: buyer),
                      ],
                    ),
                  ),
                );
              },
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
