# Validação da implementação

## Verificações executadas neste computador

| Verificação | Resultado |
| --- | --- |
| Flutter analyze | Código sem problemas na análise estática |
| Flutter test | 10 testes aprovados |
| Regras do Realtime Database | 6 testes aprovados nos emuladores oficiais |
| Compilação Android | APK de depuração compilado para ARM, ARM64 e x64 |
| Interface | Conferência visual em viewport de celular de 390 × 844 |
| Fluxo completo em execução | Aprovado com os emuladores Firebase, duas abas, reabertura e isolamento por conta |
| iOS | Projeto e configuração de plataforma preparados; compilação exige macOS/Xcode |

Os testes Flutter verificam serialização do model, tratamento de erro real de autenticação, vencimento por dia, restauração do tema, informações do usuário, validação do login, cadastro, CRUD de duas tarefas com prioridade, mudança de situação, filtros, descarte de formulário e logout.

Os testes do banco verificam acesso anônimo negado, CRUD do proprietário, rejeição de leitura/edição/exclusão por outra conta, bloqueio da raiz, validação do formato e listeners em tempo real.

## Teste completo no aplicativo em execução

O script `tools/firebase/ui-flow.mjs` utiliza os SDKs e serviços reais do Firebase (emuladores no desenvolvimento ou projeto na nuvem quando configurado), sem repositórios simulados. Ele registra contas de demonstração, cadastra duas tarefas, edita/conclui/exclui, acompanha a atualização em duas abas, recarrega a página, verifica tema e sessão, faz logout/login e verifica a rejeição de acesso por outra conta.

Após uma execução bem-sucedida:

- `docs/evidencias-firebase.json` identifica o ambiente, os dados lidos e o resultado do isolamento.
- `docs/capturas/` contém capturas reais da execução.
- `docs/video/demonstracao.webm` contém a gravação automática sem narração.

O APK foi compilado neste Windows. Não havia aparelho Android conectado para teste físico. A sessão e a persistência local também devem ser demonstradas no aparelho usado para apresentar a atividade, seguindo o roteiro.
