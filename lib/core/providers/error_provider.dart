import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:siren_marketplace/core/providers/navigator_key_provider.dart';
import 'package:siren_marketplace/core/services/error_dialog_service.dart';

final errorDialogServiceProvider = Provider<ErrorDialogService>((ref) {
  final navigatorKey = ref.watch(navigatorKeyProvider);
  return ErrorDialogService(navigatorKey);
});
