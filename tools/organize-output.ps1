$ErrorActionPreference='Stop'
$projectRoot=[IO.Path]::GetFullPath((Split-Path $PSScriptRoot -Parent))
$rootPrefix=$projectRoot.TrimEnd('\')+'\'
function ProjectPath([string]$relative) {
 $path=[IO.Path]::GetFullPath((Join-Path $projectRoot $relative))
 if (!$path.StartsWith($rootPrefix,[StringComparison]::OrdinalIgnoreCase)) { throw "Path outside project: $relative" }
 return $path
}
function MoveOutput([string]$sourceRelative,[string]$destinationRelative) {
 $source=ProjectPath $sourceRelative; $destination=ProjectPath $destinationRelative
 if (!(Test-Path -LiteralPath $source)) { return }
 $item=Get-Item -LiteralPath $source -Force
 if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Linked output: $sourceRelative" }
 if ($item.PSIsContainer) {
  if (@(Get-ChildItem -LiteralPath $source -Force -Recurse | Where-Object { $_.Attributes -band [IO.FileAttributes]::ReparsePoint }).Count) { throw "Linked descendant: $sourceRelative" }
 }
 New-Item -ItemType Directory -Path (Split-Path $destination -Parent) -Force | Out-Null
 if (Test-Path -LiteralPath $destination) {
  if ($destinationRelative.StartsWith('build\diagnostics\')) {
   Move-Item -LiteralPath $destination -Destination ($destination+'.previous-'+[DateTime]::UtcNow.ToString('yyyyMMddHHmmssfff'))
  } else { $destination=$destination+'.'+[DateTime]::UtcNow.ToString('yyyyMMddHHmmssfff') }
 }
 Move-Item -LiteralPath $source -Destination $destination
 Write-Output "Moved $sourceRelative -> $destinationRelative"
}
foreach ($name in @('VLCModern.map','VLCModern.drc','VLCModern.exe.sha256')) { MoveOutput ('bin\'+$name) ('build\diagnostics\'+$name) }
foreach ($file in Get-ChildItem -LiteralPath (ProjectPath 'bin') -File) {
 if ($file.Name -eq 'VLCModern.exe' -or $file.Extension -eq '.dll') { continue }
 if ($file.Extension -eq '.ini') {
  $storeName=[IO.Path]::GetFileNameWithoutExtension($file.Name)
  $key='HKCU:\Software\Orvana\VLCModern\'+$storeName+'\__Store'
  $migrated=Get-ItemPropertyValue -LiteralPath $key -Name Migrated -ErrorAction SilentlyContinue
  if ($migrated -eq 1 -or $file.Length -eq 0) { MoveOutput ('bin\'+$file.Name) ('maintenance\legacy-settings\'+$file.Name) }
  else { Write-Warning "Preserved unmigrated legacy settings: $($file.Name)" }
 } else { MoveOutput ('bin\'+$file.Name) ('build\tests\legacy-artifacts\'+$file.Name) }
}
MoveOutput 'bin\tests' 'build\tests\legacy-output'
MoveOutput 'bin\styles' 'assets\optional-themes\styles'
MoveOutput 'bin\skins' 'assets\optional-themes\skins'
