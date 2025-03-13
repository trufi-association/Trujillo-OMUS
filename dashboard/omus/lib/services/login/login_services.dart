import 'dart:convert';
import 'package:omus/services/api_exceptions.dart';
import 'package:omus/services/api_service.dart';
import 'package:omus/services/login/models/login_request.dart';

abstract class AuthenticationService {
  static Future<String> authenticate(LoginRequest body) async {
    final response = await ApiHelper.post(
      path: "/Auth/login",
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      final token = jsonDecode(response.body)["token"];
      ApiHelper.token = token;
      return token;
    }
    throw ApiException.fromResponse(response);
  }
}
