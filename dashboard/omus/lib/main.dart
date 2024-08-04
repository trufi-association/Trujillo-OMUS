import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:omus/services/api_service.dart';
import 'package:omus/services/models/category.dart';
import 'package:omus/services/models/report.dart';
import 'package:omus/services/models/vial_actor.dart';
import 'package:omus/widgets/components/dropdown/helpers/dropdown_item.dart';
import 'package:omus/widgets/components/dropdown/multi_select_dropdown.dart';
import 'package:omus/widgets/components/helpers/form_loading_helper_new.dart';
import 'package:omus/widgets/components/helpers/form_request_container.dart';
import 'package:omus/widgets/components/helpers/responsive_container.dart';
import 'package:omus/widgets/components/textfield/form_request_date_range_field.dart';
import 'package:omus/widgets/components/textfield/form_request_field.dart';
import 'package:omus/widgets/components/toggle_switch/custom_toggle_switch.dart';
import 'gtfs_service.dart';
import 'package:provider/provider.dart';
import 'gtfs.dart';

void main() {
  runApp(const MyApp());
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

class _SampleRequest extends FormRequest {
  _SampleRequest({
    required this.categories,
    required this.actors,
    required this.routesSelection,
    required this.dateRange,
    required this.showAll,
  });

  factory _SampleRequest.fromScratch() => _SampleRequest(
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

class GtfsMapState extends State<GtfsMap> {
  // List<String> tripsSelection = [];
  double zoom = 13;

  @override
  Widget build(BuildContext context) {
    final gtfsData = context.watch<Gtfs>();
    return Scaffold(
      // drawer: Drawer(
      //   child: RouteTripsList(
      //     tripsSelection: tripsSelection,
      //     gtfsData: gtfsData,
      //     onChanged: (bool? value, tripId) {
      //       if (value ?? false) {
      //         setState(() {
      //           tripsSelection.add(tripId);
      //         });
      //       } else {
      //         setState(() {
      //           tripsSelection.remove(tripId);
      //         });
      //       }
      //     },
      //   ),
      // ),
      body: FormRequestManager<Never, _SampleRequest, ServerOriginal>(
          id: null,
          fromScratch: _SampleRequest.fromScratch,
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
            return Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                      initialCenter: const LatLng(-8.1120, -79.0280),
                      initialZoom: zoom,
                      onPositionChanged: (camera, _) {
                        setState(() {
                          zoom = camera.zoom;
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
                  ],
                ),
                Container(
                  color: Colors.red,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomResponsiveContainer(
                        children: [
                          CustomResponsiveItem.smFixed(
                            child: FormDateRangePickerField(
                              update: model.update,
                              label: "dates",
                              field: model.dateRange,
                              enabled: true,
                            ),
                          ),
                          CustomResponsiveItem.fill(
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
                          CustomResponsiveItem.fill(
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
                          CustomResponsiveItem.small(
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
                          CustomResponsiveItem.small(
                            child: FormRequestToggleSwitch(
                              update: model.update,
                              label: "show all",
                              field: model.showAll,
                              enabled: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            );
          }),
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

class BottomPanel extends StatelessWidget {
  const BottomPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Buscar Ruta o Parada',
            ),
            onChanged: (value) {
              // Implementa la lógica de búsqueda y filtrado
            },
          ),
          // Añade más UI y lógica de filtrado aquí
        ],
      ),
    );
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
      return Polyline(
        points: entry.value,
        strokeWidth: 5,
        color: Colors.purple,
        // useStrokeWidthInMeter: true,
      );
    }).toList();
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
