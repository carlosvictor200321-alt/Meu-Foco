import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meu_foco/app.dart';
import 'package:meu_foco/models/tarefa.dart';
import 'package:meu_foco/models/usuario.dart';
import 'package:meu_foco/services/auth_service.dart';
import 'package:meu_foco/services/firebase_service.dart';
import 'package:meu_foco/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthTeste implements AuthGateway {
  final eventos = StreamController<Usuario?>.broadcast();
  Usuario? usuario;
  @override
  Stream<Usuario?> get alteracoesUsuario async* {
    yield usuario;
    yield* eventos.stream;
  }

  @override
  Future<void> cadastrar(String nome, String email, String senha) async {
    usuario = Usuario(uid: email, nome: nome, email: email);
    eventos.add(usuario);
  }

  @override
  Future<void> entrar(String email, String senha) async {
    usuario = Usuario(uid: email, nome: 'Ana Maria', email: email);
    eventos.add(usuario);
  }

  @override
  Future<void> sair() async {
    usuario = null;
    eventos.add(null);
  }

  @override
  Future<void> recuperarSenha(String email) async {}
}

class TarefasTeste implements TarefasGateway {
  final eventos = StreamController<List<Tarefa>>.broadcast();
  final List<Tarefa> tarefas = [];
  int id = 0;
  @override
  Stream<List<Tarefa>> observarTarefas() async* {
    yield List.of(tarefas);
    yield* eventos.stream;
  }

  @override
  Future<void> salvar(Tarefa tarefa) async {
    if (tarefa.id.isEmpty) {
      tarefas.add(tarefa.copyWith(id: '${++id}'));
    } else {
      tarefas[tarefas.indexWhere((t) => t.id == tarefa.id)] = tarefa;
    }
    eventos.add(List.of(tarefas));
  }

  @override
  Future<void> excluir(Tarefa tarefa) async {
    tarefas.removeWhere((t) => t.id == tarefa.id);
    eventos.add(List.of(tarefas));
  }

