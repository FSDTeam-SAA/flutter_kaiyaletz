import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_kaiyaletz/core/services/auth_storage_service.dart';
import 'package:flutter_kaiyaletz/core/utils/navigation.dart';
import 'package:flutter_kaiyaletz/features/auth/repo/auth_repo.dart';
import 'package:flutter_kaiyaletz/features/auth/screens/create_new_pass_screen.dart';
import 'package:flutter_kaiyaletz/features/profile/controller/profile_controller.dart';
import 'package:flutter_kaiyaletz/features/profile/repos/user_repo.dart';
import 'package:flutter_kaiyaletz/features/auth/screens/login_screen.dart';
import 'package:flutter_kaiyaletz/features/auth/screens/profile_screen.dart';
import 'package:flutter_kaiyaletz/features/nav/screen/bottom_nav_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_provider.dart';
import '../../../core/utils/app_snackbar.dart';
import '../screens/otp_screen.dart';

final authCtrlProvider =
    NotifierProvider.autoDispose<AuthController, AuthState>(AuthController.new);

class AuthState {
  final bool isLoading;
  final bool rememberMe;
  final String loginErrMsg;
  final String signupErrMsg;
  final String resendOtpErrMsg;
  final String verifyOtpErrMsg;
  final String profileErrMsg;
  final String forgotPassError;
  final String verifyResetOtpError;
  final String resetPassError;
  final String loginButtonText;

  AuthState({
    this.isLoading = false,
    this.rememberMe = false,
    this.loginErrMsg = '',
    this.signupErrMsg = '',
    this.resendOtpErrMsg = '',
    this.verifyOtpErrMsg = '',
    this.profileErrMsg = '',
    this.forgotPassError = '',
    this.verifyResetOtpError = '',
    this.resetPassError = '',
    this.loginButtonText = "Login",
  });

