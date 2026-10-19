import 'package:json_annotation/json_annotation.dart';

import '../../catalog/model/catalog_model.dart';
import 'job_create_response_model.dart';

part 'single_job_reponse_model.g.dart';

/// Accepts null / [] / a list of line-item objects. Anything that isn't an
/// object is skipped instead of throwing.
List<SelectedProductModel> _productsFromJson(Object? json) => [
  for (final item in (json as List? ?? const []))
    if (item is Map<String, dynamic>) SelectedProductModel.fromJson(item),
];

/// One line of `selectedProducts`: a catalog product (under `productId`)
/// plus its quantity and pricing for this job.
@JsonSerializable(checked: true)
class SelectedProductModel {
  @JsonKey(name: '_id')
  final String? id;

  @JsonKey(required: true, disallowNullValue: true)
  final CatalogModel productId;

  final int quantity;
  final num unitPrice;
  final num lineTotal;

  const SelectedProductModel({
    this.id,
    required this.productId,
    this.quantity = 1,
    this.unitPrice = 0,
    this.lineTotal = 0,
  });

  factory SelectedProductModel.fromJson(Map<String, dynamic> json) =>
      _$SelectedProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$SelectedProductModelToJson(this);
}

/// Shape of the `data` object for `GET /jobs/:id`.
@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class SingleJobResponseModel {
  @JsonKey(name: '_id', required: true, disallowNullValue: true)
  final String id;

  @JsonKey(required: true, disallowNullValue: true)
  final String jobRef;

  final String? ownerId;

  final String? assignedTo;

  @JsonKey(required: true, disallowNullValue: true)
  final DateTime date;

  @JsonKey(required: true, disallowNullValue: true)
  final String customerName;

  @JsonKey(required: true, disallowNullValue: true)
  final String propertyAddress;

  @JsonKey(required: true, disallowNullValue: true)
  final String phoneNumber;

  @JsonKey(required: true, disallowNullValue: true)
  final String emailAddress;

  final String? notes;

  @JsonKey(required: true, disallowNullValue: true)
  final String status;

  @JsonKey(required: true, disallowNullValue: true)
  final int currentStep;

  final RoomCapture? roomCapture;

  final Measurements? measurements;

  @JsonKey(fromJson: _productsFromJson)
  final List<SelectedProductModel>? selectedProducts;

  final AiLayout? aiLayout;

  final JobDesign? design;

  final Estimate? estimate;

  final Proposal? proposal;

  @JsonKey(required: true, disallowNullValue: true)
  final DateTime createdAt;

  final DateTime? updatedAt;

  @JsonKey(name: '__v')
  final int? v;

  const SingleJobResponseModel({
    required this.id,
    required this.jobRef,
    this.ownerId,
    this.assignedTo,
    required this.date,
    required this.customerName,
    required this.propertyAddress,
    required this.phoneNumber,
    required this.emailAddress,
    this.notes,
    required this.status,
    required this.currentStep,
    this.roomCapture,
    this.measurements,
    this.selectedProducts,
    this.aiLayout,
    this.design,
    this.estimate,
    this.proposal,
    required this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory SingleJobResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SingleJobResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SingleJobResponseModelToJson(this);
}
