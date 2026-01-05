import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/widgets/error_dialog.dart';

class ErrorDialogService {
  final GlobalKey<NavigatorState> navigatorKey;

  ErrorDialogService(this.navigatorKey);

  void showErrorDialog({
    String title = 'Error',
    required String message,
    VoidCallback? onRetry,
    String? retryText,
  }) {
    if (navigatorKey.currentState?.context == null) return;

    showDialog(
      context: navigatorKey.currentState!.context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        onRetry: onRetry,
        retryText: retryText,
      ),
    );
  }
}
