import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purohithulu/view/account.dart';

import '../providers/bottomnavigationnotifier.dart';
import '../providers/carouselstatenotifier.dart';
import '../providers/categorynotifier.dart';
import '../providers/eventprovider.dart';
import '../providers/locationstatenotifier.dart';
import '../providers/purohithnotifier.dart';
import '../providers/userprofiledatanotifier.dart';
import '../widgets/app_drawer.dart';
import '../widgets/appbar.dart';
import '../widgets/bottemnavigationbar.dart';
import '../widgets/categories.dart';
import 'bookingscreen.dart';
import 'horoscopescreen.dart';

class WellcomeScreen extends ConsumerStatefulWidget {
  final GlobalKey globalKey;
  const WellcomeScreen({
    required this.globalKey,
    super.key,
  });

  @override
  ConsumerState<WellcomeScreen> createState() => _WellcomeScreenState();
}

class _WellcomeScreenState extends ConsumerState<WellcomeScreen> {
  DateTime? lastPressedTime;
  bool isinit = true;
  late PageController _pageController;
  final int _selectedIndex = 0;
  final ValueNotifier<String> appBarTitle = ValueNotifier<String>('Home');

  final GlobalKey _authDetailsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  void _initFunctions(BuildContext context) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await ref.read(carouselStateProvider.notifier).getCarousel().then(
          (value) =>
              ref.read(carouselStateProvider.notifier).loadCarouselImages());
      Future.delayed(Duration.zero).then((value) async {
        return await ref
            .read(userProfileDataProvider.notifier)
            .getUser(context, ref)
            .then((value) async {
          return await ref
              .read(userProfileDataProvider.notifier)
              .getUserPic(context, ref);
        }).then((value) async {
          await ref
              .read(purohithNotifierProvider.notifier)
              .getPurohit(context, ref);
        });
      });

      try {
        await ref.read(eventDataProvider.notifier).getEvents(context).then(
            (value) =>
                ref.read(eventDataProvider.notifier).loadImages(context));
      } catch (e) {}
    });
  }

  @override
  void didChangeDependencies() async {
    if (isinit) {
      ref.read(categoryProvider.notifier).getCategories();
      ref.read(locationProvider.notifier).getLocation();

      _initFunctions(context);
      isinit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateAppBarTitle(int index) {
    switch (index) {
      case 0:
        appBarTitle.value = 'Home';
        break;
      case 1:
        appBarTitle.value = 'Your Booking History';
        break;
      case 2:
        appBarTitle.value = 'Your Files';
        break;
      case 3:
        appBarTitle.value = 'Account';

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      key: _authDetailsKey,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            final now = DateTime.now();
            final allowExit = lastPressedTime == null ||
                now.difference(lastPressedTime!) > const Duration(seconds: 2);
            if (allowExit) {
              lastPressedTime = now;
              const snackBar = SnackBar(
                content: Text('Press again to exit'),
                duration: Duration(seconds: 2),
              );
              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(snackBar);
              return false;
            } else {
              return true;
            }
          },
          child: Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(bottemNavigationProvider);
              final title = appBarTitle.value;

              print(title);
              return Scaffold(
                appBar: purohithAppBar(context, title,backButton: false),
                body: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    ref.read(bottemNavigationProvider.notifier).update(index);
                    _updateAppBarTitle(index);
                  },
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        // Accessing the CategoryState from the CategoryNotifier
                        final categoryState = ref.watch(carouselStateProvider);
                        final categories = ref.watch(categoryProvider);
                        final categoriesWithParentId = categories.categories;
                        // Filtering categories with parentid as null

                        var categoriesWithParentIdNull = categories.categories
                            .where(
                              (calling) => calling.parentid == null,
                            )
                            .toList();

                        return Categories(
                          call: categoriesWithParentId,
                          images: categoryState.carousel == null
                              ? []
                              : categoryState.carousel!.data!,
                        );
                      },
                    ),
                    BookingsScreen(
                        onTitleChanged: (title) => appBarTitle.value = title),
                    HoroscopeList(
                        onTitleChanged: (title) => appBarTitle.value = title),
                    MyAccount()
                  ],
                ),
                bottomNavigationBar: BottemNavigationBar(
                  selectedIndex: state.selectedIndex,
                  onPageChanged: (index) {
                    print('pageindex:$index');
                    _pageController.jumpToPage(index);
                    _updateAppBarTitle(index);
                  },
                  title: appBarTitle.value,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
