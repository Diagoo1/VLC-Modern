param([Parameter(Mandatory)][string]$PackageDirectory)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $PackageDirectory).Path
$stage = Join-Path $root '.quickjs-ng-v0.18.0'
New-Item -ItemType Directory -Path $stage -Force | Out-Null
$exe = Join-Path $stage 'qjs.exe'
$license = Join-Path $stage 'LICENSE'
Invoke-WebRequest 'https://github.com/quickjs-ng/quickjs/releases/download/v0.18.0/qjs-windows-x86_64.exe' -OutFile $exe
if ((Get-FileHash -LiteralPath $exe -Algorithm SHA256).Hash -ne 'ff03398d74ea6e6bd3a8e58058f7003225abcac229d7d57775b7aaae812a49c7') {
    throw 'Unexpected QuickJS-NG checksum.'
}
Invoke-WebRequest 'https://raw.githubusercontent.com/quickjs-ng/quickjs/v0.18.0/LICENSE' -OutFile $license
foreach ($edition in 'Full','Lite') {
    $payload = Join-Path $root "$edition/VLC-Modern"
    if (!(Test-Path -LiteralPath (Join-Path $payload 'VLCModern.exe'))) {
        throw "Missing $edition payload under $root"
    }
    $tools = New-Item -ItemType Directory -Path (Join-Path $payload 'tools/quickjs-ng') -Force
    Copy-Item -LiteralPath $exe,$license -Destination $tools.FullName -Force
}
