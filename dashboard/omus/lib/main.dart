import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
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

class GtfsMap extends StatefulWidget {
  const GtfsMap({super.key});

  @override
  GtfsMapState createState() => GtfsMapState();
}

class GtfsMapState extends State<GtfsMap> {
  List<String> tripsSelection = [];
  double zoom = 13;

  @override
  Widget build(BuildContext context) {
    final gtfsData = context.watch<Gtfs>();
    return Scaffold(
      drawer: Drawer(
        child: RouteTripsList(
          tripsSelection: tripsSelection,
          gtfsData: gtfsData,
          onChanged: (bool? value, tripId) {
            if (value ?? false) {
              setState(() {
                tripsSelection.add(tripId);
              });
            } else {
              setState(() {
                tripsSelection.remove(tripId);
              });
            }
          },
        ),
      ),
      appBar: AppBar(title: const Text('GTFS Route Viewer')),
      body: FlutterMap(
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
          BaseMapLayer(
            zoom: zoom,
            gtfsData: gtfsData,
          ),
          SelectedMapLayer(
            zoom: zoom,
            gtfsData: gtfsData,
            routeSelection: tripsSelection,
          ),
          // Stack(
          //   children: [
          //     PolylineLayer(
          //       polylines: _getRoutes(gtfsData),
          //     ),
          //     if (zoom > 16)
          //       MarkerLayer(
          //         markers: _getStopsMarkers(gtfsData),
          //       )
          //   ],
          // ),

          // : (zoom > 14)
          //     ? CircleLayer(
          //         circles: _getStopsCircles(gtfsData),
          //       )
          //     : Container(),
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
    _cachedSelectedRoutes =
        _getSelectedRoutes(_lastGtfsData, widget.routeSelection);
    _cachedSelectedMarkers =
        _getSelectedStopsMarkers(_lastGtfsData, widget.routeSelection);
  }

  @override
  void didUpdateWidget(SelectedMapLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gtfsData != _lastGtfsData ||
        widget.routeSelection.toString() != _lastRouteSelection) {
      setState(() {
        _lastGtfsData = widget.gtfsData;
        _lastRouteSelection = widget.routeSelection.toString();
        _cachedSelectedRoutes =
            _getSelectedRoutes(_lastGtfsData, widget.routeSelection);
        _cachedSelectedMarkers =
            _getSelectedStopsMarkers(_lastGtfsData, widget.routeSelection);
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
        shapeMap[shape.shapeId]!
            .add(LatLng(shape.shapePtLat, shape.shapePtLon));
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
    final selectedTripIds = gtfsData.trips
        .where((trip) => selectedRoutes.contains(trip.routeId))
        .map((trip) => trip.tripId)
        .toList();
    final selectedStopIds = gtfsData.stopTimes
        .where((stopTime) => selectedTripIds.contains(stopTime.tripId))
        .map((stopTime) => stopTime.stopId)
        .toList();
    return gtfsData.stops
        .where((stop) => selectedStopIds.contains(stop.stopId))
        .map((stop) {
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
