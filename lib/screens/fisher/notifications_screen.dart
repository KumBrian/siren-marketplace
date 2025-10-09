import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_state.dart';
// --- NEW IMPORTS ---
import 'package:siren_marketplace/bloc/cubits/fisher_cubit/fisher_cubit.dart';
import 'package:siren_marketplace/components/custom_button.dart';
import 'package:siren_marketplace/components/filter_button.dart';
import 'package:siren_marketplace/components/fisher_offer_card.dart';
import 'package:siren_marketplace/components/message_card.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Removed mock data variables: final List<Catch> catches = sampleCatches;
  // Removed mock data variables: late Catch selectedCatch = sampleCatches[0];

  @override
  Widget build(BuildContext context) {
    // 1. Listen to the FisherCubit to get the latest Fisher data
    return BlocBuilder<FisherCubit, Fisher?>(
      builder: (context, fisherState) {
        // Handle loading/null state
        if (fisherState == null) {
          // You can also add a check for a FisherLoading state if you had one
          return Scaffold(
            appBar: AppBar(leading: BackButton(), title: Text("Notifications")),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Extract Offers and Messages from the loaded Fisher object
        // Aggregate all offers from all catches
        final allOffers = fisherState.catches
            .expand((catchItem) => catchItem.offers)
            .toList();

        // Get all direct messages (ConversationPreview)
        final allMessages = fisherState.messages;

        // 3. Apply Filtering Logic (based on CatchFilterCubit state)
        return BlocBuilder<CatchFilterCubit, CatchFilterState>(
          builder: (context, filterState) {
            // Filter offers based on selected statuses
            final filteredOffers = allOffers.where((offer) {
              if (filterState.selectedStatuses.isEmpty) {
                return true; // Show all if no filter is active
              }
              // Check if the offer's status name (e.g., 'pending') is in the selected list (e.g., 'Pending')
              return filterState.selectedStatuses.contains(
                offer.status.name.capitalize(),
              );
            }).toList();

            return Scaffold(
              appBar: AppBar(
                leading: const BackButton(),
                actions: [
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        showDragHandle: true,
                        builder: (context) {
                          return BlocBuilder<
                            CatchFilterCubit,
                            CatchFilterState
                          >(
                            builder: (context, state) {
                              final cubit = context.read<CatchFilterCubit>();

                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Filter by",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text("Status"),
                                    Text(
                                      "Select all that apply",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textGray,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        // Note: FilterButton titles should match the capitalized enum names
                                        FilterButton(
                                          title: "Pending",
                                          color: AppColors.shellOrange,
                                          isSelected: state.selectedStatuses
                                              .contains("Pending"),
                                          onPressed: () =>
                                              cubit.toggleStatus("Pending"),
                                        ),
                                        FilterButton(
                                          title: "Accepted",
                                          color: AppColors.blue400,
                                          isSelected: state.selectedStatuses
                                              .contains("Accepted"),
                                          onPressed: () =>
                                              cubit.toggleStatus("Accepted"),
                                        ),
                                        FilterButton(
                                          title: "Completed",
                                          color: AppColors.textGray,
                                          isSelected: state.selectedStatuses
                                              .contains("Completed"),
                                          onPressed: () =>
                                              cubit.toggleStatus("Completed"),
                                        ),
                                        FilterButton(
                                          title: "Rejected",
                                          color: AppColors.fail500,
                                          isSelected: state.selectedStatuses
                                              .contains("Rejected"),
                                          onPressed: () =>
                                              cubit.toggleStatus("Rejected"),
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            cubit.clear();
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            "Reset All",
                                            style: TextStyle(
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                        CustomButton(
                                          title: "Apply Filters",
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.filter_alt_outlined),
                  ),
                ],
                title: const Text(
                  "Notifications",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlue,
                    fontSize: 24,
                  ),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              const TabBar(
                                dividerHeight: 0,
                                indicatorSize: TabBarIndicatorSize.tab,
                                tabs: [
                                  Tab(text: "Offers"),
                                  Tab(text: "Messages"),
                                ],
                              ),
                              Expanded(
                                child: TabBarView(
                                  physics: const BouncingScrollPhysics(),
                                  children: [
                                    // --- Offers Tab ---
                                    SingleChildScrollView(
                                      padding: const EdgeInsets.only(
                                        bottom: 80,
                                        top: 16,
                                      ),
                                      child: Column(
                                        children: [
                                          SearchBar(
                                            hintText: "Search",
                                            // ... (Search Bar styling)
                                            textStyle: WidgetStateProperty.all(
                                              TextStyle(
                                                fontSize: 16,
                                                color: AppColors.textBlue,
                                              ),
                                            ),
                                            side: WidgetStateProperty.all(
                                              BorderSide(
                                                color: AppColors.gray200,
                                              ),
                                            ),
                                            leading: Icon(
                                              Icons.search,
                                              color: AppColors.textBlue,
                                            ),
                                            elevation: WidgetStateProperty.all(
                                              0,
                                            ),
                                          ),
                                          // 4. Use filteredOffers list
                                          filteredOffers.isEmpty
                                              ? Column(
                                                  children: [
                                                    const SizedBox(height: 32),
                                                    SizedBox(
                                                      height: 120,
                                                      width: 120,
                                                      child: Image.asset(
                                                        "assets/images/no-offers.png",
                                                      ),
                                                    ),
                                                    const Text(
                                                      "No offers received yet.",
                                                      style: TextStyle(
                                                        color:
                                                            AppColors.textGray,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const Text(
                                                      "Buyers are reviewing your captures.",
                                                      style: TextStyle(
                                                        color:
                                                            AppColors.textGray,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Column(
                                                  children: filteredOffers.map((
                                                    offer,
                                                  ) {
                                                    return FisherOfferCard(
                                                      offer: offer,
                                                      onPressed: () {
                                                        context.push(
                                                          // Navigate using the offerId
                                                          "/fisher/offer-details/${offer.offerId}",
                                                        );
                                                      },
                                                    );
                                                  }).toList(),
                                                ),
                                        ],
                                      ),
                                    ),

                                    // --- Messages Tab ---
                                    SingleChildScrollView(
                                      padding: const EdgeInsets.only(
                                        bottom: 80,
                                        top: 16,
                                      ),
                                      // 5. Use allMessages list
                                      child: allMessages.isEmpty
                                          ? Column(
                                              children: [
                                                const SizedBox(height: 32),
                                                SizedBox(
                                                  height: 120,
                                                  width: 120,
                                                  child: Image.asset(
                                                    "assets/images/no-messages.png",
                                                  ),
                                                ),
                                                const Text(
                                                  "You have no messages yet.",
                                                  style: TextStyle(
                                                    color: AppColors.textGray,
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const Text(
                                                  "You will receive messages shortly",
                                                  style: TextStyle(
                                                    color: AppColors.textGray,
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Column(
                                              children: allMessages.map((msg) {
                                                return MessageCard(
                                                  messageId: msg.messageId,
                                                  name: msg.clientName,
                                                  time: msg.lastMessageTime
                                                      .toFormattedDate(),
                                                  message: msg.lastMessage,
                                                  unreadCount: msg.unreadCount,
                                                  avatarPath: msg.avatarPath,
                                                  onPressed: () {},
                                                );
                                              }).toList(),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
