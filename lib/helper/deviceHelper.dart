import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceHelper {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<String> getUniqueId() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        // Android 10+ için en güvenilir benzersiz kimlik 'id' alanıdır.
        // Cihaz sıfırlanmadığı sürece değişmez.
        return androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        // iOS tarafında uygulama bazlı en stabil ID 'identifierForVendor' dır.
        return iosInfo.identifierForVendor ?? "unknown_ios";
      } else {
        return "unsupported_platform";
      }
    } catch (e) {
      print("Cihaz ID alınamadı: $e");
      return "error_id";
    }
  }
}
