import 'package:material_ui/material_ui.dart';

import '../widgets/app_scaffold.dart';
import '../widgets/common.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});
  @override
  Widget build(BuildContext context) => AppScaffold(
    titulo: 'Sobre o aplicativo',
    rota: '/sobre',
    body: ListView(
      padding: const EdgeInsets.all(28),
      children: [
        const SizedBox(height: 16),
        const Marca(grande: true),
        const SizedBox(height: 32),
        Text(
          'Mais espaço para\no que importa.',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 18),
        const Text(
          'O Meu Foco ajuda você a organizar tarefas pessoais, acompanhar seus prazos '
          'e transformar planos em pequenas conquistas.',
        ),
        const SizedBox(height: 28),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Programação Mobile · P2',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 10),
                Text(
                  'Aplicativo desenvolvido com Flutter e Dart para a atividade prática '
                  'de desenvolvimento mobile com Firebase.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.verified_user_outlined),
          title: Text('Uma conta, um espaço seu'),
          subtitle: Text(
            'Cadastro e login por e-mail com Firebase Authentication.',
          ),
        ),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.sync_rounded),
          title: Text('Tudo acompanha você'),
          subtitle: Text(
            'Tarefas por usuário e atualizações com Firebase Realtime Database.',
          ),
        ),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.palette_outlined),
          title: Text('Sua preferência fica'),
          subtitle: Text('Temas claro e escuro com SharedPreferences.'),
        ),
        const SizedBox(height: 28),
        Text('Versão 1.0.0', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        const Text('Um passo de cada vez.'),
      ],
    ),
  );
}
