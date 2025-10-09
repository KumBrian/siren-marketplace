import 'package:flutter/material.dart';
import 'package:siren_marketplace/constants/constants.dart';
import 'package:siren_marketplace/constants/types.dart';

class InfoTable extends StatelessWidget {
  const InfoTable({super.key, required this.rows});

  /// Each row: label, value, optional editable
  final List<InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(0.7),
        2: FlexColumnWidth(0.3),
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
              child: SizedBox(
                width: 150,
                child: Text(
                  "${row.value.toString()} ${row.suffix ?? ""}".capitalize(),
                  maxLines: 2,
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2A45),
                  ),
                ),
              ),
            ),
            row.editable
                ? IconButton(
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    padding: EdgeInsets.zero,
                    splashRadius: 5,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.edit,
                      size: 14,
                      color: Color(0xFF0A2A45),
                    ),
                    onPressed: row.onEdit,
                  )
                : Container(),
          ],
        );
      }).toList(),
    );
  }
}
