import 'package:flutter/material.dart';
import 'package:omus/services/models/category.dart';
import 'package:omus/services/models/report.dart';
import 'package:omus/services/models/vial_actor.dart';

/// Usecase for filtering reports based on categories, actors, and date range.
/// This consolidates the duplicated filterReports function from map_viewer and image_manager.
class FilterReportsUsecase {
  /// Filters reports based on the provided criteria.
  ///
  /// [reports] - List of all reports to filter
  /// [allCategories] - All available categories for fallback
  /// [actors] - All available actors for fallback
  /// [selectedCategories] - Selected category IDs (if empty, uses all)
  /// [selectedSubCategories] - Selected subcategory IDs
  /// [selectedActors] - Selected actor IDs (if empty, uses all)
  /// [dateRange] - Optional date range filter
  List<Report> call({
    required List<Report> reports,
    required List<Category> allCategories,
    required List<VialActor> actors,
    List<String>? selectedCategories,
    List<String>? selectedSubCategories,
    List<String>? selectedActors,
    DateTimeRange? dateRange,
  }) {
    // Combine categories and subcategories
    var categories = [
      ...(selectedCategories ?? []),
      ...(selectedSubCategories ?? []),
    ];

    // If no categories selected, use all
    if (categories.isEmpty) {
      categories = allCategories.map((value) => value.id.toString()).toList();
    }

    // If no actors selected, use all
    var actorIds = selectedActors ?? [];
    if (actorIds.isEmpty) {
      actorIds = actors.map((value) => value.id.toString()).toList();
    }

    return reports.where((report) {
      // Check category filter
      final hasCategory = categories.contains(report.categoryId.toString());

      // Check date range filter
      bool inDateRange = true;
      final reportDate = report.reportDate;
      if (dateRange != null) {
        if (reportDate != null) {
          inDateRange = reportDate.isAfter(dateRange.start) &&
              reportDate.isBefore(dateRange.end);
        } else {
          inDateRange = false;
        }
      }

      return hasCategory && inDateRange;
    }).toList();
  }
}
