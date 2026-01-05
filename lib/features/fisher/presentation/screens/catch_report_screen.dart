import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/enums/catch_status.dart';
import 'package:siren_marketplace/core/domain/repositories/i_catch_repository.dart';
import 'package:siren_marketplace/core/providers/catch_providers.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/number_input_field.dart';
import 'package:siren_marketplace/core/widgets/page_title.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/widgets/error_dialog.dart';
import 'package:siren_marketplace/core/domain/value_objects/price.dart';
import 'package:siren_marketplace/core/domain/value_objects/price_per_kg.dart';
import 'package:siren_marketplace/core/domain/value_objects/weight.dart';
import 'package:siren_marketplace/features/buyer/presentation/widgets/product_image_carousel.dart';

class CatchReportScreen extends ConsumerStatefulWidget {
  const CatchReportScreen({super.key, required this.catchId});

  final String catchId;

  @override
  ConsumerState<CatchReportScreen> createState() => _CatchReportScreenState();
}

class _CatchReportScreenState extends ConsumerState<CatchReportScreen> {
  TextEditingController _meshSizeController = TextEditingController();
  TextEditingController _gearLengthController = TextEditingController();
  TextEditingController _gearWidthController = TextEditingController();
  TextEditingController _gearNatureController = TextEditingController();
  TextEditingController _waterDepthController = TextEditingController();
  TextEditingController _timeTakenController = TextEditingController();
  TextEditingController _catchWeightController = TextEditingController();
  TextEditingController _numberOfShrimpsController = TextEditingController();
  TextEditingController _shrimpSizeController = TextEditingController();
  TextEditingController _sellingShrimpsController = TextEditingController();
  TextEditingController _sellingWeightController = TextEditingController();
  TextEditingController _sellingPricePerKgController = TextEditingController();
  TextEditingController _sellingPriceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final catchAsync = ref.watch(catchByIdProvider(widget.catchId));
    final fisherAsync = ref.watch(currentUserProvider);

