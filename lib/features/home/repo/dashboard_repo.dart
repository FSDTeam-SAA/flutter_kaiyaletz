import 'package:flutter_kaiyaletz/core/api/api_client.dart';
import 'package:flutter_kaiyaletz/core/common/models/network_result.dart';
import 'package:flutter_kaiyaletz/core/constants/api_constants.dart';
import 'package:flutter_kaiyaletz/core/providers/core_provider.dart';
import 'package:flutter_kaiyaletz/features/home/models/dashboard_response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardRepo = Provider<DashboardRepo>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DashboardRepoImpl(apiClient: apiClient);
});

abstract class DashboardRepo {
  NetworkResult<DashboardResponseModel> dashboard();
}

class DashboardRepoImpl implements DashboardRepo {
  final ApiClient apiClient;
  DashboardRepoImpl({required this.apiClient});

  @override
  NetworkResult<DashboardResponseModel> dashboard() {
    return apiClient.get(
      endpoint: ApiConstants.job.dashboard,
      fromJsonT: (json) => DashboardResponseModel.fromJson(json),
    );
  }
}
