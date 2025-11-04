import 'dart:async';
import 'dart:convert';

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
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/models/order.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/buyer/data/models/buyer.dart';
import 'package:siren_marketplace/features/fisher/logic/orders_bloc/orders_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDependencies {
  final Catch catchSnapshot;
  final Buyer? buyer;

  const OrderDependencies({required this.catchSnapshot, this.buyer});
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

    final bloc = context.read<OrdersBloc>();
    final currentState = bloc.state;

    // Check if the current state is already showing the required order detail
    if (currentState is OrderDetailsLoaded &&
        currentState.order.id == widget.orderId) {
      return;
    }

    // ✅ NEW EVENT: Use the GetOrderById event from OrdersBloc
    bloc.add(GetOrderById(widget.orderId));
  }

  Future<void> _markOrderAsCompleted(Order order) async {
    context.read<OrdersBloc>().add(CompleteOrder(order: order));
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch phone app.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    super.dispose();
  }

  Future<OrderDependencies> _loadDependencies(Order order) async {
    try {
      final Map<String, dynamic> catchMap = jsonDecode(order.catchSnapshotJson);
      final catchSnapshot = Catch.fromMap(catchMap);

      final Map<String, dynamic>? buyerMap = await _userRepository
          .getUserMapById(order.buyerId)
          .timeout(const Duration(seconds: 10));

      Buyer? buyer;
      if (buyerMap != null) {
        buyer = Buyer.fromMap(buyerMap);
      }

      return OrderDependencies(catchSnapshot: catchSnapshot, buyer: buyer);
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
    return BlocConsumer<OrdersBloc, OrdersState>(
      listenWhen: (prev, curr) =>
          curr is OrdersLoaded ||
          curr is OrderDetailsLoaded ||
          curr is OrdersError,
      listener: (context, state) {
        // 💡 Listener logic is now simpler and focused on user feedback
        if (state is OrderDetailsLoaded && state.order.id == widget.orderId) {
          // This ensures the FutureBuilder is reset to load dependencies
          // if the order details were updated by the Notifier refresh.
          if (mounted) {
            setState(() {
              _orderDependenciesFuture = _loadDependencies(state.order);
            });
          }
        }

        if (state is OrdersError) {
          // You might want to show a toast or dialog here for errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Action failed: ${state.message}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },

      builder: (context, state) {
        if (state is OrdersError) {
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop()),
              title: const Text("Order Details"),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  "Load Error: ${state.message}",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (state is! OrderDetailsLoaded || state.order.id != widget.orderId) {
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

        final selectedOrder = state.order;

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
            final catchSnapshot = dependencies.catchSnapshot;
            final buyer = dependencies.buyer;

            final Map<String, dynamic> catchMap = jsonDecode(
              selectedOrder.catchSnapshotJson,
            );
            final double acceptedWeight =
                (catchMap['accepted_weight'] as num?)?.toDouble() ?? 0.0;
            final double acceptedPrice =
                (catchMap['accepted_price'] as num?)?.toDouble() ?? 0.0;
            final OfferStatus orderStatus = selectedOrder.offer.status;

            final buyerName =
                buyer?.name ?? 'Buyer ID: ${selectedOrder.buyerId}';
            final buyerAvatar =
                buyer?.avatarUrl ?? "assets/images/user-profile.png";
            final buyerRating = buyer?.rating ?? 0.0;
            final buyerReviewCount = buyer?.reviewCount ?? 0;

            final String imageUrl = catchSnapshot.images.isNotEmpty
                ? catchSnapshot.images.first
                : "assets/images/prawns.jpg";

            // ---------------------------------------------------------------
            // UI SECTION - UNCHANGED
            // ---------------------------------------------------------------
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
                                            .read<FailedTransactionCubit>();
                                        return ListView.builder(
                                          itemCount:
                                              kFailedTransactionReasons.length,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          padding: EdgeInsets.zero,
                                          itemBuilder: (context, index) {
                                            final reason =
                                                kFailedTransactionReasons[index];
                                            final isSelected =
                                                state.selectedReason == reason;
                                            return InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              onTap: () =>
                                                  cubit.toggleReason(reason),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    Checkbox(
                                                      value: isSelected,
                                                      onChanged: (_) => cubit
                                                          .toggleReason(reason),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              6,
                                                            ),
                                                      ),
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                      splashRadius: 5,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        reason,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                        overflow: TextOverflow
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
                                        hintText: "Enter the reason here...",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
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
                          "Order #${selectedOrder.id}", // Use actual Order ID
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.textBlue,
                          ),
                        ),
                        Text(
                          selectedOrder.dateUpdated.toFormattedDate(),
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
                              errorBuilder: (context, error, stackTrace) =>
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
                                catchSnapshot.name, // Use Catch name
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
                                      color: AppColors.getStatusColor(
                                        orderStatus,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 10,
                                    height: 10,
                                    margin: const EdgeInsets.only(left: 4),
                                    // Added margin
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white),
                                      color: AppColors.getStatusColor(
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
                        rows:
                            [
                                  InfoRow(
                                    label: "Market",
                                    value: catchSnapshot.market,
                                  ),
                                  InfoRow(
                                    label: "Species",
                                    value: catchSnapshot.species.name,
                                  ),
                                  catchSnapshot.species.id == "prawns"
                                      ? InfoRow(
                                          label: "Size",
                                          value: catchSnapshot.size,
                                        )
                                      : null,
                                  InfoRow(
                                    label:
                                        "Weight", // Updated label for clarity
                                    value: acceptedWeight.toInt(),
                                    suffix: "Kg",
                                  ),
                                  InfoRow(
                                    label: "Total Price",
                                    value: acceptedPrice.toStringAsFixed(0),
                                    suffix: "CFA",
                                  ),
                                ]
                                .whereType<InfoRow>()
                                .toList(), // Filter out null for non-prawns size
                      ),
                    ),
                    const SizedBox(height: 16),

                    const SectionHeader("Buyer"),

                    const SizedBox(height: 16),

                    // --- Buyer Details ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          // Updated to handle local assets vs network image
                          backgroundImage: buyerAvatar.startsWith('http')
                              ? NetworkImage(buyerAvatar) as ImageProvider
                              : AssetImage(buyerAvatar),
                          onBackgroundImageError: (exception, stackTrace) =>
                              const AssetImage(
                                "assets/images/user-profile.png",
                              ), // Fallback
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 16),

                    // --- Action Buttons ---
                    if (orderStatus != OfferStatus.completed)
                      Column(
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomButton(
                            title: "Call Buyer",
                            onPressed: () => _makePhoneCall('651204966'),
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
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Confirm Order Completion",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
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
                                                context.pop(); // Dismiss modal
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
                                                        decoration:
                                                            BoxDecoration(
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
                                                            MainAxisSize.min,
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
                                                              context.pop(),
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
                                                context.pop(); // Dismiss modal
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
                    if (orderStatus == OfferStatus.completed)
                      CustomButton(
                        title: "Rate the buyer",
                        onPressed: () {
                          // --- Rate Buyer Modal Logic (Unchanged) ---
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.white,
                            useSafeArea: true,
                            showDragHandle: true,
                            builder: (context) {
                              return DraggableScrollableSheet(
                                expand: false,
                                initialChildSize: 0.55,
                                minChildSize: 0.5,
                                maxChildSize: 0.95,
                                builder: (context, scrollController) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      left: 16,
                                      right: 16,
                                      bottom: MediaQuery.of(
                                        context,
                                      ).viewInsets.bottom,
                                    ),
                                    child: ListView(
                                      controller: scrollController,
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: context.pop,
                                              icon: const Icon(Icons.close),
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              "Give a Review",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 32,
                                                color: AppColors.textBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: List.generate(5, (index) {
                                              return const Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 2,
                                                ),
                                                child: Icon(
                                                  Icons.star,
                                                  size: 32,
                                                  color: AppColors.shellOrange,
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        TextField(
                                          maxLines: 5,
                                          onTapOutside: (e) {
                                            FocusScope.of(context).unfocus();
                                          },

                                          decoration: InputDecoration(
                                            hintText: "Write a review",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        CustomButton(
                                          title: "Submit Review",
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
