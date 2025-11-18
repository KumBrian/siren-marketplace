import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/products_cubit/products_cubit.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/error_handling_circle_avatar.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/number_input_field.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/buyer/presentation/widgets/product_image_carousel.dart';
import 'package:siren_marketplace/features/fisher/logic/catch_bloc/catch_bloc.dart';
import 'package:siren_marketplace/features/fisher/logic/fisher_cubit/fisher_cubit.dart';
import 'package:siren_marketplace/features/fisher/logic/offers_bloc/offers_bloc.dart';
import 'package:siren_marketplace/features/user/logic/user_bloc/user_bloc.dart';

// Helper extension
extension IterableExtensions<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

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
    final productsCubit = context.read<ProductsCubit>();
    if (productsCubit.state is! ProductsLoaded) {
      productsCubit.loadMarketCatches();
    } else {
      _fetchFisherFromProduct(productsCubit);
    }

    // Listen for updates after ProductsCubit loads
    productsCubit.stream.listen((state) {
      if (state is ProductsLoaded) {
        _fetchFisherFromProduct(productsCubit);
      }
    });
  }

  void _fetchFisherFromProduct(ProductsCubit productsCubit) {
    final catchItem = productsCubit.state is ProductsLoaded
        ? (productsCubit.state as ProductsLoaded).availableCatches
              .firstWhereOrNull((c) => c.id == widget.productId)
        : null;

    if (catchItem != null) {
      context.read<FisherCubit>().fetchFisher(catchItem.fisherId);
    }
  }

  void _showMakeOfferDialog(BuildContext context, Catch c) {
    _weightController.clear();
    _priceController.clear();
    _pricePerKgController.clear();

    // Prefill with the catch's current price per kg
    final initialPricePerKg = c.pricePerKg; // must exist in your Catch model
    _pricePerKgController.text = initialPricePerKg.toStringAsFixed(0);

    bool userEditingTotal = false;

    void updateTotalFromWeight() {
      if (userEditingTotal) return; // prevent loop
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
          key: formKey,
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
                        decimal: false,
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
                        decimal: false,
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
                        if (formKey.currentState!.validate()) {
                          final weight = double.tryParse(
                            _weightController.text,
                          );
                          final totalPrice = int.tryParse(
                            _priceController.text,
                          );
                          final pricePerKg = int.tryParse(
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
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, productsState) {
        if (productsState is ProductsLoading ||
            productsState is ProductsInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (productsState is ProductsError) {
          return Scaffold(
            appBar: AppBar(leading: const BackButton()),
            body: Center(
              child: Text("Error loading products: ${productsState.message}"),
            ),
          );
        }

        final loadedProducts = productsState as ProductsLoaded;
        final catchItem = loadedProducts.availableCatches.firstWhereOrNull(
          (c) => c.id == widget.productId,
        );

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

        final c = catchItem;

        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: const Text(
              "Product Details",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textBlue,
                fontSize: 24,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  // Images
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
                        child: Center(
                          child: Text(
                            // Using the price from the Catch model
                            formatPrice(c.pricePerKg.toDouble()),
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
                        InfoRow(label: "Market", value: c.market.capitalize()),
                        c.species.id == "prawns"
                            ? InfoRow(label: "Average Size", value: c.size)
                            : null,
                        InfoRow(
                          label: "Available",
                          value: "${c.availableWeight.toStringAsFixed(1)} Kg",
                        ),
                        InfoRow(
                          label: "Date Posted",
                          value: c.datePosted.toFormattedDate(),
                        ),
                      ].whereType<InfoRow>().toList(), // Filter out nulls
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
                          title: "Make Offer",
                          onPressed: () => _showMakeOfferDialog(context, c),
                          disabled: c.availableWeight <= 0,
                        ),
                      ),
                    ],
                  ),

                  const SectionHeader("Seller"),

                  BlocBuilder<FisherCubit, FisherState>(
                    builder: (context, state) {
                      if (state is FisherLoading || state is FisherInitial) {
                        return const CircularProgressIndicator();
                      } else if (state is FisherError) {
                        return Text("Error loading seller: ${state.message}");
                      } else if (state is FisherLoaded) {
                        final fisher = state.fisher;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ErrorHandlingCircleAvatar(
                              avatarUrl: fisher.avatarUrl,
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
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: AppColors.shellOrange,
                                        size: 16,
                                      ),
                                      Text(fisher.rating.toStringAsFixed(1)),
                                      Text(" (${fisher.reviewCount} Reviews)"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
