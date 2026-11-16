param([switch]$Local)
. "$PSScriptRoot\ambiente.ps1"
New-Item -ItemType Directory -Path 'entrega' -Force | Out-Null
$buildDrive = $null
try {
    # O gerador AOT do Dart para Windows exige caminho ASCII nesta versao.
    # SUBST fornece um alias temporario sem mover os arquivos do projeto.
    if ($projectRoot -match '[^\x00-\x7F]') {
        $usedDriveNames = [System.IO.DriveInfo]::GetDrives() | ForEach-Object { $_.Name.Substring(0,1) }
        $buildDriveName = @('R','S','T','U','V','W','X','Y','Z') |
            Where-Object { $_ -notin $usedDriveNames } | Select-Object -First 1
        if (-not $buildDriveName) { throw 'Nenhuma letra de unidade livre para compilar o projeto.' }
        $candidateDrive = $buildDriveName + ':'
        & subst.exe $candidateDrive $projectRoot
        if ($LASTEXITCODE -ne 0) { throw 'Nao foi possivel preparar o caminho temporario de compilacao.' }
        $buildDrive = $candidateDrive
        Set-Location -LiteralPath ($buildDrive + '\')
    }
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
} finally {
    Set-Location -LiteralPath $projectRoot
    if ($buildDrive) { & subst.exe $buildDrive /D }
}
Get-Item -LiteralPath $apkDestination | Select-Object FullName, Length
