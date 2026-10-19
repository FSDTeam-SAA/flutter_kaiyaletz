import 'package:equatable/equatable.dart';

/// Base type for every way a request can fail.
/// Repos/notifiers switch on the concrete subtype to decide what to show.
class NetworkFailure extends Equatable {
  final String message;
  final int statusCode;

  const NetworkFailure({required this.message, required this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];

  @override
  String toString() => 'NetworkFailure($statusCode): $message';
}

/// Server responded with success: false and a generic message.
class ServerFailure extends NetworkFailure {
  const ServerFailure({required super.message, required super.statusCode});
}

/// Dio's connectionError (DNS, socket refused, etc.) with no response at all.
class ConnectionFailure extends NetworkFailure {
  const ConnectionFailure({required super.message, super.statusCode = 0});
}

/// Connect/send/receive timeout.
class TimeoutFailure extends NetworkFailure {
  const TimeoutFailure({required super.message, super.statusCode = 408});
}

/// 401 that survived a refresh attempt (or no refresh token was available).
class UnauthorizedFailure extends NetworkFailure {
  const UnauthorizedFailure({required super.message, super.statusCode = 401});
}

/// Field-level validation errors (`errorSources` in the response body).
class ValidationFailure extends NetworkFailure {
  final List<String> errors;

  const ValidationFailure({
    required super.message,
    required this.errors,
    super.statusCode = 400,
  });

  @override
  List<Object?> get props => [message, statusCode, errors];
}

/// [ConnectivityService] reported no network before the request was even sent.
class NoInternetFailure extends NetworkFailure {
  const NoInternetFailure()
    : super(message: 'No internet connection available', statusCode: 0);
}

/// Anything that doesn't fit the categories above (JSON parse errors, etc.).
class UnknownFailure extends NetworkFailure {
  const UnknownFailure({required super.message, super.statusCode = 0});
}
