import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../config/app_config.dart';

/// Uploads profile images and documents to Firebase Storage.
/// Images fall back to an embedded data URL when Storage is unavailable.
class CloudinaryService {
  CloudinaryService(this._storage, this._auth);

  final FirebaseStorage _storage;
  final FirebaseAuth _auth;
  static const _uuid = Uuid();
  static const _dataUrlMaxBytes = 700000;

  Future<String> uploadFile(File file, {String? resourceType}) async {
    final length = await file.length();
    _validateSize(length, resourceType ?? 'auto');
    final name = file.path.split(Platform.pathSeparator).last;
    if (name.isEmpty) {
      throw Exception('Could not read the selected file.');
    }
    return _putBytes(
      await file.readAsBytes(),
      name,
      resourceType: resourceType,
    );
  }

  Future<String> uploadBytes(
    Uint8List bytes,
    String filename, {
    String? resourceType,
  }) async {
    _validateSize(bytes.length, resourceType ?? 'auto');
    return _putBytes(bytes, filename, resourceType: resourceType);
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

  Future<String> _putBytes(
    Uint8List bytes,
    String filename, {
    String? resourceType,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('You must be signed in to upload files.');
    }

    final isDocument = resourceType == 'raw';
    final ext = _extension(filename, isDocument);

    // Photos/logos: embed as data URL (works without Firebase Storage).
    if (!isDocument) {
      return _dataUrlFallback(bytes, ext, isDocument: false);
    }

    try {
      return await _uploadToStorage(uid, bytes, ext, isDocument);
    } on FirebaseException {
      return _dataUrlFallback(bytes, ext, isDocument: true);
    } catch (_) {
      return _dataUrlFallback(bytes, ext, isDocument: true);
    }
  }

  Future<String> _uploadToStorage(
    String uid,
    Uint8List bytes,
    String ext,
    bool isDocument,
  ) async {
    final folder = isDocument ? 'documents' : 'images';
    final path = 'uploads/$uid/$folder/${_uuid.v4()}.$ext';
    final ref = _storage.ref(path);
    await ref.putData(
      bytes,
      SettableMetadata(contentType: _contentType(ext, isDocument)),
    );
    return ref.getDownloadURL();
  }

  String _dataUrlFallback(
    Uint8List bytes,
    String ext, {
    required bool isDocument,
  }) {
    if (bytes.length > _dataUrlMaxBytes) {
      throw Exception(
        isDocument
            ? 'File is too large. Use a file under 700 KB or enable Firebase Storage.'
            : 'Image is too large. Choose a smaller photo or enable Firebase Storage.',
      );
    }
    final mime = _contentType(ext, isDocument);
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }

  String _extension(String filename, bool isDocument) {
    final dot = filename.lastIndexOf('.');
    if (dot != -1 && dot < filename.length - 1) {
      return filename.substring(dot + 1).toLowerCase();
    }
    return isDocument ? 'pdf' : 'jpg';
  }

  String _contentType(String ext, bool isDocument) {
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return isDocument ? 'application/octet-stream' : 'image/jpeg';
    }
  }
}
