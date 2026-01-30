class Region {
  final String name;
  final List<Feature> features;

  Region({required this.name, required this.features});

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      name: json['name'],
      features: (json['features'] as List).map((e) => Feature.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'features': features.map((e) => e.toJson()).toList(),
      };
}

class Feature {
  final String name;
  final List<Location> geometry;

  Feature({required this.name, required this.geometry});

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      name: json['properties']['name'],
      geometry: (json['geometry']['coordinates'] as List).map((e) => Location(latitude: e[1], longitude: e[0])).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'geometry': geometry.map((e) => e.toJson()).toList(),
      };
}

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

Map<String, Region> loadRegions(Map<String, dynamic> parsedJson) {
  return parsedJson.map((key, value) => MapEntry(
        key,
        Region.fromJson(value),
      ));
}

/// GeoJSON Feature model for bus stops with accessibility properties.
class GeoFeature {
  final Location coordinates;
  final bool? advertising;
  final bool? bench;
  final bool? bicycleParking;
  final bool? bin;
  final bool? lit;
  final bool? ramp;
  final bool? shelter;
  final bool? level;
  final bool? passengerInformationDisplaySpeechOutput;
  final bool? tactileWritingBrailleEs;
  final bool? tactilePaving;
  final bool? departuresBoard;

  GeoFeature({
    required this.coordinates,
    this.advertising,
    this.bench,
    this.bicycleParking,
    this.bin,
    this.lit,
    this.ramp,
    this.shelter,
    this.level,
    this.passengerInformationDisplaySpeechOutput,
    this.tactileWritingBrailleEs,
    this.tactilePaving,
    this.departuresBoard,
  });

  factory GeoFeature.fromJson(Map<String, dynamic> json) {
    final coords = json['geometry']['coordinates'];
    final location = Location(latitude: coords[1], longitude: coords[0]);
    final properties = json['properties'];

    return GeoFeature(
      coordinates: location,
      advertising: _boolFromProperty(properties['advertising']),
      bench: _boolFromProperty(properties['bench']),
      bicycleParking: _boolFromProperty(properties['bicycle_parking']),
      bin: _boolFromProperty(properties['bin']),
      lit: _boolFromProperty(properties['lit']),
      ramp: _boolFromProperty(properties['ramp']),
      shelter: _boolFromProperty(properties['shelter']),
      level: properties['level'] == '1'
          ? true
          : properties['level'] == '0'
              ? false
              : null,
      passengerInformationDisplaySpeechOutput:
          _boolFromProperty(properties['passenger_information_display:speech_output']),
      tactileWritingBrailleEs:
          _boolFromProperty(properties['tactile_writing:braille:es']),
      tactilePaving: _boolFromProperty(properties['tactile_paving']),
      departuresBoard: _boolFromProperty(properties['departures_board']),
    );
  }

  static bool? _boolFromProperty(String? propertyValue) {
    if (propertyValue == 'yes') {
      return true;
    } else if (propertyValue == 'no') {
      return false;
    } else {
      return null;
    }
  }
}
