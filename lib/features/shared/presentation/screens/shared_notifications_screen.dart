import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/entities/user.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/providers/conversation_providers.dart';
import 'package:siren_marketplace/core/providers/notification_filter_provider.dart';
import 'package:siren_marketplace/core/providers/offer_providers.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/filter_button.dart';
import 'package:siren_marketplace/core/widgets/page_title.dart';
import 'package:siren_marketplace/features/chat/presentation/widgets/conversation_card.dart';

class SharedNotificationsScreen extends ConsumerStatefulWidget {
  const SharedNotificationsScreen({super.key});

  @override
  ConsumerState<SharedNotificationsScreen> createState() =>
      _SharedNotificationsScreenState();
}

class _SharedNotificationsScreenState
    extends ConsumerState<SharedNotificationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildOffersTab(UserRole role) {
    final offersAsync = ref.watch(filteredNotificationOffersProvider);

    return offersAsync.when(
      data: (offers) {
        if (offers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Image.asset(
                    role == UserRole.fisher
                        ? "assets/images/no-offers.png"
                        : "assets/images/no-messages.png",
                  ),
                ),
                Text(
                  role == UserRole.fisher
                      ? "No offers found."
                      : "You have no offers yet.",
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  role == UserRole.fisher
                      ? "Try adjusting your filters or wait for new bids."
                      : "Browse the marketplace and make an offer.",
                  style: const TextStyle(
                    color: AppColors.textGray,
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80, top: 16),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: offers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final offer = offers[index];

              if (role == UserRole.fisher) {
                // Fisher view - show buyer info
                return _buildFisherOfferCard(offer, offer.buyer);
              } else {
                // Buyer view - show fisher info
                return _buildBuyerOfferCard(offer, offer.fisher);
              }
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading offers: $error')),
    );
  }

  Widget _buildFisherOfferCard(Offer offer, User? buyer) {
    // Import fisher's OfferCard
    return InkWell(
      onTap: () {
        context.push("/fisher/offer-details/${offer.id}");
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.gray200)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.textBlue.withValues(alpha: 0.1),
              ),
              child: offer.hasUpdateForFisher
                  ? Icon(CustomIcons.moneybag_filled, color: AppColors.textBlue)
                  : HugeIcon(
                      icon: HugeIconsStrokeRounded.moneyBag01,
                      color: AppColors.textBlue,
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              buyer?.name ?? "Loading...",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: offer.hasUpdateForFisher
                                    ? AppColors.textBlue
                                    : AppColors.textGray,
                                fontWeight: offer.hasUpdateForFisher
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star,
                            color: AppColors.shellOrange,
                            size: 12,
                          ),
                          Text(
                            (buyer?.rating.value ?? 0.0).toStringAsFixed(1),
                            style: TextStyle(
                              color: offer.hasUpdateForFisher
                                  ? AppColors.textBlue
                                  : AppColors.textGray,
                              fontWeight: offer.hasUpdateForFisher
                                  ? FontWeight.w500
                                  : FontWeight.w300,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        offer.dateUpdated.toIso8601String().toFormattedDate(),
                        style: TextStyle(
                          color: offer.hasUpdateForFisher
                              ? AppColors.textBlue
                              : AppColors.textGray,
                          fontWeight: offer.hasUpdateForFisher
                              ? FontWeight.w500
                              : FontWeight.w300,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.gray100,
                            ),
                            child: Text(
                              "${offer.currentTerms.weight.kilograms} kg",
                              style: const TextStyle(
                                color: AppColors.textBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.gray100,
                            ),
                            child: Text(
                              "${offer.currentTerms.totalPrice.amount} CFA",
                              style: const TextStyle(
                                color: AppColors.textBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            offer.status.name.capitalize(),
                            style: const TextStyle(
                              color: AppColors.textGray,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.getStatusColor(offer.status),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuyerOfferCard(Offer offer, User? fisher) {
    // Import buyer's OfferCard
    return InkWell(
      onTap: () {
        context.push("/buyer/offer-details/${offer.id}");
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.gray200)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.textBlue.withValues(alpha: 0.1),
              ),
              child: offer.hasUpdateForBuyer
                  ? Icon(CustomIcons.moneybag_filled, color: AppColors.textBlue)
                  : HugeIcon(
                      icon: HugeIconsStrokeRounded.moneyBag01,
                      color: AppColors.textBlue,
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              fisher?.name ?? "Loading...",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                color: AppColors.textGray,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star,
                            color: AppColors.shellOrange,
                            size: 12,
                          ),
                          Text(
                            (fisher?.rating.value ?? 0.0).toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.textGray,
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        offer.dateUpdated.toIso8601String().toFormattedDate(),
                        style: const TextStyle(
                          color: AppColors.textGray,
                          fontWeight: FontWeight.w300,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.gray100,
                            ),
                            child: Text(
                              "${offer.currentTerms.weight.kilograms} kg",
                              style: const TextStyle(
                                color: AppColors.textBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.gray100,
                            ),
                            child: Text(
                              "${offer.currentTerms.totalPrice.amount} CFA",
                              style: const TextStyle(
                                color: AppColors.textBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            offer.status.name.capitalize(),
                            style: const TextStyle(
                              color: AppColors.textGray,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.getStatusColor(offer.status),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesTab(UserRole role, String userId) {
    final conversationsAsync = ref.watch(userConversationsProvider(userId));

    return conversationsAsync.when(
      data: (conversations) {
        if (conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Image.asset("assets/images/no-messages.png"),
                ),
                const Text(
                  "No messages yet.",
                  style: TextStyle(
                    color: AppColors.textBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const Text(
                  "Start a conversation with a buyer or fisher.",
                  style: TextStyle(
                    color: AppColors.textBlue,
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80, top: 16),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: conversations.length,
            separatorBuilder: (context, index) => const SizedBox(height: 0),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final roleSlug = role == UserRole.fisher ? "fisher" : "buyer";

              return ConversationCard(
                conversation: conversation,
                currentUserId: userId,
                onTap: () {
                  context.push("/$roleSlug/chat/${conversation.id}");
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading conversations: $error')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text("User not found")));
        }

        final role = user.currentRole;
        final offersAsync = ref.watch(filteredNotificationOffersProvider);

        return Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            actions: [
              Consumer(
                builder: (context, ref, _) {
                  final filterState = ref.watch(notificationFilterProvider);
                  return IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        showDragHandle: true,
                        builder: (context) {
                          return Consumer(
                            builder: (context, ref, _) {
                              final state = ref.watch(
                                notificationFilterProvider,
                              );
                              final notifier = ref.read(
                                notificationFilterProvider.notifier,
                              );

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
                                      children: OfferStatus.values.map((
                                        status,
                                      ) {
                                        return FilterButton(
                                          title: status.name.capitalize(),
                                          color: AppColors.getStatusColor(
                                            status,
                                          ),
                                          isSelected: state.pendingStatuses
                                              .contains(status),
                                          onPressed: () =>
                                              notifier.toggleStatus(status),
                                        );
                                      }).toList(),
                                    ),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            notifier.clearAllFilters();
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
                                          onPressed: () {
                                            notifier.applyFilters();
                                            Navigator.pop(context);
                                          },
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
                    icon: filterState.activeStatuses.isEmpty
                        ? const Icon(CustomIcons.filter)
                        : Badge(
                            label: Text(
                              filterState.activeStatuses.length.toString(),
                            ),
                            child: const Icon(CustomIcons.filter),
                          ),
                  );
                },
              ),
            ],
            title: const PageTitle(title: "Notifications"),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _tabController,
                        builder: (context, _) {
                          final offerCount = offersAsync.when(
                            data: (offers) => role == UserRole.fisher
                                ? offers
                                      .where((o) => o.hasUpdateForFisher)
                                      .length
                                : offers
                                      .where((o) => o.hasUpdateForBuyer)
                                      .length,
                            loading: () => 0,
                            error: (_, __) => 0,
                          );

                          // Get unread conversations count
                          final conversationsAsync = ref.watch(
                            userConversationsProvider(user.id),
                          );
                          final unreadConversationsCount = conversationsAsync
                              .when(
                                data: (conversations) => conversations
                                    .where(
                                      (c) => c.hasUnreadMessagesFor(user.id),
                                    )
                                    .length,
                                loading: () => 0,
                                error: (_, __) => 0,
                              );

                          return TabBar(
                            controller: _tabController,
                            dividerHeight: 0,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicatorColor: AppColors.textBlue,
                            labelColor: AppColors.textBlue,
                            unselectedLabelColor: AppColors.textGray,
                            tabs: [
                              Tab(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Offers"),
                                    if (offerCount > 0)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _tabController.index == 0
                                              ? AppColors.textBlue
                                              : AppColors.textBlue.withValues(
                                                  alpha: 0.6,
                                                ),
                                        ),
                                        child: Text(
                                          "$offerCount",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textWhite,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Tab(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Messages"),
                                    if (unreadConversationsCount > 0)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _tabController.index == 1
                                              ? AppColors.textBlue
                                              : AppColors.textBlue.withValues(
                                                  alpha: 0.6,
                                                ),
                                        ),
                                        child: Text(
                                          "$unreadConversationsCount",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textWhite,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildOffersTab(role),
                            _buildMessagesTab(role, user.id),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}
