import 'package:flutter/material.dart';
import 'package:siren_marketplace/core/constants/app_colors.dart';
import 'package:siren_marketplace/core/models/info_row.dart';
import 'package:siren_marketplace/core/types/extensions.dart';

class InfoTable extends StatelessWidget {
  const InfoTable({super.key, required this.rows});

  /// Each row: label, value, optional editable
  final List<InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    final editable = rows.any((row) => row.editable);

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        0: const FlexColumnWidth(0.8),
        1: const FlexColumnWidth(1),
        2: FlexColumnWidth(editable ? 0.2 : 0.001), // 👈 never actually 0
      },
      border: TableBorder.all(style: BorderStyle.none),
      children: rows.map((row) {
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                row.label,
                style: const TextStyle(fontSize: 14, color: AppColors.textGray),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                "${row.value} ${row.suffix ?? ""}".capitalize(),
                maxLines: 2,
                softWrap: true,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A2A45),
                ),
              ),
            ),
            row.editable
                ? IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    splashRadius: 5,
                    icon: const Icon(
                      Icons.edit,
                      size: 14,
                      color: Color(0xFF0A2A45),
                    ),
                    onPressed: row.onEdit,
                  )
                : const SizedBox.shrink(), // 👈 fixed
          ],
        );
      }).toList(),
    );
  }
}
