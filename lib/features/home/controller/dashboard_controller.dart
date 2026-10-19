import 'package:flutter_kaiyaletz/features/home/models/dashboard_response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repo/dashboard_repo.dart';

final dashboardProvider =
    NotifierProvider.autoDispose<DashboardController, DashboardState>(
      DashboardController.new,
    );

class DashboardState {
  final DashboardResponseModel? dashboard;
  final bool isLoading;

  DashboardState({this.dashboard, this.isLoading = false});

  DashboardState copyWith({
    DashboardResponseModel? dashboard,
    bool? isLoading,
  }) {
    return DashboardState(
      dashboard: dashboard ?? this.dashboard,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class DashboardController extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    Future.microtask(getDashboard);
    return DashboardState();
  }

  Future<void> getDashboard() async {
    final repo = ref.read(dashboardRepo);

    state = state.copyWith(isLoading: true);

    final result = await repo.dashboard();

    result.fold(
      (f) {
        state = state.copyWith(isLoading: false);
      },
      (s) {
        state = state.copyWith(dashboard: s.data, isLoading: false);
      },
    );
  }
}
