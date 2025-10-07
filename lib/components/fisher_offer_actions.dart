import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/components/custom_button.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart' show FisherOffer;

import 'number_input_field.dart';

class FisherOfferActions extends StatelessWidget {
  const FisherOfferActions({
    super.key,
    required this.offer,
    required this.formKey,
  });

  final FisherOffer offer;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Reject Button
        TextButton(
          onPressed: () => _showRejectDialog(context),
          child: const Text(
            "Reject offer",
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),

        // Counter Offer Button
        TextButton(
          onPressed: () => _showCounterOfferDialog(context),
          child: const Text(
            "Counter-Offer",
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),

        // Accept Button
        CustomButton(
          title: "Accept",
          onPressed: () => _showAcceptDialog(context),
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
            border: Border.all(color: AppColors.textBlue, width: 2),
          ),
          child: const Icon(Icons.question_mark_outlined),
        ),
        content: Column(
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                "Reject Offer",
                style: TextStyle(fontSize: 16, color: AppColors.textBlue),
              ),
            ),
            CustomButton(
              title: "Yes",
              onPressed: () {
                // TODO: Reject offer logic
                context.pop();
              },
            ),
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

  void _showCounterOfferDialog(BuildContext context) {
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
          key: formKey,
          child: Column(
            spacing: 16,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textBlue),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    NumberInputField(label: "Weight", suffix: "Kg"),
                    NumberInputField(label: "Total", suffix: "CFA"),
                    NumberInputField(label: "Price/Kg", suffix: "CFA"),
                  ],
                ),
              ),
              CustomButton(
                title: "Send Counter-Offer",
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // TODO: Send counter offer
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
                          spacing: 16,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Text(
                                "Offer Sent",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0A2A45),
                                ),
                              ),
                            ),
                            CustomButton(
                              title: "Ok",
                              onPressed: () {
                                //TODO: Go to congratulations page
                                context.pop();
                                context.pushReplacement(
                                  "/fisher/congratulations/${offer.offerId}",
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

  void _showAcceptDialog(BuildContext context) {
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
          spacing: 16,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textBlue,
                  ),
                  children: [
                    const TextSpan(text: "Accept "),
                    TextSpan(
                      text: "${offer.weight} Kg ",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A2A45),
                      ),
                    ),
                    const TextSpan(text: "at "),
                    TextSpan(
                      text: "${offer.price} CFA ?",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A2A45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            CustomButton(
              title: "Yes",
              onPressed: () {
                // TODO: Accept offer logic
                context.pop();
                context.pushReplacement(
                  "/fisher/congratulations/${offer.offerId}",
                );
              },
            ),
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
