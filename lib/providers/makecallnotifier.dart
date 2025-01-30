import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/callmodel.dart';
import 'package:http/http.dart' as http;

class MakeCallNotifier extends StateNotifier<Call> {
  MakeCallNotifier() : super(Call(amount: 0, minutes: 0, overPulseCount: 50));
  final fbuser = FirebaseAuth.instance.currentUser;

  static const int callCost = 50;

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> initBackground() async {
    const androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "Call Monitoring",
      notificationText: "Monitoring call status in background",
      notificationIcon:
          AndroidResource(name: 'background_icon', defType: 'drawable'),
    );

    await FlutterBackground.initialize(androidConfig: androidConfig);
    await FlutterBackground.enableBackgroundExecution();
  }

  Future<void> makeCallRequest(
      BuildContext context, String callerId, String number,
      {bool? customer, required bool custemor, String? purohithUid}) async {
    var arguments = ModalRoute.of(context)!.settings.arguments as Map;
    String amountString =
        arguments['amount'].toString(); // Ensure it's a string
    String digitsOnly =
        amountString.replaceAll(RegExp(r'\D'), ''); // Remove non-digits
    int price = int.tryParse(digitsOnly) ?? 0;

    final prefs = await SharedPreferences.getInstance();
    if (fbuser == null) {
      showSnackbar(context, "User not logged in. Cannot make a call request.");
      return;
    }

    // Check wallet balance before proceeding
    final databaseReference = FirebaseDatabase.instance.ref();
    final uid = fbuser?.uid;

    if (uid == null) {
      showSnackbar(context, 'User not logged in. Cannot check wallet balance.');
      return;
    }

    final userDataSnapshot =
        await databaseReference.child('wallet').child(uid).once();

    if (userDataSnapshot.snapshot.value != null) {
      var currentAmount =
          (userDataSnapshot.snapshot.value as Map)['amount'] ?? 0;

      if (currentAmount < 100) {
        showSnackbar(context, 'Insufficient wallet balance to make a call.');
        return;
      }
    } else {
      showSnackbar(
          context, 'Wallet does not exist for the user. Cannot proceed.');
      return;
    }

    print("callerId: $callerId, number: $number");
    const url =
        'https://restapi.smscountry.com/v0.1/Accounts/UaU6aEHXZlUG1ow0wa5y/Calls/';

    const username = 'UaU6aEHXZlUG1ow0wa5y';
    const password = 'KHaHGzXTmGZvhxJ6M7EsVIw8ZcApnj3NdQ4pSOCD';
    final auth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final headers = {
      'Authorization': auth,
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "Number": customer == true ? "+919014709289" : callerId,
      "AnswerUrl": "http://domainname/answerurl",
      "HttpMethod": "POST",
      "Xml": "<Response><dial>$number</dial></Response>"
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 202) {
        final responseData = json.decode(response.body);
        print('Call Queued: ${responseData["Message"]}');
        String callId = responseData["CallUUID"];
        await prefs.setString('callId', callId).catchError((e) {
          print('Error saving callId to SharedPreferences: $e');
        });

        int deductionAmount = price;
        await monitorCallReport(context, callId, deductionAmount, purohithUid);
      } else {
        print('Failed to queue call. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error making call request: $e');
    }
  }

  Future<void> monitorCallReport(BuildContext context, String callId,
      int deductionAmount, String? purohithUid) async {
    int maxAttempts = 900;
    int attempts = 0;

    while (attempts < maxAttempts) {
      bool shouldStop =
          await getCallReport(context, callId, deductionAmount, purohithUid);
      if (shouldStop) {
        print("Call ended successfully.");
        break;
      }
      attempts++;
      await Future.delayed(const Duration(seconds: 2));
    }

    if (attempts == maxAttempts) {
      print("Max attempts reached. Stopping report monitoring.");
    }
  }

  Future<bool> getCallReport(BuildContext context, String callId,
      int deductionAmount, String? purohithUid) async {
    if (fbuser == null) {
      showSnackbar(context, "User not logged in. Cannot get call report.");
      return false;
    }

    final url =
        'https://restapi.smscountry.com/v0.1/Accounts/UaU6aEHXZlUG1ow0wa5y/Calls/$callId/';
    const username = 'UaU6aEHXZlUG1ow0wa5y';
    const password = 'KHaHGzXTmGZvhxJ6M7EsVIw8ZcApnj3NdQ4pSOCD';
    final auth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final headers = {
      'Authorization': auth,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Call Report: $responseData');

        if (responseData.containsKey('Call')) {
          String endReason = responseData['Call']['EndReason'] ?? '';
          int duration =
              int.tryParse(responseData['Call']['Duration'].toString()) ?? 0;

          if (endReason == 'NORMAL_CLEARING') {
            print(
                'Call ended with NORMAL_CLEARING. Deducting amount: $deductionAmount');
            await deductFromWallet(context, deductionAmount);
            // 🔥 Call the updatePurohithWallet function here!
            await updateWalletAmount(context, purohithUid!);

            state = Call(
                amount: deductionAmount, minutes: duration, overPulseCount: 0);
            return true;
          } else if (endReason.isEmpty) {
            print('EndReason is empty. Continuing to monitor...');
          } else {
            print(
                'EndReason: $endReason. No deduction required. Stopping monitoring.');
            return true;
          }
        } else {
          print('Call information missing in response.');
        }
      } else {
        print(
            'Failed to retrieve call report. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error retrieving call report: $e');
    }

    return false;
  }

  // void updatePurohithWallet(int amount) async {
  //   DatabaseReference walletRef = FirebaseDatabase.instance
  //       .ref()
  //       .child('presence')
  //       .child('NJGGPqQ06EM4P4e6hyo8oKAq1Fg1')
  //       .child('purohithwallet');
  //
  //   try {
  //     final snapshot = await walletRef.get();
  //
  //     if (snapshot.exists) {
  //       // If exists, update the balance
  //       int currentAmount = snapshot.value as int;
  //       walletRef.set(currentAmount + amount);
  //     } else {
  //       // If doesn't exist, create it
  //       walletRef.set(amount);
  //     }
  //     print("Wallet updated successfully!");
  //   } catch (error) {
  //     print("Error updating wallet: $error");
  //   }
  // }

  Future<void> updateWalletAmount(BuildContext context, String userId) async {
    var arguments = ModalRoute.of(context)!.settings.arguments as Map;
    String amountString =
        arguments['amount'].toString(); // Ensure it's a string
    String digitsOnly =
        amountString.replaceAll(RegExp(r'\D'), ''); // Remove non-digits
    int price = int.tryParse(digitsOnly) ??
        0; // Convert to int, default to 0 if parsing fails

    try {
      final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();

      // Reference to the specific user's wallet in presence node
      final DatabaseReference userWalletRef =
          databaseRef.child('presence').child(userId).child('wallet');

      await userWalletRef.runTransaction((Object? currentValue) {
        if (currentValue == null) {
          // If wallet does not exist, create it with initial amount 140
          return Transaction.success(price);
        }

        // Convert current value to int and add 140
        int currentWallet = int.tryParse(currentValue.toString()) ?? 0;
        return Transaction.success(currentWallet + price);
      });

      print('Wallet updated successfully for user: $userId');
    } catch (e) {
      print('Error updating wallet: $e');
      rethrow;
    }
  }

  Future<void> deductFromWallet(
      BuildContext context, int amountToDeduct) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    final uid = fbuser?.uid;

    if (uid == null) {
      showSnackbar(context, 'User not logged in. Cannot deduct from wallet.');
      return;
    }

    try {
      final userDataSnapshot =
          await databaseReference.child('wallet').child(uid).once();

      if (userDataSnapshot.snapshot.value != null) {
        var currentAmount =
            (userDataSnapshot.snapshot.value as Map)['amount'] ?? 0;

        if (currentAmount >= amountToDeduct) {
          await databaseReference
              .child('wallet')
              .child(uid)
              .update({'amount': currentAmount - amountToDeduct});
          print(
              'Amount deducted: $amountToDeduct. Remaining balance: ${currentAmount - amountToDeduct}');
        } else {
          showSnackbar(context, 'Insufficient wallet balance.');
        }
      } else {
        showSnackbar(context, 'Wallet does not exist. Please add funds.');
      }
    } catch (e) {
      showSnackbar(context, 'Error processing wallet deduction.');
      print('Error deducting wallet balance: $e');
    }
  }
}

var makeCallNotifierProvider =
    StateNotifierProvider<MakeCallNotifier, Call>((ref) => MakeCallNotifier());
