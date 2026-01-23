import 'dart:io';
import 'package:siren_marketplace/core/services/connectivity_service.dart';
import 'package:siren_marketplace/core/widgets/error_dialog.dart';

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/domain/entities/product.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/repositories/i_product_repository.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/providers/catch_filter_provider.dart';
import 'package:siren_marketplace/core/providers/catch_providers.dart';
import 'package:siren_marketplace/core/providers/product_providers.dart';
import 'package:siren_marketplace/core/providers/offer_providers.dart';
import 'package:siren_marketplace/core/providers/user_providers.dart';
import 'package:siren_marketplace/features/chat/presentation/providers/chat_providers.dart';
import 'package:siren_marketplace/features/chat/presentation/widgets/conversation_card.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/filter_button.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/number_input_field.dart';
import 'package:siren_marketplace/core/widgets/page_title.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/offer_card.dart';
import 'package:siren_marketplace/features/shared/presentation/widgets/catch_image.dart';
import 'package:siren_marketplace/core/widgets/offline_message_widget.dart';

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

  void _showOfflineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ErrorDialog(
        title: 'Offline',
        message: 'You need to be online to perform this action.',
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Product selectedCatch) {
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
              title: "Delete",
              onPressed: () async {
                final repository = sl<IProductRepository>();
                await repository.deleteProduct(selectedCatch.id);

                // Invalidate providers to refresh data
                ref.invalidate(productByIdProvider(widget.catchId));
                ref.invalidate(fisherProductsProvider);
                // Also invalidate old provider just in case if mixed usage exists (though we are moving away)
                ref.invalidate(fisherCatchesProvider);

                if (context.mounted) {
                  context.pop(); // Close dialog
                  context.pop(); // Go back to previous screen
                }
              },
            ),
            CustomButton(
              title: "Cancel",
              cancel: true,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCatchDialog(BuildContext context, Product selectedCatch) {
    // Note: Edit functionality might still depend on Catch Repository if Product Repo doesn't support updates yet.
    // Assuming we can still use Catch logic for updates or we need to update to use Product logic.
    // For now, keeping as is but using Product entity data.
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
    final double initialTotal = selectedCatch.totalPrice.amount.toDouble();
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
                              // Note: Product entity might not have separate initialWeight in same way or logic might differ
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
                            editable: false,
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
                        final repository = sl<IProductRepository>();
                        await repository.updateProduct(
                          selectedCatch.id,
                          pricePerKg: currentPricePerKg,
                          finalPrice: currentTotal,
                          availableWeight: currentWeightInputKg,
                        );

                        // Invalidate providers to refresh data
                        ref.invalidate(productByIdProvider(widget.catchId));
                        ref.invalidate(fisherProductsProvider);
                        // Also invalidate old provider just in case if mixed usage exists (though we are moving away)
                        ref.invalidate(fisherCatchesProvider);

                        if (context.mounted) {
                          Navigator.of(dialogCtx).pop();
                          showDialog(
                            context: context,
                            builder: (context) => const AlertDialog(
                              content: Text("Updated successfully"),
                            ),
                          );
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
    // Use PRODUCT provider here
    final productAsync = ref.watch(productByIdProvider(widget.catchId));
    final isOnline = ref.watch(isOnlineProvider);

    // We only fetch offers if we have the product and offersCount > 0
    // But we are in a build method.
    // We can conditionally watch.

    final filterState = ref.watch(catchFilterProvider);
    final filterNotifier = ref.read(catchFilterProvider.notifier);

    return Scaffold(
      body: productAsync.when(
        data: (selectedCatch) {
          if (selectedCatch == null) {
            return const Center(child: Text('Catch (Product) not found'));
          }

          // Fetch offers if count > 0 using the new provider
          // We use AsyncValue to handle loading/error states for offers
          AsyncValue<List<Offer>> offersAsync = const AsyncValue.data([]);

          if (selectedCatch.offersCount > 0) {
            offersAsync = ref.watch(productOffersProvider(widget.catchId));
          }

          return Scaffold(
            appBar: AppBar(
              leading: const BackButton(),
              title: const PageTitle(title: "Catch Details"),
              actions: [
                IconButton(
                  onPressed: () {
                    if (!isOnline) {
                      _showOfflineDialog(context);
                      return;
                    }
                    _showDeleteDialog(context, selectedCatch);
                  },
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
                          final providers = <ImageProvider>[];
                          if (selectedCatch.images.isNotEmpty) {
                            for (final image in selectedCatch.images) {
                              if (image.startsWith('http')) {
                                providers.add(NetworkImage(image));
                              } else if (image.startsWith('assets/')) {
                                providers.add(AssetImage(image));
                              } else {
                                providers.add(FileImage(File(image)));
                              }
                            }
                          } else if (selectedCatch.species.image.isNotEmpty) {
                            final image = selectedCatch.species.image;
                            if (image.startsWith('http')) {
                              providers.add(NetworkImage(image));
                            } else if (image.startsWith('assets/')) {
                              providers.add(AssetImage(image));
                            } else {
                              providers.add(FileImage(File(image)));
                            }
                          } else {
                            providers.add(
                              const AssetImage("assets/images/shrimp.jpg"),
                            );
                          }

                          if (providers.isNotEmpty) {
                            showImageViewerPager(
                              context,
                              MultiImageProvider(providers),
                              immersive: false,
                              useSafeArea: true,
                            );
                          }
                        },
                        child: CatchImage(
                          imageUrl: selectedCatch.images.isNotEmpty
                              ? selectedCatch.images.first
                              : null,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(8),
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
                          if (!isOnline) {
                            _showOfflineDialog(context);
                            return;
                          }
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
                            final currentUserAsync = ref.watch(
                              currentUserProvider,
                            );

                            return offersAsync.when(
                              data: (offers) {
                                // Filter offers locally for now or use separate provider filtering logic
                                // Assuming we want basic display first
                                final offersWithUpdates = offers
                                    .where((o) => o.hasUpdateForFisher)
                                    .length;

                                // Get unread messages count
                                final unreadMessagesCount = currentUserAsync
                                    .maybeWhen(
                                      data: (user) {
                                        if (user == null) return 0;
                                        // Use conversationsByProductProvider
                                        final conversationsAsync = ref.watch(
                                          conversationsByProductProvider(
                                            widget.catchId,
                                          ),
                                        );

                                        return conversationsAsync.maybeWhen(
                                          data: (conversations) {
                                            // API already filters by product, so we just count unread
                                            return conversations
                                                .where(
                                                  (conv) =>
                                                      conv.hasUnreadMessagesFor(
                                                        user.id,
                                                      ),
                                                )
                                                .length;
                                          },
                                          orElse: () => 0,
                                        );
                                      },
                                      orElse: () => 0,
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
                                    Tab(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text("Messages"),
                                          if (unreadMessagesCount > 0)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                left: 8,
                                              ),
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _tabController.index == 1
                                                    ? AppColors.textBlue
                                                    : AppColors.textBlue
                                                          .withValues(
                                                            alpha: .6,
                                                          ),
                                              ),
                                              child: Text(
                                                "$unreadMessagesCount",
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
                              // Pass offers directly. Need to handle filtering if necessary.
                              offersAsync.when(
                                data: (offers) {
                                  // Apply filtering and sorting based on filterState
                                  // Create a mutable copy of the list for sorting
                                  var filteredOffers = offers.toList();

                                  // Filter by status - only if filters are active
                                  if (filterState.activeStatuses.isNotEmpty) {
                                    // Convert to lowercase for case-insensitive comparison
                                    final lowercaseFilters = filterState
                                        .activeStatuses
                                        .map((s) => s.toLowerCase())
                                        .toList();

                                    filteredOffers = filteredOffers.where((
                                      offer,
                                    ) {
                                      return lowercaseFilters.contains(
                                        offer.status.name.toLowerCase(),
                                      );
                                    }).toList();
                                  }

                                  // Apply sorting
                                  filteredOffers.sort((a, b) {
                                    final comparison = b.dateUpdated.compareTo(
                                      a.dateUpdated,
                                    );
                                    return filterState.activeSortBy ==
                                            "ascending"
                                        ? -comparison
                                        : comparison;
                                  });

                                  return _buildOffersList(
                                    context,
                                    filteredOffers,
                                  );
                                },
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (e, s) =>
                                    Center(child: Text("Error: $e")),
                              ),
                              _buildMessagesList(
                                context,
                                filterState,
                                offersAsync,
                                isOnline, // Pass isOnline status
                              ),
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
      return RefreshIndicator(
        onRefresh: () async {
          ref.read(offerRepositoryProvider).clearCache();
          await ref.refresh(productOffersProvider(widget.catchId).future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: _buildEmptyState(
              "No matching offers.",
              "Try adjusting filters.",
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Clear cache and await refresh
        ref.read(offerRepositoryProvider).clearCache();
        await ref.refresh(productOffersProvider(widget.catchId).future);
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80, top: 16),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];

          // Use embedded buyer data instead of fetching separately
          return OfferCard(
            offer: offer,
            clientName: offer.buyer?.name ?? "Unknown",
            clientRating: offer.buyer?.rating.value ?? 0.0,
            onPressed: () async {
              await context.push("/fisher/offer-details/${offer.id}");
              // Refresh offers to show updated status (e.g. read/unread)
              ref.invalidate(productOffersProvider(widget.catchId));
            },
          );
        },
      ),
    );
  }

  Widget _buildMessagesList(
    BuildContext context,
    CatchFilterState filters,
    AsyncValue<List<Offer>> offersAsync,
    bool isOnline,
  ) {
    if (!isOnline) {
      return const SingleChildScrollView(
        child: OfflineMessageWidget(
          message: "Connect to internet to view messages.",
        ),
      );
    }

    // Use conversationsByProductProvider
    final conversationsAsync = ref.watch(
      conversationsByProductProvider(widget.catchId),
    );
    final currentUserAsync = ref.watch(currentUserProvider);

    return currentUserAsync.when(
      data: (user) {
        if (user == null) {
          return _buildEmptyState("User not found", "Please log in");
        }

        return conversationsAsync.when(
          data: (conversations) {
            // API already filters by product
            if (conversations.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    ref.refresh(
                      conversationsByProductProvider(widget.catchId).future,
                    ),
                    ref.refresh(productByIdProvider(widget.catchId).future),
                  ]);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: _buildEmptyState(
                      "No messages",
                      "Start a conversation from an offer.",
                    ),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  ref.refresh(
                    conversationsByProductProvider(widget.catchId).future,
                  ),
                  ref.refresh(productByIdProvider(widget.catchId).future),
                ]);
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80, top: 16),
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conv = conversations[index];
                  return ConversationCard(
                    conversation: conv,
                    currentUser: user,
                    onTap: () => context.push('/fisher/chat/${conv.id}'),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) =>
              _buildEmptyState("Error loading messages", e.toString()),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => _buildEmptyState("Error loading user", e.toString()),
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
