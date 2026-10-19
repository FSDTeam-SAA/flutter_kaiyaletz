// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layout_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobLayout _$JobLayoutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'JobLayout',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      allowedKeys: const ['engine', 'items', 'fillers', 'warnings', 'checks'],
      requiredKeys: const ['engine', 'items'],
      disallowNullValues: const ['engine', 'items'],
    );
    final val = JobLayout(
      engine: $checkedConvert('engine', (v) => v as String),
      items: $checkedConvert(
        'items',
        (v) => (v as List<dynamic>)
            .map((e) => LayoutItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      fillers: $checkedConvert(
        'fillers',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => LayoutFiller.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      ),
      warnings: $checkedConvert(
        'warnings',
        (v) =>
            (v as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      ),
      checks: $checkedConvert(
        'checks',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => LayoutCheck.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      ),
    );
    return val;
  },
);

Map<String, dynamic> _$JobLayoutToJson(JobLayout instance) => <String, dynamic>{
  'engine': instance.engine,
  'items': instance.items.map((e) => e.toJson()).toList(),
  'fillers': instance.fillers.map((e) => e.toJson()).toList(),
  'warnings': instance.warnings,
  'checks': instance.checks.map((e) => e.toJson()).toList(),
};

LayoutItem _$LayoutItemFromJson(Map<String, dynamic> json) => $checkedCreate(
  'LayoutItem',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      allowedKeys: const [
        'productId',
        'sku',
        'name',
        'tier',
        'wallId',
        'offsetMm',
        'widthMm',
        'heightMm',
        'depthMm',
      ],
      requiredKeys: const [
        'productId',
        'sku',
        'tier',
        'wallId',
        'offsetMm',
        'widthMm',
        'heightMm',
        'depthMm',
      ],
      disallowNullValues: const [
        'productId',
        'sku',
        'tier',
        'wallId',
        'offsetMm',
        'widthMm',
        'heightMm',
        'depthMm',
      ],
    );
    final val = LayoutItem(
      productId: $checkedConvert('productId', (v) => v as String),
      sku: $checkedConvert('sku', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String?),
      tier: $checkedConvert('tier', (v) => $enumDecode(_$LayoutTierEnumMap, v)),
      wallId: $checkedConvert('wallId', (v) => v as String),
      offsetMm: $checkedConvert('offsetMm', (v) => (v as num).toInt()),
      widthMm: $checkedConvert('widthMm', (v) => (v as num).toInt()),
      heightMm: $checkedConvert('heightMm', (v) => (v as num).toInt()),
      depthMm: $checkedConvert('depthMm', (v) => (v as num).toInt()),
    );
    return val;
  },
);

Map<String, dynamic> _$LayoutItemToJson(LayoutItem instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'sku': instance.sku,
      'name': instance.name,
      'tier': _$LayoutTierEnumMap[instance.tier]!,
      'wallId': instance.wallId,
      'offsetMm': instance.offsetMm,
      'widthMm': instance.widthMm,
      'heightMm': instance.heightMm,
      'depthMm': instance.depthMm,
    };

const _$LayoutTierEnumMap = {
  LayoutTier.base: 'base',
  LayoutTier.wall: 'wall',
  LayoutTier.tall: 'tall',
};

LayoutFiller _$LayoutFillerFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LayoutFiller', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['wallId', 'tier', 'offsetMm', 'widthMm'],
        requiredKeys: const ['wallId', 'tier', 'offsetMm', 'widthMm'],
        disallowNullValues: const ['wallId', 'tier', 'offsetMm', 'widthMm'],
      );
      final val = LayoutFiller(
        wallId: $checkedConvert('wallId', (v) => v as String),
        tier: $checkedConvert(
          'tier',
          (v) => $enumDecode(_$LayoutTierEnumMap, v),
        ),
        offsetMm: $checkedConvert('offsetMm', (v) => (v as num).toInt()),
        widthMm: $checkedConvert('widthMm', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$LayoutFillerToJson(LayoutFiller instance) =>
    <String, dynamic>{
      'wallId': instance.wallId,
      'tier': _$LayoutTierEnumMap[instance.tier]!,
      'offsetMm': instance.offsetMm,
      'widthMm': instance.widthMm,
    };

LayoutCheck _$LayoutCheckFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LayoutCheck', json, ($checkedConvert) {
      $checkKeys(
        json,
        allowedKeys: const ['label', 'passed'],
        requiredKeys: const ['label', 'passed'],
        disallowNullValues: const ['label', 'passed'],
      );
      final val = LayoutCheck(
        label: $checkedConvert('label', (v) => v as String),
        passed: $checkedConvert('passed', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$LayoutCheckToJson(LayoutCheck instance) =>
    <String, dynamic>{'label': instance.label, 'passed': instance.passed};
