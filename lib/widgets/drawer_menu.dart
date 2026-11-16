import 'package:material_ui/material_ui.dart';

import '../services/app_exception.dart';
import 'app_scope.dart';
import 'common.dart';

Future<void> confirmarSaida(BuildContext context) async {
  final auth = AppScope.of(context).auth;
  final sair = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Sair da sua conta?'),
      content: const Text(
        'Suas tarefas continuam salvas. Você pode entrar novamente quando quiser.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Sair'),
        ),
      ],
    ),
  );
  if (sair != true) return;
  try {
    await auth.sair();
  } catch (e) {
    if (context.mounted) mostrarMensagem(context, mensagemErro(e), erro: true);
  }
}

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key, required this.selecionado});
  final String selecionado;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final usuario = scope.usuario!;
    final scheme = Theme.of(context).colorScheme;
    void navegar(String rota) {
      final navigator = Navigator.of(context);
      navigator.pop();
      if (selecionado != rota) {
        navigator.pushNamedAndRemoveUntil(rota, (_) => false);
      }
    }

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Marca(grande: true),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: scheme.primaryContainer,
                    child: Text(
                      usuario.iniciais,
                      style: TextStyle(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuario.nome,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          usuario.email,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              child: Divider(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _item(
                    context,
                    'Início',
                    Icons.space_dashboard_outlined,
                    '/inicio',
                    navegar,
                  ),
                  _item(
                    context,
                    'Minhas tarefas',
                    Icons.checklist_rounded,
                    '/tarefas',
                    navegar,
                  ),
                  _item(
                    context,
                    'Configurações',
                    Icons.tune_rounded,
                    '/configuracoes',
                    navegar,
                  ),
                  _item(
                    context,
                    'Sobre o aplicativo',
                    Icons.info_outline_rounded,
                    '/sobre',
                    navegar,
                  ),
                ],
              ),
            ),
            const Divider(indent: 24, endIndent: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: ListTile(
                leading: const Icon(Icons.logout_rounded),
                title: const Text('Sair'),
                onTap: () => confirmarSaida(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
              child: Text(
                'Um passo de cada vez.  •  v1.0.0',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    String label,
    IconData icon,
    String route,
    ValueChanged<String> navegar,
  ) {
    final selected = selecionado == route;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        selected: selected,
        selectedTileColor: scheme.primaryContainer,
        selectedColor: scheme.onPrimaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        leading: Icon(icon),
        title: Text(label),
        onTap: () => navegar(route),
      ),
    );
  }
}
