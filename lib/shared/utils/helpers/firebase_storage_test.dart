import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// A utility class for testing Firebase Storage connectivity and permissions
class FirebaseStorageTest {
  /// Tests Firebase Storage connectivity and permissions
  /// Returns a message with the test result
  static Future<String> testStorageConnection() async {
    try {
      // Get the Firebase Storage instance
      final storage = FirebaseStorage.instance;
      
      // Log the bucket information
      if (kDebugMode) {
        print('Firebase Storage bucket: ${storage.bucket}');
      }
      
      // Try to list items in the root directory
      final rootResult = await storage.ref().listAll();
      
      // Try to list items in the profile_images directory
      try {
        final profileImagesResult = await storage.ref('profile_images').listAll();
        if (kDebugMode) {
          print('Found ${profileImagesResult.items.length} items in profile_images folder');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error accessing profile_images folder: $e');
          
          // Check if it's a permissions issue or if the folder doesn't exist
          if (e is FirebaseException && e.code == 'object-not-found') {
            // Try to create the folder by creating a placeholder file
            try {
              await storage.ref('profile_images/placeholder.txt')
                  .putString('This is a placeholder file to create the profile_images folder.');
              
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
