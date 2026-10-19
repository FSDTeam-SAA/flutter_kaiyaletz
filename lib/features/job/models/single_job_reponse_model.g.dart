// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'single_job_reponse_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SelectedProductModel _$SelectedProductModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SelectedProductModel', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['productId'],
    disallowNullValues: const ['productId'],
  );
  final val = SelectedProductModel(
    id: $checkedConvert('_id', (v) => v as String?),
    productId: $checkedConvert(
      'productId',
      (v) => CatalogModel.fromJson(v as Map<String, dynamic>),
    ),
    quantity: $checkedConvert('quantity', (v) => (v as num?)?.toInt() ?? 1),
    unitPrice: $checkedConvert('unitPrice', (v) => v as num? ?? 0),
    lineTotal: $checkedConvert('lineTotal', (v) => v as num? ?? 0),
  );
  return val;
}, fieldKeyMap: const {'id': '_id'});

Map<String, dynamic> _$SelectedProductModelToJson(
  SelectedProductModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'productId': instance.productId,
  'quantity': instance.quantity,
  'unitPrice': instance.unitPrice,
  'lineTotal': instance.lineTotal,
};

SingleJobResponseModel _$SingleJobResponseModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SingleJobResponseModel', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const [
      '_id',
      'jobRef',
      'ownerId',
      'assignedTo',
      'date',
      'customerName',
      'propertyAddress',
      'phoneNumber',
      'emailAddress',
      'notes',
      'status',
      'currentStep',
      'roomCapture',
      'measurements',
      'selectedProducts',
      'aiLayout',
      'design',
      'estimate',
      'proposal',
      'createdAt',
      'updatedAt',
      '__v',
    ],
    requiredKeys: const [
      '_id',
      'jobRef',
      'date',
      'customerName',
      'propertyAddress',
      'phoneNumber',
      'emailAddress',
      'status',
      'currentStep',
      'createdAt',
    ],
    disallowNullValues: const [
      '_id',
      'jobRef',
      'date',
      'customerName',
      'propertyAddress',
      'phoneNumber',
      'emailAddress',
      'status',
      'currentStep',
      'createdAt',
    ],
  );
  final val = SingleJobResponseModel(
    id: $checkedConvert('_id', (v) => v as String),
    jobRef: $checkedConvert('jobRef', (v) => v as String),
    ownerId: $checkedConvert('ownerId', (v) => v as String?),
    assignedTo: $checkedConvert('assignedTo', (v) => v as String?),
    date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
    customerName: $checkedConvert('customerName', (v) => v as String),
    propertyAddress: $checkedConvert('propertyAddress', (v) => v as String),
    phoneNumber: $checkedConvert('phoneNumber', (v) => v as String),
    emailAddress: $checkedConvert('emailAddress', (v) => v as String),
    notes: $checkedConvert('notes', (v) => v as String?),
    status: $checkedConvert('status', (v) => v as String),
    currentStep: $checkedConvert('currentStep', (v) => (v as num).toInt()),
    roomCapture: $checkedConvert(
      'roomCapture',
      (v) => v == null ? null : RoomCapture.fromJson(v as Map<String, dynamic>),
    ),
    measurements: $checkedConvert(
      'measurements',
      (v) =>
          v == null ? null : Measurements.fromJson(v as Map<String, dynamic>),
    ),
    selectedProducts: $checkedConvert(
      'selectedProducts',
      (v) => _productsFromJson(v),
    ),
    aiLayout: $checkedConvert(
      'aiLayout',
      (v) => v == null ? null : AiLayout.fromJson(v as Map<String, dynamic>),
    ),
    design: $checkedConvert(
      'design',
      (v) => v == null ? null : JobDesign.fromJson(v as Map<String, dynamic>),
    ),
    estimate: $checkedConvert(
      'estimate',
      (v) => v == null ? null : Estimate.fromJson(v as Map<String, dynamic>),
    ),
    proposal: $checkedConvert(
      'proposal',
      (v) => v == null ? null : Proposal.fromJson(v as Map<String, dynamic>),
    ),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert(
      'updatedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    v: $checkedConvert('__v', (v) => (v as num?)?.toInt()),
  );
  return val;
}, fieldKeyMap: const {'id': '_id', 'v': '__v'});

Map<String, dynamic> _$SingleJobResponseModelToJson(
  SingleJobResponseModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'jobRef': instance.jobRef,
  'ownerId': instance.ownerId,
  'assignedTo': instance.assignedTo,
  'date': instance.date.toIso8601String(),
  'customerName': instance.customerName,
  'propertyAddress': instance.propertyAddress,
  'phoneNumber': instance.phoneNumber,
  'emailAddress': instance.emailAddress,
  'notes': instance.notes,
  'status': instance.status,
  'currentStep': instance.currentStep,
  'roomCapture': instance.roomCapture,
  'measurements': instance.measurements,
  'selectedProducts': instance.selectedProducts,
  'aiLayout': instance.aiLayout,
  'design': instance.design,
  'estimate': instance.estimate,
  'proposal': instance.proposal,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  '__v': instance.v,
};
