import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:omus/data/models/sensor_reading.dart';
import 'package:omus/stations.dart';

/// Widget that displays detailed information about a station.
class StationInfoRender extends StatefulWidget {
  const StationInfoRender({super.key, required this.station, this.onPressed});

  final Station station;
  final void Function()? onPressed;

  @override
  State<StationInfoRender> createState() => _StationInfoRenderState();
}

class _StationInfoRenderState extends State<StationInfoRender> {
  List<SensorReading> _readings = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) => _fetchData());
  }

  Future<void> _fetchData() async {
    final url =
        'https://tudata.info/api/v1/register/${widget.station.id}/last-register';

    var headers = {
      'x-api-key': '821303c9-yyqr-1860-vt4t',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _readings =
                data.map((json) => SensorReading.fromJson(json)).toList();
          });
        }
      }
    } catch (e) {
      // Error handling silently
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200, maxWidth: 500),
          child: Stack(
            children: [
              ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(10),
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Estación: ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        TextSpan(
                          text: widget.station.name,
                          style:
                              const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Código: ',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        TextSpan(
                          text: widget.station.info.codigo,
                          style:
                              const TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Lugar: ',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        TextSpan(
                          text: widget.station.info.lugar,
                          style:
                              const TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Ubicación: ',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        TextSpan(
                          text: widget.station.info.ubicacion,
                          style:
                              const TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Estado: ',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        TextSpan(
                          text: widget.station.info.estado,
                          style:
                              const TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Variables: \n',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        ..._readings.map((reading) => TextSpan(
                              text: '        ${reading.sensor}:    ',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              children: [
                                TextSpan(
                                  text:
                                      '${reading.payload} ${reading.measureUnit}\n',
                                  style:
                                      const TextStyle(fontWeight: FontWeight.normal),
                                ),
                              ],
                            )),
                      ],
                    ),
                  )
                ],
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: widget.onPressed,
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget that shows the air quality status indicator for a station marker.
class StationStatus extends StatefulWidget {
  final Station station;
  const StationStatus({super.key, required this.station});

  @override
  StationStatusState createState() => StationStatusState();
}

class StationStatusState extends State<StationStatus> {
  List<SensorReading> _readings = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) => _fetchData());
  }

  Future<void> _fetchData() async {
    final url =
        'https://tudata.info/api/v1/register/${widget.station.id}/last-register';

    var headers = {
      'x-api-key': '821303c9-yyqr-1860-vt4t',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _readings =
                data.map((json) => SensorReading.fromJson(json)).toList();
          });
        }
      }
    } catch (e) {
      // Error handling silently
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String? _calculateAirQuality() {
    double? getSensorValue(String sensorName) {
      final index = _readings.indexWhere((r) => r.sensor == sensorName);
      if (index == -1) return null;

      return double.tryParse(_readings[index].payload);
    }

    final pm2_5Value = getSensorValue('PM2_5');
    final pm10Value = getSensorValue('PM10');

    if (pm2_5Value == null || pm10Value == null) {
      return null;
    }

    if (pm2_5Value > 50 || pm10Value > 100) {
      return 'Poor';
    } else if (pm2_5Value > 25 || pm10Value > 50) {
      return 'Moderate';
    } else {
      return 'Good';
    }
  }

  Color _getColorBasedOnQuality(String? quality) {
    switch (quality) {
      case 'Good':
        return Colors.green;
      case 'Moderate':
        return Colors.orange;
      case 'Poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final airQuality = _calculateAirQuality();
    final color = _getColorBasedOnQuality(airQuality);

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white),
      ),
      child: const Icon(
        Icons.sensors,
        size: 20,
        color: Colors.white,
      ),
    );
  }
}
