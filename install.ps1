# ClawManager Installer — Windows
# Usage (PowerShell):
#   iwr -useb https://raw.githubusercontent.com/ClawManager/releases/main/install.ps1 | iex
#   $env:VERSION="v0.1.26"; iwr -useb https://raw.githubusercontent.com/ClawManager/releases/main/install.ps1 | iex
#
# Or download and run locally:
#   .\install.ps1
#   .\install.ps1 -Version v0.1.26

param(
  [string]$Version = ""
)

$ErrorActionPreference = "Stop"
$ProgressPreference    = "Continue"

$Repo        = "ClawManager/releases"
$ApiUrl      = "https://api.github.com/repos/$Repo/releases/latest"
$ReleasesUrl = "https://github.com/$Repo/releases/download"
$AssetName   = "ClawManager-Setup.exe"

# ── Helpers ──────────────────────────────────────────────────────────────────
function Write-Info    ($msg) { Write-Host "[✓] $msg" -ForegroundColor Green  }
function Write-Warn    ($msg) { Write-Host "[!] $msg" -ForegroundColor Yellow }
function Write-Fail    ($msg) { Write-Host "[✗] $msg" -ForegroundColor Red; exit 1 }
function Write-Heading ($msg) { Write-Host "`n$msg" -ForegroundColor Cyan }

# ── Resolve version ──────────────────────────────────────────────────────────
function Resolve-Version {
  # Prefer $env:VERSION, then -Version param, then GitHub API
  $v = if ($env:VERSION) { $env:VERSION } elseif ($Version) { $Version } else { "" }
  if ($v) { return $v }

  Write-Info "Fetching latest release version from GitHub …"
  try {
    $headers = @{ "User-Agent" = "ClawManager-Installer/1.0" }
    $release = Invoke-RestMethod -Uri $ApiUrl -Headers $headers
    return $release.tag_name
  } catch {
    Write-Fail "Could not fetch latest release. Check your connection or set `$env:VERSION = 'vX.Y.Z'."
  }
}

# ── Detect architecture ───────────────────────────────────────────────────────
function Get-InstallerAsset {
  $arch = [System.Environment]::GetEnvironmentVariable("PROCESSOR_ARCHITECTURE")
  # On ARM64 Windows, PROCESSOR_ARCHITECTURE may be ARM64 or x86 (in WoW64).
  # Check PROCESSOR_ARCHITEW6432 as well.
  $arch6432 = [System.Environment]::GetEnvironmentVariable("PROCESSOR_ARCHITEW6432")

  if ($arch -eq "ARM64" -or $arch6432 -eq "ARM64") {
    Write-Warn "ARM64 Windows detected. The x64 installer will run under emulation."
  }
  # Currently only one Windows installer is published (x64/universal)
  return $AssetName
}

# ── Main ─────────────────────────────────────────────────────────────────────
Write-Heading "ClawManager Installer for Windows"

$resolvedVersion = Resolve-Version
Write-Info "Version: $resolvedVersion"

$asset      = Get-InstallerAsset
$downloadUrl = "$ReleasesUrl/$resolvedVersion/$asset"

$tmpDir  = Join-Path $env:TEMP "ClawManager-install"
New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null
$destPath = Join-Path $tmpDir $asset

Write-Info "Downloading $asset …"
try {
  Invoke-WebRequest -Uri $downloadUrl -OutFile $destPath -UseBasicParsing
} catch {
  Write-Fail "Download failed: $_`nURL: $downloadUrl"
}
Write-Info "Download complete: $destPath"

Write-Heading "Launching installer …"
Write-Host ""
Write-Host "  The ClawManager Setup wizard will open." -ForegroundColor Cyan
Write-Host "  Follow the on-screen instructions to complete installation." -ForegroundColor Cyan
Write-Host ""

try {
  Start-Process -FilePath $destPath -Wait
} catch {
  Write-Fail "Failed to launch installer: $_"
}

# Clean up
Remove-Item -Force $destPath -ErrorAction SilentlyContinue
Remove-Item -Force $tmpDir   -ErrorAction SilentlyContinue

Write-Heading "✅  ClawManager $resolvedVersion setup complete!"
Write-Host "   Launch ClawManager from your Start Menu or Desktop shortcut." -ForegroundColor Green
