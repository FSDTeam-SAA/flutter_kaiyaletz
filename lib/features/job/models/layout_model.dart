import 'dart:math';

import 'package:json_annotation/json_annotation.dart';

import '../../measure/model/room_spec.dart';

part 'layout_model.g.dart';

/// Which height band a cabinet occupies.
enum LayoutTier {
  @JsonValue('base')
  base,
  @JsonValue('wall')
  wall,
  @JsonValue('tall')
  tall,
}

/// Where every selected cabinet goes, as built by the backend layout engine
/// (`utils/layoutEngine.js`). All positions are mm from a wall's left end.
@JsonSerializable(
  checked: true,
  disallowUnrecognizedKeys: true,
  explicitToJson: true,
)
class JobLayout {
  /// e.g. "rules-v1".
  @JsonKey(required: true, disallowNullValue: true)
  final String engine;

  @JsonKey(required: true, disallowNullValue: true)
  final List<LayoutItem> items;

  final List<LayoutFiller> fillers;

  /// Problems the user should know about, e.g. a unit that didn't fit.
  final List<String> warnings;

  final List<LayoutCheck> checks;

  const JobLayout({
    required this.engine,
    required this.items,
    this.fillers = const [],
    this.warnings = const [],
    this.checks = const [],
  });

  /// Reads `aiLayout.layoutData`. Jobs from before the layout engine hold a
  /// different placeholder object there; those read as "no layout yet".
  static JobLayout? tryParse(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    try {
      return JobLayout.fromJson(json);
    } on CheckedFromJsonException {
      return null;
    }
  }

  factory JobLayout.fromJson(Map<String, dynamic> json) =>
      _$JobLayoutFromJson(json);

  Map<String, dynamic> toJson() => _$JobLayoutToJson(this);

  /// Swaps item [index] with its nearest same-tier neighbour on the same
  /// wall, to the left ([dir] -1) or right (+1). The pair keeps its outer
  /// edges, so other cabinets don't move. Returns null when there is no
  /// neighbour or the result would break a placement rule.
  ///
  /// Item order is kept so callers can keep [index] selected. Fillers are
  /// dropped until the backend rebuilds them on save.
  JobLayout? swapWithNeighbour(RoomSpec room, int index, int dir) {
    final item = items[index];
    final row =
        items
            .where((i) => i.wallId == item.wallId && i.tier == item.tier)
            .toList()
          ..sort((a, b) => a.offsetMm.compareTo(b.offsetMm));
    final at = row.indexOf(item) + dir;
    if (at < 0 || at >= row.length) return null;

    final other = row[at];
    final (left, right) = dir < 0 ? (other, item) : (item, other);
    final end = right.offsetMm + right.widthMm;
    final moved = {
      right: right.copyWith(offsetMm: left.offsetMm),
      left: left.copyWith(offsetMm: end - left.widthMm),
    };

    final next = JobLayout(
      engine: engine,
      items: [for (final i in items) moved[i] ?? i],
      warnings: warnings,
      checks: checks,
    );
    return next.problems(room).isEmpty ? next : null;
  }

  /// Placement rules broken by this layout. Mirrors checkLayout() in the
  /// backend's utils/layoutEngine.js.
  List<String> problems(RoomSpec room) {
    final found = <String>[];
    for (var n = 0; n < items.length; n++) {
      final item = items[n];
      final w = room.walls.indexWhere((wall) => wall.id == item.wallId);
      if (w < 0) {
        found.add('${item.sku}: invalid position');
        continue;
      }
      final (start, end) = (item.offsetMm, item.offsetMm + item.widthMm);
      if (start < 0 || end > room.walls[w].lengthMm) {
        found.add('${item.sku} runs past the end of the wall');
      } else if (_roomSpans(
        room,
        w,
        item.tier,
      ).any((s) => _overlaps(s, (start, end)))) {
        found.add('${item.sku} blocks a door, window, hob or corner');
      }
      for (final other in items.skip(n + 1)) {
        if (other.wallId == item.wallId &&
            _conflicts(item.tier, other.tier) &&
            _overlaps(
              (start, end),
              (other.offsetMm, other.offsetMm + other.widthMm),
            )) {
          found.add('${item.sku} overlaps ${other.sku}');
        }
      }
    }
    return found;
  }

