import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../measure/model/room_spec.dart';
import '../../measure/widgets/room_plan_view.dart';
import '../models/layout_model.dart';

// Drawing assumptions, in mm. The layout only stores horizontal positions.
const _wallUnitBottomMm = 1450; // underside of hung units above the worktop
const _worktopMm = 900;
// Used when a door or window has no measured height.
const _doorHeightMm = 2040;
const _windowHeightMm = 1100;

const _pad = 16.0;
const _header = 22.0;

/// Front view of one wall with its cabinets. Tap a cabinet to select it.
class WallElevation extends StatelessWidget {
  const WallElevation({
    super.key,
    required this.room,
    required this.layout,
    required this.wallIndex,
    this.selected,
    this.onTapItem,
  });

  final RoomSpec room;
  final JobLayout layout;
  final int wallIndex;

  /// Index into [JobLayout.items].
  final int? selected;

  /// Called with the tapped item's index, or null for empty space.
  final ValueChanged<int?>? onTapItem;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.maxWidth,
          _heightFor(constraints.maxWidth, room, wallIndex, maxHeight: 300),
        );
        final painter = ElevationPainter(
          room: room,
          layout: layout,
          wallIndex: wallIndex,
          selected: selected,
        );
        return GestureDetector(
          onTapUp: onTapItem == null
              ? null
              : (d) => onTapItem!(painter.itemAt(size, d.localPosition)),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: CustomPaint(size: size, painter: painter),
          ),
        );
      },
    );
  }
}

double _heightFor(
  double width,
  RoomSpec room,
  int wallIndex, {
  required double maxHeight,
}) {
  final wall = room.walls[wallIndex];
  final scale = (width - _pad * 2) / wall.lengthMm;
  final ceiling = wall.highestCeilingMm(room.ceilingHeightMm);
  return min(ceiling * scale + _pad + _header, maxHeight);
}

/// mm → px for one wall drawn into [size]: floor at the bottom, centred.
class _Geo {
  factory _Geo(Size size, int lengthMm, int ceilingMm) {
    final scale = min(
      (size.width - _pad * 2) / lengthMm,
      (size.height - _pad - _header) / ceilingMm,
    );
    return _Geo._(
      scale,
      size.height - _pad,
      (size.width - lengthMm * scale) / 2,
    );
  }

  const _Geo._(this.scale, this.floorY, this.left);

  final double scale;
  final double floorY;
  final double left;

  double x(num mm) => left + mm * scale;
  double y(num mm) => floorY - mm * scale;

  /// [x0]/[w] along the wall, [y0]/[h] up from the floor.
  Rect rect(num x0, num w, num y0, num h) =>
      Rect.fromLTRB(x(x0), y(y0 + h), x(x0 + w), y(y0));
}

class ElevationPainter extends CustomPainter {
  ElevationPainter({
    required this.room,
    required this.layout,
    required this.wallIndex,
    this.selected,
  });

  final RoomSpec room;
  final JobLayout layout;
  final int wallIndex;
  final int? selected;

  RoomWall get _wall => room.walls[wallIndex];

  /// Ceiling at the wall's left and right ends.
  int get _ceilingStartMm => _wall.heightMm ?? room.ceilingHeightMm;
  int get _ceilingEndMm => _wall.heightEndMm ?? _ceilingStartMm;

  /// Taller end of the wall; the drawing is scaled to fit it.
  int get _drawHeightMm => max(_ceilingStartMm, _ceilingEndMm);

  /// Bottom and height of an item, in mm from the floor.
  (int, int) _band(LayoutItem i) {
    final ceiling = room.lowestCeilingMm(wallIndex);
    return switch (i.tier) {
      .wall => (min(_wallUnitBottomMm, ceiling - i.heightMm), i.heightMm),
      _ => (0, min(i.heightMm, ceiling)),
    };
  }

  Iterable<int> get _indexes sync* {
    for (var n = 0; n < layout.items.length; n++) {
      if (layout.items[n].wallId == _wall.id) yield n;
    }
  }

