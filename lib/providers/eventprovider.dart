import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/retry.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path_provider/path_provider.dart';

import 'package:http/http.dart' as http;

import '../models/events.dart';
import '../utils/purohitapi.dart';
import 'authnotifier.dart';

class EventNotifier extends StateNotifier<Events> {
  final AuthNotifier authNotifier;
  EventNotifier(this.authNotifier) : super(Events());
  Future<XFile?> getEventPic(
      BuildContext cont, String packageid, String imageid) async {
    final url =
        "${PurohitApi().baseUrl}${PurohitApi().packageId}$packageid${PurohitApi().imageId}$imageid";
    final token = authNotifier.state.accessToken;

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
    var response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token!
      },
    );
    //Map<String, dynamic> userResponse = json.decode(response.body);
    final Uint8List resbytes = response.bodyBytes;

    switch (response.statusCode) {
      case 200:

        // Attempt to create an Image object from the image bytes
        // final image = Image.memory(resbytes);
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/event');
        await file.writeAsBytes(resbytes);
        final xfile = XFile(file.path);

        //userDetails!.data![0].xfile = XFile(file.path);

        return xfile;
      // If the image was created successfully, the bytes are in a valid format
    }

    // print(
    //     "this is from getuserPic:${userDetails!.data![0].xfile!.readAsBytes()}");

    return null;
  }

  Future<void> getEvents(BuildContext context) async {
    final url = '${PurohitApi().baseUrl}${PurohitApi().createPackage}';

    final token = authNotifier.state.accessToken;
    final client = RetryClient(
      http.Client(),
      retries: 4,
      when: (response) {
        return response.statusCode == 401 ? true : false;
      },
      onRetry: (req, res, retryCount) async {
        if (retryCount == 0 && res?.statusCode == 401) {
          var accessToken = await authNotifier.restoreAccessToken(call: "get events");
          // Only this block can run (once) until done

          req.headers['Authorization'] = accessToken;
        }
      },
    );
    var response = await client.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token!
      },
    );
    Map<String, dynamic> event = json.decode(response.body);
    state = Events.fromJson(event);
  }

  Future<void> loadImages(BuildContext cont) async {
    for (var i = 0; i < state.eventdata!.length; i++) {
      final data = state.eventdata![i];
      final packageid = data.id;
      final imageid = data.catid;

      // Check if the packageid and imageid are not null
      if (packageid != null && imageid != null) {
        // Call the getEventPic API to download the image
        final xfile =
            await getEventPic(cont, packageid.toString(), imageid.toString());

        if (xfile != null) {
          data.xfile = xfile;
        }
      }
    }
  }
}

final eventDataProvider = StateNotifierProvider<EventNotifier, Events>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);

  return EventNotifier(authNotifier);
});
