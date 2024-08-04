import "dart:convert";

import "package:http/http.dart" as http;
import "package:omus/env.dart";
import "package:omus/services/models/category.dart";
import "package:omus/services/models/report.dart";
import "package:omus/services/models/vial_actor.dart";

abstract class ApiHelper {
  static Future<http.Response> get({required String path}) async {
    final url = Uri.parse("$apiUrl$path");
    return http.get(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );
  }
}

abstract class ApiServices {
  static Future<List<Category>> getAllCategories() async {
    final response = await ApiHelper.get(path: "/Categories");
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List<dynamic>;
      return json
          .map((item) => Category.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response.statusCode);
    }
  }

  static Future<List<VialActor>> getAllActors() async {
    final response = await ApiHelper.get(path: "/VialActors");
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List<dynamic>;
      return json
          .map((item) => VialActor.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response.statusCode);
    }
  }

  static Future<List<Report>> getAllReports() async {
    final response = await ApiHelper.get(path: "/Reports");
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List<dynamic>;
      return json
          .map((item) => Report.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(response.statusCode);
    }
  }
}
