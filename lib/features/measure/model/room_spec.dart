import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

import 'measure_state.dart';

part 'room_spec.g.dart';

// Keep these in sync with utils/roomSpec.js in the backend.
const int wallMinMm = 300;
const int wallMaxMm = 20000;
const int ceilingMinMm = 1800;
const int ceilingMaxMm = 5000;
const int openingMinMm = 50;
const int defaultCeilingMm = 2400;
const int defaultWallMm = 3000;

enum RoomShape {
  @JsonValue('straight')
  straight,
  @JsonValue('L')
  l,
  @JsonValue('U')
  u,
}

extension RoomShapeX on RoomShape {
  int get wallCount => switch (this) {
    .straight => 1,
    .l => 2,
    .u => 3,
  };

  String get label => switch (this) {
    .straight => 'Straight',
    .l => 'L-shape',
    .u => 'U-shape',
  };
}

/// How the room was measured. Anything but [manual] is an estimate that
/// should be checked on site.
enum CaptureSource {
  @JsonValue('manual')
  manual,
  @JsonValue('arPoints')
  arPoints,
  @JsonValue('arGuided')
  arGuided,
  @JsonValue('lidarScan')
  lidarScan,
}

enum OpeningType {
  @JsonValue('window')
  window,
  @JsonValue('door')
  door,
  @JsonValue('sink')
  sink,
  @JsonValue('hob')
  hob,
}

extension OpeningTypeX on OpeningType {
  String get label => switch (this) {
    .window => 'Window',
    .door => 'Door',
    .sink => 'Sink',
    .hob => 'Hob',
  };
}

/// "Wall A", "Wall B", ...
String wallName(int index) => 'Wall ${String.fromCharCode(65 + index)}';

/// The kitchen walls the layout is built against. All lengths are integer mm.
@JsonSerializable(
  checked: true,
  disallowUnrecognizedKeys: true,
  explicitToJson: true,
)
class RoomSpec {
  @JsonKey(required: true, disallowNullValue: true)
  final RoomShape shape;

  @JsonKey(required: true, disallowNullValue: true)
  final int ceilingHeightMm;

  @JsonKey(required: true, disallowNullValue: true)
  final CaptureSource source;

  /// In order around the room: A, B, C. Length matches [RoomShape.wallCount].
  @JsonKey(required: true, disallowNullValue: true)
  final List<RoomWall> walls;

  const RoomSpec({
    required this.shape,
    required this.ceilingHeightMm,
    required this.source,
    required this.walls,
  });

  /// Starting point for manual entry: one 3 m wall.
  factory RoomSpec.manual() => const RoomSpec(
    shape: .straight,
    ceilingHeightMm: defaultCeilingMm,
    source: .manual,
    walls: [RoomWall(id: 'w1', lengthMm: defaultWallMm)],
  );

  /// Builds a draft from AR points pinned at the kitchen's floor corners.
  ///
  /// Each segment between consecutive points becomes a wall, measured on
  /// the floor plane only (height differences between taps are ignored).
  /// Extra segments past three are dropped. The ceiling can't be known
  /// from corner points, so it gets the default for the user to correct.
  factory RoomSpec.fromCornerPoints(List<MeasurePoint> points) {
    final lengths = [
      for (var i = 1; i < points.length && i <= 3; i++)
        _floorDistanceMm(points[i - 1], points[i]),
    ];
    return RoomSpec(
      shape: RoomShape.values[(lengths.length - 1).clamp(0, 2)],
      ceilingHeightMm: defaultCeilingMm,
      source: .arPoints,
      walls: [
        for (var i = 0; i < lengths.length; i++)
          RoomWall(id: 'w${i + 1}', lengthMm: lengths[i]),
      ],
    );
  }

  static int _floorDistanceMm(MeasurePoint a, MeasurePoint b) {
    final dx = b.x - a.x, dz = b.z - a.z;
    return (sqrt(dx * dx + dz * dz) * 1000).round();
  }

  bool get isEstimate => source != .manual;

  /// Rough wall length free for floor units (base and tall) or, with
  /// [wallUnits], for hung units. Uses the backend engine's blocking rules
  /// (corners, doors, windows, hob) but ignores overlaps between openings,
  /// so the engine's result is the final word.
  int runCapacityMm({bool wallUnits = false}) {
    var total = 0;
    for (var i = 0; i < walls.length; i++) {
      var free = walls[i].lengthMm;
      if (i > 0) free -= wallUnits ? 350 : 600; // corner from the previous run
      for (final o in walls[i].openings) {
        final blocks = switch (o.type) {
          .door => true,
          .window => wallUnits || (o.sillMm ?? 0) < 900,
          .hob => wallUnits,
          .sink => false,
        };
        if (blocks) free -= o.widthMm;
      }
      total += max(free, 0);
    }
    return total;
  }

  factory RoomSpec.fromJson(Map<String, dynamic> json) =>
      _$RoomSpecFromJson(json);

