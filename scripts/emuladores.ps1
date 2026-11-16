. "$PSScriptRoot\ambiente.ps1"
$firebaseArguments = @('emulators:start','--only','auth,database','--project','demo-meu-foco',
    '--export-on-exit=./.firebase-data')
if (Test-Path -LiteralPath '.firebase-data/firebase-export-metadata.json') {
    $firebaseArguments += '--import=./.firebase-data'
}
& $FirebaseBin @firebaseArguments
