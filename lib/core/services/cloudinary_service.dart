import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class CloudinaryService {
  Future<String> uploadFile(File file, {String? resourceType}) async {
    if (!AppConfig.cloudinaryConfigured) {
      throw Exception('Cloudinary is not configured. See README.md');
    }
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${AppConfig.cloudinaryCloudName}/'
      '${resourceType ?? 'auto'}/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = AppConfig.cloudinaryUploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));
    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode >= 400) {
      throw Exception('Upload failed: $body');
    }
    final json = jsonDecode(body) as Map<String, dynamic>;
    return json['secure_url'] as String;
  }
}
