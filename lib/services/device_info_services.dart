// lib/services/device_info_service.dart

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;

import 'connectivity_service.dart';

class DeviceInfoService {
  final ConnectivityService _connectivityService = ConnectivityService();

  Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;

    final isAndroid = deviceInfo is AndroidDeviceInfo;
    final isIOS = deviceInfo is IosDeviceInfo;

    final Map<String, dynamic> deviceData = isAndroid
        ? await _readAndroidBuildData(deviceInfoPlugin)
        : await _readIosDeviceInfo(deviceInfoPlugin);

    final bool isConnectedToWiFi =
        await _connectivityService.isConnectedToWiFi();
    final double speed = await _getNetworkSpeed();

    print("Is connected to WiFi: $isConnectedToWiFi");
    print("Network speed: $speed");

    return {
      'device_info': deviceData,
      'is_connected_to_wifi': isConnectedToWiFi,
      'bandwidth': speed,
    };
  }

  Future<Map<String, dynamic>> _readAndroidBuildData(
      DeviceInfoPlugin deviceInfoPlugin) async {
    final androidInfo = await deviceInfoPlugin.androidInfo;
    return {
      'system_version': 'Android ${androidInfo.version.release}',
      'model': androidInfo.model,
      'device_id': androidInfo.id,
    };
  }

  Future<Map<String, dynamic>> _readIosDeviceInfo(
      DeviceInfoPlugin deviceInfoPlugin) async {
    final iosInfo = await deviceInfoPlugin.iosInfo;
    return {
      'system_version': 'iOS ${iosInfo.systemVersion}',
      'model': iosInfo.model,
      'device_id': iosInfo.identifierForVendor,
    };
  }

  Future<double> _getNetworkSpeed() async {
    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.get(Uri.parse(
          'https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_92x30dp.png'));
      stopwatch.stop();
      final timeTaken = stopwatch.elapsedMilliseconds;
      final contentLength = response.bodyBytes.length;

      // Calcula a velocidade em Kbps
      final speedKbps = (contentLength / timeTaken) * 8;
      return speedKbps;
    } catch (e) {
      return 0.0; // se falhar, retornar 0
    }
  }
}
