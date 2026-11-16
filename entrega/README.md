# Meu Foco - Entrega da P2

Aplicativo de gerenciamento de tarefas pessoais em Flutter/Dart com Firebase Authentication e Firebase Realtime Database. Este índice reúne os materiais solicitados na seção 7 do enunciado e os oito itens da demonstração obrigatória.

Repositório público: [carlosvictor200321-alt/Meu-Foco](https://github.com/carlosvictor200321-alt/Meu-Foco).

## Downloads

- [Entrega completa em ZIP](https://github.com/carlosvictor200321-alt/Meu-Foco/releases/latest/download/meu-foco-entrega-p2.zip): código-fonte, APK Android, configuração pública do Firebase, documentação, capturas e vídeo.
- [APK Android](https://github.com/carlosvictor200321-alt/Meu-Foco/releases/latest/download/meu-foco.apk): aplicativo conectado ao Firebase na nuvem.
- [Somente código-fonte e documentação em ZIP](https://github.com/carlosvictor200321-alt/Meu-Foco/releases/latest/download/meu-foco-codigo-fonte.zip).
- [Vídeo demonstrativo em WebM](https://github.com/carlosvictor200321-alt/Meu-Foco/releases/latest/download/demonstracao.webm).

Os mesmos arquivos de código, documentação, capturas e vídeo podem ser consultados diretamente no repositório.

## Materiais exigidos no PDF

| Item de entrega | Local no repositório |
| --- | --- |
| Código-fonte completo do projeto Flutter | [lib](../lib), [android](../android), [ios](../ios), [web](../web), [assets](../assets) e [pubspec.yaml](../pubspec.yaml) |
| Arquivos necessários à execução | [README](../README.md), [scripts](../scripts), [pubspec.lock](../pubspec.lock) e [ferramentas Firebase](../tools/firebase); APK disponível nos downloads acima |
| Configuração para integração com Firebase | [Opções Flutter](../lib/firebase_options.dart), [configurações públicas](../config), [Android](../android/app/google-services.json), [iOS](../ios/Runner/GoogleService-Info.plist), [firebase.json](../firebase.json), [.firebaserc](../.firebaserc) e [regras do banco](../database.rules.json) |
| README com configuração e execução | [README principal](../README.md) e [guia do Firebase](../docs/firebase.md) |
| Capturas demonstrando as funcionalidades | [13 capturas reais](../docs/capturas), identificadas na tabela abaixo |
| Projeto entregue no Git | [Repositório público Meu-Foco](https://github.com/carlosvictor200321-alt/Meu-Foco) |
| Demonstração obrigatória em vídeo | [Vídeo versionado](../docs/video/demonstracao.webm), [download direto](https://github.com/carlosvictor200321-alt/Meu-Foco/releases/latest/download/demonstracao.webm) e [roteiro](../docs/roteiro-demonstracao.md) |

## Oito itens da demonstração obrigatória

O vídeo tem aproximadamente 1 minuto e 39 segundos, sem narração. Foi gravado na prévia web do mesmo aplicativo Flutter, com Firebase na nuvem. As contas e as tarefas apresentadas são fictícias.

| Item do enunciado | Demonstração registrada |
| --- | --- |
| 1. Cadastro de usuário | Preenchimento de nome, e-mail, senha e confirmação, seguido do acesso à tela inicial |
| 2. Login com e-mail e senha | Autenticação após o logout, incluindo uma tentativa inválida e o login correto |
| 3. Cadastro de pelo menos duas tarefas | Criação de “Estudar Flutter” e “Organizar a semana”, com descrição, vencimento e prioridade |
| 4. Edição e exclusão | Edição para “Revisar Flutter e Firebase” e exclusão confirmada da segunda tarefa |
| 5. Tarefas no ListView | Listagem das duas tarefas, abertura dos detalhes e atualização da situação |
| 6. Logout e novo login | Saída pelo Drawer e nova autenticação, com recuperação da tarefa salva |
| 7. Tema escuro e reabertura | Alteração em Configurações e recarga da aplicação, preservando o tema e a sessão |
| 8. Dados no Firebase Realtime Database | Leitura autenticada real do banco ao final do vídeo; os dados e o bloqueio de outra conta também constam nas [evidências](../docs/evidencias-firebase.json) |

O [roteiro da demonstração](../docs/roteiro-demonstracao.md) orienta a apresentação interativa. Para assistir após baixar o projeto, abra [docs/video/assistir.html](../docs/video/assistir.html) no navegador ou reproduza o arquivo WebM em um player compatível.

## Capturas de tela

| Tela ou funcionalidade | Captura |
| --- | --- |
| Login | [01-login.png](../docs/capturas/01-login.png) |
| Cadastro de usuário | [02-cadastro.png](../docs/capturas/02-cadastro.png) |
| Início e contadores | [03-inicio.png](../docs/capturas/03-inicio.png) |
| Cadastro de tarefa | [04-formulario.png](../docs/capturas/04-formulario.png) |
| ListView de tarefas | [05-tarefas.png](../docs/capturas/05-tarefas.png) |
| Detalhes de tarefa | [06-detalhes.png](../docs/capturas/06-detalhes.png) |
| Tarefa concluída | [07-concluida.png](../docs/capturas/07-concluida.png) |
| Confirmação de exclusão | [08-exclusao.png](../docs/capturas/08-exclusao.png) |
| Configurações e tema escuro | [09-configuracoes-escuro.png](../docs/capturas/09-configuracoes-escuro.png) |
| Início no tema escuro | [10-inicio-escuro.png](../docs/capturas/10-inicio-escuro.png) |
| Sobre o aplicativo | [11-sobre.png](../docs/capturas/11-sobre.png) |
| Validação de autenticação | [12-erro-autenticacao.png](../docs/capturas/12-erro-autenticacao.png) |
| Dados reais do Firebase | [13-firebase-dados.png](../docs/capturas/13-firebase-dados.png) |

## Executar para avaliar

Para testar no Android, baixe e instale o APK. Ele requer Android 7.0 ou superior e internet. Crie uma nova conta dentro do aplicativo; cada usuário acessa somente as próprias tarefas. Não é necessário ter acesso à conta Google proprietária do Firebase para usar o aplicativo.

Para executar o código-fonte, siga os pré-requisitos e comandos do [README principal](../README.md). O projeto já inclui as configurações públicas de cliente do Firebase. A troca de projeto ou publicação de regras exige acesso administrativo ao projeto correspondente.

O APK usa assinatura de desenvolvimento para a apresentação acadêmica. A compilação e a assinatura foram verificadas; a instalação em aparelho físico ainda deve ser conferida no dispositivo usado na apresentação. O projeto iOS está incluído, mas a compilação para iPhone exige macOS/Xcode.

Resultados anteriores: 10 testes Flutter e 6 testes das regras aprovados, análise estática sem problemas e fluxo completo verificado com o Firebase na nuvem. Consulte a [validação](../docs/validacao.md) e a [matriz RF01 a RF09](../docs/requisitos.md).
