import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../model/room_spec.dart';

const openingColors = {
  OpeningType.window: Color(0xFF3B82B8),
  OpeningType.door: AppColors.primary,
  OpeningType.sink: Color(0xFF14A3A3),
  OpeningType.hob: AppColors.error,
};

/// Top-down sketch of the kitchen walls, with openings in colour.
///
/// Walls are drawn in order: A runs right, B turns down, C turns left. In
/// a galley, B faces A across the aisle and runs left.
class RoomPlanView extends StatelessWidget {
  const RoomPlanView({super.key, required this.room});

  final RoomSpec room;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: CustomPaint(painter: _RoomPlanPainter(room)),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: [
            for (final MapEntry(key: type, value: color)
                in openingColors.entries)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 12, height: 4, color: color),
                  const SizedBox(width: 4),
                  Text(type.label, style: AppTextStyles.caption),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _RoomPlanPainter extends CustomPainter {
  _RoomPlanPainter(this.room);

  final RoomSpec room;

  // Right, down, left: the direction of wall A, B, C.
  static const _cornerDirs = [Offset(1, 0), Offset(0, 1), Offset(-1, 0)];
  static const _galleyDirs = [Offset(1, 0), Offset(-1, 0)];
  // A galley's aisle isn't measured; this only spaces the sketch.
  static const _galleyAisleMm = 1200.0;
  static const _pad = 28.0;

  @override
  void paint(Canvas canvas, Size size) {
    final galley = !room.shape.hasCorners;
    final dirs = galley ? _galleyDirs : _cornerDirs;
    // Wall start and end points in mm.
    final starts = <Offset>[], ends = <Offset>[];
    for (var i = 0; i < room.walls.length; i++) {
      final start = i == 0
          ? Offset.zero
          : galley
          ? Offset(ends[0].dx, _galleyAisleMm)
          : ends[i - 1];
      starts.add(start);
      ends.add(start + dirs[i] * room.walls[i].lengthMm.toDouble());
    }
    final points = [...starts, ...ends];

    final minX = points.map((p) => p.dx).reduce(min);
    final maxX = points.map((p) => p.dx).reduce(max);
    final minY = points.map((p) => p.dy).reduce(min);
    final maxY = points.map((p) => p.dy).reduce(max);
    final spanX = max(maxX - minX, 1.0);
    final spanY = max(maxY - minY, 1.0);
    final scale = min(
      (size.width - _pad * 2) / spanX,
      (size.height - _pad * 2) / spanY,
    );
    // Centre the drawing.
    final origin = Offset(
      (size.width - spanX * scale) / 2 - minX * scale,
      (size.height - spanY * scale) / 2 - minY * scale,
    );
    Offset toPx(Offset mm) => origin + mm * scale;

    final wallPaint = Paint()
      ..color = AppColors.textDark
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square;
    final openingPaint = Paint()..strokeWidth = 7;

    for (var i = 0; i < room.walls.length; i++) {
      final wall = room.walls[i];
      final a = starts[i], b = ends[i], dir = dirs[i];
      canvas.drawLine(toPx(a), toPx(b), wallPaint);

      for (final o in wall.openings) {
        openingPaint.color = openingColors[o.type]!;
        canvas.drawLine(
          toPx(a + dir * o.offsetMm.toDouble()),
          toPx(a + dir * (o.offsetMm + o.widthMm).toDouble()),
          openingPaint,
        );
      }

      // Label outside the room: above A, right of B, below C.
      final normal = Offset(dir.dy, -dir.dx);
      final mid = toPx((a + b) / 2) + normal * 14;
      _label(canvas, mid, '${String.fromCharCode(65 + i)} · ${wall.lengthMm}');
    }
  }

  void _label(Canvas canvas, Offset centre, String text) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTextStyles.caption),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, centre - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_RoomPlanPainter old) => old.room != room;
}
