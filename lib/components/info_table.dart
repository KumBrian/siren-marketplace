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
      columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
      border: const TableBorder(
        horizontalInside: BorderSide(color: Colors.black12, width: 1),
      ),
      children: rows.map((row) {
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                row.label,
                style: const TextStyle(fontSize: 14, color: AppColors.textGray),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 130,
                    child: Text(
                      "${row.value.toString()} ${row.suffix ?? ""}"
                          .capitalize(),
                      maxLines: 2,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A2A45),
                      ),
                    ),
                  ),
                  if (row.editable)
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 14,
                        color: Color(0xFF0A2A45),
                      ),
                      onPressed: row.onEdit,
                    ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
