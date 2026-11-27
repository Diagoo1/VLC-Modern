$ErrorActionPreference = 'Stop'
$projectRoot = [IO.Path]::GetFullPath((Split-Path $PSScriptRoot -Parent))
$prefix = $projectRoot.TrimEnd('\') + '\'
function Assert-ProjectPath([string]$relative) {
    $target = [IO.Path]::GetFullPath((Join-Path $projectRoot $relative))
    if (!$target.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Cleanup target escaped the project: $relative"
    }
    if (Test-Path -LiteralPath $target) {
        $item = Get-Item -LiteralPath $target -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Linked cleanup target: $relative" }
        if ($item.PSIsContainer) {
            $links = @(Get-ChildItem -LiteralPath $target -Force -Recurse | Where-Object { $_.Attributes -band [IO.FileAttributes]::ReparsePoint })
            if ($links.Count) { throw "Linked item inside cleanup target: $relative" }
        }
    }
    return $target
}
& (Join-Path $PSScriptRoot 'organize-output.ps1')
# Only disposable compiler units are deleted; test reports and crash symbols remain.
$target = Assert-ProjectPath 'build\dcu'
if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Recurse -Force }
Write-Output 'Compiler cache removed. Runtime files, reports, symbols and migrated settings preserved.'