  Map<String, dynamic> toJson() => _$RoomSpecToJson(this);

  RoomSpec copyWith({
    RoomShape? shape,
    int? ceilingHeightMm,
    CaptureSource? source,
    List<RoomWall>? walls,
  }) => RoomSpec(
    shape: shape ?? this.shape,
    ceilingHeightMm: ceilingHeightMm ?? this.ceilingHeightMm,
    source: source ?? this.source,
    walls: walls ?? this.walls,
  );

  /// Changes the shape, keeping existing walls and adding default ones.
  RoomSpec withShape(RoomShape next) {
    final kept = walls.take(next.wallCount).toList();
    return copyWith(
      shape: next,
      walls: [
        ...kept,
        for (var i = kept.length; i < next.wallCount; i++)
          RoomWall(id: 'w${i + 1}', lengthMm: defaultWallMm),
      ],
    );
  }

  RoomSpec withWall(int index, RoomWall wall) =>
      copyWith(walls: [...walls]..[index] = wall);

  /// Every problem with this spec, in the backend's wording. Empty if valid.
  List<String> validate() {
    final errors = <String>[];
    if (ceilingHeightMm < ceilingMinMm || ceilingHeightMm > ceilingMaxMm) {
      errors.add('Ceiling height must be $ceilingMinMm–$ceilingMaxMm mm');
    }
    if (walls.length != shape.wallCount) {
      errors.add('A ${shape.label} kitchen needs ${shape.wallCount} wall(s)');
    }
    for (var i = 0; i < walls.length; i++) {
      final wall = walls[i];
      final name = wallName(i);
      if (wall.lengthMm < wallMinMm || wall.lengthMm > wallMaxMm) {
        errors.add('$name: length must be $wallMinMm–$wallMaxMm mm');
      }
      for (var j = 0; j < wall.openings.length; j++) {
        final o = wall.openings[j];
        final label = '$name, ${o.type.label.toLowerCase()} ${j + 1}';
        if (o.widthMm < openingMinMm) {
          errors.add('$label: width must be at least $openingMinMm mm');
        }
        if (o.offsetMm < 0 || o.offsetMm + o.widthMm > wall.lengthMm) {
          errors.add('$label: runs past the end of the wall');
        }
        final sill = o.sillMm;
        if (sill != null && (sill < 0 || sill >= ceilingHeightMm)) {
          errors.add('$label: sill must be below the ceiling');
        }
      }
    }
    return errors;
  }
}

@JsonSerializable(
  checked: true,
  disallowUnrecognizedKeys: true,
  explicitToJson: true,
)
class RoomWall {
  @JsonKey(required: true, disallowNullValue: true)
  final String id;

  @JsonKey(required: true, disallowNullValue: true)
  final int lengthMm;

  final List<RoomOpening> openings;

  const RoomWall({
    required this.id,
    required this.lengthMm,
    this.openings = const [],
  });

  factory RoomWall.fromJson(Map<String, dynamic> json) =>
      _$RoomWallFromJson(json);

  Map<String, dynamic> toJson() => _$RoomWallToJson(this);

  RoomWall copyWith({int? lengthMm, List<RoomOpening>? openings}) => RoomWall(
    id: id,
    lengthMm: lengthMm ?? this.lengthMm,
    openings: openings ?? this.openings,
  );
}

/// A window, door or fixed service point along a wall.
@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class RoomOpening {
  @JsonKey(required: true, disallowNullValue: true)
  final OpeningType type;

  /// Distance from the wall's left end to the opening's left edge.
  @JsonKey(required: true, disallowNullValue: true)
  final int offsetMm;

  @JsonKey(required: true, disallowNullValue: true)
  final int widthMm;

  /// Floor to the bottom of a window. Null for everything else.
  final int? sillMm;

  const RoomOpening({
    required this.type,
    required this.offsetMm,
    required this.widthMm,
    this.sillMm,
  });

  /// Sensible size for a newly added opening of [type].
  factory RoomOpening.defaultFor(OpeningType type) => switch (type) {
    .window => const RoomOpening(
      type: .window,
      offsetMm: 0,
      widthMm: 900,
      sillMm: 1000,
    ),
    .door => const RoomOpening(type: .door, offsetMm: 0, widthMm: 820),
    .sink => const RoomOpening(type: .sink, offsetMm: 0, widthMm: 800),
    .hob => const RoomOpening(type: .hob, offsetMm: 0, widthMm: 600),
  };

  factory RoomOpening.fromJson(Map<String, dynamic> json) =>
      _$RoomOpeningFromJson(json);

  Map<String, dynamic> toJson() => _$RoomOpeningToJson(this);

  RoomOpening copyWith({int? offsetMm, int? widthMm, int? sillMm}) =>
      RoomOpening(
        type: type,
        offsetMm: offsetMm ?? this.offsetMm,
        widthMm: widthMm ?? this.widthMm,
        sillMm: sillMm ?? this.sillMm,
      );
}
