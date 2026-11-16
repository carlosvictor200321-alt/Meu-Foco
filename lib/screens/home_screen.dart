import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import '../services/app_exception.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_scope.dart';
import '../widgets/common.dart';
import '../widgets/tarefa_card.dart';
import 'cadastro_tarefa_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final controller = scope.tarefas!;
    final theme = Theme.of(context);
    return AppScaffold(
      titulo: 'Início',
      rota: '/inicio',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => const CadastroTarefaScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova tarefa'),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final total = controller.tarefas.length;
          final recentes = controller.tarefas.take(3).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 104),
            children: [
              Text(
                DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(DateTime.now()),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Olá, ${scope.usuario!.primeiroNome}.',
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Vamos dar espaço ao que importa hoje?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 26),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF285B46),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.wb_sunny_outlined,
                          color: Color(0xFFE8D7A8),
                          size: 20,
                        ),
                        const SizedBox(width: 9),
                        const Expanded(
                          child: Text(
                            'UM PASSO DE CADA VEZ',
                            style: TextStyle(
                              color: Color(0xFFE3EEDD),
                              fontSize: 10,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (scope.emulador)
                          const Text(
                            'TESTE LOCAL',
                            style: TextStyle(
                              color: Color(0xFFE3EEDD),
                              fontSize: 9,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Pequenos passos.\nGrandes dias.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                        letterSpacing: -.6,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      total == 0
                          ? 'Sua próxima conquista começa com uma tarefa.'
                          : controller.pendentes == 0
                          ? 'Tudo em dia. Aproveite esse respiro!'
                          : 'Você tem ${controller.pendentes} tarefa(s) pendente(s). Você consegue.',
                      style: const TextStyle(
                        color: Color(0xFFE3EEDD),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Seu progresso',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Text(
                          '${total == 0 ? 0 : (controller.concluidas / total * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : controller.concluidas / total,
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: .16),
                        color: const Color(0xFFD3DDA4),
                        semanticsLabel: 'Progresso das tarefas',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Resumo(
                    label: 'Cadastradas',
                    valor: total,
                    icone: Icons.layers_outlined,
                    onTap: () => Navigator.pushNamed(context, '/tarefas'),
                  ),
                  const SizedBox(width: 10),
                  _Resumo(
                    label: 'Pendentes',
                    valor: controller.pendentes,
                    icone: Icons.timelapse_rounded,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/tarefas',
                      arguments: 'pendentes',
                    ),
                  ),
                  const SizedBox(width: 10),
                  _Resumo(
                    label: 'Concluídas',
                    valor: controller.concluidas,
                    icone: Icons.task_alt_rounded,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/tarefas',
                      arguments: 'concluidas',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('No seu radar', style: theme.textTheme.titleLarge),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/tarefas'),
                    child: const Text('Ver todas'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (controller.carregando)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (controller.erro != null)
                PainelEstado(
                  icone: Icons.cloud_off_rounded,
                  titulo: 'Não foi possível carregar',
                  descricao: mensagemErro(controller.erro!),
                  rotuloAcao: 'Tentar novamente',
                  acao: controller.carregar,
                )
              else if (recentes.isEmpty)
                PainelEstado(
                  icone: Icons.playlist_add_check_rounded,
                  titulo: 'Um novo começo',
                  descricao: 'Adicione sua primeira tarefa e tire seus planos do papel.',
                )
              else
                ...recentes.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TarefaCard(t, key: ValueKey(t.id)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Resumo extends StatelessWidget {
  const _Resumo({
    required this.label,
    required this.valor,
    required this.icone,
    required this.onTap,
  });
  final String label;
  final int valor;
  final IconData icone;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icone,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text('$valor', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
