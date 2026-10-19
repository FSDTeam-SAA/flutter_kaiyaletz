import 'dart:math';

import 'room_spec.dart';

// Turns an Apple RoomPlan scan (ios/Runner/RoomScanView.swift) into a
// RoomSpec. Pure Dart so it can be unit tested without a device.
//
// World units from native are meters, y up. Walls are measured on the
// floor plane (x, z); heights are y above the floor.

/// Doors and windows sit in the wall, so they must be this close to it.
const double _maxOpeningOffWallM = 0.15;

/// A sink or stove stands in front of its wall (worktop depth), so allow
/// more, but not so much that an island is pinned to a wall.
const double _maxObjectOffWallM = 0.9;

/// Two picked walls closer to parallel than this, and not touching, are a
/// galley.
const double _galleyMaxAngleDeg = 20;

/// Neighbouring walls whose ends are further apart than this don't meet.
const double _cornerGapM = 0.3;

/// A wall's own height is only kept when it differs from the room's by
/// more than this.
const int _wallHeightNoiseMm = 20;

enum ScanConfidence { low, medium, high }

/// One wall found by RoomPlan, as a segment on the floor plane.
class ScanWall {
  const ScanWall({
    required this.id,
    required this.start,
    required this.end,
    required this.bottomY,
    required this.heightM,
    this.confidence = ScanConfidence.high,
  });

  final String id;

  /// Ends on the floor plane, (x, z) in meters.
  final Point<double> start, end;
  final double bottomY;
  final double heightM;
  final ScanConfidence confidence;

  double get lengthM => start.distanceTo(end);

  factory ScanWall.fromMap(Map<dynamic, dynamic> m) => ScanWall(
    id: m['id'] as String,
    start: _xz(m['start']),
    end: _xz(m['end']),
    bottomY: _d(m['bottomY']),
    heightM: _d(m['heightM']),
    confidence: _confidence(m['confidence']),
  );
}

enum ScanItemKind { door, window, opening, sink, stove, other }

/// A door, window, open passage or object found by RoomPlan.
class ScanItem {
  const ScanItem({
    required this.id,
    required this.kind,
    required this.center,
    required this.widthM,
    required this.heightM,
    required this.bottomY,
  });

  final String id;
  final ScanItemKind kind;

  /// Centre on the floor plane, (x, z) in meters.
  final Point<double> center;
  final double widthM;
  final double heightM;
  final double bottomY;

  factory ScanItem.fromMap(Map<dynamic, dynamic> m) => ScanItem(
    id: m['id'] as String,
    kind: ScanItemKind.values.firstWhere(
      (k) => k.name == m['kind'],
      orElse: () => ScanItemKind.other,
    ),
    center: _xz(m['center']),
    widthM: _d(m['widthM']),
    heightM: _d(m['heightM']),
    bottomY: _d(m['bottomY']),
  );
}

/// A live or final snapshot of the RoomPlan scan.
class RoomScan {
  const RoomScan({
    this.walls = const [],
    this.items = const [],
    this.camera,
    this.instruction,
  });

  final List<ScanWall> walls;
  final List<ScanItem> items;

  /// Where the phone was, (x, z). The user stands inside the room, so this
  /// tells which side of a wall is the room.
  final Point<double>? camera;

  /// RoomPlan's coaching hint, e.g. "slowDown". Null when all is well.
  final String? instruction;

  factory RoomScan.fromMap(Map<dynamic, dynamic> m) => RoomScan(
    walls: [
      for (final w in (m['walls'] as List? ?? const []))
        ScanWall.fromMap(w as Map),
    ],
    items: [
      for (final i in (m['items'] as List? ?? const []))
        ScanItem.fromMap(i as Map),
    ],
    camera: m['camera'] == null ? null : _xz(m['camera']),
    instruction: switch (m['instruction']) {
      'normal' || null => null,
      final String s => s,
      _ => null,
    },
  );

  /// Floor height: the lowest wall bottom.
  double get floorY =>
      walls.isEmpty ? 0 : walls.map((w) => w.bottomY).reduce(min);

  /// The walls of this (final) scan that match [ids] picked in the [live]
  /// scan. RoomPlan's final pass may give walls new ids, so a wall that
  /// isn't found by id is matched by its midpoint (within 0.5 m). Null if
  /// any picked wall has no match.
  List<String>? matchWalls(RoomScan live, List<String> ids) {
    final mine = {for (final w in walls) w.id: w};
    final liveById = {for (final w in live.walls) w.id: w};
    final used = <String>{};
    final matched = <String>[];
    for (final id in ids) {
      if (mine.containsKey(id) && used.add(id)) {
        matched.add(id);
        continue;
      }
      final picked = liveById[id];
      if (picked == null) return null;
      final mid = _mid(picked.start, picked.end);
      ScanWall? best;
      for (final w in walls) {
        if (used.contains(w.id)) continue;
        final d = _mid(w.start, w.end).distanceTo(mid);
        if (d <= 0.5 &&
            (best == null || d < _mid(best.start, best.end).distanceTo(mid))) {
          best = w;
        }
      }
      if (best == null) return null;
      used.add(best.id);
      matched.add(best.id);
    }
    return matched;
  }

