// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_reponse_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignupResponseModel _$SignupResponseModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SignupResponseModel', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['email'],
        requiredKeys: const ['email'],
        disallowNullValues: const ['email'],
      );
      final val = SignupResponseModel(
        email: $checkedConvert('email', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$SignupResponseModelToJson(
  SignupResponseModel instance,
) => <String, dynamic>{'email': instance.email};
