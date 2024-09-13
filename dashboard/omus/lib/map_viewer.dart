import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:go_router/go_router.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:latlong2/latlong.dart';
import 'package:omus/env.dart';
import 'package:omus/logo.dart';
import 'package:omus/main.dart';
import 'package:omus/services/api_service.dart';
import 'package:omus/services/models/category.dart';
import 'package:omus/services/models/report.dart';
import 'package:omus/services/models/vial_actor.dart';
import 'package:omus/stats_viewer.dart';
import 'package:omus/widgets/components/checkbox/custom_checkbox.dart';
import 'package:omus/widgets/components/dropdown/helpers/dropdown_item.dart';
import 'package:omus/widgets/components/dropdown/multi_select_dropdown.dart';
import 'package:omus/widgets/components/fleaflet_map_controller.dart';
import 'package:omus/widgets/components/helpers/form_loading_helper_new.dart';
import 'package:omus/widgets/components/textfield/form_request_date_range_field.dart';
import 'package:omus/widgets/components/textfield/form_request_field.dart';
import 'package:omus/widgets/components/toggle_switch/custom_toggle_switch.dart';
import 'package:omus/widgets/components/zoom_map_button.dart';
import 'gtfs_service.dart';
import 'package:provider/provider.dart';
import 'gtfs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';

class ModelRequest extends FormRequest {
  ModelRequest({
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
    required this.stopsFilter,
  });

  factory ModelRequest.fromScratch() => ModelRequest(
        categories: FormItemContainer<List<String>>(fieldKey: "categories", value: []),
        subCategories: FormItemContainer<List<String>>(fieldKey: "categories", value: []),
        actors: FormItemContainer<List<String>>(fieldKey: "actors", value: []),
        agenciesSelection: FormItemContainer<List<String>>(fieldKey: "ac", value: []),
        routesSelection: FormItemContainer<List<String>>(fieldKey: "ac", value: []),
        dateRange: FormItemContainer<DateTimeRange>(
          fieldKey: "keyStartDate",
        ),
        showRoutes: FormItemContainer<bool>(fieldKey: "keyShowAllRoutes", value: false),
        showAllRoutes: FormItemContainer<bool>(fieldKey: "keyShowAllRoutes", value: true),
        showHeatMap: FormItemContainer<bool>(fieldKey: "keyShowHeatMap", value: false),
        heatMapFilter: FormItemContainer<List<String>>(fieldKey: "categories", value: []),
        showReports: FormItemContainer<bool>(fieldKey: "keyShowHeatMap", value: true),
        showHeatMapReports: FormItemContainer<bool>(fieldKey: "keyShowHeatMap", value: false),
        showStops: FormItemContainer<bool>(fieldKey: "keyShowHeatMap", value: true),
        stopsFilter: FormItemContainer<List<String>>(fieldKey: "categories", value: []),
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
  final FormItemContainer<List<String>> stopsFilter;
}

class ServerOriginal {
  final Map<int, Category> categories;
  final List<Category> allCategories;
  final List<VialActor> actors;
  final List<Report> reports;
  final List<GenderBoard> data;
  final List<GeoFeature> stops;
  ServerOriginal({
    required this.categories,
    required this.allCategories,
    required this.actors,
    required this.reports,
    required this.data,
    required this.stops,
  });
}

enum FeatureType {
  advertising,
  bench,
  bicycleParking,
  bin,
  lit,
  ramp,
  shelter,
  level,
  passengerInformationDisplaySpeechOutput,
  tactileWritingBrailleEs,
  tactilePaving,
  departuresBoard,
}

extension FeatureTypeExtension on FeatureType {
  static const Map<FeatureType, String> _featureTypeMap = {
    FeatureType.advertising: 'advertising',
    FeatureType.bench: 'bench',
    FeatureType.bicycleParking: 'bicycleParking',
    FeatureType.bin: 'bin',
    FeatureType.lit: 'lit',
    FeatureType.ramp: 'ramp',
    FeatureType.shelter: 'shelter',
    FeatureType.level: 'level',
    FeatureType.passengerInformationDisplaySpeechOutput: 'passenger_information_display:speech_output',
    FeatureType.tactileWritingBrailleEs: 'tactile_writing:braille:es',
    FeatureType.tactilePaving: 'tactile_paving',
    FeatureType.departuresBoard: 'departures_board',
  };

  String toValue() => _featureTypeMap[this]!;

