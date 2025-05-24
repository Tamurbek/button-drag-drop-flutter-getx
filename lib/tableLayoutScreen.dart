import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'table_controller.dart';
import 'table_model.dart';

class TableLayoutScreen extends StatelessWidget {
  final TableController controller = Get.put(TableController());
  final RxString selectedArea = 'Main Hall'.obs;
  final List<String> areas = ['Main Hall', 'Garden', 'Terrace', 'Private Room', 'All Areas'];
  final double gridSize = 20.0;

  @override
  Widget build(BuildContext context) {
    controller.loadInitialTables(context, gridSize);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Restaurant Table Layout"),
        actions: [
          Obx(() => DropdownButton<String>(
            value: selectedArea.value,
            icon: const Icon(Icons.arrow_drop_down),
            elevation: 16,
            style: const TextStyle(color: Colors.black87),
            underline: Container(height: 0),
            items: areas.map<DropdownMenuItem<String>>((String area) {
              return DropdownMenuItem<String>(
                value: area,
                child: Text(area),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                selectedArea.value = newValue;
              }
            },
          )),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add table',
            onPressed: () => controller.addTableToArea(selectedArea.value, context, gridSize),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Obx(() {
            final filteredTables = selectedArea.value == 'All Areas'
                ? controller.tables
                : controller.tables.where((table) => table.area == selectedArea.value).toList();

            return Stack(
              children: [
                CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _GridPainter(gridSize: gridSize),
                ),
                ...filteredTables.map((table) {
                  final gridX = (table.x / gridSize).round() * gridSize;
                  final gridY = (table.y / gridSize).round() * gridSize;

                  return Positioned(
                    left: gridX,
                    top: gridY,
                    child: GestureDetector(
                      onDoubleTap: () => controller.toggleTableShape(table.id),
                      onLongPress: () => controller.editTable(context, table),
                      child: Draggable(
                        feedback: Material(
                          color: Colors.transparent,
                          child: _buildTableWidget(table, showDelete: false, showResize: false),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: _buildTableWidget(table, showResize: false),
                        ),
                        onDragEnd: (details) {
                          final newX = details.offset.dx;
                          final newY = details.offset.dy -
                              (AppBar().preferredSize.height + MediaQuery.of(context).padding.top);

                          final gridNewX = (newX / gridSize).round() * gridSize;
                          final gridNewY = (newY / gridSize).round() * gridSize;

                          controller.updatePosition(
                            table.id,
                            gridNewX,
                            gridNewY,
                            constraints.maxWidth,
                            constraints.maxHeight,
                          );
                        },
                        child: _buildTableWidget(table),
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          });
        },
      ),
    );
  }

  Widget _buildTableWidget(TableModel table, {bool showDelete = true, bool showResize = true}) {
    return SizedBox(
      width: table.width,
      height: table.height,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: _getAreaColor(table.area),
              borderRadius: table.isRound
                  ? BorderRadius.circular(table.width / 2)
                  : BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(2, 3),
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      table.name.isNotEmpty ? table.name : "Table ${table.id}",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "(${table.area})",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ❌ Delete Button
          if (showDelete)
            Positioned(
              right: 4,
              top: 4,
              child: GestureDetector(
                onTap: () => controller.deleteTable(table.id),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.red[600],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      '×',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ↔️ Resize Button
          if (showResize)
            Positioned(
              right: 4,
              bottom: 4,
              child: GestureDetector(
                onPanUpdate: (details) {
                  final newWidth = (table.width + details.delta.dx).clamp(60.0, 300.0).toDouble();
                  final newHeight = (table.height + details.delta.dy).clamp(60.0, 300.0).toDouble();
                  controller.updateSize(table.id, newWidth, newHeight);
                },
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.open_with,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getAreaColor(String area) {
    switch (area) {
      case 'Main Hall': return Colors.blue[600]!;
      case 'Garden': return Colors.green[600]!;
      case 'Terrace': return Colors.orange[600]!;
      case 'Private Room': return Colors.purple[600]!;
      default: return Colors.grey[600]!;
    }
  }

}

class _GridPainter extends CustomPainter {
  final double gridSize;

  _GridPainter({required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.8;

    // Gorizontal chiziqlar
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertikal chiziqlar
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}