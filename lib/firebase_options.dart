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
    apiKey: 'AIzaSyCPuR2GVUE-I4OvxTtz2XxLM8Lo17uga7A',
    appId: '1:408590004796:web:f50b25996b30da083f4939',
    messagingSenderId: '408590004796',
    projectId: 'vedicpurohit-d68c1',
    authDomain: 'vedicpurohit-d68c1.firebaseapp.com',
    databaseURL: 'https://vedicpurohit-d68c1-default-rtdb.firebaseio.com',
    storageBucket: 'vedicpurohit-d68c1.firebasestorage.app',
    measurementId: 'G-09YF3Z1YJB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBkByrZazrbsGH8pBFDUpKovxO-HSy3sf0',
    appId: '1:408590004796:android:61486bf3d88dd1703f4939',
    messagingSenderId: '408590004796',
    projectId: 'vedicpurohit-d68c1',
    databaseURL: 'https://vedicpurohit-d68c1-default-rtdb.firebaseio.com',
    storageBucket: 'vedicpurohit-d68c1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCwcFAC4LHauQvAupXO-n_6EJYF4Onupfo',
    appId: '1:408590004796:ios:69389aa453aefe0b3f4939',
    messagingSenderId: '408590004796',
    projectId: 'vedicpurohit-d68c1',
    databaseURL: 'https://vedicpurohit-d68c1-default-rtdb.firebaseio.com',
    storageBucket: 'vedicpurohit-d68c1.firebasestorage.app',
    androidClientId: '408590004796-050hfub1kl5gj6p99b6at1g0vpfr7irg.apps.googleusercontent.com',
    iosBundleId: 'com.example.kotlinTest',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCwcFAC4LHauQvAupXO-n_6EJYF4Onupfo',
    appId: '1:408590004796:ios:69389aa453aefe0b3f4939',
    messagingSenderId: '408590004796',
    projectId: 'vedicpurohit-d68c1',
    databaseURL: 'https://vedicpurohit-d68c1-default-rtdb.firebaseio.com',
    storageBucket: 'vedicpurohit-d68c1.firebasestorage.app',
    androidClientId: '408590004796-050hfub1kl5gj6p99b6at1g0vpfr7irg.apps.googleusercontent.com',
    iosBundleId: 'com.example.kotlinTest',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCPuR2GVUE-I4OvxTtz2XxLM8Lo17uga7A',
    appId: '1:408590004796:web:0ce2083bdfed32943f4939',
    messagingSenderId: '408590004796',
    projectId: 'vedicpurohit-d68c1',
    authDomain: 'vedicpurohit-d68c1.firebaseapp.com',
    databaseURL: 'https://vedicpurohit-d68c1-default-rtdb.firebaseio.com',
    storageBucket: 'vedicpurohit-d68c1.firebasestorage.app',
    measurementId: 'G-VD8KNB16PR',
  );
}
