import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/widgets/error_handling_circle_avatar.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/offer_actions.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/buyer/data/models/buyer.dart';
import 'package:siren_marketplace/features/fisher/data/catch_repository.dart';
import 'package:siren_marketplace/features/fisher/logic/offers_bloc/offers_bloc.dart';
import 'package:siren_marketplace/features/user/logic/user_bloc/user_bloc.dart';

/// Helper extension to find the first element matching a test, or return null.
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

class OfferTransactionData {
  final Buyer? buyer;
  final Catch? catchSnapshot;
  final PreviousOfferDetails? previousDetails;

  const OfferTransactionData({
    this.buyer,
    this.previousDetails,
    this.catchSnapshot,
  });
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
  bool _hasMarkedAsViewed = false;

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

    final Catch? catchSnapshot = await sl<CatchRepository>().getCatchById(
      offer.catchId,
    );

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

    return OfferTransactionData(
      buyer: buyer,
      catchSnapshot: catchSnapshot,
      previousDetails: previousDetails,
    );
  }

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
      // Reset Future and fetch data on ID change
      _transactionDataFuture = null;
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
            // Dismiss the loading dialog for ANY action completion (Success or Failure)
            if (offerState is OfferActionSuccess ||
                offerState is OfferActionFailure) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            }

            // Handle Accept success: Show final dialog and prepare navigation
            if (offerState is OfferActionSuccess) {
              if (offerState.action == 'Accept' &&
                  offerState.orderId != null &&
                  offerState.orderId!.isNotEmpty) {
                final orderId = offerState.orderId!;

                showActionSuccessDialog(
                  context,
                  message: "Offer Successfully Accepted.",
                  actionTitle: "View Details",
                  onAction: () {
                    context.pushReplacement("/fisher/order-details/$orderId");
                  },
                );
              }

              // Handle Reject/Counter success: Show dialog without navigation
              String message = '';
              if (offerState.action == 'Reject') {
                message = 'Offer Rejected!';
              } else if (offerState.action == 'Counter') {
                message = 'Counter-Offer Sent!';
              }

              if (message.isNotEmpty && offerState.action != 'Accept') {
                showActionSuccessDialog(
                  context,
                  message: message,
                  autoCloseSeconds: 3,
                );
              }
            }
          },
          builder: (context, offersState) {
            if (offersState is OffersLoading || offersState is OffersInitial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final Offer? selectedOffer;

            if (offersState is OfferDetailsLoaded) {
              selectedOffer = offersState.offer;
            } else if (offersState is OfferActionSuccess) {
              selectedOffer = offersState.updatedOffer;
            } else {
              selectedOffer = null;
            }

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

            final Offer currentOffer = selectedOffer;
            _markOfferAsViewed(currentOffer, role);

            // Re-fetch transaction data if the underlying offer changed
            if (_transactionDataFuture == null ||
                _transactionDataFuture!.hashCode != currentOffer.hashCode) {
              _transactionDataFuture = _loadTransactionData(currentOffer);
            }

            return FutureBuilder<OfferTransactionData>(
              key: ValueKey('${selectedOffer.id}-${selectedOffer.dateCreated}'),
              future: _loadTransactionData(selectedOffer),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final transactionData = snapshot.data;
                final Buyer? buyer = transactionData?.buyer;
                final Catch? catchSnapshot = transactionData?.catchSnapshot;
                final PreviousOfferDetails? previous =
                    transactionData?.previousDetails;

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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                final ImageProvider imageProvider =
                                    selectedOffer!.catchImageUrl.startsWith(
                                      'http',
                                    )
                                    ? NetworkImage(selectedOffer.catchImageUrl)
                                          as ImageProvider
                                    : AssetImage(selectedOffer.catchImageUrl);

                                showImageViewer(
                                  context,
                                  imageProvider,
                                  swipeDismissible: true,
                                  immersive: true,
                                  useSafeArea: true,
                                  doubleTapZoomable: true,
                                  backgroundColor: Colors.black.withValues(
                                    alpha: 0.4,
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  selectedOffer!.catchImageUrl,
                                  // Use the safely determined URL
                                  // Use Catch image URL
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                        "assets/images/prawns.jpg",
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    selectedOffer.catchName, // Use Catch name
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: AppColors.textBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        selectedOffer.dateCreated
                                            .toFormattedDate(),
                                        // Use actual status
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.gray650,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SectionHeader("Current Offer"),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selectedOffer.status.name.capitalize(),
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

                        OfferActions(
                          offer: selectedOffer,
                          formKey: _formKey,
                          currentUserRole: Role.fisher,
                          catchItem: catchSnapshot!,
                          onNavigateToOrder: (offerId) {
                            context.pushReplacement(
                              "/fisher/order-details/$offerId",
                            );
                          },
                        ),

                        if (selectedOffer.status == OfferStatus.rejected)
                          Row(
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
                        else
                          const SizedBox.shrink(),

                        const SizedBox(height: 8),

                        // Display previous counter-offer details if available
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
                                InfoRow(
                                  label: "Weight",
                                  value:
                                      "${previous.weight.toStringAsFixed(1)} Kg",
                                ),
                                InfoRow(
                                  label: "Price",
                                  value: formatPrice(previous.price),
                                ),
                                InfoRow(
                                  label: "Price Per Kg",
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

/// Displays the buyer's name, rating, and avatar.
class OfferHeader extends StatelessWidget {
  final Offer offer;
  final Buyer? buyer;

  const OfferHeader({super.key, required this.offer, this.buyer});

  @override
  Widget build(BuildContext context) {
    // Safely access buyer data with fallbacks
    final clientName = buyer?.name ?? 'Buyer (ID: ${offer.buyerId})';
    final clientAvatar = buyer?.avatarUrl ?? "assets/images/user-profile.png";
    final clientRating = buyer?.rating ?? 0.0;
    final clientReviewCount = buyer?.reviewCount ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ErrorHandlingCircleAvatar(avatarUrl: clientAvatar),
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
