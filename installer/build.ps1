param(
    [Parameter(Mandatory)][string]$Compiler,
    [Parameter(Mandatory)][string]$PackageDirectory,
    [switch]$TestBuild
)
$ErrorActionPreference = 'Stop'
$compilerPath = (Resolve-Path -LiteralPath $Compiler).Path
$packages = (Resolve-Path -LiteralPath $PackageDirectory).Path
$root = Split-Path -Parent $PSScriptRoot
$destination = Join-Path $root $(if ($TestBuild) {'build/test-installers'} else {'build/installers'})
New-Item -ItemType Directory -Force -Path $destination | Out-Null

$expectedVersion = $null
foreach ($edition in @('Full','Lite')) {
    $payload = Join-Path $packages "$edition/VLC-Modern"
    if (!(Test-Path -LiteralPath (Join-Path $payload 'VLCModern.exe'))) {
        throw "Missing $edition payload under $packages"
    }
    $info = (Get-Item -LiteralPath (Join-Path $payload 'VLCModern.exe')).VersionInfo
    $version = "$($info.FileMajorPart).$($info.FileMinorPart).$($info.FileBuildPart)"
    if ($version -eq '0.0.0' -or $info.FilePrivatePart -ne 0) {
        throw "Missing or invalid embedded version in $edition payload"
    }
    if ($expectedVersion -and $version -ne $expectedVersion) {
        throw "Full and Lite payload versions differ"
    }
    $expectedVersion = $version
    $arguments = @("/DEdition=$edition", "/DPayload=$payload", "/DOutputPath=$destination")
    if ($TestBuild) { $arguments += '/DTestBuild=1' }
    & $compilerPath @arguments (Join-Path $PSScriptRoot 'VLCModern.iss')
    if ($LASTEXITCODE) { throw "Installer compilation failed for $edition" }
    $file = "VLC-Modern-v$version-Setup-$edition-Windows.exe"
    $hash = (Get-FileHash -LiteralPath (Join-Path $destination $file)).Hash.ToLowerInvariant()
    Set-Content -LiteralPath (Join-Path $destination "$file.sha256") -Value "$hash  $file"
}
