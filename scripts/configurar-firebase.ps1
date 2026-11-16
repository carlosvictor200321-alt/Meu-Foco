param(
    [string]$Projeto = 'gerenciamento-de-tarefas-2f419',
    [string]$Conta = ''
)
. "$PSScriptRoot\ambiente.ps1"
if ($Conta) {
    & $FirebaseBin login:use $Conta --json
    if ($LASTEXITCODE -ne 0) {
        & $FirebaseBin login:add $Conta --interactive
        if ($LASTEXITCODE -ne 0) { throw 'Login no Google nao concluido.' }
        & $FirebaseBin login:use $Conta --json
        if ($LASTEXITCODE -ne 0) { throw 'Nao foi possivel selecionar a conta do projeto.' }
    }
} else {
    & $FirebaseBin login --interactive
    if ($LASTEXITCODE -ne 0) { throw 'Login no Google nao concluido.' }
}
& node tools/firebase/configure-cloud.mjs $Projeto
if ($LASTEXITCODE -ne 0) { throw 'Configuracao do Firebase nao concluida. Confira a mensagem acima.' }
