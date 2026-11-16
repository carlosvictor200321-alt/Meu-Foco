$ErrorActionPreference = 'Stop'
$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
Set-Location -LiteralPath $projectRoot
$flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
if ($flutterCommand) {
    $script:FlutterBin = $flutterCommand.Source
} else {
    $script:FlutterBin = Join-Path $env:USERPROFILE 'develop\flutter\bin\flutter.bat'
    if (-not (Test-Path -LiteralPath $script:FlutterBin)) {
        throw 'Flutter nao encontrado. Instale o SDK e adicione flutter/bin ao PATH.'
    }
}
$javaFolder = Join-Path $env:USERPROFILE 'develop\java'
if (-not $env:JAVA_HOME -and (Test-Path -LiteralPath $javaFolder)) {
    $javaInstallation = Get-ChildItem -LiteralPath $javaFolder -Directory |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'bin\java.exe') } |
        Sort-Object Name -Descending | Select-Object -First 1
    if ($javaInstallation) { $env:JAVA_HOME = $javaInstallation.FullName }
}
if ($env:JAVA_HOME) { $env:Path = (Join-Path $env:JAVA_HOME 'bin') + ';' + $env:Path }
$androidFolder = Join-Path $env:USERPROFILE 'develop\android-sdk'
if (-not $env:ANDROID_HOME -and (Test-Path -LiteralPath $androidFolder)) {
    $env:ANDROID_HOME = $androidFolder
}
$script:FirebaseBin = Join-Path $projectRoot 'tools\firebase\node_modules\.bin\firebase.cmd'
if (-not (Test-Path -LiteralPath $script:FirebaseBin)) {
    & npm.cmd ci --prefix tools/firebase
    if ($LASTEXITCODE -ne 0) { throw 'Nao foi possivel instalar as ferramentas Firebase.' }
}
