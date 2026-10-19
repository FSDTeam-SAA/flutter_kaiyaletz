import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_kaiyaletz/core/utils/d_print.dart';

import '../constants/api_constants.dart';
import '../common/models/session_status.dart';
import 'dio_error_handler.dart';
import '../common/models/base_response.dart';
import '../common/models/network_failure.dart';
import '../common/models/network_success.dart';
import '../services/api_cache_service.dart';
import '../services/auth_storage_service.dart';
import '../services/connectivity_service.dart';
import '../services/request_queue_service.dart';

/// Dio-based REST client. Framework-agnostic — nothing in this file knows
/// about GetX, Riverpod, or any other state-management package. Wire it up
/// once (see riverpod_providers.dart) and every repo just takes an
/// [ApiClient] in its constructor.
///
/// Features:
///  - Standard envelope parsing via [BaseResponse]
///  - Automatic Bearer header + silent token refresh on 401, with pending
///    requests queued while a refresh is already in flight
///  - Proactive refresh when only the refresh token survives, so a
///    request doesn't have to fail once before recovering
///  - A guest session (no tokens) is never treated as an expired one —
///    see [onAuthRequired] vs [onSessionExpired] and [sessionStatusStream]
///  - Optional offline queueing for mutating requests ([useQueue])
///  - Optional cache-then-network streaming for GET requests ([getStream])
///  - Typed [NetworkFailure] subtypes instead of raw exceptions
class ApiClient {
  final Dio dio;
  final ConnectivityService _connectivityService;
  final ApiCacheService _cacheService;
  final AuthStorageService _authStorageService;
  final RequestQueueService _requestQueue;

  bool _isRefreshing = false;
  final List<Completer<void>> _pendingRequests = [];

  final StreamController<SessionStatus> _sessionController =
      StreamController<SessionStatus>.broadcast();

  /// Emits whenever the session state changes (login, forced logout, a
  /// guest hitting a protected endpoint). Use this to drive route guards
  /// instead of gating every screen manually:
  ///
  /// ```dart
  /// final sessionStatusProvider = StreamProvider<SessionStatus>((ref) {
  ///   return ref.watch(apiClientProvider).sessionStatusStream;
  /// });
  /// ```
  ///
  /// Most routes should never read this at all — only ones you've
  /// explicitly marked as requiring login.
  Stream<SessionStatus> get sessionStatusStream => _sessionController.stream;

  /// Called when a real session (had at least one token) could not be
  /// recovered. Clears storage + cache first, so by the time this fires
  /// the app is already back to a clean guest state — wire it to
  /// navigation, e.g. `ApiClient.onSessionExpired = () => router.go('/login');`
  static void Function()? onSessionExpired;

  /// Called when a request needed auth but there was no session at all
  /// (true guest). Nothing is cleared — there's nothing to clear. Wire
  /// this to something soft: show a login prompt, or let the calling
  /// feature disable itself. Never force-navigate away from where the
  /// guest currently is.
  static void Function()? onAuthRequired;

  ApiClient({
    required this._connectivityService,
    required this._cacheService,
    required this._authStorageService,
    required this._requestQueue,
    String? baseUrl,
  }) : dio = Dio(
         BaseOptions(
           baseUrl: baseUrl ?? ApiConstants.baseUrl,
           connectTimeout: const Duration(seconds: 60),
           receiveTimeout: const Duration(seconds: 60),
           sendTimeout: const Duration(seconds: 60),
           headers: const {
             'Content-Type': 'application/json',
             'Accept': 'application/json',
           },
           validateStatus: (status) => status != null && status < 400,
         ),
       );

  void _log(String message) {
    if (kDebugMode) developer.log(message, name: 'ApiClient');
  }

  String _fullUrl(String endpoint) => '${dio.options.baseUrl}$endpoint';

  void _logRequest({required String method, required String endpoint}) {
    if (!kDebugMode) return;
    DPrint.log('➡️  $method ${_fullUrl(endpoint)}');
  }

  void _logResponse({
    required String method,
    required String endpoint,
    required int? statusCode,
    required bool success,
    required String message,
  }) {
    if (!kDebugMode) return;
    final icon = success ? '✅' : '⚠️';
    DPrint.log('$icon  $method ${_fullUrl(endpoint)} [$statusCode] — $message');
  }

  void _logApiError({
    required String method,
    required String endpoint,
    required Object error,
    int? statusCode,
  }) {
    if (!kDebugMode) return;
    DPrint.error(
      '❌  $method ${_fullUrl(endpoint)} [${statusCode ?? '-'}] — $error',
    );
  }

  void dispose() {
    _sessionController.close();
  }

