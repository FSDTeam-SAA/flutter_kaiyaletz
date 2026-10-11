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
