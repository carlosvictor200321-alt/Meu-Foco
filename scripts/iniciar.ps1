param(
    [ValidateSet('nuvem','local')] [string]$Modo = 'nuvem',
    [string]$Dispositivo = 'edge',
    [string]$HostEmulador = ''
)
. "$PSScriptRoot\ambiente.ps1"
& $FlutterBin pub get
if ($LASTEXITCODE -ne 0) { throw 'Falha ao restaurar dependencias Flutter.' }
$flutterArguments = @('run', '-d', $Dispositivo)
if ($Modo -eq 'local') {
    $flutterArguments += '--dart-define=USE_FIREBASE_EMULATOR=true'
    if ($HostEmulador) {
        $flutterArguments += "--dart-define=FIREBASE_EMULATOR_HOST=$HostEmulador"
    }
} else {
    if (-not (Test-Path -LiteralPath 'config/firebase.web.json')) {
        throw 'Conecte primeiro o projeto executando scripts/configurar-firebase.ps1.'
    }
}
& $FlutterBin @flutterArguments
if ($LASTEXITCODE -ne 0) { throw 'Nao foi possivel iniciar o aplicativo.' }
