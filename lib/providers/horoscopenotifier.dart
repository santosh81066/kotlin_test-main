import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/retry.dart';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:http/http.dart' as http;

import '../models/horoscope.dart';
import '../utils/permissionservice.dart';
import '../utils/purohitapi.dart';
import 'authnotifier.dart';

class HoroScopeNotifier extends StateNotifier<Horoscope> {
  final AuthNotifier authNotifier;
  final Map<String, bool> _downloadedFiles = {};
  HoroScopeNotifier(this.authNotifier) : super(Horoscope());
  Future<void> getHoroscope(BuildContext cont) async {
    final url = PurohitApi().baseUrl + PurohitApi().getHoroscope;
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
    Map<String, dynamic> horos = json.decode(response.body);
    state = Horoscope.fromJson(horos);
  }

  void downloadPDF(String name, String fileid) async {
    PermissionsService permissionsService = PermissionsService();
    final status =
        await permissionsService.requestPermission(Permission.storage);
    if (status.isGranted) {
      final url = PurohitApi().baseUrl +
          PurohitApi().downloadHoroscope +
          fileid; // Replace with your file URL.
      String filename = '$name.pdf'; // Replace with your file name.
      _downloadFile(url, filename, 'Horoscope');
      _downloadedFiles['$name.pdf'] = true;
    }
  }

  Future<File> _downloadFile(
      String url, String filename, String directoryName) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var bytes = response.bodyBytes;
      Directory dir = await createSubDirectory(directoryName);
      File file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);
      return file;
    } else {
      throw Exception('Failed to load file: ${response.statusCode}');
    }
  }

  Future<Directory> createSubDirectory(String name) async {
    final directory = await getExternalStorageDirectory();
    final path = Directory('${directory!.path}/$name');

    if (await path.exists()) {
      // TODO: Handle the case where the directory already exists
      return path;
    } else {
      // If the directory does not exist, create it
      return await path.create();
    }
  }

  Future<bool> checkFileExists(String filename, String directoryName) async {
    Directory dir = await createSubDirectory(directoryName);
    File file = File('${dir.path}/$filename');

    return file.exists();
  }

  Future<void> openFile(String filename, String directoryName) async {
    Directory dir = await createSubDirectory(directoryName);
    File file = File('${dir.path}/$filename');

    await OpenFile.open(file.path);
  }

  bool isFileDownloaded(String filename) {
    return _downloadedFiles[filename] ?? false;
  }
}

final horoScopeDataProvider =
    StateNotifierProvider<HoroScopeNotifier, Horoscope>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);
  return HoroScopeNotifier(authNotifier);
});
