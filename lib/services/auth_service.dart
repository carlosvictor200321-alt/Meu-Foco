import 'package:firebase_auth/firebase_auth.dart';

import '../models/usuario.dart';

abstract class AuthGateway {
  Stream<Usuario?> get alteracoesUsuario;
  Future<void> cadastrar(String nome, String email, String senha);
  Future<void> entrar(String email, String senha);
  Future<void> sair();
  Future<void> recuperarSenha(String email);
}

class AuthService implements AuthGateway {
  AuthService(this._auth);
  final FirebaseAuth _auth;

  @override
  Stream<Usuario?> get alteracoesUsuario => _auth.userChanges().map(
    (user) => user == null
        ? null
        : Usuario(
            uid: user.uid,
            nome: (user.displayName?.trim().isNotEmpty ?? false)
                ? user.displayName!
                : 'Usuário',
            email: user.email ?? '',
          ),
  );

  @override
  Future<void> cadastrar(String nome, String email, String senha) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
    await credential.user!.updateDisplayName(nome.trim());
    await credential.user!.reload();
  }

  @override
  Future<void> entrar(String email, String senha) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
  }

  @override
  Future<void> sair() => _auth.signOut();

  @override
  Future<void> recuperarSenha(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());
}
