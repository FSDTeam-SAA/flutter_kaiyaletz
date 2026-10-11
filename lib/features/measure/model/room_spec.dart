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
const double cornerMinDeg = 45;
const double cornerMaxDeg = 135;

enum RoomShape {
  @JsonValue('straight')
  straight,
  @JsonValue('L')
  l,
  @JsonValue('U')
  u,

  /// Two facing walls with no shared corner. Keep last: AR drafts pick a
  /// shape by index.
  @JsonValue('galley')
  galley,
}

extension RoomShapeX on RoomShape {
  int get wallCount => switch (this) {
    .straight => 1,
    .l => 2,
    .u => 3,
    .galley => 2,
  };

  /// Whether each wall after A starts at the previous wall's corner.
  bool get hasCorners => this != .galley;

  String get label => switch (this) {
    .straight => 'Straight',
    .l => 'L-shape',
    .u => 'U-shape',
    .galley => 'Galley',
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

  /// Inside angle at each corner, between wall i and wall i + 1, so one
  /// fewer than [walls]. Null means every corner is square (90°). Always
  /// null for a [RoomShape.galley].
  final List<double>? cornerAnglesDeg;

  const RoomSpec({
    required this.shape,
    required this.ceilingHeightMm,
    required this.source,
    required this.walls,
    this.cornerAnglesDeg,
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

  /// Lowest ceiling along wall [w]; a sloped ceiling counts at its low end.
  int lowestCeilingMm(int w) => walls[w].lowestCeilingMm(ceilingHeightMm);

  /// Rough wall length free for floor units (base and tall) or, with
  /// [wallUnits], for hung units. Uses the backend engine's blocking rules
  /// (corners, doors, windows, hob) but ignores overlaps between openings,
  /// so the engine's result is the final word.
  int runCapacityMm({bool wallUnits = false}) {
    var total = 0;
    for (var i = 0; i < walls.length; i++) {
      var free = walls[i].lengthMm;
      // Corner from the previous run.
      if (i > 0 && shape.hasCorners) free -= wallUnits ? 350 : 600;
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
    cornerAnglesDeg: cornerAnglesDeg,
  );

  /// Changes the shape, keeping existing walls and adding default ones.
  /// Measured corner angles are kept for the corners that remain.
  RoomSpec withShape(RoomShape next) {
    final kept = walls.take(next.wallCount).toList();
    final angles = cornerAnglesDeg;
    return RoomSpec(
      shape: next,
      ceilingHeightMm: ceilingHeightMm,
      source: source,
      walls: [
        ...kept,
        for (var i = kept.length; i < next.wallCount; i++)
          RoomWall(id: 'w${i + 1}', lengthMm: defaultWallMm),
      ],
      cornerAnglesDeg: angles == null || !next.hasCorners || next.wallCount < 2
          ? null
          : [
              for (var i = 0; i < next.wallCount - 1; i++)
                i < angles.length ? angles[i] : 90,
            ],
    );
  }

  RoomSpec withWall(int index, RoomWall wall) =>
      copyWith(walls: [...walls]..[index] = wall);

  /// Sets the angle at corner [index] (between wall [index] and the next).
  RoomSpec withCornerAngle(int index, double degrees) => RoomSpec(
    shape: shape,
    ceilingHeightMm: ceilingHeightMm,
    source: source,
    walls: walls,
    cornerAnglesDeg: [
      for (var i = 0; i < walls.length - 1; i++)
        i == index ? degrees : cornerAngleDeg(i),
    ],
  );

  /// Angle at corner [index]; 90 when not measured.
  double cornerAngleDeg(int index) {
    final angles = cornerAnglesDeg;
    return angles != null && index < angles.length ? angles[index] : 90;
  }

  /// Every problem with this spec, in the backend's wording. Empty if valid.
  List<String> validate() {
    final errors = <String>[];
    if (ceilingHeightMm < ceilingMinMm || ceilingHeightMm > ceilingMaxMm) {
      errors.add('Ceiling height must be $ceilingMinMm–$ceilingMaxMm mm');
    }
    if (walls.length != shape.wallCount) {
      errors.add('A ${shape.label} kitchen needs ${shape.wallCount} wall(s)');
    }
    final angles = cornerAnglesDeg;
    if (angles != null) {
      if (!shape.hasCorners) {
        errors.add('A galley kitchen has no corners');
      } else if (angles.length != walls.length - 1) {
        errors.add('Need one corner angle per corner (${walls.length - 1})');
      } else {
        for (var i = 0; i < angles.length; i++) {
          if (angles[i] < cornerMinDeg || angles[i] > cornerMaxDeg) {
            errors.add(
              'Corner ${_letter(i)}/${_letter(i + 1)}: angle must be '
              '${cornerMinDeg.round()}–${cornerMaxDeg.round()}°',
            );
          }
        }
      }
    }
    for (var i = 0; i < walls.length; i++) {
      final wall = walls[i];
      final name = wallName(i);
      if (wall.lengthMm < wallMinMm || wall.lengthMm > wallMaxMm) {
        errors.add('$name: length must be $wallMinMm–$wallMaxMm mm');
      }
      for (final h in [wall.heightMm, wall.heightEndMm]) {
        if (h != null && (h < ceilingMinMm || h > ceilingMaxMm)) {
          errors.add(
            '$name: ceiling height must be $ceilingMinMm–$ceilingMaxMm mm',
          );
          break;
        }
      }
      final ceiling = wall.lowestCeilingMm(ceilingHeightMm);
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
        if (sill != null) {
          if (o.type != .window) {
            errors.add('$label: only windows have a sill');
          } else if (sill < 0 || sill >= ceiling) {
            errors.add('$label: sill must be below the ceiling');
          }
        }
        final height = o.heightMm;
        if (height != null) {
          if (o.type != .window && o.type != .door) {
            errors.add('$label: only windows and doors have a height');
          } else if (height < openingMinMm) {
            errors.add('$label: height must be at least $openingMinMm mm');
          } else if ((o.type == .window ? sill ?? 0 : 0) + height > ceiling) {
            errors.add('$label: top must be below the ceiling');
          }
        }
      }
    }
    return errors;
  }

  static String _letter(int i) => String.fromCharCode(65 + i);
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

  /// Ceiling at the wall's left end. Null means [RoomSpec.ceilingHeightMm].
  final int? heightMm;

  /// Ceiling at the right end, for a sloped ceiling. Null means the same as
  /// the left end.
  final int? heightEndMm;

  const RoomWall({
    required this.id,
    required this.lengthMm,
    this.openings = const [],
    this.heightMm,
    this.heightEndMm,
  });

  int lowestCeilingMm(int roomCeilingMm) {
    final start = heightMm ?? roomCeilingMm;
    return min(start, heightEndMm ?? start);
  }

  int highestCeilingMm(int roomCeilingMm) {
    final start = heightMm ?? roomCeilingMm;
    return max(start, heightEndMm ?? start);
  }

  factory RoomWall.fromJson(Map<String, dynamic> json) =>
      _$RoomWallFromJson(json);

  Map<String, dynamic> toJson() => _$RoomWallToJson(this);

  RoomWall copyWith({int? lengthMm, List<RoomOpening>? openings}) => RoomWall(
    id: id,
    lengthMm: lengthMm ?? this.lengthMm,
    openings: openings ?? this.openings,
    heightMm: heightMm,
    heightEndMm: heightEndMm,
  );

  /// Sets both ceiling heights; null clears them back to the room's.
  RoomWall withHeights(int? heightMm, int? heightEndMm) => RoomWall(
    id: id,
    lengthMm: lengthMm,
    openings: openings,
    heightMm: heightMm,
    heightEndMm: heightEndMm,
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

  /// Window or door height (a window's top is sill + height). Null means
  /// not measured; other types never have one.
  final int? heightMm;

  const RoomOpening({
    required this.type,
    required this.offsetMm,
    required this.widthMm,
    this.sillMm,
    this.heightMm,
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

  RoomOpening copyWith({
    int? offsetMm,
    int? widthMm,
    int? sillMm,
    int? heightMm,
  }) => RoomOpening(
    type: type,
    offsetMm: offsetMm ?? this.offsetMm,
    widthMm: widthMm ?? this.widthMm,
    sillMm: sillMm ?? this.sillMm,
    heightMm: heightMm ?? this.heightMm,
  );

  /// Clears [heightMm] back to "not measured".
  RoomOpening withoutHeight() => RoomOpening(
    type: type,
    offsetMm: offsetMm,
    widthMm: widthMm,
    sillMm: sillMm,
  );
}
