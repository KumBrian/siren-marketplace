import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for notification settings (toggle)
/// Defaults to false
final notificationSettingsProvider = StateProvider<bool>((ref) => false);
