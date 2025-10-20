import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/widgets/counter_offer_dialog.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/number_input_field.dart';
import 'package:siren_marketplace/features/buyer/logic/buyer_offer_details_bloc/offer_details_bloc.dart';
import 'package:siren_marketplace/features/fisher/logic/offer_bloc/offer_bloc.dart';

Future<void> showActionSuccessDialog(
  BuildContext context, {
  required String message,
  String? actionTitle,
  VoidCallback? onAction,
  int autoCloseSeconds = 3,
}) async {
  if (!context.mounted) return;
  showDialog(
    context: context,
    barrierDismissible: actionTitle == null,
    builder: (ctx) {
      // <--- The local dialog context
      if (autoCloseSeconds > 0 && actionTitle == null) {
        Future.delayed(Duration(seconds: autoCloseSeconds), () {
          if (ctx.mounted) Navigator.of(ctx).pop();
        });
      }

      return AlertDialog(
        title: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.textBlue,
            border: Border.all(color: AppColors.textBlue, width: 2),
          ),
          child: const Icon(Icons.check, color: AppColors.textWhite),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.textBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (actionTitle != null && onAction != null)
              // Use ctx to pop the dialog first, then call onAction.
              CustomButton(
                title: actionTitle,
                onPressed: () {
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop(); // 1. Close the dialog safely
                    onAction(); // 2. Execute the navigation
                  }
                },
              ),
          ],
        ),
      );
    },
  );
}

class OfferActions extends StatefulWidget {
  const OfferActions({
    super.key,
    required this.offer, // Still passed for initial data, but BLoC handles state
    required this.formKey,
  });

  final Offer offer;
  final GlobalKey<FormState> formKey;

  @override
  State<OfferActions> createState() => _OfferActionsState();
}

