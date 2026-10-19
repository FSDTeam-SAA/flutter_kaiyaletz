import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_kaiyaletz/core/api/api_client.dart';
import 'package:flutter_kaiyaletz/core/common/models/network_result.dart';
import 'package:flutter_kaiyaletz/core/constants/api_constants.dart';
import 'package:flutter_kaiyaletz/core/providers/core_provider.dart';
import 'package:flutter_kaiyaletz/features/job/models/job_create_response_model.dart';
import 'package:flutter_kaiyaletz/features/job/models/layout_model.dart';
import 'package:flutter_kaiyaletz/features/measure/model/room_spec.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/single_job_reponse_model.dart';

final jobRepo = Provider<JobRepo>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return JobRepoImpl(apiClient: apiClient);
});

class SelectedProductInput {
  final String productId;
  final int quantity;
  const SelectedProductInput({required this.productId, this.quantity = 1});

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
  };
}

abstract class JobRepo {
  NetworkResult<JobModel> createJob({
    required DateTime date,
    required String customerName,
    required String propertyAddress,
    required String phoneNumber,
    required String emailAddress,
    required String notes,
  });

  NetworkStream<List<JobModel>> getJobs({
    String search = "",
    String? status,
    int page = 1,
    int limit = 20,
  });
  NetworkResult<SingleJobResponseModel> getSingleJob({required String jobId});

  // Step 2: method is "Room Scan" | "Manual"
  NetworkResult<Map<String, dynamic>> saveRoomCapture({
    required String jobId,
    String method = 'Room Scan',
  });

  // Step 3
  NetworkResult<Map<String, dynamic>> saveMeasurements({
    required String jobId,
    required RoomSpec room,
  });

  // Step 4
  NetworkResult<Map<String, dynamic>> saveSelectedProducts({
    required String jobId,
    required List<SelectedProductInput> products,
  });

  // Step 5 (no body)
  NetworkResult<Map<String, dynamic>> generateAILayout({required String jobId});

  // Step 6 (multipart): the rearranged layout plus its elevation PNG.
  NetworkResult<Map<String, dynamic>> saveDesign({
    required String jobId,
    required JobLayout layout,
    Uint8List? layoutPng,
  });

  // Step 7
  NetworkResult<Map<String, dynamic>> saveEstimate({
    required String jobId,
    num installationCharge = 0,
    num deliveryCharge = 0,
    num taxRate = 10,
  });

  // Step 8
  NetworkResult<Map<String, dynamic>> generateProposal({
    required String jobId,
    String? terms,
  });

  // Step 8: saves the private proposal PDF to [savePath]. Generate first.
  NetworkResult<String> downloadProposalPdf({
    required String jobId,
    required String savePath,
  });

  // Add a catalog product to a job
  NetworkResult<Map<String, dynamic>> addProductToJob({
    required String jobId,
    required String productId,
    int quantity = 1,
  });
}

class JobRepoImpl implements JobRepo {
  final ApiClient apiClient;
  JobRepoImpl({required this.apiClient});

  @override
  NetworkResult<JobModel> createJob({
    required DateTime date,
    required String customerName,
    required String propertyAddress,
    required String phoneNumber,
    required String emailAddress,
    required String notes,
  }) {
    return apiClient.post(
      endpoint: ApiConstants.job.job,
      data: {
        "date": date.toIso8601String(),
        "customerName": customerName,
        "propertyAddress": propertyAddress,
        "phoneNumber": phoneNumber,
        "emailAddress": emailAddress,
        "notes": notes,
      },
      fromJsonT: (json) => JobModel.fromJson(json),
    );
  }

  @override
  NetworkStream<List<JobModel>> getJobs({
    String search = "",
    String? status,
    int page = 1,
    int limit = 20,
  }) {
    return apiClient.getStream(
      endpoint: ApiConstants.job.job,
      queryParameters: {
        if (search.isNotEmpty) "search": search,
        if (status != null && status.isNotEmpty) "status": status,
        "page": page,
        "limit": limit,
      },
      fromJsonT: (json) =>
          (json as List).map((item) => JobModel.fromJson(item)).toList(),
    );
  }

