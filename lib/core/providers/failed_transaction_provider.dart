import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for tracking selected failed transaction reason
final failedTransactionProvider = StateProvider<String?>((ref) => null);
