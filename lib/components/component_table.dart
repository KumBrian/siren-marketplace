import 'package:flutter/material.dart';
import 'package:siren_marketplace/constants/types.dart';

class ComponentTable extends StatelessWidget {
  const ComponentTable({super.key, required this.rows});

  /// Each row: firstItem and secondItem
  final List<ComponentRow> rows;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
      border: const TableBorder(
        horizontalInside: BorderSide(color: Colors.black12, width: 1),
      ),

      children: rows.map((row) {
        return TableRow(children: [row.firstItem, row.secondItem]);
      }).toList(),
    );
  }
}
