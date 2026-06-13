import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class CloudinaryService {
  Future<String> uploadFile(File file, {String? resourceType}) async {
    final length = await file.length();
    _validateSize(length, resourceType ?? 'auto');
    return _upload(
      await http.MultipartFile.fromPath('file', file.path),
      resourceType: resourceType,
    );
  }

  Future<String> uploadBytes(
    Uint8List bytes,
    String filename, {
    String? resourceType,
  }) async {
    _validateSize(bytes.length, resourceType ?? 'auto');
    return _upload(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
      resourceType: resourceType,
    );
  }

  void _validateSize(int bytes, String resourceType) {
    final mb = bytes / (1024 * 1024);
    if (resourceType == 'raw') {
      if (mb > AppConfig.maxResumeSizeMb) {
        throw Exception(
          'File is too large. Maximum size is ${AppConfig.maxResumeSizeMb} MB.',
        );
      }
    } else if (mb > AppConfig.maxImageSizeMb) {
      throw Exception(
        'Image is too large. Maximum size is ${AppConfig.maxImageSizeMb} MB.',
      );
    }
  }

  Future<String> _upload(
    http.MultipartFile filePart, {
    String? resourceType,
  }) async {
    if (!AppConfig.cloudinaryConfigured) {
      throw Exception('Cloudinary is not configured. See README.md');
    }
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${AppConfig.cloudinaryCloudName}/'
      '${resourceType ?? 'auto'}/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = AppConfig.cloudinaryUploadPreset
      ..files.add(filePart);
    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode >= 400) {
      throw Exception(_parseError(body));
    }
    final json = jsonDecode(body) as Map<String, dynamic>;
    return json['secure_url'] as String;
  }

  String _parseError(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final error = json['error'];
      if (error is Map && error['message'] != null) {
        return 'Upload failed: ${error['message']}';
      }
    } catch (_) {}
    return 'Upload failed. Please try again.';
  }
}
