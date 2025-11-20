import 'package:intl/intl.dart';

extension DateFormatting on String {
  String toFormattedDate() {
    try {
      final date = DateTime.parse(this);
      return DateFormat("MMM d, yyyy - H:mm").format(date);
    } catch (_) {
      return this;
    }
  }

  String toShortFormattedDate() {
    try {
      final date = DateTime.parse(this);
      return DateFormat("MMM d, yyyy").format(date);
    } catch (_) {
      return this;
    }
  }
}

extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return '';
    return this[0].toUpperCase() + substring(1);
  }

  String capitalizeWords() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
}
