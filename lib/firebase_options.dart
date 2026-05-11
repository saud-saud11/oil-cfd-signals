import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCz_KdPmeURGe6F_d2dQfMknODmz4aoFPA',
    appId: '1:873181555730:web:62d8a50914264e459ebccb',
    messagingSenderId: '873181555730',
    projectId: 'oil-cfd-signals',
    authDomain: 'oil-cfd-signals.firebaseapp.com',
    storageBucket: 'oil-cfd-signals.firebasestorage.app',
  );
}
