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

enum FeatureType {
  advertising,
  bench,
  bicycleParking,
  bin,
  lit,
  ramp,
  shelter,
}

extension FeatureTypeExtension on FeatureType {
  static const Map<FeatureType, String> _featureTypeMap = {
    FeatureType.advertising: 'advertising',
    FeatureType.bench: 'bench',
    FeatureType.bicycleParking: 'bicycleParking',
    FeatureType.bin: 'bin',
    FeatureType.lit: 'lit',
    FeatureType.ramp: 'ramp',
    FeatureType.shelter: 'shelter',
  };

  String toValue() => _featureTypeMap[this]!;

  static FeatureType fromValue(String value) => _featureTypeMap.entries.firstWhere((entry) => entry.value == value).key;
  static const Map<FeatureType, String> _featureTypeSpanishMap = {
    FeatureType.advertising: 'Publicidad',
    FeatureType.bench: 'Banco',
    FeatureType.bicycleParking: 'Estacionamiento para bicicletas',
    FeatureType.bin: 'Papelera',
    FeatureType.lit: 'Iluminado',
    FeatureType.ramp: 'Rampa',
    FeatureType.shelter: 'Refugio',
  };
  String toText() => _featureTypeSpanishMap[this]!;
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
  final bool advertising;
  final bool bench;
  final bool bicycleParking;
  final bool bin;
  final bool lit;
  final bool ramp;
  final bool shelter;

  GeoFeature({
    required this.coordinates,
    required this.advertising,
    required this.bench,
    required this.bicycleParking,
    required this.bin,
    required this.lit,
    required this.ramp,
    required this.shelter,
  });

  factory GeoFeature.fromJson(Map<String, dynamic> json) {
    final coords = json['geometry']['coordinates'];
    final latLng = LatLng(coords[1], coords[0]);
    final properties = json['properties'];

    return GeoFeature(
      coordinates: latLng,
      advertising: properties['advertising'] == 'yes',
      bench: properties['bench'] == 'yes',
      bicycleParking: properties['bicycle_parking'] == 'yes',
      bin: properties['bin'] == 'yes',
      lit: properties['lit'] == 'yes',
      ramp: properties['ramp'] == 'yes',
      shelter: properties['shelter'] == 'yes',
    );
  }
}

enum CategoryEnum {
  genderMobilityInclusive,
  roadSafety,
  citizenBehavior,
  infrastructureAccess,
  cleanEfficientMobility,
}

extension CategoryExtension on CategoryEnum {
  static const Map<CategoryEnum, String> _titles = {
    CategoryEnum.genderMobilityInclusive: "Género y movilidad inclusiva",
    CategoryEnum.roadSafety: "Seguridad vial",
    CategoryEnum.citizenBehavior: "Comportamiento ciudadano e infracciones",
    CategoryEnum.infrastructureAccess: "Infraestructura y acceso",
    CategoryEnum.cleanEfficientMobility: "Movilidad limpia y eficiente",
  };

  static const Map<CategoryEnum, String> _colors = {
    CategoryEnum.genderMobilityInclusive: "0xFFFF7043",
    CategoryEnum.roadSafety: "0xFFFFB74D",
    CategoryEnum.citizenBehavior: "0xFFCDDC39",
    CategoryEnum.infrastructureAccess: "0xFF66BB6A",
    CategoryEnum.cleanEfficientMobility: "0xFF388E3C",
  };

  String get title => _titles[this]!;

  Color get color => Color(int.parse(_colors[this]!));

  Widget buildBody(ServerOriginal model) {
    // switch (this) {
    //   case CategoryEnum.genderMobilityInclusive:
    return ListView(
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          spacing: 0,
          children: [
            MonthlyReportChart(
              reports: model.reports,
              title: "Número de reportes de acoso sexual",
            ),
            MonthlyReportChart(
              reports: model.reports,
              title: "Número de reportes de barreras de accesibilidad en el TPU",
            ),
            MonthlyReportChart(
              reports: model.reports,
              title: "Número de reportes de discriminación en el transporte público por tipo",
            ),
          ],
        ),
      ],
    );
    // case CategoryEnum.roadSafety:
    //   return Container();
    // case CategoryEnum.citizenBehavior:
    //   return Container();
    // case CategoryEnum.infrastructureAccess:
    //   return Container();
    // case CategoryEnum.cleanEfficientMobility:
    //   return Container();
    // default:
    //   return Container();
    // }
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
        leading: const Icon(
          Icons.bar_chart,
          color: Colors.white,
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
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Cerrar el popup
                      },
                      icon: Icon(Icons.close),
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
  final Map<int, Category> categories; // Mapa de categorías principales
  final void Function() onClose;
  ReportPieChart({
    required this.reports,
    required this.categories,
    required this.onClose,
  });

  @override
  State<ReportPieChart> createState() => _ReportPieChartState();
}

class _ReportPieChartState extends State<ReportPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Color de fondo blanco
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ), // Bordes redondeados
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Color de sombra con opacidad
            spreadRadius: 5, // Extensión de la sombra
            blurRadius: 10, // Difuminado de la sombra
            offset: Offset(0, 3), // Desplazamiento de la sombra (x, y)
          ),
        ],
      ),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: Text(
                  "Estadisticas de reportes", // Cambia "Título Bonito" por el texto que desees
                  style: TextStyle(
                    fontSize: 30, // Tamaño de fuente mayor para hacerlo destacar
                    fontWeight: FontWeight.bold, // Negrita para más énfasis
                    color: Colors.blue, // Color azul o el que prefieras
                  ),
                ),
              ),
              IconButton(
                  onPressed: widget.onClose,
                  icon: Icon(
                    Icons.close,
                    size: 30,
                  )),
            ],
          ),
          Expanded(
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
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
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
      margin: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(fontSize: 30),
          ),
          Container(
            width: 800,
            height: 500,
            padding: EdgeInsets.all(10),
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
                        child: Text('Volver a meses'),
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
                          topTitles: AxisTitles(
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
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16, // Ajusta el tamaño de la fuente
                                    fontWeight: FontWeight.bold, // Aumenta el grosor
                                  ),
                                );
                              },
                              reservedSize: 40, // Aumenta el ancho de la barra izquierda
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(show: false), // Oculta las líneas de cuadrícula
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
