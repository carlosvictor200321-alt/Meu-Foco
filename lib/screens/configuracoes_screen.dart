import 'package:material_ui/material_ui.dart';

import '../services/app_exception.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_scope.dart';
import '../widgets/common.dart';

class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final preferences = scope.preferences;
    final theme = Theme.of(context);
    return AppScaffold(
      titulo: 'Configurações',
      rota: '/configuracoes',
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Do seu jeito.', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 10),
          const Text('Um espaço confortável para a sua rotina.'),
          const SizedBox(height: 32),
          Text(
            'APARÊNCIA',
            style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 1.5),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile.adaptive(
              key: const ValueKey('tema-escuro'),
              value: preferences.escuro,
              secondary: Icon(
                preferences.escuro
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
              ),
              title: const Text('Tema escuro'),
              subtitle: Text(
                preferences.escuro
                    ? 'Ativado em todas as telas.'
                    : 'O tema claro está ativado.',
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              onChanged: (escuro) async {
                try {
                  await preferences.definirTema(escuro);
                } catch (e) {
                  if (context.mounted) {
                    mostrarMensagem(context, mensagemErro(e), erro: true);
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Sua escolha será lembrada quando você abrir o aplicativo novamente.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'SUA CONTA',
            style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 1.5),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scope.usuario!.nome, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  SelectableText(scope.usuario!.email),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lock_person_outlined,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Somente você pode acessar e alterar suas tarefas.',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'ARMAZENAMENTO',
            style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 1.5),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              leading: Icon(
                scope.emulador
                    ? Icons.computer_outlined
                    : Icons.cloud_done_outlined,
              ),
              title: Text(
                scope.emulador
                    ? 'Ambiente de teste local'
                    : 'Firebase na nuvem',
              ),
              subtitle: Text(
                scope.emulador
                    ? 'Os dados ficam nos emuladores deste computador. Conecte seu projeto Firebase para usar a nuvem.'
                    : 'Suas tarefas são atualizadas em tempo real no Realtime Database.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
