import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/retry.dart';
import 'package:http/http.dart' as http;
import '../models/location.dart';
import '../utils/purohitapi.dart';
import 'authnotifier.dart';

class LocationStateNotifier extends StateNotifier<Location> {
  final AuthNotifier authNotifier;
  String? currentFilterLocation;
  int? locationId;

  LocationStateNotifier(this.authNotifier) : super(Location.initial());

  Future<void> getLocation() async {
    final url = '${PurohitApi().baseUrl}${PurohitApi().location}';

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
    var response = await client.get(
      Uri.parse(url),
    );
    Map<String, dynamic> locationBody = json.decode(response.body);
    state = Location.fromJson(locationBody);
  }

  void setFilterLocation(String filterLocation, int id) {
    currentFilterLocation = filterLocation;
    locationId = id;
    state = state.copyWith(data: state.data);
  }

  String? getFilterLocation() {
    return currentFilterLocation;
  }

  int? getLocationId() {
    return locationId;
  }
}

final locationProvider =
    StateNotifierProvider<LocationStateNotifier, Location>((ref) {
  final authNotifier = ref.read(authProvider.notifier);
  return LocationStateNotifier(authNotifier);
});
