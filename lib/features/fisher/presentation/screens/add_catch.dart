import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/providers/navigation_providers.dart';
import 'package:siren_marketplace/core/utils/custom_dialogs.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/number_input_field.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/core/domain/entities/species.dart';
import 'package:siren_marketplace/features/fisher/presentation/providers/add_catch_provider.dart';

List<Species> speciesList = [
  const Species(
    id: "prawn",
    name: "Prawn",
    image: "assets/shrimp-species/prawn.png",
  ),
  const Species(
    id: "grey-shrimp",
    name: "Grey Shrimp",
    image: "assets/shrimp-species/grey-shrimp.png",
  ),
  const Species(
    id: "pink-shrimp",
    name: "Pink Shrimp",
    image: "assets/shrimp-species/pink-shrimp.png",
  ),
  const Species(
    id: "tiger-shrimp",
    name: "Tiger Shrimp",
    image: "assets/shrimp-species/tiger-shrimp.png",
  ),
];

class AddCatchScreen extends ConsumerStatefulWidget {
  const AddCatchScreen({super.key});

  @override
  ConsumerState<AddCatchScreen> createState() => _AddCatchScreenState();
}

class _AddCatchScreenState extends ConsumerState<AddCatchScreen> {
  // Controllers for Step 1
  final TextEditingController _meshSizeController = TextEditingController();
  final TextEditingController _gearLengthController = TextEditingController();
  final TextEditingController _gearWidthController = TextEditingController();
  final TextEditingController _waterDepthController = TextEditingController();
  final TextEditingController _fishingTimeController = TextEditingController();
  // Gear Nature is handled via Dropdown, no text controller needed directly but state stores it

  // Controllers for Step 3
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _countController = TextEditingController();
  final TextEditingController _qtySellController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _finalPriceController =
      TextEditingController(); // Read-only

  // Controller for Step 4
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _meshSizeController.dispose();
    _gearLengthController.dispose();
    _gearWidthController.dispose();
    _waterDepthController.dispose();
    _fishingTimeController.dispose();