class _OfferActionsState extends State<OfferActions> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _pricePerKgController = TextEditingController();
  double _calculatedPricePerKg = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current offer details if it's a counter-back scenario
    if (widget.offer.status == OfferStatus.countered) {
      _weightController.text = widget.offer.weight.toStringAsFixed(1);
      _priceController.text = widget.offer.price.toStringAsFixed(0);
      _calculatedPricePerKg = calculatePricePerKg(
        _weightController,
        _priceController,
      );
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _priceController.dispose();
    _pricePerKgController.dispose();
    super.dispose();
  }

  double calculatePricePerKg(
    TextEditingController weight,
    TextEditingController price,
  ) {
    final w = double.tryParse(weight.text) ?? 0.0;
    final p = double.tryParse(price.text) ?? 0.0;
    return (w > 0) ? p / w : 0.0;
  }

  // Helper to dispatch the CounterOffer event
  void _sendCounterOffer(bool isCounter) {
    if (widget.formKey.currentState!.validate()) {
      final weight = double.tryParse(_weightController.text) ?? 0.0;
      final price = double.tryParse(_priceController.text) ?? 0.0;

      // Close the dialog
      context.pop();

      // Dispatch the BLoC event
      context.read<OfferDetailsBloc>().add(
        SendCounterOffer(
          offerId: widget.offer.id,
          newWeight: weight,
          newPrice: price,
          // isCounter determines if it's a new offer or a counter-back
          isCounter: isCounter || widget.offer.status == OfferStatus.countered,
        ),
      );
    }
  }

  // Helper to dispatch the AcceptOffer event
  void _acceptOffer() {
    // Close the dialog
    context.pop();

    // Dispatch the BLoC event
    context.read<OfferDetailsBloc>().add(AcceptOffer(offerId: widget.offer.id));
  }

  @override
  Widget build(BuildContext context) {
    // 🆕 Use BlocConsumer to handle UI build based on status and navigation based on side effects
    return BlocConsumer<OfferDetailsBloc, OfferDetailsState>(
      // We only want to rebuild the UI when the status changes, which is in OfferDetailsLoaded
      buildWhen: (previous, current) =>
          (previous is OfferDetailsLoaded && current is OfferDetailsLoaded) &&
          previous.offer.status != current.offer.status,
      listener: (context, state) {
        if (state is OfferDetailsLoading) {
          // Show a loading indicator overlay if needed, but usually handled by parent BLoC
        }

        // 🆕 Handle navigation after successful transaction (Accept/Counter)
        if (state is OfferDetailsLoaded) {
          final currentOfferStatus = state.offer.status;

          // After accepting, navigate to the congratulations screen
          if (currentOfferStatus == OfferStatus.accepted) {
            context.pushReplacement("/buyer/congratulations/${state.offer.id}");
          }

          // After sending a counter/new offer, show success dialog
          if (currentOfferStatus == OfferStatus.pending &&
              state.offer.id != widget.offer.id) {
            _showSuccessDialog(context);
          }
        }

        // Handle errors in a Snack bar or specific dialog
        if (state is OfferDetailsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Action Failed: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        if (state is! OfferDetailsLoaded) {
          return const SizedBox.shrink();
        }

        final currentOffer = state.offer;
        // 🆕 Get the Fisher ID directly from the BLoC state
        final fisherContactId = state.fisher.id;

        // --- Accepted Offers (Finalized Negotiation) ---
        if (currentOffer.status == OfferStatus.accepted) {
          return Row(
            children: [
              Expanded(
                child: CustomButton(
                  title: "Message",
                  onPressed: () {
                    context.push("/buyer/chat/$fisherContactId");
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
                    // TODO: Implement call functionality using fisherContactId
                  },
                  icon: Icons.phone_outlined,
                ),
              ),
            ],
          );
        }

        // --- Completed Offers ---
        if (currentOffer.status == OfferStatus.completed) {
          return Row(
            children: [
              Expanded(
                child: CustomButton(
                  title: "Rate Fisher",
                  onPressed: () {
                    // TODO: Implement Fisher rating logic
                  },
                ),
              ),
            ],
          );
        }

        // --- Countered Offer (Action required by Buyer) ---
        if (currentOffer.status == OfferStatus.countered) {
          return Row(
            children: [
              Expanded(
                child: CustomButton(
                  title: "Counter Back",
                  onPressed: () {
                    showCounterOfferDialog(
                      context: context,
                      role: Role.buyer,
                      formKey: widget.formKey,
                      initialWeight: widget.offer.weight,
                      initialPrice: widget.offer.price,
                      onSubmit: (newWeight, newPrice, dialogCtx) async {
                        if (Navigator.of(dialogCtx).canPop()) {
                          Navigator.of(dialogCtx).pop();
                        }

                        context.read<OffersBloc>().add(
                          CounterOfferEvent(widget.offer, newPrice, newWeight),
                        );

                        await showActionSuccessDialog(
                          dialogCtx,
                          message: 'Counter-Offer Sent!',
                          actionTitle: 'Offer details',
                          onAction: () {
                            dialogCtx.pushReplacement(
                              '/buyer/order-details/${widget.offer.id}',
                            );
                          },
                        );
                      },
                    );
                  },

                  bordered: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomButton(
                  title: "Accept Offer",
                  onPressed: () => _showAcceptDialog(context, currentOffer),
                ),
              ),
            ],
          );
        }

        // --- Rejected / Pending Offers (Buyer's turn to act) ---
        if (currentOffer.status == OfferStatus.rejected ||
            currentOffer.status == OfferStatus.pending) {
          return Row(
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
                  onPressed: () => _showOfferDialog(context, isCounter: false),
                ),
              ),
            ],
          );
        }

        // Default case (e.g., status is unknown/invalid)
        return const SizedBox.shrink();
      },
    );
  }

  // ---- Dialogs ----
  void _showOfferDialog(BuildContext context, {bool isCounter = false}) {
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
                      },
                    ),
                    const SizedBox(height: 16),
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
                      },
                    ),
                    const SizedBox(height: 16),
                    NumberInputField(
                      controller: _pricePerKgController,
                      label: "Price/Kg",
                      suffix: "CFA",
                      value: _calculatedPricePerKg,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                title: isCounter ? "Send Counter Offer" : "Send Offer",
                // 🆕 Call the helper function that dispatches the event
                onPressed: () => _sendCounterOffer(isCounter),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dialog for accepting a Fisher's counter-offer
  void _showAcceptDialog(BuildContext context, Offer offerToAccept) {
    // Use the details of the offer passed from the BLoC state
    final weight = offerToAccept.weight.toStringAsFixed(1);
    final price = offerToAccept.price.toStringAsFixed(0);

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
                      text: "$weight Kg ",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlue,
                      ),
                    ),
                    const TextSpan(text: "at "),
                    TextSpan(
                      text: "$price CFA ? ",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              title: "Yes",
              // 🆕 Call the helper function that dispatches the event and handles navigation
              onPressed: _acceptOffer,
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

  // 🆕 New success dialog to confirm offer/counter was sent
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.textBlue,
            border: Border.all(color: AppColors.textBlue, width: 2),
          ),
          child: const Icon(Icons.check, color: AppColors.textWhite),
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
            CustomButton(
              title: "Ok",
              onPressed: () {
                // Return to the offer details screen
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
