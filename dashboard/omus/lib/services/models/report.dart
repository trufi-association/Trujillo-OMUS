class Report {
  final int id;
  final String? userId;
  final int categoryId;
  final DateTime? createDate;
  final DateTime? reportDate;
  final double? latitude;
  final double? longitude;
  final List<String>? images;
  final String? description;
  final int? involvedActorId;
  final int? victimActorId;

  Report({
    required this.id,
    this.userId,
    required this.categoryId,
    this.createDate,
    this.reportDate,
    this.latitude,
    this.longitude,
    this.images,
    this.description,
    this.involvedActorId,
    this.victimActorId,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      userId: json['userId'],
      categoryId: json['categoryId'],
      createDate: DateTime.tryParse(json['createDate'] ?? ""),
      reportDate: DateTime.tryParse(json['reportDate'] ?? ""),
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      images: (json['images'] as List?)?.map((e) => e as String).toList(),
      description: json['description'],
      involvedActorId: json['involvedActorId'],
      victimActorId: json['victimActorId'],
    );
  }
}
