import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/value_objects/offer_terms.dart';
import 'package:siren_marketplace/core/domain/value_objects/price.dart';
import 'package:siren_marketplace/core/domain/value_objects/weight.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/providers/catch_providers.dart';
import 'package:siren_marketplace/core/providers/offer_providers.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/error_handling_circle_avatar.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/number_input_field.dart';
import 'package:siren_marketplace/core/widgets/page_title.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/buyer/presentation/widgets/product_image_carousel.dart';
import 'package:siren_marketplace/features/shared/presentation/providers/offer_actions_provider.dart';

class ProductDetails extends ConsumerStatefulWidget {
  const ProductDetails({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends ConsumerState<ProductDetails> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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

  void _showMakeOfferDialog(
    BuildContext context,
    Catch catchItem,
    String currentUserId,
  ) {
    _weightController.clear();
    _priceController.clear();
    _pricePerKgController.clear();

    // Prefill with the catch's current price per kg
    final initialPricePerKg = catchItem.pricePerKg.amountPerKg;
    _pricePerKgController.text = initialPricePerKg.toStringAsFixed(0);

    bool userEditingTotal = false;

    void updateTotalFromWeight() {
      if (userEditingTotal) return;
      final weight = double.tryParse(_weightController.text);
      final pricePerKg = int.tryParse(_pricePerKgController.text);
      if (weight != null && pricePerKg != null) {
        final total = weight * pricePerKg;
        _priceController.text = total.toStringAsFixed(0);
      }
    }

    void updatePricePerKgFromTotal() {
      final weight = double.tryParse(_weightController.text);
      final total = int.tryParse(_priceController.text);
      if (weight != null && weight > 0 && total != null) {
        final pricePerKg = total / weight;
        _pricePerKgController.text = pricePerKg.toStringAsFixed(0);
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
                final calculatedPricePerKg =
                    ((totalPrice * 1000) / weightInGrams).round();

                if (_pricePerKgController.text !=
                    calculatedPricePerKg.toString()) {
                  _pricePerKgController.text = calculatedPricePerKg.toString();
                }
              }
            }

            return Form(
              key: formKey,
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
                    Consumer(
                      builder: (context, ref, child) {
                        final actionState = ref.watch(offerActionsProvider);

                        return CustomButton(
                          title: "Send Offer",
                          disabled: actionState.isLoading,
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final weightInputKg = double.tryParse(
                                _weightController.text,
                              );
                              final totalPrice = int.tryParse(
                                _priceController.text,
                              );

                              if (weightInputKg != null && totalPrice != null) {
                                final weightInGrams = (weightInputKg * 1000)
                                    .round();

                                // Create offer using domain entities
                                final weight = Weight.fromGrams(weightInGrams);
                                final price = Price.fromAmount(totalPrice);
                                final terms = OfferTerms.create(
                                  totalPrice: price,
                                  weight: weight,
                                );

                                ref
                                    .read(offerActionsProvider.notifier)
                                    .createOffer(
                                      catchItem.id,
                                      currentUserId,
                                      catchItem.fisherId,
                                      terms,
                                    );

                                // Close dialog immediately or wait for success?
                                // Usually better to wait, but the dialog is blocking.
                                // I'll listen to state changes in the parent widget to close/show success.
                                // But here I'm inside a dialog.
                                // I can listen here too if I use Consumer.
                                // However, the success dialog is shown AFTER this one closes.
                                // So I'll just trigger the action. The listener in the main build method will handle success.
                                Navigator.of(dialogContext).pop();
                              }
                            }
                          },
                        );
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
    final catchAsync = ref.watch(catchProvider(widget.productId));
    final currentUserAsync = ref.watch(currentUserProvider);
    final buyerOffersAsync = ref.watch(buyerOffersProvider);

    // Listen for offer action results
    ref.listen(offerActionsProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
        );
      } else if (next.successMessage != null) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            return AlertDialog(
              title: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.textBlue,
                  border: Border.all(color: AppColors.textBlue, width: 2),
                ),
                child: const Icon(Icons.check, color: AppColors.textWhite),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    next.successMessage!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    title: "View Marketplace",
                    onPressed: () {
                      ctx.go("/buyer");
                    },
                  ),
                ],
              ),
            );
          },
        );
        // Reset state after showing success
        ref.read(offerActionsProvider.notifier).reset();
      }
    });

    return catchAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: Center(child: Text("Error loading product: $error")),
      ),
      data: (catchItem) {
        if (catchItem == null) {
          return Scaffold(
            appBar: AppBar(
              leading: const BackButton(),
              title: const Text("Details"),
            ),
            body: const Center(
              child: Text("Catch not found in marketplace listings."),
            ),
          );
        }

        return currentUserAsync.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stack) =>
              Scaffold(body: Center(child: Text("Error loading user: $error"))),
          data: (currentUser) {
            if (currentUser == null) {
              return const Scaffold(
                body: Center(child: Text("User not logged in")),
              );
            }

            // Check for pending offers
            final hasPendingOffer = buyerOffersAsync.maybeWhen(
              data: (offers) => offers.any(
                (offer) =>
                    offer.status == OfferStatus.pending &&
                    offer.catchId == catchItem.id &&
                    offer.buyerId == currentUser.id,
              ),
              orElse: () => false,
            );

            // Fetch fisher details
            final fisherAsync = ref.watch(userProvider(catchItem.fisherId));

            return Scaffold(
              appBar: AppBar(
                leading: const BackButton(),
                title: PageTitle(title: "Product Details"),
                centerTitle: true,
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(catchProvider(widget.productId));
                  ref.invalidate(buyerOffersProvider);
                  await Future.wait([
                    ref.read(catchProvider(widget.productId).future),
                    ref.read(buyerOffersProvider.future),
                  ]);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        // Images
                        ProductImagesCarousel(images: catchItem.images),

                        SectionHeader(catchItem.name),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gray100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.gray200),
                              ),
                              child: Center(
                                child: Text(
                                  formatPrice(catchItem.pricePerKg.amountPerKg),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.textBlue,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text("/Kg"),
                          ],
                        ),
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
                                label: "Market",
                                value: catchItem.market.capitalize(),
                              ),
                              if (catchItem.species.id == "prawns")
                                InfoRow(label: "Size", value: catchItem.size)
                              else
                                InfoRow(
                                  label: "Average Size",
                                  value: catchItem.size,
                                ),
                              InfoRow(
                                label: "Available",
                                value: catchItem.availableWeight.kilograms,
                              ),
                              InfoRow(
                                label: "Date Posted",
                                value: catchItem.datePosted
                                    .toIso8601String()
                                    .toFormattedDate(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                title: "Message",
                                onPressed: () {
                                  // Navigate to chat
                                  // context.push("/chat/${catchItem.fisherId}"); // Assuming chat route
                                },
                                bordered: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: CustomButton(
                                title: hasPendingOffer
                                    ? "Offer Pending"
                                    : "Make Offer",
                                onPressed: hasPendingOffer
                                    ? () {}
                                    : () => _showMakeOfferDialog(
                                        context,
                                        catchItem,
                                        currentUser.id,
                                      ),
                                disabled:
                                    catchItem.availableWeight.isZero ||
                                    hasPendingOffer,
                              ),
                            ),
                          ],
                        ),

                        const SectionHeader("Seller"),

                        fisherAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (_, __) => const SizedBox.shrink(),
                          data: (fisher) {
                            if (fisher == null) return const SizedBox.shrink();

                            return Material(
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                onTap: () {
                                  context.push("/buyer/reviews/${fisher.id}");
                                },
                                borderRadius: BorderRadius.circular(16),
                                splashColor: AppColors.blue700.withValues(
                                  alpha: 0.1,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ErrorHandlingCircleAvatar(
                                        avatarUrl: fisher.avatarUrl!,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              fisher.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                color: AppColors.textBlue,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: AppColors.shellOrange,
                                                  size: 16,
                                                ),
                                                Text(
                                                  fisher.rating.value
                                                      .toStringAsFixed(1),
                                                ),
                                                Text(
                                                  " (${fisher.reviewCount} Reviews)",
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
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
