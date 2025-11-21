import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/widgets/counter_offer_dialog.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/new_core/domain/entities/catch.dart';
import 'package:siren_marketplace/new_core/domain/entities/offer.dart';
import 'package:siren_marketplace/new_core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/new_core/domain/enums/user_role.dart';
import 'package:siren_marketplace/new_core/domain/value_objects/offer_terms.dart';
import 'package:siren_marketplace/new_core/domain/value_objects/price.dart';
import 'package:siren_marketplace/new_core/domain/value_objects/price_per_kg.dart';
import 'package:siren_marketplace/new_core/domain/value_objects/weight.dart';
import 'package:siren_marketplace/new_core/presentation/cubits/auth/auth_cubit.dart';
import 'package:siren_marketplace/new_core/presentation/cubits/auth/auth_state.dart';
import 'package:siren_marketplace/new_features/fisher/presentation/cubits/offer_detail/offer_detail_cubit.dart';
import 'package:siren_marketplace/new_features/fisher/presentation/cubits/offer_detail/offer_detail_state.dart';

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
    barrierDismissible: true,
    builder: (ctx) {
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
              CustomButton(
                title: actionTitle,
                onPressed: () {
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                    onAction();
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
    required this.offer,
    required this.formKey,
    required this.currentUserRole,
    required this.onNavigateToOrder,
    required this.catchItem,
  });

  final Offer offer;
  final GlobalKey<FormState> formKey;
  final UserRole currentUserRole;
  final void Function(String orderId) onNavigateToOrder;
  final Catch catchItem;

  @override
  State<OfferActions> createState() => _OfferActionsState();
}

class _OfferActionsState extends State<OfferActions> {
  // Helper to display grams as Kg cleanly (1500 -> "1.5")
  String _displayWeightInKg(int weightInGrams) {
    return (weightInGrams / 1000)
        .toStringAsFixed(2)
        .replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
  }

  Future<void> _handleAccept(BuildContext confirmDialogContext) async {
    if (Navigator.of(confirmDialogContext).canPop()) {
      Navigator.of(confirmDialogContext).pop();
    }

    if (!context.mounted) return;
    showLoadingDialog(context, message: 'Accepting offer...');

    try {
      // Get current user ID from AuthCubit
      final authState = context.read<AuthCubit>().state;
      final userId = authState is AuthAuthenticated ? authState.user.id : '';

      await context.read<OfferDetailCubit>().acceptOffer(userId);

      if (!context.mounted) return;

      // Listen for state changes
      final state = context.read<OfferDetailCubit>().state;
      if (state is OfferDetailLoaded && state.linkedOrder != null) {
        // Close loading dialog
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        await showActionSuccessDialog(
          context,
          message: "Offer Successfully Accepted.",
          actionTitle: "View Details",
          onAction: () {
            widget.onNavigateToOrder(state.linkedOrder!.id);
          },
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      await showActionSuccessDialog(
        context,
        message: 'Accept failed: ${e.toString()}',
        autoCloseSeconds: 3,
      );
    }
  }

  Future<void> _handleReject(BuildContext outerContext) async {
    if (Navigator.of(outerContext).canPop()) Navigator.of(outerContext).pop();
    if (!context.mounted) return;
    showLoadingDialog(context, message: 'Rejecting offer...');

    try {
      // Get current user ID from AuthCubit
      final authState = context.read<AuthCubit>().state;
      final userId = authState is AuthAuthenticated ? authState.user.id : '';

      await context.read<OfferDetailCubit>().rejectOffer(userId);

      if (!context.mounted) return;
      Navigator.of(context).pop();

      await showActionSuccessDialog(
        context,
        message: 'Offer Rejected!',
        autoCloseSeconds: 3,
      );
    } catch (e) {
      if (outerContext.mounted) {
        Navigator.of(context).pop();
        await showActionSuccessDialog(
          outerContext,
          message: 'Reject failed: $e',
          autoCloseSeconds: 3,
        );
      }
    }
  }

  Future<void> _handleCounter(int newWeightGrams, int newPriceAmount) async {
    if (!context.mounted) return;
    showLoadingDialog(context, message: 'Sending counter-offer...');

    try {
      // Get current user ID from AuthCubit
      final authState = context.read<AuthCubit>().state;
      final userId = authState is AuthAuthenticated ? authState.user.id : '';

      // Create new OfferTerms
      final newTerms = OfferTerms.create(
        weight: Weight.fromGrams(newWeightGrams),
        totalPrice: Price.fromAmount(newPriceAmount),
      );

      await context.read<OfferDetailCubit>().counterOffer(
        userId: userId,
        newTerms: newTerms,
      );

      if (!context.mounted) return;
      Navigator.of(context).pop();

      await showActionSuccessDialog(
        context,
        message: 'Counter-Offer Sent!',
        autoCloseSeconds: 3,
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        await showActionSuccessDialog(
          context,
          message: 'Counter failed: $e',
          autoCloseSeconds: 3,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.offer.status == OfferStatus.pending ||
            (widget.offer.previousTerms != null &&
                widget.offer.status == OfferStatus.pending)
        ? Column(
            children: [
              if (widget.offer.status == OfferStatus.pending &&
                  widget.offer.waitingFor == widget.currentUserRole) ...[
                CustomButton(
                  title: "Accept",
                  icon: Icons.check,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (confirmCtx) => AlertDialog(
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
                                    "${_displayWeightInKg(widget.offer.currentTerms.weight.grams)} Kg / ${formatPrice(widget.offer.currentTerms.totalPrice.amount)}",
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
                const SizedBox(height: 8),
              ],

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: CustomButton(
                      title: "Reject",
                      icon: Icons.close,
                      onPressed: () {
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "Reject the offer?",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textBlue,
                                  ),
                                ),
                                Text(
                                  "${_displayWeightInKg(widget.offer.currentTerms.weight.grams)} Kg / ${formatPrice(widget.offer.currentTerms.totalPrice.amount)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
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

                  if (widget.offer.waitingFor == widget.currentUserRole) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        title: "Counter-Offer",
                        icon: Icons.autorenew_rounded,
                        onPressed: () {
                          showCounterOfferDialog(
                            context: context,
                            role: widget.currentUserRole,
                            formKey: widget.formKey,
                            initialWeight:
                                widget.offer.currentTerms.weight.grams,
                            initialPrice:
                                widget.offer.currentTerms.totalPrice.amount,
                            onSubmit: (newWeight, newPrice, dialogCtx) async {
                              if (Navigator.of(dialogCtx).canPop()) {
                                Navigator.of(dialogCtx).pop();
                              }
                              await _handleCounter(newWeight, newPrice);
                            },
                          );
                        },
                        bordered: true,
                      ),
                    ),
                  ],
                ],
              ),

              if (widget.offer.waitingFor != widget.currentUserRole) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                      color: AppColors.shellOrange,
                      size: 20,
                    ),
                    Text(
                      "Please wait for the ${widget.offer.waitingFor!.name} to respond.",
                    ),
                  ],
                ),
              ],
            ],
          )
        : widget.offer.status == OfferStatus.accepted
        ? BlocBuilder<OfferDetailCubit, OfferDetailState>(
            builder: (context, state) {
              if (state is OfferDetailLoaded && state.linkedOrder != null) {
                return CustomButton(
                  title: "Order Details",
                  onPressed: () {
                    widget.onNavigateToOrder(state.linkedOrder!.id);
                  },
                );
              }
              return Container();
            },
          )
        : Container();
  }
}
