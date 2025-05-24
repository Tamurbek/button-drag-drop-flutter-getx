class TableModel {
  final int id;
  final double x;
  final double y;
  final double width;
  final double height;
  final bool isRound;
  final String area;
  final double originalScreenWidth;
  final double originalScreenHeight;
  String name;

  TableModel({
    required this.id,
    required this.x,
    required this.y,
    this.width = 80,
    this.height = 80,
    this.isRound = false,
    required this.area,
    required this.originalScreenWidth,
    required this.originalScreenHeight,
    this.name = '',
  });

  TableModel copyWith({
    int? id,
    double? x,
    double? y,
    double? width,
    double? height,
    bool? isRound,
    String? area,
    double? originalScreenWidth,
    double? originalScreenHeight,
    String? name,
  }) {
    return TableModel(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      isRound: isRound ?? this.isRound,
      area: area ?? this.area,
      originalScreenWidth: originalScreenWidth ?? this.originalScreenWidth,
      originalScreenHeight: originalScreenHeight ?? this.originalScreenHeight,
      name: name ?? this.name,
    );
  }
}