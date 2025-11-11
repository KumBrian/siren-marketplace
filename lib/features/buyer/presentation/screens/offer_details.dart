import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/data/repositories/user_repository.dart';
import 'package:siren_marketplace/core/di/injector.dart';
import 'package:siren_marketplace/core/models/catch.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/models/offer.dart';
import 'package:siren_marketplace/core/types/converters.dart';
import 'package:siren_marketplace/core/types/enum.dart';
import 'package:siren_marketplace/core/types/extensions.dart';
import 'package:siren_marketplace/core/utils/custom_icons.dart';
import 'package:siren_marketplace/core/widgets/custom_button.dart';
import 'package:siren_marketplace/core/widgets/info_table.dart';
import 'package:siren_marketplace/core/widgets/number_input_field.dart';
import 'package:siren_marketplace/core/widgets/offer_actions.dart';
import 'package:siren_marketplace/core/widgets/section_header.dart';
import 'package:siren_marketplace/features/fisher/data/catch_repository.dart';
import 'package:siren_marketplace/features/fisher/data/models/fisher.dart';
import 'package:siren_marketplace/features/fisher/logic/catch_bloc/catch_bloc.dart';
import 'package:siren_marketplace/features/fisher/logic/offers_bloc/offers_bloc.dart';
import 'package:siren_marketplace/features/user/logic/user_bloc/user_bloc.dart';

class PreviousOfferDetails {
  final double price;
  final double weight;
  final double pricePerKg;

  const PreviousOfferDetails({
    required this.price,
    required this.weight,
    required this.pricePerKg,
  });
}

class OfferTransactionData {
  final Fisher? fisher;
  final Catch? catchSnapshot;
  final PreviousOfferDetails? previousDetails;

  const OfferTransactionData({
    this.fisher,
    this.previousDetails,
    this.catchSnapshot,
  });
}

class BuyerOfferDetails extends StatefulWidget {
  const BuyerOfferDetails({super.key, required this.offerId});

  final String offerId;

  @override
  State<BuyerOfferDetails> createState() => _BuyerOfferDetailsState();
}

