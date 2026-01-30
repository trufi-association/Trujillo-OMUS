import 'package:flutter/services.dart' show rootBundle;
import 'package:omus/data/models/gtfs_models.dart';

/// Service for loading GTFS data from assets.
class GtfsService {
  Future<Map<String, dynamic>> _loadCsv(String path) async {
    final data = await rootBundle.loadString(path);
    final normalizedData = data.replaceAll(RegExp(r'\r\n?'), '\n');
    final rows = normalizedData.trim().split('\n');
    final headers =
        rows.first.split(',').map((header) => header.trim()).toList();
    final dataRows = rows
        .skip(1)
        .map((row) => row.split(',').map((item) => item.trim()).toList())
        .toList();

    return {'headers': headers, 'data': dataRows};
  }

  /// Loads all GTFS data from asset files.
  Future<Gtfs> loadGtfsData() async {
    final agencyData = await _loadCsv('assets/gtfs/agency.txt');
    final routesData = await _loadCsv('assets/gtfs/routes.txt');
    final stopsData = await _loadCsv('assets/gtfs/stops.txt');
    final shapesData = await _loadCsv('assets/gtfs/shapes.txt');
    final frequenciesData = await _loadCsv('assets/gtfs/frequencies.txt');
    final calendarData = await _loadCsv('assets/gtfs/calendar.txt');
    final stopTimesData = await _loadCsv('assets/gtfs/stop_times.txt');
    final tripsData = await _loadCsv('assets/gtfs/trips.txt');

    final agencies = agencyData['data']
        .map<Agency>((data) => Agency.fromList(data, agencyData['headers']))
        .toList();
    final routes = routesData['data']
        .map<Route>((data) => Route.fromList(data, routesData['headers']))
        .toList();
    final stops = stopsData['data']
        .map<Stop>((data) => Stop.fromList(data, stopsData['headers']))
        .toList();
    final shapes = shapesData['data']
        .map<Shape>((data) => Shape.fromList(data, shapesData['headers']))
        .toList();
    final frequencies = frequenciesData['data']
        .map<Frequency>(
            (data) => Frequency.fromList(data, frequenciesData['headers']))
        .toList();
    final calendars = calendarData['data']
        .map<Calendar>(
            (data) => Calendar.fromList(data, calendarData['headers']))
        .toList();
    final stopTimes = stopTimesData['data']
        .map<StopTime>(
            (data) => StopTime.fromList(data, stopTimesData['headers']))
        .toList();
    final trips = tripsData['data']
        .map<Trip>((data) => Trip.fromList(data, tripsData['headers']))
        .toList();

    return Gtfs(
      agencies: agencies,
      routes: routes,
      stops: stops,
      shapes: shapes,
      frequencies: frequencies,
      calendars: calendars,
      stopTimes: stopTimes,
      trips: trips,
    );
  }
}
