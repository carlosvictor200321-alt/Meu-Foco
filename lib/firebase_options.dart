import 'package:firebase_core/firebase_core.dart';

/// Substituído automaticamente por scripts/configurar-firebase.ps1.
abstract final class DefaultFirebaseOptions {
  static const configurado = false;
  static FirebaseOptions get currentPlatform => throw StateError(
    'Conecte seu projeto Firebase com scripts/configurar-firebase.ps1 '
    'ou execute com USE_FIREBASE_EMULATOR=true para desenvolvimento local.',
  );
}
