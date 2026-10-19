import 'package:dio/dio.dart';

/// Turns a raw [DioException] into a message a user could actually read.
/// [ApiClient] only falls back to this when the response body has no
/// `message` field of its own.
String dioErrorToUserMessage(DioException error) {
  if (error.response != null) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }

    switch (error.response?.statusCode) {
      case 400:
        return 'Bad request — please check your input';
      case 401:
        return 'Unauthorized — please log in again';
      case 403:
        return "Forbidden — you don't have permission";
      case 404:
        return 'Resource not found';
      case 429:
        return 'Too many requests — please slow down';
      case 500:
        return 'Server error — please try again later';
      case 502:
        return 'Bad gateway — service temporarily unavailable';
      case 503:
        return 'Service unavailable — please try again later';
      case 504:
        return 'Gateway timeout — please try again';
    }
  }

  switch (error.type) {
    case .connectionTimeout:
      return 'Connection timed out. Please try again.';
    case .sendTimeout:
      return 'Request timed out. Please check your network.';
    case .receiveTimeout:
      return 'Server took too long to respond.';
    case .badCertificate:
      return 'Invalid server certificate.';
    case .badResponse:
      return 'Server error occurred.';
    case .cancel:
      return 'Request was cancelled.';
    case .connectionError:
      return 'No internet connection.';
    case .unknown:
      return 'Something went wrong. Please try again.';
    case .transformTimeout:
      return 'Response processing timed out. Please try again.';
  }
}
