import 'dart:math';

import 'package:flutter_kaiyaletz/features/measure/model/room_scan.dart';
import 'package:flutter_kaiyaletz/features/measure/model/room_spec.dart';
import 'package:flutter_test/flutter_test.dart';

// A 4 m × 3 m room seen from above, camera in the middle at (0, 0).
// ARKit: x right, z towards the viewer, so "north" is -z.
//   north wall z = -1.5, x -2 → 2
//   east wall  x =  2,   z -1.5 → 1.5
//   south wall z =  1.5
//   west wall  x = -2
ScanWall wall(String id, List<double> a, List<double> b, {double h = 2.4}) =>
    ScanWall(
      id: id,
      start: Point(a[0], a[1]),
      end: Point(b[0], b[1]),
      bottomY: -1.2,
      heightM: h,
    );

final north = wall('N', [2, -1.5], [-2, -1.5]); // scanned right to left
final east = wall('E', [2, 1.5], [2, -1.5]);
final south = wall('S', [-2, 1.5], [2, 1.5]);
final west = wall('W', [-2, -1.5], [-2, 1.5]);

RoomScan scan(List<ScanItem> items, {List<ScanWall>? walls}) => RoomScan(
  walls: walls ?? [north, east, south, west],
  items: items,
  camera: const Point(0, 0),
);

ScanItem item(
  ScanItemKind kind,
  double x,
  double z, {
  double w = 0.9,
  double h = 1.0,
  double bottom = 0,
}) => ScanItem(
  id: '$kind$x$z',
  kind: kind,
  center: Point(x, z),
  widthM: w,
  heightM: h,
  bottomY: -1.2 + bottom,
);

