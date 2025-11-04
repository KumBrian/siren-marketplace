import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/number_input_field.dart';

typedef CounterSubmit =
    Future<void> Function(
      double newWeight,
      double newPrice,
      BuildContext dialogContext,
    );

Future<void> showCounterOfferDialog({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
  required Role role,
  required double initialWeight,
  required double initialPrice,
  required CounterSubmit onSubmit,
}) async {
  final weightController = TextEditingController(
    text: initialWeight.toStringAsFixed(1),
  );
  final priceController = TextEditingController(
    text: initialPrice.toStringAsFixed(0),
  );
  final pricePerKgController = TextEditingController();

  double calcPricePerKg(double w, double p) => (w > 0) ? p / w : 0;

  double calculatedPricePerKg = calcPricePerKg(initialWeight, initialPrice);
  pricePerKgController.text = calculatedPricePerKg.toStringAsFixed(0);

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
            void updatePricePerKg(String _) {
              final w = double.tryParse(weightController.text) ?? 0.0;
              final p = double.tryParse(priceController.text) ?? 0.0;
              setLocalState(() {
                calculatedPricePerKg = calcPricePerKg(w, p);
                pricePerKgController.text = calculatedPricePerKg
                    .toStringAsFixed(0);
              });
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
                          onChanged: updatePricePerKg,
                        ),
                        const SizedBox(height: 12),
                        NumberInputField(
                          controller: priceController,
                          label: "Total",
                          suffix: "CFA",
                          onChanged: updatePricePerKg,
                        ),
                        const SizedBox(height: 12),
                        NumberInputField(
                          controller: pricePerKgController,
                          label: "Price/Kg",
                          suffix: "CFA",
                          value: calculatedPricePerKg,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    title: "Send Counter Offer",
                    onPressed: () async {
                      final newWeight =
                          double.tryParse(weightController.text) ?? 0.0;
                      final newPrice =
                          double.tryParse(priceController.text) ?? 0.0;
                      if (formKey.currentState!.validate() &&
                          newWeight > 0 &&
                          newPrice > 0) {
                        await onSubmit(
                          newWeight,
                          newPrice,
                          dialogCtx,
                        ); // ✅ pass the outer context
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
