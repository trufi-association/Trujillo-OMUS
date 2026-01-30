import 'package:omus/data/models/map_data_container.dart';
import 'package:omus/services/models/report.dart';
import 'package:omus/stations.dart';

/// Enum representing the loading status of the map viewer.
enum MapViewerStatus { initial, loading, loaded, error }

/// State class for the map viewer.
class MapViewerState {
  final MapViewerStatus status;
  final MapDataContainer? data;
  final Report? selectedReport;
  final Station? selectedStation;
  final double zoom;
  final List<Report> filteredReports;
  final String? errorMessage;

  const MapViewerState({
    this.status = MapViewerStatus.initial,
    this.data,
    this.selectedReport,
    this.selectedStation,
    this.zoom = 13,
    this.filteredReports = const [],
    this.errorMessage,
  });

  MapViewerState copyWith({
    MapViewerStatus? status,
    MapDataContainer? data,
    Report? selectedReport,
    Station? selectedStation,
    double? zoom,
    List<Report>? filteredReports,
    String? errorMessage,
    bool clearSelectedReport = false,
    bool clearSelectedStation = false,
  }) {
    return MapViewerState(
      status: status ?? this.status,
      data: data ?? this.data,
      selectedReport:
          clearSelectedReport ? null : (selectedReport ?? this.selectedReport),
      selectedStation:
          clearSelectedStation ? null : (selectedStation ?? this.selectedStation),
      zoom: zoom ?? this.zoom,
      filteredReports: filteredReports ?? this.filteredReports,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => status == MapViewerStatus.loading;
  bool get isLoaded => status == MapViewerStatus.loaded;
  bool get hasError => status == MapViewerStatus.error;
}
