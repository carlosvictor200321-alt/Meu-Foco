# Firebase do Meu Foco

Projeto conectado: `gerenciamento-de-tarefas-2f419`.

Realtime Database: `https://gerenciamento-de-tarefas-2f419-default-rtdb.firebaseio.com`. O provedor e-mail/senha e as regras por UID já estão publicados. O modo padrão do aplicativo usa esse projeto na nuvem.

## Configuração da nuvem

Execute na raiz:

```powershell
.\scripts\configurar-firebase.ps1 -Projeto gerenciamento-de-tarefas-2f419
```

Entre na **conta que é proprietária do projeto** quando a página do Google abrir. A conta usada pelo terminal precisa conseguir visualizar o projeto com `firebase projects:list`.

Se o projeto estiver em outra conta, use `-Conta EMAIL_DA_CONTA` no comando acima para abrir o login correto e selecionar essa conta para esta pasta.

O script usa a sessão do Firebase CLI, registra os aplicativos Android/iOS/Web, cria o Realtime Database padrão em `us-central1` e grava as configurações públicas. A publicação usa `firebase deploy --only auth,database` para habilitar e-mail/senha a partir de `firebase.json` e publicar `database.rules.json`. Não é necessário criar uma chave privada de conta de serviço.

Arquivos gerados após a conexão:

- `lib/firebase_options.dart`: opções públicas das plataformas.
- `android/app/google-services.json`: configuração Android.
- `ios/Runner/GoogleService-Info.plist`: configuração iOS.
- `config/firebase.android.json`, `config/firebase.ios.json`, `config/firebase.web.json`: opções para execução por `--dart-define-from-file`.
- `.firebaserc`: projeto padrão do CLI.

## Estrutura do Realtime Database

```text
usuarios/
  UID_DA_CONTA/
    tarefas/
      ID_DA_TAREFA/
        id: string
        titulo: string
        descricao: string
        dataVencimento: "AAAA-MM-DD"
        prioridade: "baixa" | "media" | "alta"
        concluida: boolean
```

A sessão pertence ao Firebase Authentication. A senha nunca é salva no Realtime Database nem em SharedPreferences. O nome fica no perfil do Firebase Authentication. SharedPreferences guarda somente a preferência de tema.

`FirebaseService` escuta `onValue` apenas em `usuarios/UID/tarefas`. O servidor exige `auth.uid == UID`, rejeita acessos à raiz e valida os campos de cada tarefa. Os testes das regras verificam operações do proprietário, acesso anônimo, acessos de outra conta e registros inválidos.

## Desenvolvimento local

Os emuladores oficiais utilizam o projeto fictício `demo-meu-foco` e são independentes do projeto na nuvem.

```powershell
.\scripts\emuladores.ps1
# Em outro terminal:
.\scripts\iniciar.ps1 -Modo local
```

O painel fica em http://127.0.0.1:4000, a autenticação em `9099` e o banco em `9000`. O encerramento normal exporta os dados para `.firebase-data`; a próxima inicialização os recupera.

Para um Android físico conectado por USB:

```powershell
& "$env:ANDROID_HOME\platform-tools\adb.exe" reverse tcp:9099 tcp:9099
& "$env:ANDROID_HOME\platform-tools\adb.exe" reverse tcp:9000 tcp:9000
.\scripts\iniciar.ps1 -Modo local -Dispositivo ID_DO_CELULAR -HostEmulador 127.0.0.1
```

No emulador Android padrão, o aplicativo usa `10.0.2.2` por padrão. O tráfego HTTP local é liberado somente no manifesto de depuração e somente para loopback/host do emulador.
