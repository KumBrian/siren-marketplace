import 'dart:io';

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/repositories/i_catch_repository.dart';
import 'package:siren_marketplace/core/domain/value_objects/price.dart';
import 'package:siren_marketplace/core/domain/value_objects/price_per_kg.dart';
import 'package:siren_marketplace/core/domain/value_objects/weight.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/providers/catch_filter_provider.dart';
import 'package:siren_marketplace/core/providers/catch_providers.dart';
import 'package:siren_marketplace/core/providers/conversation_providers.dart';
import 'package:siren_marketplace/core/providers/offer_providers.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/filter_button.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/number_input_field.dart';
import 'package:siren_marketplace/core/widgets/page_title.dart';
import 'package:siren_marketplace/features/chat/presentation/widgets/conversation_card.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/offer_card.dart';

class CatchDetails extends ConsumerStatefulWidget {
  const CatchDetails({super.key, required this.catchId});

  final String catchId;

  @override
  ConsumerState<CatchDetails> createState() => _CatchDetailsState();
}

class _CatchDetailsState extends ConsumerState<CatchDetails>
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

  void _showDeleteDialog(BuildContext context, Catch selectedCatch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                "Delete catch?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlue,
                ),
              ),
            ),
            Center(
              child: Text(
                selectedCatch.name,
                style: TextStyle(fontSize: 14, color: AppColors.textBlue),
              ),
            ),
            const SizedBox(height: 8),
            CustomButton(
              title: "Accept",
              onPressed: () async {
                final repository = sl<ICatchRepository>();
                await repository.delete(selectedCatch.id);

                // Invalidate providers to refresh data
                ref.invalidate(catchByIdProvider(widget.catchId));
                ref.invalidate(fisherCatchesProvider);

                if (context.mounted) {
                  context.pop(); // Close dialog
                  context.pop(); // Go back to previous screen
                }
              },
            ),
            CustomButton(
              title: "Reject",
              cancel: true,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCatchDialog(BuildContext context, Catch selectedCatch) {
    final editCatchFormKey = GlobalKey<FormState>();
    final TextEditingController weightController = TextEditingController();
    final TextEditingController pricePerKgController = TextEditingController();
    final TextEditingController totalController = TextEditingController();

    // Initial setup
    final double initialWeightInKg = selectedCatch.availableWeight.kilograms;
    weightController.text = initialWeightInKg.toString().replaceAll(
      RegExp(r"([.]*0)(?!.*\d)"),
      "",
    );

    pricePerKgController.text = selectedCatch.pricePerKg.amountPerKg.toString();
    final double initialTotal = selectedCatch.totalPrice.major;
    totalController.text = initialTotal.toStringAsFixed(0);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (stfCtx, setState) {
            final double currentWeightInputKg =
                double.tryParse(weightController.text) ?? 0.0;
            final double currentPricePerKg =
                double.tryParse(pricePerKgController.text) ?? 0;
            final double currentTotal =
                currentWeightInputKg * currentPricePerKg;

            totalController.text = currentTotal.toStringAsFixed(0);

            void updateStateOnChanged(String _) {
              setState(() {});
            }

            return AlertDialog(
              contentPadding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 24,
              ),
              constraints: const BoxConstraints(maxWidth: 500, minWidth: 450),
              title: Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                ),
              ),
              content: Form(
                key: editCatchFormKey,
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
                            label: "Available Weight",
                            role: UserRole.fisher,
                            suffix: "Kg",
                            onChanged: updateStateOnChanged,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a value';
                              }
                              final parsedValue = double.tryParse(value);
                              if (parsedValue == null) {
                                return 'Enter a valid number';
                              }
                              if (parsedValue >
                                  selectedCatch.initialWeight.kilograms) {
                                return 'Cannot exceed initial weight (${selectedCatch.initialWeight.kilograms} kg)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          NumberInputField(
                            controller: pricePerKgController,
                            label: "Price per Kg",
                            role: UserRole.fisher,
                            decimal: false,
                            suffix: "CFA",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a value';
                              }
                              final parsedValue = double.tryParse(value);
                              if (parsedValue == null) {
                                return 'Enter a valid number';
                              }
                              return null;
                            },
                            onChanged: updateStateOnChanged,
                          ),
                          const SizedBox(height: 16),
                          NumberInputField(
                            controller: totalController,
                            label: "Total",
                            role: UserRole.fisher,
                            suffix: "CFA",
                            onChanged: null,
                            decimal: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      title: "Update Catch",
                      onPressed: () async {
                        if (editCatchFormKey.currentState!.validate()) {
                          final updatedCatch = selectedCatch.copyWith(
                            availableWeight: Weight.fromKg(
                              currentWeightInputKg,
                            ),
                            pricePerKg: PricePerKg.fromAmount(
                              currentPricePerKg.floor(),
                            ),
                            totalPrice: Price.fromAmount(currentTotal.round()),
                          );

                          final repository = sl<ICatchRepository>();
                          await repository.update(updatedCatch);

                          // Invalidate providers to refresh data
                          ref.invalidate(catchByIdProvider(widget.catchId));
                          ref.invalidate(fisherCatchesProvider);

                          Navigator.of(dialogCtx).pop();
                        }
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

  @override
  Widget build(BuildContext context) {
    final catchAsync = ref.watch(catchByIdProvider(widget.catchId));
    final offersAsync = ref.watch(offersByCatchProvider(widget.catchId));
    final filteredOffers = ref.watch(filteredOffersProvider(widget.catchId));
    final filterState = ref.watch(catchFilterProvider);
    final filterNotifier = ref.read(catchFilterProvider.notifier);

    return Scaffold(
      body: catchAsync.when(
        data: (selectedCatch) {
          if (selectedCatch == null) {
            return const Center(child: Text('Catch not found'));
          }

          return Scaffold(
            appBar: AppBar(
              leading: const BackButton(),
              title: const PageTitle(title: "Catch Details"),
              actions: [
                IconButton(
                  onPressed: () => _showDeleteDialog(context, selectedCatch),
                  icon: const Icon(CustomIcons.trash, color: AppColors.fail500),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                spacing: 8,
                children: [
                  // Catch header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          final providers = selectedCatch.images
                              .map<ImageProvider>((img) {
                                if (img.startsWith("http")) {
                                  return NetworkImage(img);
                                } else if (img.startsWith("assets/")) {
                                  return AssetImage(img);
                                } else {
                                  return FileImage(File(img));
                                }
                              })
                              .toList();

                          if (providers.isEmpty) return;

                          final multiImageProvider = MultiImageProvider(
                            providers,
                          );
                          showImageViewerPager(
                            context,
                            multiImageProvider,
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
                          borderRadius: BorderRadius.circular(8),
                          child: selectedCatch.images.isEmpty
                              ? Image.asset(
                                  'assets/images/shrimp.jpg',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                              : (selectedCatch.images[0].startsWith("http")
                                    ? Image.network(
                                        selectedCatch.images[0],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stacktrace) =>
                                                Image.asset(
                                                  'assets/images/shrimp.jpg',
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                      )
                                    : (selectedCatch.images[0].startsWith(
                                            'assets/',
                                          )
                                          ? Image.asset(
                                              selectedCatch.images[0],
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              File(selectedCatch.images[0]),
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Image.asset(
                                                    'assets/images/shrimp.jpg',
                                                    width: 60,
                                                    height: 60,
                                                    fit: BoxFit.cover,
                                                  ),
                                            ))),
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
                              selectedCatch.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.textBlue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              selectedCatch.datePosted
                                  .toIso8601String()
                                  .toFormattedDate(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.gray650,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        splashRadius: 5,
                        icon: Icon(
                          CustomIcons.edit,
                          size: 14,
                          color: Color(0xFF0A2A45),
                        ),
                        onPressed: () {
                          _showEditCatchDialog(context, selectedCatch);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Catch info table
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: InfoTable(
                      rows: [
                        if (selectedCatch.species.id == "prawns")
                          InfoRow(label: "Size", value: selectedCatch.size),
                        if (selectedCatch.species.id != "prawns")
                          InfoRow(
                            label: "Average Size",
                            value: selectedCatch.size,
                          ),
                        InfoRow(
                          label: "Initial weight",
                          value: "${selectedCatch.initialWeight.kilograms} kg",
                        ),
                        InfoRow(
                          label: "Available weight",
                          value:
                              "${selectedCatch.availableWeight.kilograms} kg",
                        ),
                        InfoRow(
                          label: "Price/Kg",
                          value: formatPrice(
                            selectedCatch.pricePerKg.amountPerKg,
                          ),
                        ),
                        InfoRow(
                          label: "Total",
                          value: formatPrice(selectedCatch.totalPrice.amount),
                        ),
                      ],
                    ),
                  ),

                  // Filter and sort controls
                  AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_tabController.index == 0)
                            TextButton(
                              onPressed: () {
                                _showFilterBottomSheet(
                                  context,
                                  filterState,
                                  filterNotifier,
                                );
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    CustomIcons.filter,
                                    size: 20,
                                    color: AppColors.textBlue,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Filter${filterState.totalFilters == 0 ? "" : "(${filterState.totalFilters})"}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: AppColors.textBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_tabController.index == 0)
                            const SizedBox(width: 10),
                          TextButton(
                            onPressed: () {
                              filterNotifier.setSort(
                                filterState.activeSortBy == "ascending"
                                    ? "descending"
                                    : "ascending",
                              );
                            },
                            child: Row(
                              children: [
                                Icon(
                                  filterState.activeSortBy == "ascending"
                                      ? Icons.arrow_upward_outlined
                                      : Icons.arrow_downward_outlined,
                                  size: 20,
                                  color: AppColors.textBlue,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Date",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: AppColors.textBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Tabs
                  Expanded(
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _tabController,
                          builder: (context, _) {
                            return offersAsync.when(
                              data: (offers) {
                                final offersWithUpdates = offers
                                    .where((o) => o.hasUpdateForFisher)
                                    .length;

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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text("Offers"),
                                          if (offersWithUpdates > 0)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                left: 8,
                                              ),
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _tabController.index == 0
                                                    ? AppColors.textBlue
                                                    : AppColors.textBlue
                                                          .withValues(
                                                            alpha: .6,
                                                          ),
                                              ),
                                              child: Text(
                                                "$offersWithUpdates",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textWhite,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const Tab(text: "Messages"),
                                  ],
                                );
                              },
                              loading: () => TabBar(
                                controller: _tabController,
                                tabs: const [
                                  Tab(text: "Offers"),
                                  Tab(text: "Messages"),
                                ],
                              ),
                              error: (_, __) => TabBar(
                                controller: _tabController,
                                tabs: const [
                                  Tab(text: "Offers"),
                                  Tab(text: "Messages"),
                                ],
                              ),
                            );
                          },
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildOffersList(context, filteredOffers),
                              _buildMessagesList(context, filterState),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error loading catch: $error')),
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    CatchFilterState filterState,
    CatchFilterNotifier filterNotifier,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(catchFilterProvider);
            final notifier = ref.read(catchFilterProvider.notifier);

            return Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Filter by", style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 12),
                  const Text("Status"),
                  Text(
                    "Select all that apply",
                    style: TextStyle(fontSize: 12, color: AppColors.textGray),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: OfferStatus.values.map((status) {
                      final title =
                          status.name.substring(0, 1).toUpperCase() +
                          status.name.substring(1);
                      return FilterButton(
                        title: title,
                        color: AppColors.getStatusColor(status),
                        isSelected: state.pendingStatuses.contains(title),
                        onPressed: () => notifier.toggleStatus(title),
                      );
                    }).toList(),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          notifier.clearAllFilters();
                          context.pop();
                        },
                        child: const Text(
                          "Reset All",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      CustomButton(
                        title: "Apply Filters",
                        onPressed: () {
                          notifier.applyFilters();
                          context.pop();
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
  }

  Widget _buildOffersList(BuildContext context, List<Offer> offers) {
    if (offers.isEmpty) {
      return _buildEmptyState("No matching offers.", "Try adjusting filters.");
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, top: 16),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        final buyerAsync = ref.watch(buyerByIdProvider(offer.buyerId));

        return buyerAsync.when(
          data: (buyer) {
            return OfferCard(
              offer: offer,
              clientName: buyer?.name ?? "Unknown",
              clientRating: buyer?.rating.value ?? 0.0,
              onPressed: () =>
                  context.push("/fisher/offer-details/${offer.id}"),
            );
          },
          loading: () => OfferCard(
            offer: offer,
            clientName: "Loading...",
            clientRating: 0.0,
            onPressed: () => context.push("/fisher/offer-details/${offer.id}"),
          ),
          error: (_, __) => OfferCard(
            offer: offer,
            clientName: "Error",
            clientRating: 0.0,
            onPressed: () => context.push("/fisher/offer-details/${offer.id}"),
          ),
        );
      },
    );
  }

  Widget _buildMessagesList(BuildContext context, CatchFilterState filters) {
    // Get current user to fetch their conversations
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      data: (currentUser) {
        if (currentUser == null) {
          return _buildEmptyState(
            "Unable to load messages",
            "Please try again later",
          );
        }

        // Get all conversations for the current user (fisher)
        final conversationsAsync = ref.watch(
          userConversationsProvider(currentUser.id),
        );

        return conversationsAsync.when(
          data: (allConversations) {
            // Get offers for this catch to find relevant buyer IDs
            final offersAsync = ref.watch(
              offersByCatchProvider(widget.catchId),
            );

            return offersAsync.when(
              data: (offers) {
                // Get unique buyer IDs from offers
                final buyerIds = offers.map((o) => o.buyerId).toSet();

                // Filter conversations to only those with buyers who made offers
                final relevantConversations = allConversations.where((conv) {
                  final otherUserId = conv.getOtherParticipantId(
                    currentUser.id,
                  );
                  return buyerIds.contains(otherUserId);
                }).toList();

                if (relevantConversations.isEmpty) {
                  return _buildEmptyState(
                    "No messages yet",
                    "Buyers will appear here after making offers",
                  );
                }

                // Sort conversations by last message time
                relevantConversations.sort((a, b) {
                  if (filters.activeSortBy == "ascending") {
                    return a.lastMessageTime.compareTo(b.lastMessageTime);
                  } else {
                    return b.lastMessageTime.compareTo(a.lastMessageTime);
                  }
                });

                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 80, top: 16),
                  itemCount: relevantConversations.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 0),
                  itemBuilder: (context, index) {
                    final conversation = relevantConversations[index];
                    return ConversationCard(
                      conversation: conversation,
                      currentUserId: currentUser.id,
                      onTap: () {
                        context.push('/fisher/chat/${conversation.id}');
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Error loading offers: $e")),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Error loading messages: $e")),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error loading user: $e")),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: AppColors.gray200),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: AppColors.textGray),
          ),
        ],
      ),
    );
  }
}
