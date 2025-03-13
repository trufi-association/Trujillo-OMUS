class Gtfs {
  final List<Agency> agencies;
  final List<Route> routes;
  final List<Stop> stops;
  final List<Shape> shapes;
  final List<Frequency> frequencies;
  final List<Calendar> calendars;
  final List<StopTime> stopTimes;
  final List<Trip> trips;

  Gtfs({
    required this.agencies,
    required this.routes,
    required this.stops,
    required this.shapes,
    required this.frequencies,
    required this.calendars,
    required this.stopTimes,
    required this.trips,
  });
}

class Agency {
  final String agencyId;
  final String agencyName;
  final String agencyUrl;
  final String agencyTimezone;
  final String? agencyLang;
  final String? agencyPhone;
  final String? agencyFareUrl;
  final String? agencyEmail;

  Agency({
    required this.agencyId,
    required this.agencyName,
    required this.agencyUrl,
    required this.agencyTimezone,
    this.agencyLang,
    this.agencyPhone,
    this.agencyFareUrl,
    this.agencyEmail,
  });

  factory Agency.fromList(List<dynamic> data, List<String> headers) {
    final map = Map<String, dynamic>.fromIterables(headers, data);
    return Agency(
      agencyId: "${map['agency_id']}",
      agencyName: "${map['agency_name']}",
      agencyUrl: "${map['agency_url']}",
      agencyTimezone: "${map['agency_timezone']}",
      agencyLang: map['agency_lang'] != null ? "${map['agency_lang']}" : null,
      agencyPhone: map['agency_phone'] != null ? "${map['agency_phone']}" : null,
      agencyFareUrl: map['agency_fare_url'] != null ? "${map['agency_fare_url']}" : null,
      agencyEmail: map['agency_email'] != null ? "${map['agency_email']}" : null,
    );
  }
}

class Route {
  final String routeId;
  final String agencyId;
  final String routeShortName;
  final String routeLongName;
  final String routeDesc;
  final int routeType;
  final String? routeUrl;
  final String? routeColor;
  final String? routeTextColor;

  Route({
    required this.routeId,
    required this.agencyId,
    required this.routeShortName,
    required this.routeLongName,
    required this.routeDesc,
    required this.routeType,
    this.routeUrl,
    this.routeColor,
    this.routeTextColor,
  });

  factory Route.fromList(List<dynamic> data, List<String> headers) {
    final map = Map<String, dynamic>.fromIterables(headers, data);
    return Route(
      routeId: "${map['route_id']}",
      agencyId: "${map['agency_id']}",
      routeShortName: "${map['route_short_name']}",
      routeLongName: "${map['route_long_name']}",
      routeDesc: "${map['route_desc']}",
      routeType: int.parse("${map['route_type']}"),
      routeUrl: map['route_url'] != null ? "${map['route_url']}" : null,
      routeColor: map['route_color'] != null ? "${map['route_color']}" : null,
      routeTextColor: map['route_text_color'] != null ? "${map['route_text_color']}" : null,
    );
  }
}

class Stop {
  final String stopId;
  final String stopCode;
  final String stopName;
  final double stopLat;
  final double stopLon;
  final String? zoneId;
  final String? stopUrl;
  final int? locationType;
  final String? parentStation;
  final String? stopTimezone;
  final String? wheelchairBoarding;

  Stop({
    required this.stopId,
    required this.stopCode,
    required this.stopName,
    required this.stopLat,
    required this.stopLon,
    this.zoneId,
    this.stopUrl,
    this.locationType,
    this.parentStation,
    this.stopTimezone,
    this.wheelchairBoarding,
  });

  factory Stop.fromList(List<dynamic> data, List<String> headers) {
    final map = Map<String, dynamic>.fromIterables(headers, data);
    return Stop(
      stopId: "${map['stop_id']}",
      stopCode: "${map['stop_code']}",
      stopName: "${map['stop_name']}",
      stopLat: double.parse("${map['stop_lat']}"),
      stopLon: double.parse("${map['stop_lon']}"),
      zoneId: map['zone_id'] != null ? "${map['zone_id']}" : null,
      stopUrl: map['stop_url'] != null ? "${map['stop_url']}" : null,
      locationType: map['location_type'] != null ? int.tryParse("${map['location_type']}") : null,
      parentStation: map['parent_station'] != null ? "${map['parent_station']}" : null,
      stopTimezone: map['stop_timezone'] != null ? "${map['stop_timezone']}" : null,
      wheelchairBoarding: map['wheelchair_boarding'] != null ? "${map['wheelchair_boarding']}" : null,
    );
  }
}

class Shape {
  final String shapeId;
  final double shapePtLat;
  final double shapePtLon;
  final int shapePtSequence;
  final double? shapeDistTraveled;

  Shape({
    required this.shapeId,
    required this.shapePtLat,
    required this.shapePtLon,
    required this.shapePtSequence,
    this.shapeDistTraveled,
  });

