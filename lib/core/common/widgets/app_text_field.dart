import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Labeled text input.
///
/// Figma: label DM Sans Medium 16 #000 → 8px gap → field h51,
/// border 1px #ECDDD0 (focused #C29266), radius 8, padding 16,
/// placeholder DM Sans Regular 16 #979797.
/// Used on: Login Screen, Forgot Password, Create Account, Profile Setup,
/// Create Job, Job Details, Measurements (3 small fields in a row → use
/// [width]), Continue to Room Captured, Estimate ("Installation Charge",
/// "Delivery Charge"), Edit Profile, Change Password, Contact us.
///
/// The validation error renders as a plain flush-left [Text] below the
/// field (via a [FormField] wrapper) instead of [InputDecoration.errorText],
/// which Flutter always indents to match the input's content padding.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.autofillHints,
    this.width,
    this.contentPadding,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Hides the text and shows the eye toggle.
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  /// Use > 1 for multiline fields ("Design preferences", Contact us "Note").
  final int maxLines;
  final int? minLines;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Useful with [readOnly] for date pickers ("--/--/--").
  final VoidCallback? onTap;
  final bool enabled;
  final bool readOnly;
  final Widget? prefixIcon;

  /// Ignored when [isPassword] is true (the eye toggle is used instead).
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;

  /// Fixed width. Leave null to fill the available width.
  final double? width;

  /// Measurements' small fields use EdgeInsets.all(10) in the design.
  final EdgeInsetsGeometry? contentPadding;

  final AutovalidateMode? autovalidateMode;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.isPassword;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color),
  );

  @override
  Widget build(BuildContext context) {
    final multiline = !widget.isPassword && widget.maxLines > 1;

    final suffix = widget.isPassword
        ? InkResponse(
            onTap: () => setState(() => _obscure = !_obscure),
            radius: 20,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, left: 8),
              child: Icon(
                _obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: AppColors.textPlaceholder,
              ),
            ),
          )
        : widget.suffixIcon;

    final field = FormField<String>(
      initialValue: widget.controller?.text ?? '',
      validator: widget.validator,
      autovalidateMode:
          widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
      builder: (state) {
        final hasError = state.hasError;

        return Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              obscureText: _obscure,
              obscuringCharacter: '*',
              keyboardType: widget.isPassword
                  ? .visiblePassword
                  : (widget.keyboardType ??
                        (multiline
                            ? .multiline
                            : .text)),
              textInputAction: widget.textInputAction,
              maxLines: widget.isPassword ? 1 : widget.maxLines,
              minLines: widget.minLines,
              onChanged: (value) {
                state.didChange(value);
                widget.onChanged?.call(value);
              },
              onSubmitted: widget.onSubmitted,
              onTap: widget.onTap,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              inputFormatters: widget.inputFormatters,
              autofillHints: widget.autofillHints,
              cursorColor: AppColors.primary,
              style: AppTextStyles.placeholder.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.hint,
                hintStyle: AppTextStyles.placeholder,
                contentPadding:
                    widget.contentPadding ?? const EdgeInsets.all(16),
                prefixIcon: widget.prefixIcon,
                suffixIcon: suffix,
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                enabledBorder: _border(
                  hasError ? AppColors.danger : AppColors.border,
                ),
                disabledBorder: _border(AppColors.border),
                focusedBorder: _border(
                  hasError ? AppColors.danger : AppColors.borderFocus,
                ),
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: 6),
              Text(
                state.errorText!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.danger,
                ),
              ),
            ],
          ],
        );
      },
    );

    final content = Column(
      mainAxisSize: .min,
      crossAxisAlignment: .stretch,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: AppTextStyles.inputLabel),
          const SizedBox(height: 8),
        ],
        field,
      ],
    );

    return widget.width == null
        ? content
        : SizedBox(width: widget.width, child: content);
  }
}