  @override
  NetworkResult<SingleJobResponseModel> getSingleJob({String jobId = ""}) {
    return apiClient.get<SingleJobResponseModel>(
      endpoint: ApiConstants.job.jobById(jobId),
      fromJsonT: (json) => SingleJobResponseModel.fromJson(json),
    );
  }

  @override
  NetworkResult<Map<String, dynamic>> saveRoomCapture({
    required String jobId,
    String method = 'Room Scan',
  }) {
    return apiClient.patch<Map<String, dynamic>>(
      endpoint: ApiConstants.job.saveRoomCapture(jobId),
      data: {'method': method},
      fromJsonT: (json) => json,
    );
  }

  @override
  NetworkResult<Map<String, dynamic>> saveMeasurements({
    required String jobId,
    required RoomSpec room,
  }) {
    return apiClient.patch<Map<String, dynamic>>(
      endpoint: ApiConstants.job.saveMeasurements(jobId),
      data: {'room': room.toJson()},
      fromJsonT: (json) => json,
    );
  }

  @override
  NetworkResult<Map<String, dynamic>> saveSelectedProducts({
    required String jobId,
    required List<SelectedProductInput> products,
  }) {
    return apiClient.patch<Map<String, dynamic>>(
      endpoint: ApiConstants.job.saveSelectedProducts(jobId),
      data: {'products': products.map((p) => p.toJson()).toList()},
      fromJsonT: (json) => json,
    );
  }

  @override
  NetworkResult<Map<String, dynamic>> generateAILayout({
    required String jobId,
  }) {
    return apiClient.patch<Map<String, dynamic>>(
      endpoint: ApiConstants.job.generateAILayout(jobId),
      fromJsonT: (json) => json,
    );
  }

  @override
  NetworkResult<Map<String, dynamic>> saveDesign({
    required String jobId,
    required JobLayout layout,
    Uint8List? layoutPng,
  }) {
    // Multipart, so the layout travels as a JSON string. The backend only
    // reads positions from it. File field must be exactly "layoutImage"
    // (multer upload.single).
    final form = FormData.fromMap({
      'layout': jsonEncode(layout.toJson()),
      if (layoutPng != null)
        'layoutImage': MultipartFile.fromBytes(
          layoutPng,
          filename: 'layout.png',
          contentType: DioMediaType('image', 'png'),
        ),
    });

    return apiClient.patch<Map<String, dynamic>>(
      endpoint: ApiConstants.job.saveDesign(jobId),
      formData: form,
      fromJsonT: (json) => json,
    );
  }

  @override
  NetworkResult<Map<String, dynamic>> saveEstimate({
    required String jobId,
    num installationCharge = 0,
    num deliveryCharge = 0,
    num taxRate = 10,
  }) {
    return apiClient.patch<Map<String, dynamic>>(
      endpoint: ApiConstants.job.saveEstimate(jobId),
      data: {
        'installationCharge': installationCharge,
        'deliveryCharge': deliveryCharge,
        'taxRate': taxRate,
      },
      fromJsonT: (json) => json,
    );
  }

  @override
  NetworkResult<Map<String, dynamic>> generateProposal({
    required String jobId,
    String? terms,
  }) {
    return apiClient.post<Map<String, dynamic>>(
      endpoint: ApiConstants.job.generateProposal(jobId),
      data: {if (terms != null && terms.isNotEmpty) 'terms': terms},
      fromJsonT: (json) => json,
    );
  }

  @override
  NetworkResult<String> downloadProposalPdf({
    required String jobId,
    required String savePath,
  }) {
    return apiClient.downloadFile(
      endpoint: ApiConstants.job.proposalPdf(jobId),
      savePath: savePath,
    );
  }

  @override
  NetworkResult<Map<String, dynamic>> addProductToJob({
    required String jobId,
    required String productId,
    int quantity = 1,
  }) {
    return apiClient.post<Map<String, dynamic>>(
      endpoint: ApiConstants.job.addProductToJob,
      data: {'jobId': jobId, 'productId': productId, 'quantity': quantity},
      fromJsonT: (json) => json,
    );
  }
}
