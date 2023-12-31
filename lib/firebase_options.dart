// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyBxDSkyvLDKx4ntliqQPN4y3j5ZKQ3WfA8',
    appId: '1:442571443979:web:310ff65dcf2f3dd49fdc0e',
    messagingSenderId: '442571443979',
    projectId: 'invoice-app-533e7',
    authDomain: 'invoice-app-533e7.firebaseapp.com',
    storageBucket: 'invoice-app-533e7.appspot.com',
    measurementId: 'G-K6BDQ41JBM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBUucwKMRyakQRnLm8Se4LLBviR0r_wIKg',
    appId: '1:442571443979:android:c94a50d3fc5c76d79fdc0e',
    messagingSenderId: '442571443979',
    projectId: 'invoice-app-533e7',
    storageBucket: 'invoice-app-533e7.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCjzzm-3uXQKv68h65_FCrLwt-XDBwbu6g',
    appId: '1:442571443979:ios:68711877a52f407c9fdc0e',
    messagingSenderId: '442571443979',
    projectId: 'invoice-app-533e7',
    storageBucket: 'invoice-app-533e7.appspot.com',
    iosBundleId: 'com.solutine.invoice',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCjzzm-3uXQKv68h65_FCrLwt-XDBwbu6g',
    appId: '1:442571443979:ios:1cbc9493c7138b6b9fdc0e',
    messagingSenderId: '442571443979',
    projectId: 'invoice-app-533e7',
    storageBucket: 'invoice-app-533e7.appspot.com',
    iosBundleId: 'com.solutine.invoice.RunnerTests',
  );
}
