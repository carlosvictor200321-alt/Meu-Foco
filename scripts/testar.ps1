. "$PSScriptRoot\ambiente.ps1"
& $FlutterBin analyze
if ($LASTEXITCODE -ne 0) { throw 'A analise do codigo falhou.' }
& $FlutterBin test --reporter expanded
if ($LASTEXITCODE -ne 0) { throw 'Os testes Flutter falharam.' }
& $FirebaseBin emulators:exec --only database --project demo-meu-foco 'node --test tools/firebase/rules.test.mjs'
if ($LASTEXITCODE -ne 0) { throw 'Os testes das regras falharam.' }
