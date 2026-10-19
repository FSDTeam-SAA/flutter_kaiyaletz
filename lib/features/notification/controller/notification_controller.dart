import 'package:flutter_kaiyaletz/features/auth/model/login_response_model.dart';
import 'package:flutter_kaiyaletz/features/notification/repos/notification_repo.dart';
import 'package:flutter_kaiyaletz/features/profile/controller/profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationProvider =
    NotifierProvider.autoDispose<NotificationController, NotificationState>(
      NotificationController.new,
    );

class NotificationState {
  final bool isLoading;
  final Map<String, bool> values;
  NotificationState({
    this.isLoading = false,
    this.values = const {
      'Push Notifications': false,
      'Loan Notifications': false,
      'Transaction Notifications': false,
      'Fund Notifications': false,
      'Support Notifications': false,
    },
  });

  NotificationState copyWith({
    final bool? isLoading,
    final Map<String, bool>? values,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      values: values ?? this.values,
    );
  }
}

Map<String, bool> _valueFromNotifications(Notifications n) => {
  'Push Notifications': n.push,
  'Loan Notifications': n.loan,
  'Transaction Notifications': n.transaction,
  'Fund Notifications': n.fund,
  'Support Notifications': n.support,
};

class NotificationController extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    final profile = ref.watch(profileProvider).user;
    if (profile != null) {
      return NotificationState(
        values: _valueFromNotifications(profile.notifications),
      );
    }
    return NotificationState();
  }

  Future<void> toggleChange(String key, bool value) async {
    final updated = {...state.values, key: value};
    state = state.copyWith(isLoading: true);

    final repo = ref.read(notificationRepo);

    final result = await repo.updateNotifications(updated);

    result.fold(
      (f) {
        state = state.copyWith(isLoading: false);
      },
      (s) {
        state = state.copyWith(values: updated, isLoading: false);
      },
    );
  }
}
