import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_state.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/domain/entities/catch.dart';
import 'package:siren_marketplace/core/domain/entities/offer.dart';
import 'package:siren_marketplace/core/domain/enums/offer_status.dart';
import 'package:siren_marketplace/core/domain/enums/user_role.dart';
import 'package:siren_marketplace/core/domain/value_objects/price.dart';
import 'package:siren_marketplace/core/domain/value_objects/price_per_kg.dart';
import 'package:siren_marketplace/core/domain/value_objects/weight.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/filter_button.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/message_card.dart';
import 'package:siren_marketplace/core/widgets/number_input_field.dart';
import 'package:siren_marketplace/core/widgets/page_title.dart';
import 'package:siren_marketplace/features/chat/data/models/message.dart';
import 'package:siren_marketplace/features/fisher/logic/catches_bloc/catches_cubit.dart';
import 'package:siren_marketplace/features/fisher/logic/offers_bloc/offers_cubit.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/offer_card.dart';
import 'package:siren_marketplace/features/user/logic/user_cubit/user_cubit.dart';

List<Message> PLACEHOLDER_MESSAGES = [
  // Example data
  Message(
    messageId: 'm1',
    clientName: 'Jean Buyer',
    lastMessageTime: '2025-10-09T10:00:00',
    lastMessage: 'I can take 50kg at that price.',
    unreadCount: 1,
    avatarPath: 'https://i.pravatar.cc/150?img=8',
  ),
  Message(
    messageId: 'm2',
    clientName: 'Alice Corp',
    lastMessageTime: '2025-10-08T15:30:00',
    lastMessage: 'Check your email for the contract.',
    unreadCount: 0,
    avatarPath: 'https://i.pravatar.cc/150?img=40',
  ),
];

class CatchDetails extends StatefulWidget {
  const CatchDetails({super.key, required this.catchId});

  final String catchId;

  @override
  State<CatchDetails> createState() => _CatchDetailsState();
}

