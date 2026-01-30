import 'package:flutter/material.dart';

/// Base class for map viewer events.
abstract class MapViewerEvent {}

/// Event to load initial map data.
class LoadMapData extends MapViewerEvent {}

/// Event to select a report on the map.
class SelectReport extends MapViewerEvent {
  final int reportId;
  SelectReport(this.reportId);
}

/// Event to deselect the current report.
class DeselectReport extends MapViewerEvent {}

/// Event to select a station on the map.
class SelectStation extends MapViewerEvent {
  final String stationId;
  SelectStation(this.stationId);
}

/// Event to deselect the current station.
class DeselectStation extends MapViewerEvent {}

/// Event to update the zoom level.
class UpdateZoom extends MapViewerEvent {
  final double zoom;
  UpdateZoom(this.zoom);
}

/// Event to update filter criteria.
class UpdateFilters extends MapViewerEvent {
  final List<String>? categories;
  final List<String>? subCategories;
  final List<String>? actors;
  final DateTimeRange? dateRange;

  UpdateFilters({
    this.categories,
    this.subCategories,
    this.actors,
    this.dateRange,
  });
}

/// Event to clear all filters.
class ClearFilters extends MapViewerEvent {}

/// Event to toggle a layer visibility.
class ToggleLayer extends MapViewerEvent {
  final String layerName;
  final bool isVisible;
  ToggleLayer(this.layerName, this.isVisible);
}
