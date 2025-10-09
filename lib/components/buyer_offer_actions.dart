import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/components/custom_button.dart';
import 'package:siren_marketplace/constants/constants.dart';
// UPDATE: Import the unified Offer type
import 'package:siren_marketplace/constants/types.dart' show Offer, OfferStatus;

import 'number_input_field.dart';

class BuyerOfferActions extends StatefulWidget {
  const BuyerOfferActions({
    super.key,
    // UPDATE: Change type to Offer
    required this.offer,
    required this.formKey,
  });

  // UPDATE: Change type to Offer
  final Offer offer;
  final GlobalKey<FormState> formKey;

  @override
  State<BuyerOfferActions> createState() => _BuyerOfferActionsState();
}

class _BuyerOfferActionsState extends State<BuyerOfferActions> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _pricePerKgController = TextEditingController();
  double _calculatedPricePerKg = 0.0;

  @override
  void dispose() {
    _weightController.dispose();
    _priceController.dispose();
    _pricePerKgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- Accepted / Completed Offers ---
    if (widget.offer.status == OfferStatus.accepted) {
      return Row(
        // UPDATE: Replaced spacing: 8 with SizedBox
        children: [
          Expanded(
            child: CustomButton(
              title: "Message",
              onPressed: () {
                // TODO: Navigate to message screen with fisher details
              },
              icon: Icons.chat_bubble_outline_rounded,
              bordered: true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CustomButton(
              title: "Call",
              onPressed: () {
                // TODO: Implement call functionality
              },
              icon: Icons.phone_outlined,
            ),
          ),
        ],
      );
    }

    if (widget.offer.status == OfferStatus.completed) {
      return Row(
        children: [
          Expanded(
            child: CustomButton(title: "Rate Fisher", onPressed: () {}),
          ),
        ],
      );
    }

    // --- Countered Offer ---
    // If the Fisher sent a counter-offer, the Buyer can accept or counter back
    if (widget.offer.status == OfferStatus.accepted) {
      return Row(
        // UPDATE: Replaced spacing: 8 with SizedBox
        children: [
          Expanded(
            child: CustomButton(
              title: "Counter Back",
              onPressed: () => _showOfferDialog(context),
              bordered: true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CustomButton(
              title: "Accept Offer",
              onPressed: () => _showAcceptDialog(context),
            ),
          ),
        ],
      );
    }

    // --- Rejected / Pending Offers ---
    // For rejected offers, the buyer can make a new offer (if they want to negotiate again).
    // For pending, no action is needed, but we provide a "Make Offer" button for rejected/pending (re-offer).
    if (widget.offer.status == OfferStatus.rejected ||
        widget.offer.status == OfferStatus.pending) {
      return Row(
        // UPDATE: Replaced spacing: 8 with SizedBox
        children: [
          Expanded(
            child: CustomButton(
              title: "Marketplace",
              onPressed: () {
                context.go("/buyer");
              },
              bordered: true,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CustomButton(
              title: "Make Offer",
              onPressed: () => _showOfferDialog(context),
            ),
          ),
        ],
      );
    }

    // Default case (e.g., status is unknown/invalid)
    return Container();
  }

  // ---- Dialogs ----
  void _showOfferDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
        constraints: const BoxConstraints(maxWidth: 500, minWidth: 450),
        title: Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        content: Form(
          key: widget.formKey,
          child: Column(
            // UPDATE: Replaced spacing: 16 with SizedBox
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
                      onChanged: (newWeight) {
                        setState(() {
                          _calculatedPricePerKg = calculatePricePerKg(
                            _weightController,
                            _priceController,
                          );
                        });
                      }, // ADDED: Recalculate on change
                    ),
                    NumberInputField(
                      controller: _priceController,
                      label: "Total",
                      suffix: "CFA",
                      onChanged: (newPrice) {
                        setState(() {
                          _calculatedPricePerKg = calculatePricePerKg(
                            _weightController,
                            _priceController,
                          );
                        });
                      }, // ADDED: Recalculate on change
                    ),
                    NumberInputField(
                      controller: _pricePerKgController,
                      label: "Price/Kg",
                      suffix: "CFA",
                      value:
                          _calculatedPricePerKg, // UPDATED: Use the calculated value
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                title: "Send Offer",
                onPressed: () {
                  if (widget.formKey.currentState!.validate()) {
                    // TODO: Send offer/counter offer logic
                    context.pop();
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
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
                          // UPDATE: Replaced spacing: 16 with SizedBox
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Center(
                              child: Text(
                                "Offer Sent",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0A2A45),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                              title: "Ok",
                              onPressed: () {
                                //TODO: Update status/navigation after offer sent
                                context.pop();
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

  // Dialog for accepting a Fisher's counter-offer
  void _showAcceptDialog(BuildContext context) {
    final counterOffer = widget.offer.previousCounterOffer;

    if (counterOffer == null) {
      // This should not happen if status is 'countered'
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.textBlue, width: 2),
          ),
          child: const Icon(Icons.question_mark_outlined),
        ),
        content: Column(
          // UPDATE: Replaced spacing: 16 with SizedBox
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textBlue,
                  ),
                  children: [
                    const TextSpan(text: "Accept the Fisher's offer of "),
                    TextSpan(
                      // Use the counter offer's weight and price
                      text: "${counterOffer.weight.toInt()} Kg ",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A2A45),
                      ),
                    ),
                    const TextSpan(text: "at "),
                    TextSpan(
                      text: "${counterOffer.price.toInt()} CFA ? ",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A2A45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              title: "Yes",
              onPressed: () {
                // TODO: Accept counter offer logic (updates offer status to accepted)
                context.pop();
                context.pushReplacement(
                  "/buyer/congratulations/${widget.offer.offerId}",
                );
              },
            ),
            const SizedBox(height: 16),
            CustomButton(
              title: "No",
              cancel: true,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
