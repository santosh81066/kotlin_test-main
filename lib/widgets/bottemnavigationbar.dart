import 'package:flutter/material.dart';

class BottemNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onPageChanged;
  final String title;
  const BottemNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onPageChanged,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Color.fromARGB(223, 255, 253, 253),
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              const Icon(Icons.temple_hindu),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              const Icon(Icons.event_available),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              const Icon(Icons.file_download),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
          label: 'Your Files',
        ),
        // BottomNavigationBarItem(
        //   icon: Stack(
        //     children: [
        //       const Icon(Icons.event_available),
        //       Positioned.fill(
        //         child: Align(
        //           alignment: Alignment.center,
        //           child: Container(
        //             decoration: const BoxDecoration(
        //               shape: BoxShape.circle,
        //             ),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        //   label: 'Bookings',
        // ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              const Icon(Icons.account_circle_outlined),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
          label: 'Acount',
        ),
      ],
      selectedItemColor: Colors.black,
      showSelectedLabels: true,
      unselectedItemColor: const Color.fromARGB(255, 111, 109, 109),
      currentIndex: selectedIndex,
      useLegacyColorScheme: true,
      selectedLabelStyle: TextStyle(
          decoration: TextDecoration.underline, decorationColor: Colors.orange),
      onTap: onPageChanged,
    );
  }
}