class _CatchDetailsState extends State<CatchDetails>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load catch and offers data
    context.read<CatchesCubit>().loadById(widget.catchId);
    context.read<OffersCubit>().loadByCatchId(widget.catchId);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
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
              onPressed: () {
                // Get fisher ID from user state
                final userState = context.read<UserCubit>().state;
                if (userState is UserLoaded) {
                  context.read<CatchesCubit>().deleteCatch(
                    selectedCatch.id,
                    userState.user!.id,
                  );
                }
                context.pop();
              },
            ),

            CustomButton(
              title: "Reject",
              cancel: true,
              onPressed: () {
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editCatchFormKey = GlobalKey<FormState>();
    final TextEditingController weightController = TextEditingController();
    final TextEditingController pricePerKgController = TextEditingController();
    final TextEditingController totalController = TextEditingController();

    void showEditCatchDialog(BuildContext context, Catch selectedCatch) {
      // Initial setup: Display weight in Kg
      final double initialWeightInKg = selectedCatch.availableWeight.kilograms;
      weightController.text = initialWeightInKg.toString().replaceAll(
        RegExp(r"([.]*0)(?!.*\d)"),
        "",
      );

      pricePerKgController.text = selectedCatch.pricePerKg.amountPerKg
          .toString();

      // Initial calculation for the read-only field
      final double initialTotal = selectedCatch.totalPrice.major;
      totalController.text = initialTotal.toStringAsFixed(0);

      showDialog(
        context: context,
        builder: (dialogCtx) {
          return StatefulBuilder(
            builder: (stfCtx, setState) {
              // Parse User Input (Kg)
              final double currentWeightInputKg =
                  double.tryParse(weightController.text) ?? 0.0;

              // Parse Price
              final double currentPricePerKg =
                  double.tryParse(pricePerKgController.text) ?? 0;

              // Calculate Total
              final double currentTotal =
                  currentWeightInputKg * currentPricePerKg;

              // Update the read-only controller's text
              totalController.text = currentTotal.toStringAsFixed(0);

              // Helper to trigger rebuild
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
                              // Read-only
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
                            // Update using value objects
                            final updatedCatch = selectedCatch.copyWith(
                              availableWeight: Weight.fromKg(
                                currentWeightInputKg,
                              ),
                              pricePerKg: PricePerKg.fromAmount(
                                currentPricePerKg.floor(),
                              ),
                              totalPrice: Price.fromMajor(currentTotal),
                            );

                            context.read<CatchesCubit>().updateCatch(
                              updatedCatch,
                            );
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

    return Scaffold(
      body: BlocBuilder<CatchesCubit, CatchesState>(
        builder: (context, catchesState) {
          if (catchesState.loading && catchesState.catches.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (catchesState.error != null && catchesState.catches.isEmpty) {
            return Center(
              child: Text('Error loading catch: ${catchesState.error}'),
            );
          }

          if (catchesState.catches.isEmpty) {
            return const Center(child: Text('Catch not found'));
          }

          final selectedCatch = catchesState.catches.first;
          final messagesForCatch = PLACEHOLDER_MESSAGES;

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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          final providers = selectedCatch.images
                              .map<ImageProvider>(
                                (img) => img.startsWith("http")
                                    ? NetworkImage(img)
                                    : AssetImage(img) as ImageProvider,
                              )
                              .toList();

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
                          child: selectedCatch.images[0].contains("http")
                              ? Image.network(
                                  selectedCatch.images.isNotEmpty
                                      ? selectedCatch.images[0]
                                      : 'https://via.placeholder.com/60',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stacktrace) =>
                                      Image.asset(
                                        'assets/images/shrimp.jpg',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                )
                              : Image.asset(
                                  selectedCatch.images.isNotEmpty
                                      ? selectedCatch.images[0]
                                      : 'assets/images/prawns.jpg',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
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
                          showEditCatchDialog(context, selectedCatch);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: InfoTable(
                      rows: [
                        ?selectedCatch.species.id == "prawns"
                            ? InfoRow(label: "Size", value: selectedCatch.size)
                            : null,
                        ?selectedCatch.species.id != "prawns"
                            ? InfoRow(
                                label: "Average Size",
                                value: "${selectedCatch.size} cm",
                              )
                            : null,
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

                  AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, child) {
                      return BlocBuilder<CatchFilterCubit, CatchFilterState>(
                        builder: (context, state) {
                          final cubit = context.read<CatchFilterCubit>();
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (_tabController.index == 0)
                                TextButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      showDragHandle: true,
                                      builder: (context) {
                                        return BlocBuilder<
                                          CatchFilterCubit,
                                          CatchFilterState
                                        >(
                                          builder: (innerContext, innerState) {
                                            final innerCubit = innerContext
                                                .read<CatchFilterCubit>();
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                left: 16,
                                                right: 16,
                                                top: 16,
                                                bottom: 32,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "Filter by",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
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
                                                      final title =
                                                          status.name
                                                              .substring(0, 1)
                                                              .toUpperCase() +
                                                          status.name.substring(
                                                            1,
                                                          );
                                                      return FilterButton(
                                                        title: title,
                                                        color:
                                                            AppColors.getStatusColor(
                                                              status,
                                                            ),
                                                        isSelected: innerState
                                                            .pendingStatuses
                                                            .contains(title),
                                                        onPressed: () =>
                                                            innerCubit
                                                                .toggleStatus(
                                                                  title,
                                                                ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                  const Divider(),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      TextButton(
                                                        onPressed: () {
                                                          innerCubit
                                                              .clearAllFilters();
                                                          innerContext.pop();
                                                        },
                                                        child: const Text(
                                                          "Reset All",
                                                          style: TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                          ),
                                                        ),
                                                      ),
                                                      CustomButton(
                                                        title: "Apply Filters",
                                                        onPressed: () {
                                                          innerCubit
                                                              .applyFilters();
                                                          innerContext.pop();
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
                                  child: Row(
                                    children: [
                                      Icon(
                                        CustomIcons.filter,
                                        size: 20,
                                        color: AppColors.textBlue,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Filter${state.totalFilters == 0 ? "" : "(${state.totalFilters})"}",
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
                                  cubit.setSort(
                                    state.activeSortBy == "ascending"
                                        ? "descending"
                                        : "ascending",
                                  );
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      state.activeSortBy == "ascending"
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
                      );
                    },
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _tabController,
                          builder: (context, _) {
                            return BlocBuilder<OffersCubit, OffersState>(
                              builder: (context, offersState) {
                                final offersWithUpdates = offersState.offers
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
                                    Tab(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text("Messages"),
                                          if (false)
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
                                                "${messagesForCatch.length}",
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
                            );
                          },
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              BlocBuilder<OffersCubit, OffersState>(
                                builder: (context, offerState) {
                                  return _buildOffersList(
                                    context,
                                    offerState.offers,
                                    context.watch<CatchFilterCubit>().state,
                                  );
                                },
                              ),
                              _buildMessagesList(
                                context,
                                messagesForCatch,
                                context.watch<CatchFilterCubit>().state,
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
      ),
    );
  }

  Widget _buildOffersList(
    BuildContext context,
    List<Offer> offers,
    CatchFilterState filters,
  ) {
    final filteredOffers = offers.where((offer) {
      if (filters.activeStatuses.isEmpty) return true;
      final statusName = offer.status.name.capitalize();
      return filters.activeStatuses.contains(statusName);
    }).toList();

    filteredOffers.sort((a, b) {
      final dateA = a.dateCreated;
      final dateB = b.dateCreated;
      return filters.activeSortBy == "ascending"
          ? dateA.compareTo(dateB)
          : dateB.compareTo(dateA);
    });

    if (filteredOffers.isEmpty) {
      return _buildEmptyState("No matching offers.", "Try adjusting filters.");
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80, top: 16),
      itemCount: filteredOffers.length,
      itemBuilder: (context, index) {
        final offer = filteredOffers[index];
        return OfferCard(
          offer: offer,
          clientName: "Buyer", // TODO: Load buyer name separately
          clientRating: 0.0, // TODO: Load buyer rating separately
          onPressed: () => context.push("/fisher/offer-details/${offer.id}"),
        );
      },
    );
  }

  Widget _buildMessagesList(
    BuildContext context,
    List<Message> messages,
    CatchFilterState filters,
  ) {
    if (messages.isEmpty) {
      return _buildEmptyState(
        "You have no messages yet.",
        "You will receive messages shortly",
      );
    }

    final sortedMessages = messages
      ..sort((a, b) {
        final dateA = DateTime.parse(a.lastMessageTime);
        final dateB = DateTime.parse(b.lastMessageTime);

        if (filters.activeSortBy == "ascending") {
          return dateA.compareTo(dateB);
        } else {
          return dateB.compareTo(dateA);
        }
      });

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 80, top: messages.isEmpty ? 16 : 0),
      itemCount: sortedMessages.length,
      itemBuilder: (context, index) {
        final msg = sortedMessages[index];
        return MessageCard(
          messageId: msg.messageId,
          name: msg.clientName,
          time: msg.lastMessageTime.toFormattedDate(),
          message: msg.lastMessage,
          unreadCount: msg.unreadCount,
          avatarPath: msg.avatarPath,
          onPressed: () => context.go('/fisher/chat'),
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textBlue,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            subtitle,
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
}
