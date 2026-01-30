import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:omus/core/extensions/list_extensions.dart';
import 'package:omus/data/models/map_data_container.dart';
import 'package:omus/domain/usecases/filter_reports_usecase.dart';
import 'package:omus/geojson_models.dart';
import 'package:omus/services/api_service.dart';
import 'package:omus/services/models/category.dart';
import 'package:omus/services/models/report.dart';
import 'package:omus/services/models/vial_actor.dart';
import 'package:omus/stations.dart';

import 'map_viewer_event.dart';
import 'map_viewer_state.dart';

/// BLoC for managing map viewer state and logic.
class MapViewerBloc extends Bloc<MapViewerEvent, MapViewerState> {
  final FilterReportsUsecase _filterReportsUsecase;

  MapViewerBloc({FilterReportsUsecase? filterReportsUsecase})
      : _filterReportsUsecase = filterReportsUsecase ?? FilterReportsUsecase(),
        super(const MapViewerState()) {
    on<LoadMapData>(_onLoadMapData);
    on<SelectReport>(_onSelectReport);
    on<DeselectReport>(_onDeselectReport);
    on<SelectStation>(_onSelectStation);
    on<DeselectStation>(_onDeselectStation);
    on<UpdateZoom>(_onUpdateZoom);
    on<UpdateFilters>(_onUpdateFilters);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadMapData(
    LoadMapData event,
    Emitter<MapViewerState> emit,
  ) async {
    emit(state.copyWith(status: MapViewerStatus.loading));

    try {
      // Load data from API
      final response = await Future.wait([
        ApiServices.getAllCategories(),
        ApiServices.getAllActors(),
        ApiServices.getAllReports(),
      ]);

      final allCategories = response[0] as List<Category>;
      final categoriesMap = Map.fromEntries(
        allCategories
            .where((value) => value.parentId == null)
            .map((value) => MapEntry(value.id, value)),
      );

      // Add subcategories to parent categories
      for (var category in allCategories.where((value) => value.parentId != null)) {
        categoriesMap[category.parentId]?.subcategories.add(category);
      }

      // Load local assets
      final heatMapData =
          await rootBundle.loadString('assets/mapa_de_calor.geojson');
      final genderData =
          (jsonDecode(heatMapData)['features'] as List).map((feature) {
        final coords = feature['geometry']['coordinates'];
        final name =
            (feature['properties']['name']?.toString() ?? '').toLowerCase();
        final latlng = LatLng(coords[1], coords[0]);
        return GenderBoard(latLng: latlng, isMen: name.contains('hombre'));
      }).toList();

      final ptpuDataString =
          await rootBundle.loadString('assets/pnft_latlon_01156_2023.geojson');
      final ptpuFeatures =
          (jsonDecode(ptpuDataString)['features'] as List).expand((feature) {
        final coords = feature['geometry']['coordinates'] as List;
        return coords.map((polygon) {
          return (polygon as List).map((ring) {
            return (ring as List).map((point) {
              final lon = point[0];
              final lat = point[1];
              return LatLng(lat, lon);
            }).toList();
          }).toList();
        });
      }).toList();

      final stopsDataString =
          await rootBundle.loadString('assets/stops.geojson');
      final stops = (jsonDecode(stopsDataString)['features'] as List)
          .map((feature) => GeoFeature.fromJson(feature))
          .toList();

      final stationsDataString =
          await rootBundle.loadString('assets/merged_stations.json');
      final stations = (jsonDecode(stationsDataString) as List)
          .map((feature) => Station.fromJson(feature))
          .toList();

      final sittRoutesDataString =
          await rootBundle.loadString('assets/RutasDelSITT.json');
      final Map<String, dynamic> sittRoutesDecodedData =
          jsonDecode(sittRoutesDataString);
      final sittRoutes = sittRoutesDecodedData.map(
        (key, value) => MapEntry(key, Region.fromJson(value)),
      );

      final regulatedRoutesDataString =
          await rootBundle.loadString('assets/PlanReguladorDeRutas.json');
      final Map<String, dynamic> regulatedRoutesDecodedData =
          jsonDecode(regulatedRoutesDataString);
      final regulatedRoutes = regulatedRoutesDecodedData.map(
        (key, value) => MapEntry(key, Region.fromJson(value)),
      );

      final mapData = MapDataContainer(
        allCategories: allCategories,
        categories: categoriesMap,
        actors: response[1] as List<VialActor>,
        reports: response[2] as List<Report>,
        genderData: genderData,
        stops: stops,
        stations: stations,
        sittRoutes: sittRoutes,
        regulatedRoutes: regulatedRoutes,
        ptpuFeatures: ptpuFeatures,
      );

      // Initially show all reports
      final filteredReports = _filterReportsUsecase(
        reports: mapData.reports,
        allCategories: mapData.allCategories,
        actors: mapData.actors,
      );

      emit(state.copyWith(
        status: MapViewerStatus.loaded,
        data: mapData,
        filteredReports: filteredReports,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MapViewerStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSelectReport(
    SelectReport event,
    Emitter<MapViewerState> emit,
  ) {
    final report = state.data?.reports.findOrNull((r) => r.id == event.reportId);
    if (report != null) {
      emit(state.copyWith(
        selectedReport: report,
        clearSelectedStation: true,
      ));
    }
  }

  void _onDeselectReport(
    DeselectReport event,
    Emitter<MapViewerState> emit,
  ) {
    emit(state.copyWith(clearSelectedReport: true));
  }

  void _onSelectStation(
    SelectStation event,
    Emitter<MapViewerState> emit,
  ) {
    final station =
        state.data?.stations.findOrNull((s) => s.id == event.stationId);
    if (station != null) {
      emit(state.copyWith(
        selectedStation: station,
        clearSelectedReport: true,
      ));
    }
  }

  void _onDeselectStation(
    DeselectStation event,
    Emitter<MapViewerState> emit,
  ) {
    emit(state.copyWith(clearSelectedStation: true));
  }

  void _onUpdateZoom(
    UpdateZoom event,
    Emitter<MapViewerState> emit,
  ) {
    emit(state.copyWith(zoom: event.zoom));
  }

  void _onUpdateFilters(
    UpdateFilters event,
    Emitter<MapViewerState> emit,
  ) {
    if (state.data == null) return;

    final filteredReports = _filterReportsUsecase(
      reports: state.data!.reports,
      allCategories: state.data!.allCategories,
      actors: state.data!.actors,
      selectedCategories: event.categories,
      selectedSubCategories: event.subCategories,
      selectedActors: event.actors,
      dateRange: event.dateRange,
    );

    emit(state.copyWith(filteredReports: filteredReports));
  }

  void _onClearFilters(
    ClearFilters event,
    Emitter<MapViewerState> emit,
  ) {
    if (state.data == null) return;

    final filteredReports = _filterReportsUsecase(
      reports: state.data!.reports,
      allCategories: state.data!.allCategories,
      actors: state.data!.actors,
    );

    emit(state.copyWith(filteredReports: filteredReports));
  }
}
