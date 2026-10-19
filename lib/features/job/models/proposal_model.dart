import 'package:json_annotation/json_annotation.dart';

part 'proposal_model.g.dart';

/// `data.proposal` from `POST /jobs/:id/proposal` (buildProposalView in the
/// backend). Every value is final; the screen shows it as-is so it always
/// matches the PDF (downloaded via [JobRepo.downloadProposalPdf]).
@JsonSerializable(
  checked: true,
  disallowUnrecognizedKeys: true,
  explicitToJson: true,
)
class ProposalModel {
  @JsonKey(required: true, disallowNullValue: true)
  final ProposalBusiness business;

  @JsonKey(required: true, disallowNullValue: true)
  final String jobRef;

  @JsonKey(required: true, disallowNullValue: true)
  final DateTime date;

  @JsonKey(required: true, disallowNullValue: true)
  final ProposalCustomer customer;

  /// Elevation PNG saved in the Design step. Null if none was uploaded.
  final String? layoutImageUrl;

  @JsonKey(required: true, disallowNullValue: true)
  final List<ProposalLine> lines;

  /// Products only; charges and tax are separate.
  @JsonKey(required: true, disallowNullValue: true)
  final num subTotal;

  final num installationCharge;
  final num deliveryCharge;

  @JsonKey(required: true, disallowNullValue: true)
  final num taxRate;

  @JsonKey(required: true, disallowNullValue: true)
  final num taxAmount;

  @JsonKey(required: true, disallowNullValue: true)
  final num total;

  @JsonKey(required: true, disallowNullValue: true)
  final String terms;

  const ProposalModel({
    required this.business,
    required this.jobRef,
    required this.date,
    required this.customer,
    this.layoutImageUrl,
    required this.lines,
    required this.subTotal,
    this.installationCharge = 0,
    this.deliveryCharge = 0,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
    required this.terms,
  });

  factory ProposalModel.fromJson(Map<String, dynamic> json) =>
      _$ProposalModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProposalModelToJson(this);
}

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class ProposalBusiness {
  @JsonKey(required: true, disallowNullValue: true)
  final String name;

  @JsonKey(required: true, disallowNullValue: true)
  final String tagline;

  const ProposalBusiness({required this.name, required this.tagline});

  factory ProposalBusiness.fromJson(Map<String, dynamic> json) =>
      _$ProposalBusinessFromJson(json);

  Map<String, dynamic> toJson() => _$ProposalBusinessToJson(this);
}

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class ProposalCustomer {
  @JsonKey(required: true, disallowNullValue: true)
  final String name;

  final String address;
  final String phone;
  final String email;

  const ProposalCustomer({
    required this.name,
    this.address = '',
    this.phone = '',
    this.email = '',
  });

  factory ProposalCustomer.fromJson(Map<String, dynamic> json) =>
      _$ProposalCustomerFromJson(json);

  Map<String, dynamic> toJson() => _$ProposalCustomerToJson(this);
}

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class ProposalLine {
  @JsonKey(required: true, disallowNullValue: true)
  final String name;

  final String sku;

  @JsonKey(required: true, disallowNullValue: true)
  final int quantity;

  @JsonKey(required: true, disallowNullValue: true)
  final num unitPrice;

  @JsonKey(required: true, disallowNullValue: true)
  final num lineTotal;

  const ProposalLine({
    required this.name,
    this.sku = '',
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory ProposalLine.fromJson(Map<String, dynamic> json) =>
      _$ProposalLineFromJson(json);

  Map<String, dynamic> toJson() => _$ProposalLineToJson(this);
}
