class BottomNavigationState {
  final String appBarTitle;
  final int selectedIndex;
  final int previousIndex;

  BottomNavigationState(
      {this.appBarTitle = 'Home',
      this.selectedIndex = 0,
      this.previousIndex = 0});

  BottomNavigationState copyWith(
      {String? appBarTitle, int? selectedIndex, int? previousIndex}) {
    return BottomNavigationState(
      appBarTitle: appBarTitle ?? this.appBarTitle,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      previousIndex: previousIndex ?? this.previousIndex,
    );
  }
}
