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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAIdgrcoU_sYiNpqXzGFC6XbZp7L3R2HOQ',
    appId: '1:706508579691:android:9510234eece5fe9827a22e',
    messagingSenderId: '706508579691',
    projectId: 'pito-99f2b',
    storageBucket: 'pito-99f2b.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAXc6G9CadSJvn30YNO8cvGgwCkUT7FSt8',
    appId: '1:706508579691:ios:cc581b228bf7454827a22e',
    messagingSenderId: '706508579691',
    projectId: 'pito-99f2b',
    storageBucket: 'pito-99f2b.appspot.com',
    androidClientId: '706508579691-97ijmufpg4ibdvfvb1kg3hc1t569h6b6.apps.googleusercontent.com',
    iosClientId: '706508579691-j5lsb594q332g4d5rdma9qdgc6sv2k69.apps.googleusercontent.com',
    iosBundleId: 'com.pito.customer',
  );
}