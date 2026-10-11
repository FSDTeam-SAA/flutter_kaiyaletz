// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proposal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProposalModel _$ProposalModelFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ProposalModel', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const [
          'business',
          'jobRef',
          'date',
          'customer',
          'layoutImageUrl',
          'lines',
          'subTotal',
          'installationCharge',
          'deliveryCharge',
          'taxRate',
          'taxAmount',
          'total',
          'terms',
        ],
        requiredKeys: const [
          'business',
          'jobRef',
          'date',
          'customer',
          'lines',
          'subTotal',
          'taxRate',
          'taxAmount',
          'total',
          'terms',
        ],
        disallowNullValues: const [
          'business',
          'jobRef',
          'date',
          'customer',
          'lines',
          'subTotal',
          'taxRate',
          'taxAmount',
          'total',
          'terms',
        ],
      );
      final val = ProposalModel(
        business: $checkedConvert(
          'business',
          (v) => ProposalBusiness.fromJson(v as Map<String, dynamic>),
        ),
        jobRef: $checkedConvert('jobRef', (v) => v as String),
        date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
        customer: $checkedConvert(
          'customer',
          (v) => ProposalCustomer.fromJson(v as Map<String, dynamic>),
        ),
        layoutImageUrl: $checkedConvert('layoutImageUrl', (v) => v as String?),
        lines: $checkedConvert(
          'lines',
          (v) => (v as List<dynamic>)
              .map((e) => ProposalLine.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        subTotal: $checkedConvert('subTotal', (v) => v as num),
        installationCharge: $checkedConvert(
          'installationCharge',
          (v) => v as num? ?? 0,
        ),
        deliveryCharge: $checkedConvert(
          'deliveryCharge',
          (v) => v as num? ?? 0,
        ),
        taxRate: $checkedConvert('taxRate', (v) => v as num),
        taxAmount: $checkedConvert('taxAmount', (v) => v as num),
        total: $checkedConvert('total', (v) => v as num),
        terms: $checkedConvert('terms', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ProposalModelToJson(ProposalModel instance) =>
    <String, dynamic>{
      'business': instance.business.toJson(),
      'jobRef': instance.jobRef,
      'date': instance.date.toIso8601String(),
      'customer': instance.customer.toJson(),
      'layoutImageUrl': instance.layoutImageUrl,
      'lines': instance.lines.map((e) => e.toJson()).toList(),
      'subTotal': instance.subTotal,
      'installationCharge': instance.installationCharge,
      'deliveryCharge': instance.deliveryCharge,
      'taxRate': instance.taxRate,
      'taxAmount': instance.taxAmount,
      'total': instance.total,
      'terms': instance.terms,
    };

ProposalBusiness _$ProposalBusinessFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ProposalBusiness', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['name', 'tagline'],
        requiredKeys: const ['name', 'tagline'],
        disallowNullValues: const ['name', 'tagline'],
      );
      final val = ProposalBusiness(
        name: $checkedConvert('name', (v) => v as String),
        tagline: $checkedConvert('tagline', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ProposalBusinessToJson(ProposalBusiness instance) =>
    <String, dynamic>{'name': instance.name, 'tagline': instance.tagline};

ProposalCustomer _$ProposalCustomerFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ProposalCustomer', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['name', 'address', 'phone', 'email'],
        requiredKeys: const ['name'],
        disallowNullValues: const ['name'],
      );
      final val = ProposalCustomer(
        name: $checkedConvert('name', (v) => v as String),
        address: $checkedConvert('address', (v) => v as String? ?? ''),
        phone: $checkedConvert('phone', (v) => v as String? ?? ''),
        email: $checkedConvert('email', (v) => v as String? ?? ''),
      );
      return val;
    });

Map<String, dynamic> _$ProposalCustomerToJson(ProposalCustomer instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'phone': instance.phone,
      'email': instance.email,
    };

ProposalLine _$ProposalLineFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ProposalLine', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const ['name', 'sku', 'quantity', 'unitPrice', 'lineTotal'],
    requiredKeys: const ['name', 'quantity', 'unitPrice', 'lineTotal'],
    disallowNullValues: const ['name', 'quantity', 'unitPrice', 'lineTotal'],
  );
  final val = ProposalLine(
    name: $checkedConvert('name', (v) => v as String),
    sku: $checkedConvert('sku', (v) => v as String? ?? ''),
    quantity: $checkedConvert('quantity', (v) => (v as num).toInt()),
    unitPrice: $checkedConvert('unitPrice', (v) => v as num),
    lineTotal: $checkedConvert('lineTotal', (v) => v as num),
  );
  return val;
});

Map<String, dynamic> _$ProposalLineToJson(ProposalLine instance) =>
    <String, dynamic>{
      'name': instance.name,
      'sku': instance.sku,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'lineTotal': instance.lineTotal,
    };
