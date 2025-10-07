import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/bottom_nav_cubit/bottom_nav_cubit.dart';
import 'package:siren_marketplace/components/custom_button.dart';
import 'package:siren_marketplace/components/info_table.dart';
import 'package:siren_marketplace/components/number_input_field.dart';
import 'package:siren_marketplace/components/section_header.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';
import 'package:siren_marketplace/data/product_data.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final CarouselController _controller = CarouselController();
  late Product? product;

  @override
  void initState() {
    super.initState();
    product = sampleProducts.firstWhere(
      (p) => p.id == widget.productId,
      orElse: () => Product.empty(),
    );
  }

  void _showMakeOfferDialog(BuildContext context) {
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
            spacing: 16,
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
                  children: const [
                    NumberInputField(label: "Weight", suffix: "Kg"),
                    NumberInputField(label: "Total", suffix: "CFA"),
                    NumberInputField(label: "Price/Kg", suffix: "CFA"),
                  ],
                ),
              ),
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
                          spacing: 16,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Offer Sent",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBlue,
                              ),
                            ),
                            BlocBuilder<BottomNavCubit, int>(
                              builder: (context, state) {
                                return CustomButton(
                                  title: "OK",
                                  onPressed: () {
                                    // Close all open dialogs
                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).popUntil((route) => route.isFirst);

                                    // Ensure any local modal/pop is closed
                                    if (Navigator.of(context).canPop()) {
                                      context.pop();
                                    }

                                    // Switch tab to Orders
                                    context.read<BottomNavCubit>().changeIndex(
                                      2,
                                    );
                                  },
                                );
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Product Details")),
        body: const Center(
          child: Text(
            "Product not found",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final p = product!;

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),

      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child: CarouselView.weighted(
                controller: _controller,
                flexWeights: const <int>[5, 1],
                enableSplash: true,
                children: p.images.map((img) {
                  return Image.network(img, fit: BoxFit.cover);
                }).toList(),
                onTap: (index) {
                  final providers = p.images.map<ImageProvider>((img) {
                    return NetworkImage(img);
                  }).toList();
                  final multiImageProvider = MultiImageProvider(providers);
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

            Padding(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 32,
                left: 16,
                right: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  SectionHeader(p.name),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.gray500),
                        ),
                        child: Text(
                          "${p.pricePerKg.toStringAsFixed(0)} CFA / Kg",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(color: AppColors.gray200),

                  InfoTable(
                    rows: [
                      InfoRow(
                        label: "Average Size",
                        value: p.averageSize.toString().capitalize(),
                      ),
                      InfoRow(
                        label: "Available",
                        value: "${p.availableWeight} Kg",
                      ),
                      InfoRow(
                        label: "Total Price",
                        value: "${p.totalPrice} CFA",
                      ),
                      InfoRow(
                        label: "Date Posted",
                        value: p.datePosted.toFormattedDate(),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: CustomButton(
                          title: "Message",
                          onPressed: () {},
                          bordered: true,
                        ),
                      ),
                      Expanded(
                        child: CustomButton(
                          title: "Make Offer",
                          onPressed: () => _showMakeOfferDialog(context),
                        ),
                      ),
                    ],
                  ),

                  const SectionHeader("Seller"),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(p.seller.avatarUrl),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 6,
                          children: [
                            Text(
                              p.seller.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.textBlue,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: AppColors.shellOrange,
                                  size: 16,
                                ),
                                Text(
                                  p.seller.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: AppColors.textBlue,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                Text(
                                  " (${p.seller.reviewCount} Reviews)",
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
