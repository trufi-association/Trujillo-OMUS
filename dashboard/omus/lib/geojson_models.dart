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
      name: json['properties']['Name'],
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
