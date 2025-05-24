import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'table_controller.dart';
import 'table_model.dart';

class TableLayoutScreen extends StatelessWidget {
  final TableController controller = Get.put(TableController());
  final RxString selectedArea = 'Main Hall'.obs;
  final List<String> areas = ['Main Hall', 'Garden', 'Terrace', 'Private Room', 'All Areas'];

  @override
  Widget build(BuildContext context) {
    controller.loadInitialTables(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Restaurant Table Layout"),
        actions: [
          Obx(() => DropdownButton<String>(
            value: selectedArea.value,
            icon: const Icon(Icons.arrow_drop_down),
            elevation: 16,
            style: const TextStyle(color: Colors.black),
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
            onPressed: () => controller.addTableToArea(selectedArea.value, context),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Obx(() {
            final filteredTables = selectedArea.value == 'All Areas'
                ? controller.tables
                : controller.tables.where((table) => table.area == selectedArea.value).toList();

            return Stack(
              children: filteredTables.map((table) {
                final currentWidth = constraints.maxWidth;
                final currentHeight = constraints.maxHeight;
                final x = table.x * currentWidth / table.originalScreenWidth;
                final y = table.y * currentHeight / table.originalScreenHeight;

                return Positioned(
                  left: x,
                  top: y,
                  child: GestureDetector(
                    onDoubleTap: () => controller.toggleTableShape(table.id),
                    onLongPress: () => controller.editTable(context, table),
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
                        final newX = details.offset.dx;
                        final newY = details.offset.dy -
                            (AppBar().preferredSize.height + MediaQuery.of(context).padding.top);

                        controller.updatePosition(
                          table.id,
                          newX,
                          newY,
                          currentWidth,
                          currentHeight,
                        );
                      },
                      child: _buildResizableTable(table),
                    ),
                  ),
                );
              }).toList(),
            );
          });
        },
      ),
    );
  }

  Widget _buildResizableTable(TableModel table) {
    return Obx(() {
      final tableData = controller.tables.firstWhere((t) => t.id == table.id);
      return ResizableWidget(
        width: tableData.width,
        height: tableData.height,
        onResized: (newSize) {
          controller.updateSize(table.id, newSize.width, newSize.height);
        },
        child: _buildTableWidget(tableData),
      );
    });
  }

  Widget _buildTableWidget(TableModel table) {
    return Container(
      width: table.width,
      height: table.height,
      decoration: BoxDecoration(
        color: _getAreaColor(table.area),
        borderRadius: table.isRound
            ? BorderRadius.circular(table.width / 2)
            : BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ), // <- shu yerda oldin xatolik bor edi
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                table.name.isNotEmpty ? table.name : "Table ${table.id}",
                textAlign: TextAlign.center,
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
    );
  }


  Color _getAreaColor(String area) {
    switch (area) {
      case 'Main Hall':
        return Colors.brown[400]!;
      case 'Garden':
        return Colors.green[600]!;
      case 'Terrace':
        return Colors.blue[500]!;
      case 'Private Room':
        return Colors.purple[500]!;
      default:
        return Colors.grey[500]!;
    }
  }
}

class ResizableWidget extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final Function(Size) onResized;

  const ResizableWidget({
    required this.child,
    required this.width,
    required this.height,
    required this.onResized,
  });

  @override
  _ResizableWidgetState createState() => _ResizableWidgetState();
}

class _ResizableWidgetState extends State<ResizableWidget> {
  late double width;
  late double height;

  @override
  void initState() {
    super.initState();
    width = widget.width;
    height = widget.height;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: width,
          height: height,
          child: widget.child,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                width = (width + details.delta.dx).clamp(60, 300);
                height = (height + details.delta.dy).clamp(60, 300);
              });
              widget.onResized(Size(width, height));
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}