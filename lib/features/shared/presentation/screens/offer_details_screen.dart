import 'dart:io';

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/value_objects/offer_terms.dart';
import 'package:siren_marketplace/core/domain/value_objects/price.dart';
import 'package:siren_marketplace/core/domain/value_objects/weight.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/utils/custom_dialogs.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/utils/phone_launcher.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/number_input_field.dart';
import 'package:siren_marketplace/core/widgets/page_title.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/shared/presentation/providers/offer_actions_provider.dart';
import 'package:siren_marketplace/features/shared/presentation/providers/shared_offer_details_provider.dart';
import 'package:siren_marketplace/features/shared/presentation/widgets/partner_card.dart';

class SharedOfferDetailsScreen extends ConsumerStatefulWidget {
  final String offerId;

  const SharedOfferDetailsScreen({super.key, required this.offerId});

  @override
  ConsumerState<SharedOfferDetailsScreen> createState() =>
      _SharedOfferDetailsScreenState();
}

class _SharedOfferDetailsScreenState
    extends ConsumerState<SharedOfferDetailsScreen> {
  bool _hasMarkedAsViewed = false;

  /// Generate conversation ID from buyer and fisher IDs
  /// This matches the logic in Conversation.generateId()
  String _generateConversationId(String buyerId, String fisherId) {
    final ids = [buyerId, fisherId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(sharedOfferDetailsProvider(widget.offerId));

    // Listen for action results
    ref.listen(offerActionsProvider, (previous, next) {
      if (next.error != null) {
        showActionSuccessDialog(
          context,
          message: next.error!,
          autoCloseSeconds: 3,
        );
      }

      if (next.successMessage != null) {
        // Handle Accept success with navigation
        if (next.createdOrder != null) {
          showActionSuccessDialog(
            context,
            message: next.successMessage!,
            actionTitle: "View Details",
            onAction: () async {
              // Navigate to order details
              final state = ref
                  .read(sharedOfferDetailsProvider(widget.offerId))
                  .valueOrNull;
              if (state != null) {
                final prefix = state.currentUserRole == UserRole.buyer
                    ? 'buyer'
                    : 'fisher';
                context.pushReplacement(
                  "/$prefix/order-details/${next.createdOrder!.id}",
                );
              }
            },
          );
        } else {
          // Handle Reject/Counter success
          showActionSuccessDialog(
            context,
            message: next.successMessage!,
            autoCloseSeconds: 3,
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const PageTitle(title: "Offer Details"),
      ),
      body: detailsAsync.when(
        data: (state) {
          // Mark as viewed once
          if (!_hasMarkedAsViewed &&
              state.offer.hasUpdateFor(state.currentUserRole)) {
            // Defer to next frame to avoid build-time state updates
            Future.microtask(() {
              ref
                  .read(offerActionsProvider.notifier)
                  .markAsViewed(state.offer.id, state.currentUserRole);
              if (mounted) {
                setState(() {
                  _hasMarkedAsViewed = true;
                });
              }
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                // 1. Header (Catch Info)
                _buildCatchHeader(context, state.catchItem, state.offer),

                // 2. Current Offer Details
                _buildCurrentOfferSection(state),

                // 3. Actions (Accept/Reject/Counter) - Only if Active
                if (state.offer.status == OfferStatus.pending)
                  _buildActionSection(context, state),

                // 4. Transaction Partner (Other Party)
                PartnerCard(
                  partner: state.otherParty,
                  myRole: state.currentUserRole,
                ),

                // 5. Rejection Message
                if (state.offer.status == OfferStatus.rejected)
                  _buildRejectionMessage(context, state),

                // 6. Accepted/Completed Actions (Call, Rate, etc.)
                if (state.offer.status == OfferStatus.accepted ||
                    state.offer.status == OfferStatus.completed)
                  _buildPostAcceptanceActions(context, state),

                // 7. Previous Counter Offer (History)
                if (state.offer.previousTerms != null)
                  _buildPreviousOfferSection(state.offer.previousTerms!),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildCatchHeader(BuildContext context, Catch catchItem, Offer offer) {
    final image = catchItem.images.firstOrNull ?? "assets/images/prawns.jpg";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            ImageProvider provider;
            if (image.startsWith("http")) {
              provider = NetworkImage(image);
            } else if (image.startsWith("assets/")) {
              provider = AssetImage(image);
            } else {
              provider = FileImage(File(image));
            }
            showImageViewer(context, provider, immersive: true);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: image.startsWith("http")
                ? Image.network(
                    image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      "assets/images/prawns.jpg",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  )
                : (image.startsWith("assets/")
                      ? Image.asset(
                          image,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            "assets/images/prawns.jpg",
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.file(
                          File(image),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            "assets/images/prawns.jpg",
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                catchItem.species.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textBlue,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.getStatusColor(offer.status),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    offer.status.name.capitalize(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getStatusColor(offer.status),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentOfferSection(SharedOfferDetailsState state) {
    final title = state.isUserTurn ? "Current Offer" : "Current Offer";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray200),
          ),
          child: InfoTable(
            rows: [
              InfoRow(
                label: "Weight",
                value: "${state.offer.currentTerms.weight.kilograms} kg",
              ),
              InfoRow(
                label: "Price/Kg",
                value: formatPrice(
                  state.offer.currentTerms.pricePerKg.amountPerKg,
                ),
              ),
              InfoRow(
                label: "Total",
                value: formatPrice(state.offer.currentTerms.totalPrice.amount),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection(
    BuildContext context,
    SharedOfferDetailsState state,
  ) {
    if (!state.isUserTurn) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.hourglass_empty, color: AppColors.textGray),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Waiting for ${state.otherParty.name} to respond...",
                style: const TextStyle(color: AppColors.textGray),
              ),
            ),
          ],
        ),
      );
    }

    final actionState = ref.watch(offerActionsProvider);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomButton(
                title: "Reject",
                disabled: actionState.isLoading,
                bordered: true,
                icon: Icons.close,
                onPressed: () => _showRejectConfirmation(context, state),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                title: "Counter-Offer",
                disabled: actionState.isLoading,
                bordered: true,
                icon: Icons.autorenew_rounded,
                onPressed: () => _showCounterOfferDialog(context, state),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            title: "Accept Offer",
            disabled: actionState.isLoading,
            onPressed: () => _showAcceptConfirmation(context, state),
          ),
        ),
      ],
    );
  }

  void _showAcceptConfirmation(
    BuildContext context,
    SharedOfferDetailsState state,
  ) {
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
                    style: TextStyle(fontSize: 16, color: AppColors.textBlue),
                  ),
                  Text(
                    "${state.offer.currentTerms.weight.kilograms} Kg / ${formatPrice(state.offer.currentTerms.totalPrice.amount)}",
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
              onPressed: () {
                if (Navigator.of(confirmCtx).canPop()) {
                  Navigator.of(confirmCtx).pop();
                }
                ref
                    .read(offerActionsProvider.notifier)
                    .acceptOffer(state.offer.id, state.currentUserRole);
              },
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
  }

  void _showRejectConfirmation(
    BuildContext context,
    SharedOfferDetailsState state,
  ) {
    showDialog(
      context: context,
      builder: (rejectCtx) => AlertDialog(
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Reject the offer?",
              style: TextStyle(fontSize: 16, color: AppColors.textBlue),
            ),
            Text(
              "${state.offer.currentTerms.weight.kilograms} Kg / ${formatPrice(state.offer.currentTerms.totalPrice.amount)}",
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: AppColors.textBlue,
              ),
            ),
            const SizedBox(height: 8),
            CustomButton(
              title: "Reject",
              onPressed: () {
                if (Navigator.of(rejectCtx).canPop()) {
                  Navigator.of(rejectCtx).pop();
                }
                ref
                    .read(offerActionsProvider.notifier)
                    .rejectOffer(state.offer.id, state.currentUserRole);
              },
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
  }

  Widget _buildRejectionMessage(
    BuildContext context,
    SharedOfferDetailsState state,
  ) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.fail50.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.fail200),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.fail500),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "This offer has been rejected.",
                  style: TextStyle(color: AppColors.fail500),
                ),
              ),
            ],
          ),
        ),
        if (state.currentUserRole == UserRole.buyer) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              title: "Marketplace",
              onPressed: () {
                context.go("/buyer");
              },
              icon: Icons.storefront,
              bordered: true,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              title: "Make New Offer",
              onPressed: () => _showMakeOfferDialog(context, state),
            ),
          ),
        ],
      ],
    );
  }

  void _showMakeOfferDialog(
    BuildContext context,
    SharedOfferDetailsState state,
  ) {
    final weightController = TextEditingController();
    final priceController = TextEditingController();
    final pricePerKgController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final catchItem = state.catchItem;
    final initialPricePerKg = catchItem.pricePerKg.amountPerKg;
    pricePerKgController.text = initialPricePerKg.toStringAsFixed(0);

    bool userEditingTotal = false;

    void updateTotalFromWeight() {
      if (userEditingTotal) return;
      final weight = double.tryParse(weightController.text);
      final pricePerKg = double.tryParse(pricePerKgController.text);
      if (weight != null && pricePerKg != null) {
        final total = weight * pricePerKg;
        priceController.text = total.toStringAsFixed(0);
      }
    }

    void updatePricePerKgFromTotal() {
      final weight = double.tryParse(weightController.text);
      final total = double.tryParse(priceController.text);
      if (weight != null && weight > 0 && total != null) {
        final pricePerKg = total / weight;
        pricePerKgController.text = pricePerKg.toStringAsFixed(0);
      }
    }

    weightController.addListener(updateTotalFromWeight);

    priceController.addListener(() {
      userEditingTotal = true;
      updatePricePerKgFromTotal();
      Future.delayed(const Duration(milliseconds: 200), () {
        userEditingTotal = false;
      });
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        contentPadding: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          minWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        title: Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            void updateCalculations(String _) {
              final weightInputKg =
                  double.tryParse(weightController.text) ?? 0.0;
              final totalPrice = int.tryParse(priceController.text) ?? 0;
              final weightInGrams = (weightInputKg * 1000).round();

              if (weightInGrams > 0 && totalPrice > 0) {
                final calcPricePerKg = ((totalPrice * 1000) / weightInGrams)
                    .round();
                if (pricePerKgController.text != calcPricePerKg.toString()) {
                  pricePerKgController.text = calcPricePerKg.toString();
                }
              }
            }

            return Form(
              key: formKey,
              child: SingleChildScrollView(
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
                            role: UserRole.buyer,
                            suffix: "Kg",
                            onChanged: updateCalculations,
                            validator: (value) {
                              final weightInputKg = double.tryParse(
                                value ?? "",
                              );
                              if (weightInputKg == null || weightInputKg <= 0) {
                                return "Enter valid weight";
                              }
                              final weightInGrams = (weightInputKg * 1000)
                                  .round();
                              if (weightInGrams >
                                  catchItem.availableWeight.grams) {
                                return "Cannot exceed available weight";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          NumberInputField(
                            controller: priceController,
                            label: "Total Price",
                            suffix: "CFA",
                            decimal: false,
                            onChanged: updateCalculations,
                            validator: (value) {
                              final price = int.tryParse(value ?? "");
                              if (price == null || price <= 0) {
                                return "Enter valid price";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          NumberInputField(
                            controller: pricePerKgController,
                            label: "Price/Kg",
                            suffix: "CFA",
                            decimal: false,
                            editable: false,
                            validator: (value) {
                              final pricePerKg = int.tryParse(value ?? "");
                              if (pricePerKg == null || pricePerKg <= 0) {
                                return "Enter valid price per kg";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      title: "Send Offer",
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final weightInputKg = double.tryParse(
                            weightController.text,
                          );
                          final totalPrice = int.tryParse(priceController.text);

                          if (weightInputKg != null && totalPrice != null) {
                            final weightInGrams = (weightInputKg * 1000)
                                .round();

                            ref
                                .read(offerActionsProvider.notifier)
                                .createOffer(
                                  catchItem.id,
                                  state.offer.buyerId,
                                  state.offer.fisherId,
                                  OfferTerms.create(
                                    weight: Weight.fromGrams(weightInGrams),
                                    totalPrice: Price.fromAmount(totalPrice),
                                  ),
                                );
                            context.pop();
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPostAcceptanceActions(
    BuildContext context,
    SharedOfferDetailsState state,
  ) {
    return Column(
      children: [
        if (state.orderId != null) ...[
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              title: "View Order",
              onPressed: () {
                final prefix = state.currentUserRole == UserRole.buyer
                    ? 'buyer'
                    : 'fisher';
                context.push("/$prefix/order-details/${state.orderId}");
              },
              icon: Icons.receipt_long,
            ),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            title: "Call ${state.otherParty.currentRole.displayName}",
            onPressed: () =>
                makePhoneCall('651204966', context), // Placeholder number
            hugeIcon: HugeIcons.strokeRoundedCall02,
            bordered: true,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            title: "Message ${state.otherParty.currentRole.displayName}",
            onPressed: () {
              final prefix = state.currentUserRole == UserRole.buyer
                  ? 'buyer'
                  : 'fisher';
              // Generate conversation ID from buyer and fisher IDs
              final conversationId = _generateConversationId(
                state.offer.buyerId,
                state.offer.fisherId,
              );
              context.push("/$prefix/chat/$conversationId");
            },
            icon: CustomIcons.chatbubble,
            bordered: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPreviousOfferSection(OfferTerms terms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader("Previous Offer"),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray200),
          ),
          child: InfoTable(
            rows: [
              InfoRow(label: "Weight", value: "${terms.weight.kilograms} kg"),

              InfoRow(
                label: "Price/Kg",
                value: formatPrice(terms.pricePerKg.amountPerKg),
              ),
              InfoRow(
                label: "Price",
                value: formatPrice(terms.totalPrice.amount),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCounterOfferDialog(
    BuildContext context,
    SharedOfferDetailsState state,
  ) {
    final weightController = TextEditingController();
    final priceController = TextEditingController();
    final pricePerKgController = TextEditingController();

    // Pre-fill with current values
    weightController.text = state.offer.currentTerms.weight.kilograms
        .toString();
    priceController.text = state.offer.currentTerms.totalPrice.amount
        .toStringAsFixed(0);
    pricePerKgController.text = state.offer.currentTerms.pricePerKg.amountPerKg
        .toStringAsFixed(0);

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: StatefulBuilder(
          builder: (context, setState) {
            void updateCalculations() {
              final weight = double.tryParse(weightController.text) ?? 0;
              final total = double.tryParse(priceController.text) ?? 0;
              if (weight > 0 && total > 0) {
                final perKg = total / weight;
                if (pricePerKgController.text != perKg.toStringAsFixed(0)) {
                  pricePerKgController.text = perKg.toStringAsFixed(0);
                }
              }
            }

            return Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(Icons.close),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NumberInputField(
                          controller: weightController,
                          label: "Weight",
                          decimal: true,
                          suffix: "Kg",
                          editable: false,
                          onChanged: (_) => setState(updateCalculations),
                          validator: (value) {
                            final val = double.tryParse(value ?? "");
                            if (val == null || val <= 0) {
                              return "Enter valid weight";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        NumberInputField(
                          controller: priceController,
                          label: "Total Price",
                          suffix: "CFA",
                          decimal: false,
                          editable: true,
                          onChanged: (_) => setState(updateCalculations),
                          validator: (value) {
                            final val = int.tryParse(value ?? "");
                            if (val == null || val <= 0) {
                              return "Enter valid price";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        NumberInputField(
                          controller: pricePerKgController,
                          label: "Price/Kg",
                          suffix: "CFA",
                          decimal: false,
                          editable: false, // Read-only
                        ),
                      ],
                    ),
                  ),
                  CustomButton(
                    title: "Send Counter-offer",
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final weight = double.tryParse(weightController.text);
                        final total = int.tryParse(priceController.text);

                        if (weight != null && total != null) {
                          final terms = OfferTerms.create(
                            weight: Weight.fromKg(weight),
                            totalPrice: Price.fromAmount(total),
                          );

                          ref
                              .read(offerActionsProvider.notifier)
                              .counterOffer(
                                state.offer.id,
                                state.currentUserRole,
                                terms,
                              );
                          context.pop();
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
