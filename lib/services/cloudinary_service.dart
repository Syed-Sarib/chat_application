import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class CloudinaryService {
  static const String cloudName = 'dcntmaunz'; // Replace if needed
  static const String uploadPreset = 'flutter_chat_app'; // Use consistently

  static Uri _getUploadUri(String type) {
    return Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$type/upload');
  }

  // ✅ Updated uploadFile() to detect type and upload properly
  static Future<String> uploadFile(File file) async {
    try {
      final extension = file.path.split('.').last.toLowerCase();

      String type;
      if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
        type = 'image';
      } else if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension)) {
        type = 'video';
      } else if (['mp3', 'wav', 'm4a', 'aac', 'ogg'].contains(extension)) {
        type = 'raw'; // audio goes here
      } else {
        type = 'raw'; // fallback for documents, etc.
      }

      final uri = _getUploadUri(type);
      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        return jsonResponse['secure_url'];
      } else {
        print('❌ Upload failed: ${response.statusCode}');
        print(responseBody);
        throw Exception('Failed to upload file to Cloudinary');
      }
    } catch (e) {
      print('❌ Error uploading file to Cloudinary: $e');
      throw Exception('Failed to upload file to Cloudinary');
    }
  }

  // ✅ Used internally by uploadImage, uploadVideo, uploadAudio
  static Future<String?> _uploadFile(File file, String type) async {
    try {
      final uri = _getUploadUri(type);
      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        return jsonResponse['secure_url'];
      } else {
        print('Upload failed: ${response.statusCode}');
        print(responseBody);
        return null;
      }
    } catch (e) {
      print('Error uploading $type: $e');
      return null;
    }
  }

  // Upload image
  static Future<String?> uploadImage(File imageFile) async {
    return await _uploadFile(imageFile, 'image');
  }

  // Upload video
  static Future<String?> uploadVideo(File videoFile) async {
    return await _uploadFile(videoFile, 'video');
  }

  // Upload audio (Cloudinary stores audio as raw or video)
  static Future<String?> uploadAudio(File audioFile) async {
    return await _uploadFile(audioFile, 'raw'); // 'raw' is Cloudinary's type for audio/docs/etc.
  }

  // Download file and save locally
  static Future<File?> downloadFile(String url, {String? customName}) async {
    try {
      final dir = await getApplicationDocumentsDirectory();

      String extension = 'file';
      try {
        extension = url.split('.').last.split('?').first;
      } catch (_) {}

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = customName ?? 'file_$timestamp.$extension';
      final path = '${dir.path}/$fileName';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final file = File(path);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        print('Download failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }
}
