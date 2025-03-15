import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:omus/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';
import 'package:omus/services/models/category.dart';
import 'package:omus/services/models/report.dart';
import 'package:omus/services/models/vial_actor.dart';
import 'package:omus/stations.dart';
import 'package:omus/stats_viewer.dart';
import 'package:omus/widgets/components/dropdown/helpers/dropdown_item.dart';
import 'package:omus/widgets/components/dropdown/multi_select_dropdown.dart';
import 'package:omus/widgets/components/helpers/form_loading_helper_new.dart';
import 'package:omus/widgets/components/helpers/responsive_container.dart';
import 'package:omus/widgets/components/textfield/form_request_date_range_field.dart';
import 'package:omus/widgets/components/checkbox/custom_checkbox.dart';
import 'package:omus/main.dart';
import 'package:omus/widgets/components/textfield/form_request_field.dart';

class ModelRequest extends FormRequest {
  ModelRequest({
    required this.categories,
    required this.subCategories,
    required this.actors,
    required this.dateRange,
  });

  factory ModelRequest.fromScratch() => ModelRequest(
        categories: FormItemContainer<List<String>>(fieldKey: "categories", value: []),
        subCategories: FormItemContainer<List<String>>(fieldKey: "subCategories", value: []),
        actors: FormItemContainer<List<String>>(fieldKey: "actors", value: []),
        dateRange: FormItemContainer<DateTimeRange>(fieldKey: "dateRange"),
      );

  final FormItemContainer<List<String>> categories;
  final FormItemContainer<List<String>> subCategories;
  final FormItemContainer<List<String>> actors;
  final FormItemContainer<DateTimeRange> dateRange;
}

class ServerOriginal {
  final Map<int, Category> categories;
  final List<Category> allCategories;
  final List<VialActor> actors;
  List<Report> reports;
  final List<GenderBoard> data;
  final List<GeoFeature> stops;
  final List<Station> stations;
  ServerOriginal({
    required this.categories,
    required this.allCategories,
    required this.actors,
    required this.reports,
    required this.data,
    required this.stops,
    required this.stations,
  });
}

class ImageManagerScreen extends StatelessWidget {
  const ImageManagerScreen({super.key});
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
          var stationsData = await rootBundle.loadString('assets/merged_stations.json');
          final stations = (jsonDecode(stationsData) as List).map((feature) => Station.fromJson(feature)).toList();
          var reports = response[2] as List<Report>;
          reports = reports.where((element) => (element.images?.length == 1) && (element.images!.first.trim().isNotEmpty)).toList();

          return ServerOriginal(
            allCategories: allCategories,
            categories: categoriesMap,
            actors: response[1] as List<VialActor>,
            reports: reports.reversed.toList(),
            data: data,
            stops: stops,
            stations: stations,
          );
        },
        saveModel: (_, {id}) async {},
        onSaveChanges: () {},
        builder: (params) {
          final helper = params.responseModel.responseHelper!;
          final model = params.model;

          List<Report> filteredReports = filterReports(model: model, helper: params.responseModel.responseHelper!);

          return Scaffold(
            appBar: AppBar(title: const Text("Administrar Imágenes")),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomResponsiveContainer(
                    children: [
                      CustomResponsiveItem.small(
                        child: FormRequestMultiSelectField(
                          update: model.update,
                          field: model.categories,
                          label: "Categorias",
                          items: helper.categories.values.map((e) => DropdownItem(id: e.id.toString(), text: e.categoryName.toString())).toList(),
                          enabled: true,
                        ),
                      ),
                      CustomResponsiveItem.small(
                        child: FormRequestMultiSelectField(
                          update: model.update,
                          field: model.subCategories,
                          label: "Sub-Categorias",
                          items: helper.allCategories
                              .where((value) => model.categories.value?.contains(value.parentId.toString()) ?? false)
                              .map((e) => DropdownItem(id: e.id.toString(), text: e.categoryName.toString()))
                              .toList(),
                          enabled: true,
                        ),
                      ),
                      CustomResponsiveItem.small(
                        child: FormRequestMultiSelectField(
                          update: model.update,
                          field: model.actors,
                          label: "Actores viales",
                          items: helper.actors.map((e) => DropdownItem(id: e.id.toString(), text: e.name.toString())).toList(),
                          enabled: true,
                        ),
                      ),
                      CustomResponsiveItem.small(
                        child: FormDateRangePickerField(
                          update: model.update,
                          label: "Rango de fechas",
                          field: model.dateRange,
                          enabled: true,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  child: const Text("Limpiar filtro"),
                  onPressed: () {
                    model.update(() {
                      model.categories.value = null;
                      model.subCategories.value = null;
                      model.actors.value = null;
                      model.dateRange.value = null;
                    });
                  },
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      var report = filteredReports[index];
                      String image = report.images!.first;

                      return Card(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: InstaImageViewer(
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: 'https://omus.tmt.gob.pe/api/Categories/proxy?url=${Uri.encodeComponent(image)}',
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  params.asyncHelperParams.runAsync(() async {
                                    await ApiServices.deleteAllReportImages(report.id);
                                    params.model.update(() {
                                      params.responseModel.responseHelper!.reports.removeWhere((element) => element.id == report.id);
                                    });
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
