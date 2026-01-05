import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:siren_marketplace/core/widgets/error_dialog.dart';

Future<void> makePhoneCall(String phoneNumber, context) async {
  final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(launchUri)) {
    await launchUrl(launchUri);
  } else {
    showDialog(
      context: context,
      builder: (context) => const ErrorDialog(
        title: "Error",
        message: 'Could not launch phone app.',
      ),
    );
  }
}
