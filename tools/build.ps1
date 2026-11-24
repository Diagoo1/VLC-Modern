$ErrorActionPreference='Stop'
$projectRoot=Split-Path $PSScriptRoot -Parent
Push-Location $projectRoot
try {
 New-Item -ItemType Directory -Path bin,build\dcu,build\diagnostics -Force | Out-Null
 $resourceCompiler=$null
 if (!$resourceCompiler) {
  $sdkRoot=Join-Path ([Environment]::GetEnvironmentVariable('ProgramFiles(x86)')) 'Windows Kits\10\bin'
  $resourceCompiler=Get-ChildItem -LiteralPath $sdkRoot -Directory -ErrorAction SilentlyContinue |
   Sort-Object Name -Descending | ForEach-Object { Join-Path $_.FullName 'x86\rc.exe' } |
   Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
 }
 if (!$resourceCompiler) { throw 'Windows SDK rc.exe is required for the embedded multi-resolution icon.' }
 Push-Location res
 try { & $resourceCompiler /fo VLCModern.res VLCModern.rc; if ($LASTEXITCODE) { throw 'Resource build failed' } }
 finally { Pop-Location }
 & dcc32 -B -GD '-$W+' '--peosversion:6.1' '--pesubsysversion:6.1' '-NSWinapi;System;System.Win;Vcl;Vcl.Imaging;Vcl.Touch;Vcl.Samples;Vcl.Shell' '-Isrc\core;src\ui;src\forms;res' '-Usrc\core;src\ui;src\forms;res' '-Rres' '-Ebin' '-NUbuild\dcu' VLCModern.dpr
 if ($LASTEXITCODE) { throw 'Player build failed' }
 & (Join-Path $PSScriptRoot 'organize-output.ps1')
 $hash=(Get-FileHash -LiteralPath bin\VLCModern.exe -Algorithm SHA256).Hash
 Set-Content -LiteralPath build\diagnostics\VLCModern.exe.sha256 -Value ($hash+'  VLCModern.exe')
 Write-Output 'Built bin\VLCModern.exe; diagnostics are under build\diagnostics.'
} finally { Pop-Location }
