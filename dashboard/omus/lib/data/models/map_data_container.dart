import 'package:latlong2/latlong.dart';
import 'package:omus/services/models/category.dart';
import 'package:omus/services/models/report.dart';
import 'package:omus/services/models/vial_actor.dart';
import 'package:omus/geojson_models.dart';
import 'package:omus/stations.dart';

/// Container for map data loaded from various sources.
/// Previously named ServerOriginal in map_viewer.dart
class MapDataContainer {
  final Map<int, Category> categories;
  final List<Category> allCategories;
  final List<VialActor> actors;
  final List<Report> reports;
  final List<GenderBoard> genderData;
  final List<GeoFeature> stops;
  final List<Station> stations;
  final Map<String, Region> sittRoutes;
  final Map<String, Region> regulatedRoutes;
  final List<List<List<LatLng>>> ptpuFeatures;

  MapDataContainer({
    required this.categories,
    required this.allCategories,
    required this.actors,
    required this.reports,
    required this.genderData,
    required this.stops,
    required this.stations,
    required this.sittRoutes,
    required this.regulatedRoutes,
    required this.ptpuFeatures,
  });
}

/// Represents a point on the gender heatmap.
class GenderBoard {
  final LatLng latLng;
  final bool isMen;

  GenderBoard({required this.latLng, required this.isMen});
}
