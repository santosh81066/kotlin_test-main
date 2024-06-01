import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/phoneauthstate.dart';
import 'authnotifier.dart';
import 'loader.dart';

class PhoneAuthNotifier extends StateNotifier<PhoneAuthState> {
  PhoneAuthNotifier() : super(PhoneAuthState());
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void restartTimer() {
    state =
        state.copyWith(countdown: 45, wait: true); // Reset countdown and wait
    startTimer(); // Start the timer again
  }

  void startTimer() {
    _timer?.cancel(); // Cancel any existing timer

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.countdown == 0) {
        waitTime();
        timer.cancel();
      } else {
        updateCountdown();
      }
    });
  }

  void updateCountdown() {
    state = state.copyWith(countdown: state.countdown - 1);
  }

  void waitTime() {
    state = state.copyWith(wait: !state.wait);
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> phoneAuth(
      BuildContext context, String phoneNumber, WidgetRef ref) async {
    final loadingState = ref.watch(loadingProvider.notifier);
    final FirebaseAuth auth =
        FirebaseAuth.instance; // Ensure you have an instance of FirebaseAuth

    try {
      loadingState.state = true;

      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          // Handle auto-retrieval or instant verification
        },
        verificationFailed: (FirebaseException exception) {
          loadingState.state = false;
          _showAlertDialog(context, "Verification Failed",
              exception.message ?? "An error occurred.");
        },
        codeSent: (String verificationId, [int? forceResendingToken]) async {
          _showAlertDialog(
              context, "Code Sent", "Verification code sent on your mobile.");
          Navigator.of(context).pushNamed('verifyotp', arguments: phoneNumber);
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('verificationid', verificationId);
          loadingState.state = false;
        },
        timeout: const Duration(seconds: 30),
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle auto retrieval timeout
        },
      );
    } catch (e) {
      loadingState.state = false;
      _showAlertDialog(context, "Error", e.toString());
    }
  }

  Future<void> signInWithPhoneNumber(
      String smsCode,
      BuildContext context,
      WidgetRef ref,
      String phoneNumber,
      ScaffoldMessengerState scaffoldKey) async {
    final prefs = await SharedPreferences.getInstance();
    String? verificationId = prefs.getString('verificationid');
    final authState = ref.watch(authProvider);
    final loadingState = ref.watch(loadingProvider.notifier);
    try {
      loadingState.state = true;

      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId!, smsCode: smsCode);

      await auth.signInWithCredential(credential).then((value) async {
        if (value.user != null) {
          var user = auth.currentUser!;

          user.getIdToken().then((ftoken) async {
            await prefs.setString('firebaseToken', ftoken!);
          });

          // FirebaseFirestore.instance
          //     .collection('userdata')
          //     .doc(value.user!.uid)
          int response = await ref
              .read(authProvider.notifier)
              .registerUser(context, phoneNumber, ref);
          //     .set({"mobileno": phoneNumber, "role": "u"});

          switch (response) {
            case 400:
              scaffoldKey.showSnackBar(SnackBar(
                content: Text('${authState.messages}'),
                duration: const Duration(seconds: 5),
              ));
              loadingState.state = false;
              break;
            case 201:
              scaffoldKey.showSnackBar(SnackBar(
                content: Text('${authState.messages}'),
                duration: const Duration(seconds: 5),
              ));

              loadingState.state = false;
              break;
          }
        }
      });

      loadingState.state = false;
    } catch (e) {
      loadingState.state = false;
      if (e is PlatformException) {
        PlatformException exception = e;
        if (exception.code == 'firebase_auth') {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: Text(exception.message!),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
        }

        //showsnackbar(context, e.toString());
      }
    }
    loadingState.state = false;
  }

  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    // Implement any additional logic as needed
  }
}

final phoneAuthProvider =
    StateNotifierProvider<PhoneAuthNotifier, PhoneAuthState>((ref) {
  return PhoneAuthNotifier();
});
