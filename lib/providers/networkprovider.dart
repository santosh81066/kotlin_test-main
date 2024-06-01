import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkProvider with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  ConnectivityResult? _networkStatus; // Now it's nullable

  NetworkProvider() {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  ConnectivityResult? get networkStatus =>
      _networkStatus; // Getter is now also nullable

  Future<void> _initConnectivity() async {
    _networkStatus = await _connectivity.checkConnectivity();
    notifyListeners();
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    _networkStatus = result;
    notifyListeners();
  }
}
