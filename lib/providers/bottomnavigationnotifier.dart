import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../models/bottomnavigationstate.dart';

class BottemNavigation extends StateNotifier<BottomNavigationState> {
  BottemNavigation() : super(BottomNavigationState());
  void update(int index) {
    int previousIndex = state.selectedIndex;
    String newTitle;

    switch (index) {
      case 0:
        newTitle = 'Home';
        break;
      case 1:
        newTitle = 'Bookings';
        break;
      case 2:
        newTitle = 'Horoscope';
        break;
      default:
        newTitle = state.appBarTitle;
    }

    state = state.copyWith(
      appBarTitle: newTitle,
      selectedIndex: index,
      previousIndex: previousIndex,
    );
  }
}

final bottemNavigationProvider =
    StateNotifierProvider<BottemNavigation, BottomNavigationState>(
        (ref) => BottemNavigation());
