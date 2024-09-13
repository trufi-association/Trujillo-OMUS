import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:go_router/go_router.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:latlong2/latlong.dart';
import 'package:omus/env.dart';
import 'package:omus/logo.dart';
import 'package:omus/main.dart';
import 'package:omus/map_viewer.dart';
import 'package:omus/services/api_service.dart';
import 'package:omus/services/models/category.dart';
import 'package:omus/services/models/report.dart';
import 'package:omus/services/models/vial_actor.dart';
import 'package:omus/widgets/components/checkbox/custom_checkbox.dart';
import 'package:omus/widgets/components/dropdown/helpers/dropdown_item.dart';
import 'package:omus/widgets/components/dropdown/multi_select_dropdown.dart';
import 'package:omus/widgets/components/fleaflet_map_controller.dart';
import 'package:omus/widgets/components/helpers/form_loading_helper_new.dart';
import 'package:omus/widgets/components/textfield/form_request_date_range_field.dart';
import 'package:omus/widgets/components/textfield/form_request_field.dart';
import 'package:omus/widgets/components/toggle_switch/custom_toggle_switch.dart';
import 'package:omus/widgets/components/zoom_map_button.dart';
import 'gtfs_service.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';

class ModelRequest extends FormRequest {
  ModelRequest({
    required this.categories,
    required this.subCategories,
    required this.actors,
    required this.agenciesSelection,
    required this.routesSelection,
    required this.dateRange,
    required this.showRoutes,
    required this.showAllRoutes,
    required this.showHeatMap,
    required this.heatMapFilter,
    required this.showReports,
    required this.showHeatMapReports,
    required this.showStops,
    required this.stopsFilter,
  });

  factory ModelRequest.fromScratch() => ModelRequest(
        categories: FormItemContainer<List<String>>(fieldKey: "categories", value: []),
        subCategories: FormItemContainer<List<String>>(fieldKey: "categories", value: []),
        actors: FormItemContainer<List<String>>(fieldKey: "actors", value: []),
        agenciesSelection: FormItemContainer<List<String>>(fieldKey: "ac", value: []),
        routesSelection: FormItemContainer<List<String>>(fieldKey: "ac", value: []),
        dateRange: FormItemContainer<DateTimeRange>(
          fieldKey: "keyStartDate",
        ),
        showRoutes: FormItemContainer<bool>(fieldKey: "keyShowAllRoutes", value: false),
        showAllRoutes: FormItemContainer<bool>(fieldKey: "keyShowAllRoutes", value: true),
        showHeatMap: FormItemContainer<bool>(fieldKey: "keyShowHeatMap", value: false),
        heatMapFilter: FormItemContainer<List<String>>(fieldKey: "categories", value: []),
        showReports: FormItemContainer<bool>(fieldKey: "keyShowHeatMap", value: true),
        showHeatMapReports: FormItemContainer<bool>(fieldKey: "keyShowHeatMap", value: false),
        showStops: FormItemContainer<bool>(fieldKey: "keyShowHeatMap", value: true),
        stopsFilter: FormItemContainer<List<String>>(fieldKey: "categories", value: []),
      );

  final FormItemContainer<List<String>> categories;
  final FormItemContainer<List<String>> subCategories;
  final FormItemContainer<List<String>> actors;
  final FormItemContainer<List<String>> agenciesSelection;
  final FormItemContainer<List<String>> routesSelection;
  final FormItemContainer<DateTimeRange> dateRange;
  final FormItemContainer<bool> showRoutes;
  final FormItemContainer<bool> showAllRoutes;
  final FormItemContainer<bool> showHeatMap;
  final FormItemContainer<bool> showReports;
  final FormItemContainer<bool> showHeatMapReports;
  final FormItemContainer<List<String>> heatMapFilter;
  final FormItemContainer<bool> showStops;
  final FormItemContainer<List<String>> stopsFilter;
}

class ServerOriginal {
  final Map<int, Category> categories;
  final List<Category> allCategories;
  final List<VialActor> actors;
  final List<Report> reports;
  final List<GenderBoard> data;
  final List<GeoFeature> stops;
  ServerOriginal({
    required this.categories,
    required this.allCategories,
    required this.actors,
    required this.reports,
    required this.data,
    required this.stops,
  });
}

