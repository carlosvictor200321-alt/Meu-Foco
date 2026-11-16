import 'package:material_ui/material_ui.dart';

import 'app_scope.dart';
import 'common.dart';
import 'drawer_menu.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.titulo,
    required this.rota,
    required this.body,
    this.floatingActionButton,
  });
  final String titulo;
  final String rota;
  final Widget body;
  final Widget? floatingActionButton;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: rota == '/inicio' ? const Marca() : Text(titulo),
      actions: [
        const BotaoTema(),
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 20),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              AppScope.of(context).usuario!.iniciais,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ],
    ),
    drawer: DrawerMenu(selecionado: rota),
    floatingActionButton: floatingActionButton,
    body: SafeArea(child: ConteudoCentral(child: body)),
  );
}