  AuthState copyWith({
    bool? isLoading,
    bool? rememberMe,
    String? loginErrMsg,
    String? signupErrMsg,
    String? resendOtpErrMsg,
    String? verifyOtpErrMsg,
    String? profileErrMsg,
    String? forgotPassError,
    String? verifyResetOtpError,
    String? resetPassError,
    String? loginButtonText,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      rememberMe: rememberMe ?? this.rememberMe,
      loginErrMsg: loginErrMsg ?? this.loginErrMsg,
      signupErrMsg: signupErrMsg ?? this.signupErrMsg,
      resendOtpErrMsg: resendOtpErrMsg ?? this.resendOtpErrMsg,
      verifyOtpErrMsg: verifyOtpErrMsg ?? this.verifyOtpErrMsg,
      profileErrMsg: profileErrMsg ?? this.profileErrMsg,
      forgotPassError: forgotPassError ?? this.forgotPassError,
      verifyResetOtpError: verifyResetOtpError ?? this.verifyResetOtpError,
      resetPassError: resetPassError ?? this.resetPassError,
      loginButtonText: loginButtonText ?? this.loginButtonText,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState();
  }

  /// [Funtion] login with email and pass
  Future<void> login(String email, String password) async {
    final repo = ref.read(authRepoProvider);

    state = state.copyWith(isLoading: true, loginErrMsg: "");

    final result = await repo.login(email: email, password: password);

    await result.fold(
      (f) async {
        state = state.copyWith(isLoading: false, loginErrMsg: f.message);

        if (f.message.contains(
          "Email not verified. Please verify your email first.",
        )) {
          await Future.delayed(const Duration(seconds: 1));

          state = state.copyWith(loginButtonText: "Verify Email");
        }
      },
      (s) async {
        final data = s.data;

        final account = StoredAccount(
          userId: data.id,
          accessToken: data.accessToken,
          refreshToken: data.refreshToken,
          role: data.role,
          firstName: data.firstName,
          lastName: data.lastName,
          profileImage: data.profileImage.url,
          email: data.email,
        );

        await ref.read(authStorageServiceProvider).storeAuthData(account);
        if (state.rememberMe) {
          await ref.read(authStorageServiceProvider).saveAccountToList(account);
        }

        state = state.copyWith(isLoading: false, loginErrMsg: '');

        if (data.fullName.isEmpty) {
          AppNav.to(ProfileScreen());
        } else {
          AppNav.offAll(BottomNavScreen());
        }
      },
    );
  }

  Future<void> logout() async {
    await ref.read(authStorageServiceProvider).clearAuthData();
    AppNav.offAll(LoginScreen());
  }

  /// [Funtion] Signup with email, pass, confirm pass
  Future<void> signup(String email, String pass, String confirmPass) async {
    final repo = ref.read(authRepoProvider);

    state = state.copyWith(isLoading: true, signupErrMsg: "");

    final result = await repo.signup(
      email: email,
      password: pass,
      confirmPassword: confirmPass,
    );

    result.fold(
      (f) {
        state = state.copyWith(isLoading: false, signupErrMsg: f.message);
      },
      (s) {
        AppSnackbar.success(s.message);
        AppNav.to(OtpScreen(email: email));
      },
    );

    state = state.copyWith(isLoading: false);
  }

  /// [Funtion] Resend otp
  Future<void> resendOtp(String email) async {
    final repo = ref.read(authRepoProvider);

    state = state.copyWith(isLoading: true, resendOtpErrMsg: "");

    final result = await repo.resendOtp(email: email);

    result.fold(
      (f) {
        state = state.copyWith(isLoading: false, signupErrMsg: f.message);
      },
      (s) async {
        AppSnackbar.success(s.message);
        await Future.delayed(const Duration(seconds: 1));
        state = state.copyWith(loginErrMsg: '');
        AppNav.to(OtpScreen(email: email));
      },
    );

    state = state.copyWith(isLoading: false, resendOtpErrMsg: "");
  }

  /// [Funtion] Verify otp
  Future<void> verifyOtp(String email, String otp) async {
    final repo = ref.read(authRepoProvider);

    state = state.copyWith(isLoading: true, verifyOtpErrMsg: "");

    final result = await repo.verifyOtp(email: email, otp: otp);

    result.fold(
      (f) {
        state = state.copyWith(isLoading: false, verifyOtpErrMsg: f.message);
      },
      (s) async {
        state = state.copyWith(
          isLoading: false,
          verifyOtpErrMsg: "",
          loginButtonText: "Login",
        );

        final data = s.data;

        final account = StoredAccount(
          userId: data.id,
          accessToken: data.accessToken,
          refreshToken: data.refreshToken,
          role: data.role,
          firstName: data.firstName,
          lastName: data.lastName,
          profileImage: data.profileImage.url,
          email: data.email,
        );

        await ref.read(authStorageServiceProvider).storeAuthData(account);

        AppSnackbar.success(s.message);
        AppNav.offAll(ProfileScreen());
      },
    );
  }

  /// [Funtion] Save profile (full name, contact number, address, avatar)
  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
    required String address,
    File? profileImage,
    bool isEditing = false,
  }) async {
    final repo = ref.read(userRepoProvider);

    state = state.copyWith(isLoading: true, profileErrMsg: "");

    final result = await repo.updateProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      address: address,
      profileImage: profileImage,
    );

    await result.fold(
      (f) async {
        state = state.copyWith(isLoading: false, profileErrMsg: f.message);
      },
      (s) async {
        final nameParts = fullName.trim().split(RegExp(r'\s+'));
        final firstName = nameParts.isNotEmpty ? nameParts.first : '';
        final lastName = nameParts.length > 1
            ? nameParts.sublist(1).join(' ')
            : '';

        await ref
            .read(authStorageServiceProvider)
            .updateBasicInfo(
              firstName: firstName,
              lastName: lastName,
              profileImage: profileImage?.path,
            );

        state = state.copyWith(isLoading: false, profileErrMsg: "");

        if (isEditing) {
          await ref.read(profileProvider.notifier).getUser(forceRefresh: true);
          AppNav.back();
        } else {
          AppNav.offAll(BottomNavScreen());
        }
      },
    );
  }

  /// [State]
  Future<void> rememberMe(bool value) async {
    state = state.copyWith(rememberMe: value);
  }

  /// [Fogot Pass] start
  Future<void> forgotPass({required String email}) async {
    final repo = ref.read(authRepoProvider);

    final result = await repo.forgotPassword(email: email);

    result.fold(
      (f) {
        state = state.copyWith(forgotPassError: f.message);
      },
      (s) async {
        AppSnackbar.success(s.message);

        await Future.delayed(const Duration(milliseconds: 500));

        AppNav.to(OtpScreen(email: email, isFogoteVerify: true));
      },
    );
  }

  Future<void> verifyResetOtp(String email, String otp) async {
    final repo = ref.read(authRepoProvider);

    final result = await repo.verfiyResetOtp(email: email, otp: otp);

    result.fold(
      (f) {
        state = state.copyWith(verifyResetOtpError: f.message);
      },
      (s) async {
        AppNav.to(CreateNewPassScreen(email: email, otp: otp));
      },
    );
  }

  Future<void> resetPass(
    String email,
    String otp,
    String password,
    String confirmPassword,
  ) async {
    final repo = ref.read(authRepoProvider);

    final result = await repo.resetPass(
      email: email,
      otp: otp,
      password: password,
      confirmPassword: confirmPassword,
    );

    result.fold(
      (f) {
        state = state.copyWith(resetPassError: f.message);
      },
      (s) async {
        AppSnackbar.success(s.message);

        await Future.delayed(const Duration(milliseconds: 500));

        AppNav.to(LoginScreen());
      },
    );
  }
}
