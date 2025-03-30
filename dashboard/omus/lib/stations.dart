import 'package:latlong2/latlong.dart';

class Station {
  final String id;
  final String name;
  final String description;
  final LatLng location;
  final StationInfo info;

  Station({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.info,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    final coordinates = json['location']['coordinates'];
    return Station(
      id: json['_id'],
      name: json['name'],
      description: json['desc'],
      location: LatLng(coordinates[1], coordinates[0]),
      info: StationInfo.fromJson(json['info']),
    );
  }
}

class StationInfo {
  final String codigo;
  final String lugar;
  final String ubicacion;
  final List<String> variables;
  final String estado;

  StationInfo({
    required this.codigo,
    required this.lugar,
    required this.ubicacion,
    required this.variables,
    required this.estado,
  });

  factory StationInfo.fromJson(Map<String, dynamic> json) {
    return StationInfo(
      codigo: json['codigo'],
      lugar: json['lugar'],
      ubicacion: json['ubicacion'],
      variables: List<String>.from(json['variables']),
      estado: json['estado'],
    );
  }
}