  /// Space a tier can't use on wall [w]: previous run's corner, doors,
  /// windows and the hob. Mirrors roomSpans() in the backend.
  List<(int, int)> _roomSpans(RoomSpec room, int w, LayoutTier tier) {
    int depthOf(LayoutTier t) => items
        .where((i) => i.tier == t)
        .fold(t == .wall ? 350 : 600, (d, i) => max(d, i.depthMm));

    return [
      if (w > 0) (0, depthOf(tier == .wall ? .wall : .base)),
      for (final o in room.walls[w].openings)
        if (switch (o.type) {
          .door => true,
          .window => tier != .base || (o.sillMm ?? 0) < 900,
          .hob => tier != .base,
          .sink => false,
        })
          (o.offsetMm, o.offsetMm + o.widthMm),
    ];
  }

  static bool _overlaps((int, int) a, (int, int) b) =>
      a.$1 < b.$2 && b.$1 < a.$2;

  /// A tall unit fills the base and wall space in front of it.
  static bool _conflicts(LayoutTier a, LayoutTier b) =>
      a == b || a == .tall || b == .tall;
}

@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class LayoutItem {
  @JsonKey(required: true, disallowNullValue: true)
  final String productId;

  @JsonKey(required: true, disallowNullValue: true)
  final String sku;

  final String? name;

  @JsonKey(required: true, disallowNullValue: true)
  final LayoutTier tier;

  /// Matches a [RoomWall.id].
  @JsonKey(required: true, disallowNullValue: true)
  final String wallId;

  @JsonKey(required: true, disallowNullValue: true)
  final int offsetMm;

  @JsonKey(required: true, disallowNullValue: true)
  final int widthMm;

  @JsonKey(required: true, disallowNullValue: true)
  final int heightMm;

  @JsonKey(required: true, disallowNullValue: true)
  final int depthMm;

  const LayoutItem({
    required this.productId,
    required this.sku,
    this.name,
    required this.tier,
    required this.wallId,
    required this.offsetMm,
    required this.widthMm,
    required this.heightMm,
    required this.depthMm,
  });

  factory LayoutItem.fromJson(Map<String, dynamic> json) =>
      _$LayoutItemFromJson(json);

  Map<String, dynamic> toJson() => _$LayoutItemToJson(this);

  LayoutItem copyWith({String? wallId, int? offsetMm}) => LayoutItem(
    productId: productId,
    sku: sku,
    name: name,
    tier: tier,
    wallId: wallId ?? this.wallId,
    offsetMm: offsetMm ?? this.offsetMm,
    widthMm: widthMm,
    heightMm: heightMm,
    depthMm: depthMm,
  );
}

/// A thin panel closing a small gap next to a cabinet.
@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class LayoutFiller {
  @JsonKey(required: true, disallowNullValue: true)
  final String wallId;

  @JsonKey(required: true, disallowNullValue: true)
  final LayoutTier tier;

  @JsonKey(required: true, disallowNullValue: true)
  final int offsetMm;

  @JsonKey(required: true, disallowNullValue: true)
  final int widthMm;

  const LayoutFiller({
    required this.wallId,
    required this.tier,
    required this.offsetMm,
    required this.widthMm,
  });

  factory LayoutFiller.fromJson(Map<String, dynamic> json) =>
      _$LayoutFillerFromJson(json);

  Map<String, dynamic> toJson() => _$LayoutFillerToJson(this);
}

/// One line of the engine's checklist, e.g. "Sink base centred on the window".
@JsonSerializable(checked: true, disallowUnrecognizedKeys: true)
class LayoutCheck {
  @JsonKey(required: true, disallowNullValue: true)
  final String label;

  @JsonKey(required: true, disallowNullValue: true)
  final bool passed;

  const LayoutCheck({required this.label, required this.passed});

  factory LayoutCheck.fromJson(Map<String, dynamic> json) =>
      _$LayoutCheckFromJson(json);

  Map<String, dynamic> toJson() => _$LayoutCheckToJson(this);
}
