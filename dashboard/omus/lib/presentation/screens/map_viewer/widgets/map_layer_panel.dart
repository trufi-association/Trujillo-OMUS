import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:omus/core/enums/feature_type.dart';
import 'package:omus/core/enums/gender.dart';
import 'package:omus/data/models/filter_request.dart';
import 'package:omus/data/models/map_data_container.dart';
import 'package:omus/data/models/gtfs_models.dart';
import 'package:omus/logo.dart';
import 'package:omus/widgets/components/checkbox/custom_checkbox.dart';
import 'package:omus/widgets/components/dropdown/helpers/dropdown_item.dart';
import 'package:omus/widgets/components/dropdown/multi_select_dropdown.dart';
import 'package:omus/widgets/components/fleaflet_map_controller.dart';
import 'package:omus/widgets/components/textfield/form_request_date_range_field.dart';
import 'package:omus/widgets/components/textfield/form_request_field.dart';
import 'package:omus/widgets/components/toggle_switch/custom_toggle_switch.dart';
import 'package:omus/widgets/components/zoom_map_button.dart';
import 'package:provider/provider.dart';

enum ShowMapLayer { routes }

/// Widget that displays the map layer control panel.
class MapLayerPanel extends StatefulWidget {
  const MapLayerPanel({
    super.key,
    required this.leafletMapController,
    required this.model,
    required this.helper,
    required this.onGenderUpdate,
    required this.onGeneralUpdate,
  });

  final LeafletMapController leafletMapController;
  final FilterRequest model;
  final MapDataContainer helper;
  final void Function() onGenderUpdate;
  final void Function() onGeneralUpdate;

  @override
  State<MapLayerPanel> createState() => _MapLayerPanelState();
}

class _MapLayerPanelState extends State<MapLayerPanel> {
  ShowMapLayer? showMapLayer = ShowMapLayer.routes;
  Uint8List bytes = base64Decode(logo);

