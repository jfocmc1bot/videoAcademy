// lib/services/connectivity_service.dart

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  Future<bool> isConnectedToWiFi() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    print("Connectivity result: $connectivityResult");
    return connectivityResult.contains(ConnectivityResult.wifi);
  }

  Future<bool> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    print("Connectivity result: $connectivityResult");
    return connectivityResult.isNotEmpty &&
        !connectivityResult.contains(ConnectivityResult.none);
  }
}
