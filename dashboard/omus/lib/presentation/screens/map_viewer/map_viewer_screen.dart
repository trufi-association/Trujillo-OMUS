import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:omus/core/enums/feature_type.dart';
import 'package:omus/core/enums/gender.dart';
import 'package:omus/data/models/filter_request.dart';
import 'package:omus/data/models/map_data_container.dart';
import 'package:omus/domain/usecases/filter_reports_usecase.dart';
import 'package:omus/geojson_models.dart';
import 'package:omus/data/models/gtfs_models.dart';
import 'package:omus/core/utils/map_utils.dart';
import 'package:omus/presentation/widgets/common/general_app_bar.dart';
import 'package:omus/services/api_service.dart';
import 'package:omus/services/models/category.dart';
import 'package:omus/services/models/report.dart';
import 'package:omus/services/models/vial_actor.dart';
import 'package:omus/stations.dart';
import 'package:omus/widgets/components/fleaflet_map_controller.dart';
import 'package:omus/widgets/components/helpers/form_loading_helper_new.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

import 'widgets/base_map_layer.dart';
import 'widgets/map_layer_panel.dart';
import 'widgets/report_info_widget.dart';
import 'widgets/selected_map_layer.dart';
import 'widgets/station_info_widget.dart';

/// Main map viewer screen that displays the geographic viewer.
class MapViewerScreen extends StatefulWidget {
  const MapViewerScreen({super.key});

  @override
  MapViewerScreenState createState() => MapViewerScreenState();
}

class MapViewerScreenState extends State<MapViewerScreen> {
  double zoom = 13;
  Report? currentReport;
  Station? currentStation;
  final StreamController<void> _rebuildGenderStream = StreamController.broadcast();
  final StreamController<void> _rebuildGeneralStream = StreamController.broadcast();
  final LeafletMapController leafletMapController = LeafletMapController();
  final FilterReportsUsecase _filterReportsUsecase = FilterReportsUsecase();