  /// Builds the kitchen from the walls the user picked, in order (A, B, C).
  /// Extra walls past three are ignored.
  RoomScanResult toRoomSpec(List<String> wallIds) {
    final notes = <String>[];
    final byId = {for (final w in walls) w.id: w};
    final picked = [
      for (final id in wallIds.take(3))
        if (byId[id] case final w?) _Seg(w.start, w.end, w),
    ];
    if (picked.isEmpty) {
      throw ArgumentError('Pick at least one wall');
    }

    final galley =
        picked.length == 2 &&
        _lineAngleDeg(picked[0], picked[1]) < _galleyMaxAngleDeg &&
        _closestEnds(picked[0], picked[1]).$3 > _cornerGapM;

    final List<_Seg> run;
    if (galley || picked.length == 1) {
      // Each wall reads left to right as seen from inside the room.
      run = [for (final s in picked) _leftToRight(s)];
    } else {
      run = _orientRun(picked, notes);
    }

    // Heights.
    final heights = [for (final s in run) _mm(s.wall.heightM)]..sort();
    final ceiling = heights[heights.length ~/ 2];
    final floorY = this.floorY;

    final specWalls = <RoomWall>[];
    for (var i = 0; i < run.length; i++) {
      final s = run[i];
      final lengthMm = _mm(s.lengthM);
      final heightMm = _mm(s.wall.heightM);
      specWalls.add(
        RoomWall(
          id: 'w${i + 1}',
          lengthMm: lengthMm,
          heightMm: (heightMm - ceiling).abs() > _wallHeightNoiseMm
              ? heightMm
              : null,
          openings: [],
        ),
      );
    }

    // Openings and services onto their nearest picked wall.
    for (final item in items) {
      final type = switch (item.kind) {
        .door || .opening => OpeningType.door,
        .window => OpeningType.window,
        .sink => OpeningType.sink,
        .stove => OpeningType.hob,
        .other => null,
      };
      if (type == null) continue;
      final maxOff = type == .sink || type == .hob
          ? _maxObjectOffWallM
          : _maxOpeningOffWallM;
      final hit = _nearestWall(run, item.center, maxOff);
      if (hit == null) continue;
      final (w, along) = hit;
      final wall = specWalls[w];
      final wallCeiling = wall.heightMm ?? ceiling;

      // A sink or stove RoomPlan couldn't size gets the usual width.
      final detectedMm = _mm(item.widthM);
      var widthMm = switch (type) {
        .sink when detectedMm < 300 => 800,
        .hob when detectedMm < 300 => 600,
        _ => detectedMm,
      };
      var offsetMm = _mm(along) - widthMm ~/ 2;
      // Keep it on the wall.
      if (offsetMm < 0) {
        widthMm += offsetMm;
        offsetMm = 0;
      }
      if (offsetMm + widthMm > wall.lengthMm) {
        widthMm = wall.lengthMm - offsetMm;
      }
      if (widthMm < openingMinMm) continue;

      int? sillMm, heightMm;
      if (type == .window) {
        sillMm = max(0, _mm(item.bottomY - floorY));
        if (sillMm >= wallCeiling) continue;
        heightMm = min(_mm(item.heightM), wallCeiling - sillMm);
      } else if (type == .door) {
        heightMm = min(_mm(item.heightM), wallCeiling);
      }
      if (heightMm != null && heightMm < openingMinMm) heightMm = null;

      specWalls[w] = wall.copyWith(
        openings: [
          ...wall.openings,
          RoomOpening(
            type: type,
            offsetMm: offsetMm,
            widthMm: widthMm,
            sillMm: sillMm,
            heightMm: heightMm,
          ),
        ]..sort((a, b) => a.offsetMm.compareTo(b.offsetMm)),
      );
    }

    final shape = galley ? RoomShape.galley : RoomShape.values[run.length - 1];
    final angles = galley || run.length < 2
        ? null
        : [
            for (var i = 0; i + 1 < run.length; i++)
              _cornerAngleDeg(run[i], run[i + 1]),
          ];

    if (run.any((s) => s.wall.confidence == ScanConfidence.low)) {
      notes.add('Some walls were scanned with low confidence. Check them.');
    }

    return RoomScanResult(
      RoomSpec(
        shape: shape,
        ceilingHeightMm: ceiling,
        source: .lidarScan,
        walls: specWalls,
        cornerAnglesDeg: angles,
      ),
      notes,
    );
  }

