param([switch]$Local)
. "$PSScriptRoot\ambiente.ps1"
New-Item -ItemType Directory -Path 'entrega' -Force | Out-Null
if ($Local) {
    & $FlutterBin build apk --debug '--dart-define=USE_FIREBASE_EMULATOR=true' '--dart-define=FIREBASE_EMULATOR_HOST=127.0.0.1'
    $apkSource = 'build/app/outputs/flutter-apk/app-debug.apk'
    $apkDestination = 'entrega/meu-foco-local.apk'
} else {
    & $FlutterBin build apk --release
    $apkSource = 'build/app/outputs/flutter-apk/app-release.apk'
    $apkDestination = 'entrega/meu-foco.apk'
}
if ($LASTEXITCODE -ne 0) { throw 'Falha ao compilar o APK.' }
Copy-Item -LiteralPath $apkSource -Destination $apkDestination -Force
Get-Item -LiteralPath $apkDestination | Select-Object FullName, Length
