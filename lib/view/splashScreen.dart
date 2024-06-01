import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  AppUpdateInfo? updateInfo;

  @override
  Widget build(BuildContext context) {
    return updateInfo?.updateAvailability == UpdateAvailability.updateAvailable
        ? FutureBuilder(
            future: Future.delayed(Duration.zero),
            builder: (context, snapshot) {
              // If future is complete, show dialog
              if (snapshot.connectionState == ConnectionState.done) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Update Available'),
                      content:
                          const Text('A new version of this app is available.'),
                      actions: <Widget>[
                        ElevatedButton(
                          child: const Text('UPDATE'),
                          onPressed: () {
                            InAppUpdate.startFlexibleUpdate().then((_) {
                              InAppUpdate.completeFlexibleUpdate();
                            });
                          },
                        ),
                      ],
                    );
                  },
                );
              }
              // Show splash screen while waiting
              return const Scaffold(
                body: Center(
                  child: Text('Welcome to my app! Loading...'),
                ),
              );
            },
          )
        : Scaffold(
            body: Center(
              child: Image.asset('assets/icon.png'),
            ),
          );
  }
}
