import 'dart:async';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:permission_handler/permission_handler.dart';
import '/providers/authnotifier.dart';
import '/view/categoryscreen.dart';
import '/view/contactus.dart';
import '/view/eventform.dart';
import '/view/events.dart';
import '/view/otp.dart';
import '/view/profiledetails.dart';
import '/view/registeruser.dart';
import '/view/saveprofile.dart';
import '/view/splashScreen.dart';
import '/view/subcatscreen.dart';
import '/view/verify_otp.dart';
import '/view/wallet.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'view/wellcomescreen.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrintStack(stackTrace: details.stack);
    return ErrorWidget(details.exception);
  };
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    final navigatorKey = GlobalKey<NavigatorState>();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    // ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

    // try {
    //   await ZegoUIKit().initLog();
    //   ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
    //     [ZegoUIKitSignalingPlugin()],
    //   );
    // } on PlatformException catch (e) {
    //   print('PlatformException was thrown: ${e.message}');
    // }

    runApp(
      ProviderScope(child: MyApp(navigatorKey: navigatorKey)),
    );
  }, (error, stackTrace) {
    print('Caught Flutter error');
    print(error.toString());
    print(stackTrace.toString());
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const MyApp({super.key, required this.navigatorKey});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppUpdateInfo? _updateInfo;
  final Connectivity _connectivity = Connectivity();
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();

    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
    });
    _checkForUpdates();
    // Delay permission request to ensure the app is fully initialized
    // Future.delayed(Duration(milliseconds: 500), () {
    //    _checkForUpdates();
    //   _requestSmsPermissions();
    // });
  }

  Future<void> _requestSmsPermissions() async {
    PermissionStatus status = await Permission.sms.status;
    if (status.isGranted) {
      // Permission is granted, proceed with functionality

      print('granted');
    } else if (status.isDenied) {
      print('denied');
      Permission.sms.request();
      // Permission is denied, request it
    } else if (status.isPermanentlyDenied) {
      // Permission is permanently denied, open app settings
    }
  }

  Future<void> _checkForUpdates() async {
    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      setState(() {
        _updateInfo = updateInfo;
      });

      if (_updateInfo!.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      if (e.toString().contains('ERROR_INSUFFICIENT_STORAGE')) {
        _showErrorDialog('Insufficient storage available for update.');
      } else {
        _showErrorDialog('An error occurred while checking for update.');
      }
    }
  }

  void _showErrorDialog(String errorMessage) {
    if (navigatorKey.currentContext != null) {
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Update Error"),
            content: Text(errorMessage),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      print('Context is null when trying to show error dialog');
    }
  }

  @override
  Widget build(BuildContext context) {
    const MaterialColor customColor = MaterialColor(
      0xFFF9BF42,
      <int, Color>{
        50: Color(0xFFFFFDE7),
        100: Color(0xFFFFF9C4),
        200: Color(0xFFFFF59D),
        300: Color(0xFFFFF176),
        400: Color(0xFFFFEE58),
        500: Color(0xFFF9BF42),
        600: Color(0xFFF57F17),
        700: Color(0xFFEF6C00),
        800: Color(0xFFE65100),
        900: Color(0xFFBF360C),
      },
    );
    final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
    return StreamBuilder(
      stream: _connectivity.onConnectivityChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final connectivity = snapshot.data;
          if (connectivity == ConnectivityResult.none) {
            return const Directionality(
              textDirection: TextDirection.ltr, // or rtl if needed
              child: MaterialApp(
                home: Center(
                  child: Text('you are offline'),
                ),
              ),
            );
          } else {
            return MaterialApp(
              navigatorKey: widget.navigatorKey,
              debugShowCheckedModeBanner: false,
              title: 'Talk2Purohith',
              scaffoldMessengerKey: scaffoldMessengerKey,
              theme: ThemeData(
                primarySwatch: customColor,
              ),
              supportedLocales: const [
                Locale('en', ''), // English
                // add other locales your app supports
              ],
              routes: {
                '/': (context) {
                  return Consumer(
                    builder: (context, ref, child) {
                      final authState = ref.watch(authProvider);
                      print('${authState.profile}');
                      // Check if the user is authenticated and profile is complete
                      if (authState.refreshToken != null) {
                        return authState.profile
                            ? WellcomeScreen(globalKey: GlobalKey())
                            : const SaveProfile();
                      }

                      // If the user is not authenticated, attempt auto-login
                      return FutureBuilder(
                        future: ref.watch(authProvider.notifier).tryAutoLogin(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SplashScreen(); // Show SplashScreen while waiting
                          } else {
                            // Based on auto-login result, navigate to appropriate screen
                            return snapshot.data == true
                                ? (authState.profile
                                    ? WellcomeScreen(globalKey: GlobalKey())
                                    : const SaveProfile())
                                : Otp(
                                    scaffoldMessengerKey: scaffoldMessengerKey);
                          }
                        },
                      );
                    },
                  );
                },
                'verifyotp': (context) => VerifyOtp(
                      scaffoldMessengerKey: scaffoldMessengerKey,
                    ),
                'wellcome': (context) => WellcomeScreen(globalKey: GlobalKey()),
                'wallet': (context) =>
                    Wallet(scaffoldMessengerKey: scaffoldMessengerKey),
                'catscreen': (context) {
                  return const CatScreen();
                },
                'subcatscreen': (context) {
                  return SubCat(scaffoldMessengerKey: scaffoldMessengerKey);
                },
                'saveprofile': (context) {
                  return const SaveProfile();
                },
                // 'registerotp': (context) => RegisterVerifyOtp(
                //       scaffoldMessengerKey: scaffoldMessengerKey
                //     ),
                'events': (context) {
                  return const Events();
                },
                'register': (context) {
                  return Register(scaffoldMessengerKey: scaffoldMessengerKey);
                },
                'eventForm': (context) {
                  return const EventForm();
                },
                'Customer Care': (context) {
                  return const ContactUsScreen();
                },
                'profileDetails': (context) {
                  return const ProfileDetails();
                },
              },
            );
          }
        }
        return const Directionality(
          textDirection: TextDirection.ltr, // or rtl if needed
          child: Center(
            child: Text('you are offline'),
          ),
        );
      },
    );
  }
}
