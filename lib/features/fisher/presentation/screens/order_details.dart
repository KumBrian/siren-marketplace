import 'dart:async';

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:siren_marketplace/bloc/cubits/failed_transaction_cubit/failed_transaction_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/failed_transaction_cubit/failed_transaction_state.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/order.dart';
import 'package:siren_marketplace/core/domain/enums/order_status.dart';
import 'package:siren_marketplace/core/domain/repositories/i_catch_repository.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/utils/phone_launcher.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/error_handling_circle_avatar.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/rating_modal_content.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/buyer/data/models/buyer.dart';
import 'package:siren_marketplace/features/fisher/new_logic/orders_bloc/orders_cubit.dart';
import 'package:siren_marketplace/features/user/logic/user_bloc/user_bloc.dart';

class OrderDependencies {
  final Catch catchItem;
  final Buyer? buyer;

  const OrderDependencies({required this.catchItem, this.buyer});
}

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Repost Menu');

  // ⛔️ REMOVED: OrderDetailState? _lastOrderDetailsState;
  final UserRepository _userRepository = sl<UserRepository>();
  final ICatchRepository _catchRepository = sl<ICatchRepository>();

  Future<OrderDependencies>? _orderDependenciesFuture;

  @override
  void initState() {
    super.initState();
    _dispatchGetOrder();
  }

  @override
  void didUpdateWidget(covariant OrderDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderId != widget.orderId) {
      _orderDependenciesFuture = null;
      _dispatchGetOrder();
    }
  }

  void _dispatchGetOrder() {
    if (widget.orderId.isEmpty) return;

    final cubit = context.read<OrdersCubit>();
    final currentState = cubit.state;

    // Check if the current state is already showing the required order detail
    if (currentState.selectedOrder?.id == widget.orderId) {
      return;
    }

    // ✅ NEW EVENT: Use the loadById method from OrdersCubit
    cubit.loadById(widget.orderId);
  }

  Future<void> _markOrderAsCompleted(Order order) async {
    context.read<OrdersCubit>().completeOrder(order);
  }

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    super.dispose();
  }

  Future<OrderDependencies> _loadDependencies(Order order) async {
    try {
      final catchItem = await _catchRepository.getById(order.catchId);

      final Map<String, dynamic>? buyerMap = await _userRepository
          .getUserMapById(order.buyerId)
          .timeout(const Duration(seconds: 10));

      Buyer? buyer;
      if (buyerMap != null) {
        buyer = Buyer.fromMap(buyerMap);
      }

      return OrderDependencies(catchItem: catchItem!, buyer: buyer);
    } on TimeoutException {
      throw Exception(
        "Dependency loading timed out after 10 seconds. Check network or repository.",
      );
    } catch (e) {
      throw Exception("Failed to load order dependencies: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrdersCubit, OrdersState>(
      listenWhen: (prev, curr) =>
          curr.selectedOrder != null || curr.error != null,
      listener: (context, state) {
        // 💡 Listener logic is now simpler and focused on user feedback
        if (state.selectedOrder != null &&
            state.selectedOrder!.id == widget.orderId) {
          // This ensures the FutureBuilder is reset to load dependencies
          // if the order details were updated by the Notifier refresh.
          if (mounted) {
            setState(() {
              _orderDependenciesFuture = _loadDependencies(
                state.selectedOrder!,
              );
            });
          }
        }

        if (state.error != null) {
          // You might want to show a toast or dialog here for errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Action failed: ${state.error}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },

      builder: (context, state) {
        if (state.error != null && state.selectedOrder == null) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop()),
              title: const Text("Order Details"),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  "Load Error: ${state.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (state.selectedOrder == null ||
            state.selectedOrder!.id != widget.orderId) {
          // Show loading if we are waiting for the specific order
          return Scaffold(
            key: ValueKey(widget.orderId),
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop()),
              title: const Text("Order Details"),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final selectedOrder = state.selectedOrder!;

        _orderDependenciesFuture ??= _loadDependencies(selectedOrder);

        return FutureBuilder<OrderDependencies>(
          future: _orderDependenciesFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Scaffold(
                appBar: AppBar(
                  leading: BackButton(onPressed: () => context.pop()),
                  title: const Text("Order Details (Error)"),
                ),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Failed to load critical order data.",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Reason: ${snapshot.error}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.gray650,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          title: "Retry Loading",
                          onPressed: () {
                            setState(() {
                              _orderDependenciesFuture = null;
                            });
                            _dispatchGetOrder();
                          },
                          icon: Icons.refresh,
                          bordered: true,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (snapshot.connectionState != ConnectionState.done ||
                snapshot.data == null) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final dependencies = snapshot.data!;
            final catchItem = dependencies.catchItem;
            final buyer = dependencies.buyer;

            final int acceptedWeight = selectedOrder.terms.weight.grams;
            final int acceptedPrice = selectedOrder.terms.totalPrice.amount
                .toInt();
            final OrderStatus orderStatus = selectedOrder.status;

            final buyerName =
                buyer?.name ?? 'Buyer ID: ${selectedOrder.buyerId}';
            final buyerAvatar =
                buyer?.avatarUrl ?? "assets/images/user-profile.png";
            final buyerRating = buyer?.rating ?? 0.0;
            final buyerReviewCount = buyer?.reviewCount ?? 0;

            final String imageUrl = catchItem.images.isNotEmpty
                ? catchItem.images.first
                : "assets/images/prawns.jpg";

            // ---------------------------------------------------------------
            // UI SECTION - UNCHANGED
            // ---------------------------------------------------------------
            return BlocBuilder<UserBloc, UserState>(
              builder: (context, userState) {
                if (userState is UserLoaded) {
                  final user = userState.user;
                  final buyerId = selectedOrder.buyerId;
                  final String ratedUserName = buyerName;
                  final bool hasRatedBuyer = selectedOrder.hasReviewFromFisher;
                  return Scaffold(
                    appBar: AppBar(
                      leading: BackButton(onPressed: () => context.pop()),
                      title: const Text(
                        "Order Details",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlue,
                          fontSize: 24,
                        ),
                      ),
                      actions: [
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.white,
                              useSafeArea: true,
                              showDragHandle: true,
                              builder: (context) {
                                return DraggableScrollableSheet(
                                  expand: false,
                                  initialChildSize: 0.6,
                                  minChildSize: 0.6,
                                  maxChildSize: 0.95,
                                  builder: (context, scrollController) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        left: 32,
                                        right: 32,
                                        bottom: MediaQuery.of(
                                          context,
                                        ).viewInsets.bottom,
                                      ),
                                      child: ListView(
                                        controller: scrollController,
                                        children: [
                                          const Text(
                                            "Why did this transaction not go through?",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textBlue,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          BlocBuilder<
                                            FailedTransactionCubit,
                                            FailedTransactionState
                                          >(
                                            builder: (context, state) {
                                              final cubit = context
                                                  .read<
                                                    FailedTransactionCubit
                                                  >();
                                              return ListView.builder(
                                                itemCount:
                                                    kFailedTransactionReasons
                                                        .length,
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                padding: EdgeInsets.zero,
                                                itemBuilder: (context, index) {
                                                  final reason =
                                                      kFailedTransactionReasons[index];
                                                  final isSelected =
                                                      state.selectedReason ==
                                                      reason;
                                                  return InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    onTap: () => cubit
                                                        .toggleReason(reason),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 4,
                                                          ),
                                                      child: Row(
                                                        children: [
                                                          Checkbox(
                                                            value: isSelected,
                                                            onChanged: (_) =>
                                                                cubit
                                                                    .toggleReason(
                                                                      reason,
                                                                    ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    6,
                                                                  ),
                                                            ),
                                                            visualDensity:
                                                                VisualDensity
                                                                    .compact,
                                                            splashRadius: 5,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              reason,
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            "Other reason? Specify",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textBlue,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextField(
                                            maxLines: 3,
                                            decoration: InputDecoration(
                                              hintText:
                                                  "Enter the reason here...",
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          CustomButton(
                                            title: "Confirm",
                                            onPressed: () {},
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.autorenew),
                        ),
                      ],
                    ),
                    body: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // --- Order ID and Date ---
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Order #${selectedOrder.id}",
                                // Use actual Order ID
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: AppColors.textBlue,
                                ),
                              ),
                              Text(
                                selectedOrder.dateUpdated
                                    .toIso8601String()
                                    .toFormattedDate(),
                                // Use Order date
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.gray650,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // --- Product/Catch Details ---
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  final ImageProvider imageProvider =
                                      imageUrl.startsWith('http')
                                      ? NetworkImage(imageUrl) as ImageProvider
                                      : AssetImage(imageUrl);

                                  showImageViewer(
                                    context,
                                    imageProvider,
                                    swipeDismissible: true,
                                    immersive: true,
                                    useSafeArea: true,
                                    doubleTapZoomable: true,
                                    backgroundColor: Colors.black.withValues(
                                      alpha: 0.4,
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    imageUrl, // Use the safely determined URL
                                    // Use Catch image URL
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                              "assets/images/prawns.jpg",
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      catchItem.name, // Use Catch name
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: AppColors.textBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          orderStatus.name.capitalize(),
                                          // Use actual status
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                AppColors.getOrderStatusColor(
                                                  orderStatus,
                                                ),
                                          ),
                                        ),
                                        Container(
                                          width: 10,
                                          height: 10,
                                          margin: const EdgeInsets.only(
                                            left: 4,
                                          ),
                                          // Added margin
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                            ),
                                            color:
                                                AppColors.getOrderStatusColor(
                                                  orderStatus,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // --- Info Table ---
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.gray200),
                            ),
                            child: InfoTable(
                              rows: [
                                InfoRow(
                                  label: "Market",
                                  value: catchItem.market,
                                ),
                                InfoRow(
                                  label: "Species",
                                  value: catchItem.species.name,
                                ),
                                catchItem.species.id == "prawns"
                                    ? InfoRow(
                                        label: "Size",
                                        value: catchItem.size,
                                      )
                                    : null,
                                InfoRow(
                                  label: "Weight", // Updated label for clarity
                                  value: formatWeight(acceptedWeight),
                                ),
                                InfoRow(
                                  label: "Total Price",
                                  value: acceptedPrice.toStringAsFixed(0),
                                  suffix: "CFA",
                                ),
                              ].whereType<InfoRow>().toList(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          const SectionHeader("Buyer"),

                          // --- Buyer Details ---
                          Material(
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: () {
                                context.push("/fisher/reviews/${buyer?.id}");
                              },
                              borderRadius: BorderRadius.circular(16),
                              splashColor: AppColors.blue700.withValues(
                                alpha: 0.1,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ErrorHandlingCircleAvatar(
                                      avatarUrl: buyerAvatar,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            buyerName, // Use buyer name
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: AppColors.textBlue,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: AppColors.shellOrange,
                                                size: 16,
                                              ),
                                              Text(
                                                buyerRating.toStringAsFixed(1),
                                                // Use buyer rating
                                                style: const TextStyle(
                                                  color: AppColors.textBlue,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                              Text(
                                                " ($buyerReviewCount Reviews)",
                                                // Use buyer review count
                                                style: const TextStyle(
                                                  color: AppColors.textBlue,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // --- Action Buttons ---
                          if (orderStatus != OfferStatus.completed) ...[
                            const SizedBox(height: 16),
                            Column(
                              spacing: 8,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomButton(
                                  title: "Call Buyer",
                                  onPressed: () =>
                                      makePhoneCall('651204966', context),
                                  // Using the provided phone number
                                  bordered: true,
                                  hugeIcon: HugeIcons.strokeRoundedCall02,
                                ),
                                CustomButton(
                                  title: "Message Buyer",
                                  onPressed: () => context.push("/fisher/chat"),
                                  // Using the provided phone number
                                  bordered: true,
                                  icon: CustomIcons.chatbubble,
                                ),

                                const SizedBox(height: 16),

                                CustomButton(
                                  title: "Mark as Completed",
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.white,
                                      useSafeArea: true,
                                      showDragHandle: true,
                                      builder: (context) {
                                        return DraggableScrollableSheet(
                                          expand: false,
                                          builder: (context, scrollController) {
                                            return Padding(
                                              padding: const EdgeInsets.all(
                                                16.0,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Text(
                                                    "Confirm Order Completion",
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors.textBlue,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  const Text(
                                                    "Are you sure you want to mark this order as completed? This action cannot be undone.",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: AppColors.gray650,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 24),
                                                  CustomButton(
                                                    title: "Confirm",
                                                    onPressed: () {
                                                      context
                                                          .pop(); // Dismiss modal
                                                      _markOrderAsCompleted(
                                                        selectedOrder,
                                                      );
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            title: Container(
                                                              height: 100,
                                                              width: 100,
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: AppColors
                                                                    .shell300,
                                                              ),
                                                              child: Center(
                                                                child: SvgPicture.asset(
                                                                  "assets/icons/confetti.svg",
                                                                  width: 50,
                                                                ),
                                                              ),
                                                            ),
                                                            content: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                SectionHeader(
                                                                  "Well done!",
                                                                ),
                                                                SectionHeader(
                                                                  "You've completed this order.",
                                                                ),
                                                              ],
                                                            ),
                                                            actions: [
                                                              CustomButton(
                                                                title: "Thanks",
                                                                onPressed: () =>
                                                                    context
                                                                        .pop(),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                    icon: Icons.check,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  CustomButton(
                                                    title: "Cancel",
                                                    onPressed: () {
                                                      context
                                                          .pop(); // Dismiss modal
                                                    },
                                                    bordered: true,
                                                    icon: Icons.cancel_outlined,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                  icon: Icons.check,
                                ),
                              ],
                            ),
                          ],

                          if (orderStatus == OfferStatus.completed &&
                              !selectedOrder.hasReviewFromFisher) ...[
                            CustomButton(
                              title: "Rate the buyer",
                              onPressed: () {
                                final ordersCubit = context.read<OrdersCubit>();
                                // --- Rate Buyer Modal Logic (Unchanged) ---
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.white,
                                  useSafeArea: true,
                                  showDragHandle: true,
                                  builder: (context) {
                                    return RatingModalContent(
                                      orderId: selectedOrder.id,
                                      raterId: user!.id,
                                      // The Fisher is the Rater
                                      ratedUserId: buyerId,
                                      ratedUserName: ratedUserName,
                                      // 🌟 PASS THE WRAPPER FUNCTION 🌟
                                      onSubmitRating:
                                          ({
                                            required String orderId,
                                            required String raterId,
                                            required String ratedUserId,
                                            required double ratingValue,
                                            String? message,
                                          }) async {
                                            // Convert the function call into an OrdersCubit method call
                                            ordersCubit.submitRating(
                                              orderId: orderId,
                                              reviewerId: raterId,
                                              reviewedUserId: ratedUserId,
                                              ratingValue: ratingValue.toInt(),
                                              comment: message ?? '',
                                            );
                                            // We return a completed Future as dispatching an event is async
                                          },
                                    );
                                  },
                                );
                              },
                            ),
                          ] else if (orderStatus == OfferStatus.completed &&
                              selectedOrder.hasReviewFromFisher) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                children: [
                                  const HugeIcon(
                                    icon:
                                        HugeIcons.strokeRoundedCheckmarkBadge01,
                                    color: AppColors.success500,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "You rated the Buyer",
                                    style: const TextStyle(
                                      color: AppColors.textBlue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          if (orderStatus == OfferStatus.completed) ...[
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  HugeIcon(
                                    icon: selectedOrder.hasReviewFromBuyer
                                        ? HugeIcons
                                              .strokeRoundedCheckmarkBadge01
                                        : HugeIcons.strokeRoundedClock01,
                                    color: selectedOrder.hasReviewFromBuyer
                                        ? AppColors.success500
                                        : AppColors.shellOrange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    selectedOrder.hasReviewFromBuyer
                                        ? "The Buyer has rated you."
                                        : "Waiting for Buyer to rate you.",
                                    style: const TextStyle(
                                      color: AppColors.textBlue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }
                return Container();
              },
            );
          },
        );
      },
    );
  }
}
