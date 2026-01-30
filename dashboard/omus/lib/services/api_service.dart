import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:omus/env.dart';
import 'package:omus/services/api_exceptions.dart';
import 'package:omus/services/models/category.dart';
import 'package:omus/services/models/report.dart';
import 'package:omus/services/models/vial_actor.dart';

/// HTTP client helper for API requests
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String? _token;

  /// Set the authentication token
  void setToken(String token) {
    _token = token;
  }

  /// Clear the authentication token
  void clearToken() {
    _token = null;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Map<String, String> _buildHeaders({bool useToken = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (useToken && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  Future<http.Response> get({
    required String path,
    bool useToken = false,
  }) async {
    final url = Uri.parse('$apiUrl$path');
    developer.log('GET $url', name: 'ApiClient');

    try {
      return await http.get(url, headers: _buildHeaders(useToken: useToken));
    } catch (e) {
      throw toApiException(e);
    }
  }

  Future<http.Response> post({
    required String path,
    Object? body,
    bool useToken = false,
  }) async {
    final url = Uri.parse('$apiUrl$path');
    developer.log('POST $url', name: 'ApiClient');

    try {
      return await http.post(
        url,
        headers: _buildHeaders(useToken: useToken),
        body: body,
      );
    } catch (e) {
      throw toApiException(e);
    }
  }

  Future<http.Response> put({
    required String path,
    Object? body,
    bool useToken = false,
  }) async {
    final url = Uri.parse('$apiUrl$path');
    developer.log('PUT $url', name: 'ApiClient');

    try {
      return await http.put(
        url,
        headers: _buildHeaders(useToken: useToken),
        body: body,
      );
    } catch (e) {
      throw toApiException(e);
    }
  }

  Future<http.Response> delete({
    required String path,
    bool useToken = false,
  }) async {
    final url = Uri.parse('$apiUrl$path');
    developer.log('DELETE $url', name: 'ApiClient');

    try {
      return await http.delete(url, headers: _buildHeaders(useToken: useToken));
    } catch (e) {
      throw toApiException(e);
    }
  }
}

/// Legacy static helper - delegates to ApiClient singleton
/// @deprecated Use ApiClient.instance instead
abstract class ApiHelper {
  static String get token => ApiClient.instance._token ?? '';
  static set token(String value) => ApiClient.instance.setToken(value);

  static Future<http.Response> get({
    required String path,
    bool useToken = false,
  }) =>
      ApiClient.instance.get(path: path, useToken: useToken);

  static Future<http.Response> post({
    required String path,
    Object? body,
    bool useToken = false,
  }) =>
      ApiClient.instance.post(path: path, body: body, useToken: useToken);

  static Future<http.Response> delete({
    required String path,
    bool useToken = false,
  }) =>
      ApiClient.instance.delete(path: path, useToken: useToken);
}

/// API services for data operations
abstract class ApiServices {
  static Future<List<Category>> getAllCategories() async {
    final response = await ApiClient.instance.get(path: '/Categories');

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body) as List<dynamic>;
        return json
            .map((item) => Category.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw ParseException(originalError: e);
      }
    }

    throw ApiResponseException.fromResponse(response);
  }

  static Future<List<VialActor>> getAllActors() async {
    final response = await ApiClient.instance.get(path: '/VialActors');

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body) as List<dynamic>;
        return json
            .map((item) => VialActor.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw ParseException(originalError: e);
      }
    }

    throw ApiResponseException.fromResponse(response);
  }

  static Future<List<Report>> getAllReports() async {
    final response = await ApiClient.instance.get(
      path: '/Reports',
    );

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body) as List<dynamic>;
        return json
            .map((item) => Report.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw ParseException(originalError: e);
      }
    }

    throw ApiResponseException.fromResponse(response);
  }

  static Future<List<Report>> getCompleteReports() async {
    final response = await ApiClient.instance.get(
      path: '/Reports/complete-reports',
    );

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body) as List<dynamic>;
        return json
            .map((item) => Report.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        throw ParseException(originalError: e);
      }
    }

    throw ApiResponseException.fromResponse(response);
  }

  static Future<void> deleteReport(int reportId) async {
    final response = await ApiClient.instance.delete(
      path: '/Reports/$reportId',
      useToken: true,
    );

    if (response.statusCode != 204) {
      throw ApiResponseException.fromResponse(response);
    }
  }

  static Future<void> deleteAllReportImages(int reportId) async {
    final response = await ApiClient.instance.delete(
      path: '/Reports/$reportId/images',
      useToken: true,
    );

    if (response.statusCode != 204) {
      throw ApiResponseException.fromResponse(response);
    }
  }
}
