import 'package:firebase_core/firebase_core.dart';

class AppException implements Exception {
  const AppException(this.mensagem);
  final String mensagem;
  @override
  String toString() => mensagem;
}

String mensagemErro(Object erro) {
  if (erro is AppException) return erro.mensagem;
  if (erro is FirebaseException) {
    return switch (erro.code) {
      'invalid-email' => 'Informe um e-mail válido.',
      'email-already-in-use' =>
        'Este e-mail já tem uma conta. Entre para continuar.',
      'weak-password' => 'Use uma senha com pelo menos 6 caracteres.',
      'invalid-credential' ||
      'invalid-login-credentials' ||
      'wrong-password' ||
      'user-not-found' =>
        'E-mail ou senha incorretos. Confira e tente novamente.',
      'user-disabled' => 'Esta conta está desativada.',
      'too-many-requests' =>
        'Muitas tentativas. Aguarde um pouco e tente novamente.',
      'network-request-failed' || 'unavailable' =>
        'Não foi possível conectar. Verifique sua conexão e tente novamente.',
      'operation-not-allowed' =>
        'O login por e-mail e senha precisa ser ativado no Firebase.',
      'permission-denied' || 'permission_denied' =>
        'Acesso não permitido. Confira sua sessão e as regras do banco.',
      _ => 'Não foi possível concluir a operação. Tente novamente.',
    };
  }
  return 'Não foi possível concluir a operação. Tente novamente.';
}
