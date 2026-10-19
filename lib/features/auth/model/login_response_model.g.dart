// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UserModel', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          '_id',
          'public_id',
          'firstName',
          'lastName',
          'email',
          'phoneNumber',
          'address',
          'profileImage',
          'role',
          'ownerId',
          'isEmailVerified',
          'notifications',
          'accessToken',
          'refreshToken',
        ],
        requiredKeys: const [
          '_id',
          'email',
          'phoneNumber',
          'address',
          'profileImage',
          'role',
          'isEmailVerified',
          'notifications',
          'accessToken',
          'refreshToken',
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
          'isEmailVerified',
          'notifications',
          'accessToken',
          'refreshToken',
        ],
      );
      final val = UserModel(
        id: $checkedConvert('_id', (v) => v as String),
        publicId: $checkedConvert('public_id', (v) => v as String?),
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
        isEmailVerified: $checkedConvert('isEmailVerified', (v) => v as bool),
        notifications: $checkedConvert(
          'notifications',
          (v) => Notifications.fromJson(v as Map<String, dynamic>),
        ),
        accessToken: $checkedConvert('accessToken', (v) => v as String),
        refreshToken: $checkedConvert('refreshToken', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'id': '_id', 'publicId': 'public_id'});

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  '_id': instance.id,
  'public_id': instance.publicId,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'address': instance.address,
  'profileImage': instance.profileImage,
  'role': instance.role,
  'ownerId': instance.ownerId,
  'isEmailVerified': instance.isEmailVerified,
  'notifications': instance.notifications,
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
};

ProfileImage _$ProfileImageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ProfileImage', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['public_id', 'url'],
        requiredKeys: const ['public_id', 'url'],
        disallowNullValues: const ['public_id', 'url'],
      );
      final val = ProfileImage(
        publicId: $checkedConvert('public_id', (v) => v as String),
        url: $checkedConvert('url', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'publicId': 'public_id'});

Map<String, dynamic> _$ProfileImageToJson(ProfileImage instance) =>
    <String, dynamic>{'public_id': instance.publicId, 'url': instance.url};

Notifications _$NotificationsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Notifications', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['push', 'loan', 'transaction', 'fund', 'support'],
        requiredKeys: const ['push', 'loan', 'transaction', 'fund', 'support'],
        disallowNullValues: const [
          'push',
          'loan',
          'transaction',
          'fund',
          'support',
        ],
      );
      final val = Notifications(
        push: $checkedConvert('push', (v) => v as bool),
        loan: $checkedConvert('loan', (v) => v as bool),
        transaction: $checkedConvert('transaction', (v) => v as bool),
        fund: $checkedConvert('fund', (v) => v as bool),
        support: $checkedConvert('support', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$NotificationsToJson(Notifications instance) =>
    <String, dynamic>{
      'push': instance.push,
      'loan': instance.loan,
      'transaction': instance.transaction,
      'fund': instance.fund,
      'support': instance.support,
    };
