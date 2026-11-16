# Conferência dos requisitos da P2

Fonte: PDF de seis páginas fornecido pelo usuário. Tema obrigatório: gerenciamento de tarefas pessoais em Flutter e Firebase Realtime Database.

| Requisito | Implementação prevista |
| --- | --- |
| RF01 | Firebase Authentication com nome, e-mail, senha, cadastro, login, logout, validações e sessão persistente |
| RF02 | Início com nome e contadores de tarefas totais, pendentes e concluídas |
| RF03 | Drawer com Início, Minhas tarefas, Configurações, Sobre o aplicativo e Sair; nome e e-mail |
| RF04 | Formulário com título, descrição, vencimento, prioridade Baixa/Média/Alta e situação Pendente/Concluída |
| RF05 | ListView com título, vencimento, prioridade por cor/ícone, situação e acesso aos detalhes |
| RF06 | Cadastro, consulta, edição, exclusão e alternância de situação |
| RF07 | Firebase Realtime Database, listeners em tempo real e regras de acesso por UID |
| RF08 | Tema salvo e restaurado por SharedPreferences |
| RF09 | ThemeData, ThemeMode, lightTheme e darkTheme em todas as telas |
| Models | Usuario (uid, nome, email) e Tarefa (id, titulo, descricao, dataVencimento, prioridade, concluida) |
| Organização | Diretórios models, screens, services, widgets e themes, como sugerido no PDF |
| Entrega | Código-fonte completo, configuração Firebase, README, capturas e repositório Git local |
| Demonstração | Roteiro com cadastro/login, duas tarefas, edição/exclusão, ListView, logout/login, tema persistente e banco |

O PDF não contém protótipos de interface nem exige um nome específico para o aplicativo. O nome adotado é **Meu Foco**. A chave `dataVencimento` segue a convenção de nomes do Dart para o campo `DataVencimento` citado no PDF.

Os emuladores oficiais do Firebase permitem desenvolver e testar autenticação, banco e regras sem uma conta de produção. Para persistência na nuvem, é necessário conectar o projeto Firebase do proprietário; dados locais de teste não são dados da nuvem.
