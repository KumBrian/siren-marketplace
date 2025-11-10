import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/models/catch.dart' as CatchModel;
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/widgets/counter_offer_dialog.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';
import 'package:siren_marketplace/features/fisher/data/order_repository.dart';
import 'package:siren_marketplace/features/fisher/logic/catch_bloc/catch_bloc.dart';
import 'package:siren_marketplace/features/fisher/logic/offers_bloc/offers_bloc.dart';
import 'package:siren_marketplace/features/user/logic/user_bloc/user_bloc.dart';

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
  });

  final Offer offer;
  final GlobalKey<FormState> formKey;
  final Role currentUserRole;
  final void Function(String offerId) onNavigateToOrder;

  @override
  State<OfferActions> createState() => _OfferActionsState();
}

class _OfferActionsState extends State<OfferActions> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _pricePerKgController = TextEditingController();

  final UserRepository _userRepository = sl<UserRepository>();

  @override
  void dispose() {
    _weightController.dispose();
    _priceController.dispose();
    _pricePerKgController.dispose();
    super.dispose();
  }

  CatchModel.Catch? _findCatchFromBloc(String catchId) {
    final catchesState = context.read<CatchesBloc>().state;
    if (catchesState is! CatchesLoaded) return null;

    try {
      return catchesState.catches.firstWhere((c) => c.id == catchId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleAccept(BuildContext confirmDialogContext) async {
    if (Navigator.of(confirmDialogContext).canPop()) {
      Navigator.of(confirmDialogContext).pop();
    }

    final catchItem = _findCatchFromBloc(widget.offer.catchId);
    if (catchItem == null) {
      if (context.mounted) {
        await showActionSuccessDialog(
          context,
          message: 'Related catch not found',
          autoCloseSeconds: 2,
        );
      }
      return;
    }

    if (!context.mounted) return;
    showLoadingDialog(context, message: 'Creating order...');

    try {
      final fisherMap = await _userRepository.getUserMapById(
        widget.offer.fisherId,
      );

      if (!context.mounted) return;

      if (fisherMap == null) {
        Navigator.of(context).pop();
        throw Exception('Fisher data not found.');
      }

      final fisher = Fisher.fromMap(fisherMap);

      context.read<OffersBloc>().add(
        AcceptOffer(
          offer: widget.offer,
          catchItem: catchItem,
          fisher: fisher,
          orderRepository: sl<OrderRepository>(),
        ),
      );
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
    showLoadingDialog(context, message: 'Creating order...');
    try {
      context.read<OffersBloc>().add(RejectOffer(offer: widget.offer));
    } catch (e) {
      if (outerContext.mounted) {
        await showActionSuccessDialog(
          outerContext,
          message: 'Reject failed: $e',
          autoCloseSeconds: 3,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.offer.status == OfferStatus.pending ||
            (widget.offer.previousPricePerKg != null &&
                widget.offer.status == OfferStatus.pending)
        ? Column(
            children: [
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
                                  "${widget.offer.weight.toInt()} Kg / ${formatPrice(widget.offer.price)}",
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
                      child: BlocBuilder<UserBloc, UserState>(
                        builder: (context, state) {
                          if (state is UserLoaded) {
                            final user = state.user;
                            return CustomButton(
                              title: "Counter-Offer",
                              icon: Icons.autorenew_rounded,
                              onPressed: () {
                                showCounterOfferDialog(
                                  context: context,
                                  role: user!.role,
                                  formKey: widget.formKey,
                                  initialWeight: widget.offer.weight,
                                  initialPrice: widget.offer.price,
                                  onSubmit:
                                      (newWeight, newPrice, dialogCtx) async {
                                        if (Navigator.of(context).canPop()) {
                                          Navigator.of(context).pop();
                                        }
                                        if (!context.mounted) return;
                                        showLoadingDialog(
                                          context,
                                          message: 'Creating order...',
                                        );
                                        try {
                                          context.read<OffersBloc>().add(
                                            CounterOffer(
                                              previousOffer: widget.offer,
                                              newPrice: newPrice,
                                              newWeight: newWeight,
                                              counteringRole: user.role,
                                            ),
                                          );
                                        } catch (e) {
                                          if (context.mounted) {
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

                              bordered: true,
                            );
                          }
                          return Container();
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ],
          )
        : widget.offer.status == OfferStatus.accepted ||
              widget.offer.status == OfferStatus.completed
        ? CustomButton(
            title: "Order Details",
            onPressed: () {
              widget.onNavigateToOrder(widget.offer.id);
            },
          )
        : Container();
  }
}
