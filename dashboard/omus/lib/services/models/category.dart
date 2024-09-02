import 'dart:math';
import 'dart:ui';

class Category {
  final int id;
  final int? parentId;
  final String? categoryName;
  final bool hasVictim;
  final bool hasDateTime;
  final List<Category> subcategories = [];
  final Color color;

  Category({
    required this.id,
    this.parentId,
    this.categoryName,
    required this.hasVictim,
    required this.hasDateTime,
  }) : color = _generateRandomColor();

  static Color _generateRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(200) + 55,
      random.nextInt(200) + 55,
      random.nextInt(200) + 55,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      parentId: json['parentId'],
      categoryName: json['categoryName'],
      hasVictim: json['hasVictim'],
      hasDateTime: json['hasDateTime'],
    );
  }
}
