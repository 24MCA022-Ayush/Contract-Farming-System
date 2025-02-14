// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyA4umPyj2ioPLc3yX6j8pLvmN6KxCN1IBg',
    appId: '1:46511866240:web:d761e355bfca5c63984165',
    messagingSenderId: '46511866240',
    projectId: 'fir-5e5c6',
    authDomain: 'fir-5e5c6.firebaseapp.com',
    storageBucket: 'fir-5e5c6.firebasestorage.app',
    measurementId: 'G-SCDQVE6XYS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDWnsoY5prsKBFrQOPFLos5gdMJrBVe8XU',
    appId: '1:46511866240:android:7f5c34cabf56c30e984165',
    messagingSenderId: '46511866240',
    projectId: 'fir-5e5c6',
    storageBucket: 'fir-5e5c6.firebasestorage.app',
  );
}
