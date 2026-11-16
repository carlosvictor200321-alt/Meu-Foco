import 'package:firebase_database/firebase_database.dart';

import '../models/tarefa.dart';

abstract class TarefasGateway {
  Stream<List<Tarefa>> observarTarefas();
  Future<void> salvar(Tarefa tarefa);
  Future<void> excluir(Tarefa tarefa);
  Future<void> alterarSituacao(Tarefa tarefa);
}

/// Cada instância aponta exclusivamente para o UID da sessão atual.
/// As regras do Realtime Database também verificam esse UID no servidor.
class FirebaseService implements TarefasGateway {
  FirebaseService(FirebaseDatabase database, String uid)
    : _referencia = database.ref('usuarios/$uid/tarefas');

  final DatabaseReference _referencia;

  @override
  Stream<List<Tarefa>> observarTarefas() => _referencia.onValue.map((evento) {
    final valor = evento.snapshot.value;
    if (valor == null) return <Tarefa>[];
    final registros = Map<Object?, Object?>.from(valor as Map);
    return registros.entries.map((registro) {
      return Tarefa.fromMap(
        registro.key.toString(),
        Map<Object?, Object?>.from(registro.value as Map),
      );
    }).toList()..sort((a, b) {
      final situacao = (a.concluida ? 1 : 0).compareTo(b.concluida ? 1 : 0);
      if (situacao != 0) return situacao;
      final data = a.dataVencimento.compareTo(b.dataVencimento);
      if (data != 0) return data;
      return b.prioridade.index.compareTo(a.prioridade.index);
    });
  });

  @override
  Future<void> salvar(Tarefa tarefa) async {
    final ref = tarefa.id.isEmpty
        ? _referencia.push()
        : _referencia.child(tarefa.id);
    await ref.set(tarefa.copyWith(id: ref.key!).toMap());
  }

  @override
  Future<void> excluir(Tarefa tarefa) => _referencia.child(tarefa.id).remove();

  @override
  Future<void> alterarSituacao(Tarefa tarefa) =>
      _referencia.child(tarefa.id).update({'concluida': !tarefa.concluida});
}