  static FeatureType fromValue(String value) => _featureTypeMap.entries.firstWhere((entry) => entry.value == value).key;

  static const Map<FeatureType, String> _featureTypeSpanishMap = {
    FeatureType.advertising: 'Publicidad',
    FeatureType.bench: 'Banco',
    FeatureType.bicycleParking: 'Estacionamiento para bicicletas',
    FeatureType.bin: 'Papelera',
    FeatureType.lit: 'Iluminado',
    FeatureType.ramp: 'Rampa',
    FeatureType.shelter: 'Refugio',
    FeatureType.level: 'Nivel',
    FeatureType.passengerInformationDisplaySpeechOutput: 'Pantalla de información al pasajero: salida de voz',
    FeatureType.tactileWritingBrailleEs: 'Escritura táctil: Braille (es)',
    FeatureType.tactilePaving: 'Pavimento táctil',
    FeatureType.departuresBoard: 'Tablero de salidas',
  };

  String toText() => _featureTypeSpanishMap[this]!;
}

enum Gender {
  men,
  woman,
}

extension GenderExtension on Gender {
  static const Map<String, Gender> _valueMap = {
    'hombre': Gender.men,
    'mujer': Gender.woman,
  };

  static Gender fromValue(String value) => _valueMap[value.toLowerCase()]!;
  String toValue() => _valueMap.entries.firstWhere((entry) => entry.value == this).key;
}

class GenderBoard {
  final LatLng latLng;
  final bool isMen;

  GenderBoard({required this.latLng, required this.isMen});
}

class MainMap extends StatefulWidget {
  const MainMap({super.key});

  @override
  MainMapState createState() => MainMapState();
}

List<Report> filterReports({required ServerOriginal helper, required ModelRequest model}) {
  var categories = [
    ...(model.categories.value ?? []),
    ...(model.subCategories.value ?? []),
  ];
  if (categories.isEmpty) {
    categories = helper.allCategories.map((value) => value.id.toString()).toList();
  }
  var actors = model.actors.value ?? [];
  if (actors.isEmpty) {
    actors = helper.actors.map((value) => value.id.toString()).toList();
  }
  DateTimeRange? dateRange = model.dateRange.value;
  return helper.reports.where((value) {
    final hasCategory = categories.contains(value.categoryId.toString());
    final hasActor = actors.contains(value.involvedActorId.toString());
    bool inDateRange = true;
    final reportDate = value.reportDate;
    if (dateRange != null) {
      if (reportDate != null) {
        inDateRange = reportDate.isAfter(dateRange.start) && reportDate.isBefore(dateRange.end);
      } else {
        inDateRange = false;
      }
    }

    return hasCategory && hasActor && inDateRange;
  }).toList();
}

class MainMapState extends State<MainMap> {
  double zoom = 13;
  Report? currentReport;
  bool showStats = false;
  StreamController<void> _rebuildGenderStream = StreamController.broadcast();
  StreamController<void> _rebuildGeneralStream = StreamController.broadcast();

  LeafletMapController leafletMapController = LeafletMapController();

