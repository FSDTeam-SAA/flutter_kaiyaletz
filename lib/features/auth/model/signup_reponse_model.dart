import 'package:json_annotation/json_annotation.dart';

part 'signup_reponse_model.g.dart';

/// Email echoed back in the signup response's `data` object.
@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class SignupResponseModel {
  @JsonKey(required: true, disallowNullValue: true)
  final String email;

  const SignupResponseModel({required this.email});

  factory SignupResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SignupResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SignupResponseModelToJson(this);
}