    return catchAsync.when(
      data: (selectedCatch) {
        if (selectedCatch == null) {
          return const Scaffold(body: Center(child: Text("Catch not found")));
        }

        _meshSizeController.text = selectedCatch.meshSize?.toString() ?? '';
        _gearLengthController.text = selectedCatch.gearLength?.toString() ?? '';
        _gearWidthController.text = selectedCatch.gearWidth?.toString() ?? '';
        _gearNatureController.text = selectedCatch.gearNature ?? '';
        _waterDepthController.text = selectedCatch.waterDepth?.toString() ?? '';
        _timeTakenController.text = selectedCatch.fishingTime?.toString() ?? '';
        _catchWeightController.text = selectedCatch.initialWeight
            .toNormalString();
        _numberOfShrimpsController.text =
            selectedCatch.numberOfShrimps?.toString() ?? '';
        _shrimpSizeController.text = selectedCatch.size.toString();
        _sellingShrimpsController.text =
            selectedCatch.status == CatchStatus.available ? "Yes" : "No";
        _sellingWeightController.text = selectedCatch.availableWeight
            .toNormalString();
        _sellingPricePerKgController.text = selectedCatch.pricePerKg.amountPerKg
            .toString();
        _sellingPriceController.text = selectedCatch.totalPrice.amount
            .toString();

        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: const PageTitle(title: "Catch Detail"),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            scrolledUnderElevation: 0,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.fail500,
                ),
                onPressed: () =>
                    _showDeleteConfirmation(context, selectedCatch),
              ),
              const SizedBox(width: 8),
            ],
          ),
          bottomNavigationBar: selectedCatch.status == CatchStatus.draft
              ? Container(
                  padding: const EdgeInsets.all(16),
                  child: SafeArea(
                    child: CustomButton(
                      title: "List to Marketplace",
                      onPressed: () {
                        _showListToMarketplaceDialog(context, selectedCatch);
                      },
                    ),
                  ),
                )
              : null,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                // Header: Observation ID
                Text(
                  selectedCatch.observationId.isNotEmpty
                      ? selectedCatch.observationId
                      : 'Catch #${selectedCatch.id}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlue,
                  ),
                ),

                // Info Tiles
                Column(
                  children: [
                    _buildInfoTile(
                      icon: Icons.location_on_outlined,
                      title: "Location",
                      subtitle: selectedCatch.locationName,
                    ),
                    _buildInfoTile(
                      icon: Icons.map_outlined,
                      title: "Coordinates",
                      subtitle:
                          "${selectedCatch.latitude.toStringAsFixed(4)}, ${selectedCatch.longitude.toStringAsFixed(4)}",
                    ),
                    _buildInfoTile(
                      icon: Icons.set_meal,
                      title: "Species",
                      subtitle: selectedCatch.species.name,
                    ),
                    _buildInfoTile(
                      icon: Icons.person_2_outlined,
                      title: "Fisher",
                      subtitle: fisherAsync.value!.name,
                    ),
                    _buildInfoTile(
                      icon: Icons.access_time,
                      title: "Detected at",
                      subtitle: selectedCatch.datePosted
                          .toIso8601String()
                          .toFormattedDate(),
                    ),
                  ],
                ),

                // Images
                if (selectedCatch.images.isNotEmpty)
                  ProductImagesCarousel(
                    images: selectedCatch.images,
                    height: 220,
                  ),

                // Details Form (Read-only)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16,
                    children: [
                      NumberInputField(
                        label: "Mesh Size of gear",
                        suffix: "(fingers)",
                        editable: false,
                        controller: _meshSizeController,
                        value: selectedCatch.meshSize,
                      ),
                      NumberInputField(
                        label: "Gear Length",
                        suffix: "(m)",
                        editable: false,
                        controller: _gearLengthController,
                        value: selectedCatch.gearLength,
                      ),
                      NumberInputField(
                        label: "Gear Width",
                        suffix: "(m)",
                        editable: false,
                        controller: _gearWidthController,
                        value: selectedCatch.gearWidth,
                      ),
                      TextField(
                        controller: _gearNatureController,
                        readOnly: true,
                        style: TextStyle(
                          color: AppColors.textBlue.withValues(alpha: .7),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          labelText: "Gear Nature",
                          border: UnderlineInputBorder(),
                          labelStyle: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      NumberInputField(
                        label: "Water Depth",
                        suffix: "(m)",
                        editable: false,
                        controller: _waterDepthController,
                        value: selectedCatch.waterDepth,
                      ),
                      NumberInputField(
                        label: "Time taken for fishing",
                        suffix: "(h)",
                        editable: false,
                        controller: _timeTakenController,
                        value: selectedCatch.fishingTime,
                      ),
                      NumberInputField(
                        label: "Estimated catch weight",
                        suffix: "(kg)",
                        editable: false,
                        controller: _catchWeightController,
                        value: selectedCatch.initialWeight.kilograms,
                      ),

                      if (selectedCatch.species.id == 'prawns')
                        NumberInputField(
                          label: "Number of shrimps",
                          suffix: "",
                          editable: false,
                          controller: _numberOfShrimpsController,
                          value: selectedCatch.numberOfShrimps as num?,
                        ),

                      TextField(
                        controller: _shrimpSizeController,
                        readOnly: true,
                        style: TextStyle(
                          color: AppColors.textBlue.withValues(alpha: .7),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          labelText: "Average shrimp size",
                          border: UnderlineInputBorder(),
                          labelStyle: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 12,
                          ),
                          suffix: Text(
                            "(cm)",
                            style: TextStyle(
                              color: AppColors.textBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      TextField(
                        controller: _sellingShrimpsController,
                        readOnly: true,
                        style: TextStyle(
                          color: AppColors.textBlue.withValues(alpha: .7),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          labelText: "Are you selling shrimps?",
                          border: UnderlineInputBorder(),
                          labelStyle: const TextStyle(
                            color: AppColors.textGray,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      if (selectedCatch.status == CatchStatus.available) ...[
                        NumberInputField(
                          label: "How many kg will you sell?",
                          suffix: "(kg)",
                          editable: false,
                          controller: _sellingWeightController,
                          value: selectedCatch.availableWeight.kilograms,
                        ),
                        NumberInputField(
                          label: "Price per kg",
                          suffix: "(CFA)",
                          editable: false,
                          controller: _sellingPricePerKgController,
                          value: selectedCatch.pricePerKg.amountPerKg,
                        ),
                        NumberInputField(
                          label: "Final price",
                          suffix: "(CFA)",
                          editable: false,
                          controller: _sellingPriceController,
                          value: selectedCatch.totalPrice.amount,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Icon(icon, size: 16, color: AppColors.textBlue),

          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textBlue,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showListToMarketplaceDialog(BuildContext context, Catch selectedCatch) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController weightController = TextEditingController();
    final TextEditingController pricePerKgController = TextEditingController();
    final TextEditingController totalController = TextEditingController();

    // Initial setup (default to full initial weight)
    final double initialWeightInKg = selectedCatch.initialWeight.kilograms;
    weightController.text = initialWeightInKg.toString().replaceAll(
      RegExp(r"([.]*0)(?!.*\d)"),
      "",
    );

    // Default price to existing price per kg if set, else empty
    if (selectedCatch.pricePerKg.amountPerKg > 0) {
      pricePerKgController.text = selectedCatch.pricePerKg.amountPerKg
          .toString();
    }

    // Calc initial total
    final double initialTotal =
        initialWeightInKg * selectedCatch.pricePerKg.amountPerKg;
    if (initialTotal > 0) {
      totalController.text = initialTotal.toStringAsFixed(0);
    }

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (stfCtx, setState) {
            final double currentWeightInputKg =
                double.tryParse(weightController.text) ?? 0.0;
            final double currentPricePerKg =
                double.tryParse(pricePerKgController.text) ?? 0;
            final double currentTotal =
                currentWeightInputKg * currentPricePerKg;

            totalController.text = currentTotal.toStringAsFixed(0);

            void updateStateOnChanged(String _) {
              setState(() {});
            }

            return AlertDialog(
              contentPadding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 24,
              ),
              constraints: const BoxConstraints(maxWidth: 500, minWidth: 450),
              title: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                ),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "List to Marketplace",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.textBlue),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          NumberInputField(
                            controller: weightController,
                            label: "Total Weight to Sell",
                            suffix: "Kg",
                            onChanged: updateStateOnChanged,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a value';
                              }
                              final parsedValue = double.tryParse(value);
                              if (parsedValue == null) {
                                return 'Enter a valid number';
                              }
                              if (parsedValue >
                                  selectedCatch.initialWeight.kilograms) {
                                return 'Cannot exceed initial weight (${selectedCatch.initialWeight.kilograms} kg)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          NumberInputField(
                            controller: pricePerKgController,
                            label: "Price per Kg",
                            decimal: false,
                            suffix: "CFA",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a value';
                              }
                              final parsedValue = double.tryParse(value);
                              if (parsedValue == null) {
                                return 'Enter a valid number';
                              }
                              return null;
                            },
                            onChanged: updateStateOnChanged,
                          ),
                          const SizedBox(height: 16),
                          NumberInputField(
                            controller: totalController,
                            label: "Total Estimated Price",
                            suffix: "CFA",
                            onChanged: null,
                            decimal: false,
                            editable: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      title: "Confirm Listing",
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          // 1. Update Catch Status and Values
                          final updatedCatch = selectedCatch.copyWith(
                            status: CatchStatus.available,
                            availableWeight: Weight.fromKg(
                              currentWeightInputKg,
                            ),
                            pricePerKg: PricePerKg.fromAmount(
                              currentPricePerKg.floor(),
                            ),
                            totalPrice: Price.fromAmount(currentTotal.round()),
                          );

                          // 2. Save to Repository
                          final repository = sl<ICatchRepository>();
                          String? finalCatchId;

                          if (selectedCatch.status == CatchStatus.draft) {
                            finalCatchId = await repository.publishDraft(
                              updatedCatch,
                            );
                          } else {
                            await repository.update(updatedCatch);
                            finalCatchId = updatedCatch.id;
                          }

                          // 3. Invalidate Providers
                          ref.invalidate(catchByIdProvider(widget.catchId));
                          ref.invalidate(fisherCatchesProvider);

                          // 4. Close Dialog & Show Feedback
                          if (dialogCtx.mounted) {
                            Navigator.of(dialogCtx).pop(); // Close dialog
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Catch listed for sale!"),
                                backgroundColor: AppColors.success500,
                              ),
                            );

                            // Redirect to new ID if it changed (local draft -> published catch)
                            if (finalCatchId != widget.catchId) {
                              // Replace the current route with the new catch details
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CatchReportScreen(catchId: finalCatchId!),
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Catch selectedCatch) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Catch"),
          content: const Text(
            "Are you sure you want to delete this catch? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // Close dialog
                Navigator.of(context).pop();

                try {
                  final repository = sl<ICatchRepository>();
                  await repository.delete(selectedCatch.id);

                  // Invalidate providers
                  ref.invalidate(fisherCatchesProvider);
                  // Also invalidate specific catch provider just in case
                  ref.invalidate(catchByIdProvider(selectedCatch.id));

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Catch deleted successfully"),
                        backgroundColor: AppColors.success500,
                      ),
                    );
                    Navigator.of(context).pop(); // Go back to list
                  }
                } catch (e) {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => ErrorDialog(
                        title: "Error",
                        message: "Error deleting catch: $e",
                      ),
                    );
                  }
                }
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: AppColors.fail500),
              ),
            ),
          ],
        );
      },
    );
  }
}
