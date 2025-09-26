import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

Future<File?> savePickedFile(XFile? picked) async {
  if (picked == null) return null;

  try {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = picked.name;
    final savedFile = await File(picked.path).copy('${appDir.path}/$fileName');
    return savedFile;
  } catch (e) {
    print("Error saving picked file: $e");
    return null;
  }
}
