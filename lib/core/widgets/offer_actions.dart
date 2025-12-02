import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/repositories/i_order_repository.dart';
import 'package:siren_marketplace/core/domain/repositories/i_user_repository.dart';
import 'package:siren_marketplace/core/domain/value_objects/offer_terms.dart';
import 'package:siren_marketplace/core/domain/value_objects/price.dart';
import 'package:siren_marketplace/core/domain/value_objects/weight.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/widgets/counter_offer_dialog.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/features/fisher/logic/offers_bloc/offers_cubit.dart';

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
  final IUserRepository _userRepository = sl<IUserRepository>();

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleAccept(BuildContext confirmDialogContext) async {
    if (Navigator.of(confirmDialogContext).canPop()) {
      Navigator.of(confirmDialogContext).pop();
    }

    if (!context.mounted) return;
    showLoadingDialog(context, message: 'Loading...');

    try {
      final fisherUser = await _userRepository.getById(widget.offer.fisherId);

      if (fisherUser == null) {
        if (!context.mounted) return;
        Navigator.of(context).pop();
        await showActionSuccessDialog(
          context,
          message: 'Fisher not found',
          autoCloseSeconds: 3,
        );
        return;
      }

      if (!mounted) return;

      final navigator = Navigator.of(context);

      // Await the action
      await context.read<OffersCubit>().acceptOffer(
        widget.offer.id,
        widget.currentUserRole,
      );

      // Dismiss loading dialog
      if (navigator.mounted) {
        navigator.pop();
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss loading dialog on error too
      await showActionSuccessDialog(
        context,
        message: 'Accept failed: ${e.toString()}',
        autoCloseSeconds: 3,
      );
    }
  }

  Future<void> _handleReject(BuildContext outerContext) async {
    if (Navigator.of(outerContext).canPop()) Navigator.of(outerContext).pop();
    if (!mounted) return;
    showLoadingDialog(context, message: 'Creating order...');

    final navigator = Navigator.of(context);

    try {
      // Await the action
      await context.read<OffersCubit>().rejectOffer(
        widget.offer.id,
        widget.currentUserRole,
      );

      // Dismiss loading dialog
      if (navigator.mounted) {
        navigator.pop();
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading dialog
        await showActionSuccessDialog(
          context,
          message: 'Reject failed: $e',
          autoCloseSeconds: 3,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.offer.status == OfferStatus.pending ||
            (widget.offer.hasBeenCountered &&
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
                                    // UPDATED: Convert Grams to Kg for display
                                    "${widget.offer.currentTerms.weight.kilograms} Kg / ${formatPrice(widget.offer.currentTerms.totalPrice.amount)}",
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
                                  // UPDATED: Convert Grams to Kg for display
                                  "${widget.offer.currentTerms.weight.kilograms} Kg / ${formatPrice(widget.offer.currentTerms.totalPrice.amount)}",
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
                        bordered: true,
                        onPressed: () {
                          showCounterOfferDialog(
                            context: context,
                            role: widget.currentUserRole,
                            formKey: widget.formKey,
                            // UPDATED: Pass weight in Grams directly
                            initialWeight:
                                widget.offer.currentTerms.weight.grams,
                            initialPrice:
                                widget.offer.currentTerms.totalPrice.amount,
                            onSubmit: (newWeight, newPrice, dialogCtx) async {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
                              if (!mounted) return;
                              showLoadingDialog(
                                context,
                                message: 'Creating order...',
                              );

                              final navigator = Navigator.of(context);

                              try {
                                await context.read<OffersCubit>().counterOffer(
                                  widget.offer.id,
                                  widget.currentUserRole,
                                  OfferTerms.create(
                                    weight: Weight.fromGrams(newWeight),
                                    totalPrice: Price.fromAmount(newPrice),
                                  ),
                                );

                                // Dismiss loading dialog
                                if (navigator.mounted) {
                                  navigator.pop();
                                }
                              } catch (e) {
                                if (mounted) {
                                  Navigator.of(
                                    context,
                                  ).pop(); // Dismiss loading dialog
                                  await showActionSuccessDialog(
                                    context,
                                    message: 'Counter failed: $e',
                                    autoCloseSeconds: 3,
                                  );
                                }
                              }
                            },
                          );
                        },
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
        : (widget.offer.status == OfferStatus.accepted)
        ? FutureBuilder<String?>(
            future: sl<IOrderRepository>()
                .getByOfferId(widget.offer.id)
                .then((order) => order?.id),
            builder: (context, snapshot) {
              final orderId = snapshot.data;
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;

              return CustomButton(
                title: isLoading ? "Loading..." : "View Order Details",
                onPressed: orderId != null && !isLoading
                    ? () {
                        widget.onNavigateToOrder(orderId);
                      }
                    : () {}, // Disabled state
              );
            },
          )
        : Container();
  }
}
