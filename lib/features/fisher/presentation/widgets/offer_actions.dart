import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/models/catch.dart' as CatchModel;
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/number_input_field.dart';
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';
import 'package:siren_marketplace/features/fisher/logic/catch_bloc/catch_bloc.dart';
import 'package:siren_marketplace/features/fisher/logic/offer_bloc/offer_bloc.dart';

// Helper: show a small modal progress indicator (MOVED TO TOP-LEVEL)
void showLoadingDialog(BuildContext context, {String message = 'Please wait'}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      content: Row(
        children: [
          const SizedBox(width: 8),
          const CircularProgressIndicator(),
          const SizedBox(width: 16),
          Expanded(child: Text(message)),
        ],
      ),
    ),
  );
}

// Helper: reusable success dialog (MOVED TO TOP-LEVEL)
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
  const OfferActions({super.key, required this.offer, required this.formKey});

  final Offer offer;
  final GlobalKey<FormState> formKey;

  @override
  State<OfferActions> createState() => _OfferActionsState();
}

class _OfferActionsState extends State<OfferActions> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _pricePerKgController = TextEditingController();

  double _calculatedPricePerKg = 0;
  final UserRepository _userRepository = sl<UserRepository>();

  @override
  void dispose() {
    _weightController.dispose();
    _priceController.dispose();
    _pricePerKgController.dispose();
    super.dispose();
  }

  // Retrieves the Catch model from the CatchesBloc (synchronously from state)
  CatchModel.Catch? _findCatchFromBloc(String catchId) {
    final catchesState = context.read<CatchesBloc>().state;
    if (catchesState is! CatchesLoaded) return null;

    // ⚠️ FIX: Use the firstWhereOrNull extension to avoid the bad cast
    // Note: Assuming firstWhereOrNull is available via an import or extension,
    // otherwise, use a standard loop or try/catch around firstWhere.
    try {
      return catchesState.catches.firstWhere((c) => c.id == catchId);
    } catch (_) {
      return null;
    }
  }

  // Accept flow:
  // 1. gather required Catch and Fisher
  // 2. dispatch AcceptOfferEvent(offer, catch, fisher)
  Future<void> _handleAccept(BuildContext outerContext) async {
    // 1. If any prior dialog is open (e.g., confirmation dialog), close it.
    if (Navigator.of(outerContext).canPop()) Navigator.of(outerContext).pop();

    final catchItem = _findCatchFromBloc(widget.offer.catchId);
    if (catchItem == null) {
      if (!outerContext.mounted) return;
      await showActionSuccessDialog(
        // Using top-level function
        outerContext,
        message: 'Related catch not found',
        autoCloseSeconds: 2,
      );
      return;
    }

    // 2. Show loading dialog, which must be closed by the BLoC Listener on success/failure.
    showLoadingDialog(
      outerContext,
      message: 'Creating order...',
    ); // Using top-level function

    try {
      final fisherMap = await _userRepository.getUserMapById(
        widget.offer.fisherId,
      );
      if (fisherMap == null) {
        if (outerContext.mounted) {
          Navigator.of(outerContext).pop(); // close loading
          await showActionSuccessDialog(
            // Using top-level function
            outerContext,
            message: 'Fisher not found',
            autoCloseSeconds: 2,
          );
        }
        return;
      }

      final fisher = Fisher.fromMap(fisherMap);

      // 3. Dispatch event
      if (context.mounted) {
        context.read<OffersBloc>().add(
          AcceptOfferEvent(widget.offer, catchItem, fisher),
        );
      }

      // CRITICAL: The BLoC Listener in FisherOfferDetails handles the subsequent action and UI.
    } catch (e) {
      // 4. Handle sync error and close loading dialog if open
      if (outerContext.mounted) {
        Navigator.of(outerContext).pop();
        await showActionSuccessDialog(
          // Using top-level function
          outerContext,
          message: 'Accept failed: $e',
          autoCloseSeconds: 3,
        );
      }
    }
  }

  // Reject flow: fire event immediately and show short confirmation
  Future<void> _handleReject(BuildContext outerContext) async {
    if (Navigator.of(outerContext).canPop()) Navigator.of(outerContext).pop();
    try {
      context.read<OffersBloc>().add(RejectOfferEvent(widget.offer));
      await showActionSuccessDialog(
        // Using top-level function
        outerContext,
        message: 'Offer Rejected!',
        autoCloseSeconds: 3,
      );
    } catch (e) {
      if (outerContext.mounted) {
        await showActionSuccessDialog(
          // Using top-level function
          outerContext,
          message: 'Reject failed: $e',
          autoCloseSeconds: 3,
        );
      }
    }
  }

  void _initializeCounterState() {
    // 1. Reset state (we don't clear weight as it is handled by the NumberInputField now)
    _priceController.clear();
    _pricePerKgController.clear();
    _calculatedPricePerKg = 0.0;

    // 2. Set initial Total Price (Editable)
    final initialPrice = widget.offer.price;
    if (initialPrice > 0.0) {
      _priceController.text = initialPrice.toStringAsFixed(0);
    }

    final initialWeight = widget.offer.weight;
    if (initialWeight > 0) {
      _calculatedPricePerKg = initialPrice / initialWeight;
      _pricePerKgController.text = _calculatedPricePerKg.toStringAsFixed(0);
    }
  }

  Future<void> _handleSendCounter(BuildContext dialogContext) async {
    if (!widget.formKey.currentState!.validate()) return;

    final newWeight = double.tryParse(_weightController.text) ?? 0.0;
    final newPrice = double.tryParse(_priceController.text) ?? 0.0;

    if (newWeight <= 0 || newPrice <= 0) {
      if (dialogContext.mounted) {
        await showActionSuccessDialog(
          // Using top-level function
          dialogContext,
          message: 'Invalid price or weight',
          autoCloseSeconds: 2,
        );
      }
      return;
    }

    // close the counter dialog
    if (Navigator.of(dialogContext).canPop()) Navigator.of(dialogContext).pop();

    // dispatch counter event (previous, newPrice, newWeight)
    try {
      context.read<OffersBloc>().add(
        CounterOfferEvent(widget.offer, newPrice, newWeight),
      );

      // show confirmation then navigate to order-details when pressed
      await showActionSuccessDialog(
        // Using top-level function
        dialogContext,
        message: 'Counter-Offer Sent!',
        actionTitle: 'Offer details',
        // The push logic here will benefit from the fix in showActionSuccessDialog as well
        onAction: () {
          if (dialogContext.mounted) {
            dialogContext.pushReplacement(
              '/fisher/order-details/${widget.offer.id}',
            );
          }
        },
      );
    } catch (e) {
      await showActionSuccessDialog(
        // Using top-level function
        dialogContext,
        message: 'Counter failed: $e',
        autoCloseSeconds: 3,
      );
    }
  }

  void _calculatePricePerKg(StateSetter localSetState) {
    final weight = double.tryParse(_weightController.text);
    final price = double.tryParse(_priceController.text);
    double newPricePerKg = 0.0;

    // Only calculate if we have valid input
    if (weight != null && weight > 0 && price != null) {
      newPricePerKg = price / weight;
    }

    if (_calculatedPricePerKg != newPricePerKg) {
      localSetState(() => _calculatedPricePerKg = newPricePerKg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          title: "Accept",
          icon: Icons.check,
          onPressed: () {
            // Show confirm dialog then call _handleAccept if confirmed
            showDialog(
              context: context,
              builder: (confirmCtx) => AlertDialog(
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            "Accept the offer?",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textBlue,
                            ),
                          ),
                          Text(
                            "${widget.offer.weight.toInt()} Kg / ${formatPrice(widget.offer.price)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppColors.textBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      title: "Accept",
                      onPressed: () => _handleAccept(confirmCtx),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      title: "Cancel",
                      cancel: true,
                      onPressed: () {
                        if (Navigator.of(confirmCtx).canPop()) {
                          Navigator.of(confirmCtx).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: CustomButton(
                title: "Reject",
                icon: Icons.close,
                onPressed: () {
                  // show confirm dialog and call _handleReject
                  showDialog(
                    context: context,
                    builder: (rejectCtx) => AlertDialog(
                      title: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.textBlue,
                            width: 3,
                          ),
                        ),
                        child: const Icon(Icons.question_mark_outlined),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            // Removed const from Text because it was causing problems
                            "Reject the offer?",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CustomButton(
                            title: "Reject",
                            onPressed: () => _handleReject(rejectCtx),
                          ),
                          const SizedBox(height: 8),
                          CustomButton(
                            title: "Cancel",
                            cancel: true,
                            onPressed: () {
                              if (Navigator.of(rejectCtx).canPop()) {
                                Navigator.of(rejectCtx).pop();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                bordered: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                title: "Counter-Offer",
                icon: Icons.autorenew_rounded,
                onPressed: () {
                  // Open counter dialog (stateful) and handle send
                  showDialog(
                    context: context,
                    builder: (dialogCtx) {
                      _initializeCounterState();

                      return AlertDialog(
                        contentPadding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          bottom: 24,
                        ),
                        constraints: const BoxConstraints(
                          maxWidth: 500,
                          minWidth: 450,
                        ),
                        title: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              if (Navigator.of(dialogCtx).canPop()) {
                                Navigator.of(dialogCtx).pop();
                              }
                            },
                          ),
                        ),
                        content: StatefulBuilder(
                          builder:
                              (
                                BuildContext statefulCtx,
                                StateSetter localSetState,
                              ) {
                                void onFieldChanged(String? _) =>
                                    _calculatePricePerKg(localSetState);

                                return Form(
                                  key: widget.formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColors.textBlue,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            NumberInputField(
                                              controller: _weightController,
                                              label: "Weight",
                                              suffix: "Kg",
                                              value: widget.offer.weight,
                                              onChanged: onFieldChanged,
                                            ),
                                            const SizedBox(height: 12),
                                            NumberInputField(
                                              controller: _priceController,
                                              label: "Total",
                                              suffix: "CFA",
                                              onChanged: onFieldChanged,
                                            ),
                                            const SizedBox(height: 12),
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
                                        title: "Send Counter-Offer",
                                        onPressed: () =>
                                            _handleSendCounter(statefulCtx),
                                      ),
                                    ],
                                  ),
                                );
                              },
                        ),
                      );
                    },
                  );
                },
                bordered: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