  /// Orients connected walls so each ends at the corner it shares with the
  /// next, and the run reads left to right from inside the room (wall
  /// offsets are measured from the left end). Reverses the run if needed.
  List<_Seg> _orientRun(List<_Seg> picked, List<String> notes) {
    final run = <_Seg>[];
    // Wall A: its end is the one nearest wall B.
    final (endA, _, _) = _closestEnds(picked[0], picked[1]);
    run.add(endA ? picked[0] : picked[0].flipped);
    for (var i = 1; i < picked.length; i++) {
      final prevEnd = run[i - 1].b;
      final s = picked[i];
      final oriented = s.a.distanceTo(prevEnd) <= s.b.distanceTo(prevEnd)
          ? s
          : s.flipped;
      if (oriented.a.distanceTo(prevEnd) > _cornerGapM) {
        notes.add(
          '${wallName(i - 1)} and ${wallName(i)} don\'t meet. '
          'Check that the walls were picked in order.',
        );
      }
      run.add(oriented);
    }

    if (_readsLeftToRight(run.first)) return run;
    notes.add('Walls were renamed so they run left to right.');
    return [for (final s in run.reversed) s.flipped];
  }

  _Seg _leftToRight(_Seg s) => _readsLeftToRight(s) ? s : s.flipped;

  /// Whether a→b runs left to right for someone standing in the room
  /// facing the wall. Without a camera position, keeps the scan's order.
  bool _readsLeftToRight(_Seg s) {
    final cam = camera;
    if (cam == null) return true;
    final u = s.dir;
    // Normal pointing into the room, towards the camera.
    var n = Point(-u.y, u.x);
    final mid = _mid(s.a, s.b);
    if (_dot(n, cam - mid) < 0) n = Point(-n.x, -n.y);
    // Facing the wall (direction -n), "right" on the (x, z) floor is
    // (n.z, -n.x) in ARKit's y-up, right-handed world.
    final right = Point(n.y, -n.x);
    return _dot(u, right) > 0;
  }
}

/// A converted scan, plus anything the user should double-check.
class RoomScanResult {
  const RoomScanResult(this.room, this.notes);

  final RoomSpec room;
  final List<String> notes;
}

/// A picked wall with a chosen direction a → b.
class _Seg {
  const _Seg(this.a, this.b, this.wall);

  final Point<double> a, b;
  final ScanWall wall;

  _Seg get flipped => _Seg(b, a, wall);
  double get lengthM => a.distanceTo(b);

  Point<double> get dir {
    final d = b - a;
    final len = d.magnitude;
    return len == 0 ? const Point(1, 0) : Point(d.x / len, d.y / len);
  }
}

/// Which ends of [s] and [t] are closest: (s's end is b, t's end is a,
/// distance). Used to find the shared corner.
(bool, bool, double) _closestEnds(_Seg s, _Seg t) {
  var best = (true, true, double.infinity);
  for (final sb in [true, false]) {
    for (final ta in [true, false]) {
      final d = (sb ? s.b : s.a).distanceTo(ta ? t.a : t.b);
      if (d < best.$3) best = (sb, ta, d);
    }
  }
  return best;
}

/// Angle between the two walls' lines, 0–90°, ignoring direction.
double _lineAngleDeg(_Seg s, _Seg t) {
  final c = _dot(s.dir, t.dir).abs().clamp(0.0, 1.0);
  return acos(c) * 180 / pi;
}

/// Inside angle where [s] (ending at the corner) meets [t] (starting
/// there): 90° for a square corner. One decimal place.
double _cornerAngleDeg(_Seg s, _Seg t) {
  final c = _dot(s.dir, t.dir).clamp(-1.0, 1.0);
  final turn = acos(c) * 180 / pi;
  return ((180 - turn) * 10).round() / 10;
}

/// The picked wall nearest [p] within [maxOff] meters, and how far along
/// it (meters from its start) [p] projects. Null if none is close enough.
(int, double)? _nearestWall(List<_Seg> run, Point<double> p, double maxOff) {
  (int, double, double)? best;
  for (var i = 0; i < run.length; i++) {
    final s = run[i];
    final u = s.dir;
    final t = _dot(p - s.a, u); // t = dot(p − a, u)
    if (t < -maxOff || t > s.lengthM + maxOff) continue;
    final off = _dot(p - s.a, Point(-u.y, u.x)).abs();
    if (off > maxOff) continue;
    if (best == null || off < best.$3) best = (i, t.clamp(0.0, s.lengthM), off);
  }
  return best == null ? null : (best.$1, best.$2);
}

double _dot(Point<double> a, Point<double> b) => a.x * b.x + a.y * b.y;

Point<double> _mid(Point<double> a, Point<double> b) =>
    Point((a.x + b.x) / 2, (a.y + b.y) / 2);

int _mm(double meters) => (meters * 1000).round();

double _d(Object? v) => (v as num?)?.toDouble() ?? 0;

Point<double> _xz(Object? v) {
  final l = v as List;
  return Point((l[0] as num).toDouble(), (l[1] as num).toDouble());
}

ScanConfidence _confidence(Object? v) => ScanConfidence.values.firstWhere(
  (c) => c.name == v,
  orElse: () => ScanConfidence.high,
);
