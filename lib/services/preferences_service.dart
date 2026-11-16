import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_exception.dart';

class PreferencesService extends ChangeNotifier {
  PreferencesService(this._preferences)
    : _escuro = _preferences.getBool('tema_escuro') ?? false;

  final SharedPreferences _preferences;
  bool _escuro;
  bool get escuro => _escuro;
  ThemeMode get themeMode => _escuro ? ThemeMode.dark : ThemeMode.light;

  Future<void> definirTema(bool escuro) async {
    final salvo = await _preferences.setBool('tema_escuro', escuro);
    if (!salvo) {
      throw const AppException(
        'Não foi possível salvar sua preferência de tema.',
      );
    }
    _escuro = escuro;
    notifyListeners();
  }
}
