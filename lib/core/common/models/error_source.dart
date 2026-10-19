/// One field-level validation error, as returned by a NestJS/Zod-style
/// error response: `{ "path": "email", "message": "Invalid email" }`.
class ErrorSource {
  final String? path;
  final String message;

  const ErrorSource({this.path, required this.message});

  factory ErrorSource.fromJson(Map<String, dynamic> json) {
    return ErrorSource(
      path: json['path']?.toString(),
      message: json['message']?.toString() ?? 'Invalid value',
    );
  }

  Map<String, dynamic> toJson() => {'path': path, 'message': message};
}
