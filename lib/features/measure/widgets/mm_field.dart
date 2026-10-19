import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/common/widgets/app_text_field.dart';

/// Whole-millimetre input. Reports only parsable values, and follows
/// [value] when it changes from outside (e.g. a new scan or shape).
class MmField extends StatefulWidget {
  const MmField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<MmField> createState() => _MmFieldState();
}

class _MmFieldState extends State<MmField> {
  late final _controller = TextEditingController(text: '${widget.value}');

  @override
  void didUpdateWidget(MmField old) {
    super.didUpdateWidget(old);
    if (int.tryParse(_controller.text) != widget.value) {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      controller: _controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (text) {
        final mm = int.tryParse(text);
        if (mm != null) widget.onChanged(mm);
      },
    );
  }
}

/// Whole-millimetre input that may be left empty (reported as null), for
/// values that fall back to something else, named in [hint].
class OptionalMmField extends StatefulWidget {
  const OptionalMmField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final int? value;
  final String? hint;
  final ValueChanged<int?> onChanged;

  @override
  State<OptionalMmField> createState() => _OptionalMmFieldState();
}

class _OptionalMmFieldState extends State<OptionalMmField> {
  late final _controller = TextEditingController(text: _text(widget.value));

  static String _text(int? mm) => mm == null ? '' : '$mm';

  @override
  void didUpdateWidget(OptionalMmField old) {
    super.didUpdateWidget(old);
    if (int.tryParse(_controller.text) != widget.value) {
      _controller.text = _text(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hint: widget.hint,
      controller: _controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (text) {
        if (text.isEmpty) return widget.onChanged(null);
        final mm = int.tryParse(text);
        if (mm != null) widget.onChanged(mm);
      },
    );
  }
}

/// Angle input in degrees, one decimal place.
class DegreesField extends StatefulWidget {
  const DegreesField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<DegreesField> createState() => _DegreesFieldState();
}

class _DegreesFieldState extends State<DegreesField> {
  late final _controller = TextEditingController(text: _text(widget.value));

  // 90.0 → "90", 92.5 → "92.5".
  static String _text(double deg) =>
      deg == deg.roundToDouble() ? '${deg.round()}' : deg.toStringAsFixed(1);

  @override
  void didUpdateWidget(DegreesField old) {
    super.didUpdateWidget(old);
    if (double.tryParse(_controller.text) != widget.value) {
      _controller.text = _text(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d?)?')),
      ],
      onChanged: (text) {
        final deg = double.tryParse(text);
        if (deg != null) widget.onChanged(deg);
      },
    );
  }
}
