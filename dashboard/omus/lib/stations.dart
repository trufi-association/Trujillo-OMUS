import 'package:latlong2/latlong.dart';

class Station {
  final String id;
  final String name;
  final String description;
  final LatLng location;

  Station({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    final coordinates = json['location']['coordinates'];
    return Station(
      id: json['_id'],
      name: json['name'],
      description: json['desc'],
      location: LatLng(coordinates[1], coordinates[0]),
    );
  }
}
