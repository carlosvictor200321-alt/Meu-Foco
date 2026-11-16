import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meu_foco/models/tarefa.dart';
import 'package:meu_foco/models/usuario.dart';
import 'package:meu_foco/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meu_foco/services/app_exception.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('erro real de credenciais do Firebase é apresentado em português', () {
    expect(
      mensagemErro(FirebaseAuthException(code: 'invalid-login-credentials')),
      'E-mail ou senha incorretos. Confira e tente novamente.',
    );
  });
  test('Tarefa preserva todos os campos no Realtime Database', () {
    final original = Tarefa(
      id: '-tarefa1',
      titulo: 'Estudar Flutter',
      descricao: 'Revisar Models e Firebase.',
      dataVencimento: DateTime(2026, 11, 20),
      prioridade: Prioridade.alta,
      concluida: false,
    );
    final mapa = original.toMap();
    expect(mapa['dataVencimento'], '2026-11-20');
    expect(Tarefa.fromMap(original.id, mapa).toMap(), original.toMap());
    expect(original.copyWith(concluida: true).toMap()['concluida'], true);
    expect(original.concluida, false);
  });
  test('vencimento considera o dia completo e ignora tarefas concluídas', () {
    final tarefa = Tarefa(
      id: '1',
      titulo: 'Prazo',
      descricao: 'Teste',
      dataVencimento: DateTime(2026, 11, 16),
      prioridade: Prioridade.media,
      concluida: false,
    );
    expect(tarefa.atrasadaEm(DateTime(2026, 11, 16, 23, 59)), false);
    expect(tarefa.atrasadaEm(DateTime(2026, 11, 17)), true);
    expect(
      tarefa.copyWith(concluida: true).atrasadaEm(DateTime(2026, 11, 17)),
      false,
    );
  });
  test('SharedPreferences restaura tema ao recriar o serviço', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final primeiro = PreferencesService(prefs);
    expect(primeiro.themeMode, ThemeMode.light);
    await primeiro.definirTema(true);
    expect(
      PreferencesService(await SharedPreferences.getInstance()).themeMode,
      ThemeMode.dark,
    );
    await primeiro.definirTema(false);
    expect(PreferencesService(prefs).themeMode, ThemeMode.light);
  });
  test('Usuario apresenta nome e iniciais', () {
    const usuario = Usuario(
      uid: 'u1',
      nome: 'Ana Maria Silva',
      email: 'ana@exemplo.com',
    );
    expect(usuario.primeiroNome, 'Ana');
    expect(usuario.iniciais, 'AM');
  });
}
