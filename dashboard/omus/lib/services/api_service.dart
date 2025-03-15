import "dart:convert";

import "package:http/http.dart" as http;
import "package:omus/env.dart";
import "package:omus/services/models/category.dart";
import "package:omus/services/models/report.dart";
import "package:omus/services/models/vial_actor.dart";
import "package:shared_preferences/shared_preferences.dart";

abstract class ApiHelper {
  static String token = "";

  static Future<http.Response> get({required String path, bool useToken = false}) async {
    final url = Uri.parse("$apiUrl$path");
    return http.get(
      url,
      headers: !useToken
          ? {
              "Content-Type": "application/json",
            }
          : {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
    );
  }

  static Future<http.Response> delete({required String path, bool useToken = false}) async {
    final url = Uri.parse("$apiUrl$path");
    return http.delete(
      url,
      headers: !useToken
          ? {
              "Content-Type": "application/json",
            }
          : {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
    );
  }

  static Future<http.Response> post({
    required String path,
    Object? body,
    bool useToken = false,
  }) async {
    final url = Uri.parse("$apiUrl$path");
    return http.post(
      url,
      headers: !useToken
          ? {
              "Content-Type": "application/json",
            }
          : {
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
      body: body,
    );
  }
}

abstract class ApiServices {
  static Future<List<Category>> getAllCategories() async {
    final response = await ApiHelper.get(path: "/Categories");
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List<dynamic>;
      return json.map((item) => Category.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception(response.statusCode);
    }
  }

  static Future<List<VialActor>> getAllActors() async {
    final response = await ApiHelper.get(path: "/VialActors");
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List<dynamic>;
      return json.map((item) => VialActor.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception(response.statusCode);
    }
  }

  static Future<List<Report>> getAllReports() async {
    final response = await ApiHelper.get(path: "/Reports");
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as List<dynamic>;
      return json.map((item) => Report.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception(response.statusCode);
    }
  }

  static Future<void> deleteAllReportImages(int reportId) async {
    final response = await ApiHelper.delete(path: "/Reports/$reportId/images");
    if (response.statusCode != 204) {
      throw Exception(response.statusCode);
    }
  }
}
