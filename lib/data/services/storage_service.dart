import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Future<bool> checkStoragePermissions() async {
    try {
      final ListResult result = await _storage.ref('profile_images').listAll();
      if (kDebugMode) {
        print('Storage access successful. Found ${result.items.length} items.');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Storage access error: $e');
      }
      return false;
    }
  }

  static Future<String?> uploadFile({
    required String filePath,
    required String fileName,
    required String contentType,
    String folder = 'uploads',
  }) async {
    try {
      if (kDebugMode) {
        print('Starting upload of $fileName to $folder');

        final file = File(filePath);
        final fileExists = await file.exists();
        final fileSize = fileExists ? await file.length() : 0;
        print('File exists: $fileExists, Size: $fileSize bytes');

        print('Storage bucket: ${_storage.bucket}');
      }

      final ref = _storage.ref().child('$folder/$fileName');
      if (kDebugMode) {
        print('Storage reference path: ${ref.fullPath}');
      }

      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {'uploaded-by': 'teton-meal-app'},
      );

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      final uploadTask = ref.putFile(
        file,
        metadata,
      );

      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          if (kDebugMode) {
            print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
          }
        },
        onError: (e) {
          if (kDebugMode) {
            print('Upload error: $e');
          }
        },
      );

      final snapshot = await uploadTask;

      if (kDebugMode) {
        print('Upload completed. Trying to get download URL...');
      }

      final downloadUrl = await snapshot.ref.getDownloadURL();

      if (kDebugMode) {
        print('Got download URL: $downloadUrl');
      }

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error in uploadFile: $e');

        if (e is FirebaseException) {
          print('Firebase error code: ${e.code}, message: ${e.message}');

          if (e.code == 'unauthorized') {
            print(
                'Firebase Storage Rules are likely blocking access. Check your security rules.');
          } else if (e.code == 'object-not-found') {
            print(
                'The specified object (folder or file) was not found. Check if the path exists.');
          } else if (e.code == 'storage/quota-exceeded') {
            print('Storage quota exceeded. Check your Firebase plan.');
          }
        }
      }
      return null;
    }
  }

  static Future<File> getFile(String path) async {
    if (path.startsWith('http')) {
      throw Exception('URL uploads not yet implemented');
    } else {
      final file = File(path);
      if (!await file.exists()) {
        throw Exception('File does not exist: $path');
      }
      return file;
    }
  }

  static Future<String?> uploadProfileImage(
      String userId, File imageFile) async {
    try {
      final fileName = 'profile_$userId.jpg';
      final downloadUrl = await uploadFile(
        filePath: imageFile.path,
        fileName: fileName,
        contentType: 'image/jpeg',
        folder: 'profile_images',
      );
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading profile image: $e');
      }
      return null;
    }
  }

  static Future<bool> deleteProfileImage(String userId) async {
    try {
      final fileName = 'profile_$userId.jpg';
      final ref = _storage.ref().child('profile_images/$fileName');
      await ref.delete();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting profile image: $e');
      }
      return false;
    }
  }
}
