import 'dart:math';

/// A pinned point in AR world space, in meters.
class MeasurePoint {
  const MeasurePoint(this.x, this.y, this.z);

  final double x, y, z;

  factory MeasurePoint.fromList(List<dynamic> v) => MeasurePoint(
    (v[0] as num).toDouble(),
    (v[1] as num).toDouble(),
    (v[2] as num).toDouble(),
  );

  Map<String, double> toJson() => {'x': x, 'y': y, 'z': z};
}

/// Snapshot streamed from the native AR view.
class MeasureState {
  const MeasureState({
    this.points = const [],
    this.liveDistance,
    this.tracking = false,
    this.lidar = false,
    this.message,
  });

  final List<MeasurePoint> points;

  /// Meters from the last pinned point to the crosshair, or null when there
  /// is no pinned point yet or no surface under the crosshair.
  final double? liveDistance;

  /// True when the crosshair is on a detected surface (a tap will pin).
  final bool tracking;
  final bool lidar;

  /// Native-side error, e.g. AR not supported on this device.
  final String? message;

  factory MeasureState.fromMap(Map<dynamic, dynamic> m) => MeasureState(
    points: [
      for (final p in (m['points'] as List? ?? const []))
        MeasurePoint.fromList(p as List),
    ],
    liveDistance: (m['live'] as num?)?.toDouble(),
    tracking: m['tracking'] as bool? ?? false,
    lidar: m['lidar'] as bool? ?? false,
    message: m['message'] as String?,
  );

  /// Lengths between consecutive pinned points, in meters.
  List<double> get segments => [
    for (var i = 1; i < points.length; i++) _dist(points[i - 1], points[i]),
  ];

  static double _dist(MeasurePoint a, MeasurePoint b) {
    final dx = b.x - a.x, dy = b.y - a.y, dz = b.z - a.z;
    return sqrt(dx * dx + dy * dy + dz * dz);
  }
}

/// "3.42 m  (11′ 2.6″)"
String formatMeters(double m) {
  final totalIn = m * 39.3701;
  final feet = totalIn ~/ 12;
  final inches = totalIn - feet * 12;
  return '${m.toStringAsFixed(2)} m  ($feet′ ${inches.toStringAsFixed(1)}″)';
}
