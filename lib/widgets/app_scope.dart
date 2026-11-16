import 'package:material_ui/material_ui.dart';

import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../services/preferences_service.dart';
import '../services/tarefas_controller.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.auth,
    required this.preferences,
    required this.usuario,
    required this.tarefas,
    required this.emulador,
    required super.child,
  });

  final AuthGateway auth;
  final PreferencesService preferences;
  final Usuario? usuario;
  final TarefasController? tarefas;
  final bool emulador;

  static AppScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!;

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      usuario != oldWidget.usuario ||
      tarefas != oldWidget.tarefas ||
      emulador != oldWidget.emulador;
}
