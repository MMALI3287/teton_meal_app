import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDFgbZ-E6UswI9BhP8umISHdqKvkror1Vo',
    appId: '1:532094527655:web:34ca28bbeca3ec546a9382',
    messagingSenderId: '532094527655',
    projectId: 'teton-meal-app',
    authDomain: 'teton-meal-app.firebaseapp.com',
    storageBucket: 'teton-meal-app.firebasestorage.app',
    measurementId: 'G-P9TFL7X7XP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCgpcyb24FFXVwHmvR0-Z9sDoAx2E8q_ug',
    appId: '1:532094527655:android:95baa5dfa7f5ccbb6a9382',
    messagingSenderId: '532094527655',
    projectId: 'teton-meal-app',
    storageBucket: 'teton-meal-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCJ6lzxWRbYkd35vYmTIa8ZrY4CeLhpkL4',
    appId: '1:532094527655:ios:a18c42f264c1a5d46a9382',
    messagingSenderId: '532094527655',
    projectId: 'teton-meal-app',
    storageBucket: 'teton-meal-app.firebasestorage.app',
    iosBundleId: 'com.example.tetonMealApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCJ6lzxWRbYkd35vYmTIa8ZrY4CeLhpkL4',
    appId: '1:532094527655:ios:a18c42f264c1a5d46a9382',
    messagingSenderId: '532094527655',
    projectId: 'teton-meal-app',
    storageBucket: 'teton-meal-app.firebasestorage.app',
    iosBundleId: 'com.example.tetonMealApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDFgbZ-E6UswI9BhP8umISHdqKvkror1Vo',
    appId: '1:532094527655:web:d79fe7571d2e1dea6a9382',
    messagingSenderId: '532094527655',
    projectId: 'teton-meal-app',
    authDomain: 'teton-meal-app.firebaseapp.com',
    storageBucket: 'teton-meal-app.firebasestorage.app',
    measurementId: 'G-YM985MZFQN',
  );
}
