import 'error_source.dart';
import 'pagination_model.dart';

/// Parses the standard backend envelope:
/// `{ "success": true, "message": "...", "data": {...}, "pagination": {...} }`
class BaseResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<ErrorSource>? errorSources;
  final PaginationModel? pagination;
  final Map<String, dynamic>? meta;

  const BaseResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorSources,
    this.pagination,
    this.meta,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return BaseResponse<T>(
      // Accepts either `success` or `status` as the backend's ok flag.
      success: json['success'] ?? json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      errorSources: json['errorSources'] != null
          ? (json['errorSources'] as List)
                .map((e) => ErrorSource.fromJson(e))
                .toList()
          : null,
      // Some endpoints (e.g. products) send paging under `meta` instead.
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'])
          : (json['meta'] is Map<String, dynamic> &&
                    json['meta']['page'] != null
                ? PaginationModel.fromJson(json['meta'])
                : null),
      meta: json['meta'],
    );
  }

  /// Joins every field error into one string, falling back to [message]
  /// when there are no field-level errors.
  String get combinedErrorMessage {
    if (errorSources == null || errorSources!.isEmpty) return message;
    return errorSources!.map((e) => e.message).join('\n');
  }
}
