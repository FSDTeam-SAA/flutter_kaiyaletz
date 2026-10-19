import 'package:json_annotation/json_annotation.dart';

part 'login_response_model.g.dart';

/// Authenticated user and tokens in the login response's `data` object.
@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class UserModel {
  @JsonKey(name: '_id', required: true, disallowNullValue: true)
  final String id;

  // The supplied sample does not include `public_id`, so it is nullable.
  @JsonKey(name: 'public_id')
  final String? publicId;

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
  final bool isEmailVerified;

  @JsonKey(required: true, disallowNullValue: true)
  final Notifications notifications;

  @JsonKey(required: true, disallowNullValue: true)
  final String accessToken;

  @JsonKey(required: true, disallowNullValue: true)
  final String refreshToken;

  const UserModel({
    required this.id,
    this.publicId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.profileImage,
    required this.role,
    this.ownerId,
    required this.isEmailVerified,
    required this.notifications,
    required this.accessToken,
    required this.refreshToken,
  });

  // Fullname
  String get fullName => "$firstName $lastName";

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class ProfileImage {
  @JsonKey(name: 'public_id', required: true, disallowNullValue: true)
  final String publicId;

  @JsonKey(required: true, disallowNullValue: true)
  final String url;

  const ProfileImage({required this.publicId, required this.url});

  factory ProfileImage.fromJson(Map<String, dynamic> json) =>
      _$ProfileImageFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileImageToJson(this);
}

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class Notifications {
  @JsonKey(required: true, disallowNullValue: true)
  final bool push;

  @JsonKey(required: true, disallowNullValue: true)
  final bool loan;

  @JsonKey(required: true, disallowNullValue: true)
  final bool transaction;

  @JsonKey(required: true, disallowNullValue: true)
  final bool fund;

  @JsonKey(required: true, disallowNullValue: true)
  final bool support;

  const Notifications({
    required this.push,
    required this.loan,
    required this.transaction,
    required this.fund,
    required this.support,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) =>
      _$NotificationsFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationsToJson(this);
}