enum Gender {
  men,
  woman,
}

extension GenderExtension on Gender {
  static const Map<String, Gender> _valueMap = {
    'hombre': Gender.men,
    'mujer': Gender.woman,
  };

  static Gender fromValue(String value) => _valueMap[value.toLowerCase()]!;
  String toValue() => _valueMap.entries.firstWhere((entry) => entry.value == this).key;
}

class GeoFeature {
  final LatLng coordinates;
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
    final latLng = LatLng(coords[1], coords[0]);
    final properties = json['properties'];

    return GeoFeature(
      coordinates: latLng,
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
      passengerInformationDisplaySpeechOutput: _boolFromProperty(properties['passenger_information_display:speech_output']),
      tactileWritingBrailleEs: _boolFromProperty(properties['tactile_writing:braille:es']),
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

enum CategoryEnum {
  genderMobilityInclusive,
  roadSafety,
  citizenBehavior,
  infrastructureAccess,
  cleanEfficientMobility,
  userExperience,
}

extension CategoryExtension on CategoryEnum {
  static const Map<CategoryEnum, String> _titles = {
    CategoryEnum.genderMobilityInclusive: "Género y movilidad inclusiva",
    CategoryEnum.roadSafety: "Seguridad vial",
    CategoryEnum.citizenBehavior: "Comportamiento ciudadano e infracciones",
    CategoryEnum.infrastructureAccess: "Infraestructura y acceso",
    CategoryEnum.cleanEfficientMobility: "Movilidad limpia y eficiente",
    CategoryEnum.userExperience: "Experiencia de usuario",
  };

  static const Map<CategoryEnum, String> _colors = {
    CategoryEnum.genderMobilityInclusive: "0xFFFF7043",
    CategoryEnum.roadSafety: "0xFFFFB74D",
    CategoryEnum.citizenBehavior: "0xFFCDDC39",
    CategoryEnum.infrastructureAccess: "0xFF66BB6A",
    CategoryEnum.cleanEfficientMobility: "0xFF388E3C",
    CategoryEnum.userExperience: "0xFF398E3C",
  };

  String get title => _titles[this]!;

  Color get color => Color(int.parse(_colors[this]!));

  Widget buildBody(ServerOriginal model) {
    switch (this) {
      case CategoryEnum.genderMobilityInclusive:
        return ListView(
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              spacing: 0,
              children: [
                MonthlyReportChart(
                  reports: model.reports.where((value) => value.categoryId == 52).toList(),
                  title: "Número de reportes de acoso sexual",
                ),
                StopFeaturesChart(
                  stops: model.stops,
                  title: "Número de estaciones y paraderos accesibles a personas con movilidad reducida",
                ),
                MonthlyReportChart(
                  reports: model.reports.where((value) => value.categoryId == 72 || value.categoryId == 73).toList(),
                  title: "Número de reportes de barreras de accesibilidad en el TPU",
                ),
                MonthlyReportChart(
                  reports: model.reports
                      .where(
                        (value) => value.categoryId == 74 || value.categoryId == 75 || value.categoryId == 76,
                      )
                      .toList(),
                  title: "Número de reportes de discriminación en el transporte público por tipo",
                ),
              ],
            ),
          ],
        );
      case CategoryEnum.roadSafety:
        return ListView(
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              spacing: 0,
              children: [
                ReportPieChart(
                  title: "Número y ubicación de reportes de incidentes viales por tipo y severidad",
                  reports: model.reports,
                  categories: model.categories,
                )
              ],
            ),
          ],
        );
      case CategoryEnum.citizenBehavior:
        return Container();
      case CategoryEnum.infrastructureAccess:
        return Container();
      case CategoryEnum.cleanEfficientMobility:
        return Container();
      case CategoryEnum.userExperience:
        return Container();
      default:
        return Container();
    }
  }
}

class GenderBoard {
  final LatLng latLng;
  final bool isMen;

  GenderBoard({required this.latLng, required this.isMen});
}

class StatsViewer extends StatefulWidget {
  const StatsViewer({super.key});

  @override
  StatsViewerState createState() => StatsViewerState();
}

