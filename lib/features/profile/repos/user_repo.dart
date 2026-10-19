import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/common/models/network_result.dart';
import '../../../core/providers/core_provider.dart';
import '../model/profile_model.dart';

final userRepoProvider = Provider.autoDispose<UserRepo>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return UserRepoImpl(apiClient: apiClient);
});

abstract class UserRepo {
  NetworkStream<ProfileModel> getProfile({bool forceRefresh = false});

  NetworkResult<void> updateProfile({
    required String fullName,
    required String phoneNumber,
    required String address,
    File? profileImage,
  });

  NetworkResult<void> changePassword({
    required String currentPass,
    required String newPass,
    required String confirmPass,
  });

  NetworkResult<void> delete({required String reason});
}

class UserRepoImpl implements UserRepo {
  final ApiClient apiClient;

  const UserRepoImpl({required this.apiClient});

  @override
  NetworkStream<ProfileModel> getProfile({bool forceRefresh = false}) {
    return apiClient.getStream(
      endpoint: ApiConstants.user.profile,
      cacheDuration: const Duration(days: 30),
      forceEmitRemote: forceRefresh,
      fromJsonT: (json) => ProfileModel.fromJson(json),
    );
  }

  @override
  NetworkResult<void> updateProfile({
    required String fullName,
    required String phoneNumber,
    required String address,
    File? profileImage,
  }) async {
    final formData = FormData.fromMap({
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      if (profileImage != null)
        'profileImage': await MultipartFile.fromFile(
          profileImage.path,
          filename: profileImage.path.split('/').last,
        ),
    });

    return apiClient.patch<void>(
      endpoint: ApiConstants.user.profile,
      formData: formData,
      fromJsonT: (json) => json,
    );
  }

  @override
  NetworkResult<void> changePassword({
    required String currentPass,
    required String newPass,
    required String confirmPass,
  }) async {
    return apiClient.patch(
      endpoint: ApiConstants.user.changePass,
      data: {
        "currentPassword": currentPass,
        "newPassword": newPass,
        "confirmPassword": confirmPass,
      },
      fromJsonT: (json) => {},
    );
  }

  @override
  NetworkResult<void> delete({required String reason}) {
    return apiClient.delete(
      endpoint: ApiConstants.user.delete,
      data: {"reason": reason},
      fromJsonT: (json) => json,
    );
  }
}