void main() {
  test('one wall reads left to right from inside the room', () {
    // Window centred 0.5 m right of the north wall's middle.
    final r = scan([
      item(.window, 0.5, -1.5, w: 1, h: 1.1, bottom: 1.05),
    ]).toRoomSpec(['N']);
    expect(r.room.shape, RoomShape.straight);
    expect(r.room.source, CaptureSource.lidarScan);
    expect(r.room.walls.single.lengthMm, 4000);
    expect(r.room.cornerAnglesDeg, isNull);
    final o = r.room.walls.single.openings.single;
    // Left end is x = -2, so the window centre is 2.5 m along.
    expect(
      (o.offsetMm, o.widthMm, o.sillMm, o.heightMm),
      (2000, 1000, 1050, 1100),
    );
    expect(r.room.validate(), isEmpty);
  });

  test('L: wall A ends at the corner with B, square angle', () {
    final r = scan([]).toRoomSpec(['N', 'E']);
    expect(r.room.shape, RoomShape.l);
    expect([for (final w in r.room.walls) w.lengthMm], [4000, 3000]);
    expect(r.room.cornerAnglesDeg, [90]);
    expect(r.notes, isEmpty);
  });

  test('walls picked right to left are renamed left to right', () {
    final r = scan([
      item(.door, 2, 0.5, w: 0.8, h: 2.04),
    ]).toRoomSpec(['E', 'N']);
    expect(r.notes, contains(startsWith('Walls were renamed')));
    // Now A = north (4 m), B = east (3 m), the door on B.
    expect([for (final w in r.room.walls) w.lengthMm], [4000, 3000]);
    final door = r.room.walls[1].openings.single;
    // East wall runs from the corner (z = -1.5): door centre 2 m along.
    expect((door.offsetMm, door.widthMm, door.heightMm), (1600, 800, 2040));
  });

  test('U with an off-square corner', () {
    final skewEast = wall('E', [2, -1.5], [2.1, 1.5]); // ~1.9° out
    final r = scan(
      [],
      walls: [west, north, skewEast],
    ).toRoomSpec(['W', 'N', 'E']);
    expect(r.room.shape, RoomShape.u);
    expect(r.room.cornerAnglesDeg![0], 90);
    expect(r.room.cornerAnglesDeg![1], closeTo(91.9, 0.1));
    expect(r.room.validate(), isEmpty);
  });

  test('two facing walls make a galley, both left to right', () {
    final r = scan([
      item(.sink, 1, -1.2, w: 0.8), // in front of the north wall
      item(.stove, -1, 1.2, w: 0.6), // in front of the south wall
    ]).toRoomSpec(['N', 'S']);
    expect(r.room.shape, RoomShape.galley);
    expect(r.room.cornerAnglesDeg, isNull);
    final sink = r.room.walls[0].openings.single;
    expect(
      (sink.type, sink.offsetMm, sink.widthMm),
      (OpeningType.sink, 2600, 800),
    );
    // Facing south from the middle, x = 2 is on the left.
    final hob = r.room.walls[1].openings.single;
    expect((hob.type, hob.offsetMm, hob.widthMm), (OpeningType.hob, 2700, 600));
    expect(r.room.validate(), isEmpty);
  });

  test('openings off the wall line are dropped', () {
    final r = scan([
      item(.window, 0, -1.3), // 20 cm in front of the north wall
      item(.door, 0, -1.4, w: 0.8, h: 2), // 10 cm: kept
      item(.sink, 0, 0), // middle of the room: an island
      item(.other, 0, -1.5),
    ]).toRoomSpec(['N']);
    expect(
      [for (final o in r.room.walls.single.openings) o.type],
      [OpeningType.door],
    );
  });

  test('sloped or lower wall keeps its own height', () {
    final low = wall('E', [2, -1.5], [2, 1.5], h: 2.2);
    final r = scan([], walls: [north, low, south]).toRoomSpec(['N', 'E', 'S']);
    expect(r.room.ceilingHeightMm, 2400);
    expect([for (final w in r.room.walls) w.heightMm], [null, 2200, null]);
    // 2.41 m is within noise of 2.40 m.
    final near = wall('E', [2, -1.5], [2, 1.5], h: 2.41);
    final r2 = scan([], walls: [north, near]).toRoomSpec(['N', 'E']);
    expect([for (final w in r2.room.walls) w.heightMm], [null, null]);
  });

  test('opening past the wall end is trimmed; unsized sink gets 800', () {
    final r = scan([
      item(.door, 1.9, -1.5, w: 0.8, h: 2.1),
      item(.sink, 0, -1.2, w: 0),
    ]).toRoomSpec(['N']);
    final [sink, door] = r.room.walls.single.openings;
    expect((door.offsetMm, door.widthMm), (3500, 500));
    expect((sink.offsetMm, sink.widthMm), (1600, 800));
    expect(r.room.validate(), isEmpty);
  });

  test('walls that do not meet are flagged', () {
    // South and north are opposite walls, so they share no corner.
    final r = scan([]).toRoomSpec(['S', 'N', 'W']);
    expect(r.notes, contains(contains("don't meet")));
  });

  test('final walls are matched to live picks by id, then position', () {
    final live = scan([]);
    // Final pass: north kept its id, east got a new one and moved 5 cm.
    final built = scan(
      [],
      walls: [
        north,
        wall('E2', [2.05, 1.5], [2.05, -1.5]),
        south,
      ],
    );
    expect(built.matchWalls(live, ['N', 'E']), ['N', 'E2']);
    // West is missing from the final pass.
    expect(built.matchWalls(live, ['N', 'W']), isNull);
  });

  test('parses the native payload', () {
    final s = RoomScan.fromMap({
      'walls': [
        {
          'id': 'a',
          'start': [0, 0],
          'end': [3, 0],
          'bottomY': -1.1,
          'heightM': 2.5,
          'confidence': 'low',
        },
      ],
      'items': [
        {
          'id': 'b',
          'kind': 'refrigerator',
          'center': [1, 0.3],
          'widthM': 0.9,
          'heightM': 1.8,
          'bottomY': -1.1,
        },
      ],
      'camera': [1, 2],
      'instruction': 'slowDown',
    });
    expect(s.walls.single.lengthM, 3);
    expect(s.walls.single.confidence, ScanConfidence.low);
    expect(s.items.single.kind, ScanItemKind.other);
    expect(s.instruction, 'slowDown');
    expect(RoomScan.fromMap({'instruction': 'normal'}).instruction, isNull);
    expect(
      s.toRoomSpec(['a']).notes,
      contains(startsWith('Some walls were scanned with low confidence')),
    );
  });
}
