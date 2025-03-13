import "package:http/http.dart";

class ApiException implements Exception {
  factory ApiException.fromResponse(Response response) {
    final regex = RegExp('"errorCode":"(.*?)"');
    final match = regex.firstMatch(response.body);

    if (match != null) {
      return ApiException._(
        errorCode: match.group(1)!,
        statusCode: response.statusCode,
      );
    } else {
      return ApiException._(
        errorCode: response.statusCode.toString(),
        statusCode: response.statusCode,
      );
    }
  }

  ApiException._({
    required this.errorCode,
    required this.statusCode,
  });

  final String errorCode;
  final int statusCode;

  @override
  String toString() => errorCode;
}
