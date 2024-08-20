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
    apiKey: 'AIzaSyB8GERPmfAOmgyXnlUZRSxm3AnDqrXgxCA',
    appId: '1:612540342490:web:926313948ffb58c66645e3',
    messagingSenderId: '612540342490',
    projectId: 'app-chat-97ecb',
    authDomain: 'app-chat-97ecb.firebaseapp.com',
    storageBucket: 'app-chat-97ecb.appspot.com',
    measurementId: 'G-HMDEWEE0TS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAlV-5Ph8FckXIHTT8alL6BwtQYSIddBII',
    appId: '1:612540342490:android:4e02c82ad79654c66645e3',
    messagingSenderId: '612540342490',
    projectId: 'app-chat-97ecb',
    storageBucket: 'app-chat-97ecb.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA_pngZvvZ7UXWzELo1qpBK5GTL-7d44qs',
    appId: '1:612540342490:ios:8468a27801fe662c6645e3',
    messagingSenderId: '612540342490',
    projectId: 'app-chat-97ecb',
    storageBucket: 'app-chat-97ecb.appspot.com',
    iosBundleId: 'com.example.appChat',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA_pngZvvZ7UXWzELo1qpBK5GTL-7d44qs',
    appId: '1:612540342490:ios:8468a27801fe662c6645e3',
    messagingSenderId: '612540342490',
    projectId: 'app-chat-97ecb',
    storageBucket: 'app-chat-97ecb.appspot.com',
    iosBundleId: 'com.example.appChat',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB8GERPmfAOmgyXnlUZRSxm3AnDqrXgxCA',
    appId: '1:612540342490:web:8a62f40f2ffe11656645e3',
    messagingSenderId: '612540342490',
    projectId: 'app-chat-97ecb',
    authDomain: 'app-chat-97ecb.firebaseapp.com',
    storageBucket: 'app-chat-97ecb.appspot.com',
    measurementId: 'G-VQSV9077MJ',
  );
}
