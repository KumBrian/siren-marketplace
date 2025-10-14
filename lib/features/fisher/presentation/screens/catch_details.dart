// lib/screens/fisher/catch_details.dart (Full Code)

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
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/filter_button.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/message_card.dart';
import 'package:siren_marketplace/features/chat/data/models/message.dart';
import 'package:siren_marketplace/features/fisher/logic/catch_bloc/catch_bloc.dart';
import 'package:siren_marketplace/features/fisher/presentation/widgets/offer_card.dart';

// --- ⚠️ Conceptual/Placeholder Model for Messages ⚠️ ---
const List<Message> PLACEHOLDER_MESSAGES = [
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
// --------------------------------------------------------

// --- 🆕 Conceptual/Placeholder Data for Buyer Lookup 🆕 ---
// This simulates fetching the client's name and rating using the offer.buyerId.
// You would replace this with a real BuyerRepository lookup.
const Map<String, ({String name, double rating})> PLACEHOLDER_BUYER_DATA = {
  'buyer-123': (name: 'Jean Buyer', rating: 4.5),
  'buyer-456': (name: 'Alice Corp', rating: 4.9),
  // Default fallback for any other ID
  'default': (name: 'Anonymous Buyer', rating: 3.0),
};
// -----------------------------------------------------------

class CatchDetails extends StatefulWidget {
  const CatchDetails({super.key, required this.catchId});

  final String catchId;

  @override
  State<CatchDetails> createState() => _CatchDetailsState();
}

class _CatchDetailsState extends State<CatchDetails> {
  void _showDeleteDialog(BuildContext context) {
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
            const SizedBox(height: 8),

            CustomButton(
              title: "Delete",
              onPressed: () {
                // TODO: Dispatch DeleteCatch(widget.catchId) to CatchesBloc
                context.pop();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.textBlue,
                        border: Border.all(color: AppColors.textBlue, width: 2),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.textWhite,
                      ),
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
                              color: AppColors.textBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          title: "All Catches",
                          onPressed: () {
                            context.go("/fisher");
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            CustomButton(
              title: "Cancel",
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
            onPressed: () => _showDeleteDialog(context),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.fail500,
            ),
          ),
        ],
      ),
      // --- Sourcing data from CatchesBloc ---
      body: BlocBuilder<CatchesBloc, CatchesState>(
        builder: (context, catchesState) {
          // 1. Handle Loading and Error states
          if (catchesState is CatchesLoading ||
              catchesState is CatchesInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (catchesState is CatchesError) {
            return Center(
              child: Text('Error loading catches: ${catchesState.message}'),
            );
          }

          // 2. Locate the specific Catch
          if (catchesState is CatchesLoaded) {
            final catches = catchesState.catches;
            Catch selectedCatch;
            try {
              // Assuming your Catch model has an 'id' field
              selectedCatch = catches.firstWhere((c) => c.id == widget.catchId);
            } catch (_) {
              return Center(
                child: Text("Catch with ID ${widget.catchId} not found."),
              );
            }

            // Use the placeholder for messages
            final messagesForCatch = PLACEHOLDER_MESSAGES;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
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
                          borderRadius: BorderRadius.circular(16),
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
                          label: "Species",
                          value: selectedCatch.species.name,
                        ),
                        InfoRow(
                          label: "Average Size",
                          value: selectedCatch.size,
                        ),
                        InfoRow(
                          label: "Initial weight",
                          suffix: "Kg",
                          value: selectedCatch.initialWeight.toStringAsFixed(1),
                        ),
                        InfoRow(
                          label: "Available weight",
                          suffix: "Kg",
                          value: selectedCatch.availableWeight.toStringAsFixed(
                            1,
                          ),
                          editable: true,
                          onEdit: () {},
                        ),
                        InfoRow(
                          label: "Price/Kg",
                          suffix: "CFA",
                          value: selectedCatch.pricePerKg.toInt(),
                          editable: true,
                          onEdit: () {},
                        ),
                        InfoRow(
                          label: "Total",
                          suffix: "CFA",
                          value: selectedCatch.total.toInt(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

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
                                    builder: (context, state) {
                                      final cubit = context
                                          .read<CatchFilterCubit>();

                                      return Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                final title =
                                                    status.name
                                                        .substring(0, 1)
                                                        .toUpperCase() +
                                                    status.name.substring(1);
                                                final color =
                                                    status ==
                                                        OfferStatus.pending
                                                    ? AppColors.shellOrange
                                                    : status ==
                                                          OfferStatus.accepted
                                                    ? AppColors.blue400
                                                    : status ==
                                                          OfferStatus.completed
                                                    ? AppColors.textGray
                                                    : AppColors.fail500;
                                                return FilterButton(
                                                  title: title,
                                                  color: color,
                                                  isSelected: state
                                                      .selectedStatuses
                                                      .contains(title),
                                                  onPressed: () =>
                                                      cubit.toggleStatus(title),
                                                );
                                              }).toList(),
                                            ),
                                            const Divider(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                      decoration: TextDecoration
                                                          .underline,
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
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.filter_alt_outlined,
                                  size: 20,
                                  color: AppColors.textBlue,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Filter",
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
                                state.sortBy == "ascending"
                                    ? "descending"
                                    : "ascending",
                              );
                            },
                            child: Row(
                              children: [
                                Icon(
                                  state.sortBy == "ascending"
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
                  const SizedBox(height: 16),

                  // --- Tabs (Offers / Messages) ---
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          TabBar(
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
                                    if (selectedCatch.offers.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.textBlue,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Messages"),
                                    if (messagesForCatch.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.textBlue,
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
                          ),
                          Expanded(
                            child: TabBarView(
                              physics: const BouncingScrollPhysics(),
                              children: [
                                // Offers Tab
                                _buildOffersList(
                                  context,
                                  selectedCatch,
                                  context.watch<CatchFilterCubit>().state,
                                ),

                                // Messages Tab
                                _buildMessagesList(context, messagesForCatch),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text("Unexpected catches state."));
        },
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
    if (filters.selectedStatuses.isNotEmpty) {
      filteredOffers = filteredOffers.where((offer) {
        final statusName = offer.status.name;
        // Check for case-insensitive match (assuming enum names are lowercase in the model, uppercase in filter)
        return filters.selectedStatuses.contains(
          statusName.substring(0, 1).toUpperCase() + statusName.substring(1),
        );
      });
    }

    // Sort by Date
    final sortedOffers = filteredOffers.toList()
      ..sort((a, b) {
        // Assume dateCreated is an ISO8601 string or similar parsable date
        final dateA = DateTime.parse(a.dateCreated);
        final dateB = DateTime.parse(b.dateCreated);

        if (filters.sortBy == "ascending") {
          return dateA.compareTo(dateB);
        } else {
          return dateB.compareTo(dateA);
        }
      });

    if (sortedOffers.isEmpty) {
      return _buildEmptyState(
        "No offers received yet.",
        "assets/images/no-offers.png",
        "Buyers are reviewing your captures.",
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80, top: 16),
      itemCount: sortedOffers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
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
  Widget _buildMessagesList(BuildContext context, List<Message> messages) {
    if (messages.isEmpty) {
      return _buildEmptyState(
        "You have no messages yet.",
        "assets/images/no-messages.png",
        "You will receive messages shortly",
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 80, top: 16),
      itemCount: messages.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final msg = messages[index];
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
  Widget _buildEmptyState(String title, String imagePath, String subtitle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 120, width: 120, child: Image.asset(imagePath)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textGray,
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