  /// Index of the item under [point], hung units checked first.
  int? itemAt(Size size, Offset point) {
    final geo = _Geo(size, _wall.lengthMm, _drawHeightMm);
    final ordered = _indexes.toList()
      ..sort(
        (a, b) => (layout.items[a].tier == .wall ? 0 : 1).compareTo(
          layout.items[b].tier == .wall ? 0 : 1,
        ),
      );
    for (final n in ordered) {
      final item = layout.items[n];
      final (bottom, height) = _band(item);
      if (geo
          .rect(item.offsetMm, item.widthMm, bottom, height)
          .contains(point)) {
        return n;
      }
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final geo = _Geo(size, _wall.lengthMm, _drawHeightMm);
    final line = Paint()
      ..color = AppColors.textDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    _text(
      canvas,
      Offset(_pad, 4),
      '${wallName(wallIndex)} · ${_wall.lengthMm} mm',
      AppTextStyles.caption,
    );

    // Room outline: floor, wall ends, ceiling (sloped if measured so).
    canvas.drawPath(
      Path()
        ..moveTo(geo.x(0), geo.y(0))
        ..lineTo(geo.x(0), geo.y(_ceilingStartMm))
        ..lineTo(geo.x(_wall.lengthMm), geo.y(_ceilingEndMm))
        ..lineTo(geo.x(_wall.lengthMm), geo.y(0))
        ..close(),
      line..color = AppColors.borderCard,
    );

    // Openings behind the cabinets.
    for (final o in _wall.openings) {
      final color = openingColors[o.type]!;
      final paint = Paint()..color = color.withValues(alpha: 0.18);
      final outline = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      switch (o.type) {
        case .window:
          final sill = o.sillMm ?? _worktopMm;
          final h =
              o.heightMm ??
              min(
                _windowHeightMm,
                room.lowestCeilingMm(wallIndex) - sill - 100,
              );
          final r = geo.rect(o.offsetMm, o.widthMm, sill, max(h, 100));
          canvas.drawRect(r, paint);
          canvas.drawRect(r, outline);
        case .door:
          final r = geo.rect(
            o.offsetMm,
            o.widthMm,
            0,
            o.heightMm ??
                min(_doorHeightMm, room.lowestCeilingMm(wallIndex) - 50),
          );
          // Outline plus a swing mark, so it doesn't read as a cabinet.
          canvas.drawRect(r, outline);
          canvas.drawPath(
            Path()
              ..moveTo(r.left, r.top)
              ..lineTo(r.right, r.center.dy)
              ..lineTo(r.left, r.bottom),
            outline..strokeWidth = 1,
          );
        case .sink || .hob:
          // A bar on the worktop line marks the service point.
          canvas.drawRect(
            geo.rect(o.offsetMm, o.widthMm, _worktopMm, 40),
            Paint()..color = color,
          );
      }
    }

    for (final f in layout.fillers.where((f) => f.wallId == _wall.id)) {
      final (bottom, height) = f.tier == .wall
          ? (_wallUnitBottomMm, 720)
          : (0, _worktopMm - 30);
      canvas.drawRect(
        geo.rect(f.offsetMm, f.widthMm, bottom, height),
        Paint()..color = AppColors.progressEmpty,
      );
    }

    for (final n in _indexes) {
      final item = layout.items[n];
      final isSelected = n == selected;
      final (bottom, height) = _band(item);
      final r = geo.rect(item.offsetMm, item.widthMm, bottom, height);

      canvas.drawRect(
        r,
        Paint()
          ..color = isSelected
              ? AppColors.brown300
              : item.tier == .wall
              ? AppColors.brown50
              : AppColors.brown100,
      );
      canvas.drawRect(
        r,
        Paint()
          ..color = isSelected ? AppColors.primaryDark : AppColors.brown700
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 2 : 1,
      );
      _textIn(canvas, r, '${item.sku}\n${item.widthMm}');
    }

    // Floor line on top of everything.
    canvas.drawLine(
      Offset(geo.x(0), geo.y(0)),
      Offset(geo.x(_wall.lengthMm), geo.y(0)),
      Paint()
        ..color = AppColors.textDark
        ..strokeWidth = 2,
    );
  }

  void _text(Canvas canvas, Offset at, String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at);
  }

  /// Centred label, skipped when the cabinet is too narrow for it.
  void _textIn(Canvas canvas, Rect r, String text) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTextStyles.caption.copyWith(fontSize: 8, height: 1.2),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    if (tp.width > r.width - 2 || tp.height > r.height - 2) return;
    tp.paint(canvas, r.center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(ElevationPainter old) =>
      old.layout != layout ||
      old.room != room ||
      old.selected != selected ||
      old.wallIndex != wallIndex;
}

/// Every wall's elevation stacked into one PNG, for the proposal.
/// Drawn off-screen, so it needs no widget on screen.
Future<Uint8List> renderElevationPng(
  RoomSpec room,
  JobLayout layout, {
  double width = 1200,
}) async {
  // Text and lines are sized for phone screens; scale them up together.
  const pixelRatio = 2.0;
  final logicalWidth = width / pixelRatio;
  final heights = [
    for (var w = 0; w < room.walls.length; w++)
      _heightFor(logicalWidth, room, w, maxHeight: 360),
  ];
  final totalHeight = heights.fold(0.0, (a, b) => a + b);

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(pixelRatio);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, logicalWidth, totalHeight),
    Paint()..color = Colors.white,
  );

  var top = 0.0;
  for (var w = 0; w < room.walls.length; w++) {
    canvas.save();
    canvas.translate(0, top);
    ElevationPainter(
      room: room,
      layout: layout,
      wallIndex: w,
    ).paint(canvas, Size(logicalWidth, heights[w]));
    canvas.restore();
    top += heights[w];
  }

  final image = await recorder.endRecording().toImage(
    width.round(),
    (totalHeight * pixelRatio).round(),
  );
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return bytes!.buffer.asUint8List();
}
