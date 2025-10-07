import 'package:flutter/material.dart';
import 'package:siren_marketplace/components/custom_button.dart';
import 'package:siren_marketplace/components/info_table.dart';
import 'package:siren_marketplace/components/section_header.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';
import 'package:siren_marketplace/data/catch_data.dart';

class BuyerCongratulationsScreen extends StatefulWidget {
  const BuyerCongratulationsScreen({super.key, required this.offerId});

  final String offerId;

  @override
  State<BuyerCongratulationsScreen> createState() =>
      _BuyerCongratulationsScreenState();
}

class _BuyerCongratulationsScreenState
    extends State<BuyerCongratulationsScreen> {
  final catches = sampleCatches;
  late final FisherOffer offer;
  late final Catch selectedCatch;

  @override
  void initState() {
    super.initState();
    offer = sampleCatches
        .expand((c) => c.offers)
        .firstWhere((offer) => offer.offerId == "o_c1_1");
    //find catch which has an offer with the offer id
    selectedCatch = catches.firstWhere(
      (c) => c.offers.any((offer) => offer.offerId == "o_c1_1"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text(
          "Congratulations!",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textBlue,
            fontSize: 24,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(selectedCatch.name),
            Divider(color: AppColors.gray200),
            InfoTable(
              rows: [
                InfoRow(label: "Weight", value: offer.weight, suffix: "Kg"),
                InfoRow(label: "Total", value: offer.price, suffix: "CFA"),
              ],
            ),

            SizedBox(height: 40),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: CustomButton(
                    title: "Message",
                    onPressed: () {},
                    icon: Icons.chat_bubble_outline_rounded,

                    bordered: true,
                  ),
                ),
                Expanded(
                  child: CustomButton(
                    title: "Call",
                    onPressed: () {},
                    icon: Icons.phone_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
