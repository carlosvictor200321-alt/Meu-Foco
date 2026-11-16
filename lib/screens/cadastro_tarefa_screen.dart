import 'package:material_ui/material_ui.dart';

import '../models/tarefa.dart';
import '../services/app_exception.dart';
import '../widgets/app_scope.dart';
import '../widgets/common.dart';

class CadastroTarefaScreen extends StatefulWidget {
  const CadastroTarefaScreen({super.key, this.tarefa});
  final Tarefa? tarefa;
  @override
  State<CadastroTarefaScreen> createState() => _CadastroTarefaScreenState();
}

class _CadastroTarefaScreenState extends State<CadastroTarefaScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _titulo;
  late final TextEditingController _descricao;
  late DateTime _vencimento;
  late Prioridade _prioridade;
  late bool _concluida;
  bool _salvando = false;
  bool _alterado = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    final tarefa = widget.tarefa;
    _titulo = TextEditingController(text: tarefa?.titulo ?? '');
    _descricao = TextEditingController(text: tarefa?.descricao ?? '');
    final hoje = DateTime.now();
    _vencimento =
        tarefa?.dataVencimento ?? DateTime(hoje.year, hoje.month, hoje.day);
    _prioridade = tarefa?.prioridade ?? Prioridade.media;
    _concluida = tarefa?.concluida ?? false;
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descricao.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _vencimento,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
      helpText: 'Data de vencimento',
    );
    if (data != null) {
      setState(() {
        _vencimento = data;
        _alterado = true;
      });
    }
  }

  Future<void> _salvar() async {
    if (!_form.currentState!.validate() || _salvando) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _salvando = true;
      _erro = null;
    });
    final tarefa = Tarefa(
      id: widget.tarefa?.id ?? '',
      titulo: _titulo.text.trim(),
      descricao: _descricao.text.trim(),
      dataVencimento: _vencimento,
      prioridade: _prioridade,
      concluida: _concluida,
    );
    try {
      await AppScope.of(context).tarefas!.service.salvar(tarefa);
      if (mounted) {
        setState(() {
          _alterado = false;
          _salvando = false;
        });
        Navigator.pop(context);
        mostrarMensagem(
          context,
          widget.tarefa == null
              ? 'Tarefa criada. Um passo a mais!'
              : 'Tarefa atualizada.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = mensagemErro(e);
          _salvando = false;
        });
      }
    }
  }

  Future<void> _voltar() async {
    if (!_alterado) {
      Navigator.pop(context);
      return;
    }
    final descartar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text(
          'As alterações desta tarefa ainda não foram salvas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continuar editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    if (descartar == true && mounted) {
      setState(() => _alterado = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_alterado && !_salvando,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop && !_salvando) _voltar();
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.tarefa == null ? 'Nova tarefa' : 'Editar tarefa'),
        leading: IconButton(
          tooltip: 'Voltar',
          onPressed: _salvando ? null : _voltar,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: ConteudoCentral(
          maxWidth: 620,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tarefa == null
                        ? 'Dê o primeiro passo.'
                        : 'Ajuste seu plano.',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Um plano claro deixa o caminho mais leve.'),
                  const SizedBox(height: 28),
                  if (_erro != null) AvisoFormulario(_erro!),
                  TextFormField(
                    key: const ValueKey('tarefa-titulo'),
                    controller: _titulo,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      hintText: 'O que você quer fazer?',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    maxLength: 120,
                    onChanged: (_) => setState(() => _alterado = true),
                    enabled: !_salvando,
                    validator: (v) => (v?.trim().isEmpty ?? true)
                        ? 'Dê um título à sua tarefa.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    key: const ValueKey('tarefa-descricao'),
                    controller: _descricao,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      hintText: 'Adicione os detalhes do seu plano.',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 3,
                    maxLines: 6,
                    maxLength: 2000,
                    onChanged: (_) => setState(() => _alterado = true),
                    enabled: !_salvando,
                    validator: (v) => (v?.trim().isEmpty ?? true)
                        ? 'Adicione uma descrição à tarefa.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Vencimento',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      key: const ValueKey('tarefa-vencimento'),
                      onPressed: _salvando ? null : _escolherData,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text(formatarData(_vencimento)),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Prioridade',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: Prioridade.values
                        .map(
                          (p) => ChoiceChip(
                            label: Text(p.rotulo),
                            selected: _prioridade == p,
                            avatar: Icon(switch (p) {
                              Prioridade.baixa =>
                                Icons.keyboard_arrow_down_rounded,
                              Prioridade.media => Icons.drag_handle_rounded,
                              Prioridade.alta =>
                                Icons.keyboard_double_arrow_up_rounded,
                            }, size: 18),
                            onSelected: _salvando
                                ? null
                                : (_) => setState(() {
                                    _prioridade = p;
                                    _alterado = true;
                                  }),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Situação',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Pendente'),
                        avatar: const Icon(Icons.timelapse_rounded, size: 18),
                        selected: !_concluida,
                        onSelected: _salvando
                            ? null
                            : (_) => setState(() {
                                _concluida = false;
                                _alterado = true;
                              }),
                      ),
                      ChoiceChip(
                        label: const Text('Concluída'),
                        avatar: const Icon(Icons.task_alt_rounded, size: 18),
                        selected: _concluida,
                        onSelected: _salvando
                            ? null
                            : (_) => setState(() {
                                _concluida = true;
                                _alterado = true;
                              }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  BotaoCarregando(
                    carregando: _salvando,
                    rotulo: widget.tarefa == null
                        ? 'Criar tarefa'
                        : 'Salvar alterações',
                    icone: Icons.check_rounded,
                    onPressed: _salvar,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: _salvando ? null : _voltar,
                      child: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
