import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/utils/phone_launcher.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/error_handling_circle_avatar.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/number_input_field.dart';
import 'package:siren_marketplace/core/widgets/offer_actions.dart';
import 'package:siren_marketplace/core/widgets/page_title.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/new_core/domain/entities/catch.dart';
import 'package:siren_marketplace/new_core/domain/entities/offer.dart';
import 'package:siren_marketplace/new_core/domain/entities/user.dart';
import 'package:siren_marketplace/new_core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/new_core/domain/enums/user_role.dart';
import 'package:siren_marketplace/new_features/fisher/presentation/cubits/offer_detail/offer_detail_cubit.dart';
import 'package:siren_marketplace/new_features/fisher/presentation/cubits/offer_detail/offer_detail_state.dart';

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
  void dispose() {
    _weightController.dispose();
    _priceController.dispose();
    _pricePerKgController.dispose();
    super.dispose();
  }

  void _showMakeOfferDialog(BuildContext context, Catch catchItem) {
    _weightController.clear();
    _priceController.clear();
    _pricePerKgController.clear();

    final initialPricePerKg = catchItem.pricePerKg.amountPerKg;
    _pricePerKgController.text = initialPricePerKg.toStringAsFixed(0);

    bool userEditingTotal = false;

    void updateTotalFromWeight() {
      if (userEditingTotal) return;
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
      userEditingTotal = true;
      updatePricePerKgFromTotal();
      Future.delayed(const Duration(milliseconds: 200), () {
        userEditingTotal = false;
      });
    });

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        contentPadding: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          minWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        title: Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            void updateCalculations(String _) {
              final weightInputKg =
                  double.tryParse(_weightController.text) ?? 0.0;
              final totalPrice = int.tryParse(_priceController.text) ?? 0;
              final weightInGrams = (weightInputKg * 1000).round();

              if (weightInGrams > 0 && totalPrice > 0) {
                final calcPricePerKg = ((totalPrice * 1000) / weightInGrams)
                    .round();
                if (_pricePerKgController.text != calcPricePerKg.toString()) {
                  _pricePerKgController.text = calcPricePerKg.toString();
                }
              }
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
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
                            role: UserRole.buyer,
                            suffix: "Kg",
                            onChanged: updateCalculations,
                            validator: (value) {
                              final weightInputKg = double.tryParse(
                                value ?? "",
                              );
                              if (weightInputKg == null || weightInputKg <= 0) {
                                return "Enter valid weight";
                              }
                              final weightInGrams = (weightInputKg * 1000)
                                  .round();
                              if (weightInGrams >
                                  catchItem.availableWeight.grams) {
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
                            decimal: false,
                            onChanged: updateCalculations,
                            validator: (value) {
                              final price = int.tryParse(value ?? "");
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
                            decimal: false,
                            validator: (value) {
                              final pricePerKg = int.tryParse(value ?? "");
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
                    CustomButton(
                      title: "Send Offer",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final weightInputKg = double.tryParse(
                            _weightController.text,
                          );
                          final totalPrice = int.tryParse(
                            _priceController.text,
                          );
                          final pricePerKg = int.tryParse(
                            _pricePerKgController.text,
                          );

                          if (weightInputKg != null &&
                              totalPrice != null &&
                              pricePerKg != null) {
                            final weightInGrams = (weightInputKg * 1000)
                                .round();

                            // TODO: Implement create offer functionality
                            // This would need to be added to OfferDetailCubit
                            Navigator.of(dialogContext).pop();

                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (ctx) {
                                Future.delayed(const Duration(seconds: 2), () {
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
                                  content: const Text(
                                    "Offer sent successfully!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: AppColors.textBlue,
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

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
              title: const PageTitle(title: "Offer Details"),
            ),
            body: Center(child: Text('Error: ${state.message}')),
          );
        }

        if (state is OfferDetailLoaded) {
          final offer = state.offer;
          final catchItem = state.relatedCatch;
          final fisher = state.counterparty;

          final hasPreviousTerms = offer.previousTerms != null;

          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop()),
              title: const PageTitle(title: "Offer Details"),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BuyerOfferHeader(
                    offer: offer,
                    catchName: catchItem.name,
                    catchImage: catchItem.images.isNotEmpty
                        ? catchItem.images[0]
                        : '',
                  ),
                  const SizedBox(height: 16),

                  if (offer.waitingFor == UserRole.buyer) ...[
                    const SectionHeader("Fisherman's Offer"),
                  ],

                  if (offer.waitingFor == UserRole.fisher) ...[
                    const SectionHeader("Current Offer"),
                  ],

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
                          value: formatWeight(offer.currentTerms.weight.grams),
                        ),
                        InfoRow(
                          label: "Price Per Kg",
                          value:
                              "${offer.currentTerms.pricePerKg.amountPerKg.toStringAsFixed(0)} CFA",
                        ),
                        InfoRow(
                          label: "Total",
                          value:
                              "${offer.currentTerms.totalPrice.amount.toStringAsFixed(0)} CFA",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  OfferActions(
                    offer: offer,
                    formKey: _formKey,
                    currentUserRole: UserRole.buyer,
                    catchItem: catchItem,
                    onNavigateToOrder: (orderId) {
                      context.push("/buyer/order-details/$orderId");
                    },
                  ),
                  const SizedBox(height: 16),

                  if (hasPreviousTerms) ...[
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
                            value: formatWeight(
                              offer.previousTerms!.weight.grams,
                            ),
                          ),
                          InfoRow(
                            label: "Price",
                            value: formatPrice(
                              offer.previousTerms!.totalPrice.amount.toInt(),
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
                    const SizedBox(height: 16),
                  ],

                  FisherDetails(fisher: fisher),
                  const SizedBox(height: 16),

                  if (offer.status == OfferStatus.rejected) ...[
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        title: "Marketplace",
                        onPressed: () {
                          context.go("/buyer");
                        },
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
                            _showMakeOfferDialog(context, catchItem),
                      ),
                    ),
                  ],

                  if (offer.status == OfferStatus.accepted) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        title: "Call Seller",
                        onPressed: () {
                          // TODO: Use fisher's actual phone number
                          makePhoneCall('651204966', context);
                        },
                        hugeIcon: HugeIcons.strokeRoundedCall02,
                        bordered: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        title: "Message Seller",
                        onPressed: () => context.push("/buyer/chat"),
                        icon: CustomIcons.chatbubble,
                      ),
                    ),
                  ],

                  // Note: OfferStatus.completed doesn't exist in new enum
                  // Completed offers would be handled as orders
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }

        return const Scaffold(body: Center(child: Text("Unexpected state")));
      },
    );
  }
}

