// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportModel _$SupportModelFromJson(Map<String, dynamic> json) => SupportModel(
  id: json['_id'] as String?,
  userId: const _UserIdConverter().fromJson(json['userId']),
  fullName: json['fullName'] as String,
  email: json['email'] as String,
  contactNumber: json['contactNumber'] as String,
  note: json['note'] as String,
  isResolved: json['isResolved'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SupportModelToJson(SupportModel instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'email': instance.email,
      'contactNumber': instance.contactNumber,
      'note': instance.note,
    };
