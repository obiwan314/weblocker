# installer/build-installer.ps1
# Build helper for Inno Setup installer for weblocker
# Reads package.json version and invokes ISCC (Inno Setup Compiler)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Push-Location $root

# Read version from package.json
$pkg = Get-Content -Raw (Join-Path $root '..\package.json') | ConvertFrom-Json
$ver = $pkg.version -replace '"',''
if (-not $ver) { Write-Error "Could not read version from package.json"; exit 1 }

# Where to find ISCC.exe (common paths)
$possible = @(
  "$env:ProgramFiles(x86)\Inno Setup 6\ISCC.exe",
  "$env:ProgramFiles\Inno Setup 6\ISCC.exe",
  "ISCC.exe" # if on PATH
)
$iscc = $possible | Where-Object { Test-Path $_ } | Select-Object -First 1

# Fallback: try Get-Command (PATH) and Chocolatey tools folder
if (-not $iscc) {
  $cmd = Get-Command ISCC.exe -ErrorAction SilentlyContinue
  if ($cmd) { $iscc = $cmd.Source }
}
if (-not $iscc) {
  $chocoCandidate = Get-ChildItem -Path 'C:\ProgramData\chocolatey\lib\**\tools\**\ISCC.exe' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($chocoCandidate) { $iscc = $chocoCandidate.FullName }
}

if (-not $iscc) {
  Write-Error "Inno Setup Compiler (ISCC.exe) not found. Install Inno Setup and ensure ISCC.exe is on PATH or in a standard location: https://jrsoftware.org/"
  exit 2
}

# Ensure dist\weblocker.exe exists
$exe = Join-Path $root '..\dist\weblocker.exe'
if (-not (Test-Path $exe)) { Write-Error "Expected $exe to exist. Run 'npm run build' first to produce the exe."; exit 1 }

# Ensure output dir exists
$outDir = Join-Path $root '..\dist\installer'
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

# Run ISCC and pass version as preprocessor define
$issFile = Join-Path $root 'weblocker.iss'
Write-Output "Running ISCC: $iscc on $issFile with MyAppVersion=$ver"
& $iscc /DMyAppVersion=$ver $issFile
$exit = $LASTEXITCODE
if ($exit -ne 0) { Write-Error "ISCC exited with code $exit"; exit $exit }

Write-Output "Installer built in $outDir"
Pop-Location
