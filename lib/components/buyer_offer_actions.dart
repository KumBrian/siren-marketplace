import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/components/custom_button.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart'
    show BuyerOffer, OfferStatus;

import 'number_input_field.dart';

class BuyerOfferActions extends StatelessWidget {
  const BuyerOfferActions({
    super.key,
    required this.offer,
    required this.formKey,
  });

  final BuyerOffer offer;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return offer.status == OfferStatus.accepted
        ? Row(
            spacing: 8,
            children: [
              Expanded(
                child: CustomButton(
                  title: "Message",
                  onPressed: () {},
                  icon: Icons.chat_bubble_outline_rounded,

                  bordered: true,
                ),
              ),
              Expanded(
                child: CustomButton(
                  title: "Call",
                  onPressed: () {},
                  icon: Icons.phone_outlined,
                ),
              ),
            ],
          )
        : offer.status == OfferStatus.rejected
        ? Row(
            spacing: 8,
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
              Expanded(
                child: CustomButton(
                  title: "Make Offer",
                  onPressed: () => _showOfferDialog(context),
                ),
              ),
            ],
          )
        : offer.status == OfferStatus.completed
        ? Row(
            children: [
              Expanded(
                child: CustomButton(title: "Rate Fisher", onPressed: () {}),
              ),
            ],
          )
        : Container();
  }

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
                title: "Send Offer",
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
                                  "/buyer/congratulations/${offer.offerId}",
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
}
