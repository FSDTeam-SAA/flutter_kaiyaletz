import 'package:flutter_kaiyaletz/core/common/models/network_result.dart';
import 'package:flutter_kaiyaletz/core/constants/api_constants.dart';
import 'package:flutter_kaiyaletz/core/providers/core_provider.dart';
import 'package:flutter_kaiyaletz/features/support/models/support_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';

final supportRepo = Provider<SupportRepo>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return SupportRepoImpl(apiClient: apiClient);
});

abstract class SupportRepo {
  NetworkResult<SupportModel> submitContactUs({
    required String fullName,
    required String email,
    required String contactNumber,
    required String note,
  });
}

class SupportRepoImpl implements SupportRepo {
  final ApiClient apiClient;

  const SupportRepoImpl({required this.apiClient});

  @override
  NetworkResult<SupportModel> submitContactUs({
    required String fullName,
    required String email,
    required String contactNumber,
    required String note,
  }) {
    return apiClient.post(
      endpoint: ApiConstants.support.contactUs,
      data: {
        "fullName": fullName,
        "email": email,
        "contactNumber": contactNumber,
        "note": note,
      },
      fromJsonT: (json) => SupportModel.fromJson(json),
    );
  }
}
