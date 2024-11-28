import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/callmodel.dart';
import 'package:http/http.dart' as http;

class MakeCallNotifier extends StateNotifier<Call> {
  MakeCallNotifier() : super(Call(amount: 0, minutes: 0));
  final fbuser = FirebaseAuth.instance.currentUser;

  static const int callCost = 50;

  Future<void> makeCallRequest(String callerId, String number, {bool? customer, required bool custemor}) async {
    final prefs = await SharedPreferences.getInstance();
    if (fbuser == null) {

      print("User not logged in. Cannot make a call request.");
      return;
    }

    print("callerId: $callerId, number: $number");
    const url = 'https://restapi.smscountry.com/v0.1/Accounts/UaU6aEHXZlUG1ow0wa5y/GroupCalls/';

    

    // Basic Authentication credentials
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
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 202) {
        final responseData = json.decode(response.body);
        print('Call Queued: ${responseData["Message"]}');
        String callId = responseData["CallUUID"];
        int deductionAmount = 100;

        // Retrieve the call report after call request
        await prefs.setString('callID', callId);
        // await getCallReport(callId, deductionAmount);
      } else {
        print('Failed to queue call. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error making call request: $e');
    }
  }

  Future<void> getCallReport(String callId, int deductionAmount) async {
    if (fbuser == null) {
      print("User not logged in. Cannot get call report.");
      return;
    }

    final url = 'https://restapi.smscountry.com/v0.1/Accounts/UaU6aEHXZlUG1ow0wa5y/GroupCalls//Participants/';

    // Basic Authentication credentials
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
        print('Call Report: ${responseData}');

        // Ensure the duration is an integer, default to 0 if null or incorrect type
        int duration = 0;
        if (responseData.containsKey('Duration')) {
          duration = int.tryParse(responseData['Duration'].toString()) ?? 0;
        }

        // Update the call state with information from the report
        state = Call(
          amount: deductionAmount,
          minutes: duration,
        );


        // Deduct the specified amount from the user's wallet
        await deductAmountFromWallet(deductionAmount);
      } else {
        print('Failed to retrieve call report. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error retrieving call report: $e');
    }
  }

  // Function to deduct a specific amount from user's wallet in Firebase
  Future<void> deductAmountFromWallet(int billAmount) async {
    if (fbuser == null) {
      print("User not logged in. Cannot deduct wallet amount.");
      return;
    }

    final databaseReference = FirebaseDatabase.instance.ref();
    final uid = fbuser?.uid;

    if (uid != null) {
      try {
        final userDataSnapshot = await databaseReference.child('wallet').child(uid).once();

        if (userDataSnapshot.snapshot.value != null) {
          var currentAmount = (userDataSnapshot.snapshot.value as Map)['amount'] ?? 0;

          // Ensure that the wallet has enough balance
          if (currentAmount >= billAmount) {
            // Deduct the amount from the wallet
            await databaseReference.child('wallet').child(uid).update({
              'amount': currentAmount - billAmount,
            });
            print('Deducted $billAmount from wallet. New balance: ${currentAmount - billAmount}');
          } else {
            print('Insufficient balance in wallet to deduct $billAmount');
          }
        } else {
          print('Wallet not found for user $uid');
        }
      } catch (e) {
        print('Error updating wallet balance: $e');
      }
    }
  }
}

var makeCallNotifierProvider =
StateNotifierProvider<MakeCallNotifier, Call>((ref) => MakeCallNotifier());
