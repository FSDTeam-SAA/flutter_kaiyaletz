import 'package:flutter_kaiyaletz/core/api/api_client.dart';
import 'package:flutter_kaiyaletz/core/common/models/network_result.dart';
import 'package:flutter_kaiyaletz/core/constants/api_constants.dart';
import 'package:flutter_kaiyaletz/core/providers/core_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationRepo = Provider<NotificationRepo>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return NotificationRepoImpl(apiClient: apiClient);
});

abstract class NotificationRepo {
  NetworkResult<void> updateNotifications(Map<String, bool> settings);
}

class NotificationRepoImpl implements NotificationRepo {
  final ApiClient apiClient;

  NotificationRepoImpl({required this.apiClient});

  static const _apiKeyFor = {
    'Push Notifications': 'push',
    'Loan Notifications': 'loan',
    'Transaction Notifications': 'transaction',
    'Fund Notifications': 'fund',
    'Support Notifications': 'support',
  };

  @override
  NetworkResult<void> updateNotifications(Map<String, bool> settings) {
    final body = {
      for (final entry in settings.entries) _apiKeyFor[entry.key]!: entry.value,
    };

    return apiClient.patch(
      endpoint: ApiConstants.user.notification,
      data: body,
      fromJsonT: (json) => json,
    );
  }
}
