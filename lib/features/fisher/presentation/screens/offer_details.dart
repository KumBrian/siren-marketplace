import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/widgets/error_handling_circle_avatar.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/offer_actions.dart';
import 'package:siren_marketplace/core/widgets/page_title.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/new_core/domain/entities/offer.dart';
import 'package:siren_marketplace/new_core/domain/entities/user.dart';
import 'package:siren_marketplace/new_core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/new_core/domain/enums/user_role.dart';
import 'package:siren_marketplace/new_features/fisher/presentation/cubits/offer_detail/offer_detail_cubit.dart';
import 'package:siren_marketplace/new_features/fisher/presentation/cubits/offer_detail/offer_detail_state.dart';

class FisherOfferDetails extends StatefulWidget {
  const FisherOfferDetails({super.key, required this.offerId});

  final String offerId;

  @override
  State<FisherOfferDetails> createState() => _FisherOfferDetailsState();
}

class _FisherOfferDetailsState extends State<FisherOfferDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OfferDetailCubit, OfferDetailState>(
      builder: (context, state) {
        if (state is OfferDetailLoading || state is OfferDetailInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is OfferDetailError) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop()),
              title: const Text("Offer Details"),
            ),
            body: Center(child: Text('Error: ${state.message}')),
          );
        }

        if (state is OfferDetailLoaded) {
          final offer = state.offer;
          final catch_ = state.relatedCatch;
          final buyer = state.counterparty;

          // Get previous offer terms if they exist
          final hasPreviousTerms = offer.previousTerms != null;

          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop()),
              title: const PageTitle(title: "Offer Details"),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                spacing: 16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Catch Image and Details Section
                  Row(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (catch_.images.isEmpty) return;

                          final ImageProvider imageProvider =
                              catch_.images[0].startsWith('http')
                              ? NetworkImage(catch_.images[0]) as ImageProvider
                              : AssetImage(catch_.images[0]);

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
                          child: catch_.images.isNotEmpty
                              ? (catch_.images[0].startsWith('http')
                                    ? Image.network(
                                        catch_.images[0],
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
                                        catch_.images[0],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ))
                              : Image.asset(
                                  "assets/images/prawns.jpg",
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              catch_.name,
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
                                  offer.dateCreated
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
                            offer.status.name.capitalize(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.getStatusColor(offer.status),
                            ),
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.only(left: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white),
                              color: AppColors.getStatusColor(offer.status),
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
                          value: formatWeight(offer.currentTerms.weight.grams),
                        ),
                        InfoRow(
                          label: "Price/Kg",
                          value: formatPrice(
                            offer.currentTerms.pricePerKg.amountPerKg,
                          ),
                        ),
                        InfoRow(
                          label: "Total",
                          value: formatPrice(
                            offer.currentTerms.totalPrice.amount,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Offer Actions Section
                  OfferActions(
                    offer: offer,
                    formKey: _formKey,
                    currentUserRole: UserRole.fisher,
                    catchItem: catch_,
                    onNavigateToOrder: (orderId) {
                      context.pushReplacement("/fisher/order-details/$orderId");
                    },
                  ),

                  // Rejection Message
                  if (offer.status == OfferStatus.rejected)
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
                  if (hasPreviousTerms) ...[
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
                            value: formatWeight(
                              offer.previousTerms!.weight.grams,
                            ),
                          ),
                          InfoRow(
                            label: "Price",
                            value: formatPrice(
                              offer.previousTerms!.totalPrice.amount,
                            ),
                          ),
                          InfoRow(
                            label: "Price Per Kg",
                            value: formatPrice(
                              offer.previousTerms!.pricePerKg.amountPerKg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Buyer Info Section
                  OfferHeader(offer: offer, buyer: buyer),
                ],
              ),
            ),
          );
        }

        return const Scaffold(backgroundColor: AppColors.white100);
      },
    );
  }
}

/// Displays the buyer's name, rating, and avatar.
class OfferHeader extends StatelessWidget {
  final Offer offer;
  final User buyer;

  const OfferHeader({super.key, required this.offer, required this.buyer});

  @override
  Widget build(BuildContext context) {
    final clientName = buyer.name;
    final clientAvatar = buyer.avatarUrl ?? "assets/images/user-profile.png";
    final clientRating = buyer.rating.value;
    final clientReviewCount = buyer.reviewCount;

    return Material(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          context.push("/buyer/reviews/${buyer.id}");
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
