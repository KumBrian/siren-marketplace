import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/services/session_service.dart';
import 'package:siren_marketplace/core/domain/value_objects/offer_terms.dart';
import 'package:siren_marketplace/core/domain/value_objects/price.dart';
import 'package:siren_marketplace/core/domain/value_objects/weight.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/error_handling_circle_avatar.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/number_input_field.dart';
import 'package:siren_marketplace/core/widgets/page_title.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/buyer/presentation/widgets/product_image_carousel.dart';
import 'package:siren_marketplace/features/fisher/new_logic/catches_bloc/catches_cubit.dart';
import 'package:siren_marketplace/features/fisher/new_logic/offers_bloc/offers_cubit.dart';
import 'package:siren_marketplace/features/fisher/new_logic/users_bloc/users_cubit.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _pricePerKgController = TextEditingController();

  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final sessionService = context.read<SessionService>();
    final user = await sessionService.getCurrentUser();

    if (user != null && mounted) {
      setState(() {
        _currentUserId = user.id;
      });

      // Load the catch and buyer's offers
      context.read<CatchesCubit>().loadById(widget.productId);
      context.read<OffersCubit>().loadForBuyer(user.id);
    }
  }

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
                    CustomButton(
                      title: "Send Offer",
                      onPressed: () {
                        if (formKey.currentState!.validate() &&
                            _currentUserId != null) {
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

                            context.read<OffersCubit>().createOffer(
                              catchItem.id,
                              _currentUserId!,
                              catchItem.fisherId,
                              terms,
                            );

                            Navigator.of(dialogContext).pop();

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
                                      const Text(
                                        "Offer sent successfully!",
                                        style: TextStyle(
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
    if (_currentUserId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocConsumer<CatchesCubit, CatchesState>(
      listener: (context, state) {
        final catchItem = state.catches
            .where((c) => c.id == widget.productId)
            .firstOrNull;

        if (catchItem != null) {
          context.read<UsersCubit>().loadById(catchItem.fisherId);
        }
      },
      builder: (context, catchesState) {
        if (catchesState.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (catchesState.error != null) {
          return Scaffold(
            appBar: AppBar(leading: const BackButton()),
            body: Center(
              child: Text("Error loading product: ${catchesState.error}"),
            ),
          );
        }

        final catchItem = catchesState.catches
            .where((c) => c.id == widget.productId)
            .firstOrNull;

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

        return BlocBuilder<OffersCubit, OffersState>(
          builder: (context, offersState) {
            // Check if the current user has any pending offers on this catch
            final bool hasPendingOffer = offersState.offers.any(
              (offer) =>
                  offer.status == OfferStatus.pending &&
                  offer.catchId == catchItem.id &&
                  offer.buyerId == _currentUserId,
            );

            return Scaffold(
              appBar: AppBar(
                leading: const BackButton(),
                title: PageTitle(title: "Product Details"),
                centerTitle: true,
              ),
              body: RefreshIndicator(
                onRefresh: _loadData,
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
                                onPressed: () {},
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
                                      ),
                                disabled:
                                    catchItem.availableWeight.isZero ||
                                    hasPendingOffer,
                              ),
                            ),
                          ],
                        ),

                        const SectionHeader("Seller"),

                        BlocBuilder<UsersCubit, UsersState>(
                          builder: (context, usersState) {
                            final fisher = usersState.users[catchItem.fisherId];

                            if (fisher == null) {
                              return const CircularProgressIndicator();
                            }

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
