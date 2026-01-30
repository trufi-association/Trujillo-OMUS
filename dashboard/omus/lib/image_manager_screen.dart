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
import 'package:omus/core/utils/map_utils.dart';
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
      bool inDateRange = true;
      final reportDate = value.reportDate;
      if (dateRange != null) {
        if (reportDate != null) {
          inDateRange = reportDate.isAfter(dateRange.start) && reportDate.isBefore(dateRange.end);
        } else {
          inDateRange = false;
        }
      }

      return hasCategory && inDateRange;
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
          // reports = reports.where((element) => (element.images?.length == 1) && (element.images!.first.trim().isNotEmpty)).toList();

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
                      // CustomResponsiveItem.small(
                      //   child: FormRequestMultiSelectField(
                      //     update: model.update,
                      //     field: model.actors,
                      //     label: "Actores viales",
                      //     items: helper.actors.map((e) => DropdownItem(id: e.id.toString(), text: e.name.toString())).toList(),
                      //     enabled: true,
                      //   ),
                      // ),
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
                      maxCrossAxisExtent: 300,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: .7,
                    ),
                    itemCount: filteredReports.length,
                    itemBuilder: (context, index) {
                      var report = filteredReports[index];
                      String? image = (report.images?.length == 1 && report.images!.first.trim().isNotEmpty) ? report.images!.first.trim() : null;

                      return Container(
                        // padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (image != null)
                                      InstaImageViewer(
                                        child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl: 'https://omus.tmt.gob.pe/api/Categories/proxy?url=${Uri.encodeComponent(image)}',
                                        ),
                                      )
                                    else
                                      Container(
                                        color: Colors.grey.shade200,
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: IconButton(
                                        icon: Icon(Icons.delete, color: image != null ? Colors.red : Colors.grey),
                                        onPressed: image != null
                                            ? () {
                                                params.asyncHelperParams.runAsync(() async {
                                                  await ApiServices.deleteAllReportImages(report.id);
                                                  params.model.update(() {
                                                    report.images = null;
                                                  });
                                                });
                                              }
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              report.description ?? "Sin descripción",
                                              // maxLines: 2,
                                              // overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          if (report.reportDate != null)
                                            Text(
                                              "Fecha: ${DateFormat('dd/MM/yyyy').format(report.reportDate!)}",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.visibility, color: Colors.blue.shade400),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.all(16),
                                                        child: SingleChildScrollView(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              RichText(
                                                                text: TextSpan(
                                                                  children: [
                                                                    const TextSpan(
                                                                      text: 'ID: ',
                                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                                                    ),
                                                                    TextSpan(
                                                                      text: '${report.id}',
                                                                      style: const TextStyle(fontSize: 16, color: Colors.black),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(height: 8.0),
                                                              RichText(
                                                                text: TextSpan(
                                                                  children: [
                                                                    const TextSpan(
                                                                      text: 'Categoría: ',
                                                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                                                    ),
                                                                    TextSpan(
                                                                      text: helper.allCategories
                                                                              .findOrNull((value) => value.id == report.categoryId)
                                                                              ?.categoryName ??
                                                                          "-",
                                                                      style: const TextStyle(fontSize: 14, color: Colors.black),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(height: 4.0),
                                                              RichText(
                                                                text: TextSpan(
                                                                  children: [
                                                                    const TextSpan(
                                                                      text: 'Actor involucrado: ',
                                                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                                                    ),
                                                                    TextSpan(
                                                                      text:
                                                                          helper.actors.findOrNull((value) => value.id == report.involvedActorId)?.name ?? "-",
                                                                      style: const TextStyle(fontSize: 14, color: Colors.black),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(height: 4.0),
                                                              RichText(
                                                                text: TextSpan(
                                                                  children: [
                                                                    const TextSpan(
                                                                      text: 'Víctima: ',
                                                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                                                    ),
                                                                    TextSpan(
                                                                      text: helper.actors.findOrNull((value) => value.id == report.victimActorId)?.name ?? "-",
                                                                      style: const TextStyle(fontSize: 14, color: Colors.black),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(height: 4.0),
                                                              RichText(
                                                                text: TextSpan(
                                                                  children: [
                                                                    const TextSpan(
                                                                      text: 'Descripción: ',
                                                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                                                    ),
                                                                    TextSpan(
                                                                      text: '${report.description}',
                                                                      style: const TextStyle(fontSize: 14, color: Colors.black),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(height: 4.0),
                                                              RichText(
                                                                text: TextSpan(
                                                                  children: [
                                                                    const TextSpan(
                                                                      text: 'Fecha: ',
                                                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                                                    ),
                                                                    TextSpan(
                                                                      text: DateFormat('yyyy-MM-dd kk:mm')
                                                                          .format(report.reportDate!.add(DateTime.now().timeZoneOffset)),
                                                                      style: const TextStyle(fontSize: 14, color: Colors.black),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        right: 0,
                                                        child: IconButton(
                                                          icon: const Icon(Icons.close),
                                                          onPressed: () => Navigator.of(context).pop(),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red.shade400),
                                          onPressed: () {
                                            params.asyncHelperParams.runAsync(() async {
                                              await ApiServices.deleteReport(report.id);
                                              params.model.update(() {
                                                params.responseModel.responseHelper!.reports.removeWhere((element) => element.id == report.id);
                                              });
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
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
