// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ProfileModel', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const [
      '_id',
      'firstName',
      'lastName',
      'email',
      'phoneNumber',
      'address',
      'profileImage',
      'role',
      'ownerId',
      'isSuspended',
      'isEmailVerified',
      'totalJobs',
      'memberSince',
      'createdAt',
      'updatedAt',
      '__v',
      'notifications',
    ],
    requiredKeys: const [
      '_id',
      'email',
      'phoneNumber',
      'address',
      'profileImage',
      'role',
      'isSuspended',
      'isEmailVerified',
      'totalJobs',
      'memberSince',
      'createdAt',
      'updatedAt',
      '__v',
      'notifications',
    ],
    disallowNullValues: const [
      '_id',
      'firstName',
      'lastName',
      'email',
      'phoneNumber',
      'address',
      'profileImage',
      'role',
      'isSuspended',
      'isEmailVerified',
      'totalJobs',
      'memberSince',
      'createdAt',
      'updatedAt',
      '__v',
      'notifications',
    ],
  );
  final val = ProfileModel(
    id: $checkedConvert('_id', (v) => v as String),
    firstName: $checkedConvert('firstName', (v) => v as String),
    lastName: $checkedConvert('lastName', (v) => v as String),
    email: $checkedConvert('email', (v) => v as String),
    phoneNumber: $checkedConvert('phoneNumber', (v) => v as String),
    address: $checkedConvert('address', (v) => v as String),
    profileImage: $checkedConvert(
      'profileImage',
      (v) => ProfileImage.fromJson(v as Map<String, dynamic>),
    ),
    role: $checkedConvert('role', (v) => v as String),
    ownerId: $checkedConvert('ownerId', (v) => v as String?),
    isSuspended: $checkedConvert('isSuspended', (v) => v as bool),
    isEmailVerified: $checkedConvert('isEmailVerified', (v) => v as bool),
    totalJobs: $checkedConvert('totalJobs', (v) => (v as num).toInt()),
    memberSince: $checkedConvert(
      'memberSince',
      (v) => DateTime.parse(v as String),
    ),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
    v: $checkedConvert('__v', (v) => (v as num).toInt()),
    notifications: $checkedConvert(
      'notifications',
      (v) => Notifications.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
}, fieldKeyMap: const {'id': '_id', 'v': '__v'});

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'address': instance.address,
      'profileImage': instance.profileImage,
      'role': instance.role,
      'ownerId': instance.ownerId,
      'isSuspended': instance.isSuspended,
      'isEmailVerified': instance.isEmailVerified,
      'totalJobs': instance.totalJobs,
      'memberSince': instance.memberSince.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      '__v': instance.v,
      'notifications': instance.notifications,
    };