  @override
  void dispose() {
    _rebuildGenderStream.close();
    _rebuildGeneralStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gtfsData = context.watch<Gtfs>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const GeneralAppBar(title: 'Visor geográfico'),
      ),
      body: SafeArea(
        child: FormRequestManager<Never, FilterRequest, MapDataContainer>(
          id: null,
          fromScratch: FilterRequest.fromScratch,
          loadModel: (_) => throw 'should not happen never loadModel',
          fromResponse: (_) => throw 'should not happen never loadModel',
          loadExtraModel: _loadMapData,
          saveModel: (_, {id}) async {},
          onSaveChanges: () {},
          builder: (params) {
            final helper = params.responseModel.responseHelper!;
            final model = params.model;
            final filteredReports = _filterReports(helper: helper, model: model);

            final genderMap = _buildGenderHeatMap(helper, model);
            final reportsFiltered = _buildReportsHeatMap(filteredReports);

            return Stack(
              children: [
                _buildMap(
                  gtfsData: gtfsData,
                  model: model,
                  helper: helper,
                  filteredReports: filteredReports,
                  genderMap: genderMap,
                  reportsFiltered: reportsFiltered,
                ),
                MapLayerPanel(
                  leafletMapController: leafletMapController,
                  model: model,
                  helper: helper,
                  onGenderUpdate: () => _rebuildGenderStream.add(null),
                  onGeneralUpdate: () => _rebuildGeneralStream.add(null),
                ),
                if (currentReport != null)
                  CurrentReportRender(
                    currentReport: currentReport!,
                    helper: helper,
                    onPressed: () => setState(() => currentReport = null),
                  ),
                if (currentStation != null)
                  StationInfoRender(
                    station: currentStation!,
                    onPressed: () => setState(() => currentStation = null),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<MapDataContainer> _loadMapData() async {
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
    allCategories
        .where((value) => value.parentId != null)
        .forEach((value) {
      categoriesMap[value.parentId]?.subcategories.add(value);
    });

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

    return MapDataContainer(
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
  }

  List<Report> _filterReports({
    required MapDataContainer helper,
    required FilterRequest model,
  }) {
    return _filterReportsUsecase(
      reports: helper.reports,
      allCategories: helper.allCategories,
      actors: helper.actors,
      selectedCategories: model.categories.value,
      selectedSubCategories: model.subCategories.value,
      selectedActors: model.actors.value,
      dateRange: model.dateRange.value,
    );
  }

  List<WeightedLatLng> _buildGenderHeatMap(
      MapDataContainer helper, FilterRequest model) {
    return helper.genderData
        .where((value) {
          final stopsFilter = model.heatMapFilter.value
                  ?.map((value) => GenderExtension.fromValue(value))
                  .toList() ??
              [];
          if (stopsFilter.isEmpty) return true;
          for (final stopFeature in stopsFilter) {
            if (stopFeature == Gender.men && value.isMen) return true;
            if (stopFeature == Gender.woman && !value.isMen) return true;
          }
          return false;
        })
        .map((value) => WeightedLatLng(value.latLng, 1))
        .toList();
  }

  List<WeightedLatLng> _buildReportsHeatMap(List<Report> filteredReports) {
    return filteredReports
        .where((report) => report.latitude != null && report.longitude != null)
        .map((report) =>
            WeightedLatLng(LatLng(report.latitude!, report.longitude!), 1))
        .toList();
  }

  Widget _buildMap({
    required Gtfs gtfsData,
    required FilterRequest model,
    required MapDataContainer helper,
    required List<Report> filteredReports,
    required List<WeightedLatLng> genderMap,
    required List<WeightedLatLng> reportsFiltered,
  }) {
    return FlutterMap(
      mapController: leafletMapController.mapController,
      options: MapOptions(
        initialCenter: const LatLng(-8.1120, -79.0280),
        initialZoom: zoom,
        onPositionChanged: (camera, _) {
          setState(() {
            zoom = camera.zoom ?? 13;
          });
        },
      ),
      children: [
        openStreetMapTileLayer,
        if (model.showHeatMap.value == true && genderMap.isNotEmpty)
          HeatMapLayer(
            heatMapDataSource: InMemoryHeatMapDataSource(data: genderMap),
            reset: _rebuildGenderStream.stream,
          ),
        if (model.showPTPU.value == true)
          _buildPTPULayer(helper.ptpuFeatures),
        if (model.showSITT.value == true)
          _buildSITTLayer(helper, model),
        if (model.showRegulated.value == true)
          _buildRegulatedLayer(helper, model),
        if (model.showRoutes.value == true) ...[
          if (model.showAllRoutes.value == true)
            BaseMapLayer(zoom: zoom, gtfsData: gtfsData),
          SelectedMapLayer(
            zoom: zoom,
            gtfsData: gtfsData,
            routeSelection: model.routesSelection.value ?? [],
          ),
        ],
        if (model.showStops.value == true)
          _buildStopsLayer(helper, model),
        if (model.showStations.value == true)
          _buildStationsLayer(helper),
        if (model.showReports.value == true)
          ..._buildReportsLayers(model, filteredReports, reportsFiltered),
      ],
    );
  }

  Widget _buildPTPULayer(List<List<List<LatLng>>> ptpuFeatures) {
    return PolygonLayer(
      polygons: ptpuFeatures.expand((polygon) {
        List<Polygon> polygonList = [];
        for (int i = 0; i < polygon.length; i++) {
          List<LatLng> ring = polygon[i];
          if (i == 0) {
            polygonList.add(Polygon(
              points: ring,
              borderColor: Colors.green,
              borderStrokeWidth: 2,
              color: Colors.green.withAlpha(50),
              isFilled: true,
            ));
          } else {
            polygonList.add(Polygon(
              points: ring,
              borderColor: Colors.green,
              borderStrokeWidth: 2,
              color: Colors.white.withAlpha(175),
              isFilled: true,
            ));
          }
        }
        return polygonList;
      }).toList(),
    );
  }

  Widget _buildSITTLayer(MapDataContainer helper, FilterRequest model) {
    return PolylineLayer(
      polylines: helper.sittRoutes.values.expand((route) {
        final selectedRegion = model.selectedSITT.value?[route.name];
        if (selectedRegion?.isEmpty ?? true) return <Polyline>[];
        return route.features
            .where((element) => selectedRegion!.contains(element.name))
            .map((feature) => Polyline(
                  points: feature.geometry
                      .map((loc) => LatLng(loc.latitude, loc.longitude))
                      .toList(),
                  strokeWidth: 4,
                  color: Colors.purple,
                ));
      }).toList(),
    );
  }

  Widget _buildRegulatedLayer(MapDataContainer helper, FilterRequest model) {
    return PolylineLayer(
      polylines: helper.regulatedRoutes.values.expand((route) {
        final selectedRegion = model.selectedRegulated.value?[route.name];
        if (selectedRegion?.isEmpty ?? true) return <Polyline>[];
        return route.features
            .where((element) => selectedRegion!.contains(element.name))
            .map((feature) => Polyline(
                  points: feature.geometry
                      .map((loc) => LatLng(loc.latitude, loc.longitude))
                      .toList(),
                  strokeWidth: 4,
                  color: const Color.fromARGB(255, 111, 4, 77),
                ));
      }).toList(),
    );
  }

  Widget _buildStopsLayer(MapDataContainer helper, FilterRequest model) {
    return MarkerLayer(
      markers: helper.stops.where((value) {
        final stopsFilter = model.stopsFilter.value
                ?.map((value) => FeatureTypeExtension.fromValue(value))
                .toList() ??
            [];
        if (stopsFilter.isEmpty) return true;
        for (final stopFeature in stopsFilter) {
          if (stopFeature == FeatureType.advertising && value.advertising == true) return true;
          if (stopFeature == FeatureType.bench && value.bench == true) return true;
          if (stopFeature == FeatureType.bicycleParking && value.bicycleParking == true) return true;
          if (stopFeature == FeatureType.bin && value.bin == true) return true;
          if (stopFeature == FeatureType.lit && value.lit == true) return true;
          if (stopFeature == FeatureType.ramp && value.ramp == true) return true;
          if (stopFeature == FeatureType.shelter && value.shelter == true) return true;
          if (stopFeature == FeatureType.level && value.level == true) return true;
          if (stopFeature == FeatureType.passengerInformationDisplaySpeechOutput &&
              value.passengerInformationDisplaySpeechOutput == true) {
            return true;
          }
          if (stopFeature == FeatureType.tactileWritingBrailleEs &&
              value.tactileWritingBrailleEs == true) return true;
          if (stopFeature == FeatureType.tactilePaving && value.tactilePaving == true) return true;
          if (stopFeature == FeatureType.departuresBoard && value.departuresBoard == true) return true;
        }
        return false;
      }).map((stop) {
        return Marker(
          width: 25,
          height: 25,
          point: LatLng(stop.coordinates.latitude, stop.coordinates.longitude),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(152, 195, 116, 1),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.white),
            ),
            child: const Icon(
              size: 20,
              Icons.directions_bus,
              color: Color.fromARGB(255, 41, 61, 43),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStationsLayer(MapDataContainer helper) {
    return MarkerLayer(
      markers: helper.stations.map((station) {
        return Marker(
          width: 25,
          height: 25,
          point: station.location,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  currentStation = station;
                  currentReport = null;
                });
              },
              child: StationStatus(station: station),
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildReportsLayers(
    FilterRequest model,
    List<Report> filteredReports,
    List<WeightedLatLng> reportsFiltered,
  ) {
    return [
      if (model.showHeatMapReports.value == true && reportsFiltered.isNotEmpty)
        HeatMapLayer(
          heatMapOptions: HeatMapOptions(layerOpacity: 1),
          heatMapDataSource: InMemoryHeatMapDataSource(data: reportsFiltered),
          reset: _rebuildGeneralStream.stream,
        ),
      if (model.showHeatMapReports.value != true)
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 45,
            size: const Size(30, 30),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(50),
            maxZoom: 15,
            markers: filteredReports.map((report) {
              return Marker(
                point: LatLng(report.latitude ?? 0, report.longitude ?? 0),
                alignment: Alignment.topCenter,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        currentReport = report;
                        currentStation = null;
                      });
                    },
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ),
              );
            }).toList(),
            builder: (context, markers) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blue,
                    border: Border.all(color: Colors.white),
                  ),
                  child: Center(
                    child: Text(
                      markers.length.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
    ];
  }
}
