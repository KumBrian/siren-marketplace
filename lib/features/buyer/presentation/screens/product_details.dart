import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:intl/intl.dart';

import 'package:siren_marketplace/core/constants/app_colors.dart';
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
import 'package:siren_marketplace/new_core/domain/entities/offer.dart';
import 'package:siren_marketplace/new_core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/new_core/domain/enums/user_role.dart';
import 'package:siren_marketplace/new_core/domain/repositories/i_offer_repository.dart';
import 'package:siren_marketplace/new_core/domain/value_objects/offer_terms.dart';
import 'package:siren_marketplace/new_core/domain/value_objects/price.dart';
import 'package:siren_marketplace/new_core/domain/value_objects/weight.dart';
import 'package:siren_marketplace/new_core/presentation/cubits/auth/auth_cubit.dart';
import 'package:siren_marketplace/new_core/presentation/cubits/auth/auth_state.dart';
import 'package:siren_marketplace/new_features/fisher/presentation/cubits/catch_detail/catch_detail_cubit.dart';
import 'package:siren_marketplace/new_features/fisher/presentation/cubits/catch_detail/catch_detail_state.dart';

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

  @override
  void initState() {
    super.initState();
    // Load catch details for this product
    context.read<CatchDetailCubit>().loadCatchDetail(widget.productId);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _priceController.dispose();
    _pricePerKgController.dispose();
    super.dispose();
  }

  void _showMakeOfferDialog(BuildContext context, CatchDetailLoaded loaded) {
    final c = loaded.catch_;
    _weightController.clear();
    _priceController.clear();
    _pricePerKgController.clear();
    // Prefill price per kg from catch
    _pricePerKgController.text = c.pricePerKg.amountPerKg.toString();

    bool userEditingTotal = false;

    void updateTotalFromWeight() {
      if (userEditingTotal) return;
      final weightKg = double.tryParse(_weightController.text);
      final pricePerKg = int.tryParse(_pricePerKgController.text);
      if (weightKg != null && pricePerKg != null) {
        final total = (weightKg * pricePerKg).round();
        _priceController.text = total.toString();
      }
    }

    void updatePricePerKgFromTotal() {
      final weightKg = double.tryParse(_weightController.text);
      final total = int.tryParse(_priceController.text);
      if (weightKg != null && weightKg > 0 && total != null) {
        final pricePerKg = (total / weightKg).round();
        _pricePerKgController.text = pricePerKg.toString();
      }
    }

    _weightController.addListener(updateTotalFromWeight);
    _priceController.addListener(() {
      userEditingTotal = true;
      updatePricePerKgFromTotal();
      Future.delayed(const Duration(milliseconds: 200), () {
        userEditingTotal = false;
      });
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        contentPadding: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => ctx.pop(),
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    NumberInputField(
                      controller: _weightController,
                      label: "Weight",
                      role: UserRole.buyer,
                      suffix: "Kg",
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        final weightKg = double.tryParse(value ?? "");
                        if (weightKg == null || weightKg <= 0)
                          return "Enter valid weight";
                        final weightGrams = (weightKg * 1000).round();
                        if (weightGrams > c.availableWeight.grams)
                          return "Cannot exceed available weight";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    NumberInputField(
                      controller: _priceController,
                      label: "Total Price",
                      suffix: "CFA",
                      decimal: false,
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        final price = int.tryParse(value ?? "");
                        if (price == null || price <= 0)
                          return "Enter valid price";
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
                        final ppk = int.tryParse(value ?? "");
                        if (ppk == null || ppk <= 0)
                          return "Enter valid price per kg";
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      title: "Send Offer",
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final weightKg = double.parse(_weightController.text);
                        final totalPrice = int.parse(_priceController.text);
                        final weightGrams = (weightKg * 1000).round();

                        // Get current user from AuthCubit
                        final authState = context.read<AuthCubit>().state;
                        if (authState is! AuthAuthenticated) return;
                        final user = authState.user;

                        final offer = Offer(
                          id: '', // backend generates
                          catchId: c.id,
                          buyerId: user.id,
                          fisherId: c.fisherId,
                          currentTerms: OfferTerms.create(
                            totalPrice: Price.fromAmount(totalPrice),
                            weight: Weight.fromGrams(weightGrams),
                          ),
                          status: OfferStatus.pending,
                          dateCreated: DateTime.now(),
                          dateUpdated: DateTime.now(),
                        );

                        await context.read<IOfferRepository>().create(offer);
                        // Refresh catch details to reflect new offer
                        if (context.mounted) {
                          await context
                              .read<CatchDetailCubit>()
                              .loadCatchDetail(c.id);
                          if (!context.mounted) return;
                          ctx.pop();
                          // Show success dialog
                          showDialog(
                            context: context, // Use parent context
                            barrierDismissible: false,
                            builder: (innerCtx) => AlertDialog(
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
                                      context.go('/buyer');
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
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
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : null;
        return BlocBuilder<CatchDetailCubit, CatchDetailState>(
          builder: (context, state) {
            if (state is CatchDetailLoading || state is CatchDetailInitial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (state is CatchDetailError) {
              return Scaffold(
                appBar: AppBar(leading: const BackButton()),
                body: Center(
                  child: Text('Error loading catch details: ${state.message}'),
                ),
              );
            }
            final loaded = state as CatchDetailLoaded;
            final c = loaded.catch_;
            final bool hasPendingOffer = loaded.offers.any(
              (o) => o.status == OfferStatus.pending && o.buyerId == user?.id,
            );
            return Scaffold(
              appBar: AppBar(
                leading: const BackButton(),
                title: PageTitle(title: "Product Details"),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProductImagesCarousel(images: c.images),
                      SectionHeader(c.name),
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
                            child: Text(
                              formatPrice(c.pricePerKg.amountPerKg.toDouble()),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: AppColors.textBlue,
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
                              value: c.market.capitalize(),
                            ),
                            if (c.species.id == "prawns")
                              InfoRow(label: "Size", value: c.size),
                            if (c.species.id != "prawns")
                              InfoRow(
                                label: "Average Size",
                                value: "${c.size} cm",
                              ),
                            InfoRow(
                              label: "Available",
                              value: formatWeight(c.availableWeight.grams),
                            ),
                            InfoRow(
                              label: "Date Posted",
                              value: DateFormat(
                                "MMM d, yyyy - H:mm",
                              ).format(c.datePosted),
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
                                  : () => _showMakeOfferDialog(context, loaded),
                              disabled:
                                  c.availableWeight.isZero || hasPendingOffer,
                            ),
                          ),
                        ],
                      ),
                      const SectionHeader("Seller"),
                      if (loaded.fisher != null)
                        Material(
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () {
                              context.push(
                                "/buyer/reviews/${loaded.fisher!.id}",
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            splashColor: AppColors.blue700.withValues(
                              alpha: 0.1,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ErrorHandlingCircleAvatar(
                                    avatarUrl: loaded.fisher!.avatarUrl ?? '',
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          loaded.fisher!.name,
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
                                              loaded.fisher!.rating.value
                                                  .toStringAsFixed(1),
                                            ),
                                            Text(
                                              " (${loaded.fisher!.reviewCount} Reviews)",
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
                        )
                      else
                        const Text("Seller info not available"),
                    ],
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