  @override
  Widget build(BuildContext context) {
    final gtfsData = context.watch<Gtfs>();
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Row(
        children: [
          _buildControlButtons(),
          if (showMapLayer == ShowMapLayer.routes) _buildLayerPanel(gtfsData),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Column(
        children: [
          ZoomInOutMapButton(
            leafletMapController: widget.leafletMapController,
          ),
          Container(height: 5),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      if (showMapLayer != ShowMapLayer.routes) {
                        showMapLayer = ShowMapLayer.routes;
                      } else {
                        showMapLayer = null;
                      }
                    });
                  },
                  child: const SizedBox(
                    width: 30,
                    height: 30,
                    child: Icon(Icons.layers),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerPanel(Gtfs gtfsData) {
    return Container(
      width: 350,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildReportsSection(),
                const Divider(),
                _buildBoardingsSection(),
                const Divider(),
                _buildRoutesSection(gtfsData),
                const Divider(),
                _buildStopsSection(),
                const Divider(),
                _buildSensorsSection(),
                const Divider(),
                _buildSITTSection(),
                const Divider(),
                _buildRegulatedSection(),
                const Divider(),
                _buildPTPUSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, FormItemContainer<bool> field,
      {void Function(bool?)? onChanged}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        FormRequestToggleSwitch(
          update: widget.model.update,
          field: field,
          enabled: true,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildReportsSection() {
    return Column(
      children: [
        _buildSectionHeader(
          'Reportes',
          widget.model.showReports,
          onChanged: (_) => widget.onGeneralUpdate(),
        ),
        if (widget.model.showReports.value == true)
          Container(
            margin: const EdgeInsets.all(5),
            child: Column(
              children: [
                FormRequestMultiSelectField(
                  update: widget.model.update,
                  field: widget.model.categories,
                  label: 'Categorias',
                  items: widget.helper.categories.values
                      .map((e) => DropdownItem(
                            id: e.id.toString(),
                            text: e.categoryName.toString(),
                          ))
                      .toList(),
                  enabled: true,
                  onChanged: (items) {
                    final categoryChanged = widget.helper.categories.values
                        .where((value) => items.contains(value.id.toString()))
                        .expand((category) => category.subcategories)
                        .toList();
                    final currentFilter = widget.model.subCategories.value ?? [];
                    final currentSubCategories = widget.helper.allCategories
                        .where(
                            (value) => currentFilter.contains(value.id.toString()))
                        .toList();
                    final newSubCategoryList = currentSubCategories
                        .where((value) => categoryChanged.contains(value))
                        .map((value) => value.id.toString())
                        .toList();
                    widget.model.update(() {
                      widget.model.subCategories.value = newSubCategoryList;
                    });
                    widget.onGeneralUpdate();
                  },
                ),
                FormRequestMultiSelectField(
                  update: widget.model.update,
                  field: widget.model.subCategories,
                  label: 'Sub-Categorias',
                  items: widget.helper.allCategories
                      .where((value) => widget.model.categories.value
                              ?.contains(value.parentId.toString()) ??
                          false)
                      .map((e) => DropdownItem(
                            id: e.id.toString(),
                            text: e.categoryName.toString(),
                          ))
                      .toList(),
                  enabled: true,
                  onChanged: (_) => widget.onGeneralUpdate(),
                ),
                FormDateRangePickerField(
                  update: widget.model.update,
                  label: 'Rango de fechas',
                  field: widget.model.dateRange,
                  enabled: true,
                  onChanged: (_) => widget.onGeneralUpdate(),
                ),
                Container(height: 10),
                FormRequestCheckBox(
                  update: widget.model.update,
                  label: 'Mapa de calor',
                  field: widget.model.showHeatMapReports,
                  enabled: true,
                ),
                Container(height: 10),
                ElevatedButton(
                  child: const Text('Limpiar filtro'),
                  onPressed: () => widget.model.clearFilters(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBoardingsSection() {
    return Column(
      children: [
        _buildSectionHeader(
          'Abordajes',
          widget.model.showHeatMap,
          onChanged: (_) => widget.onGenderUpdate(),
        ),
        if (widget.model.showHeatMap.value == true)
          Container(
            margin: const EdgeInsets.all(5),
            child: FormRequestMultiSelectField(
              update: widget.model.update,
              field: widget.model.heatMapFilter,
              label: 'Género',
              items: Gender.values
                  .map((e) => DropdownItem(
                        id: e.toValue(),
                        text: e.toText(),
                      ))
                  .toList(),
              enabled: true,
              onChanged: (_) => widget.onGenderUpdate(),
            ),
          ),
      ],
    );
  }

  Widget _buildRoutesSection(Gtfs gtfsData) {
    return Column(
      children: [
        _buildSectionHeader('Rutas', widget.model.showRoutes),
        if (widget.model.showRoutes.value == true)
          Container(
            margin: const EdgeInsets.all(5),
            child: Column(
              children: [
                FormRequestMultiSelectField(
                  update: widget.model.update,
                  field: widget.model.agenciesSelection,
                  label: 'Operadores',
                  items: gtfsData.agencies
                      .map((e) => DropdownItem(
                            id: e.agencyId,
                            text: e.agencyName,
                          ))
                      .toList(),
                  enabled: true,
                  onChanged: (items) {
                    final routesSelected =
                        widget.model.routesSelection.value ?? [];
                    final routes = routesSelected
                        .map((value) => gtfsData.routes
                            .firstWhere((route) => route.routeId == value))
                        .where((value) => items.contains(value.agencyId))
                        .map((value) => value.routeId)
                        .toList();
                    widget.model.update(() {
                      widget.model.routesSelection.value = routes;
                    });
                  },
                ),
                FormRequestMultiSelectField(
                  update: widget.model.update,
                  field: widget.model.routesSelection,
                  label: 'Rutas',
                  items: gtfsData.routes
                      .where((value) =>
                          widget.model.agenciesSelection.value
                              ?.contains(value.agencyId) ??
                          false)
                      .map((e) => DropdownItem(
                            id: e.routeId,
                            text: e.routeShortName,
                          ))
                      .toList(),
                  enabled: true,
                ),
                FormRequestCheckBox(
                  update: widget.model.update,
                  label: 'Mostrar todas las rutas',
                  field: widget.model.showAllRoutes,
                  enabled: true,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStopsSection() {
    return Column(
      children: [
        _buildSectionHeader('Paraderos', widget.model.showStops),
        if (widget.model.showStops.value == true)
          Container(
            margin: const EdgeInsets.all(5),
            child: FormRequestMultiSelectField(
              update: widget.model.update,
              field: widget.model.stopsFilter,
              label: 'Paraderos',
              items: FeatureType.values
                  .map((e) => DropdownItem(
                        id: e.toValue(),
                        text: e.toText(),
                      ))
                  .toList(),
              enabled: true,
            ),
          ),
      ],
    );
  }

  Widget _buildSensorsSection() {
    return _buildSectionHeader('Sensores de Aire', widget.model.showStations);
  }

  Widget _buildSITTSection() {
    return Column(
      children: [
        _buildSectionHeader('Rutas del SITT', widget.model.showSITT),
        if (widget.model.showSITT.value == true)
          Container(
            margin: const EdgeInsets.all(5),
            child: Column(
              children: widget.helper.sittRoutes.values.map((route) {
                final selectedRegion = widget.model.selectedSITT.value?[route.name];
                return _buildRouteSelector(
                  route,
                  selectedRegion,
                  widget.model.selectedSITT,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildRegulatedSection() {
    return Column(
      children: [
        _buildSectionHeader(
            'Plan Regulador de Rutas', widget.model.showRegulated),
        if (widget.model.showRegulated.value == true)
          Container(
            margin: const EdgeInsets.all(5),
            child: Column(
              children: widget.helper.regulatedRoutes.values.map((route) {
                final selectedRegion =
                    widget.model.selectedRegulated.value?[route.name];
                return _buildRouteSelector(
                  route,
                  selectedRegion,
                  widget.model.selectedRegulated,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildRouteSelector(
    dynamic route,
    List<String>? selectedRegion,
    FormItemContainer<Map<String, List<String>?>> container,
  ) {
    return Column(
      children: [
        Row(
          children: [
            FormRequestToggleSwitch(
              update: widget.model.update,
              field: FormItemContainer<bool>(
                  fieldKey: 'keyShowHeatMap', value: selectedRegion != null),
              enabled: true,
              onChanged: (changed) {
                widget.model.update(() {
                  if (changed == true) {
                    container.value?[route.name] = [];
                  } else {
                    container.value?.remove(route.name);
                  }
                });
              },
            ),
            Expanded(
              child: Text(
                route.name,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
          ],
        ),
        if (selectedRegion != null)
          ...route.features
              .map<Widget>((feature) => FormRequestCheckBox(
                    update: widget.model.update,
                    label: feature.name,
                    field: FormItemContainer<bool>(
                        fieldKey: 'keyShowHeatMap',
                        value: selectedRegion.contains(feature.name)),
                    enabled: true,
                    onChanged: (changed) {
                      widget.model.update(() {
                        if (changed == true) {
                          selectedRegion.add(feature.name);
                        } else {
                          selectedRegion.remove(feature.name);
                        }
                      });
                    },
                  ))
              .toList(),
      ],
    );
  }

  Widget _buildPTPUSection() {
    return _buildSectionHeader(
        'Población con cobertura de TPU', widget.model.showPTPU);
  }
}