  @override
  dispose() {
    _rebuildGenderStream.close();
    _rebuildGeneralStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gtfsData = context.watch<Gtfs>();
    return Scaffold(
      body: SafeArea(
        child: FormRequestManager<Never, ModelRequest, ServerOriginal>(
            id: null,
            fromScratch: ModelRequest.fromScratch,
            loadModel: (_) => throw "should not happen never loadModel",
            fromResponse: (_) => throw "should not happen never loadModel",
            loadExtraModel: () async {
              final response = await Future.wait([
                ApiServices.getAllCategories(),
                ApiServices.getAllActors(),
                ApiServices.getAllReports(),
              ]);
              final allCategories = response[0] as List<Category>;
              final categoriesMap = Map.fromEntries(
                allCategories.where((value) => value.parentId == null).map((value) => MapEntry(value.id, value)),
              );
              allCategories.where((value) => value.parentId != null).forEach((value) {
                categoriesMap[value.parentId]?.subcategories.add(value);
              });
              var heatMapData = await rootBundle.loadString('assets/mapa_de_calor.geojson');

              final data = (jsonDecode(heatMapData)['features'] as List).map((feature) {
                final coords = feature['geometry']['coordinates'];
                final name = (feature['properties']['name']?.toString() ?? "").toLowerCase();
                final latlng = LatLng(coords[1], coords[0]);
                return GenderBoard(latLng: latlng, isMen: name.contains("hombre"));
              }).toList();
              var stopsData = await rootBundle.loadString('assets/stops.geojson');
              final stops = (jsonDecode(stopsData)['features'] as List).map((feature) => GeoFeature.fromJson(feature)).toList();

              return ServerOriginal(
                allCategories: allCategories,
                categories: categoriesMap,
                actors: response[1] as List<VialActor>,
                reports: response[2] as List<Report>,
                data: data,
                stops: stops,
              );
            },
            saveModel: (_, {id}) async => {},
            onSaveChanges: () => {},
            builder: (params) {
              final helper = params.responseModel.responseHelper!;
              final model = params.model;
              final filteredReports = filterReports(helper: helper, model: model);

              final List<WeightedLatLng> genderMap = helper.data
                  .where((value) {
                    final stopsFilter = model.heatMapFilter.value?.map((value) => GenderExtension.fromValue(value)).toList() ?? [];
                    if (stopsFilter.isEmpty) return true;
                    for (final stopFeature in stopsFilter) {
                      if (stopFeature == Gender.men && value.isMen) return true;
                      if (stopFeature == Gender.woman && !value.isMen) return true;
                    }

                    return false;
                  })
                  .map(
                    (value) => WeightedLatLng(value.latLng, 1),
                  )
                  .toList();
              final List<WeightedLatLng> reportsFiltered = filteredReports
                  .where((report) => report.latitude != null && report.longitude != null)
                  .map((report) => WeightedLatLng(LatLng(report.latitude!, report.longitude!), 1))
                  .toList();

              return Stack(
                children: [
                  FlutterMap(
                    mapController: leafletMapController.mapController,
                    options: MapOptions(
                        initialCenter: const LatLng(-8.1120, -79.0280),
                        initialZoom: zoom,
                        onPositionChanged: (camera, _) {
                          setState(() {
                            zoom = camera.zoom ?? 13;
                          });
                        }),
                    children: [
                      openStreetMapTileLayer,
                      if (model.showHeatMap.value == true && genderMap.isNotEmpty)
                        HeatMapLayer(
                          heatMapDataSource: InMemoryHeatMapDataSource(
                            data: genderMap,
                          ),
                          reset: _rebuildGenderStream.stream,
                        ),
                      if (model.showRoutes.value == true) ...[
                        if (model.showAllRoutes.value == true)
                          BaseMapLayer(
                            zoom: zoom,
                            gtfsData: gtfsData,
                          ),
                        SelectedMapLayer(
                          zoom: zoom,
                          gtfsData: gtfsData,
                          routeSelection: model.routesSelection.value ?? [],
                        ),
                      ],
                      if (model.showStops.value == true)
                        MarkerLayer(
                          markers: helper.stops.where((value) {
                            final stopsFilter = model.stopsFilter.value?.map((value) => FeatureTypeExtension.fromValue(value)).toList() ?? [];
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
                              if (stopFeature == FeatureType.passengerInformationDisplaySpeechOutput && value.passengerInformationDisplaySpeechOutput == true) {
                                return true;
                              }
                              if (stopFeature == FeatureType.tactileWritingBrailleEs && value.tactileWritingBrailleEs == true) return true;
                              if (stopFeature == FeatureType.tactilePaving && value.tactilePaving == true) return true;
                              if (stopFeature == FeatureType.departuresBoard && value.departuresBoard == true) return true;
                            }

                            return false;
                          }).map((stop) {
                            return Marker(
                              width: 25,
                              height: 25,
                              point: stop.coordinates,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: const Color.fromRGBO(152, 195, 116, 1),
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(color: Colors.white)),
                                child: Icon(
                                  size: 20,
                                  Icons.directions_bus,
                                  color: Color.fromARGB(255, 41, 61, 43),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      if (model.showReports.value == true) ...[
                        if (model.showHeatMapReports.value == true && reportsFiltered.isNotEmpty)
                          HeatMapLayer(
                            heatMapOptions: HeatMapOptions(layerOpacity: 1),
                            heatMapDataSource: InMemoryHeatMapDataSource(
                              data: reportsFiltered,
                            ),
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
                                  // width: 80.0,
                                  // height: 80.0,
                                  point: LatLng(report.latitude ?? 0, report.longitude ?? 0),
                                  alignment: Alignment.topCenter,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          currentReport = report;
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
                                    decoration:
                                        BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.blue, border: Border.all(color: Colors.white)),
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
                      ],
                    ],
                  ),
                  // ReportBarChart(
                  //   reports: helper.reports,
                  //   categories: helper.categories,
                  // ),

                  MapLayer(
                    leafletMapController: leafletMapController,
                    model: model,
                    helper: helper,
                    onGenderUpdate: () {
                      _rebuildGenderStream.add(null);
                    },
                    onGeneralUpdate: () {
                      _rebuildGeneralStream.add(null);
                    },
                    onShowStats: () {
                      setState(() {
                        showStats = true;
                      });
                    },
                  ),
                  if (currentReport != null)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 300, maxWidth: 1000),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (currentReport?.images?.length == 1)
                                Flexible(
                                  flex: 1,
                                  child: InstaImageViewer(
                                    child: CachedNetworkImage(
                                      fit: BoxFit.contain,
                                      imageUrl: '$apiUrl/Categories/proxy?url=${Uri.encodeComponent(currentReport?.images?.first ?? "")}',
                                      placeholder: (context, url) => const SizedBox(width: 100, child: Center(child: CircularProgressIndicator())),
                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              Flexible(
                                flex: 2,
                                child: Stack(
                                  children: [
                                    ListView(
                                      shrinkWrap: true,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Report ID: ${currentReport!.id}',
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                'Category: ${helper.allCategories.findOrNull((value) => value.id == currentReport!.categoryId)?.categoryName ?? "-"}',
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                              const SizedBox(height: 4.0),
                                              Text(
                                                'Actor: ${helper.actors.findOrNull((value) => value.id == currentReport!.involvedActorId)?.name ?? "-"}',
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                              const SizedBox(height: 4.0),
                                              Text(
                                                'Description: ${currentReport!.description}',
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                              const SizedBox(height: 4.0),
                                              Text(
                                                'Date: ${currentReport!.reportDate?.toLocal()}'.split('-')[0],
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            currentReport = null;
                                          });
                                        },
                                        icon: const Icon(Icons.close),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  if (showStats)
                    ReportPieChart(
                      reports: helper.reports,
                      categories: helper.categories,
                      onClose: () {
                        setState(() {
                          showStats = false;
                        });
                      },
                    ),
                ],
              );
            }),
      ),
    );
  }
}

class MapLayer extends StatefulWidget {
  const MapLayer({
    super.key,
    required this.leafletMapController,
    required this.model,
    required this.helper,
    required this.onGenderUpdate,
    required this.onGeneralUpdate,
    required this.onShowStats,
  });

  final LeafletMapController leafletMapController;
  final ModelRequest model;
  final ServerOriginal helper;
  final void Function() onGenderUpdate;
  final void Function() onGeneralUpdate;
  final void Function() onShowStats;

  @override
  State<MapLayer> createState() => _MapLayerState();
}

enum ShowMapLayer { routes }

class _MapLayerState extends State<MapLayer> {
  ShowMapLayer? showMapLayer = ShowMapLayer.routes;
  Uint8List bytes = base64Decode(logo);
  @override
  Widget build(BuildContext context) {
    final gtfsData = context.watch<Gtfs>();
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(5),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisSize: MainAxisSize.min,
              children: [
                ZoomInOutMapButton(
                  leafletMapController: widget.leafletMapController,
                ),
                Container(
                  height: 5,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            if (showMapLayer != ShowMapLayer.routes) {
                              showMapLayer = ShowMapLayer.routes;
                            } else {
                              showMapLayer = null;
                            }
                          });
                        },
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: Icon(
                            Icons.layers,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          widget.onShowStats();
                        },
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: Icon(
                            Icons.query_stats,
                            color: Color.fromARGB(255, 255, 130, 159),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (showMapLayer == ShowMapLayer.routes)
            Container(
              width: 350,
              // height: 500,
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white, // Color de fondo blanco
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ), // Bordes redondeados
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // Color de sombra con opacidad
                    spreadRadius: 5, // Extensión de la sombra
                    blurRadius: 10, // Difuminado de la sombra
                    offset: Offset(0, 3), // Desplazamiento de la sombra (x, y)
                  ),
                ],
              ),

              child: ListView(
                children: [
                  Container(
                    margin: EdgeInsets.all(5),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                            onTap: () {
                              context.go("/");
                            },
                            child: Image.memory(bytes)),
                        Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Reportes",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            FormRequestToggleSwitch(
                              update: widget.model.update,

                              // label: "Option Sample",
                              field: widget.model.showReports,
                              enabled: true,
                              onChanged: (_) {
                                widget.onGeneralUpdate();
                              },
                            ),
                          ],
                        ),
                        if (widget.model.showReports.value == true)
                          Container(
                            margin: EdgeInsets.all(5),
                            child: Column(
                              children: [
                                FormRequestMultiSelectField(
                                  update: widget.model.update,
                                  field: widget.model.categories,
                                  label: "Categorias",
                                  items: widget.helper.categories.values
                                      .map(
                                        (e) => DropdownItem(
                                          id: e.id.toString(),
                                          text: e.categoryName.toString(),
                                        ),
                                      )
                                      .toList(),
                                  enabled: true,
                                  onChanged: (items) {
                                    final categoryChanged = widget.helper.categories.values
                                        .where((value) => items.contains(value.id.toString()))
                                        .expand((category) => category.subcategories)
                                        .toList();
                                    final currentFilter = widget.model.subCategories.value ?? [];
                                    final currentSubCategories =
                                        widget.helper.allCategories.where((value) => currentFilter.contains(value.id.toString())).toList();
                                    final newSubCategoryList = currentSubCategories
                                        .where((value) => categoryChanged.contains(value))
                                        .map(
                                          (value) => value.id.toString(),
                                        )
                                        .toList();
                                    widget.model.update(() {
                                      widget.model.subCategories.value = newSubCategoryList;
                                    });
                                    widget.onGeneralUpdate();
                                  },
                                ),
                                FormRequestMultiSelectField(
                                  update: widget.model.update,
                                  field: widget.model.subCategories,
                                  label: "Sub-Categorias",
                                  items: widget.helper.allCategories
                                      .where((value) {
                                        return widget.model.categories.value?.contains(value.parentId.toString()) ?? false;
                                      })
                                      .toList()
                                      .map(
                                        (e) => DropdownItem(
                                          id: e.id.toString(),
                                          text: e.categoryName.toString(),
                                        ),
                                      )
                                      .toList(),
                                  enabled: true,
                                  onChanged: (_) {
                                    widget.onGeneralUpdate();
                                  },
                                ),
                                FormRequestMultiSelectField(
                                  update: widget.model.update,
                                  field: widget.model.actors,
                                  label: "Actores viales",
                                  items: widget.helper.actors
                                      .map(
                                        (e) => DropdownItem(
                                          id: e.id.toString(),
                                          text: e.name.toString(),
                                        ),
                                      )
                                      .toList(),
                                  enabled: true,
                                  onChanged: (_) {
                                    widget.onGeneralUpdate();
                                  },
                                ),
                                FormDateRangePickerField(
                                  update: widget.model.update,
                                  label: "Rango de fechas",
                                  field: widget.model.dateRange,
                                  enabled: true,
                                  onChanged: (_) {
                                    widget.onGeneralUpdate();
                                  },
                                ),
                                Container(
                                  height: 10,
                                ),
                                FormRequestCheckBox(
                                  update: widget.model.update,
                                  label: "Mapa de calor",
                                  field: widget.model.showHeatMapReports,
                                  enabled: true,
                                ),
                                Container(
                                  height: 10,
                                ),
                                ElevatedButton(
                                  child: Text("Limpiar filtro"),
                                  onPressed: () {
                                    widget.model.update(() {
                                      widget.model.categories.value = null;
                                      widget.model.subCategories.value = null;
                                      widget.model.actors.value = null;
                                      widget.model.dateRange.value = null;
                                      widget.model.showHeatMapReports.value = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Abordajes", // Cambia "Título Bonito" por el texto que desees
                                style: TextStyle(
                                  fontSize: 20, // Tamaño de fuente mayor para hacerlo destacar
                                  fontWeight: FontWeight.bold, // Negrita para más énfasis
                                  color: Colors.blue, // Color azul o el que prefieras
                                ),
                              ),
                            ),
                            FormRequestToggleSwitch(
                              update: widget.model.update,

                              // label: "Option Sample",
                              field: widget.model.showHeatMap,
                              enabled: true,
                              onChanged: (_) {
                                widget.onGenderUpdate();
                              },
                            ),
                          ],
                        ),
                        if (widget.model.showHeatMap.value == true)
                          Container(
                            margin: EdgeInsets.all(5),
                            child: Column(
                              children: [
                                FormRequestMultiSelectField(
                                  update: widget.model.update,
                                  field: widget.model.heatMapFilter,
                                  label: "Genero",
                                  items: Gender.values
                                      .map(
                                        (e) => DropdownItem(
                                          id: e.toValue(),
                                          text: e.toValue(),
                                        ),
                                      )
                                      .toList(),
                                  enabled: true,
                                  onChanged: (_) {
                                    widget.onGenderUpdate();
                                  },
                                ),
                              ],
                            ),
                          ),
                        Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Rutas", // Cambia "Título Bonito" por el texto que desees
                                style: TextStyle(
                                  fontSize: 20, // Tamaño de fuente mayor para hacerlo destacar
                                  fontWeight: FontWeight.bold, // Negrita para más énfasis
                                  color: Colors.blue, // Color azul o el que prefieras
                                ),
                              ),
                            ),
                            FormRequestToggleSwitch(
                              update: widget.model.update,

                              // label: "Option Sample",
                              field: widget.model.showRoutes,
                              enabled: true,
                            ),
                          ],
                        ),
                        if (widget.model.showRoutes.value == true)
                          Container(
                            margin: EdgeInsets.all(5),
                            child: Column(
                              children: [
                                FormRequestMultiSelectField(
                                  update: widget.model.update,
                                  field: widget.model.agenciesSelection,
                                  label: "Operadores",
                                  items: gtfsData.agencies
                                      .map(
                                        (e) => DropdownItem(
                                          id: e.agencyId,
                                          text: e.agencyName,
                                        ),
                                      )
                                      .toList(),
                                  enabled: true,
                                  onChanged: (items) {
                                    final routesSelected = widget.model.routesSelection.value ?? [];
                                    final routes = routesSelected
                                        .map((value) => gtfsData.routes.findOrNull((route) => route.routeId == value)!)
                                        .where((value) => items.contains(value.agencyId))
                                        .map((value) => value.routeId)
                                        .toList();
                                    widget.model.update(() {
                                      widget.model.routesSelection.value = routes;
                                    });
                                  },
                                ),
                                FormRequestMultiSelectField(
                                  update: widget.model.update,
                                  field: widget.model.routesSelection,
                                  label: "Rutas",
                                  items: gtfsData.routes
                                      .where((value) => widget.model.agenciesSelection.value?.contains(value.agencyId) ?? false)
                                      .map(
                                        (e) => DropdownItem(
                                          id: e.routeId,
                                          text: e.routeShortName,
                                        ),
                                      )
                                      .toList(),
                                  enabled: true,
                                ),
                                FormRequestCheckBox(
                                  update: widget.model.update,
                                  label: "Mostrar todas las rutas",
                                  field: widget.model.showAllRoutes,
                                  enabled: true,
                                ),
                              ],
                            ),
                          ),
                        Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Paraderos", // Cambia "Título Bonito" por el texto que desees
                                style: TextStyle(
                                  fontSize: 20, // Tamaño de fuente mayor para hacerlo destacar
                                  fontWeight: FontWeight.bold, // Negrita para más énfasis
                                  color: Colors.blue, // Color azul o el que prefieras
                                ),
                              ),
                            ),
                            FormRequestToggleSwitch(
                              update: widget.model.update,

                              // label: "Option Sample",
                              field: widget.model.showStops,
                              enabled: true,
                            ),
                          ],
                        ),
                        if (widget.model.showStops.value == true)
                          Container(
                            margin: EdgeInsets.all(5),
                            child: Column(
                              children: [
                                FormRequestMultiSelectField(
                                  update: widget.model.update,
                                  field: widget.model.stopsFilter,
                                  label: "Paradas",
                                  items: FeatureType.values
                                      .map(
                                        (e) => DropdownItem(
                                          id: e.toValue(),
                                          text: e.toText(),
                                        ),
                                      )
                                      .toList(),
                                  enabled: true,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }
}

class BaseMapLayer extends StatefulWidget {
  const BaseMapLayer({super.key, required this.gtfsData, required this.zoom});
  final Gtfs gtfsData;
  final double zoom;

  @override
  State<BaseMapLayer> createState() => _BaseMapLayerState();
}

class _BaseMapLayerState extends State<BaseMapLayer> {
  late List<Polyline> _cachedRoutes;
  late List<Marker> _cachedMarkers;
  late Gtfs _lastGtfsData;

  @override
  void initState() {
    super.initState();
    _lastGtfsData = widget.gtfsData;
    _cachedRoutes = _getRoutes(_lastGtfsData);
    _cachedMarkers = _getStopsMarkers(_lastGtfsData);
  }

  @override
  void didUpdateWidget(BaseMapLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gtfsData != _lastGtfsData) {
      setState(() {
        _lastGtfsData = widget.gtfsData;
        _cachedRoutes = _getRoutes(_lastGtfsData);
        _cachedMarkers = _getStopsMarkers(_lastGtfsData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PolylineLayer(
          polylines: _cachedRoutes,
        ),
        if (widget.zoom > 16)
          MarkerLayer(
            markers: _cachedMarkers,
          )
      ],
    );
  }

  List<Polyline> _getRoutes(Gtfs gtfsData) {
    if (gtfsData.shapes.isEmpty) return [];
    final Map<String, List<LatLng>> shapeMap = {};
    for (var shape in gtfsData.shapes) {
      if (!shapeMap.containsKey(shape.shapeId)) {
        shapeMap[shape.shapeId] = [];
      }
      shapeMap[shape.shapeId]!.add(LatLng(shape.shapePtLat, shape.shapePtLon));
    }

    return shapeMap.entries.map((entry) {
      return Polyline(
        points: entry.value,
        strokeWidth: 10,
        color: Colors.blueGrey,
        useStrokeWidthInMeter: true,
      );
    }).toList();
  }

  List<Marker> _getStopsMarkers(Gtfs gtfsData) {
    if (gtfsData.stops.isEmpty) return [];
    return gtfsData.stops.map((stop) {
      return Marker(
          point: LatLng(stop.stopLat, stop.stopLon),
          alignment: Alignment.center,
          height: 10,
          width: 10,
          child: Tooltip(
            message: stop.stopName,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
            ),
          ));
    }).toList();
  }
}

class SelectedMapLayer extends StatefulWidget {
  const SelectedMapLayer({
    super.key,
    required this.gtfsData,
    required this.zoom,
    required this.routeSelection,
  });

  final Gtfs gtfsData;
  final double zoom;
  final List<String> routeSelection;

  @override
  State<SelectedMapLayer> createState() => _SelectedMapLayerState();
}

class _SelectedMapLayerState extends State<SelectedMapLayer> {
  late List<Polyline> _cachedSelectedRoutes;
  late List<Marker> _cachedSelectedMarkers;
  late Gtfs _lastGtfsData;
  late String _lastRouteSelection;

  @override
  void initState() {
    super.initState();
    _lastGtfsData = widget.gtfsData;
    _lastRouteSelection = widget.routeSelection.toString();
    _cachedSelectedRoutes = _getSelectedRoutes(_lastGtfsData, widget.routeSelection);
    _cachedSelectedMarkers = _getSelectedStopsMarkers(_lastGtfsData, widget.routeSelection);
  }

  @override
  void didUpdateWidget(SelectedMapLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gtfsData != _lastGtfsData || widget.routeSelection.toString() != _lastRouteSelection) {
      setState(() {
        _lastGtfsData = widget.gtfsData;
        _lastRouteSelection = widget.routeSelection.toString();
        _cachedSelectedRoutes = _getSelectedRoutes(_lastGtfsData, widget.routeSelection);
        _cachedSelectedMarkers = _getSelectedStopsMarkers(_lastGtfsData, widget.routeSelection);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PolylineLayer(
          polylines: _cachedSelectedRoutes,
        ),
        if (widget.zoom > 14)
          MarkerLayer(
            markers: _cachedSelectedMarkers,
          )
      ],
    );
  }

  List<Polyline> _getSelectedRoutes(Gtfs gtfsData, List<String> selectedTrips) {
    if (gtfsData.shapes.isEmpty) return [];
    final Map<String, List<LatLng>> shapeMap = {};
    for (var shape in gtfsData.shapes) {
      if (selectedTrips.contains(shape.shapeId)) {
        if (!shapeMap.containsKey(shape.shapeId)) {
          shapeMap[shape.shapeId] = [];
        }
        shapeMap[shape.shapeId]!.add(LatLng(shape.shapePtLat, shape.shapePtLon));
      }
    }

    return shapeMap.entries.map((entry) {
      final id = entry.key;
      final route = gtfsData.routes.findOrNull((value) => value.routeId == id);
      return Polyline(
        points: entry.value,
        strokeWidth: 5,
        color: hexToColor(route?.routeColor) ?? Colors.purple,
      );
    }).toList();
  }

  Color? hexToColor(String? hex) {
    if (hex == null) return null;
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) {
      hex = "FF$hex";
    }
    return Color(int.parse(hex, radix: 16));
  }

  List<Marker> _getSelectedStopsMarkers(
    Gtfs gtfsData,
    List<String> selectedRoutes,
  ) {
    if (gtfsData.stops.isEmpty) return [];
    final selectedTripIds = gtfsData.trips.where((trip) => selectedRoutes.contains(trip.routeId)).map((trip) => trip.tripId).toList();
    final selectedStopIds = gtfsData.stopTimes.where((stopTime) => selectedTripIds.contains(stopTime.tripId)).map((stopTime) => stopTime.stopId).toList();
    return gtfsData.stops.where((stop) => selectedStopIds.contains(stop.stopId)).map((stop) {
      return Marker(
        point: LatLng(stop.stopLat, stop.stopLon),
        alignment: Alignment.center,
        height: 16,
        width: 16,
        child: Tooltip(
          message: stop.stopName,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: Colors.black,
                width: 1,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

class RouteTripsList extends StatefulWidget {
  final Gtfs gtfsData;

  const RouteTripsList({
    super.key,
    required this.gtfsData,
    required this.tripsSelection,
    required this.onChanged,
  });
  final List<String> tripsSelection;
  final void Function(bool?, String) onChanged;
  @override
  RouteTripsListState createState() => RouteTripsListState();
}

class RouteTripsListState extends State<RouteTripsList> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: ListView(
        children: widget.gtfsData.routes.map((route) {
          return CheckboxListTile(
            title: Text(route.routeShortName),
            contentPadding: const EdgeInsets.all(0),
            value: widget.tripsSelection.contains(route.routeId),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (bool? value) {
              widget.onChanged(value, route.routeId);
            },
          );
        }).toList(),
      ),
    );
  }
}

class ReportPieChart extends StatefulWidget {
  final List<Report> reports;
  final Map<int, Category> categories; // Mapa de categorías principales
  final void Function() onClose;
  ReportPieChart({
    required this.reports,
    required this.categories,
    required this.onClose,
  });

  @override
  State<ReportPieChart> createState() => _ReportPieChartState();
}

class _ReportPieChartState extends State<ReportPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Color de fondo blanco
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ), // Bordes redondeados
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Color de sombra con opacidad
            spreadRadius: 5, // Extensión de la sombra
            blurRadius: 10, // Difuminado de la sombra
            offset: Offset(0, 3), // Desplazamiento de la sombra (x, y)
          ),
        ],
      ),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: Text(
                  "Estadisticas de reportes", // Cambia "Título Bonito" por el texto que desees
                  style: TextStyle(
                    fontSize: 30, // Tamaño de fuente mayor para hacerlo destacar
                    fontWeight: FontWeight.bold, // Negrita para más énfasis
                    color: Colors.blue, // Color azul o el que prefieras
                  ),
                ),
              ),
              IconButton(
                  onPressed: widget.onClose,
                  icon: Icon(
                    Icons.close,
                    size: 30,
                  )),
            ],
          ),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              final shortesSide = constraints.biggest.shortestSide;
              return PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 20,
                  sections: showingSections(shortesSide / 2.5),
                ),
              );
            }),
          ),
          Column(
            children: widget.categories.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Indicator(
                  color: entry.value.color, // Utiliza el color de la categoría
                  text: entry.value.categoryName ?? 'Unknown',
                  isSquare: true,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(double shortesSide) {
    Map<int, int> categoryCounts = {};
    for (var report in widget.reports) {
      int? subCategoryId = report.categoryId;
      Category? category = widget.categories[subCategoryId];
      if (category == null) {
        for (final categoryItem in widget.categories.values) {
          for (final subCategory in categoryItem.subcategories) {
            if (subCategory.id == subCategoryId) {
              category = categoryItem;
              break;
            }
          }
          if (category != null) break;
        }
      }
      if (category != null) {
        int mainCategoryId = category.parentId ?? category.id;
        categoryCounts[mainCategoryId] = (categoryCounts[mainCategoryId] ?? 0) + 1;
      }
    }

    int index = 0;
    return categoryCounts.entries.map((entry) {
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? shortesSide + 10 : shortesSide;
      final double percentage = entry.value.toDouble() / widget.reports.length * 100;
      index++;

      return PieChartSectionData(
        color: widget.categories[entry.key]?.color ?? Colors.grey, // Utiliza el color de la categoría o gris por defecto
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    }).toList();
  }
}

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}
