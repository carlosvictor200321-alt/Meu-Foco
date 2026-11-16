import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';

import '../services/app_exception.dart';
import 'app_scope.dart';

String formatarData(DateTime date) =>
    DateFormat('dd/MM/yyyy', 'pt_BR').format(date);

void mostrarMensagem(BuildContext context, String texto, {bool erro = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: erro ? Theme.of(context).colorScheme.error : null,
      ),
    );
}

class Marca extends StatelessWidget {
  const Marca({super.key, this.grande = false});
  final bool grande;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: grande ? 48 : 32,
          height: grande ? 48 : 32,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(grande ? 15 : 10),
          ),
          child: Icon(
            Icons.done_all_rounded,
            color: colors.onPrimary,
            size: grande ? 28 : 21,
          ),
        ),
        const SizedBox(width: 11),
        Flexible(
          child: Text(
            'meu foco',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                (grande
                        ? Theme.of(context).textTheme.headlineSmall
                        : Theme.of(context).textTheme.titleLarge)
                    ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -.7),
          ),
        ),
      ],
    );
  }
}

class BotaoTema extends StatelessWidget {
  const BotaoTema({super.key});
  @override
  Widget build(BuildContext context) {
    final preferences = AppScope.of(context).preferences;
    return IconButton(
      tooltip: preferences.escuro ? 'Usar tema claro' : 'Usar tema escuro',
      icon: Icon(
        preferences.escuro
            ? Icons.light_mode_outlined
            : Icons.dark_mode_outlined,
      ),
      onPressed: () async {
        try {
          await preferences.definirTema(!preferences.escuro);
        } catch (e) {
          if (context.mounted) {
            mostrarMensagem(context, mensagemErro(e), erro: true);
          }
        }
      },
    );
  }
}

class ConteudoCentral extends StatelessWidget {
  const ConteudoCentral({super.key, required this.child, this.maxWidth = 760});
  final Widget child;
  final double maxWidth;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}

class PainelEstado extends StatelessWidget {
  const PainelEstado({
    super.key,
    required this.icone,
    required this.titulo,
    required this.descricao,
    this.acao,
    this.rotuloAcao,
  });
  final IconData icone;
  final String titulo;
  final String descricao;
  final VoidCallback? acao;
  final String? rotuloAcao;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: scheme.primaryContainer,
            child: Icon(icone, color: scheme.onPrimaryContainer, size: 34),
          ),
          const SizedBox(height: 20),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            descricao,
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          if (acao != null) ...[
            const SizedBox(height: 20),
            FilledButton(onPressed: acao, child: Text(rotuloAcao!)),
          ],
        ],
      ),
    );
  }
}

class AvisoFormulario extends StatelessWidget {
  const AvisoFormulario(this.mensagem, {super.key});
  final String mensagem;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        mensagem,
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
      ),
    ),
  );
}

String? validarEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Informe seu e-mail.';
  if (email.length > 254 ||
      !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
    return 'Informe um e-mail válido.';
  }
  return null;
}

class BotaoCarregando extends StatelessWidget {
  const BotaoCarregando({
    super.key,
    required this.carregando,
    required this.rotulo,
    required this.onPressed,
    this.icone = Icons.arrow_forward_rounded,
  });
  final bool carregando;
  final String rotulo;
  final VoidCallback onPressed;
  final IconData icone;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton.icon(
      onPressed: carregando ? null : onPressed,
      icon: carregando
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icone, size: 20),
      label: Text(carregando ? 'Aguarde...' : rotulo),
    ),
  );
}
