import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../model/measure_state.dart';
import '../model/room_scan.dart';
import '../model/room_spec.dart';

/// Whether the LiDAR room scan can run on this device.
final roomScanSupportedProvider = FutureProvider<bool>(
  (ref) => RoomScanScreen.isSupported(),
);

/// LiDAR room scan with Apple RoomPlan. Walls, doors, windows, sinks and
/// stoves are found automatically and drawn in colour; the user taps the
/// kitchen walls in order (A, B, C) and Done.
///
/// The camera and RoomPlan live in `ios/Runner/RoomScanView.swift`. Pops
/// with a [RoomScanResult], or null when cancelled. Only open it when
/// [isSupported] is true.
class RoomScanScreen extends StatefulWidget {
  const RoomScanScreen({super.key});

  static const viewType = 'kaiyaletz/room_scan_view';

  static bool? _supported;

  /// Whether this device can run RoomPlan (iOS 16+ with LiDAR).
  static Future<bool> isSupported() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return false;
    try {
      return _supported ??=
          await const MethodChannel(
            'kaiyaletz/room_scan',
          ).invokeMethod<bool>('isSupported') ??
          false;
    } catch (_) {
      return false;
    }
  }

  @override
  State<RoomScanScreen> createState() => _RoomScanScreenState();
}

class _RoomScanScreenState extends State<RoomScanScreen> {
  MethodChannel? _commands;
  StreamSubscription<dynamic>? _sub;
  RoomScan _scan = const RoomScan();
  String? _error;
  final _picked = <String>[];
  bool _finishing = false;

  static const _legend = [
    ('Wall', Colors.blue),
    ('Kitchen wall', AppColors.primary),
    ('Door', Colors.yellow),
    ('Window', Colors.cyan),
    ('Sink', Colors.green),
    ('Hob', Colors.red),
  ];

  void _onViewCreated(int id) {
    _commands = MethodChannel('kaiyaletz/room_scan_$id');
    _sub = EventChannel('kaiyaletz/room_scan_events_$id')
        .receiveBroadcastStream()
        .listen((event) {
          if (!mounted) return;
          final map = event as Map;
          setState(() {
            if (map['message'] case final String message) {
              _error = message;
            } else {
              _scan = RoomScan.fromMap(map);
              // Drop picks for walls RoomPlan merged away.
              final ids = {for (final w in _scan.walls) w.id};
              if (_picked.any((id) => !ids.contains(id))) {
                _picked.removeWhere((id) => !ids.contains(id));
                _sendSelection();
              }
            }
          });
        });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _toggle(String id) {
    setState(() {
      if (!_picked.remove(id) && _picked.length < 3) _picked.add(id);
    });
    _sendSelection();
  }

  void _sendSelection() =>
      _commands?.invokeMethod('setSelection', List<String>.of(_picked));

  Future<void> _finish() async {
    setState(() => _finishing = true);
    final live = _scan;
    var result = live;
    var ids = List<String>.of(_picked);
    try {
      final map = await _commands?.invokeMethod<Map>('finish');
      if (map != null) {
        final built = RoomScan.fromMap(map);
        final matched = built.matchWalls(live, ids);
        // Keep the live camera position if the final room has none.
        if (matched != null) {
          result = RoomScan(
            walls: built.walls,
            items: built.items,
            camera: built.camera ?? live.camera,
          );
          ids = matched;
        }
      }
    } on PlatformException {
      // The final pass failed; the live scan is still usable.
    }
    if (!mounted) return;
    // Done needs a pick, and picks always name a live wall.
    Navigator.pop(context, result.toRoomSpec(ids));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          UiKitView(
            viewType: RoomScanScreen.viewType,
            onPlatformViewCreated: _onViewCreated,
          ),
          SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        _commands?.invokeMethod('cancel');
                        Navigator.maybePop(context);
                      },
                    ),
                    Expanded(child: _legendRow()),
                  ],
                ),
                _chip(_hint()),
                const Spacer(),
                if (_scan.walls.isNotEmpty) _wallChips(),
                const SizedBox(height: 8),
                Text(
                  'Scans are estimates. Verify on site before ordering.',
                  style: AppTextStyles.caption.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 14,
                    ),
                  ),
                  onPressed: _picked.isEmpty || _finishing || _error != null
                      ? null
                      : _finish,
                  child: _finishing
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Done · ${_shapeLabel()}'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _hint() {
    if (_error case final error?) return error;
    if (_finishing) return 'Finishing the scan…';
    if (_scan.instruction case final i?) {
      return switch (i) {
        'moveCloseToWall' => 'Move closer to the wall',
        'moveAwayFromWall' => 'Move further from the wall',
        'slowDown' => 'Slow down',
        'turnOnLight' => 'Turn on more light',
        'lowTexture' => 'Not enough detail here. Aim at another area',
        _ => 'Keep scanning',
      };
    }
    if (_scan.walls.isEmpty) return 'Point at the walls and walk slowly around';
    if (_picked.isEmpty) {
      return 'Scan the whole kitchen, then tap its walls left to right';
    }
    return 'Tap a wall again to remove it';
  }

  /// What Done will produce, e.g. "L-shape".
  String _shapeLabel() => switch (_picked.length) {
    0 => 'pick walls',
    1 => RoomShape.straight.label,
    3 => RoomShape.u.label,
    _ => '${RoomShape.l.label} or galley',
  };

  Widget _wallChips() => SizedBox(
    height: 40,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        for (final wall in _scan.walls)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _wallChip(wall),
          ),
      ],
    ),
  );

  Widget _wallChip(ScanWall wall) {
    final pick = _picked.indexOf(wall.id);
    final length = formatMeters(wall.lengthM).split('  ').first;
    final picked = pick >= 0;
    return ActionChip(
      onPressed: _finishing ? null : () => _toggle(wall.id),
      backgroundColor: picked ? AppColors.primary : Colors.black54,
      side: BorderSide(color: picked ? AppColors.primary : Colors.white38),
      label: Text(
        picked ? '${String.fromCharCode(65 + pick)} · $length' : length,
        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
      ),
      avatar: wall.confidence == ScanConfidence.low
          ? const Icon(Icons.warning_amber, size: 16, color: Colors.amber)
          : null,
    );
  }

  Widget _legendRow() => Wrap(
    spacing: 10,
    runSpacing: 4,
    children: [
      for (final (label, color) in _legend)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: Colors.white),
            ),
          ],
        ),
    ],
  );

  Widget _chip(String text) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
    ),
  );
}