  factory Shape.fromList(List<dynamic> data, List<String> headers) {
    final map = Map<String, dynamic>.fromIterables(headers, data);
    return Shape(
      shapeId: "${map['shape_id']}",
      shapePtLat: double.parse("${map['shape_pt_lat']}"),
      shapePtLon: double.parse("${map['shape_pt_lon']}"),
      shapePtSequence: int.parse("${map['shape_pt_sequence']}"),
      shapeDistTraveled: map['shape_dist_traveled'] != null ? double.tryParse("${map['shape_dist_traveled']}") : null,
    );
  }
}

class Frequency {
  final String tripId;
  final String startTime;
  final String endTime;
  final int headwaySecs;
  final int? exactTimes;

  Frequency({
    required this.tripId,
    required this.startTime,
    required this.endTime,
    required this.headwaySecs,
    this.exactTimes,
  });

  factory Frequency.fromList(List<dynamic> data, List<String> headers) {
    final map = Map<String, dynamic>.fromIterables(headers, data);
    return Frequency(
      tripId: "${map['trip_id']}",
      startTime: "${map['start_time']}",
      endTime: "${map['end_time']}",
      headwaySecs: int.parse("${map['headway_secs']}"),
      exactTimes: map['exact_times'] != null ? int.tryParse("${map['exact_times']}") : null,
    );
  }
}

class Calendar {
  final String serviceId;
  final int monday;
  final int tuesday;
  final int wednesday;
  final int thursday;
  final int friday;
  final int saturday;
  final int sunday;
  final String startDate;
  final String endDate;

  Calendar({
    required this.serviceId,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
    required this.startDate,
    required this.endDate,
  });

  factory Calendar.fromList(List<dynamic> data, List<String> headers) {
    final map = Map<String, dynamic>.fromIterables(headers, data);
    return Calendar(
      serviceId: "${map['service_id']}",
      monday: int.parse("${map['monday']}"),
      tuesday: int.parse("${map['tuesday']}"),
      wednesday: int.parse("${map['wednesday']}"),
      thursday: int.parse("${map['thursday']}"),
      friday: int.parse("${map['friday']}"),
      saturday: int.parse("${map['saturday']}"),
      sunday: int.parse("${map['sunday']}"),
      startDate: "${map['start_date']}",
      endDate: "${map['end_date']}",
    );
  }
}

class StopTime {
  final String tripId;
  final String arrivalTime;
  final String departureTime;
  final String stopId;
  final int stopSequence;
  final String? stopHeadsign;
  final int? pickupType;
  final int? dropOffType;
  final double? shapeDistTraveled;
  final int? timepoint;

  StopTime({
    required this.tripId,
    required this.arrivalTime,
    required this.departureTime,
    required this.stopId,
    required this.stopSequence,
    this.stopHeadsign,
    this.pickupType,
    this.dropOffType,
    this.shapeDistTraveled,
    this.timepoint,
  });

  factory StopTime.fromList(List<dynamic> data, List<String> headers) {
    final map = Map<String, dynamic>.fromIterables(headers, data);
    return StopTime(
      tripId: "${map['trip_id']}",
      arrivalTime: "${map['arrival_time']}",
      departureTime: "${map['departure_time']}",
      stopId: "${map['stop_id']}",
      stopSequence: int.parse("${map['stop_sequence']}"),
      stopHeadsign: map['stop_headsign'] != null ? "${map['stop_headsign']}" : null,
      pickupType: map['pickup_type'] != null ? int.tryParse("${map['pickup_type']}") : null,
      dropOffType: map['drop_off_type'] != null ? int.tryParse("${map['drop_off_type']}") : null,
      shapeDistTraveled: map['shape_dist_traveled'] != null ? double.tryParse("${map['shape_dist_traveled']}") : null,
      timepoint: map['timepoint'] != null ? int.tryParse("${map['timepoint']}") : null,
    );
  }
}

class Trip {
  final String routeId;
  final String serviceId;
  final String tripId;
  final String? tripHeadsign;
  final String? tripShortName;
  final int? directionId;
  final String? blockId;
  final String? shapeId;
  final int? wheelchairAccessible;
  final int? bikesAllowed;

  Trip({
    required this.routeId,
    required this.serviceId,
    required this.tripId,
    this.tripHeadsign,
    this.tripShortName,
    this.directionId,
    this.blockId,
    this.shapeId,
    this.wheelchairAccessible,
    this.bikesAllowed,
  });

  factory Trip.fromList(List<dynamic> data, List<String> headers) {
    final map = Map<String, dynamic>.fromIterables(headers, data);
    return Trip(
      routeId: "${map['route_id']}",
      serviceId: "${map['service_id']}",
      tripId: "${map['trip_id']}",
      tripHeadsign: map['trip_headsign'] != null ? "${map['trip_headsign']}" : null,
      tripShortName: map['trip_short_name'] != null ? "${map['trip_short_name']}" : null,
      directionId: map['direction_id'] != null ? int.tryParse("${map['direction_id']}") : null,
      blockId: map['block_id'] != null ? "${map['block_id']}" : null,
      shapeId: map['shape_id'] != null ? "${map['shape_id']}" : null,
      wheelchairAccessible: map['wheelchair_accessible'] != null ? int.tryParse("${map['wheelchair_accessible']}") : null,
      bikesAllowed: map['bikes_allowed'] != null ? int.tryParse("${map['bikes_allowed']}") : null,
    );
  }
}
