import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.storage,
    ].request();

    return statuses[Permission.microphone]!.isGranted && statuses[Permission.storage]!.isGranted;
  }
}