List<Report> filterReports({required ServerOriginal helper, required ModelRequest model}) {
  var categories = [
    ...(model.categories.value ?? []),
    ...(model.subCategories.value ?? []),
  ];
  if (categories.isEmpty) {
    categories = helper.allCategories.map((value) => value.id.toString()).toList();
  }
  var actors = model.actors.value ?? [];
  if (actors.isEmpty) {
    actors = helper.actors.map((value) => value.id.toString()).toList();
  }
  DateTimeRange? dateRange = model.dateRange.value;
  return helper.reports.where((value) {
    final hasCategory = categories.contains(value.categoryId.toString());
    final hasActor = actors.contains(value.involvedActorId.toString());
    bool inDateRange = true;
    final reportDate = value.reportDate;
    if (dateRange != null) {
      if (reportDate != null) {
        inDateRange = reportDate.isAfter(dateRange.start) && reportDate.isBefore(dateRange.end);
      } else {
        inDateRange = false;
      }
    }

    return hasCategory && hasActor && inDateRange;
  }).toList();
}

class StatsViewerState extends State<StatsViewer> {
  final List<CategoryEnum> categories = CategoryEnum.values;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Estadísticas de movilidad',
          style: TextStyle(color: Colors.white),
        ),
        leading: InkWell(
          onTap: () {
            context.go("/");
          },
          child: const Icon(
            Icons.bar_chart,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(153, 17, 81, 134),
                    Color.fromARGB(125, 0, 0, 0),
                  ],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: FormRequestManager<Never, ModelRequest, ServerOriginal>(
                id: null,
                fromScratch: ModelRequest.fromScratch,
                loadModel: (_) => throw "should not happen never loadModel",
                fromResponse: (_) => throw "should not happen never loadModel",
                loadExtraModel: () async {
                  final response = await Future.wait([
                    ApiServices.getAllCategories(),
                    ApiServices.getAllActors(),
                    ApiServices.getAllReports(),
                  ]);
                  final allCategories = response[0] as List<Category>;
                  final categoriesMap = Map.fromEntries(
                    allCategories.where((value) => value.parentId == null).map((value) => MapEntry(value.id, value)),
                  );
                  allCategories.where((value) => value.parentId != null).forEach((value) {
                    categoriesMap[value.parentId]?.subcategories.add(value);
                  });
                  var heatMapData = await rootBundle.loadString('assets/mapa_de_calor.geojson');

                  final data = (jsonDecode(heatMapData)['features'] as List).map((feature) {
                    final coords = feature['geometry']['coordinates'];
                    final name = (feature['properties']['name']?.toString() ?? "").toLowerCase();
                    final latlng = LatLng(coords[1], coords[0]);
                    return GenderBoard(latLng: latlng, isMen: name.contains("hombre"));
                  }).toList();
                  var stopsData = await rootBundle.loadString('assets/stops.geojson');
                  final stops = (jsonDecode(stopsData)['features'] as List).map((feature) => GeoFeature.fromJson(feature)).toList();

                  return ServerOriginal(
                    allCategories: allCategories,
                    categories: categoriesMap,
                    actors: response[1] as List<VialActor>,
                    reports: response[2] as List<Report>,
                    data: data,
                    stops: stops,
                  );
                },
                saveModel: (_, {id}) async => {},
                onSaveChanges: () => {},
                builder: (params) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: categories.map((category) {
                              return SizedBox(
                                width: 250,
                                height: 200,
                                child: GestureDetector(
                                  onTap: () {
                                    _showFullScreenPopup(context, category.title, child: category.buildBody(params.responseModel.responseHelper!));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: category.color,
                                    ),
                                    child: Center(
                                      child: Text(
                                        category.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

void _showFullScreenPopup(
  BuildContext context,
  String title, {
  required Widget child,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent, // Para que no haya bordes alrededor
        child: Container(
          width: MediaQuery.of(context).size.width, // Ocupa todo el ancho de la pantalla
          height: MediaQuery.of(context).size.height, // Ocupa todo el alto de la pantalla
          decoration: BoxDecoration(
            color: Colors.white, // Color del fondo
            borderRadius: BorderRadius.circular(10), // Ajuste opcional para esquinas redondeadas
          ),
          child: Column(
            children: [
              // Título del popup
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Cerrar el popup
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              // Aquí puedes agregar más contenido
              Expanded(
                child: child,
              ),
            ],
          ),
        ),
      );
    },
  );
}

class ReportPieChart extends StatefulWidget {
  final List<Report> reports;
  final Map<int, Category> categories;
  final String title;
  ReportPieChart({
    required this.reports,
    required this.categories,
    required this.title,
  });

  @override
  State<ReportPieChart> createState() => _ReportPieChartState();
}

class _ReportPieChartState extends State<ReportPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            widget.title,
            style: const TextStyle(fontSize: 30),
          ),
          Container(
            height: 500,
            child: Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                final shortesSide = constraints.biggest.shortestSide;
                return PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    sectionsSpace: 0,
                    centerSpaceRadius: 20,
                    sections: showingSections(shortesSide / 2.5),
                  ),
                );
              }),
            ),
          ),
          Column(
            children: widget.categories.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Indicator(
                  color: entry.value.color, // Utiliza el color de la categoría
                  text: entry.value.categoryName ?? 'Unknown',
                  isSquare: true,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(double shortesSide) {
    Map<int, int> categoryCounts = {};
    for (var report in widget.reports) {
      int? subCategoryId = report.categoryId;
      Category? category = widget.categories[subCategoryId];
      if (category == null) {
        for (final categoryItem in widget.categories.values) {
          for (final subCategory in categoryItem.subcategories) {
            if (subCategory.id == subCategoryId) {
              category = categoryItem;
              break;
            }
          }
          if (category != null) break;
        }
      }
      if (category != null) {
        int mainCategoryId = category.parentId ?? category.id;
        categoryCounts[mainCategoryId] = (categoryCounts[mainCategoryId] ?? 0) + 1;
      }
    }

    int index = 0;
    return categoryCounts.entries.map((entry) {
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? shortesSide + 10 : shortesSide;
      final double percentage = entry.value.toDouble() / widget.reports.length * 100;
      index++;

      return PieChartSectionData(
        color: widget.categories[entry.key]?.color ?? Colors.grey, // Utiliza el color de la categoría o gris por defecto
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [const Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    }).toList();
  }
}

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}

class MonthlyReportChart extends StatefulWidget {
  final List<Report> reports;
  final String title;

  MonthlyReportChart({required this.reports, required this.title});

  @override
  _MonthlyReportChartState createState() => _MonthlyReportChartState();
}

class _MonthlyReportChartState extends State<MonthlyReportChart> {
  late Map<int, Map<int, int>> reportCountsByYear; // year -> month -> count
  late Map<int, Map<int, Map<int, int>>> reportCountsByDay; // year -> month -> day -> count
  int selectedYear = DateTime.now().year;
  int? selectedMonth;
  bool showingDays = false;

  @override
  void initState() {
    super.initState();
    _calculateReportCounts();
  }

  void _calculateReportCounts() {
    reportCountsByYear = {};
    reportCountsByDay = {};

    for (var report in widget.reports) {
      if (report.reportDate != null) {
        int year = report.reportDate!.year;
        int month = report.reportDate!.month;
        int day = report.reportDate!.day;

        // Conteo por año y mes
        if (!reportCountsByYear.containsKey(year)) {
          reportCountsByYear[year] = {};
        }
        if (!reportCountsByYear[year]!.containsKey(month)) {
          reportCountsByYear[year]![month] = 0;
        }
        reportCountsByYear[year]![month] = reportCountsByYear[year]![month]! + 1;

        // Conteo por día
        if (!reportCountsByDay.containsKey(year)) {
          reportCountsByDay[year] = {};
        }
        if (!reportCountsByDay[year]!.containsKey(month)) {
          reportCountsByDay[year]![month] = {};
        }
        if (!reportCountsByDay[year]![month]!.containsKey(day)) {
          reportCountsByDay[year]![month]![day] = 0;
        }
        reportCountsByDay[year]![month]![day] = reportCountsByDay[year]![month]![day]! + 1;
      }
    }

    if (!reportCountsByYear.containsKey(selectedYear)) {
      selectedYear = reportCountsByYear.keys.isNotEmpty ? reportCountsByYear.keys.first : DateTime.now().year;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 30),
          ),
          Container(
            // width: 800,
            height: 500,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color.fromARGB(255, 206, 206, 206), borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (showingDays)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            showingDays = false; // Regresa a la vista de meses
                          });
                        },
                        child: const Text('Volver a meses'),
                      ),
                    DropdownButton<int>(
                      value: selectedYear,
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedYear = newValue!;
                          showingDays = false; // Regresa a la vista mensual cuando se cambia el año
                        });
                      },
                      items: reportCountsByYear.keys.map<DropdownMenuItem<int>>((int year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text('$year'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barGroups: showingDays ? _buildDayBarGroups() : _buildMonthBarGroups(),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false), // Oculta el eje superior
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                if (showingDays) {
                                  // Mostrar días del mes
                                  return Text(value.toInt().toString());
                                } else {
                                  const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
                                  return InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (!showingDays) {
                                            selectedMonth = value.toInt();
                                            showingDays = true; // Cambia a la vista de días al hacer clic en un mes
                                          }
                                        });
                                      },
                                      child: Text(months[value.toInt() - 1]));
                                }
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              interval: 1,
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                return Text(
                                  value.toInt().toString(), // Muestra solo enteros
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16, // Ajusta el tamaño de la fuente
                                    fontWeight: FontWeight.bold, // Aumenta el grosor
                                  ),
                                );
                              },
                              reservedSize: 40, // Aumenta el ancho de la barra izquierda
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: const FlGridData(show: false), // Oculta las líneas de cuadrícula
                        // barTouchData: BarTouchData(
                        //   touchCallback: (FlTouchEvent event, barTouchResponse) {
                        //     if (!event.isInterestedForInteractions || barTouchResponse == null || barTouchResponse.spot == null) {
                        //       return;
                        //     }
                        //     setState(() {
                        //       if (!showingDays) {
                        //         selectedMonth = barTouchResponse.spot!.touchedBarGroup.x.toInt();
                        //         showingDays = true; // Cambia a la vista de días al hacer clic en un mes
                        //       }
                        //     });
                        //   },
                        // ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildMonthBarGroups() {
    final monthCounts = reportCountsByYear[selectedYear] ?? {};

    return List.generate(12, (index) {
      int month = index + 1;
      int count = monthCounts[month] ?? 0;
      return BarChartGroupData(
        x: month,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: Colors.blue,
            width: 16,
          )
        ],
      );
    });
  }

  List<BarChartGroupData> _buildDayBarGroups() {
    if (selectedMonth == null) return [];

    final dayCounts = reportCountsByDay[selectedYear]?[selectedMonth!] ?? {};

    int daysInMonth = DateTime(selectedYear, selectedMonth! + 1, 0).day;

    return List.generate(daysInMonth, (index) {
      int day = index + 1;
      int count = dayCounts[day] ?? 0;
      return BarChartGroupData(
        x: day,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: Colors.blue,
            width: 16,
          )
        ],
      );
    });
  }
}

