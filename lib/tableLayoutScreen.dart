import 'package:drag_and_drop/table_controller.dart';
import 'package:drag_and_drop/table_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TableLayoutScreen extends StatelessWidget {
  final TableController controller = Get.put(TableController());

  @override
  Widget build(BuildContext context) {
    controller.loadInitialTables();

    return Scaffold(
      appBar: AppBar(title: Text("Restaurant Table Layout")),
      body: Obx(() {
        return Stack(
          children: controller.tables.map((table) {
            return Positioned(
              left: table.x,
              top: table.y,
              child: Draggable(
                feedback: Material(
                  color: Colors.transparent,
                  child: _buildTableWidget(table),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.5,
                  child: _buildTableWidget(table),
                ),
                onDragEnd: (details) {
                  final offset = details.offset;

                  final adjustedOffset = offset - Offset(
                    0,
                    AppBar().preferredSize.height + MediaQuery.of(context).padding.top,
                  );

                  controller.updatePosition(table.id, adjustedOffset.dx, adjustedOffset.dy);
                  debugPrint("Stol ${table.id}: x=${adjustedOffset.dx}, y=${adjustedOffset.dy}");
                },
                child: _buildTableWidget(table),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  /// Stol uchun dizayn - dragging bo'lsa rang o'zgaradi
  Widget _buildTableWidget(TableModel table) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.brown[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          "Table ${table.id}",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

}