class _BuyerOfferDetailsState extends State<BuyerOfferDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Future<OfferTransactionData>? _transactionDataFuture;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _pricePerKgController = TextEditingController();
  final UserRepository _userRepository = sl<UserRepository>();
  bool _hasMarkedAsViewed = false;

  @override
  void initState() {
    super.initState();
    _dispatchGetOffer();
  }

  Future<OfferTransactionData> _loadTransactionData(Offer offer) async {
    final Map<String, dynamic>? fisherMap = await _userRepository
        .getUserMapById(offer.fisherId);

    Fisher? fisher;
    if (fisherMap != null) {
      fisher = Fisher.fromMap(fisherMap);
    }

    final Catch? catchSnapshot = await sl<CatchRepository>().getCatchById(
      offer.catchId,
    );

    PreviousOfferDetails? previousDetails;
    final hasPreviousNegotiation =
        offer.previousPrice != null &&
        offer.previousWeight != null &&
        offer.previousPricePerKg != null;

    if (hasPreviousNegotiation) {
      previousDetails = PreviousOfferDetails(
        price: offer.previousPrice!,
        weight: offer.previousWeight!,
        pricePerKg: offer.previousPricePerKg!,
      );
    }

    return OfferTransactionData(
      fisher: fisher,
      catchSnapshot: catchSnapshot,
      previousDetails: previousDetails,
    );
  }

  void _dispatchGetOffer() {
    if (widget.offerId.isEmpty) return;
    context.read<OffersBloc>().add(GetOfferById(widget.offerId));
  }

  void _markOfferAsViewed(Offer offer, Role role) {
    if (role == Role.buyer && offer.hasUpdateForBuyer && !_hasMarkedAsViewed) {
      context.read<OffersBloc>().add(MarkOfferAsViewed(offer, role));
      _hasMarkedAsViewed = true;
    }
  }

  void _showMakeOfferDialog(BuildContext context, Catch c) {
    _weightController.clear();
    _priceController.clear();
    _pricePerKgController.clear();

    final initialPricePerKg = c.pricePerKg;
    _pricePerKgController.text = initialPricePerKg.toStringAsFixed(2);

    bool userEditingTotal = false;

    void updateTotalFromWeight() {
      if (userEditingTotal) return;
      final weight = double.tryParse(_weightController.text);
      final pricePerKg = double.tryParse(_pricePerKgController.text);
      if (weight != null && pricePerKg != null) {
        final total = weight * pricePerKg;
        _priceController.text = total.toStringAsFixed(2);
      }
    }

    void updatePricePerKgFromTotal() {
      final weight = double.tryParse(_weightController.text);
      final total = double.tryParse(_priceController.text);
      if (weight != null && weight > 0 && total != null) {
        final pricePerKg = total / weight;
        _pricePerKgController.text = pricePerKg.toStringAsFixed(2);
      }
    }

    _weightController.addListener(() {
      updateTotalFromWeight();
    });

    _priceController.addListener(() {
      userEditingTotal = true;
      updatePricePerKgFromTotal();
      Future.delayed(const Duration(milliseconds: 200), () {
        userEditingTotal = false;
      });
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        contentPadding: const EdgeInsets.only(left: 32, right: 32, bottom: 32),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          minWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        title: Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                        controller: _weightController,
                        label: "Weight",
                        role: Role.buyer,
                        suffix: "Kg",
                        validator: (value) {
                          final weight = double.tryParse(value ?? "");
                          if (weight == null || weight <= 0) {
                            return "Enter valid weight";
                          }
                          if (weight > c.availableWeight) {
                            return "Cannot exceed available weight";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      NumberInputField(
                        controller: _priceController,
                        label: "Total Price",
                        suffix: "CFA",
                        validator: (value) {
                          final price = double.tryParse(value ?? "");
                          if (price == null || price <= 0) {
                            return "Enter valid price";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      NumberInputField(
                        controller: _pricePerKgController,
                        label: "Price/Kg",
                        suffix: "CFA",
                        validator: (value) {
                          final pricePerKg = double.tryParse(value ?? "");
                          if (pricePerKg == null || pricePerKg <= 0) {
                            return "Enter valid price per kg";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, userState) {
                    final user = userState is UserLoaded
                        ? userState.user
                        : null;
                    return CustomButton(
                      title: "Send Offer",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final weight = double.tryParse(
                            _weightController.text,
                          );
                          final totalPrice = double.tryParse(
                            _priceController.text,
                          );
                          final pricePerKg = double.tryParse(
                            _pricePerKgController.text,
                          );

                          if (weight != null &&
                              totalPrice != null &&
                              pricePerKg != null &&
                              user != null) {
                            context.read<OffersBloc>().add(
                              CreateOffer(
                                catchId: c.id,
                                buyerId: user.id,
                                fisherId: c.fisherId,
                                price: totalPrice,
                                weight: weight,
                                pricePerKg: pricePerKg,
                              ),
                            );
                            context.read<CatchesBloc>().add(LoadCatches());
                            context.pop();

                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (ctx) {
                                Future.delayed(const Duration(seconds: 2), () {
                                  if (ctx.mounted) Navigator.of(ctx).pop();
                                });

                                return AlertDialog(
                                  title: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.textBlue,
                                      border: Border.all(
                                        color: AppColors.textBlue,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: AppColors.textWhite,
                                    ),
                                  ),
                                  content: const Text(
                                    "Offer sent successfully!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: AppColors.textBlue,
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant BuyerOfferDetails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offerId != widget.offerId) {
      _transactionDataFuture = null;
      _dispatchGetOffer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        final Role? role = userState is UserLoaded ? userState.role : null;

        if (role == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return BlocConsumer<OffersBloc, OffersState>(
          listenWhen: (prev, curr) =>
              curr is OfferActionSuccess || curr is OfferActionFailure,
          listener: (context, offerState) {
            // Dismiss the loading dialog for ANY action completion (Success or Failure)
            if (offerState is OfferActionSuccess ||
                offerState is OfferActionFailure) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            }

            // Handle Accept success: Show final dialog and prepare navigation
            if (offerState is OfferActionSuccess) {
              if (offerState.action == 'Accept' &&
                  offerState.orderId != null &&
                  offerState.orderId!.isNotEmpty) {
                final orderId = offerState.orderId!;

                showActionSuccessDialog(
                  context,
                  message: "Offer Successfully Accepted.",
                  actionTitle: "View Details",
                  onAction: () {
                    context.pushReplacement("/fisher/order-details/$orderId");
                  },
                );
              }

              // Handle Reject/Counter success: Show dialog without navigation
              String message = '';
              if (offerState.action == 'Reject') {
                message = 'Offer Rejected!';
              } else if (offerState.action == 'Counter') {
                message = 'Counter-Offer Sent!';
              }

              if (message.isNotEmpty && offerState.action != 'Accept') {
                showActionSuccessDialog(
                  context,
                  message: message,
                  autoCloseSeconds: 3,
                );
              }
            }
          },
          builder: (context, offersState) {
            if (offersState is OffersLoading || offersState is OffersInitial) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final Offer? selectedOffer;

            if (offersState is OfferDetailsLoaded) {
              selectedOffer = offersState.offer;
            } else if (offersState is OfferActionSuccess) {
              selectedOffer = offersState.updatedOffer;
            } else {
              selectedOffer = null;
            }

            if (selectedOffer == null || selectedOffer.id != widget.offerId) {
              final errorMessage = offersState is OffersError
                  ? "Error loading offers: ${offersState.message}"
                  : "Offer with ID ${widget.offerId} not found or mismatch.";

              return Scaffold(
                appBar: AppBar(
                  leading: BackButton(onPressed: () => context.pop()),
                  title: const Text("Offer Details"),
                ),
                body: Center(child: Text(errorMessage)),
              );
            }

            final Offer currentOffer = selectedOffer;
            _markOfferAsViewed(currentOffer, role);

            if (_transactionDataFuture == null ||
                _transactionDataFuture!.hashCode != currentOffer.hashCode) {
              _transactionDataFuture = _loadTransactionData(currentOffer);
            }
            return FutureBuilder<OfferTransactionData>(
              key: ValueKey('${selectedOffer.id}-${selectedOffer.dateCreated}'),
              future: _loadTransactionData(selectedOffer),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final transactionData = asyncSnapshot.data;
                final Fisher? fisher = transactionData?.fisher;
                final Catch? catchSnapshot = transactionData?.catchSnapshot;
                final PreviousOfferDetails? previous =
                    transactionData?.previousDetails;
                return Scaffold(
                  appBar: AppBar(
                    leading: BackButton(onPressed: () => context.pop()),
                    title: const Text(
                      "Offer Details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlue,
                        fontSize: 24,
                      ),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BuyerOfferHeader(
                          offer: currentOffer,
                          catchName: currentOffer.catchName,
                          catchImage: currentOffer.catchImageUrl,
                        ),
                        const SizedBox(height: 16),

                        if (currentOffer.waitingFor == Role.buyer) ...[
                          const SectionHeader("Fisherman's Offer"),
                        ],

                        if (currentOffer.waitingFor == Role.fisher) ...[
                          const SectionHeader("Current Offer"),
                        ],

                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.gray200),
                          ),
                          child: InfoTable(
                            rows: [
                              InfoRow(
                                label: "Weight",
                                value:
                                    "${currentOffer.weight.toStringAsFixed(1)} Kg",
                              ),
                              InfoRow(
                                label: "Price Per Kg",
                                value:
                                    "${currentOffer.pricePerKg.toStringAsFixed(0)} CFA",
                              ),
                              InfoRow(
                                label: "Total",
                                value:
                                    "${currentOffer.price.toStringAsFixed(0)} CFA",
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        OfferActions(
                          offer: currentOffer,
                          formKey: _formKey,
                          currentUserRole: Role.buyer,
                          catchItem: catchSnapshot!,
                          onNavigateToOrder: (offerId) {
                            context.push("/buyer/order-details/$offerId");
                          },
                        ),
                        const SizedBox(height: 16),

                        if (previous != null) ...[
                          const SectionHeader("Last Counter-Offer"),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.gray200),
                            ),
                            child: InfoTable(
                              rows: [
                                InfoRow(
                                  label: "Weight",
                                  value:
                                      "${previous.weight.toStringAsFixed(1)} Kg",
                                ),
                                InfoRow(
                                  label: "Price",
                                  value: formatPrice(previous.price),
                                ),
                                InfoRow(
                                  label: "Price Per Kg",
                                  value: formatPrice(previous.pricePerKg),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        FisherDetails(fisher: fisher),
                        const SizedBox(height: 16),

                        if (currentOffer.status == OfferStatus.rejected) ...[
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              title: "Marketplace",
                              onPressed: () {},
                              icon: Icons.storefront,
                              bordered: true,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              title: "Make New Offer",
                              onPressed: () {},
                              // onPressed: () =>
                              //     _showMakeOfferDialog(context, catchSnapshot),
                            ),
                          ),
                        ],

                        if (currentOffer.status == OfferStatus.accepted ||
                            currentOffer.status == OfferStatus.pending) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              title: "Call Seller",
                              onPressed: () {},
                              hugeIcon: HugeIcons.strokeRoundedCall02,
                              bordered: true,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              title: "Message Seller",
                              onPressed: () {},
                              icon: CustomIcons.chatbubble,
                            ),
                          ),
                        ],

                        if (currentOffer.status == OfferStatus.completed) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              title: "Rate the fisher",
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                  ),
                                  builder: (context) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(
                                          context,
                                        ).viewInsets.bottom,
                                        left: 16,
                                        right: 16,
                                        top: 24,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                onPressed: context.pop,
                                                icon: const Icon(Icons.close),
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                "Give a Review",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                  color: AppColors.textBlue,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 24),
                                          Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: List.generate(5, (
                                                index,
                                              ) {
                                                return const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 4.0,
                                                  ),
                                                  child: Icon(
                                                    Icons.star,
                                                    size: 32,
                                                    color:
                                                        AppColors.shellOrange,
                                                  ),
                                                );
                                              }),
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          const TextField(
                                            maxLines: 4,
                                            decoration: InputDecoration(
                                              hintText: "Write a review...",
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(16),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            width: double.infinity,
                                            child: CustomButton(
                                              title: "Submit Review",
                                              onPressed: () {},
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class BuyerOfferHeader extends StatelessWidget {
  final Offer offer;
  final String catchName;
  final String catchImage;

  const BuyerOfferHeader({
    super.key,
    required this.offer,

    required this.catchName,
    required this.catchImage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            final provider =
                (catchImage.contains("http")
                        ? NetworkImage(catchImage)
                        : AssetImage(catchImage))
                    as ImageProvider;

            showImageViewer(
              context,
              provider,
              swipeDismissible: true,
              immersive: true,
              useSafeArea: true,
              doubleTapZoomable: true,
              backgroundColor: Colors.black.withValues(alpha: .4),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              catchImage,
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
            children: [
              Text(
                catchName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textBlue,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white),
                      color: AppColors.getStatusColor(offer.status),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    offer.status.name.capitalize(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.getStatusColor(offer.status),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FisherDetails extends StatelessWidget {
  final Fisher? fisher;

  const FisherDetails({super.key, required this.fisher});

  @override
  Widget build(BuildContext context) {
    final String avatarUrl =
        fisher?.avatarUrl ?? "assets/images/user-profile.png";
    final String name = fisher?.name ?? "";
    final double rating = fisher?.rating ?? 0.0;
    final int reviewCount = fisher?.reviewCount ?? 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: avatarUrl.contains("http")
              ? NetworkImage(avatarUrl)
              : AssetImage(avatarUrl),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
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
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.textBlue,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    " ($reviewCount Reviews)",
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
    );
  }
}
