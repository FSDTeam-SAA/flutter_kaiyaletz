import 'package:equatable/equatable.dart';

import 'pagination_model.dart';

/// Successful response envelope. [data] is already parsed via the
/// `fromJsonT` you pass to [ApiClient].
class NetworkSuccess<T> extends Equatable {
  final T data;
  final String message;
  final int statusCode;
  final PaginationModel? pagination;
  final Map<String, dynamic>? meta;

  /// True when this value came from the local cache rather than the
  /// network (only relevant for [ApiClient.getStream]).
  final bool isFromCache;

  const NetworkSuccess({
    required this.data,
    required this.message,
    required this.statusCode,
    this.pagination,
    this.meta,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [
    data,
    message,
    statusCode,
    pagination,
    meta,
    isFromCache,
  ];
}
