import 'package:dartz/dartz.dart';

import 'network_failure.dart';
import 'network_success.dart';

/// Return type of every single-shot request (get/post/patch/put/delete).
typedef NetworkResult<T> = Future<Either<NetworkFailure, NetworkSuccess<T>>>;

/// Return type of cache-then-network requests ([ApiClient.getStream]).
/// Emits the cached value first (if any and not stale), then the network
/// value once it arrives.
typedef NetworkStream<T> = Stream<Either<NetworkFailure, NetworkSuccess<T>>>;
