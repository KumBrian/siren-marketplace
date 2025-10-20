import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/buyer/logic/buyer_offer_details_bloc/offer_details_bloc.dart';
import 'package:siren_marketplace/features/buyer/presentation/widgets/offer_actions.dart';
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';

class BuyerOfferDetails extends StatefulWidget {
  const BuyerOfferDetails({super.key, required this.offerId});

  final String offerId;

  @override
  State<BuyerOfferDetails> createState() => _BuyerOfferDetailsState();
}

class _BuyerOfferDetailsState extends State<BuyerOfferDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // 🆕 CORRECTED: Dispatch the LoadOfferDetails event to the BLoC
    context.read<OfferDetailsBloc>().add(LoadOfferDetails(widget.offerId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OfferDetailsBloc, OfferDetailsState>(
      builder: (context, state) {
        // 1. Handle Loading/Error States
        if (state is OfferDetailsLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is OfferDetailsError) {
          return Scaffold(
            appBar: AppBar(leading: const BackButton()),
            body: Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: AppColors.fail500),
              ),
            ),
          );
        }

        // 3. Handle Offer Not Found / Load success
        if (state is! OfferDetailsLoaded) {
          return Scaffold(
            appBar: AppBar(
              leading: const BackButton(),
              title: const Text("Offer Details"),
            ),
            body: const Center(
              child: Text(
                "Offer not found or data missing.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        // 4. Extract required objects from the loaded state
        final offer = state.offer;
        final catchSnapshot = state.catchItem; // Full Catch model
        final fisher = state.fisher; // Full Fisher model

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
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Components correctly receive the separate models
                BuyerOfferHeader(offer: offer, catchSnapshot: catchSnapshot),
                const SizedBox(height: 16),

                const SectionHeader("Current Offer"),
                const SizedBox(height: 16),
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
                        value: "${offer.weight.toStringAsFixed(1)} Kg",
                      ),
                      InfoRow(
                        label: "Price Per Kg",
                        value: "${offer.pricePerKg.toStringAsFixed(0)} CFA",
                      ),
                      InfoRow(
                        label: "Total",
                        value: "${offer.price.toStringAsFixed(0)} CFA",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                FisherDetails(fisher: fisher),
                const SizedBox(height: 16),

                OfferActions(offer: offer, formKey: _formKey),
                const SizedBox(height: 16),

                if (offer.previousPrice != null &&
                    offer.previousWeight != null) ...[
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
                          value: "${offer.previousWeight} Kg",
                        ),
                        InfoRow(
                          label: "Price",
                          value: formatPrice(offer.previousPrice!),
                        ),
                        InfoRow(
                          label: "Price Per Kg",
                          // ⚠️ FIX: Use formatPrice for currency
                          value: formatPrice(offer.previousPricePerKg!),
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
  }
}

// --- Component Updates (No change needed, they are already correct) ---

class BuyerOfferHeader extends StatelessWidget {
  final Offer offer;
  final Catch catchSnapshot;

  const BuyerOfferHeader({
    super.key,
    required this.offer,
    required this.catchSnapshot,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            final providers = catchSnapshot.images.map<ImageProvider>((img) {
              return img.contains("http") ? NetworkImage(img) : AssetImage(img);
            }).toList();
            final multiImageProvider = MultiImageProvider(providers);

            showImageViewerPager(
              context,
              multiImageProvider,
              swipeDismissible: true,
              immersive: true,
              useSafeArea: true,
              doubleTapZoomable: true,
              backgroundColor: Colors.black.withValues(alpha: .4),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              catchSnapshot.images.first,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
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
                catchSnapshot.name,
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
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white),
                      color: AppColors.getStatusColor(offer.status),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    offer.status.name.capitalize(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getStatusColor(offer.status),
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

class FisherDetails extends StatelessWidget {
  final Fisher fisher;

  const FisherDetails({super.key, required this.fisher});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: fisher.avatarUrl.contains("http")
              ? NetworkImage(fisher.avatarUrl)
              : AssetImage(fisher.avatarUrl),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fisher.name,
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
                    fisher.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.textBlue,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    " (${fisher.reviewCount} Reviews)",
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
