import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_state.dart';
import 'package:siren_marketplace/bloc/cubits/fisher_cubit/fisher_cubit.dart';
import 'package:siren_marketplace/components/custom_button.dart';
import 'package:siren_marketplace/components/filter_button.dart';
import 'package:siren_marketplace/components/fisher_offer_card.dart';
import 'package:siren_marketplace/components/info_table.dart';
import 'package:siren_marketplace/components/message_card.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';

class CatchDetails extends StatefulWidget {
  const CatchDetails({super.key, required this.catchId});

  final String catchId;

  @override
  State<CatchDetails> createState() => _CatchDetailsState();
}

class _CatchDetailsState extends State<CatchDetails> {
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
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: BlocBuilder<FisherCubit, Fisher?>(
        builder: (context, fisher) {
          if (fisher == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final selectedCatch = fisher.catches.firstWhere(
            (c) => c.catchId == widget.catchId,
            orElse: () => throw Exception("Catch not found"),
          );

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              spacing: 16,
              children: [
                // --- Header Row ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
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
                          backgroundColor: Colors.black.withValues(alpha: 0.4),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          selectedCatch.images[0],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 8,
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

                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: InfoTable(
                    rows: [
                      InfoRow(label: "Size", value: selectedCatch.size),
                      InfoRow(
                        label: "Initial weight",
                        suffix: "Kg",
                        value: selectedCatch.initialWeight.toStringAsFixed(1),
                      ),
                      InfoRow(
                        label: "Available weight",
                        suffix: "Kg",
                        value: selectedCatch.availableWeight.toStringAsFixed(1),
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
                // --- Filters ---
                BlocBuilder<CatchFilterCubit, CatchFilterState>(
                  builder: (context, state) {
                    final cubit = context.read<CatchFilterCubit>();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      spacing: 10,
                      children: [
                        TextButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              showDragHandle: true,
                              builder: (context) {
                                return Container(
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    bottom: 32,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 12,
                                    children: [
                                      const Text("Status"),
                                      Text(
                                        "Select all that apply",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textGray,
                                        ),
                                      ),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
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
                                            onPressed: () {},
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Row(
                            spacing: 8,
                            children: [
                              Icon(
                                Icons.filter_alt_outlined,
                                size: 20,
                                color: AppColors.textBlue,
                              ),
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
                        TextButton(
                          onPressed: () {
                            cubit.setSort(
                              state.sortBy == "ascending"
                                  ? "descending"
                                  : "ascending",
                            );
                          },
                          child: Row(
                            spacing: 8,
                            children: [
                              Icon(
                                state.sortBy == "ascending"
                                    ? Icons.arrow_upward_outlined
                                    : Icons.arrow_downward_outlined,
                                size: 20,
                                color: AppColors.textBlue,
                              ),
                              Text(
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
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
                                    Text("Offers"),
                                    selectedCatch.offers.isNotEmpty
                                        ? Container(
                                            margin: const EdgeInsets.only(
                                              left: 8,
                                            ),
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.textBlue,
                                            ),
                                            child: Text(
                                              "${selectedCatch.offers.length}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textWhite,
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                              Tab(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Messages"),
                                    selectedCatch.messages.isNotEmpty
                                        ? Container(
                                            margin: const EdgeInsets.only(
                                              left: 8,
                                            ),
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.textBlue,
                                            ),
                                            child: Text(
                                              "${selectedCatch.messages.length}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textWhite,
                                              ),
                                            ),
                                          )
                                        : Container(),
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
                                SingleChildScrollView(
                                  padding: EdgeInsets.only(
                                    bottom: 80,
                                    top: selectedCatch.offers.isEmpty ? 16 : 0,
                                  ),
                                  child: selectedCatch.offers.isEmpty
                                      ? Column(
                                          children: [
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
                                                color: AppColors.textGray,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const Text(
                                              "Buyers are reviewing your captures.",
                                              style: TextStyle(
                                                color: AppColors.textGray,
                                                fontWeight: FontWeight.w300,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: selectedCatch.offers.map((
                                            offer,
                                          ) {
                                            return FisherOfferCard(
                                              offer: offer,
                                              onPressed: () {
                                                context.push(
                                                  "/fisher/offer-details/${offer.offerId}",
                                                );
                                              },
                                            );
                                          }).toList(),
                                        ),
                                ),
                                // Messages Tab
                                SingleChildScrollView(
                                  padding: EdgeInsets.only(
                                    bottom: 80,
                                    top: selectedCatch.messages.isEmpty
                                        ? 16
                                        : 0,
                                  ),
                                  child: selectedCatch.messages.isEmpty
                                      ? Column(
                                          children: [
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
                                                fontWeight: FontWeight.bold,
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
                                          children: selectedCatch.messages.map((
                                            msg,
                                          ) {
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
          );
        },
      ),
    );
  }
}
