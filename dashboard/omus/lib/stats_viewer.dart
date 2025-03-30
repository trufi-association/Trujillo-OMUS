import 'dart:async';
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:omus/main.dart';
import 'package:omus/services/api_service.dart';
import 'package:omus/services/models/category.dart';
import 'package:omus/services/models/report.dart';
import 'package:omus/services/models/vial_actor.dart';
import 'package:omus/widgets/components/helpers/form_loading_helper_new.dart';
import 'package:omus/widgets/components/textfield/form_request_field.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class CategoryReport {
  final String title;
  final List<ReportItem> items;

  CategoryReport({
    required this.title,
    required this.items,
  });

  factory CategoryReport.fromJson(Map<String, dynamic> json) {
    return CategoryReport(
      title: json['title'] ?? '',
      items: (json['items'] as List<dynamic>).map((item) => ReportItem.fromJson(item)).toList(),
    );
  }
}

class ReportItem {
  final String title;
  final String description;
  final String url;
  final String type;

  ReportItem({
    required this.title,
    required this.description,
    required this.url,
    required this.type,
  });
  factory ReportItem.fromJson(Map<String, dynamic> json) {
    return ReportItem(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

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
  static const Map<CategoryEnum, String> _tooltips = {
    CategoryEnum.genderMobilityInclusive: """
Esta categoría busca garantizar que el sistema de transporte responda a las necesidades de todos los ciudadanos, con especial énfasis en la equidad de género y la inclusión de personas en situación de vulnerabilidad. Se monitoriza mediante indicadores que permiten identificar barreras, riesgos y oportunidades de mejora en el entorno vial, tales como:

          -	Reportes de acoso sexual por tipo: Permite conocer la frecuencia y características de incidentes de acoso, facilitando la implementación de medidas de prevención y protocolos de atención.
          -	Mapeo de reportes de lugares percibidos como inseguros por tipo: Identifica áreas críticas en el sistema de transporte, orientando intervenciones para mejorar la seguridad.
          -	Mujeres empleadas en el sector transporte (número y proporción por nivel de empleo): Evalúa la equidad laboral y la representatividad femenina en los distintos niveles del sector.
          -	Accesibilidad de estaciones, paraderos y vehículos de TPU: A través del número de estaciones y paraderos adaptados y la proporción de vehículos accesibles para personas con movilidad reducida, se mide el compromiso con una movilidad inclusiva.
          -	Reportes de barreras de accesibilidad y discriminación en el TPU: Detecta obstáculos y actitudes discriminatorias que impiden el acceso pleno al sistema, permitiendo acciones correctivas.
          -	Número de personas con carnet de discapacidad: Facilita el diseño de estrategias que respondan a las necesidades específicas de este grupo.
""",
    CategoryEnum.roadSafety: """
Esta categoría se centra en la protección de todos los usuarios del sistema vial, minimizando riesgos y mejorando la respuesta ante incidentes. Se evalúa mediante indicadores que permiten un análisis desagregado por género, edad, tipo de usuario y características del siniestro:

          -	Fatalidades y lesiones: Se registran por tipo de usuario vial, género, rango de edad, tipo de siniestro, y considerando el día y hora de ocurrencia, lo que permite identificar patrones y focalizar acciones de prevención.
          -	Reportes de comportamientos riesgosos e incidentes viales: Se registran tanto en número como en ubicación, permitiendo identificar zonas de alta incidencia y la gravedad de los eventos para implementar medidas correctivas en la vía pública.
""",
    CategoryEnum.citizenBehavior: """
Orientada a fomentar una cultura de respeto y responsabilidad en el uso del sistema de transporte, esta categoría recopila información sobre el cumplimiento de normas y la aplicación de sanciones. Entre sus indicadores destacan:

          -	Multas de tránsito y transporte: Registro del número de multas impuestas, clasificadas por tipo, hora, día y estado de la sanción, que sirve para evaluar la efectividad de la fiscalización.
          - Reportes de infracción de norma: Permite identificar comportamientos contrarios a las regulaciones, lo que favorece el diseño de campañas de educación vial y la aplicación de medidas correctivas.
""",
    CategoryEnum.infrastructureAccess: """
La categoría de infraestructura evalúa la calidad, cobertura y mantenimiento del entorno físico destinado a la movilidad urbana sostenible. Sus indicadores permiten conocer tanto la oferta como el estado de la infraestructura:

          -	Reportes de fallas en infraestructura: Registro de incidencias según el tipo de falla, lo que ayuda a priorizar acciones de reparación y mejora.
          -	Infraestructura para bicicletas y señalización vial: Se mide en kilómetros de infraestructura dedicada para bicicletas y vías señalizadas, impulsando modos de transporte alternativos y seguros.
          -	Cobertura y estado del sistema de TPU: Se evalúa el porcentaje de población atendida, la proporción de infraestructura en buen estado y el porcentaje intervenido mediante acciones de mantenimiento, asegurando un servicio confiable y eficiente.
""",
    CategoryEnum.cleanEfficientMobility: """
Enfocada en la reducción del impacto ambiental y la optimización de recursos, esta categoría monitorea la modernización y eficiencia energética del parque vehicular y la calidad del aire, a través de indicadores como:
          
          -	Tecnología de operación en vehículos de TPU y parque automotor: Permite conocer la cantidad de vehículos según la tecnología utilizada, incluyendo la medición de vehículos obsoletos retirados y aquellos que no superan pruebas de emisiones.
          -	Emisiones contaminantes y calidad del aire: Se cuantifican las emisiones de CO₂ y otros contaminantes (PM10, PM2.5, CO, SO₂, NO₂ y O₃), junto con el índice de calidad del aire, lo que favorece la planificación de medidas ambientales.
          -	Sensibilización ciudadana: El porcentaje de ciudadanos informados y sensibilizados respecto al aire limpio es fundamental para promover comportamientos responsables y el uso de tecnologías limpias.
""",
    CategoryEnum.userExperience: """
Esta categoría evalúa la percepción y satisfacción de los usuarios del sistema de transporte, permitiendo identificar oportunidades para mejorar la calidad del servicio y la seguridad en la experiencia de viaje. Entre los indicadores se incluyen:

          -	Abordajes diarios en TPU: Mide la demanda y uso del sistema, reflejando la confianza y aceptación de los usuarios.
          -	Reportes de incidentes de calidad y seguridad: Se registran tanto fallas en los vehículos como reportes de inseguridad (robos, asaltos, etc.), que permiten responder de manera oportuna a problemas operativos y de seguridad.
          -	Ocupación y frecuencia de viajes: La medición de la ocupación en vehículos y paraderos, así como el número de viajes diarios desglosados por modo, género y motivo de viaje, proporciona información clave para ajustar la oferta del servicio.
          -	Subsidios operativos: La proporción de estos respecto a los costos de operación y mantenimiento ayuda a evaluar la sostenibilidad económica del sistema y su impacto en la calidad del servicio.
""",
  };

  static const Map<CategoryEnum, String> _colors = {
    CategoryEnum.genderMobilityInclusive: "0xFFFF7043",
    CategoryEnum.roadSafety: "0xFFFFB74D",
    CategoryEnum.citizenBehavior: "0xFFCDDC39",
    CategoryEnum.infrastructureAccess: "0xFF66BB6A",
    CategoryEnum.cleanEfficientMobility: "0xFF388E3C",
    CategoryEnum.userExperience: "0xFF398E3C",
  };
  static const Map<CategoryEnum, String> _svgStrings = {
    CategoryEnum.genderMobilityInclusive: """<svg width="50" height="48" viewBox="0 0 50 48" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M41.0455 17.3952C41.0772 16.9819 41.0992 16.5637 41.0992 16.1406C41.0992 11.8599 39.403 7.75445 36.3838 4.72749C33.3646 1.70053 29.2698 0 25 0C20.7302 0 16.6354 1.70053 13.6162 4.72749C10.597 7.75445 8.90085 11.8599 8.90085 16.1406C8.90085 16.5637 8.9228 16.9819 8.95451 17.3952C6.98344 18.3739 5.23329 19.7471 3.81207 21.4301C2.39085 23.1132 1.32869 25.0703 0.691138 27.1809C0.0535869 29.2914 -0.145834 31.5105 0.10518 33.7013C0.356193 35.8921 1.05232 38.0081 2.1506 39.9188C3.24888 41.8294 4.72602 43.4941 6.49088 44.8102C8.25573 46.1263 10.2709 47.0659 12.4119 47.571C14.553 48.076 16.7746 48.1359 18.9396 47.7468C21.1047 47.3577 23.1672 46.528 25 45.3088C26.8328 46.528 28.8953 47.3577 31.0604 47.7468C33.2254 48.1359 35.447 48.076 37.5881 47.571C39.7291 47.0659 41.7443 46.1263 43.5091 44.8102C45.274 43.4941 46.7511 41.8294 47.8494 39.9188C48.9477 38.0081 49.6438 35.8921 49.8948 33.7013C50.1458 31.5105 49.9464 29.2914 49.3089 27.1809C48.6713 25.0703 47.6092 23.1132 46.1879 21.4301C44.7667 19.7471 43.0166 18.3739 41.0455 17.3952ZM11.828 16.1406C11.828 12.6382 13.2157 9.27921 15.686 6.80261C18.1562 4.326 21.5066 2.93466 25 2.93466C28.4934 2.93466 31.8438 4.326 34.314 6.80261C36.7843 9.27921 38.172 12.6382 38.172 16.1406C38.172 16.1822 38.172 16.2238 38.172 16.2654C35.961 15.6344 33.6406 15.4874 31.368 15.8342C29.0953 16.1811 26.9236 17.0137 25 18.2756C23.0764 17.0137 20.9047 16.1811 18.632 15.8342C16.3594 15.4874 14.039 15.6344 11.828 16.2654C11.828 16.2238 11.828 16.1822 11.828 16.1406ZM29.3907 31.7922C29.3912 33.6489 29.0003 35.4848 28.2436 37.1794C27.4869 38.8741 26.3816 40.3893 25 41.6258C23.6184 40.3893 22.5131 38.8741 21.7564 37.1794C20.9997 35.4848 20.6088 33.6489 20.6093 31.7922C20.6093 31.7506 20.6093 31.709 20.6093 31.6675C23.4794 32.4868 26.5206 32.4868 29.3907 31.6675C29.3907 31.709 29.3907 31.7506 29.3907 31.7922ZM25 29.3466C23.6336 29.3476 22.2756 29.1339 20.9752 28.7132C21.6024 26.1045 23.0061 23.7488 25 21.9586C26.9939 23.7488 28.3976 26.1045 29.0248 28.7132C27.7244 29.1339 26.3664 29.3476 25 29.3466ZM18.2676 27.4856C16.7573 26.5826 15.4421 25.3863 14.3991 23.9668C13.3561 22.5474 12.6063 20.9334 12.1939 19.2196C13.8991 18.67 15.6984 18.4759 17.4812 18.6492C19.264 18.8225 20.9926 19.3595 22.5607 20.2272C20.5138 22.2228 19.0323 24.7276 18.2676 27.4856ZM27.4393 20.2272C29.0084 19.3584 30.7383 18.8209 32.5224 18.6476C34.3066 18.4743 36.1072 18.669 37.8135 19.2196C37.401 20.9334 36.6512 22.5474 35.6082 23.9668C34.5653 25.3863 33.25 26.5826 31.7397 27.4856C30.9729 24.7269 29.4888 22.2219 27.4393 20.2272ZM16.2186 44.9982C13.3354 44.996 10.5324 44.0455 8.23989 42.2923C5.94737 40.5392 4.29194 38.0803 3.5276 35.293C2.76327 32.5057 2.93225 29.5439 4.00863 26.8622C5.085 24.1805 7.00931 21.9269 9.48627 20.4473C10.0892 22.6103 11.1338 24.6242 12.5539 26.3612C13.974 28.0982 15.7386 29.5204 17.7359 30.5376C17.7042 30.9509 17.6822 31.3691 17.6822 31.7922C17.6807 33.9493 18.1118 36.0847 18.9499 38.0715C19.788 40.0582 21.0159 41.8557 22.5607 43.3572C20.6197 44.4344 18.4373 44.9991 16.2186 44.9982ZM33.7814 44.9982C31.5627 44.9991 29.3803 44.4344 27.4393 43.3572C28.9841 41.8557 30.212 40.0582 31.0501 38.0715C31.8882 36.0847 32.3193 33.9493 32.3178 31.7922C32.3178 31.3691 32.2958 30.9509 32.2641 30.5376C34.2614 29.5204 36.026 28.0982 37.4461 26.3612C38.8662 24.6242 39.9108 22.6103 40.5137 20.4473C42.9907 21.9269 44.915 24.1805 45.9914 26.8622C47.0677 29.5439 47.2367 32.5057 46.4724 35.293C45.7081 38.0803 44.0526 40.5392 41.7601 42.2923C39.4676 44.0455 36.6646 44.996 33.7814 44.9982Z" fill="#273238"/>
</svg>

""",
    CategoryEnum.roadSafety: """
<svg width="58" height="37" viewBox="0 0 58 37" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M57.1875 36.7829C56.8219 36.9889 56.3897 37.0409 55.9858 36.9274C55.582 36.814 55.2397 36.5444 55.0341 36.178L36.5101 3.17026H30.5823V5.81214C30.5823 6.23255 30.4157 6.63573 30.1191 6.933C29.8225 7.23027 29.4203 7.39727 29.0009 7.39727C28.5814 7.39727 28.1792 7.23027 27.8826 6.933C27.586 6.63573 27.4194 6.23255 27.4194 5.81214V3.17026H21.4916L2.96759 36.178C2.86698 36.3616 2.73106 36.5234 2.56768 36.654C2.40431 36.7846 2.21673 36.8815 2.01577 36.939C1.81482 36.9966 1.60448 37.0136 1.39692 36.9892C1.18935 36.9647 0.98868 36.8993 0.806501 36.7966C0.624322 36.694 0.464248 36.5562 0.335533 36.3911C0.206817 36.2261 0.112013 36.0371 0.056601 35.8352C0.00118874 35.6332 -0.0137327 35.4222 0.0126992 35.2144C0.039131 35.0066 0.106392 34.8061 0.210594 34.6245L17.8622 3.17026H1.58909C1.16966 3.17026 0.767416 3.00326 0.470837 2.70599C0.174257 2.40872 0.0076412 2.00553 0.0076412 1.58513C0.0076412 1.16473 0.174257 0.761543 0.470837 0.464274C0.767416 0.167004 1.16966 0 1.58909 0H56.4126C56.8321 0 57.2343 0.167004 57.5309 0.464274C57.8275 0.761543 57.9941 1.16473 57.9941 1.58513C57.9941 2.00553 57.8275 2.40872 57.5309 2.70599C57.2343 3.00326 56.8321 3.17026 56.4126 3.17026H40.1395L57.799 34.6245C57.9005 34.8064 57.9651 35.0066 57.9893 35.2136C58.0135 35.4206 57.9967 35.6304 57.9399 35.8308C57.8831 36.0313 57.7874 36.2186 57.6583 36.382C57.5292 36.5454 57.3692 36.6816 57.1875 36.7829ZM29.0009 14.7945C28.5814 14.7945 28.1792 14.9616 27.8826 15.2588C27.586 15.5561 27.4194 15.9593 27.4194 16.3797V20.6067C27.4194 21.0271 27.586 21.4303 27.8826 21.7276C28.1792 22.0248 28.5814 22.1918 29.0009 22.1918C29.4203 22.1918 29.8225 22.0248 30.1191 21.7276C30.4157 21.4303 30.5823 21.0271 30.5823 20.6067V16.3797C30.5823 15.9593 30.4157 15.5561 30.1191 15.2588C29.8225 14.9616 29.4203 14.7945 29.0009 14.7945ZM29.0009 29.5891C28.5814 29.5891 28.1792 29.7561 27.8826 30.0534C27.586 30.3506 27.4194 30.7538 27.4194 31.1742V35.4012C27.4194 35.8216 27.586 36.2248 27.8826 36.5221C28.1792 36.8194 28.5814 36.9864 29.0009 36.9864C29.4203 36.9864 29.8225 36.8194 30.1191 36.5221C30.4157 36.2248 30.5823 35.8216 30.5823 35.4012V31.1742C30.5823 30.7538 30.4157 30.3506 30.1191 30.0534C29.8225 29.7561 29.4203 29.5891 29.0009 29.5891Z" fill="#273238"/>
</svg>
""",
    CategoryEnum.citizenBehavior: """
<svg width="41" height="41" viewBox="0 0 41 41" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M20.5 0C16.4455 0 12.482 1.2023 9.11082 3.45487C5.73961 5.70744 3.11207 8.9091 1.56048 12.655C0.00888198 16.4009 -0.397086 20.5227 0.393911 24.4993C1.18491 28.476 3.13734 32.1287 6.00432 34.9957C8.87129 37.8627 12.524 39.8151 16.5007 40.6061C20.4773 41.3971 24.5991 40.9911 28.345 39.4395C32.0909 37.8879 35.2926 35.2604 37.5451 31.8892C39.7977 28.518 41 24.5545 41 20.5C40.9936 15.065 38.8318 9.85447 34.9886 6.01136C31.1455 2.16825 25.935 0.00638283 20.5 0ZM38.5882 20.5C38.5922 24.8801 36.9995 29.1116 34.1084 32.4021L8.59795 6.89162C11.2117 4.60201 14.43 3.11418 17.8674 2.60624C21.3049 2.0983 24.8159 2.59178 27.9801 4.02759C31.1444 5.4634 33.8278 7.78071 35.7092 10.7021C37.5905 13.6235 38.5901 17.0252 38.5882 20.5ZM2.41177 20.5C2.40786 16.1198 4.00053 11.8884 6.89163 8.59794L32.4021 34.1084C29.7883 36.398 26.5701 37.8858 23.1326 38.3937C19.6951 38.9017 16.1841 38.4082 13.0199 36.9724C9.85561 35.5366 7.17219 33.2193 5.29083 30.2979C3.40947 27.3765 2.4099 23.9748 2.41177 20.5Z" fill="#273238"/>
</svg>
""",
    CategoryEnum.infrastructureAccess: """
<svg width="62" height="44" viewBox="0 0 62 44" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M60.271 31.5897H50.7016V12.7713C52.8954 16.019 56.0071 18.5362 59.6377 20.0003C59.8444 20.0904 60.067 20.1381 60.2924 20.1406C60.5179 20.1431 60.7415 20.1004 60.9502 20.0149C61.1588 19.9295 61.3483 19.803 61.5074 19.643C61.6666 19.483 61.7921 19.2926 61.8767 19.0832C61.9612 18.8738 62.0031 18.6496 61.9998 18.4237C61.9965 18.1978 61.9481 17.9749 61.8575 17.768C61.7669 17.5612 61.6358 17.3746 61.4721 17.2193C61.3084 17.064 61.1153 16.9432 60.9042 16.8638C57.8844 15.6479 55.2979 13.5521 53.479 10.8475C51.6602 8.1429 50.6927 4.95375 50.7016 1.69231C50.7016 1.24348 50.5237 0.813035 50.207 0.495665C49.8903 0.178296 49.4608 0 49.0129 0C48.565 0 48.1355 0.178296 47.8188 0.495665C47.5021 0.813035 47.3242 1.24348 47.3242 1.69231C47.3242 6.03098 45.6043 10.1919 42.5429 13.2598C39.4816 16.3278 35.3294 18.0513 31 18.0513C26.6706 18.0513 22.5184 16.3278 19.4571 13.2598C16.3957 10.1919 14.6758 6.03098 14.6758 1.69231C14.6758 1.24348 14.4979 0.813035 14.1812 0.495665C13.8645 0.178296 13.435 0 12.9871 0C12.5392 0 12.1097 0.178296 11.793 0.495665C11.4763 0.813035 11.2984 1.24348 11.2984 1.69231C11.3073 4.95375 10.3398 8.1429 8.52095 10.8475C6.70214 13.5521 4.11564 15.6479 1.09578 16.8638C0.884703 16.9432 0.691612 17.064 0.527889 17.2193C0.364167 17.3746 0.233127 17.5612 0.142495 17.768C0.0518629 17.9749 0.00347365 18.1978 0.000180244 18.4237C-0.00311316 18.6496 0.038756 18.8738 0.123319 19.0832C0.207882 19.2926 0.333427 19.483 0.492552 19.643C0.651678 19.803 0.841162 19.9295 1.04983 20.0149C1.25851 20.1004 1.48214 20.1431 1.70755 20.1406C1.93297 20.1381 2.15559 20.0904 2.36231 20.0003C5.99294 18.5362 9.10458 16.019 11.2984 12.7713V31.5897H1.72904C1.28117 31.5897 0.851639 31.768 0.534945 32.0854C0.218251 32.4028 0.0403338 32.8332 0.0403338 33.2821C0.0403338 33.7309 0.218251 34.1613 0.534945 34.4787C0.851639 34.7961 1.28117 34.9744 1.72904 34.9744H11.2984V42.3077C11.2984 42.7565 11.4763 43.187 11.793 43.5043C12.1097 43.8217 12.5392 44 12.9871 44C13.435 44 13.8645 43.8217 14.1812 43.5043C14.4979 43.187 14.6758 42.7565 14.6758 42.3077V34.9744H47.3242V42.3077C47.3242 42.7565 47.5021 43.187 47.8188 43.5043C48.1355 43.8217 48.565 44 49.0129 44C49.4608 44 49.8903 43.8217 50.207 43.5043C50.5237 43.187 50.7016 42.7565 50.7016 42.3077V34.9744H60.271C60.7188 34.9744 61.1484 34.7961 61.4651 34.4787C61.7817 34.1613 61.9597 33.7309 61.9597 33.2821C61.9597 32.8332 61.7817 32.4028 61.4651 32.0854C61.1484 31.768 60.7188 31.5897 60.271 31.5897ZM36.0661 20.7731V31.5897H25.9339V20.7731C29.2537 21.6569 32.7463 21.6569 36.0661 20.7731ZM14.6758 12.7346C16.6533 15.6612 19.3736 18.0066 22.5565 19.5292V31.5897H14.6758V12.7346ZM39.4435 31.5897V19.5292C42.6264 18.0066 45.3467 15.6612 47.3242 12.7346V31.5897H39.4435Z" fill="#273238"/>
</svg>
""",
    CategoryEnum.cleanEfficientMobility: """
<svg width="74" height="41" viewBox="0 0 74 41" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M69.8889 14.0541H61.2233L48.332 1.20046C47.9508 0.819054 47.4977 0.516623 46.9987 0.310594C46.4998 0.104564 45.9649 -0.000992198 45.4248 7.02832e-06H12.4156C11.7388 -0.000190333 11.0725 0.166197 10.4757 0.484405C9.8789 0.802612 9.37013 1.2628 8.99453 1.82412L0.293655 14.8359C0.101405 15.1249 -0.000769634 15.4641 4.36507e-06 15.8109V29.865C4.36507e-06 30.9522 0.433138 31.9948 1.20412 32.7635C1.9751 33.5323 3.02078 33.9641 4.11112 33.9641H9.57302C9.9774 35.9498 11.0578 37.735 12.6312 39.0173C14.2046 40.2995 16.1742 41 18.2064 41C20.2385 41 22.2081 40.2995 23.7815 39.0173C25.3549 37.735 26.4353 35.9498 26.8397 33.9641H47.1603C47.5647 35.9498 48.6451 37.735 50.2185 39.0173C51.7919 40.2995 53.7616 41 55.7937 41C57.8258 41 59.7954 40.2995 61.3688 39.0173C62.9422 37.735 64.0226 35.9498 64.427 33.9641H69.8889C70.9792 33.9641 72.0249 33.5323 72.7959 32.7635C73.5669 31.9948 74 30.9522 74 29.865V18.1532C74 17.0661 73.5669 16.0235 72.7959 15.2547C72.0249 14.486 70.9792 14.0541 69.8889 14.0541ZM11.9281 3.77412C11.9816 3.69411 12.0541 3.62848 12.1391 3.58303C12.2242 3.53758 12.3191 3.51372 12.4156 3.51354H45.4248C45.5804 3.51419 45.7293 3.57631 45.8389 3.68628L56.24 14.0541H5.05373L11.9281 3.77412ZM18.2064 37.4777C17.1609 37.4777 16.139 37.1686 15.2698 36.5895C14.4005 36.0103 13.7231 35.1872 13.323 34.2242C12.9229 33.2612 12.8183 32.2015 13.0222 31.1792C13.2262 30.1568 13.7296 29.2178 14.4688 28.4807C15.208 27.7436 16.1498 27.2417 17.1752 27.0383C18.2005 26.835 19.2633 26.9394 20.2291 27.3382C21.1949 27.7371 22.0205 28.4127 22.6013 29.2793C23.1821 30.146 23.4921 31.165 23.4921 32.2074C23.4921 33.6051 22.9352 34.9457 21.9439 35.934C20.9527 36.9224 19.6082 37.4777 18.2064 37.4777ZM55.7937 37.4777C54.7482 37.4777 53.7263 37.1686 52.8571 36.5895C51.9878 36.0103 51.3104 35.1872 50.9103 34.2242C50.5102 33.2612 50.4056 32.2015 50.6095 31.1792C50.8135 30.1568 51.3169 29.2178 52.0561 28.4807C52.7953 27.7436 53.7371 27.2417 54.7625 27.0383C55.7878 26.835 56.8506 26.9394 57.8164 27.3382C58.7822 27.7371 59.6078 28.4127 60.1886 29.2793C60.7694 30.146 61.0794 31.165 61.0794 32.2074C61.0794 33.6051 60.5225 34.9457 59.5312 35.934C58.54 36.9224 57.1955 37.4777 55.7937 37.4777ZM70.4762 29.865C70.4762 30.0203 70.4143 30.1693 70.3042 30.2791C70.194 30.3889 70.0447 30.4506 69.8889 30.4506H64.427C64.0226 28.4649 62.9422 26.6797 61.3688 25.3975C59.7954 24.1152 57.8258 23.4147 55.7937 23.4147C53.7616 23.4147 51.7919 24.1152 50.2185 25.3975C48.6451 26.6797 47.5647 28.4649 47.1603 30.4506H26.8397C26.4353 28.4649 25.3549 26.6797 23.7815 25.3975C22.2081 24.1152 20.2385 23.4147 18.2064 23.4147C16.1742 23.4147 14.2046 24.1152 12.6312 25.3975C11.0578 26.6797 9.9774 28.4649 9.57302 30.4506H4.11112C3.95535 30.4506 3.80597 30.3889 3.69583 30.2791C3.58569 30.1693 3.52381 30.0203 3.52381 29.865V17.5677H69.8889C70.0447 17.5677 70.194 17.6294 70.3042 17.7392C70.4143 17.849 70.4762 17.9979 70.4762 18.1532V29.865Z" fill="black"/>
</svg>
""",
    CategoryEnum.userExperience: """
<svg width="40" height="46" viewBox="0 0 40 46" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M33.3873 31.657C35.4456 29.9734 37.0938 27.8435 38.2069 25.4286C39.32 23.0137 39.869 20.3771 39.8122 17.7186C39.6091 8.64294 32.3453 1.16185 23.29 0.684502C20.9452 0.5569 18.5988 0.903363 16.3909 1.70318C14.183 2.503 12.1591 3.73976 10.4401 5.33953C8.72105 6.93929 7.34221 8.86923 6.38597 11.014C5.42973 13.1587 4.91573 15.4743 4.87469 17.8222L0.265785 26.6784C0.251567 26.7048 0.239379 26.7312 0.227192 26.7597C-0.0562485 27.4255 -0.0751637 28.1744 0.1743 28.8537C0.423764 29.5331 0.922838 30.0917 1.56985 30.4159L1.60641 30.4342L6.49766 32.6686V39.2498C6.49766 40.004 6.79727 40.7273 7.33057 41.2606C7.86388 41.794 8.5872 42.0936 9.34141 42.0936H19.0914C19.4146 42.0936 19.7246 41.9652 19.9532 41.7366C20.1818 41.508 20.3102 41.198 20.3102 40.8748C20.3102 40.5516 20.1818 40.2416 19.9532 40.013C19.7246 39.7845 19.4146 39.6561 19.0914 39.6561H9.34344C9.2357 39.6561 9.13237 39.6133 9.05618 39.5371C8.97999 39.4609 8.93719 39.3576 8.93719 39.2498V31.8987C8.93741 31.6652 8.87052 31.4365 8.74448 31.2399C8.61844 31.0432 8.43856 30.887 8.22625 30.7897L2.64032 28.2364C2.55648 28.1903 2.49158 28.1162 2.45702 28.0271C2.42247 27.9379 2.42048 27.8394 2.45141 27.7489L7.16594 18.6875C7.25936 18.5145 7.30954 18.3214 7.31219 18.1248C7.31336 14.6317 8.53028 11.2479 10.7541 8.55407C12.9779 5.86027 16.07 4.02446 19.4997 3.36169V7.32669C18.462 7.62085 17.5657 8.28042 16.9762 9.18368C16.3867 10.0869 16.1437 11.1729 16.2922 12.2413C16.4407 13.3096 16.9706 14.2882 17.7841 14.9964C18.5976 15.7047 19.6398 16.0948 20.7184 16.0948C21.797 16.0948 22.8393 15.7047 23.6528 14.9964C24.4663 14.2882 24.9961 13.3096 25.1446 12.2413C25.2931 11.1729 25.0502 10.0869 24.4607 9.18368C23.8712 8.28042 22.9749 7.62085 21.9372 7.32669V3.10372C22.3434 3.09356 22.7497 3.09356 23.1559 3.11591C26.2152 3.29083 29.1488 4.39298 31.5664 6.27579C33.9841 8.15859 35.7712 10.7328 36.6902 13.6561H32.0934C31.9147 13.6561 31.7382 13.6954 31.5764 13.7712C31.4146 13.847 31.2714 13.9575 31.157 14.0948L25.7844 20.542C24.7967 20.1006 23.6826 20.0314 22.6479 20.3473C21.6131 20.6631 20.7276 21.3426 20.1548 22.2604C19.582 23.1782 19.3605 24.2722 19.5313 25.3405C19.7022 26.4088 20.2537 27.3792 21.0841 28.0726C21.9146 28.766 22.9678 29.1355 24.0495 29.1129C25.1311 29.0904 26.168 28.6773 26.9689 27.9499C27.7697 27.2225 28.2803 26.2299 28.4065 25.1554C28.5326 24.081 28.2657 22.9971 27.6552 22.104L32.6642 16.0936H37.2345C37.3119 16.6498 37.3573 17.21 37.3706 17.7714C37.4229 20.1634 36.9053 22.5334 35.8605 24.6858C34.8158 26.8382 33.2738 28.7111 31.3622 30.1498C31.1906 30.2787 31.0561 30.4507 30.9722 30.6483C30.8884 30.8459 30.8583 31.0621 30.8848 31.2751L32.5098 44.2751C32.5465 44.5699 32.6895 44.8412 32.9121 45.0379C33.1346 45.2347 33.4214 45.3434 33.7184 45.3436C33.7694 45.3432 33.8203 45.3398 33.8708 45.3334C34.0296 45.3136 34.183 45.2626 34.3222 45.1835C34.4614 45.1044 34.5836 44.9986 34.6819 44.8722C34.7802 44.7458 34.8526 44.6013 34.895 44.4469C34.9374 44.2925 34.949 44.1313 34.9291 43.9725L33.3873 31.657ZM22.7497 11.6248C22.7497 12.0266 22.6306 12.4193 22.4074 12.7533C22.1842 13.0874 21.8669 13.3477 21.4958 13.5014C21.1246 13.6552 20.7162 13.6954 20.3222 13.617C19.9281 13.5387 19.5662 13.3452 19.2821 13.0611C18.9981 12.777 18.8046 12.4151 18.7262 12.0211C18.6478 11.6271 18.6881 11.2186 18.8418 10.8475C18.9956 10.4763 19.2559 10.1591 19.5899 9.93589C19.924 9.71269 20.3167 9.59356 20.7184 9.59356C21.2572 9.59356 21.7738 9.80757 22.1548 10.1885C22.5357 10.5694 22.7497 11.0861 22.7497 11.6248ZM23.9684 26.6561C23.5667 26.6561 23.174 26.5369 22.8399 26.3137C22.5059 26.0905 22.2456 25.7733 22.0918 25.4021C21.9381 25.031 21.8978 24.6226 21.9762 24.2285C22.0546 23.8345 22.2481 23.4726 22.5321 23.1885C22.8162 22.9044 23.1781 22.711 23.5722 22.6326C23.9662 22.5542 24.3746 22.5944 24.7458 22.7482C25.1169 22.9019 25.4342 23.1623 25.6574 23.4963C25.8806 23.8303 25.9997 24.2231 25.9997 24.6248C25.9997 25.1635 25.7857 25.6802 25.4048 26.0611C25.0238 26.4421 24.5072 26.6561 23.9684 26.6561Z" fill="black"/>
</svg>
""",
  };

  String get svgString => _svgStrings[this]!;
  String get title => _titles[this]!;
  String get tooltip => _tooltips[this]!;
  Color get color => Color(int.parse(_colors[this]!));
  String get jsonKey {
    switch (this) {
      case CategoryEnum.genderMobilityInclusive:
        return "genero_y_movilidad";
      case CategoryEnum.roadSafety:
        return "seguridad_vial";
      case CategoryEnum.citizenBehavior:
        return "comportamiento_ciudadano_e_infracciones";
      case CategoryEnum.infrastructureAccess:
        return "infraestructura_y_acceso";
      case CategoryEnum.cleanEfficientMobility:
        return "movilidad_limpia_y_eficiente";
      case CategoryEnum.userExperience:
        return "experiencia_de_usuario";
    }
  }

  Widget buildBody(Map<String, CategoryReport> categoryReports) {
    categoryReports[jsonKey];
    return CustomReportContainer(
      reportItems: categoryReports[jsonKey]!.items,
    );
  }
}

class CustomReportContainer extends StatefulWidget {
  final List<ReportItem> reportItems;

  const CustomReportContainer({
    super.key,
    required this.reportItems,
  });

  @override
  State<CustomReportContainer> createState() => _CustomReportContainerState();
}

class _CustomReportContainerState extends State<CustomReportContainer> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.reportItems.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: widget.reportItems.map((report) {
            return Tooltip(
              message: report.description,
              child: Tab(
                text: report.title,
              ),
            );
          }).toList(),
        ),
        Expanded(
          child: IndexedStack(
            index: _currentIndex,
            children: widget.reportItems
                .map(
                  (report) => _PersistentTabContent(
                    key: PageStorageKey(report.title),
                    url: report.url,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _PersistentTabContent extends StatefulWidget {
  final String url;

  const _PersistentTabContent({
    required Key key,
    required this.url,
  }) : super(key: key);

  @override
  _PersistentTabContentState createState() => _PersistentTabContentState();
}

class _PersistentTabContentState extends State<_PersistentTabContent> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri(widget.url),
      ),
    );
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

class StatsViewerState extends State<StatsViewer> {
  final List<CategoryEnum> categories = CategoryEnum.values;

  Map<String, CategoryReport>? categoryReports;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await ApiHelper.get(path: '/ChartConfig/config');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(json.decode(response.body));

        categoryReports = data.map(
          (key, value) => MapEntry(key, CategoryReport.fromJson(value)),
        );
        setState(() {
          isLoading = false;
        });
      } else {
        throw Exception('Error al obtener los datos: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError || categoryReports == null) {
      return const Center(child: Text("Error al cargar datos"));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const GeneralAppBar(
          title: "Estadísticas de movilidad",
        ),
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
                              return CategoryButton(
                                category: category,
                                params: params,
                                categoryReports: categoryReports!,
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

class CategoryButton extends StatefulWidget {
  const CategoryButton({
    super.key,
    required this.category,
    required this.categoryReports,
    required this.params,
  });
  final CategoryEnum category;
  final Map<String, CategoryReport> categoryReports;
  final FormRequestHelperParams<Never, ModelRequest, ServerOriginal> params;

  @override
  State<CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 200,
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            hover = true;
          });
        },
        onExit: (_) {
          setState(() {
            hover = false;
          });
        },
        child: InkWell(
          onTap: () {
            _showFullScreenPopup(
              context,
              widget.category.title,
              builder: (_, boxConstraints) => widget.category.buildBody(widget.categoryReports),
            );
          },
          child: Tooltip(
            message: widget.category.tooltip,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: hover ? const Color(0xFF0077AE) : const Color.fromRGBO(255, 255, 255, 0.8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.string(
                    theme: const SvgTheme(currentColor: Colors.red),
                    widget.category.svgString,
                    height: 50,
                    width: 50,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    widget.category.title,
                    style: TextStyle(
                      color: hover ? Colors.white : Colors.black,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _showFullScreenPopup(
  BuildContext context,
  String title, {
  required Widget Function(BuildContext, BoxConstraints) builder,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: const Color(0xFFD4DFE9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(builder: builder),
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
  const ReportPieChart({
    super.key,
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
        children: <Widget>[
          Text(
            widget.title,
            style: const TextStyle(fontSize: 30),
          ),
          SizedBox(
            height: 500,
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
                  color: entry.value.color,
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
        color: widget.categories[entry.key]?.color ?? Colors.grey,
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
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

  const MonthlyReportChart({super.key, required this.reports, required this.title});

  @override
  MonthlyReportChartState createState() => MonthlyReportChartState();
}

class MonthlyReportChartState extends State<MonthlyReportChart> {
  late Map<int, Map<int, int>> reportCountsByYear;
  late Map<int, Map<int, Map<int, int>>> reportCountsByDay;
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

        if (!reportCountsByYear.containsKey(year)) {
          reportCountsByYear[year] = {};
        }
        if (!reportCountsByYear[year]!.containsKey(month)) {
          reportCountsByYear[year]![month] = 0;
        }
        reportCountsByYear[year]![month] = reportCountsByYear[year]![month]! + 1;

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
            style: const TextStyle(fontSize: 20),
          ),
          Container(
            height: 500,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color.fromARGB(255, 255, 255, 255), borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (showingDays)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showingDays = false;
                            });
                          },
                          child: const Text('Volver a meses'),
                        ),
                      ),
                    DropdownButton<int>(
                      value: selectedYear,
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedYear = newValue!;
                          showingDays = false;
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
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                if (showingDays) {
                                  return Text(value.toInt().toString());
                                } else {
                                  const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
                                  return InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (!showingDays) {
                                            selectedMonth = value.toInt();
                                            showingDays = true;
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
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
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

  const StopFeaturesChart({super.key, required this.stops, required this.title});

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
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: featurePercentages.keys.map((feature) {
              return _buildFeatureBar(feature, featurePercentages[feature]!);
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 230),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(11, (index) {
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
                _buildBarSegment(percentages['yes']!, const Color(0xFF99C76D)),
                _buildBarSegment(percentages['no']!, const Color(0xFF0095DA)),
                _buildBarSegment(percentages['unknown']!, const Color(0xFF606060)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _translateFeature(String feature) {
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

    return featureTranslationMap[feature] ?? feature;
  }

  Widget _buildBarSegment(double percentage, Color color) {
    return Expanded(
      flex: percentage.round(),
      child: Container(
        height: 20,
        color: color,
      ),
    );
  }
}
