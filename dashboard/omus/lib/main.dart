import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:latlong2/latlong.dart';
import 'package:omus/env.dart';
import 'package:omus/logo.dart';
import 'package:omus/services/api_service.dart';
import 'package:omus/services/models/category.dart';
import 'package:omus/services/models/report.dart';
import 'package:omus/services/models/vial_actor.dart';
import 'package:omus/widgets/components/dropdown/helpers/dropdown_item.dart';
import 'package:omus/widgets/components/dropdown/multi_select_dropdown.dart';
import 'package:omus/widgets/components/helpers/form_loading_helper_new.dart';
import 'package:omus/widgets/components/textfield/form_request_date_range_field.dart';
import 'package:omus/widgets/components/textfield/form_request_field.dart';
import 'package:omus/widgets/components/toggle_switch/custom_toggle_switch.dart';
import 'gtfs_service.dart';
import 'package:provider/provider.dart';
import 'gtfs.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(const MyApp());
}

extension FindOrNullExtension<T> on List<T> {
  T? findOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
      tileProvider: CancellableNetworkTileProvider(),
    );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => GtfsService()),
        FutureProvider<Gtfs>(
          create: (context) => context.read<GtfsService>().loadGtfsData(),
          initialData: Gtfs(
            agencies: [],
            routes: [],
            stops: [],
            shapes: [],
            frequencies: [],
            calendars: [],
            stopTimes: [],
            trips: [],
          ),
        ),
      ],
      child: const MaterialApp(
        title: 'GTFS Route Viewer',
        home: GtfsMap(),
      ),
    );
  }
}

class ModelRequest extends FormRequest {
  ModelRequest({
    required this.categories,
    required this.actors,
    required this.routesSelection,
    required this.dateRange,
    required this.showAll,
  });

  factory ModelRequest.fromScratch() => ModelRequest(
        categories: FormItemContainer<List<String>>(fieldKey: "categories", value: []),
        actors: FormItemContainer<List<String>>(fieldKey: "actors", value: []),
        routesSelection: FormItemContainer<List<String>>(fieldKey: "ac", value: []),
        dateRange: FormItemContainer<DateTimeRange>(
          fieldKey: "keyStartDate",
        ),
        showAll: FormItemContainer<bool>(fieldKey: "keyStartDate", value: false),
      );

  final FormItemContainer<List<String>> categories;
  final FormItemContainer<List<String>> actors;
  final FormItemContainer<List<String>> routesSelection;
  final FormItemContainer<DateTimeRange> dateRange;
  final FormItemContainer<bool> showAll;
}

class ServerOriginal {
  final List<Category> categories;
  final List<VialActor> actors;
  final List<Report> reports;

  ServerOriginal({
    required this.categories,
    required this.actors,
    required this.reports,
  });
}

class GtfsMap extends StatefulWidget {
  const GtfsMap({super.key});

  @override
  GtfsMapState createState() => GtfsMapState();
}

List<Report> filterReports({required ServerOriginal helper, required ModelRequest model}) {
  var categories = model.categories.value ?? [];
  if (categories.isEmpty) {
    categories = helper.categories.map((value) => value.id.toString()).toList();
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

    return (hasCategory || hasActor) && inDateRange;
  }).toList();
}

class GtfsMapState extends State<GtfsMap> {
  double zoom = 13;
  Report? currentReport;
  MapController mapController = MapController();
  Uint8List bytes = base64Decode(logo);
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
              return ServerOriginal(
                categories: response[0] as List<Category>,
                actors: response[1] as List<VialActor>,
                reports: response[2] as List<Report>,
              );
            },
            saveModel: (_, {id}) async => {},
            onSaveChanges: () => {},
            builder: (params) {
              final helper = params.responseModel.responseHelper!;
              final model = params.model;
              final filteredReports = filterReports(helper: helper, model: model);
              return Stack(
                children: [
                  FlutterMap(
                    mapController: mapController,
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
                      if (model.showAll.value == true)
                        BaseMapLayer(
                          zoom: zoom,
                          gtfsData: gtfsData,
                        ),
                      SelectedMapLayer(
                        zoom: zoom,
                        gtfsData: gtfsData,
                        routeSelection: model.routesSelection.value ?? [],
                      ),
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
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.blue),
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
                                                'Category: ${helper.categories.findOrNull((value) => value.id == currentReport!.categoryId)?.categoryName ?? "-"}',
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
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Container(
                        margin: const EdgeInsets.only(
                          top: 10,
                          left: 10,
                          right: 10,
                        ),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 153, 214),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 130,
                                  height: 47,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                    borderRadius: BorderRadius.circular(5),
                                    // boxShadow: [
                                    //   BoxShadow(
                                    //     color: Colors.grey.withOpacity(0.5),
                                    //     spreadRadius: 2,
                                    //     blurRadius: 5,
                                    //     offset: Offset(0, 3),
                                    //   ),
                                    // ],
                                  ),
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: Image.memory(bytes),
                                ),
                                Flexible(
                                  child: FormRequestMultiSelectField(
                                    update: model.update,
                                    field: model.categories,
                                    label: "Category",
                                    items: helper.categories
                                        .map(
                                          (e) => DropdownItem(
                                            id: e.id.toString(),
                                            text: e.categoryName.toString(),
                                          ),
                                        )
                                        .toList(),
                                    enabled: true,
                                  ),
                                ),
                                Flexible(
                                  child: FormRequestMultiSelectField(
                                    update: model.update,
                                    field: model.actors,
                                    label: "Vial Actors",
                                    items: helper.actors
                                        .map(
                                          (e) => DropdownItem(
                                            id: e.id.toString(),
                                            text: e.name.toString(),
                                          ),
                                        )
                                        .toList(),
                                    enabled: true,
                                  ),
                                ),
                                Flexible(
                                  // width: 220,
                                  child: FormDateRangePickerField(
                                    update: model.update,
                                    label: "Date range",
                                    field: model.dateRange,
                                    enabled: true,
                                  ),
                                ),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      model.update(() {
                                        model.actors.value = [];
                                        model.categories.value = [];
                                      });
                                    },
                                    child: Container(
                                      width: 50,
                                      height: 47,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 255, 255, 255),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                      child: const Icon(Icons.close),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      width: 130,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 255, 255, 255),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  "Reports",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(255, 150, 196, 115),
                                                  ),
                                                ),
                                                // SizedBox(height: 4),
                                                Text(
                                                  "${filteredReports.length}",
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(255, 64, 79, 115),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                            Icons.query_stats,
                                            color: Color.fromARGB(255, 255, 130, 159),
                                            size: 30,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: FormRequestMultiSelectField(
                                    update: model.update,
                                    field: model.routesSelection,
                                    label: "Routes",
                                    items: gtfsData.routes
                                        .map(
                                          (e) => DropdownItem(
                                            id: e.routeId,
                                            text: e.routeShortName,
                                          ),
                                        )
                                        .toList(),
                                    enabled: true,
                                  ),
                                ),
                                Container(
                                  height: 47,
                                  width: 170,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FormRequestToggleSwitch(
                                        update: model.update,
                                        label: "Show all routes",
                                        field: model.showAll,
                                        enabled: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
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
        color: Colors.red,
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
