import 'package:json_annotation/json_annotation.dart';

import '../../measure/model/room_spec.dart';
import 'layout_model.dart';

part 'job_create_response_model.g.dart';

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class JobModel {
  @JsonKey(name: '_id', required: true, disallowNullValue: true)
  final String id;

  @JsonKey(required: true, disallowNullValue: true)
  final String jobRef;

  /// Absent on the slim list endpoint, present on job detail/create responses.
  final String? ownerId;

  /// Unassigned until a team member is set, so this legitimately accepts null.
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

  /// Absent on the slim list endpoint.
  final String? notes;

  @JsonKey(required: true, disallowNullValue: true)
  final String status;

  @JsonKey(required: true, disallowNullValue: true)
  final int currentStep;

  /// Absent on the slim list endpoint.
  final RoomCapture? roomCapture;

  /// Absent on the slim list endpoint.
  final Measurements? measurements;

  /// Absent on the slim list endpoint.
  final List<dynamic>? selectedProducts;

  /// Absent on the slim list endpoint.
  final AiLayout? aiLayout;

  /// Absent on the slim list endpoint.
  final JobDesign? design;

  /// Absent on the slim list endpoint.
  final Estimate? estimate;

  /// Absent on the slim list endpoint.
  final Proposal? proposal;

  @JsonKey(required: true, disallowNullValue: true)
  final DateTime createdAt;

  /// Absent on the slim list endpoint.
  final DateTime? updatedAt;

  @JsonKey(name: '__v')
  final int? v;

  const JobModel({
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

  factory JobModel.fromJson(Map<String, dynamic> json) =>
      _$JobModelFromJson(json);

  Map<String, dynamic> toJson() => _$JobModelToJson(this);
}

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class RoomCapture {
  final String? method;

  final DateTime? capturedAt;

  const RoomCapture({this.method, this.capturedAt});

  factory RoomCapture.fromJson(Map<String, dynamic> json) =>
      _$RoomCaptureFromJson(json);

  Map<String, dynamic> toJson() => _$RoomCaptureToJson(this);
}

@JsonSerializable(
  checked: true,
  disallowUnrecognizedKeys: true,
  explicitToJson: true,
)
class Measurements {
  /// Legacy box size in meters, derived by the backend from [room].
  final double? width;

  final double? depth;

  final double? height;

  /// The walls the layout is built from. Null on jobs measured before
  /// RoomSpec existed.
  final RoomSpec? room;

  const Measurements({this.width, this.depth, this.height, this.room});

  factory Measurements.fromJson(Map<String, dynamic> json) =>
      _$MeasurementsFromJson(json);

  Map<String, dynamic> toJson() => _$MeasurementsToJson(this);
}

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class AiLayout {
  final String? status;

  final DateTime? generatedAt;

  /// Null until generated, after inputs change, and on jobs whose layout
  /// predates the layout engine.
  @JsonKey(fromJson: JobLayout.tryParse)
  final JobLayout? layoutData;

  const AiLayout({this.status, this.generatedAt, this.layoutData});

  factory AiLayout.fromJson(Map<String, dynamic> json) =>
      _$AiLayoutFromJson(json);

  Map<String, dynamic> toJson() => _$AiLayoutToJson(this);
}

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class JobDesign {
  @JsonKey(required: true, disallowNullValue: true)
  final LayoutImage layoutImage;

  @JsonKey(required: true, disallowNullValue: true)
  final String layoutName;

  /// The generated layout as the user rearranged it. Null until saved.
  @JsonKey(fromJson: JobLayout.tryParse)
  final JobLayout? layout;

  const JobDesign({
    required this.layoutImage,
    required this.layoutName,
    this.layout,
  });

  factory JobDesign.fromJson(Map<String, dynamic> json) =>
      _$JobDesignFromJson(json);

  Map<String, dynamic> toJson() => _$JobDesignToJson(this);
}

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class LayoutImage {
  @JsonKey(name: 'public_id', required: true, disallowNullValue: true)
  final String publicId;

  @JsonKey(required: true, disallowNullValue: true)
  final String url;

  const LayoutImage({required this.publicId, required this.url});

  factory LayoutImage.fromJson(Map<String, dynamic> json) =>
      _$LayoutImageFromJson(json);

  Map<String, dynamic> toJson() => _$LayoutImageToJson(this);
}

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class Estimate {
  @JsonKey(required: true, disallowNullValue: true)
  final double subTotal;

  @JsonKey(required: true, disallowNullValue: true)
  final double installationCharge;

  @JsonKey(required: true, disallowNullValue: true)
  final double deliveryCharge;

  @JsonKey(required: true, disallowNullValue: true)
  final double taxRate;

  @JsonKey(required: true, disallowNullValue: true)
  final double taxAmount;

  @JsonKey(required: true, disallowNullValue: true)
  final double total;

  const Estimate({
    required this.subTotal,
    required this.installationCharge,
    required this.deliveryCharge,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
  });

  factory Estimate.fromJson(Map<String, dynamic> json) =>
      _$EstimateFromJson(json);

  Map<String, dynamic> toJson() => _$EstimateToJson(this);
}

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class Proposal {
  final DateTime? generatedAt;

  @JsonKey(required: true, disallowNullValue: true)
  final String pdfUrl;

  @JsonKey(required: true, disallowNullValue: true)
  final String terms;

  /// Private Cloudinary file id. The app downloads the PDF through
  /// `GET /jobs/:id/proposal/pdf`, never by URL. Absent on older jobs.
  final String? pdfPublicId;

  const Proposal({
    this.generatedAt,
    required this.pdfUrl,
    required this.terms,
    this.pdfPublicId,
  });

  factory Proposal.fromJson(Map<String, dynamic> json) =>
      _$ProposalFromJson(json);

  Map<String, dynamic> toJson() => _$ProposalToJson(this);
}
