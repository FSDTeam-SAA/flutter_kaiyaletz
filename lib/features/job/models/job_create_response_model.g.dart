// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_create_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobModel _$JobModelFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('JobModel', json, ($checkedConvert) {
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
  final val = JobModel(
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
      (v) => v as List<dynamic>?,
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

Map<String, dynamic> _$JobModelToJson(JobModel instance) => <String, dynamic>{
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

RoomCapture _$RoomCaptureFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RoomCapture', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['method', 'capturedAt']);
      final val = RoomCapture(
        method: $checkedConvert('method', (v) => v as String?),
        capturedAt: $checkedConvert(
          'capturedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$RoomCaptureToJson(RoomCapture instance) =>
    <String, dynamic>{
      'method': instance.method,
      'capturedAt': instance.capturedAt?.toIso8601String(),
    };

Measurements _$MeasurementsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Measurements', json, ($checkedConvert) {
      $checkKeys(json, allowedKeys: const ['width', 'depth', 'height', 'room']);
      final val = Measurements(
        width: $checkedConvert('width', (v) => (v as num?)?.toDouble()),
        depth: $checkedConvert('depth', (v) => (v as num?)?.toDouble()),
        height: $checkedConvert('height', (v) => (v as num?)?.toDouble()),
        room: $checkedConvert(
          'room',
          (v) =>
              v == null ? null : RoomSpec.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MeasurementsToJson(Measurements instance) =>
    <String, dynamic>{
      'width': instance.width,
      'depth': instance.depth,
      'height': instance.height,
      'room': instance.room?.toJson(),
    };

AiLayout _$AiLayoutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AiLayout', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['status', 'generatedAt', 'layoutData'],
      );
      final val = AiLayout(
        status: $checkedConvert('status', (v) => v as String?),
        generatedAt: $checkedConvert(
          'generatedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        layoutData: $checkedConvert('layoutData', (v) => JobLayout.tryParse(v)),
      );
      return val;
    });

Map<String, dynamic> _$AiLayoutToJson(AiLayout instance) => <String, dynamic>{
  'status': instance.status,
  'generatedAt': instance.generatedAt?.toIso8601String(),
  'layoutData': instance.layoutData,
};

JobDesign _$JobDesignFromJson(Map<String, dynamic> json) =>
    $checkedCreate('JobDesign', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['layoutImage', 'layoutName', 'layout'],
        requiredKeys: const ['layoutImage', 'layoutName'],
        disallowNullValues: const ['layoutImage', 'layoutName'],
      );
      final val = JobDesign(
        layoutImage: $checkedConvert(
          'layoutImage',
          (v) => LayoutImage.fromJson(v as Map<String, dynamic>),
        ),
        layoutName: $checkedConvert('layoutName', (v) => v as String),
        layout: $checkedConvert('layout', (v) => JobLayout.tryParse(v)),
      );
      return val;
    });

Map<String, dynamic> _$JobDesignToJson(JobDesign instance) => <String, dynamic>{
  'layoutImage': instance.layoutImage,
  'layoutName': instance.layoutName,
  'layout': instance.layout,
};

LayoutImage _$LayoutImageFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LayoutImage', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['public_id', 'url'],
        requiredKeys: const ['public_id', 'url'],
        disallowNullValues: const ['public_id', 'url'],
      );
      final val = LayoutImage(
        publicId: $checkedConvert('public_id', (v) => v as String),
        url: $checkedConvert('url', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'publicId': 'public_id'});

Map<String, dynamic> _$LayoutImageToJson(LayoutImage instance) =>
    <String, dynamic>{'public_id': instance.publicId, 'url': instance.url};

Estimate _$EstimateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Estimate', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'subTotal',
          'installationCharge',
          'deliveryCharge',
          'taxRate',
          'taxAmount',
          'total',
        ],
        requiredKeys: const [
          'subTotal',
          'installationCharge',
          'deliveryCharge',
          'taxRate',
          'taxAmount',
          'total',
        ],
        disallowNullValues: const [
          'subTotal',
          'installationCharge',
          'deliveryCharge',
          'taxRate',
          'taxAmount',
          'total',
        ],
      );
      final val = Estimate(
        subTotal: $checkedConvert('subTotal', (v) => (v as num).toDouble()),
        installationCharge: $checkedConvert(
          'installationCharge',
          (v) => (v as num).toDouble(),
        ),
        deliveryCharge: $checkedConvert(
          'deliveryCharge',
          (v) => (v as num).toDouble(),
        ),
        taxRate: $checkedConvert('taxRate', (v) => (v as num).toDouble()),
        taxAmount: $checkedConvert('taxAmount', (v) => (v as num).toDouble()),
        total: $checkedConvert('total', (v) => (v as num).toDouble()),
      );
      return val;
    });

Map<String, dynamic> _$EstimateToJson(Estimate instance) => <String, dynamic>{
  'subTotal': instance.subTotal,
  'installationCharge': instance.installationCharge,
  'deliveryCharge': instance.deliveryCharge,
  'taxRate': instance.taxRate,
  'taxAmount': instance.taxAmount,
  'total': instance.total,
};

Proposal _$ProposalFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Proposal', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['generatedAt', 'pdfUrl', 'terms', 'pdfPublicId'],
        requiredKeys: const ['pdfUrl', 'terms'],
        disallowNullValues: const ['pdfUrl', 'terms'],
      );
      final val = Proposal(
        generatedAt: $checkedConvert(
          'generatedAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        pdfUrl: $checkedConvert('pdfUrl', (v) => v as String),
        terms: $checkedConvert('terms', (v) => v as String),
        pdfPublicId: $checkedConvert('pdfPublicId', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$ProposalToJson(Proposal instance) => <String, dynamic>{
  'generatedAt': instance.generatedAt?.toIso8601String(),
  'pdfUrl': instance.pdfUrl,
  'terms': instance.terms,
  'pdfPublicId': instance.pdfPublicId,
};
