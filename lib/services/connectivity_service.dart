import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();

  ConnectivityService() {
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((results) {
      for (final result in results) {
        _checkConnection(result);
      }
    });
    _initConnectivity();
  }

  Stream<bool> get connectionStream => _connectionController.stream;

  Future<void> _initConnectivity() async {
    // Check initial connectivity
    final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
    for (final result in results) {
      _checkConnection(result);
    }
  }

  // Update _checkConnection to handle single ConnectivityResult instead of a list
  void _checkConnection(ConnectivityResult result) {
    final bool isConnected = result != ConnectivityResult.none;
    _connectionController.add(isConnected);
  }

  void dispose() {
    _connectionController.close();
  }
}