  Future<Either<NetworkFailure, void>> _checkConnectivity() async {
    if (!_connectivityService.isConnected) {
      try {
        await _connectivityService.waitForConnection(
          timeout: const Duration(seconds: 2),
        );
      } catch (_) {
        return const Left(NoInternetFailure());
      }
    }
    return const Right(null);
  }

  /// Attempts a refresh. Distinguishes three cases before ever calling
  /// the network:
  ///  - no tokens at all              → guest, not an error → [onAuthRequired]
  ///  - access token but no refresh   → real session, unrecoverable → expired
  ///  - refresh token present         → actually try the network call
  Future<bool> _refreshToken() async {
    final refreshToken = await _authStorageService.getRefreshToken();
    final accessToken = await _authStorageService.getAccessToken();

    if (refreshToken == null || refreshToken.isEmpty) {
      if (accessToken == null || accessToken.isEmpty) {
        // Neither token — this was never a session. Don't wipe anything,
        // don't force a redirect. Let the caller decide what a guest
        // sees when a protected feature 401s.
        _sessionController.add(.guest);
        onAuthRequired?.call();
        return false;
      }
      // Access token but no refresh token — this WAS a session, and it
      // can't be recovered without one.
      await _handleSessionExpired();
      return false;
    }

    try {
      final response = await dio.post(
        ApiConstants.auth.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final baseResponse = BaseResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json,
      );

      if (baseResponse.success && baseResponse.data != null) {
        final newAccessToken = baseResponse.data!['accessToken'] as String;
        final newRefreshToken = baseResponse.data!['refreshToken'] as String;

        await _authStorageService.storeAccessToken(accessToken: newAccessToken);
        await _authStorageService.storeRefreshToken(
          refreshToken: newRefreshToken,
        );
        _sessionController.add(.authenticated);
        return true;
      }

      // Server responded but rejected the refresh token (revoked/expired).
      await _handleSessionExpired();
      return false;
    } catch (e) {
      _log('Refresh token error: $e');
      await _handleSessionExpired();
      return false;
    }
  }

  Future<void> _handleSessionExpired() async {
    await _authStorageService.clearAuthData();
    await _cacheService.clearAllCache();
    _sessionController.add(.expired);
    onSessionExpired?.call();
  }

