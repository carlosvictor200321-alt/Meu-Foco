import 'package:material_ui/material_ui.dart';

import '../models/tarefa.dart';
import '../screens/detalhe_tarefa_screen.dart';
import '../services/app_exception.dart';
import 'app_scope.dart';
import 'common.dart';

class PrioridadeBadge extends StatelessWidget {
  const PrioridadeBadge(this.prioridade, {super.key});
  final Prioridade prioridade;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = switch (prioridade) {
      Prioridade.alta =>
        dark ? const Color(0xFFFFB4A8) : const Color(0xFFB23E32),
      Prioridade.media =>
        dark ? const Color(0xFFEBC786) : const Color(0xFF855B16),
      Prioridade.baixa =>
        dark ? const Color(0xFFA5DBB4) : const Color(0xFF29644C),
    };
    final icon = switch (prioridade) {
      Prioridade.alta => Icons.keyboard_double_arrow_up_rounded,
      Prioridade.media => Icons.drag_handle_rounded,
      Prioridade.baixa => Icons.keyboard_arrow_down_rounded,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 3),
          Text(
            prioridade.rotulo,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class TarefaCard extends StatefulWidget {
  const TarefaCard(this.tarefa, {super.key});
  final Tarefa tarefa;
  @override
  State<TarefaCard> createState() => _TarefaCardState();
}

class _TarefaCardState extends State<TarefaCard> {
  bool _salvando = false;
  Future<void> _alternar() async {
    setState(() => _salvando = true);
    try {
      await AppScope.of(context).tarefas!.service
          .alterarSituacao(widget.tarefa);
    } catch (e) {
      if (mounted) mostrarMensagem(context, mensagemErro(e), erro: true);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tarefa;
    final scheme = Theme.of(context).colorScheme;
    final atrasada = t.atrasadaEm(DateTime.now());
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DetalheTarefaScreen(tarefaId: t.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: _salvando
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Checkbox(
                        value: t.concluida,
                        semanticLabel: t.concluida
                            ? 'Marcar ${t.titulo} como pendente'
                            : 'Concluir ${t.titulo}',
                        onChanged: (_) => _alternar(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      t.titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: t.concluida
                            ? TextDecoration.lineThrough
                            : null,
                        color: t.concluida
                            ? scheme.onSurfaceVariant
                            : scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 12,
                              color: atrasada
                                  ? scheme.error
                                  : scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              formatarData(t.dataVencimento),
                              style: TextStyle(
                                fontSize: 12,
                                color: atrasada
                                    ? scheme.error
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        PrioridadeBadge(t.prioridade),
                        Text(
                          t.concluida
                              ? 'Concluída'
                              : atrasada
                              ? 'Pendente · Atrasada'
                              : 'Pendente',
                          style: TextStyle(
                            fontSize: 11,
                            color: atrasada
                                ? scheme.error
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10, left: 6),
                child: Icon(Icons.chevron_right_rounded, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
