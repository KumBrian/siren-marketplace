import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/number_input_field.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';
import 'package:siren_marketplace/features/fisher/logic/catch_bloc/catch_bloc.dart';
import 'package:siren_marketplace/features/fisher/logic/offers_bloc/offers_bloc.dart';
import 'package:siren_marketplace/features/user/logic/user_bloc/user_bloc.dart';

class BuyerOfferDetails extends StatefulWidget {
  const BuyerOfferDetails({super.key, required this.offerId});

  final String offerId;

  @override
  State<BuyerOfferDetails> createState() => _BuyerOfferDetailsState();
}

class _BuyerOfferDetailsState extends State<BuyerOfferDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _pricePerKgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 🎯 Dispatch event to the unified OffersBloc
    context.read<OffersBloc>().add(LoadOfferDetails(widget.offerId));
  }

  // 🗑️ REMOVED: The local _hasMarkedAsViewed flag is no longer strictly needed,
  // as the logic will run only once in the listener when the state *changes* to loaded.

  // 🔑 REFACTORED: The logic for marking the offer as viewed.
  void _markOfferAsViewed(Offer offer, Role role, BuildContext context) {
    // Only proceed if we are the buyer and the offer actually needs an update.
    final shouldMark = role == Role.buyer && offer.hasUpdateForBuyer;

    if (shouldMark) {
      // Dispatch the MarkOfferAsViewed event.
      // The BLoC's internal logic will prevent unnecessary repository calls
      // if the flag is already cleared.
      context.read<OffersBloc>().add(MarkOfferAsViewed(offer, role));
    }
  }

  void _showMakeOfferDialog(BuildContext context, Catch c) {
    _weightController.clear();
    _priceController.clear();
    _pricePerKgController.clear();

    // Prefill with the catch's current price per kg
    final initialPricePerKg = c.pricePerKg; // must exist in your Catch model
    _pricePerKgController.text = initialPricePerKg.toStringAsFixed(2);

    bool userEditingTotal = false;

    void updateTotalFromWeight() {
      if (userEditingTotal) return; // prevent loop
      final weight = double.tryParse(_weightController.text);
      final pricePerKg = double.tryParse(_pricePerKgController.text);
      if (weight != null && pricePerKg != null) {
        final total = weight * pricePerKg;
        _priceController.text = total.toStringAsFixed(2);
      }
    }

    void updatePricePerKgFromTotal() {
      final weight = double.tryParse(_weightController.text);
      final total = double.tryParse(_priceController.text);
      if (weight != null && weight > 0 && total != null) {
        final pricePerKg = total / weight;
        _pricePerKgController.text = pricePerKg.toStringAsFixed(2);
      }
    }

    _weightController.addListener(() {
      updateTotalFromWeight();
    });

    _priceController.addListener(() {
      // mark manual edit of total
      userEditingTotal = true;
      updatePricePerKgFromTotal();
      // short delay to reset flag after editing burst
      Future.delayed(const Duration(milliseconds: 200), () {
        userEditingTotal = false;
      });
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        contentPadding: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        constraints: BoxConstraints(
          // Make it stretch proportionally on mobile and desktop
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          minWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        title: Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            // in case of small devices
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.textBlue),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      NumberInputField(
                        controller: _weightController,
                        label: "Weight",
                        role: Role.buyer,
                        suffix: "Kg",
                        validator: (value) {
                          final weight = double.tryParse(value ?? "");
                          if (weight == null || weight <= 0) {
                            return "Enter valid weight";
                          }
                          if (weight > c.availableWeight) {
                            return "Cannot exceed available weight";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      NumberInputField(
                        controller: _priceController,
                        label: "Total Price",
                        suffix: "CFA",
                        validator: (value) {
                          final price = double.tryParse(value ?? "");
                          if (price == null || price <= 0) {
                            return "Enter valid price";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      NumberInputField(
                        controller: _pricePerKgController,
                        label: "Price/Kg",
                        suffix: "CFA",
                        validator: (value) {
                          final pricePerKg = double.tryParse(value ?? "");
                          if (pricePerKg == null || pricePerKg <= 0) {
                            return "Enter valid price per kg";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, userState) {
                    final user = userState is UserLoaded
                        ? userState.user
                        : null;
                    return CustomButton(
                      title: "Send Offer",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final weight = double.tryParse(
                            _weightController.text,
                          );
                          final totalPrice = double.tryParse(
                            _priceController.text,
                          );
                          final pricePerKg = double.tryParse(
                            _pricePerKgController.text,
                          );

                          if (weight != null &&
                              totalPrice != null &&
                              pricePerKg != null) {
                            context.read<OffersBloc>().add(
                              CreateOffer(
                                catchId: c.id,
                                buyerId: user!.id,
                                fisherId: c.fisherId,
                                price: totalPrice,
                                weight: weight,
                                pricePerKg: pricePerKg,
                              ),
                            );
                            context.read<CatchesBloc>().add(LoadCatches());
                            context.pop();
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (ctx) {
                                Future.delayed(Duration(seconds: 2), () {
                                  if (ctx.mounted) Navigator.of(ctx).pop();
                                });

                                return AlertDialog(
                                  title: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.textBlue,
                                      border: Border.all(
                                        color: AppColors.textBlue,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: AppColors.textWhite,
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Offer sent successfully!",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: AppColors.textBlue,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
          listenWhen: (prev, curr) => curr is OffersLoaded,
          // Listen when list/detail updates
          listener: (context, offersState) {
            if (offersState is OffersLoaded &&
                offersState.selectedOffer != null) {
              _markOfferAsViewed(offersState.selectedOffer!, role, context);
            }
          },
          builder: (context, offersState) {
            final isDetailsLoading =
                offersState is OffersLoading ||
                (offersState is OffersLoaded &&
                    offersState.selectedOffer == null);

            if (isDetailsLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (offersState is OffersError) {
              return Scaffold(
                appBar: AppBar(leading: const BackButton()),
                body: Center(
                  child: Text(
                    'Error: ${offersState.message}',
                    style: const TextStyle(color: AppColors.fail500),
                  ),
                ),
              );
            }

            if (offersState is OffersLoaded) {
              final offer = offersState.selectedOffer;
              final catchSnapshot = offersState.selectedCatch;
              final fisher = offersState.selectedFisher;

              if (offer == null || catchSnapshot == null || fisher == null) {
                return Scaffold(
                  appBar: AppBar(leading: const BackButton()),
                  body: const Center(child: Text("Offer details missing.")),
                );
              }

              // 🗑️ REMOVED: Calling _markOfferAsViewed here, as it's now in the listener.

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
                      BuyerOfferHeader(
                        offer: offer,
                        catchSnapshot: catchSnapshot,
                      ),
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
                              value:
                                  "${offer.pricePerKg.toStringAsFixed(0)} CFA",
                            ),
                            InfoRow(
                              label: "Total",
                              value: "${offer.price.toStringAsFixed(0)} CFA",
                            ),
                          ],
                        ),
                      ),

                      if (offer.waitingFor == Role.buyer) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            title: "Counter Offer",
                            icon: Icons.autorenew,
                            onPressed: () {},
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      FisherDetails(fisher: fisher),
                      const SizedBox(height: 16),

                      // --- ACTION BUTTONS SECTION ---
                      if (offer.status == OfferStatus.rejected) ...[
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            title: "Marketplace",
                            onPressed: () {},
                            icon: Icons.storefront,
                            bordered: true,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            title: "Make New Offer",
                            onPressed: () =>
                                _showMakeOfferDialog(context, catchSnapshot),
                          ),
                        ),
                      ],

                      if (offer.status == OfferStatus.accepted ||
                          offer.status == OfferStatus.pending) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            title: "Call Seller",
                            onPressed: () {},
                            hugeIcon: HugeIcons.strokeRoundedCall02,
                            bordered: true,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            title: "Message Seller",
                            onPressed: () {},
                            icon: CustomIcons.chatbubble,
                          ),
                        ),
                      ],

                      if (offer.status == OfferStatus.completed) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            title: "Rate the fisher",
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                ),
                                builder: (context) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(
                                        context,
                                      ).viewInsets.bottom,
                                      left: 16,
                                      right: 16,
                                      top: 24,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: context.pop,
                                              icon: const Icon(Icons.close),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              "Give a Review",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24,
                                                color: AppColors.textBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: List.generate(5, (index) {
                                              return const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 4.0,
                                                ),
                                                child: Icon(
                                                  Icons.star,
                                                  size: 32,
                                                  color: AppColors.shellOrange,
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        const TextField(
                                          maxLines: 4,
                                          decoration: InputDecoration(
                                            hintText: "Write a review...",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(16),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: CustomButton(
                                            title: "Submit Review",
                                            onPressed: () {},
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],

                      // OfferActions(offer: offer, formKey: _formKey, role: role),
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
                              InfoRow(
                                label: "Weight",
                                value: "${offer.previousWeight} Kg",
                              ),
                              InfoRow(
                                label: "Price",
                                value: formatPrice(offer.previousPrice!),
                              ),
                              InfoRow(
                                label: "Price Per Kg",
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
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}

// --- Component classes (BuyerOfferHeader, FisherDetails) remain unchanged ---
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
