import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Base class for all API exceptions
sealed class ApiException implements Exception {
  const ApiException({required this.message});

  final String message;

  @override
  String toString() => message;
}

/// Exception thrown when the server returns an error response
class ApiResponseException extends ApiException {
  factory ApiResponseException.fromResponse(http.Response response) {
    String? errorMessage;

    // Try to extract error message from JSON response
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      errorMessage = json['message'] as String? ??
                     json['error'] as String? ??
                     json['errorCode'] as String?;
    } catch (_) {
      // Response is not valid JSON
    }

    return ApiResponseException._(
      statusCode: response.statusCode,
      message: errorMessage ?? _getDefaultMessage(response.statusCode),
      body: response.body,
    );
  }

  const ApiResponseException._({
    required this.statusCode,
    required super.message,
    this.body,
  });

  final int statusCode;
  final String? body;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode >= 500;

  static String _getDefaultMessage(int statusCode) {
    return switch (statusCode) {
      400 => 'Solicitud inválida',
      401 => 'No autorizado. Por favor inicie sesión nuevamente.',
      403 => 'Acceso denegado',
      404 => 'Recurso no encontrado',
      408 => 'Tiempo de espera agotado',
      429 => 'Demasiadas solicitudes. Intente más tarde.',
      500 => 'Error interno del servidor',
      502 => 'Servidor no disponible',
      503 => 'Servicio no disponible',
      _ => 'Error del servidor ($statusCode)',
    };
  }

  @override
  String toString() => 'ApiResponseException($statusCode): $message';
}

/// Exception thrown when there's a network connectivity issue
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'Error de conexión. Verifique su conexión a internet.',
    this.originalError,
  });

  final Object? originalError;

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when the request times out
class TimeoutException extends ApiException {
  const TimeoutException({
    super.message = 'La solicitud tardó demasiado. Intente nuevamente.',
  });

  @override
  String toString() => 'TimeoutException: $message';
}

/// Exception thrown when response parsing fails
class ParseException extends ApiException {
  const ParseException({
    super.message = 'Error al procesar la respuesta del servidor',
    this.originalError,
  });

  final Object? originalError;

  @override
  String toString() => 'ParseException: $message';
}

/// Helper to convert common errors to ApiException
ApiException toApiException(Object error) {
  if (error is ApiException) return error;

  if (error is SocketException) {
    return NetworkException(originalError: error);
  }

  if (error is HttpException) {
    return NetworkException(
      message: 'Error de HTTP: ${error.message}',
      originalError: error,
    );
  }

  return NetworkException(
    message: 'Error inesperado: $error',
    originalError: error,
  );
}