  @override
  Future<void> alterarSituacao(Tarefa tarefa) =>
      salvar(tarefa.copyWith(concluida: !tarefa.concluida));
}

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
    final font = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter.ttf'));
    await font.load();
  });
  Future<
    ({AuthTeste auth, TarefasTeste tarefas, PreferencesService preferences})
  >
  iniciar(WidgetTester tester, {bool autenticado = false}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final preferences = PreferencesService(
      await SharedPreferences.getInstance(),
    );
    final auth = AuthTeste();
    final tarefas = TarefasTeste();
    if (autenticado) {
      auth.usuario = const Usuario(
        uid: 'ana',
        nome: 'Ana Maria',
        email: 'ana@exemplo.com',
      );
    }
    await tester.pumpWidget(
      MeuFocoApp(
        auth: auth,
        preferences: preferences,
        criarTarefas: (_) => tarefas,
      ),
    );
    await tester.pumpAndSettle();
    addTearDown(auth.eventos.close);
    addTearDown(tarefas.eventos.close);
    return (auth: auth, tarefas: tarefas, preferences: preferences);
  }

  Future<void> abrirMenu(WidgetTester tester, String destino) async {
    await tester.tap(find.byType(DrawerButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(destino));
    await tester.pumpAndSettle();
  }

  testWidgets('login valida e-mail e senha obrigatórios', (tester) async {
    await iniciar(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Informe seu e-mail.'), findsOneWidget);
    expect(find.text('Informe sua senha.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'invalido',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pumpAndSettle();
    expect(find.text('Informe um e-mail válido.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('cadastro valida confirmação e abre início com nome', (
    tester,
  ) async {
    await iniciar(tester);
    await tester.ensureVisible(find.text('Criar conta'));
    await tester.tap(find.text('Criar conta'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('cadastro-nome')),
      'Ana Maria',
    );
    await tester.enterText(
      find.byKey(const ValueKey('cadastro-email')),
      'ana@exemplo.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('cadastro-senha')),
      'senha123',
    );
    await tester.enterText(
      find.byKey(const ValueKey('cadastro-confirmacao')),
      'outra123',
    );
    await tester.ensureVisible(find.text('Criar minha conta'));
    await tester.tap(find.text('Criar minha conta'));
    await tester.pumpAndSettle();
    expect(find.text('As senhas precisam ser iguais.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('cadastro-confirmacao')),
      'senha123',
    );
    await tester.ensureVisible(find.text('Criar minha conta'));
    await tester.tap(find.text('Criar minha conta'));
    await tester.pumpAndSettle();
    expect(find.text('Olá, Ana.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('CRUD de duas tarefas, situação e filtros', (tester) async {
    final fixture = await iniciar(tester, autenticado: true);
    for (final titulo in ['Estudar Flutter', 'Entregar atividade']) {
      await tester.tap(find.text('Nova tarefa'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('tarefa-titulo')),
        titulo,
      );
      await tester.enterText(
        find.byKey(const ValueKey('tarefa-descricao')),
        'Descrição de $titulo',
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Alta'));
      await tester.tap(find.widgetWithText(ChoiceChip, 'Alta'));
      await tester.ensureVisible(find.text('Criar tarefa'));
      await tester.tap(find.text('Criar tarefa'));
      await tester.pumpAndSettle();
    }
    expect(fixture.tarefas.tarefas.length, 2);
    expect(
      fixture.tarefas.tarefas.every((t) => t.prioridade == Prioridade.alta),
      true,
    );
    await abrirMenu(tester, 'Minhas tarefas');
    expect(find.byKey(const ValueKey('lista-tarefas')), findsOneWidget);
    await tester.tap(find.text('Estudar Flutter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar tarefa'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('tarefa-titulo')),
      'Revisar Flutter',
    );
    await tester.ensureVisible(find.text('Salvar alterações'));
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();
    expect(find.text('Revisar Flutter'), findsOneWidget);
    await tester.tap(find.text('Marcar como concluída'));
    await tester.pumpAndSettle();
    expect(find.text('Marcar como pendente'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Concluídas'));
    await tester.pumpAndSettle();
    expect(find.text('Revisar Flutter'), findsOneWidget);
    expect(find.text('Entregar atividade'), findsNothing);
    await tester.tap(find.text('Revisar Flutter'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Excluir tarefa'));
    await tester.tap(find.text('Excluir tarefa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(fixture.tarefas.tarefas.length, 2);
    await tester.tap(find.text('Excluir tarefa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    expect(fixture.tarefas.tarefas.length, 1);
    expect(tester.takeException(), isNull);
  });
  testWidgets('formulário protege alterações não salvas', (tester) async {
    await iniciar(tester, autenticado: true);
    await tester.tap(find.text('Nova tarefa'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('tarefa-titulo')),
      'Meu plano',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Descartar alterações?'), findsOneWidget);
    await tester.tap(find.text('Continuar editando'));
    await tester.pumpAndSettle();
    expect(find.text('Meu plano'), findsOneWidget);
    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Descartar'));
    await tester.pumpAndSettle();
    expect(find.text('Olá, Ana.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('tema persiste e logout descarta rotas da conta', (tester) async {
    final fixture = await iniciar(tester, autenticado: true);
    await abrirMenu(tester, 'Configurações');
    await tester.tap(find.byKey(const ValueKey('tema-escuro')));
    await tester.pumpAndSettle();
    expect(fixture.preferences.escuro, true);
    expect(
      Theme.of(tester.element(find.text('Do seu jeito.'))).brightness,
      Brightness.dark,
    );
    expect(
      PreferencesService(await SharedPreferences.getInstance()).themeMode,
      ThemeMode.dark,
    );
    await abrirMenu(tester, 'Sair');
    await tester.tap(find.widgetWithText(FilledButton, 'Sair'));
    await tester.pumpAndSettle();
    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(find.byType(DrawerButton), findsNothing);
    expect(
      Theme.of(tester.element(find.text('Bem-vindo de volta'))).brightness,
      Brightness.dark,
    );
    expect(tester.takeException(), isNull);
  });
}
