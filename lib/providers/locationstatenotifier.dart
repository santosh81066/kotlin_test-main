import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/retry.dart';

import '../models/location.dart';
import '../utils/purohitapi.dart';
import 'authnotifier.dart';


class LocationStateNotifier extends StateNotifier<Location> {
  final AuthNotifier authNotifier;
  String? currentFilterLocation;
  LocationStateNotifier(this.authNotifier)
      : super(Location.initial()); // Define an initial state

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
          // Only this block can run (once) until done

          req.headers['Authorization'] = accessToken;
        }
      },
    );
    var response = await client.get(
      Uri.parse(url),
    );
    print('location response $response');
    Map<String, dynamic> locationBody = json.decode(response.body);
    state = Location.fromJson(locationBody);
  }

  void setFilterLocation(String filterLocation) {
    currentFilterLocation = filterLocation;
    state = state.copyWith(data: state.data);
    // Apply the filter to the data if needed
  }

  String? getFilterLocation() {
    print('get filter location:$currentFilterLocation');
    return currentFilterLocation;
  }
}

final locationProvider =
    StateNotifierProvider<LocationStateNotifier, Location>((ref) {
  final authNotifier = ref.read(authProvider.notifier);
  return LocationStateNotifier(authNotifier);
});
