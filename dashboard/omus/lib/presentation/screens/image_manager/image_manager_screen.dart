import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:omus/core/extensions/list_extensions.dart';
import 'package:omus/data/models/filter_request.dart';
import 'package:omus/data/models/map_data_container.dart';
import 'package:omus/domain/usecases/filter_reports_usecase.dart';
import 'package:omus/env.dart';
import 'package:omus/geojson_models.dart';
import 'package:omus/services/api_service.dart';
import 'package:omus/services/models/category.dart';
import 'package:omus/services/models/report.dart';
import 'package:omus/services/models/vial_actor.dart';
import 'package:omus/stations.dart';
import 'package:omus/widgets/components/dropdown/helpers/dropdown_item.dart';
import 'package:omus/widgets/components/dropdown/multi_select_dropdown.dart';
import 'package:omus/widgets/components/helpers/form_loading_helper_new.dart';
import 'package:omus/widgets/components/helpers/responsive_container.dart';
import 'package:omus/widgets/components/textfield/form_request_date_range_field.dart';
import 'package:omus/widgets/components/textfield/form_request_field.dart';

/// Screen for managing report images.
class ImageManagerScreen extends StatelessWidget {
  const ImageManagerScreen({super.key});

  final FilterReportsUsecase _filterReportsUsecase = const FilterReportsUsecase();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FormRequestManager<Never, FilterRequest, MapDataContainer>(
        id: null,
        fromScratch: FilterRequest.fromScratch,
        loadModel: (_) => throw 'should not happen never loadModel',
        fromResponse: (_) => throw 'should not happen never loadModel',
        loadExtraModel: _loadData,
        saveModel: (_, {id}) async {},
        onSaveChanges: () {},
        builder: (params) {
          final helper = params.responseModel.responseHelper!;
          final model = params.model;

          final filteredReports = _filterReportsUsecase(
            reports: helper.reports,
            allCategories: helper.allCategories,
            actors: helper.actors,
            selectedCategories: model.categories.value,
            selectedSubCategories: model.subCategories.value,
            selectedActors: model.actors.value,
            dateRange: model.dateRange.value,
          );

          return Scaffold(
            body: Column(
              children: [
                _buildFilterBar(model, helper),
                _buildClearButton(model),
                Expanded(
                  child: _buildImageGrid(
                    context,
                    filteredReports,
                    helper,
                    params,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<MapDataContainer> _loadData() async {
    final response = await Future.wait([
      ApiServices.getAllCategories(),
      ApiServices.getAllActors(),
      ApiServices.getAllReports(),
    ]);

    final allCategories = response[0] as List<Category>;
    final categoriesMap = Map.fromEntries(
      allCategories
          .where((value) => value.parentId == null)
          .map((value) => MapEntry(value.id, value)),
    );
    allCategories
        .where((value) => value.parentId != null)
        .forEach((value) {
      categoriesMap[value.parentId]?.subcategories.add(value);
    });

    final heatMapData =
        await rootBundle.loadString('assets/mapa_de_calor.geojson');
    final genderData =
        (jsonDecode(heatMapData)['features'] as List).map((feature) {
      final coords = feature['geometry']['coordinates'];
      final name =
          (feature['properties']['name']?.toString() ?? '').toLowerCase();
      final latlng = LatLng(coords[1], coords[0]);
      return GenderBoard(latLng: latlng, isMen: name.contains('hombre'));
    }).toList();

    final stopsData = await rootBundle.loadString('assets/stops.geojson');
    final stops = (jsonDecode(stopsData)['features'] as List)
        .map((feature) => GeoFeature.fromJson(feature))
        .toList();

    final stationsData =
        await rootBundle.loadString('assets/merged_stations.json');
    final stations = (jsonDecode(stationsData) as List)
        .map((feature) => Station.fromJson(feature))
        .toList();

    final reports = (response[2] as List<Report>).reversed.toList();

    return MapDataContainer(
      allCategories: allCategories,
      categories: categoriesMap,
      actors: response[1] as List<VialActor>,
      reports: reports,
      genderData: genderData,
      stops: stops,
      stations: stations,
      sittRoutes: {},
      regulatedRoutes: {},
      ptpuFeatures: [],
    );
  }

  Widget _buildFilterBar(FilterRequest model, MapDataContainer helper) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomResponsiveContainer(
        children: [
          CustomResponsiveItem.small(
            child: FormRequestMultiSelectField(
              update: model.update,
              field: model.categories,
              label: 'Categorias',
              items: helper.categories.values
                  .map((e) => DropdownItem(
                        id: e.id.toString(),
                        text: e.categoryName.toString(),
                      ))
                  .toList(),
              enabled: true,
            ),
          ),
          CustomResponsiveItem.small(
            child: FormRequestMultiSelectField(
              update: model.update,
              field: model.subCategories,
              label: 'Sub-Categorias',
              items: helper.allCategories
                  .where((value) =>
                      model.categories.value
                          ?.contains(value.parentId.toString()) ??
                      false)
                  .map((e) => DropdownItem(
                        id: e.id.toString(),
                        text: e.categoryName.toString(),
                      ))
                  .toList(),
              enabled: true,
            ),
          ),
          CustomResponsiveItem.small(
            child: FormDateRangePickerField(
              update: model.update,
              label: 'Rango de fechas',
              field: model.dateRange,
              enabled: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearButton(FilterRequest model) {
    return ElevatedButton(
      child: const Text('Limpiar filtro'),
      onPressed: () => model.clearFilters(),
    );
  }

  Widget _buildImageGrid(
    BuildContext context,
    List<Report> filteredReports,
    MapDataContainer helper,
    FormRequestHelperParams<Never, FilterRequest, MapDataContainer> params,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: .7,
      ),
      itemCount: filteredReports.length,
      itemBuilder: (context, index) {
        final report = filteredReports[index];
        return _ReportCard(
          report: report,
          helper: helper,
          params: params,
        );
      },
    );
  }
}

/// Card widget for displaying a single report.
class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.report,
    required this.helper,
    required this.params,
  });

  final Report report;
  final MapDataContainer helper;
  final FormRequestHelperParams<Never, FilterRequest, MapDataContainer> params;

  String? get _imageUrl {
    if (report.images?.length == 1 && report.images!.first.trim().isNotEmpty) {
      return report.images!.first.trim();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: _buildImageSection(context),
          ),
          Expanded(
            child: _buildInfoSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_imageUrl != null)
            InstaImageViewer(
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl:
                    '$apiUrl/Categories/proxy?url=${Uri.encodeComponent(_imageUrl!)}',
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
              icon: Icon(
                Icons.delete,
                color: _imageUrl != null ? Colors.red : Colors.grey,
              ),
              onPressed: _imageUrl != null ? () => _deleteImage() : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    report.description ?? 'Sin descripción',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (report.reportDate != null)
                  Text(
                    'Fecha: ${DateFormat('dd/MM/yyyy').format(report.reportDate!)}',
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
                onPressed: () => _showDetailDialog(context),
              ),
              const SizedBox(height: 8),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red.shade400),
                onPressed: _deleteReport,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _deleteImage() {
    params.asyncHelperParams.runAsync(() async {
      await ApiServices.deleteAllReportImages(report.id);
      params.model.update(() {
        report.images = null;
      });
    });
  }

  void _deleteReport() {
    params.asyncHelperParams.runAsync(() async {
      await ApiServices.deleteReport(report.id);
      params.model.update(() {
        params.responseModel.responseHelper!.reports
            .removeWhere((element) => element.id == report.id);
      });
    });
  }

  void _showDetailDialog(BuildContext context) {
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
                      _buildDetailRow('ID: ', '${report.id}'),
                      const SizedBox(height: 8.0),
                      _buildDetailRow(
                        'Categoría: ',
                        helper.allCategories
                                .findOrNull(
                                    (value) => value.id == report.categoryId)
                                ?.categoryName ??
                            '-',
                      ),
                      const SizedBox(height: 4.0),
                      _buildDetailRow(
                        'Actor involucrado: ',
                        helper.actors
                                .findOrNull(
                                    (value) => value.id == report.involvedActorId)
                                ?.name ??
                            '-',
                      ),
                      const SizedBox(height: 4.0),
                      _buildDetailRow(
                        'Víctima: ',
                        helper.actors
                                .findOrNull(
                                    (value) => value.id == report.victimActorId)
                                ?.name ??
                            '-',
                      ),
                      const SizedBox(height: 4.0),
                      _buildDetailRow(
                        'Descripción: ',
                        '${report.description}',
                      ),
                      const SizedBox(height: 4.0),
                      if (report.reportDate != null)
                        _buildDetailRow(
                          'Fecha: ',
                          DateFormat('yyyy-MM-dd kk:mm').format(
                              report.reportDate!.add(DateTime.now().timeZoneOffset)),
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
  }

  Widget _buildDetailRow(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

/// Usecase constant class for dependency injection.
class FilterReportsUsecase {
  const FilterReportsUsecase();

  List<Report> call({
    required List<Report> reports,
    required List<Category> allCategories,
    required List<VialActor> actors,
    List<String>? selectedCategories,
    List<String>? selectedSubCategories,
    List<String>? selectedActors,
    DateTimeRange? dateRange,
  }) {
    var categories = [
      ...(selectedCategories ?? []),
      ...(selectedSubCategories ?? []),
    ];

    if (categories.isEmpty) {
      categories = allCategories.map((value) => value.id.toString()).toList();
    }

    var actorIds = selectedActors ?? [];
    if (actorIds.isEmpty) {
      actorIds = actors.map((value) => value.id.toString()).toList();
    }

    return reports.where((report) {
      final hasCategory = categories.contains(report.categoryId.toString());

      bool inDateRange = true;
      final reportDate = report.reportDate;
      if (dateRange != null) {
        if (reportDate != null) {
          inDateRange = reportDate.isAfter(dateRange.start) &&
              reportDate.isBefore(dateRange.end);
        } else {
          inDateRange = false;
        }
      }

      return hasCategory && inDateRange;
    }).toList();
  }
}
