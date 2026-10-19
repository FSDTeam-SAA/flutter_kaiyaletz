import 'package:flutter_kaiyaletz/core/utils/app_snackbar.dart';
import 'package:flutter_kaiyaletz/core/utils/navigation.dart';
import 'package:flutter_kaiyaletz/features/support/repos/support_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final supportProvider = NotifierProvider<SupportController, SupportState>(
  SupportController.new,
);

class SupportState {
  final String submitContactUsError;
  SupportState({this.submitContactUsError = ''});

  SupportState copyWith({final String? submitContactUsError}) {
    return SupportState(
      submitContactUsError: submitContactUsError ?? this.submitContactUsError,
    );
  }
}

class SupportController extends Notifier<SupportState> {
  @override
  SupportState build() {
    return SupportState();
  }

  Future<void> submitContactUs({
    required String fullName,
    required String email,
    required String contactNumber,
    required String note,
  }) async {
    final repo = ref.read(supportRepo);

    final result = await repo.submitContactUs(
      fullName: fullName,
      email: email,
      contactNumber: contactNumber,
      note: note,
    );

    result.fold(
      (f) {
        state = state.copyWith(submitContactUsError: f.message);
      },
      (s) {
        AppSnackbar.success(s.message);
        AppNav.back();
      },
    );
  }
}
