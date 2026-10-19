/// Endpoint paths. Replace `baseDomain` with your real API base URL and
/// add sections the same way `auth` is structured, one class per resource.
class ApiConstants {
  ApiConstants._();

  // static const String baseDomain = 'http://187.77.187.56:5001'; // [OV]
  static const String baseDomain = 'http://192.168.10.143:5001'; // [Home]

  static const String baseUrl = '$baseDomain/api/v1';

  /// Dynamically generated WebSocket URL based on baseDomain
  static String get webSocketUrl {
    if (baseDomain.startsWith('https://')) {
      return baseDomain.replaceFirst('https://', 'wss://');
    } else if (baseDomain.startsWith('http://')) {
      return baseDomain.replaceFirst('http://', 'ws://');
    }
    // Fallback for unexpected cases (e.g., no scheme)
    return 'ws://$baseDomain';
  }

  /// [Headers]
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };

  static Map<String, String> get multipartHeaders => {
    'Accept': 'application/json',
    // Content-Type will be set automatically for multipart
  };

  static const AuthEndpoints auth = AuthEndpoints();
  static const UserEndpoints user = UserEndpoints();
  static const SupportEndpoints support = SupportEndpoints();
  static const JobEndpoints job = JobEndpoints();
  static const CatalogEndpoint catalog = CatalogEndpoint();
}

class AuthEndpoints {
  const AuthEndpoints();

  static const String _base = '/auth/';

  String get login => '${_base}login';
  String get register => '${_base}register';
  String get resendOtp => '${_base}resend-otp';
  String get verifyEmail => '${_base}verify-email';
  String get forgotPassword => '${_base}forgot-password';
  String get verifyResetOtp => '${_base}verify-reset-otp';
  String get resetPassword => '${_base}reset-password';

  String get refreshToken => '${_base}refresh-token';
}

class UserEndpoints {
  const UserEndpoints();

  static const String _base = '/user/';

  String get profile => '${_base}profile';
  String get delete => '${_base}delete-account';
  String get changePass => '${_base}change-password';
  String get notification => '${_base}notifications';
}

class SupportEndpoints {
  const SupportEndpoints();

  static const String _base = '/support/';

  String get contactUs => _base;
}

class JobEndpoints {
  const JobEndpoints();

  static const String _base = '/jobs/';

  String get job => _base;
  String get dashboard => "${_base}dashboard";

  String jobById(String id) => '$_base$id';

  String get addProductToJob => "${_base}add-product";

  String saveRoomCapture(String id) => "$_base$id/room-capture";
  String saveMeasurements(String id) => "$_base$id/measurements";
  String saveSelectedProducts(String id) => "$_base$id/products";
  String generateAILayout(String id) => "$_base$id/ai-layout";
  String saveDesign(String id) => "$_base$id/design";
  String saveEstimate(String id) => "$_base$id/estimate";
  String generateProposal(String id) => "$_base$id/proposal";
  String proposalPdf(String id) => "$_base$id/proposal/pdf";
}

class CatalogEndpoint {
  const CatalogEndpoint();

  static const String _base = '/products/';

  String get catalogs => _base;
}
