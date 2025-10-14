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

class OrderDependencies {
  final Catch catchSnapshot;
  final Buyer? buyer;

  const OrderDependencies({required this.catchSnapshot, this.buyer});
}

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key, required this.offerId});

  final String offerId;

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Repost Menu');
  final UserRepository _userRepository = UserRepository();

  // 🆕 NEW: Future to hold the *Buyer* lookup, which is dependent on the Order
  Future<OrderDependencies>? _orderDependenciesFuture;

  @override
  void initState() {
    super.initState();
    // 🆕 ACTION: Dispatch the specific event to fetch the single order by offerId
    context.read<OrdersBloc>().add(GetOrderByOfferId(widget.offerId));
  }

  @override
  void dispose() {
    _buttonFocusNode.dispose();
    super.dispose();
  }

  // Method to fetch dependent data (Catch Snapshot and Buyer)
  Future<OrderDependencies> _loadDependencies(Order order) async {
    // 1. Decode the Catch Snapshot JSON (No change required here, it's correct)
    final Map<String, dynamic> catchMap = jsonDecode(order.catchSnapshotJson);
    final catchSnapshot = Catch.fromMap(catchMap);

    // 2. Fetch Buyer Details using the UserRepository

    // 🆕 Use the new raw map retrieval method
    final Map<String, dynamic>? buyerMap = await _userRepository.getUserMapById(
      order.buyerId,
    );

    Buyer? buyer;
    if (buyerMap != null) {
      // 🆕 Use the clean Buyer.fromMap factory to assemble the model.
      // This handles all the base AppUser property transfer internally.
      buyer = Buyer.fromMap(buyerMap);
    }

    return OrderDependencies(catchSnapshot: catchSnapshot, buyer: buyer);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Listen for the SingleOrderLoaded state
    return BlocConsumer<OrdersBloc, OrdersState>(
      listener: (context, state) {
        // 🆕 LISTENER: When the single order is loaded, kick off the dependent data fetch
        if (state is SingleOrderLoaded) {
          // Set the future state to trigger the FutureBuilder
          setState(() {
            _orderDependenciesFuture = _loadDependencies(state.order);
          });
        }
      },
      builder: (context, state) {
        // --- State Handling for the OrdersBloc ---
        if (state is OrdersLoading || state is OrdersInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is OrdersError) {
          // This handles errors from LoadOrders or GetOrderByOfferId not finding the order
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop()),
              title: const Text("Order Details"),
            ),
            body: Center(child: Text("Error: ${state.message}")),
          );
        }

        // 2. Handle the case where the Order is loaded (state is SingleOrderLoaded)
        if (state is! SingleOrderLoaded) {
          // This should technically not happen if initial load is successful, but acts as a safeguard
          return Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: () => context.pop()),
              title: const Text("Order Details"),
            ),
            body: const Center(child: Text("Initializing order view...")),
          );
        }

        // Order is loaded, now we need to check the FutureBuilder for dependencies
        final selectedOrder = state.order;

        // 3. Use FutureBuilder for the dependent data (Catch Snapshot and Buyer)
        return FutureBuilder<OrderDependencies>(
          // Use the future set in the listener
          future: _orderDependenciesFuture,
          builder: (context, snapshot) {
            // --- State Handling for Dependent Data ---
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
            // NOTE: The Offer model status is likely what's needed for UI color/label.
            // Assuming the Order model has a property for this derived from the Offer it created.
            final OfferStatus orderStatus = selectedOrder.offer.status;

            // Placeholder/Fallback values for Buyer
            final buyerName =
                buyer?.name ?? 'Buyer ID: ${selectedOrder.buyerId}';
            final buyerAvatar =
                buyer?.avatarUrl ?? "assets/images/user-profile.png";
            final buyerRating = buyer?.rating ?? 0.0;
            final buyerReviewCount = buyer?.reviewCount ?? 0;

            // --- UI Structure (Unchanged content, now uses clean data flow) ---
            return Scaffold(
              appBar: AppBar(
                leading: BackButton(onPressed: () => context.pop()),
                title: const Text(
                  "Order Details",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlue,
                    fontSize: 24,
                  ),
                ),
                actions: [
                  // ... Repost Menu Button (Modal Bottom Sheet) ...
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
                            final imageUrl = catchSnapshot.images.isNotEmpty
                                ? catchSnapshot.images.first
                                : "assets/images/prawns.jpg";

                            final ImageProvider imageProvider =
                                imageUrl.startsWith('http')
                                ? NetworkImage(imageUrl)
                                : AssetImage(imageUrl) as ImageProvider;

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
                              catchSnapshot.images.first, // Use Catch image URL
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
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white),
                                      color: AppColors.getStatusColor(
                                        orderStatus,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    orderStatus.name.capitalize(),
                                    // Use actual status
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
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
                        rows: [
                          InfoRow(label: "Market", value: catchSnapshot.market),
                          InfoRow(
                            label: "Species",
                            value: catchSnapshot.species.name,
                          ),
                          InfoRow(label: "Size", value: catchSnapshot.size),
                          InfoRow(
                            label: "Weight", // Updated label for clarity
                            value: acceptedWeight.toInt(),
                            suffix: "Kg",
                          ),
                          InfoRow(
                            label: "Total Price",
                            value: acceptedPrice.toStringAsFixed(0),
                            suffix: "CFA",
                          ),
                        ],
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomButton(
                            title: "Call Buyer",
                            onPressed: () {
                              // ... Call Buyer Modal Logic (Unchanged) ...
                            },
                            bordered: true,
                            icon: Icons.phone_outlined,
                          ),
                          const SizedBox(height: 8),
                          CustomButton(
                            title: "Message Buyer",
                            onPressed: () {
                              context.push("/fisher/chat");
                            },
                            icon: Icons.chat_bubble_outline_rounded,
                            bordered: true,
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),

                    // --- Primary Action ---
                    if (orderStatus == OfferStatus.completed)
                      CustomButton(
                        title: "Rate the buyer",
                        onPressed: () {
                          // ... Rate Buyer Modal Logic (Unchanged) ...
                        },
                      )
                    else
                      CustomButton(
                        title: "Mark as Completed",
                        icon: Icons.check,
                        onPressed: () {
                          // TODO: Dispatch a BLoC event to update the Order status
                          // You'll need to define this event (e.g., CompleteOrder) in order_event.dart
                        },
                      ),
                    const SizedBox(height: 16),
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
