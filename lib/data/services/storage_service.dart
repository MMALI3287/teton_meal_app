import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Check if storage permissions are correctly set up
  static Future<bool> checkStoragePermissions() async {
    try {
      // Try to list items in the storage bucket to verify permissions
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

  // Upload a file to Firebase Storage with enhanced error handling
  static Future<String?> uploadFile({
    required String filePath,
    required String fileName,
    required String contentType,
    String folder = 'uploads',
  }) async {
    try {
      if (kDebugMode) {
        print('Starting upload of $fileName to $folder');
        
        // Debug: Check if file exists and has content
        final file = File(filePath);
        final fileExists = await file.exists();
        final fileSize = fileExists ? await file.length() : 0;
        print('File exists: $fileExists, Size: $fileSize bytes');
        
        // Debug: Check Firebase Storage instance
        print('Storage bucket: ${_storage.bucket}');
      }

      // Create the reference with correct path
      final ref = _storage.ref().child('$folder/$fileName');
      if (kDebugMode) {
        print('Storage reference path: ${ref.fullPath}');
      }
      
      // Set proper metadata
      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {'uploaded-by': 'teton-meal-app'},
      );

      // Get the file
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      // Start upload task
      final uploadTask = ref.putFile(
        file,
        metadata,
      );

      // Listen for state changes, errors, and completion events
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

      // Wait for the upload to complete
      final snapshot = await uploadTask;
      
      if (kDebugMode) {
        print('Upload completed. Trying to get download URL...');
      }
      
      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      if (kDebugMode) {
        print('Got download URL: $downloadUrl');
      }
      
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error in uploadFile: $e');
        
        // More specific error classification
        if (e is FirebaseException) {
          print('Firebase error code: ${e.code}, message: ${e.message}');
          
          if (e.code == 'unauthorized') {
            print('Firebase Storage Rules are likely blocking access. Check your security rules.');
          } else if (e.code == 'object-not-found') {
            print('The specified object (folder or file) was not found. Check if the path exists.');
          } else if (e.code == 'storage/quota-exceeded') {
            print('Storage quota exceeded. Check your Firebase plan.');
          }
        }
      }
      return null;
    }
  }

  // Helper to get a file from a path
  static Future<File> getFile(String path) async {
    if (path.startsWith('http')) {
      // Handle URLs if needed
      throw Exception('URL uploads not yet implemented');
    } else {
      // Handle file path
      final file = File(path);
      if (!await file.exists()) {
        throw Exception('File does not exist: $path');
      }
      return file;
    }
  }
}
