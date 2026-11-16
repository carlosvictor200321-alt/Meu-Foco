# Roteiro da demonstração da P2

Use um celular Android com o APK ou a mesma aplicação Flutter na prévia em navegador. Informe no vídeo o ambiente utilizado (Firebase na nuvem ou emuladores locais). As imagens em `capturas/` são capturas reais do aplicativo.

1. Abra **Criar conta**. Preencha nome, e-mail e senha; confirme a senha. Mostre a validação de campos e conclua o cadastro.
2. Abra o Drawer e selecione **Sair**. Confirme e faça login com o e-mail e a senha cadastrados.
3. No **Início**, mostre o nome do usuário e os contadores de tarefas cadastradas, pendentes e concluídas.
4. Cadastre **duas tarefas**, preenchendo título, descrição, vencimento, prioridade e situação.
5. Abra **Minhas tarefas** no Drawer. Mostre o `ListView`, a data, a prioridade por cor/ícone e a situação de cada tarefa.
6. Selecione uma tarefa para consultar os detalhes. Use **Editar tarefa**, altere o título e a prioridade e salve.
7. Marque a tarefa como concluída; mostre a alteração no contador e no filtro **Concluídas**. Demonstre também a volta para pendente.
8. Exclua a segunda tarefa e confirme a ação. Mostre a atualização imediata da listagem.
9. Faça logout e login novamente. Mostre que a primeira tarefa continua salva.
10. Abra **Configurações**, selecione **Tema escuro**, feche e reabra o aplicativo. Mostre que o tema e a sessão foram restaurados.
11. No console Firebase, abra **Realtime Database → Dados → usuarios → UID → tarefas**. Mostre os mesmos dados exibidos no aplicativo e faça uma edição para demonstrar o listener em tempo real.
12. Crie uma segunda conta e mostre que ela inicia sem as tarefas da primeira. As regras do banco também impedem a leitura/gravação de caminhos de outro UID.

O fluxo automatizado `tools/firebase/ui-flow.mjs` grava um vídeo sem narração, captura as telas e verifica a edição/exclusão em duas abas simultâneas. A última tela mostra uma leitura autenticada real do banco e a rejeição de acesso por uma segunda conta. `evidencias-firebase.json` registra o ambiente e os resultados dessa execução.
