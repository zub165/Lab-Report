import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Request camera only when the user chooses "Take photo".
/// Gallery uses the Android/iOS system picker (no broad storage access).
Future<bool> ensureImageSourcePermission(ImageSource source) async {
  if (source != ImageSource.camera) return true;
  final status = await Permission.camera.request();
  return status.isGranted;
}
