import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for managing bottom navigation bar index
/// Default index is 1 (Home screen for both buyer and fisher)
final bottomNavIndexProvider = StateProvider<int>((ref) => 1);
