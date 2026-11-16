import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:material_ui/material_ui.dart';

import 'models/usuario.dart';
import 'screens/configuracoes_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/sobre_screen.dart';
import 'screens/tarefas_screen.dart';
import 'services/auth_service.dart';
import 'services/firebase_service.dart';
import 'services/preferences_service.dart';
import 'services/tarefas_controller.dart';
import 'themes/app_theme.dart';
import 'widgets/app_scope.dart';

class MeuFocoApp extends StatefulWidget {
  const MeuFocoApp({
    super.key,
    required this.auth,
    required this.preferences,
    required this.criarTarefas,
    this.emulador = false,
  });
  final AuthGateway auth;
  final PreferencesService preferences;
  final TarefasGateway Function(Usuario usuario) criarTarefas;
  final bool emulador;
  @override
  State<MeuFocoApp> createState() => _MeuFocoAppState();
}

class _MeuFocoAppState extends State<MeuFocoApp> {
  StreamSubscription<Usuario?>? _subscription;
  Usuario? _usuario;
  TarefasController? _tarefas;
  bool _aguardandoSessao = true;
  Object? _erro;

  @override
  void initState() {
    super.initState();
    _ouvirSessao();
  }

  void _ouvirSessao() {
    _subscription?.cancel();
    _subscription = widget.auth.alteracoesUsuario.listen(
      (usuario) {
        if (!mounted) return;
        if (_usuario?.uid != usuario?.uid) {
          _tarefas?.dispose();
          _tarefas = usuario == null
              ? null
              : TarefasController(widget.criarTarefas(usuario));
        }
        setState(() {
          _usuario = usuario;
          _aguardandoSessao = false;
          _erro = null;
        });
      },
      onError: (Object e) {
        if (mounted) {
          setState(() {
            _erro = e;
            _aguardandoSessao = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _tarefas?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.preferences,
    builder: (context, _) => AppScope(
      auth: widget.auth,
      preferences: widget.preferences,
      usuario: _usuario,
      tarefas: _tarefas,
      emulador: widget.emulador,
      child: MaterialApp(
        // Trocar de usuário descarta todas as rotas e dados visuais da sessão anterior.
        key: ValueKey(_usuario?.uid ?? 'sem-sessao'),
        title: 'Meu Foco',
        builder: (context, child) => widget.emulador && kIsWeb
            ? Padding(padding: const EdgeInsets.only(bottom: 42), child: child)
            : child!,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: widget.preferences.themeMode,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: _aguardandoSessao
            ? const Scaffold(body: Center(child: CircularProgressIndicator()))
            : _erro != null
            ? Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        _aguardandoSessao = true;
                        _erro = null;
                      });
                      _ouvirSessao();
                    },
                    child: const Text('Reconectar à sua conta'),
                  ),
                ),
              )
            : _usuario == null
            ? const LoginScreen()
            : const HomeScreen(),
        routes: _usuario == null
            ? const {}
            : {
                '/inicio': (_) => const HomeScreen(),
                '/tarefas': (_) => const TarefasScreen(),
                '/configuracoes': (_) => const ConfiguracoesScreen(),
                '/sobre': (_) => const SobreScreen(),
              },
      ),
    ),
  );
}
