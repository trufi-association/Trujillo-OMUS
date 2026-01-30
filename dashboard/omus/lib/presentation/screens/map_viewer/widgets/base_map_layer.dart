import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:omus/data/models/gtfs_models.dart';

/// Renders the base map layer with all GTFS routes and stops.
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
        ),
      );
    }).toList();
  }
}
