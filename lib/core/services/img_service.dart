import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<String> uploadToCloudinary(XFile pickedFile) async {
  final file = File(pickedFile.path);

  final request =
      http.MultipartRequest(
          'POST',
          Uri.parse("https://api.cloudinary.com/v1_1/dlqz13vkz/image/upload"),
        )
        ..fields['upload_preset'] = 'flutter_unsigned'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

  final response = await request.send();
  final resBody = await response.stream.bytesToString();
  final data = jsonDecode(resBody);

  return data['secure_url']; // <- public image URL
}

class ImageCacheService {
  static const _fileName = "profile.jpeg";

  Future<File?> saveFromUrl(String imageUrl) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File("${appDir.path}/$_fileName");

      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
      return null;
    } catch (e) {
      print("Error saving from URL: $e");
      return null;
    }
  }

  Future<File?> saveFromXFile(XFile picked) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File("${appDir.path}/$_fileName");
      return await File(picked.path).copy(file.path);
    } catch (e) {
      print("Error saving from XFile: $e");
      return null;
    }
  }

  Future<File?> loadCached() async {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File("${appDir.path}/$_fileName");
    return await file.exists() ? file : null;
  }
}
