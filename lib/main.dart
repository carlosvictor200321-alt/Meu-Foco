import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/auth_service.dart';
import 'services/firebase_bootstrap.dart';
import 'services/firebase_service.dart';
import 'services/preferences_service.dart';
import 'themes/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _InicializarApp());
}

class _InicializarApp extends StatefulWidget {
  const _InicializarApp();
  @override
  State<_InicializarApp> createState() => _InicializarAppState();
}

class _InicializarAppState extends State<_InicializarApp> {
  late Future<PreferencesService> _inicializacao = _inicializar();

  Future<PreferencesService> _inicializar() async {
    await initializeDateFormatting('pt_BR');
    await FirebaseBootstrap.inicializar();
    return PreferencesService(await SharedPreferences.getInstance());
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _inicializacao,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return MeuFocoApp(
          auth: AuthService(FirebaseAuth.instance),
          preferences: snapshot.data!,
          criarTarefas: (usuario) =>
              FirebaseService(FirebaseDatabase.instance, usuario.uid),
          emulador: FirebaseBootstrap.emulador,
        );
      }
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: snapshot.hasError
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.settings_suggest_outlined, size: 48),
                          const SizedBox(height: 20),
                          const Text(
                            'Vamos preparar sua conexão',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Confira a configuração do Firebase e tente abrir o aplicativo novamente.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: () =>
                                setState(() => _inicializacao = _inicializar()),
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      );
    },
  );
}
