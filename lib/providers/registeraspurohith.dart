import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purohithulu/models/registeraspurohith.dart';
import 'package:http_parser/http_parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import '../utils/purohitapi.dart';
import 'categorynotifier.dart';
import 'imagepicker.dart';
import 'loader.dart';
import 'locationstatenotifier.dart';

class Registeraspurohith extends StateNotifier<RegisterAsPurohith> {
  Registeraspurohith() : super(RegisterAsPurohith.initial());
  Future register(String mobileno, String expirience, String languages,
      String userName, BuildContext context, WidgetRef ref) async {
    final categoryNotifier = ref.read(categoryProvider.notifier);
    var catIdString = categoryNotifier.selectedCatId.isNotEmpty
        ? categoryNotifier.selectedCatId.join(",")
        : '';
    final locationNotifier = ref.read(locationProvider.notifier);
    var locationId = locationNotifier.getLocationId();
    String randomLetters = generateRandomLetters(10);
    final loadingState = ref.read(loadingProvider.notifier);
    final imagePickerState = ref.read(imagePickerProvider);
    var data = {
      "mobileno": mobileno,
      "role": "p",
      "username": userName,
      "userstatus": "0",
      "adhar": "${randomLetters}_adhar",
      "profilepic": "${randomLetters}_profilepic",
      "expirience": expirience,
      "lang": languages,
      "isonline": "0",
      "location": locationId
    };
    var separator = '/';

    var url =
        "${PurohitApi().baseUrl}${PurohitApi().register}$catIdString$separator";
    Map<String, String> obj = {"attributes": json.encode(data).toString()};
    try {
      loadingState.state = true;
      var response = http.MultipartRequest('POST', Uri.parse(url));

// Check if the adhar image is available and not null
      // if (flutterFunctions.imageFileList['adhar'] != null) {
      //   response.files.add(await http.MultipartFile.fromPath(
      //       "imagefile[]", flutterFunctions.imageFileList['adhar']!.path,
      //       contentType: parser.MediaType("image", "jpg")));
      // }

// Check if the profile image is available and not null
      if (imagePickerState.imageFileList['profile'] != null) {
        response.files.add(await http.MultipartFile.fromPath(
          "imagefile[]",
          imagePickerState.imageFileList['profile']!.path,
          contentType: parser.MediaType("image", "jpg"),
        ));
      }

// Add the rest of your fields and complete your API call...
      response.fields.addAll(obj);
      final send = await response.send();
      final res = await http.Response.fromStream(send);
      var statuscode = res.statusCode;
      loadingState.state = false;

      var user = json.decode(res.body);

      state = state.copyWith(
          statusCode: user['statuscode'], messages: user['messages']);
      Future.delayed(Duration.zero).then((v) {
        return showAlertDialog(context, "Response");
      });
      return statuscode;
    } catch (e) {
      loadingState.state = false;
    }
  }

  String generateRandomLetters(int length) {
    var random = Random();
    var letters = List.generate(length, (_) => random.nextInt(26) + 97);
    return String.fromCharCodes(letters);
  }

  void showAlertDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(state.messages.toString()),
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

final registerProvider =
    StateNotifierProvider<Registeraspurohith, RegisterAsPurohith>((ref) {
  return Registeraspurohith();
});