    _weightController.dispose();
    _sizeController.dispose();
    _countController.dispose();
    _qtySellController.dispose();
    _priceController.dispose();
    _finalPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addCatchProvider);
    final notifier = ref.read(addCatchProvider.notifier);

    // Sync final price controller
    _finalPriceController.text = state.finalPrice > 0
        ? state.finalPrice.toStringAsFixed(0)
        : '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(
          onPressed: () {
            if (state.currentStep > 0) {
              notifier.previousStep();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader("New Catch"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.blue600,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                "Shrimp",
                style: TextStyle(
                  color: AppColors.white100,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.currentStep == 0) _buildStep1(state, notifier),
                    if (state.currentStep == 1) _buildStep2(state, notifier),
                    if (state.currentStep == 2) _buildStep3(state, notifier),
                    if (state.currentStep == 3) _buildStep4(state, notifier),
                    if (state.currentStep == 4) _buildStep5(state, notifier),
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(state, notifier, context),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(AddCatchState state, AddCatchNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 32,
      children: [
        // Location Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.blue600),
                  const SizedBox(width: 8),
                  const Text(
                    "Catch Location",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (state.locationName != null) ...[
                Text(
                  state.locationName!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  state.observationId ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                  ),
                ),
                if (state.latitude != null && state.longitude != null)
                  Text(
                    "${state.latitude!.toStringAsFixed(4)}, ${state.longitude!.toStringAsFixed(4)}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGray,
                    ),
                  ),
                const SizedBox(height: 16),
              ],
              CustomButton(
                title: state.locationName == null
                    ? "Get Current Location"
                    : "Update Location",
                icon: Icons.my_location,
                bordered: true,
                loading: state.isLoadingLocation,
                onPressed: () => notifier.fetchLocation(),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Column(
            children: [
              NumberInputField(
                label: "Mesh Size",
                suffix: "(finger)",
                controller: _meshSizeController,
                value: state.meshSize,
                onChanged: (val) => notifier.updateGearAndEnvironment(
                  meshSize: double.tryParse(val),
                ),
              ),
              const SizedBox(height: 16),
              NumberInputField(
                label: "Gear Length",
                suffix: "(m)",
                controller: _gearLengthController,
                value: state.gearLength,
                onChanged: (val) => notifier.updateGearAndEnvironment(
                  gearLength: double.tryParse(val),
                ),
              ),
              const SizedBox(height: 16),
              NumberInputField(
                label: "Gear Width",
                suffix: "(m)",
                controller: _gearWidthController,
                value: state.gearWidth,
                onChanged: (val) => notifier.updateGearAndEnvironment(
                  gearWidth: double.tryParse(val),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: "Gear Nature",
                  labelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGray,
                  ),
                ),
                initialValue: state.gearNature,
                items: ["Cotton", "Monofilament", "Multifilament"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) =>
                    notifier.updateGearAndEnvironment(gearNature: val),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Column(
            children: [
              NumberInputField(
                label: "Water Depth",
                suffix: "(m)",
                controller: _waterDepthController,
                value: state.waterDepth,
                onChanged: (val) => notifier.updateGearAndEnvironment(
                  waterDepth: double.tryParse(val),
                ),
              ),
              NumberInputField(
                label: "Fishing Time",
                suffix: "(h)",
                controller: _fishingTimeController,
                value: state.fishingTime,
                onChanged: (val) => notifier.updateGearAndEnvironment(
                  fishingTime: double.tryParse(val),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(AddCatchState state, AddCatchNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Shrimp Species *",
                style: TextStyle(
                  color: AppColors.textGray,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
              ...List.generate(
                speciesList.length,
                (index) => ShrimpSpeciesWidget(
                  species: speciesList[index],
                  isSelected:
                      state.selectedSpecies?.id == speciesList[index].id,
                  onTap: () => notifier.selectSpecies(speciesList[index]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep3(AddCatchState state, AddCatchNotifier notifier) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSelectedSpeciesHeader(state.selectedSpecies),
          const SizedBox(height: 16),
          // Catch Details Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader("Catch Details"),
                const SizedBox(height: 16),
                NumberInputField(
                  label: "Est. Weight (kg)",
                  suffix: "kg",
                  controller: _weightController,
                  value: state.estimatedWeight,
                  onChanged: (val) =>
                      notifier.updateCatchDetails(weight: double.tryParse(val)),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                NumberInputField(
                  label: "Avg. Size (cm)",
                  suffix: "cm",
                  controller: _sizeController,
                  value: state.averageSize,
                  onChanged: (val) =>
                      notifier.updateCatchDetails(size: double.tryParse(val)),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                NumberInputField(
                  label: "Count (approx)",
                  suffix: "pcs",
                  decimal: false,
                  controller: _countController,
                  value: state.estimatedCount,
                  onChanged: (val) =>
                      notifier.updateCatchDetails(count: int.tryParse(val)),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Selling Toggle & Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.gray200,
              ), // Highlight for selling section
            ),
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    "Sell this catch?",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  value: state.isSelling,
                  onChanged: notifier.toggleSelling,
                  activeColor: AppColors.blue600,
                ),
                if (state.isSelling) ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  NumberInputField(
                    label: "Qty to Sell (kg)",
                    suffix: "kg",
                    controller: _qtySellController,
                    value: state.quantityToSell,
                    onChanged: (val) => notifier.updateSellingDetails(
                      quantity: double.tryParse(val),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      final qty = double.tryParse(val);
                      if (qty == null || qty <= 0) return 'Invalid quantity';
                      if (state.estimatedWeight != null &&
                          qty > state.estimatedWeight!) {
                        return 'Cannot sell more than caught';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  NumberInputField(
                    label: "Price/Kg",
                    suffix: "CFA",
                    controller: _priceController,
                    value: state.pricePerKg,
                    onChanged: (val) => notifier.updateSellingDetails(
                      price: double.tryParse(val),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  NumberInputField(
                    label: "Total Price",
                    suffix: "CFA",
                    controller: _finalPriceController,
                    editable: false, // Auto-calculated
                    value: state.finalPrice,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4(AddCatchState state, AddCatchNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSelectedSpeciesHeader(state.selectedSpecies),
        const SizedBox(height: 24),
        SectionHeader("Add Photos"),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildImageOption(
                icon: Icons.camera,
                label: "Camera",
                onTap: () {
                  notifier.pickImage(ImageSource.camera);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildImageOption(
                icon: Icons.image,
                label: "Gallery",
                onTap: () {
                  notifier.pickImage(ImageSource.gallery);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (state.images.isNotEmpty) ...[
          SectionHeader("Selected Images (${state.images.length})"),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(state.images.length, (index) {
              final imagePath = state.images[index];
              final isAsset = imagePath.startsWith('assets/');
              return Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: isAsset
                          ? Image.asset(imagePath, fit: BoxFit.cover)
                          : Image.file(File(imagePath), fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: () => notifier.removeImage(index),
                      child: const CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close, size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.blue600),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildStep5(AddCatchState state, AddCatchNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSelectedSpeciesHeader(state.selectedSpecies),
        const SizedBox(height: 24),
        SectionHeader("Notes"),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Add any additional details here...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gray200),
            ),
          ),
          onChanged: notifier.updateNotes,
        ),
      ],
    );
  }

  Widget _buildSelectedSpeciesHeader(Species? species) {
    if (species == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.blue600.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.blue600.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(
            "Selected: ",
            style: TextStyle(
              color: AppColors.blue600,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            species.name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(
    AddCatchState state,
    AddCatchNotifier notifier,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),

      child: Column(
        children: [
          if (state.currentStep == 4) ...[
            CustomButton(
              title: "Save as draft",
              bordered: true,
              icon: Icons.wifi_off,
              onPressed: () {
                //TODO: save as draft
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],

          Row(
            children: [
              // Previous Button (or Cancel)
              if (state.currentStep > 0)
                Expanded(
                  child: CustomButton(
                    title: "Previous",
                    onPressed: notifier.previousStep,
                    bordered: true, // Specific style
                  ),
                ),
              const SizedBox(width: 16),

              // Next/Save Button
              Expanded(
                child: state.currentStep == 4
                    ? Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              title: "Submit",
                              onPressed: () async {
                                final success = await notifier.submit();
                                if (success) {
                                  if (context.mounted) {
                                    showActionSuccessDialog(
                                      context,
                                      actionTitle: "View Details",
                                      message: "Catch added successfully",

                                      onAction: () {
                                        ref
                                                .read(
                                                  bottomNavIndexProvider
                                                      .notifier,
                                                )
                                                .state =
                                            2; // Switch to 3rd tab (index 2)
                                        Navigator.pop(
                                          context,
                                        ); // Close Add Catch screen
                                      },
                                    ).then((_) {
                                      // Ensure navigation happens even if dialog autocloses without action
                                      if (context.mounted) {
                                        ref
                                                .read(
                                                  bottomNavIndexProvider
                                                      .notifier,
                                                )
                                                .state =
                                            2;
                                        Navigator.of(
                                          context,
                                        ).popUntil((route) => route.isFirst);
                                      }
                                    });
                                  }
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Failed to submit catch. Please check your inputs.",
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      )
                    : CustomButton(
                        title: "Next",
                        onPressed: notifier.canProceed()
                            ? notifier.nextStep
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please fill in required fields",
                                    ),
                                  ),
                                );
                              },
                        disabled: !notifier.canProceed(),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Success"),
        content: const Text("Catch added successfully!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

class ShrimpSpeciesWidget extends StatelessWidget {
  const ShrimpSpeciesWidget({
    super.key,
    required this.species,
    this.isSelected = false,
    required this.onTap,
  });

  final Species species;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: isSelected ? true : null,
                  onChanged: (_) => onTap(),
                  activeColor: AppColors.blue600,
                  visualDensity: VisualDensity.compact,
                ),
                Expanded(
                  child: Text(
                    species.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  species.image,
                  fit: BoxFit.cover,
                  height: 130,
                  width: 170,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