class StopFeaturesChart extends StatelessWidget {
  final List<GeoFeature> stops;
  final String title;

  StopFeaturesChart({required this.stops, required this.title});

  @override
  Widget build(BuildContext context) {
    final featurePercentages = _calculateFeaturePercentages(stops);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        for (var feature in featurePercentages.keys) _buildFeatureBar(feature, featurePercentages[feature]!),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 230),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(11, (index) {
              // Calcula los porcentajes desde 0% a 100%
              int percentage = index * 10;
              return Text(
                '$percentage%',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              );
            }),
          ),
        )
      ],
    );
  }

  Map<String, Map<String, double>> _calculateFeaturePercentages(List<GeoFeature> stops) {
    final featureCounts = {
      'Advertising': {'yes': 0, 'no': 0, 'unknown': 0},
      'Bench': {'yes': 0, 'no': 0, 'unknown': 0},
      'Bicycle Parking': {'yes': 0, 'no': 0, 'unknown': 0},
      'Bin': {'yes': 0, 'no': 0, 'unknown': 0},
      'Lit': {'yes': 0, 'no': 0, 'unknown': 0},
      'Ramp': {'yes': 0, 'no': 0, 'unknown': 0},
      'Shelter': {'yes': 0, 'no': 0, 'unknown': 0},
      'Level': {'yes': 0, 'no': 0, 'unknown': 0},
      'Passenger Info Display': {'yes': 0, 'no': 0, 'unknown': 0},
      'Tactile Writing Braille': {'yes': 0, 'no': 0, 'unknown': 0},
      'Tactile Paving': {'yes': 0, 'no': 0, 'unknown': 0},
      'Departures Board': {'yes': 0, 'no': 0, 'unknown': 0},
    };

    for (var stop in stops) {
      _updateFeatureCount(stop.advertising, featureCounts['Advertising']!);
      _updateFeatureCount(stop.bench, featureCounts['Bench']!);
      _updateFeatureCount(stop.bicycleParking, featureCounts['Bicycle Parking']!);
      _updateFeatureCount(stop.bin, featureCounts['Bin']!);
      _updateFeatureCount(stop.lit, featureCounts['Lit']!);
      _updateFeatureCount(stop.ramp, featureCounts['Ramp']!);
      _updateFeatureCount(stop.shelter, featureCounts['Shelter']!);
      _updateFeatureCount(stop.level, featureCounts['Level']!);
      _updateFeatureCount(stop.passengerInformationDisplaySpeechOutput, featureCounts['Passenger Info Display']!);
      _updateFeatureCount(stop.tactileWritingBrailleEs, featureCounts['Tactile Writing Braille']!);
      _updateFeatureCount(stop.tactilePaving, featureCounts['Tactile Paving']!);
      _updateFeatureCount(stop.departuresBoard, featureCounts['Departures Board']!);
    }

    final featurePercentages = <String, Map<String, double>>{};
    for (var feature in featureCounts.keys) {
      var total = stops.length;
      var yes = featureCounts[feature]!['yes']! / total * 100;
      var no = featureCounts[feature]!['no']! / total * 100;
      var unknown = featureCounts[feature]!['unknown']! / total * 100;

      featurePercentages[feature] = {
        'yes': yes,
        'no': no,
        'unknown': unknown,
      };
    }

    return featurePercentages;
  }

  void _updateFeatureCount(bool? featureValue, Map<String, int> countMap) {
    if (featureValue == null) {
      countMap['unknown'] = countMap['unknown']! + 1;
    } else if (featureValue) {
      countMap['yes'] = countMap['yes']! + 1;
    } else {
      countMap['no'] = countMap['no']! + 1;
    }
  }

  Widget _buildFeatureBar(String feature, Map<String, double> percentages) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
      child: Row(
        children: [
          Container(
            width: 200,
            margin: const EdgeInsets.only(right: 10),
            child: Text(
              _translateFeature(feature),
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildBarSegment(percentages['yes']!, Colors.blue),
                _buildBarSegment(percentages['no']!, Colors.red),
                _buildBarSegment(percentages['unknown']!, const Color.fromARGB(255, 239, 197, 28)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _translateFeature(String feature) {
    // Mapa que traduce los nombres de las características al español
    const Map<String, String> featureTranslationMap = {
      'Advertising': 'Panel Publicidad',
      'Bench': 'Tiene Banco',
      'Bicycle Parking': 'Tiene Aparcabici',
      'Bin': 'Tiene Tacho',
      'Lit': 'Iluminacion',
      'Ramp': 'Rampas Acera',
      'Shelter': 'Tiene Techo',
      'Level': 'Acceso Nivel',
      'Passenger Info Display': 'Guia Sonora',
      'Tactitle Writing Braille': 'Señal Braille',
      'Tactile Paving': 'Guia Podotactil',
      'Departure Board': 'Info Rutas',
    };

    // Retorna la traducción correspondiente o el texto original si no se encuentra
    return featureTranslationMap[feature] ?? feature;
  }

  Widget _buildBarSegment(double percentage, Color color) {
    return Expanded(
      flex: percentage.round(),
      child: Container(
        height: 20,
        color: color,
        // child: Text('${percentage.toStringAsFixed(1)}%'),
      ),
    );
  }
}
