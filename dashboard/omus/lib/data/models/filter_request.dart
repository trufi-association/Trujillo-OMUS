import 'package:flutter/material.dart';
import 'package:omus/widgets/components/textfield/form_request_field.dart';

/// Unified filter request model used across map_viewer, stats_viewer, and image_manager.
/// This replaces the duplicated ModelRequest classes.
class FilterRequest extends FormRequest {
  FilterRequest({
    required this.categories,
    required this.subCategories,
    required this.actors,
    required this.agenciesSelection,
    required this.routesSelection,
    required this.dateRange,
    required this.showRoutes,
    required this.showAllRoutes,
    required this.showHeatMap,
    required this.heatMapFilter,
    required this.showReports,
    required this.showHeatMapReports,
    required this.showStops,
    required this.showStations,
    required this.stopsFilter,
    required this.showSITT,
    required this.showRegulated,
    required this.selectedSITT,
    required this.selectedRegulated,
    required this.showPTPU,
  });

  factory FilterRequest.fromScratch() => FilterRequest(
        categories:
            FormItemContainer<List<String>>(fieldKey: "categories", value: []),
        subCategories:
            FormItemContainer<List<String>>(fieldKey: "subCategories", value: []),
        actors: FormItemContainer<List<String>>(fieldKey: "actors", value: []),
        agenciesSelection:
            FormItemContainer<List<String>>(fieldKey: "agenciesSelection", value: []),
        routesSelection:
            FormItemContainer<List<String>>(fieldKey: "routesSelection", value: []),
        dateRange: FormItemContainer<DateTimeRange>(fieldKey: "dateRange"),
        showRoutes:
            FormItemContainer<bool>(fieldKey: "showRoutes", value: false),
        showAllRoutes:
            FormItemContainer<bool>(fieldKey: "showAllRoutes", value: true),
        showHeatMap:
            FormItemContainer<bool>(fieldKey: "showHeatMap", value: false),
        heatMapFilter:
            FormItemContainer<List<String>>(fieldKey: "heatMapFilter", value: []),
        showReports:
            FormItemContainer<bool>(fieldKey: "showReports", value: true),
        showHeatMapReports:
            FormItemContainer<bool>(fieldKey: "showHeatMapReports", value: false),
        showStops: FormItemContainer<bool>(fieldKey: "showStops", value: true),
        showStations:
            FormItemContainer<bool>(fieldKey: "showStations", value: false),
        stopsFilter:
            FormItemContainer<List<String>>(fieldKey: "stopsFilter", value: []),
        showSITT: FormItemContainer<bool>(fieldKey: "showSITT", value: false),
        showRegulated:
            FormItemContainer<bool>(fieldKey: "showRegulated", value: false),
        selectedSITT: FormItemContainer<Map<String, List<String>>>(
            fieldKey: "selectedSITT", value: {}),
        selectedRegulated: FormItemContainer<Map<String, List<String>>>(
            fieldKey: "selectedRegulated", value: {}),
        showPTPU: FormItemContainer<bool>(fieldKey: "showPTPU", value: false),
      );

  final FormItemContainer<List<String>> categories;
  final FormItemContainer<List<String>> subCategories;
  final FormItemContainer<List<String>> actors;
  final FormItemContainer<List<String>> agenciesSelection;
  final FormItemContainer<List<String>> routesSelection;
  final FormItemContainer<DateTimeRange> dateRange;
  final FormItemContainer<bool> showRoutes;
  final FormItemContainer<bool> showAllRoutes;
  final FormItemContainer<bool> showHeatMap;
  final FormItemContainer<bool> showReports;
  final FormItemContainer<bool> showHeatMapReports;
  final FormItemContainer<List<String>> heatMapFilter;
  final FormItemContainer<bool> showStops;
  final FormItemContainer<bool> showStations;
  final FormItemContainer<List<String>> stopsFilter;
  final FormItemContainer<bool> showSITT;
  final FormItemContainer<bool> showRegulated;
  final FormItemContainer<bool> showPTPU;
  final FormItemContainer<Map<String, List<String>?>> selectedSITT;
  final FormItemContainer<Map<String, List<String>?>> selectedRegulated;

  /// Clears all filter values to their defaults
  void clearFilters() {
    update(() {
      categories.value = null;
      subCategories.value = null;
      actors.value = null;
      dateRange.value = null;
      showHeatMapReports.value = false;
    });
  }
}
