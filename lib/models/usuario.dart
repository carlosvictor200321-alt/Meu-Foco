class Usuario {
  const Usuario({required this.uid, required this.nome, required this.email});

  final String uid;
  final String nome;
  final String email;

  String get primeiroNome => nome.trim().split(' ').first;
  String get iniciais {
    final partes = nome.trim().split(RegExp(r'\s+'));
    return partes
        .take(2)
        .map((p) => p.isEmpty ? '' : p[0])
        .join()
        .toUpperCase();
  }
}
