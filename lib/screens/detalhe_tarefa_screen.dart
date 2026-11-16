import 'package:material_ui/material_ui.dart';

import '../models/tarefa.dart';
import '../services/app_exception.dart';
import '../widgets/app_scope.dart';
import '../widgets/common.dart';
import '../widgets/tarefa_card.dart';
import 'cadastro_tarefa_screen.dart';

class DetalheTarefaScreen extends StatefulWidget {
  const DetalheTarefaScreen({super.key, required this.tarefaId});
  final String tarefaId;
  @override
  State<DetalheTarefaScreen> createState() => _DetalheTarefaScreenState();
}

class _DetalheTarefaScreenState extends State<DetalheTarefaScreen> {
  bool _ocupado = false;

  Future<void> _alterar(Tarefa tarefa) async {
    setState(() => _ocupado = true);
    try {
      await AppScope.of(context).tarefas!.service.alterarSituacao(tarefa);
      if (mounted) {
        mostrarMensagem(
          context,
          tarefa.concluida
              ? 'Tarefa marcada como pendente.'
              : 'Mais uma conquista. Tarefa concluída!',
        );
      }
    } catch (e) {
      if (mounted) mostrarMensagem(context, mensagemErro(e), erro: true);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _excluir(Tarefa tarefa) async {
    final service = AppScope.of(context).tarefas!.service;
    final excluir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: Text(
          '“${tarefa.titulo}” será excluída. Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (excluir != true || !mounted) return;
    setState(() => _ocupado = true);
    try {
      await service.excluir(tarefa);
      if (mounted) {
        Navigator.pop(context);
        mostrarMensagem(context, 'Tarefa excluída.');
      }
    } catch (e) {
      if (mounted) mostrarMensagem(context, mensagemErro(e), erro: true);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).tarefas!;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da tarefa')),
      body: SafeArea(
        child: ConteudoCentral(
          maxWidth: 620,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final index = controller.tarefas.indexWhere(
                (t) => t.id == widget.tarefaId,
              );
              if (index == -1) {
                return const PainelEstado(
                  icone: Icons.task_alt_rounded,
                  titulo: 'Esta tarefa não está mais aqui',
                  descricao: 'Volte à lista para ver suas tarefas atuais.',
                );
              }
              final t = controller.tarefas[index];
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: PrioridadeBadge(t.prioridade),
                  ),
                  const SizedBox(height: 20),
                  SelectableText(
                    t.titulo,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _Linha(
                            icone: Icons.calendar_month_outlined,
                            rotulo: 'Vencimento',
                            valor: formatarData(t.dataVencimento),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(),
                          ),
                          _Linha(
                            icone: t.concluida
                                ? Icons.task_alt_rounded
                                : Icons.timelapse_rounded,
                            rotulo: 'Situação',
                            valor: t.concluida ? 'Concluída' : 'Pendente',
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (t.atrasadaEm(DateTime.now()))
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Text(
                        'Esta tarefa está atrasada. Você pode ajustar o vencimento.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 28),
                  Text(
                    'Descrição',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  SelectableText(
                    t.descricao.isEmpty ? 'Sem descrição.' : t.descricao,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 36),
                  BotaoCarregando(
                    carregando: _ocupado,
                    rotulo: t.concluida
                        ? 'Marcar como pendente'
                        : 'Marcar como concluída',
                    icone: t.concluida
                        ? Icons.undo_rounded
                        : Icons.check_rounded,
                    onPressed: () => _alterar(t),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: _ocupado
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => CadastroTarefaScreen(tarefa: t),
                            ),
                          ),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar tarefa'),
                  ),
                  const SizedBox(height: 14),
                  TextButton.icon(
                    onPressed: _ocupado ? null : () => _excluir(t),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Excluir tarefa'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({
    required this.icone,
    required this.rotulo,
    required this.valor,
  });
  final IconData icone;
  final String rotulo;
  final String valor;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icone, color: Theme.of(context).colorScheme.primary, size: 23),
      const SizedBox(width: 14),
      Expanded(child: Text(rotulo)),
      Text(valor, style: const TextStyle(fontWeight: FontWeight.w700)),
    ],
  );
}
