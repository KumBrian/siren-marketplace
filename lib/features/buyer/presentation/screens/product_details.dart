import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/bottom_nav_cubit/bottom_nav_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/products_cubit/products_cubit.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/number_input_field.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/fisher/logic/fisher_cubit/fisher_cubit.dart';

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
  final CarouselController _controller = CarouselController();
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

    void calculatePricePerKg() {
      final weight = double.tryParse(_weightController.text);
      final totalPrice = double.tryParse(_priceController.text);
      if (weight != null && weight > 0 && totalPrice != null) {
        _pricePerKgController.text = (totalPrice / weight).toStringAsFixed(0);
      }
    }

    void calculateTotalPrice() {
      final weight = double.tryParse(_weightController.text);
      final pricePerKg = double.tryParse(_pricePerKgController.text);
      if (weight != null && pricePerKg != null) {
        _priceController.text = (weight * pricePerKg).toStringAsFixed(0);
      }
    }

    void calculateWeight() {
      final totalPrice = double.tryParse(_priceController.text);
      final pricePerKg = double.tryParse(_pricePerKgController.text);
      if (pricePerKg != null && pricePerKg > 0 && totalPrice != null) {
        _weightController.text = (totalPrice / pricePerKg).toStringAsFixed(1);
      }
    }

    _weightController.addListener(() {
      if (_priceController.text.isNotEmpty) {
        calculatePricePerKg();
      } else if (_pricePerKgController.text.isNotEmpty) {
        calculateTotalPrice();
      }
    });

    _priceController.addListener(() {
      if (_weightController.text.isNotEmpty) {
        calculatePricePerKg();
      } else if (_pricePerKgController.text.isNotEmpty) {
        calculateWeight();
      }
    });

    _pricePerKgController.addListener(() {
      if (_weightController.text.isNotEmpty) {
        calculateTotalPrice();
      } else if (_priceController.text.isNotEmpty) {
        calculateWeight();
      }
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
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
              CustomButton(
                title: "Send Offer",
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    context.pop();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.textBlue,
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
                              "Offer Sent",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBlue,
                              ),
                            ),
                            const SizedBox(height: 16),
                            BlocBuilder<BottomNavCubit, int>(
                              builder: (context, state) => CustomButton(
                                title: "OK",
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).popUntil((route) => route.isFirst);
                                  context.read<BottomNavCubit>().changeIndex(2);
                                },
                              ),
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
          appBar: AppBar(leading: const BackButton()),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Images
                  SizedBox(
                    height: 250,
                    child: CarouselView.weighted(
                      controller: _controller,
                      flexWeights: const <int>[5, 1],
                      enableSplash: true,
                      children: c.images.map((img) {
                        return img.contains("http")
                            ? Image.network(img, fit: BoxFit.cover)
                            : Image.asset(img, fit: BoxFit.cover);
                      }).toList(),
                      onTap: (index) {
                        final providers = c.images.map<ImageProvider>((img) {
                          return img.contains("http")
                              ? NetworkImage(img)
                              : AssetImage(img);
                        }).toList();
                        final multiImageProvider = MultiImageProvider(
                          providers,
                        );
                        // Show image viewer
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
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionHeader(c.name),
                  InfoTable(
                    rows: [
                      InfoRow(label: "Market", value: c.market.capitalize()),
                      InfoRow(
                        label: "Species",
                        value: c.species.name.capitalize(),
                      ),
                      InfoRow(
                        label: "Available Weight",
                        value: "${c.availableWeight.toStringAsFixed(1)} Kg",
                      ),
                      InfoRow(
                        label: "Total Lot Price",
                        value: "${c.total.toStringAsFixed(0)} CFA",
                      ),
                      InfoRow(
                        label: "Date Posted",
                        value: c.datePosted.toFormattedDate(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 16),
                  const SectionHeader("Seller"),
                  const SizedBox(height: 8),
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
