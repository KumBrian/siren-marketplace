import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/number_input_field.dart';

typedef CounterSubmit =
    Future<void> Function(
      int newWeightInGrams,
      int newPrice,
      BuildContext dialogContext,
    );

Future<void> showCounterOfferDialog({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
  required Role role,
  required int initialWeight, // Expecting Grams (e.g., 39300)
  required int initialPrice, // Expecting Total Price (e.g., 6798)
  required CounterSubmit onSubmit,
}) async {
  // 1. SETUP: Convert Grams to String for display (39300 -> "39.3")
  final initialWeightInKg = initialWeight / 1000.0;
  final weightController = TextEditingController(
    text: initialWeightInKg.toString().replaceAll(
      RegExp(r"([.]*0)(?!.*\d)"),
      "",
    ),
  );

  final priceController = TextEditingController(text: initialPrice.toString());

  final pricePerKgController = TextEditingController();

  // 2. LOGIC: Pure Integer Math Helper
  // This ensures we never multiply floats during the core logic.
  int calculatePricePerKg(int weightInGrams, int totalPrice) {
    if (weightInGrams <= 0) return 0;
    // Formula: (Total * 1000) / Grams
    // We use round() to get the closest integer representation
    return ((totalPrice * 1000) / weightInGrams).round();
  }

  // Initial Calculation
  pricePerKgController.text = calculatePricePerKg(
    initialWeight,
    initialPrice,
  ).toString();

  await showDialog(
    context: context,
    builder: (dialogCtx) {
      return AlertDialog(
        contentPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        constraints: const BoxConstraints(maxWidth: 500, minWidth: 450),
        title: Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(dialogCtx).pop(),
          ),
        ),
        content: StatefulBuilder(
          builder: (ctx, setLocalState) {
            // 3. HELPER: Parse UI String to Clean Integer Grams
            int getGramsFromInput() {
              final val = double.tryParse(weightController.text) ?? 0.0;
              // This .round() removes the floating point noise (e.g. 39.29999 -> 39300)
              return (val * 1000).round();
            }

            // 4. UPDATE: One-way calculation (Total + Weight -> Price/Kg)
            void updateCalculatedPricePerKg(String _) {
              final weightInGrams = getGramsFromInput();
              final total = int.tryParse(priceController.text) ?? 0;

              final result = calculatePricePerKg(weightInGrams, total);

              // Only update if the value actually changed to avoid flicker
              if (pricePerKgController.text != result.toString()) {
                setLocalState(() {
                  pricePerKgController.text = result.toString();
                });
              }
            }

            return Form(
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
                          controller: weightController,
                          label: "Weight",
                          role: role,
                          suffix: "Kg",
                          // Changing weight updates the unit price
                          onChanged: updateCalculatedPricePerKg,
                        ),
                        const SizedBox(height: 12),
                        NumberInputField(
                          controller: priceController,
                          label: "Total Price",
                          suffix: "CFA",
                          editable: true,
                          decimal: false,
                          // Changing total updates the unit price
                          onChanged: updateCalculatedPricePerKg,
                        ),
                        const SizedBox(height: 12),
                        NumberInputField(
                          controller: pricePerKgController,
                          label: "Price/Kg",
                          suffix: "CFA",
                          decimal: false,
                          // Read-only derived field
                          editable: false,
                          validator: (value) {
                            final val = int.tryParse(value ?? "0") ?? 0;
                            if (val <= 0) return "Check inputs";
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    title: "Send Counter Offer",
                    onPressed: () async {
                      // Get the clean Integers one last time
                      final weightInGrams = getGramsFromInput();
                      final total = int.tryParse(priceController.text) ?? 0;

                      if (formKey.currentState!.validate() &&
                          weightInGrams > 0 &&
                          total > 0) {
                        await onSubmit(weightInGrams, total, dialogCtx);
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
