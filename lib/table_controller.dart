import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'table_model.dart';

class TableController extends GetxController {
  var tables = <TableModel>[].obs;
  var nextId = 1;

  void updatePosition(int id, double x, double y, double currentWidth, double currentHeight) {
    final index = tables.indexWhere((t) => t.id == id);
    if (index != -1) {
      tables[index] = tables[index].copyWith(
        x: x,
        y: y,
        originalScreenWidth: currentWidth,
        originalScreenHeight: currentHeight,
      );
    }
  }

  void updateSize(int id, double width, double height) {
    final index = tables.indexWhere((t) => t.id == id);
    if (index != -1) {
      tables[index] = tables[index].copyWith(
        width: width,
        height: height,
      );
    }
  }

  void toggleTableShape(int id) {
    final index = tables.indexWhere((t) => t.id == id);
    if (index != -1) {
      tables[index] = tables[index].copyWith(
        isRound: !tables[index].isRound,
      );
    }
  }

  void updateTableName(int id, String newName) {
    final index = tables.indexWhere((t) => t.id == id);
    if (index != -1) {
      tables[index] = tables[index].copyWith(name: newName);
    }
  }

  void deleteTable(int id) {
    tables.removeWhere((table) => table.id == id);
  }

  void addTableToArea(String area, BuildContext context, double gridSize) {
    if (area == 'All Areas') area = 'Main Hall';

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height -
        AppBar().preferredSize.height -
        mediaQuery.padding.top;

    final initialX = (screenWidth * 0.2 / gridSize).round() * gridSize;
    final initialY = (screenHeight * 0.2 / gridSize).round() * gridSize;

    tables.add(TableModel(
      id: nextId++,
      x: initialX,
      y: initialY,
      area: area,
      originalScreenWidth: screenWidth,
      originalScreenHeight: screenHeight,
    ));
  }

  void loadInitialTables(BuildContext context, double gridSize) {
    if (tables.isNotEmpty) return;

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height -
        AppBar().preferredSize.height -
        mediaQuery.padding.top;

    tables.addAll([
      TableModel(
        id: nextId++,
        x: (screenWidth * 0.1 / gridSize).round() * gridSize,
        y: (screenHeight * 0.1 / gridSize).round() * gridSize,
        area: 'Main Hall',
        originalScreenWidth: screenWidth,
        originalScreenHeight: screenHeight,
        name: 'Window View',
      ),
      TableModel(
        id: nextId++,
        x: (screenWidth * 0.4 / gridSize).round() * gridSize,
        y: (screenHeight * 0.3 / gridSize).round() * gridSize,
        area: 'Main Hall',
        originalScreenWidth: screenWidth,
        originalScreenHeight: screenHeight,
        name: 'VIP Table',
      ),
      TableModel(
        id: nextId++,
        x: (screenWidth * 0.2 / gridSize).round() * gridSize,
        y: (screenHeight * 0.6 / gridSize).round() * gridSize,
        area: 'Garden',
        originalScreenWidth: screenWidth,
        originalScreenHeight: screenHeight,
      ),
    ]);
  }

  void editTable(BuildContext context, TableModel table) {
    final nameController = TextEditingController(text: table.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Table ${table.id}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Table Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    deleteTable(table.id);
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: Text('DELETE'),
                ),
                TextButton(
                  onPressed: () {
                    updateTableName(table.id, nameController.text);
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                  child: Text('SAVE'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}