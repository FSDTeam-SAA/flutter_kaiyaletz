import 'package:json_annotation/json_annotation.dart';

part 'dashboard_response_model.g.dart';

/// Response for `GET /jobs/dashboard`, backing the home screen's stat tiles
/// and recent jobs list.
@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class DashboardResponseModel {
  @JsonKey(required: true, disallowNullValue: true)
  final int totalJobs;

  @JsonKey(required: true, disallowNullValue: true)
  final int activeJobs;

  @JsonKey(required: true, disallowNullValue: true)
  final int completedJobs;

  @JsonKey(required: true, disallowNullValue: true)
  final int proposalSentJobs;

  @JsonKey(required: true, disallowNullValue: true)
  final int totalStaff;

  @JsonKey(required: true, disallowNullValue: true)
  final int totalCatalog;

  @JsonKey(required: true, disallowNullValue: true)
  final num thisMonthRevenue;

  @JsonKey(required: true, disallowNullValue: true)
  final List<DashboardRecentJob> recentJobs;

  const DashboardResponseModel({
    required this.totalJobs,
    required this.activeJobs,
    required this.completedJobs,
    required this.proposalSentJobs,
    required this.totalStaff,
    required this.totalCatalog,
    required this.thisMonthRevenue,
    required this.recentJobs,
  });

  factory DashboardResponseModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardResponseModelToJson(this);
}

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class DashboardRecentJob {
  @JsonKey(name: '_id', required: true, disallowNullValue: true)
  final String id;

  @JsonKey(required: true, disallowNullValue: true)
  final String jobRef;

  @JsonKey(required: true, disallowNullValue: true)
  final String customerName;

  @JsonKey(required: true, disallowNullValue: true)
  final String propertyAddress;

  @JsonKey(required: true, disallowNullValue: true)
  final String status;

  @JsonKey(required: true, disallowNullValue: true)
  final int currentStep;

  /// Unassigned until a team member is set, so this legitimately accepts null.
  final DashboardAssignee? assignedTo;

  @JsonKey(required: true, disallowNullValue: true)
  final DateTime date;

  @JsonKey(required: true, disallowNullValue: true)
  final DateTime createdAt;

  const DashboardRecentJob({
    required this.id,
    required this.jobRef,
    required this.customerName,
    required this.propertyAddress,
    required this.status,
    required this.currentStep,
    this.assignedTo,
    required this.date,
    required this.createdAt,
  });

  factory DashboardRecentJob.fromJson(Map<String, dynamic> json) =>
      _$DashboardRecentJobFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardRecentJobToJson(this);
}

/// Shape of the populated `assignedTo` staff reference. Left permissive
/// (unrecognized keys allowed) since the exact fields returned here haven't
/// been confirmed against the backend yet.
@JsonSerializable(checked: true)
class DashboardAssignee {
  @JsonKey(name: '_id', required: true, disallowNullValue: true)
  final String id;

  final String? firstName;

  final String? lastName;

  final String? email;

  const DashboardAssignee({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
  });

  factory DashboardAssignee.fromJson(Map<String, dynamic> json) =>
      _$DashboardAssigneeFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardAssigneeToJson(this);
}