  /// Attaches the Bearer header. If the access token is missing but a
  /// refresh token is present, refreshes proactively first — this is the
  /// "refresh-only" state (app was killed mid-session, access token
  /// cleared but refresh survived) and would otherwise send one request
  /// unauthenticated, get a wasted 401, and only then recover.
  Future<Options> _addAuthHeader(Options? options) async {
    options ??= Options();

    var accessToken = await _authStorageService.getAccessToken();
    final hasAccess = accessToken != null && accessToken.isNotEmpty;

    // Claim the refresh slot in the same synchronous step as the check —
    // no `await` between reading `_isRefreshing` and setting it, so two
    // concurrent requests can't both slip through and start their own
    // refresh call.
    if (!hasAccess && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await _authStorageService.getRefreshToken();
        final hasRefresh = refreshToken != null && refreshToken.isNotEmpty;

        if (hasRefresh) {
          if (await _refreshToken()) {
            accessToken = await _authStorageService.getAccessToken();
          }
        }
      } finally {
        _isRefreshing = false;
        for (final completer in _pendingRequests) {
          completer.complete();
        }
        _pendingRequests.clear();
      }
    }

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers ??= {};
      options.headers!['Authorization'] = 'Bearer $accessToken';
    }
    return options;
  }

  NetworkFailure _handleDioError(DioException error) {
    if (error.response != null) {
      try {
        final responseData = error.response?.data;
        if (responseData is Map) {
          if (responseData.containsKey('errorSources')) {
            final baseResponse = BaseResponse<void>.fromJson(
              responseData as Map<String, dynamic>,
              (json) {},
            );
            if (baseResponse.errorSources != null &&
                baseResponse.errorSources!.isNotEmpty) {
              return ValidationFailure(
                message: baseResponse.combinedErrorMessage,
                errors: baseResponse.errorSources!
                    .map((e) => e.message)
                    .toList(),
                statusCode: error.response?.statusCode ?? 400,
              );
            }
            return ServerFailure(
              message: baseResponse.combinedErrorMessage,
              statusCode: error.response?.statusCode ?? 400,
            );
          }
          if (responseData.containsKey('message')) {
            return ServerFailure(
              message: responseData['message'] as String,
              statusCode: error.response?.statusCode ?? 400,
            );
          }
        }
      } catch (e) {
        _log('Error parsing error response: $e');
      }
    }

    switch (error.type) {
      case .connectionTimeout:
      case .sendTimeout:
      case .receiveTimeout:
        return TimeoutFailure(
          message: dioErrorToUserMessage(error),
          statusCode: error.response?.statusCode ?? 408,
        );
      case .connectionError:
        return const ConnectionFailure(message: 'No internet connection');
      default:
        if (error.response?.statusCode == 401) {
          return UnauthorizedFailure(
            message: dioErrorToUserMessage(error),
            statusCode: 401,
          );
        }
        return ServerFailure(
          message: dioErrorToUserMessage(error),
          statusCode: error.response?.statusCode ?? 0,
        );
    }
  }

  /// Core request method. Every HTTP verb below is a thin wrapper over this.
  Future<Either<NetworkFailure, NetworkSuccess<T>>> _request<T>({
    required String method,
    required String endpoint,
    required T Function(dynamic) fromJsonT,
    dynamic data,
    FormData? formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Duration? cacheDuration,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final bool isGet = method.toUpperCase() == 'GET';
    final bool cache = isGet && cacheDuration != null;

    final connectivityCheck = await _checkConnectivity();
    if (connectivityCheck.isLeft()) {
      if (cache) {
        final cachedData = await _cacheService.getCachedData(
          endpoint,
          requestData: queryParameters,
        );
        if (cachedData != null) {
          return Right(
            NetworkSuccess<T>(
              data: fromJsonT(cachedData),
              message: 'Served from cache (offline)',
              statusCode: 200,
              isFromCache: true,
            ),
          );
        }
      }
      return const Left(NoInternetFailure());
    }

    try {
      // If a token refresh is in flight, wait for it before firing this
      // request with the (possibly new) token.
      if (_isRefreshing) {
        final completer = Completer<void>();
        _pendingRequests.add(completer);
        await completer.future;
      }

      options = await _addAuthHeader(options);
      final requestData = formData ?? data;

      _logRequest(method: method, endpoint: endpoint);

      final response = await dio.request(
        endpoint,
        data: requestData,
        queryParameters: queryParameters,
        options: options..method = method,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      final baseResponse = BaseResponse<T>.fromJson(response.data, fromJsonT);

      _logResponse(
        method: method,
        endpoint: endpoint,
        statusCode: response.statusCode,
        success: baseResponse.success,
        message: baseResponse.message,
      );

      if (baseResponse.success) {
        final successResult = NetworkSuccess<T>(
          data: baseResponse.data as T,
          message: baseResponse.message,
          pagination: baseResponse.pagination,
          meta: baseResponse.meta,
          statusCode: response.statusCode ?? 200,
        );

        if (cache) {
          final rawData = (response.data as Map<String, dynamic>?)?['data'];
          if (rawData != null) {
            await _cacheService.cacheData(
              endpoint,
              data: rawData,
              requestData: queryParameters,
              cacheDuration: cacheDuration,
            );
          }
        }

        return Right(successResult);
      }

      return Left(
        ServerFailure(
          message: baseResponse.combinedErrorMessage,
          statusCode: response.statusCode ?? 400,
        ),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 401 && !_isRefreshing) {
        _isRefreshing = true;
        try {
          if (await _refreshToken()) {
            return _request<T>(
              method: method,
              endpoint: endpoint,
              fromJsonT: fromJsonT,
              data: data,
              formData: formData,
              queryParameters: queryParameters,
              options: options,
              cancelToken: cancelToken,
              onSendProgress: onSendProgress,
              onReceiveProgress: onReceiveProgress,
            );
          }
        } finally {
          _isRefreshing = false;
          for (final completer in _pendingRequests) {
            completer.complete();
          }
          _pendingRequests.clear();
        }
      }
      _logApiError(
        method: method,
        endpoint: endpoint,
        error: error,
        statusCode: error.response?.statusCode,
      );
      return Left(_handleDioError(error));
    } catch (e) {
      _log('Unexpected error: $e');
      _logApiError(method: method, endpoint: endpoint, error: e);
      return const Left(
        UnknownFailure(message: 'An unexpected error occurred'),
      );
    }
  }

  bool _isDataUpdated(dynamic oldData, dynamic newData) {
    try {
      if (oldData is Map && newData is Map) {
        final oldUpdate = oldData['updatedAt'];
        final newUpdate = newData['updatedAt'];
        if (oldUpdate != null && newUpdate != null) {
          return oldUpdate.toString() != newUpdate.toString();
        }
      }
      return jsonEncode(oldData) != jsonEncode(newData);
    } catch (_) {
      return true;
    }
  }

  /// Cache-then-network GET, for screens that should show something
  /// instantly while a fresh copy loads in the background.
  ///
  /// Emits:
  ///  1. The cached value (if any) with `isFromCache: true`
  ///  2. The network value, but ONLY if it differs from the cached value
  ///     (compares `updatedAt` when present, otherwise a full JSON diff)
  ///     — unless [forceEmitRemote] is true.
  Stream<Either<NetworkFailure, NetworkSuccess<T>>> _streamRequest<T>({
    required String endpoint,
    required T Function(dynamic) fromJsonT,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Duration? cacheDuration,
    bool forceEmitRemote = false,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async* {
    dynamic cachedRawData;

    if (cacheDuration != null) {
      cachedRawData = await _cacheService.getCachedData(
        endpoint,
        requestData: queryParameters,
      );
      if (cachedRawData != null) {
        yield Right(
          NetworkSuccess<T>(
            data: fromJsonT(cachedRawData),
            message: 'Served from cache',
            statusCode: 200,
            isFromCache: true,
          ),
        );
      }
    }

    final result = await _request<T>(
      method: 'GET',
      endpoint: endpoint,
      fromJsonT: fromJsonT,
      queryParameters: queryParameters,
      options: options,
      cacheDuration: cacheDuration,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );

    if (result.isRight()) {
      final success = result.getOrElse(() => throw StateError('unreachable'));
      final remoteRawData = await _cacheService.getCachedData(
        endpoint,
        requestData: queryParameters,
      );

      final isUpdated = (cachedRawData != null && remoteRawData != null)
          ? _isDataUpdated(cachedRawData, remoteRawData)
          : true;

      if (isUpdated || cachedRawData == null || forceEmitRemote) {
        yield Right(success);
      }
    } else {
      yield result;
    }
  }

  // ---------------------------------------------------------------------
  // Public HTTP verbs
  // ---------------------------------------------------------------------

  /// GETs a binary file (e.g. a PDF) from our API into [savePath], with
  /// the same auth and refresh handling as [get]. Succeeds with the path.
  Future<Either<NetworkFailure, NetworkSuccess<String>>> downloadFile({
    required String endpoint,
    required String savePath,
    bool isRetry = false,
  }) async {
    final connectivity = await _checkConnectivity();
    if (connectivity.isLeft()) return const Left(NoInternetFailure());

    try {
      if (_isRefreshing) {
        final completer = Completer<void>();
        _pendingRequests.add(completer);
        await completer.future;
      }

      final options = await _addAuthHeader(null);
      _logRequest(method: 'GET', endpoint: endpoint);
      final response = await dio.download(endpoint, savePath, options: options);
      return Right(
        NetworkSuccess<String>(
          data: savePath,
          message: 'Downloaded',
          statusCode: response.statusCode ?? 200,
        ),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 401 && !_isRefreshing && !isRetry) {
        _isRefreshing = true;
        try {
          if (await _refreshToken()) {
            return downloadFile(
              endpoint: endpoint,
              savePath: savePath,
              isRetry: true,
            );
          }
        } finally {
          _isRefreshing = false;
          for (final completer in _pendingRequests) {
            completer.complete();
          }
          _pendingRequests.clear();
        }
      }
      _logApiError(
        method: 'GET',
        endpoint: endpoint,
        error: error,
        statusCode: error.response?.statusCode,
      );
      return Left(_handleDioError(error));
    } catch (e) {
      _logApiError(method: 'GET', endpoint: endpoint, error: e);
      return const Left(
        UnknownFailure(message: 'An unexpected error occurred'),
      );
    }
  }

  Future<Either<NetworkFailure, NetworkSuccess<T>>> get<T>({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJsonT,
    Options? options,
    CancelToken? cancelToken,

    /// Pass a duration to cache this GET's response for offline use.
    Duration? cacheDuration,
    ProgressCallback? onReceiveProgress,
  }) {
    return _request(
      method: 'GET',
      endpoint: endpoint,
      fromJsonT: fromJsonT,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      cacheDuration: cacheDuration,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Cache-then-network GET. See [_streamRequest] for emission rules.
  Stream<Either<NetworkFailure, NetworkSuccess<T>>> getStream<T>({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJsonT,
    Options? options,
    CancelToken? cancelToken,
    Duration? cacheDuration,
    bool forceEmitRemote = false,
    ProgressCallback? onReceiveProgress,
  }) {
    return _streamRequest(
      endpoint: endpoint,
      fromJsonT: fromJsonT,
      queryParameters: queryParameters,
      options: options,
      cacheDuration: cacheDuration,
      forceEmitRemote: forceEmitRemote,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// Type-erased GET/POST/etc, used by [RequestQueueService] to replay a
  /// queued request without caring what shape the response is.
  Future<Either<NetworkFailure, NetworkSuccess<dynamic>>> requestGeneric({
    required String method,
    required String endpoint,
    dynamic data,
  }) {
    return _request<dynamic>(
      method: method,
      endpoint: endpoint,
      fromJsonT: (json) => json,
      data: data,
    );
  }

  Future<Either<NetworkFailure, NetworkSuccess<T>>> post<T>({
    required String endpoint,
    dynamic data,
    required T Function(dynamic) fromJsonT,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    FormData? formData,

    /// Cache keys to drop after a successful call (e.g. invalidate a list
    /// endpoint after creating an item in it).
    List<String>? invalidatePaths,

    /// If true and the device is offline, queue this request instead of
    /// failing immediately. It's replayed automatically on reconnect.
    /// Only use for requests that are safe to run later without the user
    /// watching (an update, not a payment).
    bool useQueue = false,
  }) async {
    if (useQueue) {
      final connectivity = await _checkConnectivity();
      if (connectivity.isLeft()) {
        await _requestQueue.addToQueue(
          method: 'POST',
          endpoint: endpoint,
          data: data,
        );
        return const Left(NoInternetFailure());
      }
    }

    final result = await _request<T>(
      method: 'POST',
      endpoint: endpoint,
      fromJsonT: fromJsonT,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      formData: formData,
    );

    if (result.isRight() && invalidatePaths != null) {
      for (final path in invalidatePaths) {
        await _cacheService.clearCache(path);
      }
    }
    return result;
  }

  Future<Either<NetworkFailure, NetworkSuccess<T>>> patch<T>({
    required String endpoint,
    dynamic data,
    required T Function(dynamic) fromJsonT,
    Options? options,
    CancelToken? cancelToken,
    FormData? formData,
    List<String>? invalidatePaths,
    bool useQueue = false,
  }) async {
    if (useQueue) {
      final connectivity = await _checkConnectivity();
      if (connectivity.isLeft()) {
        await _requestQueue.addToQueue(
          method: 'PATCH',
          endpoint: endpoint,
          data: data,
        );
        return const Left(NoInternetFailure());
      }
    }

    final result = await _request<T>(
      method: 'PATCH',
      endpoint: endpoint,
      fromJsonT: fromJsonT,
      data: data,
      options: options,
      cancelToken: cancelToken,
      formData: formData,
    );

    if (result.isRight() && invalidatePaths != null) {
      for (final path in invalidatePaths) {
        await _cacheService.clearCache(path);
      }
    }
    return result;
  }

  Future<Either<NetworkFailure, NetworkSuccess<T>>> put<T>({
    required String endpoint,
    dynamic data,
    required T Function(dynamic) fromJsonT,
    Options? options,
    CancelToken? cancelToken,
    FormData? formData,
    List<String>? invalidatePaths,
    bool useQueue = false,
  }) async {
    if (useQueue) {
      final connectivity = await _checkConnectivity();
      if (connectivity.isLeft()) {
        await _requestQueue.addToQueue(
          method: 'PUT',
          endpoint: endpoint,
          data: data,
        );
        return const Left(NoInternetFailure());
      }
    }

    final result = await _request<T>(
      method: 'PUT',
      endpoint: endpoint,
      fromJsonT: fromJsonT,
      data: data,
      options: options,
      cancelToken: cancelToken,
      formData: formData,
    );

    if (result.isRight() && invalidatePaths != null) {
      for (final path in invalidatePaths) {
        await _cacheService.clearCache(path);
      }
    }
    return result;
  }

  Future<Either<NetworkFailure, NetworkSuccess<T>>> delete<T>({
    required String endpoint,
    dynamic data,
    required T Function(dynamic) fromJsonT,
    Options? options,
    CancelToken? cancelToken,
    List<String>? invalidatePaths,
    bool useQueue = false,
  }) async {
    if (useQueue) {
      final connectivity = await _checkConnectivity();
      if (connectivity.isLeft()) {
        await _requestQueue.addToQueue(
          method: 'DELETE',
          endpoint: endpoint,
          data: data,
        );
        return const Left(NoInternetFailure());
      }
    }

    final result = await _request<T>(
      method: 'DELETE',
      endpoint: endpoint,
      fromJsonT: fromJsonT,
      data: data,
      options: options,
      cancelToken: cancelToken,
    );

    if (result.isRight() && invalidatePaths != null) {
      for (final path in invalidatePaths) {
        await _cacheService.clearCache(path);
      }
    }
    return result;
  }

  ConnectivityService get connectivityService => _connectivityService;
}
