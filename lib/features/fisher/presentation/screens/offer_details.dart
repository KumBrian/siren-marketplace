import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/repositories/i_catch_repository.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/enum.dart' hide OfferStatus;
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/widgets/error_handling_circle_avatar.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/offer_actions.dart';
import 'package:siren_marketplace/core/widgets/page_title.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/buyer/data/models/buyer.dart';
import 'package:siren_marketplace/features/fisher/new_logic/offers_bloc/offers_cubit.dart';
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

/// Holds the necessary transaction details for display.
class OfferTransactionData {
  final Buyer? buyer;
  final Catch catchItem;

  const OfferTransactionData({this.buyer, required this.catchItem});
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
  final ICatchRepository _catchRepository = sl<ICatchRepository>();
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

    final Catch? catchItem = await _catchRepository.getById(offer.catchId);

    return OfferTransactionData(buyer: buyer, catchItem: catchItem!);
  }

  void _markOfferAsViewed(Offer offer, Role role) {
    if (role == Role.fisher &&
        offer.hasUpdateForFisher &&
        !_hasMarkedAsViewed) {
      context.read<OffersCubit>().markOfferAsViewed(offer.id, UserRole.fisher);
      _hasMarkedAsViewed = true;
    }
  }

  void _dispatchGetOffer() {
    if (widget.offerId.isEmpty) return;
    context.read<OffersCubit>().loadById(widget.offerId);
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
      _hasMarkedAsViewed = false;
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

        return BlocConsumer<OffersCubit, OffersState>(
          listenWhen: (prev, curr) =>
              curr.updatedOffer != null || curr.order != null,
          listener: (context, offerState) {
            // Handle Accept success: Show final dialog and prepare navigation
            if (offerState.order != null) {
              final orderId = offerState.order!.id;

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
            if (offerState.updatedOffer != null && offerState.order == null) {
              final updatedOffer = offerState.updatedOffer!;
              String message = '';

              if (updatedOffer.status == OfferStatus.rejected) {
                message = 'Offer Rejected!';
              } else if (updatedOffer.status == OfferStatus.pending) {
                message = 'Counter-Offer Sent!';
              }

              if (message.isNotEmpty) {
                showActionSuccessDialog(
                  context,
                  message: message,
                  autoCloseSeconds: 3,
                );
              }
            }
          },
          builder: (context, offersState) {
            if (offersState.loading && offersState.offers.isEmpty) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Get the offer from state
            final Offer? selectedOffer =
                offersState.offers.firstWhereOrNull(
                  (o) => o.id == widget.offerId,
                ) ??
                offersState.updatedOffer;

            if (selectedOffer == null) {
              final errorMessage =
                  offersState.error ??
                  "Offer with ID ${widget.offerId} not found.";

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
              future: _transactionDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final transactionData = snapshot.data;
                final Buyer? buyer = transactionData?.buyer;
                final Catch catchSnapshot = transactionData!.catchItem;

                // Get catch image and name
                final catchImageUrl = catchSnapshot.images.isNotEmpty == true
                    ? catchSnapshot.images.first
                    : "assets/images/prawns.jpg";
                final catchName =
                    catchSnapshot?.species.name ?? "Unknown Catch";

                return Scaffold(
                  appBar: AppBar(
                    leading: BackButton(onPressed: () => context.pop()),
                    title: const PageTitle(title: "Offer Details"),
                  ),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      spacing: 16, // Main section spacing increased for clarity
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Catch Image and Details Section
                        Row(
                          spacing: 10, // Replaces SizedBox(width: 10)
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                final ImageProvider imageProvider =
                                    catchImageUrl.startsWith('http')
                                    ? NetworkImage(catchImageUrl)
                                          as ImageProvider
                                    : AssetImage(catchImageUrl);

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
                                child: catchImageUrl.startsWith('http')
                                    ? Image.network(
                                        catchImageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                                  "assets/images/prawns.jpg",
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                      )
                                    : Image.asset(
                                        catchImageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                spacing: 8,
                                // Replaces SizedBox(height: 8)
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    catchName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: AppColors.textBlue,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        selectedOffer.dateCreated
                                            .toIso8601String()
                                            .toFormattedDate(),
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

                        // Current Offer Header and Status
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

                        // Current Offer Details Box
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
                                    "${selectedOffer.currentTerms.weight.kilograms} kg",
                              ),
                              InfoRow(
                                label: "Price/Kg",
                                value: formatPrice(
                                  selectedOffer
                                      .currentTerms
                                      .pricePerKg
                                      .amountPerKg,
                                ),
                              ),
                              InfoRow(
                                label: "Total",
                                value: formatPrice(
                                  selectedOffer.currentTerms.totalPrice.amount,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Offer Actions Section
                        if (selectedOffer.status != OfferStatus.rejected)
                          OfferActions(
                            offer: selectedOffer,
                            formKey: _formKey,
                            currentUserRole: UserRole.fisher,
                            catchItem: catchSnapshot,
                            onNavigateToOrder: (orderId) {
                              context.pushReplacement(
                                "/fisher/order-details/$orderId",
                              );
                            },
                          ),

                        // Rejection Message
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
                          ),

                        // Previous Counter-Offer Details
                        if (selectedOffer.previousTerms != null) ...[
                          const SectionHeader("Last Counter-Offer"),

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
                                      "${selectedOffer.previousTerms!.weight.kilograms} kg",
                                ),
                                InfoRow(
                                  label: "Price",
                                  value: formatPrice(
                                    selectedOffer
                                        .previousTerms!
                                        .totalPrice
                                        .amount,
                                  ),
                                ),
                                InfoRow(
                                  label: "Price Per Kg",
                                  value: formatPrice(
                                    selectedOffer
                                        .previousTerms!
                                        .pricePerKg
                                        .amountPerKg,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Offer Header / Buyer Info Section
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

    return Material(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          context.push("/buyer/reviews/${buyer?.id}");
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.blue700.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
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
          ),
        ),
      ),
    );
  }
}
