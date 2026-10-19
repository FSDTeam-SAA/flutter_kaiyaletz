class AppAssets {
  AppAssets._();
  static Images get img => Images();
  static Icons get icons => Icons();
}

class Images {
  const Images();

  static const String _base = 'assets/img';
  final String logo = '$_base/app_logo.png';
  final String illustration = '$_base/illustration.png';
}

class Icons {
  const Icons();

  static const String _base = 'assets/icons/';
  final String back = '${_base}back-icon.svg';

  /// [Screen] Setting
  ///
  final String edit = '${_base}edit.svg';
  final String general = '${_base}general.svg';
  final String notification = '${_base}notification.svg';
  final String email = '${_base}email.svg';

  /// [Screen] General Setting
  ///
  final String password = '${_base}formkit_password.svg';
  final String delete = '${_base}light_delete-outline.svg';
}
