import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/components/custom_button.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart'
    show Offer; // UPDATE: Import the unified Offer type

import 'number_input_field.dart';

class FisherOfferActions extends StatefulWidget {
  const FisherOfferActions({
    super.key,
    // UPDATE: Change type to Offer
    required this.offer,
    required this.formKey,
  });

  // UPDATE: Change type to Offer
  final Offer offer;
  final GlobalKey<FormState> formKey;

  @override
  State<FisherOfferActions> createState() => _FisherOfferActionsState();
}

class _FisherOfferActionsState extends State<FisherOfferActions> {
  final TextEditingController _weightController = TextEditingController();

  final TextEditingController _priceController = TextEditingController();

  final TextEditingController _pricePerKgController = TextEditingController();

  // State to hold the calculated Price/Kg value
  double _calculatedPricePerKg = 0.0;

  @override
  void dispose() {
    _weightController.dispose();
    _priceController.dispose();
    _pricePerKgController.dispose();
    super.dispose();
  }

  /// Calculates Price/Kg whenever weight or price changes.
  void _calculatePricePerKg(Function localSetState) {
    final weightText = _weightController.text;
    final priceText = _priceController.text;

    final weight = double.tryParse(weightText);
    final price = double.tryParse(priceText);

    double newPricePerKg = 0.0;

    if (weight != null && price != null && weight > 0) {
      newPricePerKg = price / weight;
    }

    if (_calculatedPricePerKg != newPricePerKg) {
      // *** CRITICAL CHANGE: Use the localSetState function ***
      localSetState(() {
        _calculatedPricePerKg = newPricePerKg;
      });
      // The parent widget's setState is no longer needed here, but the
      // variable _calculatedPricePerKg must be kept at the FisherOfferActionsState level
      // to persist its value between dialog openings.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // UPDATED: Replaced spacing: 16 with SizedBox
      children: [
        CustomButton(
          title: "Accept",
          icon: Icons.check,
          onPressed: () => _showAcceptDialog(context),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          // UPDATED: Replaced spacing: 8 with SizedBox
          children: [
            // Reject Button
            Expanded(
              child: CustomButton(
                title: "Reject offer",
                icon: Icons.close,
                onPressed: () => _showRejectDialog(context),
                bordered: true,
              ),
            ),
            const SizedBox(width: 8),

            // Counter Offer Button
            Expanded(
              child: CustomButton(
                title: "Counter-Offer",
                icon: Icons.autorenew_rounded,
                onPressed: () => _showCounterOfferDialog(context),
                bordered: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---- Dialogs ----
  void _showRejectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.textBlue, width: 3),
          ),
          child: const Icon(Icons.question_mark_outlined),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          // UPDATED: Replaced spacing: 8 with SizedBox
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                "Reject the offer?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlue,
                ),
              ),
            ),
            const SizedBox(height: 8),

            CustomButton(title: "Keep Offer", onPressed: () => context.pop()),
            const SizedBox(height: 8),
            CustomButton(
              title: "Reject",
              cancel: true,
              onPressed: () {
                // TODO: Reject offer logic
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCounterOfferDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        _calculatedPricePerKg = 0.0;
        _weightController.clear();
        _priceController.clear();
        _pricePerKgController.clear();
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
              onPressed: () => context.pop(),
            ),
          ),
          titlePadding: EdgeInsets.only(top: 8, right: 8),
          content: StatefulBuilder(
            builder: (BuildContext dialogContext, StateSetter localSetState) {
              // Define the local onChanged handler using the localSetState
              void onFieldChanged(String? _) {
                _calculatePricePerKg(localSetState);
              }

              return Form(
                key: widget.formKey,
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
                        spacing: 16,
                        children: [
                          NumberInputField(
                            controller: _weightController,
                            label: "Weight",
                            suffix: "Kg",
                            // Use the local handler
                            onChanged: onFieldChanged,
                          ),
                          NumberInputField(
                            controller: _priceController,
                            label: "Total",
                            suffix: "CFA",
                            // Use the local handler
                            onChanged: onFieldChanged,
                          ),
                          NumberInputField(
                            controller: _pricePerKgController,
                            label: "Price/Kg",
                            suffix: "CFA",
                            // This value is updated by the localSetState
                            value: _calculatedPricePerKg,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      title: "Send Counter-Offer",
                      onPressed: () {
                        if (widget.formKey.currentState!.validate()) {
                          // TODO: Send counter offer
                          dialogContext.pop(); // Use dialogContext for pop
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              // ... (Success dialog content remains the same)
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
                                  Icons.question_mark_outlined,
                                  color: AppColors.textWhite,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Center(
                                    child: Text(
                                      "Offer Sent",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textBlue,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    child: Text("Deal details"),
                                    onPressed: () {
                                      //TODO: Go to congratulations page
                                      context.pop();
                                      context.pushReplacement(
                                        "/fisher/order-details/${widget.offer.offerId}",
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
              );
            },
          ),
        );
      },
    );
  }

  void _showAcceptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.textBlue, width: 3),
          ),
          child: const Icon(Icons.question_mark_outlined),
        ),
        content: Column(
          // UPDATED: Removed spacing, using SizedBox
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    // UPDATE: Format weight as string/int
                    "Accept the offer?",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Color(0xFF0A2A45),
                    ),
                  ),
                  Text(
                    // UPDATE: Format weight as string/int
                    "${widget.offer.weight.toInt()} Kg / ${widget.offer.price.toInt()} CFA",
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              title: "Accept",
              onPressed: () {
                // TODO: Accept offer logic
                context.pop();
                context.pushReplacement(
                  "/fisher/congratulations/${widget.offer.offerId}",
                );
              },
            ),
            const SizedBox(height: 16),
            CustomButton(
              title: "Reject",
              cancel: true,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
