import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_cubit.dart';
import 'package:siren_marketplace/bloc/cubits/catch_filter_cubit/catch_filter_state.dart';
import 'package:siren_marketplace/components/custom_button.dart';
import 'package:siren_marketplace/components/filter_button.dart';
import 'package:siren_marketplace/components/fisher_offer_card.dart';
import 'package:siren_marketplace/components/info_table.dart';
import 'package:siren_marketplace/components/message_card.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';
import 'package:siren_marketplace/data/catch_data.dart';

class CatchDetails extends StatefulWidget {
  const CatchDetails({super.key, required this.catchId});

  final String catchId;

  @override
  State<CatchDetails> createState() => _CatchDetailsState();
}

class _CatchDetailsState extends State<CatchDetails> {
  final List<Catch> catches = sampleCatches;
  late Catch selectedCatch = sampleCatches.firstWhere(
    (c) => c.catchId == widget.catchId,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(
          "Catch Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textBlue,
            fontSize: 24,
          ),
        ),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.more_vert))],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                GestureDetector(
                  onTap: () {
                    final providers = selectedCatch.images.map<ImageProvider>((
                      img,
                    ) {
                      if (img.startsWith("http")) {
                        return NetworkImage(img);
                      } else {
                        return AssetImage(img);
                      }
                    }).toList();

                    final multiImageProvider = MultiImageProvider(providers);
                    // Show image viewer
                    showImageViewerPager(
                      context,
                      multiImageProvider,
                      swipeDismissible: true,
                      immersive: true,
                      useSafeArea: true,
                      doubleTapZoomable: true,

                      backgroundColor: Colors.black.withValues(alpha: .4),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),

                    // round corners
                    child: Image.asset(
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
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.textBlue,
                        ),
                      ),
                      Text(
                        selectedCatch.datePosted.toFormattedDate(),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.gray650,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(color: AppColors.gray200),
            InfoTable(
              rows: [
                InfoRow(label: "Size", value: selectedCatch.size),
                InfoRow(
                  label: "Initial weight",
                  value: selectedCatch.initialWeight,
                ),
                InfoRow(
                  label: "Available weight",
                  value: selectedCatch.availableWeight,
                  editable: true,
                  onEdit: () {
                    /* edit logic */
                  },
                ),
                InfoRow(
                  label: "Price/Kg",
                  value: selectedCatch.pricePerKg,
                  editable: true,
                  onEdit: () {
                    /* edit logic */
                  },
                ),
                InfoRow(label: "Total", value: selectedCatch.total),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Filters",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textBlue,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      builder: (context) {
                        return BlocBuilder<CatchFilterCubit, CatchFilterState>(
                          builder: (context, state) {
                            final cubit = context.read<CatchFilterCubit>();

                            return Container(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: 32,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  const Text("Sort by:"),
                                  RadioGroup<String>(
                                    groupValue: state.sortBy,
                                    onChanged: (val) => cubit.setSort(val!),
                                    child: Column(
                                      children: [
                                        ListTile(
                                          onTap: () {
                                            cubit.setSort("ascending");
                                          },
                                          title: Text('Newest to oldest'),
                                          leading: Radio<String>(
                                            value: "ascending",
                                          ),
                                        ),
                                        ListTile(
                                          onTap: () {
                                            cubit.setSort("descending");
                                          },
                                          title: Text('Oldest to newest'),
                                          leading: Radio<String>(
                                            value: "descending",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                        child: Text(
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
                    );
                  },
                  icon: Icon(Icons.filter_alt_outlined),
                ),
              ],
            ),
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
                        tabs: [
                          Tab(text: "Offers"),
                          Tab(text: "Messages"),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            SingleChildScrollView(
                              padding: const EdgeInsets.only(
                                bottom: 80,
                                top: 16,
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
                                        Text(
                                          "No offers received yet.",
                                          style: TextStyle(
                                            color: AppColors.textGray,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
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

                            SingleChildScrollView(
                              padding: const EdgeInsets.only(
                                bottom: 80,
                                top: 16,
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
                                        Text(
                                          "You have no messages yet.",
                                          style: TextStyle(
                                            color: AppColors.textGray,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
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
                                          // format as needed
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
  }
}
