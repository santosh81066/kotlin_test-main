import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  // Request permission
  Future<PermissionStatus> requestPermission(Permission permission) async {
    final status = await permission.request();
    return status;
  }
}
