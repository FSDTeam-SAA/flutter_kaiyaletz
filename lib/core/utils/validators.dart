/// Shared [AppTextField.validator] functions, so the same email/password/
/// required-field rules aren't rewritten (with slightly different wording)
/// on every form screen.
class Validators {
  Validators._();

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  /// Non-empty check for plain text fields (name, phone, notes, ...).
  static String? required(
    String? value, {
    String message = 'This field is required',
  }) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(
    String? value, {
    String requiredMessage = 'Please enter your email',
    String invalidMessage = 'Please enter a valid email',
  }) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return requiredMessage;
    if (!_emailRegex.hasMatch(email)) return invalidMessage;
    return null;
  }

  static String? password(
    String? value, {
    int minLength = 6,
    String requiredMessage = 'Please enter your password',
    String? shortMessage,
  }) {
    if (value == null || value.trim().isEmpty) return requiredMessage;
    if (value.trim().length < minLength) {
      return shortMessage ?? 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// [original] is the password this confirm field must match.
  static String? confirmPassword(
    String? value,
    String original, {
    String requiredMessage = 'Please confirm your password',
    String mismatchMessage = 'Passwords do not match',
  }) {
    if (value == null || value.trim().isEmpty) return requiredMessage;
    if (value.trim() != original.trim()) return mismatchMessage;
    return null;
  }
}
