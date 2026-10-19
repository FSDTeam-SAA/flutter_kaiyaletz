import 'package:json_annotation/json_annotation.dart';

import '../../auth/model/login_response_model.dart';

part 'profile_model.g.dart';

/// User data returned by `GET /user/profile`. Distinct from [UserModel]
/// (the login response) because the two endpoints return different shapes.
@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class ProfileModel {
  @JsonKey(name: '_id', required: true, disallowNullValue: true)
  final String id;

  @JsonKey(required: false, disallowNullValue: true)
  final String firstName;

  @JsonKey(required: false, disallowNullValue: true)
  final String lastName;

  @JsonKey(required: true, disallowNullValue: true)
  final String email;

  @JsonKey(required: true, disallowNullValue: true)
  final String phoneNumber;

  @JsonKey(required: true, disallowNullValue: true)
  final String address;

  @JsonKey(required: true, disallowNullValue: true)
  final ProfileImage profileImage;

  @JsonKey(required: true, disallowNullValue: true)
  final String role;

  /// An owner account has no owner, so this field legitimately accepts null.
  final String? ownerId;

  @JsonKey(required: true, disallowNullValue: true)
  final bool isSuspended;

  @JsonKey(required: true, disallowNullValue: true)
  final bool isEmailVerified;

  @JsonKey(required: true, disallowNullValue: true)
  final int totalJobs;

  @JsonKey(required: true, disallowNullValue: true)
  final DateTime memberSince;

  @JsonKey(required: true, disallowNullValue: true)
  final DateTime createdAt;

  @JsonKey(required: true, disallowNullValue: true)
  final DateTime updatedAt;

  @JsonKey(name: '__v', required: true, disallowNullValue: true)
  final int v;

  @JsonKey(required: true, disallowNullValue: true)
  final Notifications notifications;

  const ProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.profileImage,
    required this.role,
    this.ownerId,
    required this.isSuspended,
    required this.isEmailVerified,
    required this.totalJobs,
    required this.memberSince,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.notifications,
  });

  String get fullName => "$firstName $lastName";

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}
