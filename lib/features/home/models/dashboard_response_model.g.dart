// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardResponseModel _$DashboardResponseModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DashboardResponseModel', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const [
      'totalJobs',
      'activeJobs',
      'completedJobs',
      'proposalSentJobs',
      'totalStaff',
      'totalCatalog',
      'thisMonthRevenue',
      'recentJobs',
    ],
    requiredKeys: const [
      'totalJobs',
      'activeJobs',
      'completedJobs',
      'proposalSentJobs',
      'totalStaff',
      'totalCatalog',
      'thisMonthRevenue',
      'recentJobs',
    ],
    disallowNullValues: const [
      'totalJobs',
      'activeJobs',
      'completedJobs',
      'proposalSentJobs',
      'totalStaff',
      'totalCatalog',
      'thisMonthRevenue',
      'recentJobs',
    ],
  );
  final val = DashboardResponseModel(
    totalJobs: $checkedConvert('totalJobs', (v) => (v as num).toInt()),
    activeJobs: $checkedConvert('activeJobs', (v) => (v as num).toInt()),
    completedJobs: $checkedConvert('completedJobs', (v) => (v as num).toInt()),
    proposalSentJobs: $checkedConvert(
      'proposalSentJobs',
      (v) => (v as num).toInt(),
    ),
    totalStaff: $checkedConvert('totalStaff', (v) => (v as num).toInt()),
    totalCatalog: $checkedConvert('totalCatalog', (v) => (v as num).toInt()),
    thisMonthRevenue: $checkedConvert('thisMonthRevenue', (v) => v as num),
    recentJobs: $checkedConvert(
      'recentJobs',
      (v) => (v as List<dynamic>)
          .map((e) => DashboardRecentJob.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$DashboardResponseModelToJson(
  DashboardResponseModel instance,
) => <String, dynamic>{
  'totalJobs': instance.totalJobs,
  'activeJobs': instance.activeJobs,
  'completedJobs': instance.completedJobs,
  'proposalSentJobs': instance.proposalSentJobs,
  'totalStaff': instance.totalStaff,
  'totalCatalog': instance.totalCatalog,
  'thisMonthRevenue': instance.thisMonthRevenue,
  'recentJobs': instance.recentJobs,
};

DashboardRecentJob _$DashboardRecentJobFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DashboardRecentJob', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          '_id',
          'jobRef',
          'customerName',
          'propertyAddress',
          'status',
          'currentStep',
          'assignedTo',
          'date',
          'createdAt',
        ],
        requiredKeys: const [
          '_id',
          'jobRef',
          'customerName',
          'propertyAddress',
          'status',
          'currentStep',
          'date',
          'createdAt',
        ],
        disallowNullValues: const [
          '_id',
          'jobRef',
          'customerName',
          'propertyAddress',
          'status',
          'currentStep',
          'date',
          'createdAt',
        ],
      );
      final val = DashboardRecentJob(
        id: $checkedConvert('_id', (v) => v as String),
        jobRef: $checkedConvert('jobRef', (v) => v as String),
        customerName: $checkedConvert('customerName', (v) => v as String),
        propertyAddress: $checkedConvert('propertyAddress', (v) => v as String),
        status: $checkedConvert('status', (v) => v as String),
        currentStep: $checkedConvert('currentStep', (v) => (v as num).toInt()),
        assignedTo: $checkedConvert(
          'assignedTo',
          (v) => v == null
              ? null
              : DashboardAssignee.fromJson(v as Map<String, dynamic>),
        ),
        date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    }, fieldKeyMap: const {'id': '_id'});

Map<String, dynamic> _$DashboardRecentJobToJson(DashboardRecentJob instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'jobRef': instance.jobRef,
      'customerName': instance.customerName,
      'propertyAddress': instance.propertyAddress,
      'status': instance.status,
      'currentStep': instance.currentStep,
      'assignedTo': instance.assignedTo,
      'date': instance.date.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

DashboardAssignee _$DashboardAssigneeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DashboardAssignee', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['_id'],
        disallowNullValues: const ['_id'],
      );
      final val = DashboardAssignee(
        id: $checkedConvert('_id', (v) => v as String),
        firstName: $checkedConvert('firstName', (v) => v as String?),
        lastName: $checkedConvert('lastName', (v) => v as String?),
        email: $checkedConvert('email', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'id': '_id'});

Map<String, dynamic> _$DashboardAssigneeToJson(DashboardAssignee instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
    };
