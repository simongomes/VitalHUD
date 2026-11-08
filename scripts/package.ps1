# Builds the UI and writes release/VitalHUD-<version>.zip.
# File work goes through .NET so paths that contain brackets are not treated as wildcards.

param(
    [string]$RequireTag
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot

function Join-Root([string]$Relative) {
    return Join-Path $root $Relative
}

function Invoke-Npm([string]$Arguments) {
    $start = New-Object System.Diagnostics.ProcessStartInfo
    $start.FileName = 'cmd.exe'
    $start.Arguments = "/c npm $Arguments"
    $start.WorkingDirectory = Join-Root 'ui'
    $start.UseShellExecute = $false
    $process = [System.Diagnostics.Process]::Start($start)
    $process.WaitForExit()
    if ($process.ExitCode -ne 0) {
        throw "npm $Arguments failed."
    }
}

function Copy-Tree([string]$Source, [string]$Destination) {
    [System.IO.Directory]::CreateDirectory($Destination) | Out-Null
    foreach ($dir in [System.IO.Directory]::GetDirectories($Source)) {
        $name = [System.IO.Path]::GetFileName($dir)
        Copy-Tree $dir (Join-Path $Destination $name)
    }
    foreach ($file in [System.IO.Directory]::GetFiles($Source)) {
        $name = [System.IO.Path]::GetFileName($file)
        [System.IO.File]::Copy($file, (Join-Path $Destination $name), $true)
    }
}

$manifest = [System.IO.File]::ReadAllText((Join-Root 'fxmanifest.lua'))
$versionMatch = [regex]::Match($manifest, "(?m)^version\s+'([^']+)'")

if (-not $versionMatch.Success) {
    throw 'fxmanifest.lua has no version string.'
}

$version = $versionMatch.Groups[1].Value

if ($RequireTag) {
    $tagVersion = $RequireTag -replace '^v', ''
    if ($tagVersion -ne $version) {
        throw "Tag $RequireTag does not match fxmanifest version $version. Bump version in fxmanifest.lua and CHANGELOG.md, then tag v$version."
    }
}

$notes = @()
$changelogPath = Join-Root 'CHANGELOG.md'
if ([System.IO.File]::Exists($changelogPath)) {
    $header = "## [$version]"
    $capturing = $false
    foreach ($line in [System.IO.File]::ReadAllLines($changelogPath)) {
        if ($line.StartsWith($header)) {
            $capturing = $true
            continue
        }
        if ($capturing -and $line.StartsWith('## ')) {
            break
        }
        if ($capturing) {
            $notes += $line
        }
    }
}

$tscWindows = Join-Root 'ui/node_modules/.bin/tsc.cmd'
$tscUnix = Join-Root 'ui/node_modules/.bin/tsc'
if (-not ([System.IO.File]::Exists($tscWindows) -or [System.IO.File]::Exists($tscUnix))) {
    Invoke-Npm 'ci'
}
Invoke-Npm 'run build'

if (-not [System.IO.File]::Exists((Join-Root 'ui/dist/index.html'))) {
    throw 'UI build did not write ui/dist/index.html.'
}

$staging = Join-Root 'release/staging'
$resource = Join-Root 'release/staging/VitalHUD'
if ([System.IO.Directory]::Exists($staging)) {
    [System.IO.Directory]::Delete($staging, $true)
}
[System.IO.Directory]::CreateDirectory((Join-Path $resource 'client')) | Out-Null
[System.IO.Directory]::CreateDirectory((Join-Path $resource 'server')) | Out-Null

foreach ($name in @('fxmanifest.lua', 'config.lua', 'README.md', 'CHANGELOG.md')) {
    [System.IO.File]::Copy((Join-Root $name), (Join-Path $resource $name), $true)
}
[System.IO.File]::Copy((Join-Root 'client/main.lua'), (Join-Path $resource 'client/main.lua'), $true)
[System.IO.File]::Copy((Join-Root 'server/main.lua'), (Join-Path $resource 'server/main.lua'), $true)
Copy-Tree (Join-Root 'ui/dist') (Join-Path $resource 'ui/dist')

$releaseDir = Join-Root 'release'
$zipPath = Join-Path $releaseDir "VitalHUD-$version.zip"
$notesPath = Join-Path $releaseDir 'notes.md'
if ([System.IO.File]::Exists($zipPath)) {
    [System.IO.File]::Delete($zipPath)
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$zipStream = [System.IO.File]::Open($zipPath, [System.IO.FileMode]::Create)
$archive = New-Object System.IO.Compression.ZipArchive($zipStream, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    $files = [System.IO.Directory]::GetFiles($resource, '*', [System.IO.SearchOption]::AllDirectories)
    foreach ($file in $files) {
        $relative = $file.Substring($resource.Length).TrimStart('\', '/')
        $entryName = 'VitalHUD/' + ($relative -replace '\\', '/')
        $entry = $archive.CreateEntry($entryName, [System.IO.Compression.CompressionLevel]::Optimal)
        $inputStream = [System.IO.File]::OpenRead($file)
        try {
            $outputStream = $entry.Open()
            try {
                $inputStream.CopyTo($outputStream)
            }
            finally {
                $outputStream.Dispose()
            }
        }
        finally {
            $inputStream.Dispose()
        }
    }
}
finally {
    $archive.Dispose()
    $zipStream.Dispose()
}

$noteBody = if ($notes.Count -gt 0) { ($notes -join "`n").Trim() } else { "Vital HUD $version" }
[System.IO.File]::WriteAllText($notesPath, $noteBody)
[System.IO.Directory]::Delete($staging, $true)

Write-Host "Wrote $zipPath"
