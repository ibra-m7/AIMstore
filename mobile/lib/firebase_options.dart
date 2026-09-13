// إعدادات Firebase لمشروع AIMstore (aimstore-d17a3)
// Android: من google-services.json
// iOS: سجّل تطبيق iOS في Firebase ثم حدّث القيم من GoogleService-Info.plist

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions غير مدعوم لهذه المنصة.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAGATqhDidV5DQItQ0VuCYFNh-F-WDOj2c',
    appId: '1:474286441573:android:59c4dc8d2e489be0c5f28c',
    messagingSenderId: '474286441573',
    projectId: 'aimstore-d17a3',
    storageBucket: 'aimstore-d17a3.firebasestorage.app',
  );

  /// يحتاج تسجيل تطبيق iOS في Firebase وتنزيل GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAGATqhDidV5DQItQ0VuCYFNh-F-WDOj2c',
    appId: 'REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '474286441573',
    projectId: 'aimstore-d17a3',
    storageBucket: 'aimstore-d17a3.firebasestorage.app',
    iosBundleId: 'com.aim.aimstore',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAGATqhDidV5DQItQ0VuCYFNh-F-WDOj2c',
    appId: 'REPLACE_WITH_WEB_APP_ID',
    messagingSenderId: '474286441573',
    projectId: 'aimstore-d17a3',
    storageBucket: 'aimstore-d17a3.firebasestorage.app',
    authDomain: 'aimstore-d17a3.firebaseapp.com',
  );
}