class BuyerOfferHeader extends StatelessWidget {
  final Offer offer;
  final String catchName;
  final String catchImage;

  const BuyerOfferHeader({
    super.key,
    required this.offer,
    required this.catchName,
    required this.catchImage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            if (catchImage.isEmpty) return;

            final provider =
                (catchImage.contains("http")
                        ? NetworkImage(catchImage)
                        : AssetImage(catchImage))
                    as ImageProvider;

            showImageViewer(
              context,
              provider,
              swipeDismissible: true,
              immersive: true,
              useSafeArea: true,
              doubleTapZoomable: true,
              backgroundColor: Colors.black.withValues(alpha: .4),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: catchImage.isNotEmpty
                ? Image.network(
                    catchImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      "assets/images/shrimp.jpg",
                      height: 60,
                      width: 60,
                    ),
                  )
                : Image.asset(
                    "assets/images/shrimp.jpg",
                    height: 60,
                    width: 60,
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                catchName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textBlue,
                ),
              ),
              const SizedBox(height: 8),
              Row(
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
                    offer.status.displayName.capitalize(),
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
  final User? fisher;

  const FisherDetails({super.key, required this.fisher});

  @override
  Widget build(BuildContext context) {
    final String avatarUrl =
        fisher?.avatarUrl ?? "assets/images/user-profile.png";
    final String name = fisher?.name ?? "Unknown Fisher";
    final double rating = fisher?.rating.value ?? 0.0;
    final int reviewCount = fisher?.reviewCount ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        const SectionHeader("Seller"),
        Material(
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () {
              if (fisher != null) {
                context.push("/buyer/reviews/${fisher!.id}");
              }
            },
            borderRadius: BorderRadius.circular(16),
            splashColor: AppColors.blue700.withValues(alpha: 0.1),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ErrorHandlingCircleAvatar(avatarUrl: avatarUrl),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
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
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppColors.textBlue,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              " ($reviewCount Reviews)",
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
        ),
      ],
    );
  }
}
