import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Read-only label / value line.
///
/// Figma: label DM Sans Medium 16 #000000 on the left, value DM Sans
/// Regular 16 #979797 right-aligned, 12px vertical spacing between rows.
/// Used on: Job Details (Date, Customer Name, Property Address,
/// Phone Number, Email Address).
///
/// Different from [SummaryRow], which is the smaller totals line
/// (Regular 14 #333333 label) on Estimate/Proposal.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.inputLabel),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.placeholder, // Regular 16 #979797
            ),
          ),
        ],
      ),
    );
  }
}

/// Label with a dashed-border text box underneath.
///
/// Figma: label DM Sans Medium 16 #000; box border 1px #ECDDD0, dashes
/// 4 on / 4 off, radius 8, padding 16, text DM Sans Regular 16 #979797.
/// Used on: Job Details ("Projects Notes").
class DashedNotesBox extends StatelessWidget {
  const DashedNotesBox({
    super.key,
    required this.label,
    required this.text,
    this.minHeight = 96,
  });

  final String label;
  final String text;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        CustomPaint(
          painter: _DashedBorderPainter(color: AppColors.border, radius: 8),
          child: Container(
            constraints: BoxConstraints(minHeight: minHeight),
            padding: const EdgeInsets.all(16),
            child: Text(text, style: AppTextStyles.placeholder),
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius})
    : strokeWidth = 1,
      gap = 4,
      dash = 4;

  final Color color;
  final double radius;
  final double dash;
  final double gap;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

    for (final PathMetric metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.dash != dash ||
      old.gap != gap ||
      old.strokeWidth != strokeWidth;
}
