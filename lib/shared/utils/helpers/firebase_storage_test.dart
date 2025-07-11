import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageTest {
  static Future<String> testStorageConnection() async {
    try {
      final storage = FirebaseStorage.instance;

      if (kDebugMode) {
        print('Firebase Storage bucket: ${storage.bucket}');
      }

      final rootResult = await storage.ref().listAll();

      try {
        final profileImagesResult =
            await storage.ref('profile_images').listAll();
        if (kDebugMode) {
          print(
              'Found ${profileImagesResult.items.length} items in profile_images folder');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error accessing profile_images folder: $e');

          if (e is FirebaseException && e.code == 'object-not-found') {
            try {
              await storage.ref('profile_images/placeholder.txt').putString(
                  'This is a placeholder file to create the profile_images folder.');

              return 'Storage test successful. Created profile_images folder since it did not exist.';
            } catch (createError) {
              if (kDebugMode) {
                print('Error creating profile_images folder: $createError');
              }
              return 'Error: Could not access or create profile_images folder. Please check Firebase Storage rules.';
            }
          }
        }
        return 'Error accessing profile_images folder: ${e.toString()}';
      }

      return 'Storage test successful. Found ${rootResult.items.length} items in root and can access profile_images folder.';
    } catch (e) {
      if (kDebugMode) {
        print('Storage test failed: $e');
      }

      if (e is FirebaseException) {
        switch (e.code) {
          case 'unauthorized':
            return 'Error: Unauthorized access to Firebase Storage. Please check your Firebase Storage rules.';
          case 'object-not-found':
            return 'Error: Storage path not found. The storage bucket might not be initialized correctly.';
          default:
            return 'Firebase Storage error: ${e.code} - ${e.message}';
        }
      }

      return 'Storage test failed: ${e.toString()}';
    }
  }
}
