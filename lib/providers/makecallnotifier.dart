import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import '../models/callmodel.dart';
import '../widgets/callduration.dart';
import 'bookingnotifier.dart';
import 'package:http/http.dart' as http;

class MakeCallNotifier extends StateNotifier<Call> {
  MakeCallNotifier() : super(Call(amount: 0, minutes: 0));
  Future<void> makeCallRequest(String callerId, String number) async {
    print("callerid : $callerId,number:$number");
    final url =
        'https://restapi.smscountry.com/v0.1/Accounts/AyKPrr0sxwdexW4dNqIX/Calls/';

    // Basic Authentication credentials
    final username = 'AyKPrr0sxwdexW4dNqIX';
    final password = 'njmgojnQ01kwJp3KjsfxD667wauJdOtRVywGEdNZ';
    final auth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));

    final headers = {
      'Authorization': auth,
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "Number": number,
      "AnswerUrl": "http://domainname/answerurl",
      "HttpMethod": "POST",
      "Xml": "<Response><dial>$callerId</dial></Response>"
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 202) {
        final responseData = json.decode(response.body);
        print('Call Queued: ${responseData["Message"]}');
      } else {
        print('Failed to queue call. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error making call request: $e');
    }
  }
}

var makeCallNotifierProvider =
    StateNotifierProvider<MakeCallNotifier, Call>((ref) => MakeCallNotifier());
