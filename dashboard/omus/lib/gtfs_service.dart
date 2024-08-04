import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:omus/gtfs.dart';

class GtfsService {
  Future<Map<String, dynamic>> _loadCsv(String path) async {
    final data = await rootBundle.loadString(path);
    final rows = const CsvToListConverter().convert(data, eol: '\n');
    final headers = rows.first.map((header) => header.toString()).toList();
    final dataRows = rows.skip(1).toList();
    return {'headers': headers, 'data': dataRows};
  }

  Future<Gtfs> loadGtfsData() async {
    final agencyData = await _loadCsv('assets/gtfs/agency.txt');
    final routesData = await _loadCsv('assets/gtfs/routes.txt');
    final stopsData = await _loadCsv('assets/gtfs/stops.txt');
    final shapesData = await _loadCsv('assets/gtfs/shapes.txt');
    final frequenciesData = await _loadCsv('assets/gtfs/frequencies.txt');
    final calendarData = await _loadCsv('assets/gtfs/calendar.txt');
    final stopTimesData = await _loadCsv('assets/gtfs/stop_times.txt');
    final tripsData = await _loadCsv('assets/gtfs/trips.txt');

    List<Agency> agencies = agencyData['data']
        .map<Agency>((data) => Agency.fromList(data, agencyData['headers']))
        .toList();
    List<Route> routes = routesData['data']
        .map<Route>((data) => Route.fromList(data, routesData['headers']))
        .toList();
    List<Stop> stops = stopsData['data']
        .map<Stop>((data) => Stop.fromList(data, stopsData['headers']))
        .toList();
    List<Shape> shapes = shapesData['data']
        .map<Shape>((data) => Shape.fromList(data, shapesData['headers']))
        .toList();
    List<Frequency> frequencies = frequenciesData['data']
        .map<Frequency>(
            (data) => Frequency.fromList(data, frequenciesData['headers']))
        .toList();
    List<Calendar> calendars = calendarData['data']
        .map<Calendar>(
            (data) => Calendar.fromList(data, calendarData['headers']))
        .toList();
    List<StopTime> stopTimes = stopTimesData['data']
        .map<StopTime>(
            (data) => StopTime.fromList(data, stopTimesData['headers']))
        .toList();
    List<Trip> trips = tripsData['data']
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
