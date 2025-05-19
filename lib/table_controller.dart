import 'package:get/get.dart';
import 'table_model.dart';
import 'package:flutter/foundation.dart'; // debugPrint uchun

class TableController extends GetxController {
  var tables = <TableModel>[].obs;

  void updatePosition(int id, double x, double y) {
    int index = tables.indexWhere((t) => t.id == id);
    if (index != -1) {
      tables[index].x = x;
      tables[index].y = y;
      tables.refresh();
    }
  }

  void loadInitialTables() {
    tables.value = [
      TableModel(id: 1, x: 50, y: 100),
      TableModel(id: 2, x: 180, y: 250),
      TableModel(id: 3, x: 100, y: 400),
    ];
  }
}