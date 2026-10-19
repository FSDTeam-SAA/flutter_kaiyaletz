import 'package:flutter_riverpod/flutter_riverpod.dart';

final bottomNavCtrlProvider = NotifierProvider<BottomNavCtrl, BottomNavState>(
  BottomNavCtrl.new,
);

class BottomNavState {
  final int currentIndex;
  BottomNavState({this.currentIndex = 0});

  BottomNavState copyWith({int? currentIndex}) =>
      BottomNavState(currentIndex: currentIndex ?? this.currentIndex);
}

class BottomNavCtrl extends Notifier<BottomNavState> {
  @override
  BottomNavState build() => BottomNavState();

  void setIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }
}
