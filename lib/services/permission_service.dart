import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class PermissionService {
  Future<bool> requestStoragePermission() async {
    if (kIsWeb) return true;

    if (Platform.isAndroid) {
      var status = await Permission.audio.status;
      if (!status.isGranted) {
        status = await Permission.audio.request();
      }
      if (status.isGranted) return true;

      status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      if (status.isGranted) return true;

      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return false;
    }
    return true;
  }

  Future<bool> requestAudioPermission() async {
    if (kIsWeb) return true;
    return true;
  }

  Future<bool> hasPermissions() async {
    if (kIsWeb) return true;
    bool storagePermission = await Permission.storage.isGranted;
    bool audioPermission = await Permission.audio.isGranted;
    return storagePermission || audioPermission;
  }
}
