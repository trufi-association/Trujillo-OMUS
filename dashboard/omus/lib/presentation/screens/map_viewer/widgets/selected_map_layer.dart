import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:omus/data/models/gtfs_models.dart';
import 'package:omus/core/extensions/list_extensions.dart';

/// Renders the selected routes layer with highlighted routes and stops.
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
        shapeMap[shape.shapeId]!.add(LatLng(shape.shapePtLat, shape.shapePtLon));
      }
    }

    return shapeMap.entries.map((entry) {
      final id = entry.key;
      final route = gtfsData.routes.findOrNull((value) => value.routeId == id);
      return Polyline(
        points: entry.value,
        strokeWidth: 5,
        color: _hexToColor(route?.routeColor) ?? const Color(0xFF808080),
      );
    }).toList();
  }

  Color? _hexToColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
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
