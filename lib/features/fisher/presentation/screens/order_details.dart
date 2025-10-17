import 'dart:async'; // Import for TimeoutException and Timer
import 'dart:convert';

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/failed_transaction_cubit/failed_transaction_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/failed_transaction_cubit/failed_transaction_state.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
// Import the service locator for accessing singletons
import 'package:siren_marketplace/core/di/injector.dart'; // Import sl
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/models/order.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/buyer/data/models/buyer.dart';
import 'package:siren_marketplace/features/fisher/logic/order_bloc/order_bloc.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

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
  OrdersState? _lastOrdersState;
  final UserRepository _userRepository = sl<UserRepository>();

  // Local future to load dependencies, which must be reset on orderId change.
  Future<OrderDependencies>? _orderDependenciesFuture;

  // Retry mechanism variables: REMOVED the periodic timer as the BLoC check
  // is now sufficient to prevent repeated data fetching from the repository.
  // Timer? _initialLoadRetryTimer;
  // static const int maxRetries = 5;
  // int currentRetries = 0;

  @override
  void initState() {
    super.initState();
    // Initial load
    _startLoadProcess();
  }

  // --- NEW: Handle orderId change when navigating from one order to another ---
  @override
  void didUpdateWidget(covariant OrderDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderId != widget.orderId) {
      // 1. Reset everything for the new order
      _orderDependenciesFuture = null;
      // Removed timer cancellation and retry counter reset

      // 2. Start the load process for the new ID
      _startLoadProcess();
    }
  }

  // --------------------------------------------------------------------------

  void _startLoadProcess() {
    // Dispatch the initial request immediately.
    _dispatchGetOrder();
  }

  void _dispatchGetOrder() {
    // Dispatches the GetOrderById event for the current widget.orderId
    if (widget.orderId.isNotEmpty) {
      // 🎯 CRITICAL FIX: Use the correct event (GetOrderById) for the order's primary ID.
      context.read<OrdersBloc>().add(GetOrderById(widget.orderId));
      // OLD CODE: context.read<OrdersBloc>().add(GetOrderByOfferId(widget.orderId));
    }
  }

  // New method to make a phone call
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
    // Removed timer cancellation
    _buttonFocusNode.dispose();
    super.dispose();
  }

  // Method to fetch dependent data (Catch Snapshot and Buyer)
  Future<OrderDependencies> _loadDependencies(Order order) async {
    try {
      // 1. Decode the Catch Snapshot JSON
      final Map<String, dynamic> catchMap = jsonDecode(order.catchSnapshotJson);
      final catchSnapshot = Catch.fromMap(catchMap);

      // Added a timeout to prevent indefinite loading if the network/database call hangs
      final Map<String, dynamic>? buyerMap = await _userRepository
          .getUserMapById(order.buyerId)
          .timeout(const Duration(seconds: 10)); // 10 second timeout

      Buyer? buyer;
      if (buyerMap != null) {
        buyer = Buyer.fromMap(buyerMap);
      } else {}

      return OrderDependencies(catchSnapshot: catchSnapshot, buyer: buyer);
    } on TimeoutException {
      // Catch specific timeout error and throw a clearer message
      throw Exception(
        "Dependency loading timed out after 10 seconds. Check network or repository.",
      );
    } catch (e) {
      // Catch any other error (e.g., JSON parsing error, network failure)
      throw Exception("Failed to load order dependencies: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrdersBloc, OrdersState>(
      // Listen for all state changes and log them immediately
      listener: (context, state) {
        if (state != _lastOrdersState) {
          _lastOrdersState = state;
        }
      },
      child: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, state) {
          // 1. BLoC error handling
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

          // 2. BLoC Loading/Initial State Handling
          if (state is! SingleOrderLoaded) {
            return Scaffold(
              key: ValueKey(widget.orderId),
              appBar: AppBar(
                leading: BackButton(onPressed: () => context.pop()),
                title: const Text("Order Details"),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          // 3. CRITICAL FIX: Check if the loaded order matches the current ID
          final selectedOrder = state.order;
          if (selectedOrder.id != widget.orderId) {
            // The BLoC is holding old data. Wait for the correct data to load.
            return Scaffold(
              key: ValueKey(widget.orderId),
              appBar: AppBar(
                leading: BackButton(onPressed: () => context.pop()),
                title: const Text("Order Details"),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          // 4. If ID matches, proceed to load dependencies (or use existing future)
          // The future is already reset in didUpdateWidget when the ID changes.
          _orderDependenciesFuture ??= _loadDependencies(selectedOrder);

          // 5. Use FutureBuilder for the dependent data
          return FutureBuilder<OrderDependencies>(
            future: _orderDependenciesFuture,
            builder: (context, snapshot) {
              // --- DEPENDENCY LOADING ERROR HANDLING ---
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
                              // Reset the future and restart the BLoC load process
                              setState(() {
                                _orderDependenciesFuture = null;
                              });
                              _startLoadProcess();
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

              // --- DEPENDENCY LOADING/WAITING STATE ---
              if (snapshot.connectionState != ConnectionState.done ||
                  snapshot.data == null) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              final dependencies = snapshot.data!;
              final catchSnapshot = dependencies.catchSnapshot;
              final buyer = dependencies.buyer;

              // Extract accepted details from the JSON snapshot
              final Map<String, dynamic> catchMap = jsonDecode(
                selectedOrder.catchSnapshotJson,
              );
              final double acceptedWeight =
                  (catchMap['accepted_weight'] as num?)?.toDouble() ?? 0.0;
              final double acceptedPrice =
                  (catchMap['accepted_price'] as num?)?.toDouble() ?? 0.0;

              // Assuming the Order status reflects the completion status
              final OfferStatus orderStatus = selectedOrder.offer.status;

              // Placeholder/Fallback values for Buyer
              final buyerName =
                  buyer?.name ?? 'Buyer ID: ${selectedOrder.buyerId}';
              final buyerAvatar =
                  buyer?.avatarUrl ?? "assets/images/user-profile.png";
              final buyerRating = buyer?.rating ?? 0.0;
              final buyerReviewCount = buyer?.reviewCount ?? 0;

              // Safely access the first image, or use the fallback asset
              final String imageUrl = catchSnapshot.images.isNotEmpty
                  ? catchSnapshot.images.first
                  : "assets/images/prawns.jpg";

              // --- UI Structure (Unchanged content) ---
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
                        // ... [Modal Logic for Failed Transaction Cubit - unchanged] ...
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
                                            itemCount: kFailedTransactionReasons
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
                                                        onChanged: (_) =>
                                                            cubit.toggleReason(
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
                              icon: Icons.phone_outlined,
                            ),
                            CustomButton(
                              title: "Message Buyer",
                              onPressed: () => context.push("/fisher/chat"),
                              // Using the provided phone number
                              bordered: true,
                              icon: Icons.chat_bubble_outline_outlined,
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
                                                  context
                                                      .pop(); // Dismiss modal
                                                  context
                                                      .read<OrdersBloc>()
                                                      .add(
                                                        MarkOrderAsCompleted(
                                                          selectedOrder,
                                                        ),
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
                                              children: List.generate(5, (
                                                index,
                                              ) {
                                                return const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 2,
                                                  ),
                                                  child: Icon(
                                                    Icons.star,
                                                    size: 32,
                                                    color:
                                                        AppColors.shellOrange,
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
      ),
    );
  }
}
