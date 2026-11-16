import 'package:material_ui/material_ui.dart';

import '../services/app_exception.dart';
import '../widgets/app_scope.dart';
import '../widgets/common.dart';

class CadastroUsuarioScreen extends StatefulWidget {
  const CadastroUsuarioScreen({super.key});
  @override
  State<CadastroUsuarioScreen> createState() => _CadastroUsuarioScreenState();
}

class _CadastroUsuarioScreenState extends State<CadastroUsuarioScreen> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirmacao = TextEditingController();
  bool _ocultar = true;
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    for (final controller in [_nome, _email, _senha, _confirmacao]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_form.currentState!.validate() || _carregando) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      await AppScope.of(context).auth
          .cadastrar(_nome.text, _email.text, _senha.text);
    } catch (e) {
      if (mounted) setState(() => _erro = mensagemErro(e));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
        actions: const [BotaoTema()],
      ),
      body: SafeArea(
        child: ConteudoCentral(
          maxWidth: 480,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: AutofillGroup(
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Marca(grande: true),
                    const SizedBox(height: 32),
                    Text(
                      'Seu próximo passo\ncomeça aqui.',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Crie sua conta e reserve um lugar para o que importa.',
                    ),
                    const SizedBox(height: 28),
                    if (_erro != null) AvisoFormulario(_erro!),
                    TextFormField(
                      key: const ValueKey('cadastro-nome'),
                      controller: _nome,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      textCapitalization: TextCapitalization.words,
                      maxLength: 80,
                      autofillHints: const [AutofillHints.name],
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v?.trim().isEmpty ?? true)
                          ? 'Informe seu nome.'
                          : null,
                      enabled: !_carregando,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      key: const ValueKey('cadastro-email'),
                      controller: _email,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: validarEmail,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      enabled: !_carregando,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      key: const ValueKey('cadastro-senha'),
                      controller: _senha,
                      obscureText: _ocultar,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        helperText: 'Pelo menos 6 caracteres.',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip: _ocultar ? 'Mostrar senha' : 'Ocultar senha',
                          onPressed: () => setState(() => _ocultar = !_ocultar),
                          icon: Icon(
                            _ocultar
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v?.length ?? 0) < 6
                          ? 'Use pelo menos 6 caracteres.'
                          : null,
                      enabled: !_carregando,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      key: const ValueKey('cadastro-confirmacao'),
                      controller: _confirmacao,
                      obscureText: _ocultar,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar senha',
                        prefixIcon: Icon(Icons.lock_outline_rounded),
                      ),
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.done,
                      validator: (v) => v != _senha.text
                          ? 'As senhas precisam ser iguais.'
                          : null,
                      onFieldSubmitted: (_) => _cadastrar(),
                      enabled: !_carregando,
                    ),
                    const SizedBox(height: 28),
                    BotaoCarregando(
                      carregando: _carregando,
                      rotulo: 'Criar minha conta',
                      onPressed: _cadastrar,
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: TextButton(
                        onPressed: _carregando
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text('Já tenho uma conta. Entrar'),
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
}
