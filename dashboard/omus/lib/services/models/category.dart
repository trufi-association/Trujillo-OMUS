class Category {
  final int id;
  final int? parentId;
  final String? categoryName;
  final bool hasVictim;
  final bool hasDateTime;

  Category({
    required this.id,
    this.parentId,
    this.categoryName,
    required this.hasVictim,
    required this.hasDateTime,
  });

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
