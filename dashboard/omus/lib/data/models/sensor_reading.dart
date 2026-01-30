/// Model for sensor reading data from air quality stations.
class SensorReading {
  final String payload;
  final DateTime createdAt;
  final String sensor;
  final String icon;
  final String description;
  final String measureUnit;

  SensorReading({
    required this.payload,
    required this.createdAt,
    required this.sensor,
    required this.icon,
    required this.description,
    required this.measureUnit,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      payload: json['payload'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      sensor: json['sensor'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String,
      measureUnit: json['measure_unit'] as String,
    );
  }
}
