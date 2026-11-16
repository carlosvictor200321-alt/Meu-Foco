// Configurações públicas dos aplicativos registrados no Firebase.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

abstract final class DefaultFirebaseOptions {
  static const configurado = true;
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    return defaultTargetPlatform == TargetPlatform.iOS ? ios : android;
  }

  static const android = FirebaseOptions(
    projectId: "gerenciamento-de-tarefas-2f419",
    databaseURL:
        "https://gerenciamento-de-tarefas-2f419-default-rtdb.firebaseio.com",
    messagingSenderId: "616568726742",
    apiKey: "AIzaSyBAs-NgtTMIZILBa6b9cS-7YoSdA9jI4xc",
    appId: "1:616568726742:android:78687764de0470704ad577",
  );

  static const ios = FirebaseOptions(
    projectId: "gerenciamento-de-tarefas-2f419",
    databaseURL:
        "https://gerenciamento-de-tarefas-2f419-default-rtdb.firebaseio.com",
    messagingSenderId: "616568726742",
    apiKey: "AIzaSyDxC6bmYI-umvmDljTPoqjzW5XuH050c2A",
    appId: "1:616568726742:ios:757bab06291ee9554ad577",
    iosBundleId: "br.com.meufoco.meuFoco",
  );

  static const web = FirebaseOptions(
    projectId: "gerenciamento-de-tarefas-2f419",
    databaseURL:
        "https://gerenciamento-de-tarefas-2f419-default-rtdb.firebaseio.com",
    messagingSenderId: "616568726742",
    apiKey: "AIzaSyA8CrtehhrMPvHciys_329MHyY1BD0Upx4",
    appId: "1:616568726742:web:bfd1ac02c467be304ad577",
    authDomain: "gerenciamento-de-tarefas-2f419.firebaseapp.com",
  );
}
