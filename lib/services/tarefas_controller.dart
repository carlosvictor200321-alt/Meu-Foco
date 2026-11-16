import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/tarefa.dart';
import 'firebase_service.dart';

class TarefasController extends ChangeNotifier {
  TarefasController(this.service) {
    carregar();
  }
  final TarefasGateway service;
  StreamSubscription<List<Tarefa>>? _subscription;
  List<Tarefa> tarefas = const [];
  bool carregando = true;
  Object? erro;

  int get pendentes => tarefas.where((t) => !t.concluida).length;
  int get concluidas => tarefas.where((t) => t.concluida).length;

  void carregar() {
    _subscription?.cancel();
    carregando = true;
    erro = null;
    _subscription = service.observarTarefas().listen(
      (novas) {
        tarefas = List.unmodifiable(novas);
        carregando = false;
        erro = null;
        notifyListeners();
      },
      onError: (Object e) {
        carregando = false;
        erro = e;
        notifyListeners();
      },
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
