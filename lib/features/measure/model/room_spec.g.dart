// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_spec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomSpec _$RoomSpecFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RoomSpec', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const [
      'shape',
      'ceilingHeightMm',
      'source',
      'walls',
      'cornerAnglesDeg',
    ],
    requiredKeys: const ['shape', 'ceilingHeightMm', 'source', 'walls'],
    disallowNullValues: const ['shape', 'ceilingHeightMm', 'source', 'walls'],
  );
  final val = RoomSpec(
    shape: $checkedConvert('shape', (v) => $enumDecode(_$RoomShapeEnumMap, v)),
    ceilingHeightMm: $checkedConvert(
      'ceilingHeightMm',
      (v) => (v as num).toInt(),
    ),
    source: $checkedConvert(
      'source',
      (v) => $enumDecode(_$CaptureSourceEnumMap, v),
    ),
    walls: $checkedConvert(
      'walls',
      (v) => (v as List<dynamic>)
          .map((e) => RoomWall.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    cornerAnglesDeg: $checkedConvert(
      'cornerAnglesDeg',
      (v) => (v as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$RoomSpecToJson(RoomSpec instance) => <String, dynamic>{
  'shape': _$RoomShapeEnumMap[instance.shape]!,
  'ceilingHeightMm': instance.ceilingHeightMm,
  'source': _$CaptureSourceEnumMap[instance.source]!,
  'walls': instance.walls.map((e) => e.toJson()).toList(),
  'cornerAnglesDeg': instance.cornerAnglesDeg,
};

const _$RoomShapeEnumMap = {
  RoomShape.straight: 'straight',
  RoomShape.l: 'L',
  RoomShape.u: 'U',
  RoomShape.galley: 'galley',
};

const _$CaptureSourceEnumMap = {
  CaptureSource.manual: 'manual',
  CaptureSource.arPoints: 'arPoints',
  CaptureSource.arGuided: 'arGuided',
  CaptureSource.lidarScan: 'lidarScan',
};

RoomWall _$RoomWallFromJson(Map<String, dynamic> json) => $checkedCreate(
  'RoomWall',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      allowedKeys: const [
        'id',
        'lengthMm',
        'openings',
        'heightMm',
        'heightEndMm',
      ],
      requiredKeys: const ['id', 'lengthMm'],
      disallowNullValues: const ['id', 'lengthMm'],
    );
    final val = RoomWall(
      id: $checkedConvert('id', (v) => v as String),
      lengthMm: $checkedConvert('lengthMm', (v) => (v as num).toInt()),
      openings: $checkedConvert(
        'openings',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => RoomOpening.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      ),
      heightMm: $checkedConvert('heightMm', (v) => (v as num?)?.toInt()),
      heightEndMm: $checkedConvert('heightEndMm', (v) => (v as num?)?.toInt()),
    );
    return val;
  },
);

Map<String, dynamic> _$RoomWallToJson(RoomWall instance) => <String, dynamic>{
  'id': instance.id,
  'lengthMm': instance.lengthMm,
  'openings': instance.openings.map((e) => e.toJson()).toList(),
  'heightMm': instance.heightMm,
  'heightEndMm': instance.heightEndMm,
};

RoomOpening _$RoomOpeningFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RoomOpening', json, ($checkedConvert) {
  $checkKeys(
    json,
    allowedKeys: const ['type', 'offsetMm', 'widthMm', 'sillMm', 'heightMm'],
    requiredKeys: const ['type', 'offsetMm', 'widthMm'],
    disallowNullValues: const ['type', 'offsetMm', 'widthMm'],
  );
  final val = RoomOpening(
    type: $checkedConvert('type', (v) => $enumDecode(_$OpeningTypeEnumMap, v)),
    offsetMm: $checkedConvert('offsetMm', (v) => (v as num).toInt()),
    widthMm: $checkedConvert('widthMm', (v) => (v as num).toInt()),
    sillMm: $checkedConvert('sillMm', (v) => (v as num?)?.toInt()),
    heightMm: $checkedConvert('heightMm', (v) => (v as num?)?.toInt()),
  );
  return val;
});

Map<String, dynamic> _$RoomOpeningToJson(RoomOpening instance) =>
    <String, dynamic>{
      'type': _$OpeningTypeEnumMap[instance.type]!,
      'offsetMm': instance.offsetMm,
      'widthMm': instance.widthMm,
      'sillMm': instance.sillMm,
      'heightMm': instance.heightMm,
    };

const _$OpeningTypeEnumMap = {
  OpeningType.window: 'window',
  OpeningType.door: 'door',
  OpeningType.sink: 'sink',
  OpeningType.hob: 'hob',
};
