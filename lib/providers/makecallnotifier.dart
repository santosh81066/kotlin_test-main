import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../models/callmodel.dart';
import 'package:http/http.dart' as http;

class MakeCallNotifier extends StateNotifier<Call> {
  MakeCallNotifier() : super(Call(amount: 0, minutes: 0));
  Future<void> makeCallRequest(String callerId, String number,{bool?custemor}) async {
    print("callerid : $callerId,number:$number");
    const url =
        'https://restapi.smscountry.com/v0.1/Accounts/UaU6aEHXZlUG1ow0wa5y/Calls/';

    // Basic Authentication credentials
    const username = 'UaU6aEHXZlUG1ow0wa5y';
    const password = 'KHaHGzXTmGZvhxJ6M7EsVIw8ZcApnj3NdQ4pSOCD';
    final auth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final headers = {
      'Authorization': auth,
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "Number": custemor == true? "+919014709289" : number,
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
