import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_state.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/filter_button.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/message_card.dart';
import 'package:siren_marketplace/core/widgets/number_input_field.dart';
import 'package:siren_marketplace/features/chat/data/models/message.dart';
import 'package:siren_marketplace/features/fisher/logic/catch_bloc/catch_bloc.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/offer_card.dart';

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
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  // Inside _CatchDetailsState

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

            // 🔑 REMOVED the nested BlocBuilder and success dialog here.
            CustomButton(
              title: "Accept",
              onPressed: () {
                // Dispatch the event directly to the CatchesBloc
                context.read<CatchesBloc>().add(
                  DeleteCatchEvent(selectedCatch.id),
                );
                // Close the initial confirmation dialog
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
    final _weightFormKey = GlobalKey<FormState>();
    final _priceFormKey = GlobalKey<FormState>();
    final TextEditingController weightController = TextEditingController();
    final TextEditingController pricePerKgController = TextEditingController();

    return Scaffold(
      body: BlocListener<CatchesBloc, CatchesState>(
        bloc: context.read<CatchesBloc>(),

        listenWhen: (previous, current) {
          return current is CatchDeletedSuccess;
        },
        listener: (context, state) {
          if (state is CatchDeletedSuccess) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (successCtx) => AlertDialog(
                title: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.textBlue,
                    border: Border.all(color: AppColors.textBlue, width: 2),
                  ),
                  child: const Icon(Icons.check, color: AppColors.textWhite),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: Text(
                        "Catch deleted!",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      title: "All Catches",
                      onPressed: () {
                        successCtx.pop();
                        context.go("/fisher");
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
        child: BlocBuilder<CatchesBloc, CatchesState>(
          builder: (context, catchesState) {
            // 1. Handle Transient Success State (Show nothing, let Listener handle dialog/nav)
            if (catchesState is CatchDeletedSuccess) {
              return const Scaffold(
                backgroundColor: Colors.white,
                body: SizedBox.shrink(),
              );
            }

            // 2. Handle Loading/Initial States
            if (catchesState is CatchesLoading ||
                catchesState is CatchesInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            // 3. Handle Errors
            if (catchesState is CatchesError) {
              return Center(
                child: Text('Error loading catches: ${catchesState.message}'),
              );
            }

            if (catchesState is CatchesLoaded) {
              final catches = catchesState.catches;
              Catch selectedCatch;
              try {
                selectedCatch = catches.firstWhere(
                  (c) => c.id == widget.catchId,
                );
                final messagesForCatch = PLACEHOLDER_MESSAGES;
                return Scaffold(
                  appBar: AppBar(
                    leading: const BackButton(),
                    title: const Text(
                      "Catch Details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: AppColors.textBlue,
                      ),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () =>
                            _showDeleteDialog(context, selectedCatch),
                        icon: const Icon(
                          CustomIcons.trash,
                          color: AppColors.fail500,
                        ),
                      ),
                    ],
                  ),

                  body: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Column(
                      spacing: 8,
                      children: [
                        // --- Header Row ---
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
                                    selectedCatch.datePosted.toFormattedDate(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.gray650,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // --- Info Table ---
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.gray200),
                          ),
                          child: InfoTable(
                            rows: [
                              ?selectedCatch.species.id == "prawns"
                                  ? InfoRow(
                                      label: "Average Size",
                                      value: selectedCatch.size,
                                    )
                                  : null,
                              InfoRow(
                                label: "Initial weight",
                                suffix: "Kg",
                                value: selectedCatch.initialWeight.toInt(),
                              ),
                              InfoRow(
                                label: "Available weight",
                                suffix: "Kg",
                                value: selectedCatch.availableWeight.toInt(),
                                editable: true,
                                onEdit: () {
                                  weightController.text = selectedCatch
                                      .availableWeight
                                      .toString();
                                  pricePerKgController.clear();

                                  showDialog(
                                    context: context,
                                    builder: (dialogCtx) {
                                      return AlertDialog(
                                        contentPadding: const EdgeInsets.only(
                                          left: 24,
                                          right: 24,
                                          bottom: 24,
                                        ),
                                        constraints: const BoxConstraints(
                                          maxWidth: 500,
                                          minWidth: 450,
                                        ),
                                        title: Align(
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                            icon: const Icon(Icons.close),
                                            onPressed: () =>
                                                Navigator.of(dialogCtx).pop(),
                                          ),
                                        ),
                                        content: StatefulBuilder(
                                          builder: (ctx, setLocalState) {
                                            double currentWeight =
                                                selectedCatch.availableWeight;

                                            return Form(
                                              key: _weightFormKey,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          16,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color:
                                                            AppColors.textBlue,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        NumberInputField(
                                                          controller:
                                                              weightController,
                                                          label:
                                                              "Available Weight",
                                                          role: Role.fisher,
                                                          suffix: "Kg",
                                                          onChanged: (value) {
                                                            setLocalState(() {
                                                              currentWeight =
                                                                  double.parse(
                                                                    value.isEmpty
                                                                        ? "0"
                                                                        : value,
                                                                  );
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  CustomButton(
                                                    title: "Update Weight",
                                                    onPressed: () async {
                                                      if (_weightFormKey
                                                          .currentState!
                                                          .validate()) {
                                                        final newWeight =
                                                            double.tryParse(
                                                              weightController
                                                                  .text,
                                                            ) ??
                                                            0.0;

                                                        final newTotal =
                                                            newWeight *
                                                            selectedCatch
                                                                .pricePerKg;

                                                        final updatedCatch =
                                                            selectedCatch
                                                                .copyWith(
                                                                  availableWeight:
                                                                      newWeight,
                                                                  total:
                                                                      newTotal,
                                                                );

                                                        // 4. Dispatch the event
                                                        context
                                                            .read<CatchesBloc>()
                                                            .add(
                                                              UpdateCatchEvent(
                                                                updatedCatch,
                                                              ),
                                                            );

                                                        Navigator.of(
                                                          dialogCtx,
                                                        ).pop();
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              InfoRow(
                                label: "Price/Kg",
                                value: formatPrice(selectedCatch.pricePerKg),
                                editable: true,
                                onEdit: () {
                                  pricePerKgController.text = selectedCatch
                                      .pricePerKg
                                      .toString();
                                  weightController.clear();

                                  showDialog(
                                    context: context,
                                    builder: (dialogCtx) {
                                      return AlertDialog(
                                        contentPadding: const EdgeInsets.only(
                                          left: 24,
                                          right: 24,
                                          bottom: 24,
                                        ),
                                        constraints: const BoxConstraints(
                                          maxWidth: 500,
                                          minWidth: 450,
                                        ),
                                        title: Align(
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                            icon: const Icon(Icons.close),
                                            onPressed: () =>
                                                Navigator.of(dialogCtx).pop(),
                                          ),
                                        ),
                                        content: StatefulBuilder(
                                          builder: (ctx, setLocalState) {
                                            double currentPrice =
                                                selectedCatch.pricePerKg;

                                            return Form(
                                              key: _priceFormKey,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          16,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color:
                                                            AppColors.textBlue,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        NumberInputField(
                                                          controller:
                                                              pricePerKgController,
                                                          label: "Price per Kg",
                                                          role: Role.fisher,
                                                          suffix: "CFA",
                                                          onChanged: (value) {
                                                            setLocalState(() {
                                                              currentPrice =
                                                                  double.parse(
                                                                    value.isEmpty
                                                                        ? "0"
                                                                        : value,
                                                                  );
                                                            });
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  CustomButton(
                                                    title: "Update Price/Kg",
                                                    onPressed: () async {
                                                      if (_priceFormKey
                                                          .currentState!
                                                          .validate()) {
                                                        final newPrice =
                                                            double.tryParse(
                                                              pricePerKgController
                                                                  .text,
                                                            ) ??
                                                            0.0;

                                                        final newTotal =
                                                            newPrice *
                                                            selectedCatch
                                                                .availableWeight;

                                                        final updatedCatch =
                                                            selectedCatch
                                                                .copyWith(
                                                                  pricePerKg:
                                                                      newPrice,
                                                                  total:
                                                                      newTotal,
                                                                );

                                                        context
                                                            .read<CatchesBloc>()
                                                            .add(
                                                              UpdateCatchEvent(
                                                                updatedCatch,
                                                              ),
                                                            );

                                                        Navigator.of(
                                                          dialogCtx,
                                                        ).pop();
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              InfoRow(
                                label: "Total",
                                value: formatPrice(selectedCatch.total),
                                onEdit: () {},
                              ),
                            ],
                          ),
                        ),

                        // --- Filters ---
                        BlocBuilder<CatchFilterCubit, CatchFilterState>(
                          builder: (context, state) {
                            final cubit = context.read<CatchFilterCubit>();
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    // Filter Modal logic
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
                                      SizedBox(width: 8),
                                      Text(
                                        "Filter${state.totalFilters == 0 ? "" : "(${state.totalFilters})"}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          color: AppColors.textBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                        ),

                        // --- Tabs (Offers / Messages) ---
                        Expanded(
                          child: Column(
                            children: [
                              AnimatedBuilder(
                                animation: _tabController,
                                builder: (context, _) {
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
                                            if (selectedCatch.offers.isNotEmpty)
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  left: 8,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      _tabController.index == 0
                                                      ? AppColors.textBlue
                                                      : AppColors.textBlue
                                                            .withValues(
                                                              alpha: .6,
                                                            ),
                                                ),
                                                child: Text(
                                                  "${selectedCatch.offers.length}",
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
                                            if (messagesForCatch.isNotEmpty)
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  left: 8,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      _tabController.index == 1
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
                              ),
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController,
                                  physics: const BouncingScrollPhysics(),
                                  children: [
                                    // Offers Tab
                                    _buildOffersList(
                                      context,
                                      selectedCatch,
                                      context.watch<CatchFilterCubit>().state,
                                    ),

                                    // Messages Tab
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
              } catch (_) {
                return const Scaffold(
                  backgroundColor: AppColors.white100,
                  body: SizedBox.shrink(),
                );
              }

              // Use the placeholder for messages
            }
            return const Scaffold(backgroundColor: AppColors.white100);
          },
        ),
      ),
    );
  }

  // --- Helper to build the Offers List with Filters ---
  Widget _buildOffersList(
    BuildContext context,
    Catch selectedCatch,
    CatchFilterState filters,
  ) {
    Iterable<Offer> filteredOffers = selectedCatch.offers;

    // Filter by Status
    if (filters.activeStatuses.isNotEmpty) {
      filteredOffers = filteredOffers.where((offer) {
        final statusName = offer.status.name;
        return filters.activeStatuses.contains(
          statusName.substring(0, 1).toUpperCase() + statusName.substring(1),
        );
      });
    }

    // Sort by Date
    final sortedOffers = filteredOffers.toList()
      ..sort((a, b) {
        final dateA = DateTime.parse(a.dateCreated);
        final dateB = DateTime.parse(b.dateCreated);

        if (filters.activeSortBy == "ascending") {
          return dateA.compareTo(dateB);
        } else {
          return dateB.compareTo(dateA);
        }
      });

    if (sortedOffers.isEmpty) {
      return _buildEmptyState(
        "No offers received yet.",
        "Buyers are reviewing your captures.",
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 80, top: sortedOffers.isEmpty ? 16 : 0),
      itemCount: sortedOffers.length,

      itemBuilder: (context, index) {
        final offer = sortedOffers[index];

        return OfferCard(
          offer: offer,
          clientName: offer.buyerName,
          clientRating: offer.buyerRating,

          onPressed: () {
            context.push("/fisher/offer-details/${offer.id}");
          },
        );
      },
    );
  }

  // --- Helper to build the Messages List ---
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

  // --- Generic Empty State Builder ---
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
