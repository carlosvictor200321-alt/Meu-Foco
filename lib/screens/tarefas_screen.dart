import 'package:material_ui/material_ui.dart';

import '../models/tarefa.dart';
import '../services/app_exception.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/app_scope.dart';
import '../widgets/common.dart';
import '../widgets/tarefa_card.dart';
import 'cadastro_tarefa_screen.dart';

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({super.key});
  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  final _busca = TextEditingController();
  String _filtro = 'todas';
  Prioridade? _prioridade;
  bool _inicializado = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inicializado) {
      _filtro =
          ModalRoute.of(context)?.settings.arguments as String? ?? 'todas';
      _inicializado = true;
    }
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).tarefas!;
    void novaTarefa() => Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const CadastroTarefaScreen()),
    );
    return AppScaffold(
      titulo: 'Minhas tarefas',
      rota: '/tarefas',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: novaTarefa,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova tarefa'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Um plano para\ncada conquista.',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                const Text('Organize, acompanhe e celebre seus passos.'),
                const SizedBox(height: 24),
                TextField(
                  controller: _busca,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Buscar tarefas',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _busca.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpar busca',
                            onPressed: () => setState(() => _busca.clear()),
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final filtro in const {
                      'todas': 'Todas',
                      'pendentes': 'Pendentes',
                      'concluidas': 'Concluídas',
                    }.entries)
                      ChoiceChip(
                        label: Text(filtro.value),
                        selected: _filtro == filtro.key,
                        onSelected: (_) => setState(() => _filtro = filtro.key),
                      ),
                    PopupMenuButton<Prioridade?>(
                      tooltip: 'Filtrar por prioridade',
                      initialValue: _prioridade,
                      onSelected: (p) => setState(() => _prioridade = p),
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: null,
                          child: Text('Todas as prioridades'),
                        ),
                        ...Prioridade.values.map(
                          (p) => PopupMenuItem(
                            value: p,
                            child: Text('Prioridade ${p.rotulo.toLowerCase()}'),
                          ),
                        ),
                      ],
                      child: Chip(
                        avatar: const Icon(Icons.filter_list_rounded, size: 18),
                        label: Text(_prioridade?.rotulo ?? 'Prioridade'),
                      ),
                    ),
                  ],
                ),
                if (_prioridade != null)
                  TextButton.icon(
                    onPressed: () => setState(() => _prioridade = null),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Limpar prioridade'),
                  ),
                const SizedBox(height: 14),
              ],
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                if (controller.carregando) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.erro != null) {
                  return ListView(
                    children: [
                      PainelEstado(
                        icone: Icons.cloud_off_rounded,
                        titulo: 'Não foi possível carregar',
                        descricao: mensagemErro(controller.erro!),
                        acao: controller.carregar,
                        rotuloAcao: 'Tentar novamente',
                      ),
                    ],
                  );
                }
                final query = _busca.text.trim().toLowerCase();
                final tarefas = controller.tarefas
                    .where(
                      (t) =>
                          (_filtro == 'todas' ||
                              (_filtro == 'pendentes'
                                  ? !t.concluida
                                  : t.concluida)) &&
                          (_prioridade == null ||
                              t.prioridade == _prioridade) &&
                          (query.isEmpty ||
                              t.titulo.toLowerCase().contains(query) ||
                              t.descricao.toLowerCase().contains(query)),
                    )
                    .toList();
                if (tarefas.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      PainelEstado(
                        icone: controller.tarefas.isEmpty
                            ? Icons.playlist_add_rounded
                            : Icons.search_off_rounded,
                        titulo: controller.tarefas.isEmpty
                            ? 'Seus planos moram aqui'
                            : 'Nenhuma tarefa por aqui',
                        descricao: controller.tarefas.isEmpty
                            ? 'Adicione sua primeira tarefa para começar.'
                            : 'Experimente outra busca ou altere os filtros.',
                        acao: controller.tarefas.isEmpty ? novaTarefa : null,
                        rotuloAcao: 'Criar primeira tarefa',
                      ),
                    ],
                  );
                }
                return ListView.separated(
                  key: const ValueKey('lista-tarefas'),
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 100),
                  itemCount: tarefas.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (_, index) => TarefaCard(
                    tarefas[index],
                    key: ValueKey(tarefas[index].id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
