import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/retry.dart';

import 'package:http/http.dart' as http;


import '../models/familymem.dart';
import '../utils/purohitapi.dart';
import 'authnotifier.dart';

class EventFormNotifier extends StateNotifier<FamilyMembers> {
  final AuthNotifier authNotifier;
  EventFormNotifier(this.authNotifier) : super(FamilyMembers());
  List<int> selectedFamilyMemberId = [];
  List<String> selectedFamilyMemberName = [];
  Future addFamilyMember(BuildContext context, String member) async {
    var separator = '/';

    var url = "${PurohitApi().baseUrl}${PurohitApi().members}$separator$member";
    final token = authNotifier.state.accessToken;
    try {
      final client = RetryClient(
        http.Client(),
        retries: 4,
        when: (response) {
          return response.statusCode == 401 ? true : false;
        },
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 && res?.statusCode == 401) {
            var accessToken = await authNotifier.restoreAccessToken();
            req.headers['Authorization'] = accessToken;
          }
        },
      );
      var response = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token!
        },
      );

      var statuscode = response.statusCode;

      Map<String, dynamic> memberResponse = json.decode(response.body);

      if (state.data == null) {
        state = FamilyMembers.fromJson(memberResponse);
      } else {
        FamilyMembers newFamilyMembers = FamilyMembers.fromJson(memberResponse);

        state.data?.addAll(newFamilyMembers.data ?? []);
      }

      return statuscode;
    } catch (e) {}
  }

  void selectedFamilyMember(int val) {
    if (selectedFamilyMemberId.contains(val)) {
      selectedFamilyMemberId.remove(val);
    } else {
      selectedFamilyMemberId.add(val);
    }
    state = state;
  }

  void selectedFamilymember(String val) {
    if (selectedFamilyMemberName.contains(val)) {
      selectedFamilyMemberName.remove(val);
    } else {
      selectedFamilyMemberName.add(val);
    }
    state = state;
  }

  Future<void> getFamilyMembers(BuildContext context) async {
    // Assuming your API url is something like this:
    var url = "${PurohitApi().baseUrl}${PurohitApi().members}";

    if (state.data == null) {
      final client = RetryClient(
        http.Client(),
        retries: 4,
        when: (response) {
          return response.statusCode == 401 ? true : false;
        },
        onRetry: (req, res, retryCount) async {
          if (retryCount == 0 && res?.statusCode == 401) {
            var accessToken = await authNotifier.restoreAccessToken();
            // Only this block can run (once) until done

            req.headers['Authorization'] = accessToken;
          }
        },
      );

      final response = await client.get(Uri.parse(url));

      // If the server returns a 200 OK response, parse the JSON.
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        state = FamilyMembers.fromJson(jsonResponse);
      }
    }

    // Making the HTTP GET request
  }
}

final eventFormDataProvider =
    StateNotifierProvider<EventFormNotifier, FamilyMembers>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);

  return EventFormNotifier(authNotifier);
});
