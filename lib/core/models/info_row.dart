import 'dart:ui';

class InfoRow {
  InfoRow({
    required this.label,
    required this.value,
    this.editable = false,
    this.onEdit,
    this.suffix,
  });

  final String label;
  final dynamic value;
  final bool editable;
  final String? suffix;
  final VoidCallback? onEdit;
}
