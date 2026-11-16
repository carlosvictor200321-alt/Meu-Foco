import 'package:material_ui/material_ui.dart';

import '../services/app_exception.dart';
import '../widgets/app_scope.dart';
import '../widgets/common.dart';
import 'cadastro_usuario_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _ocultar = true;
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_form.currentState!.validate() || _carregando) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      await AppScope.of(context).auth.entrar(_email.text, _senha.text);
    } catch (e) {
      if (mounted) setState(() => _erro = mensagemErro(e));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _recuperarSenha() async {
    final error = validarEmail(_email.text);
    if (error != null) {
      mostrarMensagem(
        context,
        'Preencha um e-mail válido acima para recuperar sua senha.',
        erro: true,
      );
      return;
    }
    setState(() => _carregando = true);
    try {
      await AppScope.of(context).auth.recuperarSenha(_email.text);
      if (mounted) {
        mostrarMensagem(
          context,
          'Se houver uma conta com esse e-mail, você receberá as instruções para redefinir a senha.',
        );
      }
    } catch (e) {
      if (mounted) setState(() => _erro = mensagemErro(e));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(actions: const [BotaoTema(), SizedBox(width: 12)]),
      body: SafeArea(
        child: ConteudoCentral(
          maxWidth: 480,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
            child: AutofillGroup(
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Marca(grande: true),
                    const SizedBox(height: 44),
                    Text(
                      'Mais leveza.\nMais feito.',
                      style: theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Suas tarefas em ordem, um passo de cada vez.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Bem-vindo de volta',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    const Text('Entre na sua conta para continuar.'),
                    const SizedBox(height: 24),
                    if (_erro != null) AvisoFormulario(_erro!),
                    TextFormField(
                      key: const ValueKey('login-email'),
                      controller: _email,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        hintText: 'voce@exemplo.com',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: validarEmail,
                      enabled: !_carregando,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      key: const ValueKey('login-senha'),
                      controller: _senha,
                      decoration: InputDecoration(
                        labelText: 'Senha',
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
                      obscureText: _ocultar,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _entrar(),
                      validator: (v) =>
                          (v?.isEmpty ?? true) ? 'Informe sua senha.' : null,
                      enabled: !_carregando,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _carregando ? null : _recuperarSenha,
                        child: const Text('Esqueci minha senha'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    BotaoCarregando(
                      carregando: _carregando,
                      rotulo: 'Entrar',
                      onPressed: _entrar,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('Ainda não tem conta?'),
                        TextButton(
                          onPressed: _carregando
                              ? null
                              : () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const CadastroUsuarioScreen(),
                                  ),
                                ),
                          child: const Text('Criar conta'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_person_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Um espaço só seu.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
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
