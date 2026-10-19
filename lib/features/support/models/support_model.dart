import 'package:json_annotation/json_annotation.dart';

part 'support_model.g.dart';

@JsonSerializable()
class SupportModel {
  @JsonKey(name: '_id', includeToJson: false)
  final String? id;

  /// userId can be null, a plain ObjectId string, or a populated object
  /// (e.g. { _id, firstName, lastName, email }) from getAllSupportMessages,
  /// since it's populated with .populate("userId", ...).
  @_UserIdConverter()
  @JsonKey(includeToJson: false)
  final String? userId;

  final String fullName;
  final String email;
  final String contactNumber;
  final String note;

  @JsonKey(includeToJson: false)
  final bool isResolved;

  @JsonKey(includeToJson: false)
  final DateTime? createdAt;

  @JsonKey(includeToJson: false)
  final DateTime? updatedAt;

  const SupportModel({
    this.id,
    this.userId,
    required this.fullName,
    required this.email,
    required this.contactNumber,
    required this.note,
    this.isResolved = false,
    this.createdAt,
    this.updatedAt,
  });

  factory SupportModel.fromJson(Map<String, dynamic> json) =>
      _$SupportModelFromJson(json);

  Map<String, dynamic> toJson() => _$SupportModelToJson(this);
}

class _UserIdConverter implements JsonConverter<String?, Object?> {
  const _UserIdConverter();

  @override
  String? fromJson(Object? json) {
    if (json == null) return null;
    if (json is String) return json;
    if (json is Map<String, dynamic>) return json['_id'] as String?;
    return null;
  }

  @override
  Object? toJson(String? object) => object;
}
