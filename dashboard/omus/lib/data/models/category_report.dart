/// Model for category report data from the chart config API.
class CategoryReport {
  final String title;
  final List<ReportItem> items;

  CategoryReport({
    required this.title,
    required this.items,
  });

  factory CategoryReport.fromJson(Map<String, dynamic> json) {
    return CategoryReport(
      title: json['title'] ?? '',
      items: (json['items'] as List<dynamic>)
          .map((item) => ReportItem.fromJson(item))
          .toList(),
    );
  }
}

/// Model for individual report item within a category.
class ReportItem {
  final String title;
  final String description;
  final String url;
  final String type;

  ReportItem({
    required this.title,
    required this.description,
    required this.url,
    required this.type,
  });

  factory ReportItem.fromJson(Map<String, dynamic> json) {
    return ReportItem(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? '',
    );
  }
}
