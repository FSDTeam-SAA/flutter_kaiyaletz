import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../model/measure_state.dart';

/// Live AR camera where the user pins points and sees distances in real time.
///
/// The camera, tracking and raycast live in native code (iOS: ARKit view in
/// `ios/Runner/ArMeasureView.swift`; Android: ARCore view in
/// `android/.../ArMeasureView.kt`). This screen embeds that view and talks to
/// it over a per-view MethodChannel (commands) and EventChannel (state).
/// Pops with the pinned [MeasureState] when the user taps Done.
class ArMeasureScreen extends StatefulWidget {
  const ArMeasureScreen({super.key});

  static const viewType = 'kaiyaletz/ar_measure_view';

  @override
  State<ArMeasureScreen> createState() => _ArMeasureScreenState();
}

class _ArMeasureScreenState extends State<ArMeasureScreen> {
  MethodChannel? _commands;
  StreamSubscription<dynamic>? _sub;
  MeasureState _state = const MeasureState();

  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;
  bool get _supported =>
      defaultTargetPlatform == TargetPlatform.iOS || _isAndroid;

  /// Android needs camera permission + ARCore before the view is created.
  /// iOS asks for camera permission by itself when the session starts.
  bool _ready = false;
  String? _blocked;

  @override
  void initState() {
    super.initState();
    if (_isAndroid) {
      _prepareAndroid();
    } else {
      _ready = true;
    }
  }

  Future<void> _prepareAndroid() async {
    String? blocked;
    try {
      final r = await const MethodChannel(
        'kaiyaletz/ar_prepare',
      ).invokeMethod<String>('prepare');
      blocked = switch (r) {
        'ok' => null,
        'denied' =>
          'Camera permission is needed to measure. '
              'Allow it in Settings, or enter the measurements manually.',
        'install' =>
          'Google Play Services for AR is being installed. '
              'Come back and try again when it finishes.',
        _ =>
          'This device does not support camera measuring. '
              'Please enter the measurements manually.',
      };
    } catch (_) {
      blocked =
          'Could not start the camera. Please enter the measurements manually.';
    }
    if (!mounted) return;
    setState(() {
      _blocked = blocked;
      _ready = blocked == null;
    });
  }

  void _onViewCreated(int id) {
    _commands = MethodChannel('kaiyaletz/ar_measure_$id');
    _sub = EventChannel('kaiyaletz/ar_measure_events_$id')
        .receiveBroadcastStream()
        .listen((event) {
          if (!mounted) return;
          setState(() => _state = MeasureState.fromMap(event as Map));
        });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: !_supported
          ? _buildUnsupported(
              context,
              'Camera measuring is not available on this device yet. '
              'Please enter the measurements manually.',
            )
          : _blocked != null
          ? _buildUnsupported(context, _blocked!)
          : !_ready
          ? const Center(child: CircularProgressIndicator())
          : _buildCamera(context),
    );
  }

  Widget _buildUnsupported(BuildContext context, String text) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.maybePop(context),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCamera(BuildContext context) {
    final live = _state.liveDistance;
    final segments = _state.segments;

    return Stack(
      fit: StackFit.expand,
      children: [
        _isAndroid ? _androidView() : _iosView(),
        // Crosshair: green when a tap will pin a point, red otherwise.
        Center(
          child: Icon(
            Icons.add,
            size: 36,
            color: _state.tracking ? Colors.greenAccent : Colors.redAccent,
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.maybePop(context),
                ),
              ),
              if (_state.message != null)
                _chip(_state.message!)
              else if (live != null)
                _chip(formatMeters(live))
              else
                _chip(
                  _state.tracking
                      ? 'Pin the first kitchen corner where wall meets floor'
                      : 'Move the phone slowly to find a surface',
                ),
              const Spacer(),
              if (segments.isNotEmpty)
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      for (var i = 0; i < segments.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _chip(
                            '${i + 1}: ${formatMeters(segments[i])}',
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              _controls(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iosView() => UiKitView(
    viewType: ArMeasureScreen.viewType,
    onPlatformViewCreated: _onViewCreated,
  );

  // Hybrid composition, so the GLSurfaceView camera renders correctly.
  Widget _androidView() => PlatformViewLink(
    viewType: ArMeasureScreen.viewType,
    surfaceFactory: (context, controller) => AndroidViewSurface(
      controller: controller as AndroidViewController,
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
      hitTestBehavior: PlatformViewHitTestBehavior.opaque,
    ),
    onCreatePlatformView: (params) {
      return PlatformViewsService.initExpensiveAndroidView(
          id: params.id,
          viewType: ArMeasureScreen.viewType,
          layoutDirection: TextDirection.ltr,
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () => params.onFocusChanged(true),
        )
        ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
        ..addOnPlatformViewCreatedListener(_onViewCreated)
        ..create();
    },
  );

  Widget _controls() {
    final hasPoints = _state.points.isNotEmpty;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: hasPoints ? () => _commands?.invokeMethod('undo') : null,
          child: const Text('Undo'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
          ),
          onPressed: _state.tracking
              ? () => _commands?.invokeMethod('addPoint')
              : null,
          child: const Text('Pin point'),
        ),
        TextButton(
          onPressed: hasPoints ? () => _commands?.invokeMethod('clear') : null,
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: hasPoints ? () => Navigator.pop(context, _state) : null,
          child: const Text('Done'),
        ),
      ],
    );
  }

  Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
    ),
  );
}
