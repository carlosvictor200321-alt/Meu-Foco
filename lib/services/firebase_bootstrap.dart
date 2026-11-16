import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

abstract final class FirebaseBootstrap {
  static const emulador = bool.fromEnvironment('USE_FIREBASE_EMULATOR');

  static Future<void> inicializar() async {
    const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
    const appId = String.fromEnvironment('FIREBASE_APP_ID');
    const databaseUrl = String.fromEnvironment('FIREBASE_DATABASE_URL');
    FirebaseOptions options;
    if (emulador) {
      options = const FirebaseOptions(
        apiKey: 'demo-api-key-meu-foco',
        appId: '1:1234567890:android:1234567890abcdef123456',
        messagingSenderId: '1234567890',
        projectId: 'demo-meu-foco',
        databaseURL: 'https://demo-meu-foco-default-rtdb.firebaseio.com',
      );
    } else if (apiKey.isNotEmpty) {
      if (appId.isEmpty || databaseUrl.isEmpty) {
        throw StateError('A configuração do Firebase está incompleta.');
      }
      options = const FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
        messagingSenderId: String.fromEnvironment(
          'FIREBASE_MESSAGING_SENDER_ID',
        ),
        databaseURL: databaseUrl,
        authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
      );
    } else {
      options = DefaultFirebaseOptions.currentPlatform;
    }
    if (Firebase.apps.isEmpty) await Firebase.initializeApp(options: options);
    if (emulador) {
      const hostOverride = String.fromEnvironment('FIREBASE_EMULATOR_HOST');
      final host = hostOverride.isNotEmpty
          ? hostOverride
          : (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
          ? '10.0.2.2'
          : '127.0.0.1';
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      FirebaseDatabase.instance.useDatabaseEmulator(host, 9000);
    }
    if (!kIsWeb) {
      FirebaseDatabase.instance.setPersistenceEnabled(true);
    } else {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    }
    await FirebaseAuth.instance.setLanguageCode('pt-BR');
  }
}
