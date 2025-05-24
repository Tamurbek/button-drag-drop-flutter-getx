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
            items: areas.map((String area) {
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
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => controller.addTableToArea(selectedArea.value, context),
          ),
          const SizedBox(width: 8),
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
    final borderRadius = table.isRound
        ? BorderRadius.circular(table.width / 2)
        : BorderRadius.circular(12);

    final boxShadow = [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 4,
        offset: const Offset(2, 2),
      ),
    ];

    return Container(
      width: table.width,
      height: table.height,
      decoration: BoxDecoration(
        color: _getAreaColor(table.area),
        borderRadius: borderRadius,
        boxShadow: boxShadow,
      ),
      child: Center(
        child: Text(
          "Table ${table.id}\n(${table.area})",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.bold,
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
        return Colors.green[400]!;
      case 'Terrace':
        return Colors.blue[400]!;
      case 'Private Room':
        return Colors.purple[400]!;
      default:
        return Colors.grey[400]!;
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
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}