# Setup script for new user environment
# Run in classic PowerShell (not PowerShell Core)

Write-Host "Setting up your development environment..." -ForegroundColor Cyan

# Set execution policy for current user (ignore if already set by group policy)
Write-Host "`nSetting execution policy..." -ForegroundColor Yellow
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop
} catch {
    Write-Host "  Execution policy already configured (current: $(Get-ExecutionPolicy))" -ForegroundColor Gray
}

# Install Scoop (if not already installed)
Write-Host "`nInstalling Scoop..." -ForegroundColor Yellow
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Host "  Scoop already installed" -ForegroundColor Gray
} else {
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

# Refresh PATH to include scoop
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "User") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "Machine")

# Install git first (required for adding buckets)
Write-Host "`nInstalling git (required for buckets)..." -ForegroundColor Yellow
if (scoop list git 2>$null | Select-String "git") {
    Write-Host "  git already installed" -ForegroundColor Gray
} else {
    scoop install git 2>&1 | Write-Host
}

# Add required buckets (scoop handles duplicates gracefully)
Write-Host "`nAdding Scoop buckets..." -ForegroundColor Yellow
$buckets = scoop bucket list 2>$null

if ($buckets | Select-String "extras") {
    Write-Host "  extras bucket already added" -ForegroundColor Gray
} else {
    Write-Host "  Adding extras bucket..." -ForegroundColor Gray
    scoop bucket add extras 2>&1 | Write-Host
}

if ($buckets | Select-String "nerd-fonts") {
    Write-Host "  nerd-fonts bucket already added" -ForegroundColor Gray
} else {
    Write-Host "  Adding nerd-fonts bucket..." -ForegroundColor Gray
    scoop bucket add nerd-fonts 2>&1 | Write-Host
}

# Install packages
Write-Host "`nInstalling packages..." -ForegroundColor Yellow

$packages = @(
    "7zip",
    "antigravity",
    "duckdb",
    "Hack-NF",
    "innounp",
    "mise",
    "pwsh",
    "slack",
    "starship",
    "touch",
    "vcredist2022",
    "vscode",
    "which",
    "windows-terminal"
)

# Get list of installed packages once
$installedPackages = scoop list 2>$null | Out-String

foreach ($package in $packages) {
    if ($installedPackages -match "(?m)^\s*$package\s") {
        Write-Host "  $package already installed" -ForegroundColor Gray
    } else {
        Write-Host "  Installing $package..." -ForegroundColor Gray
        scoop install $package 2>&1 | Write-Host
    }
}

# Refresh PATH to include newly installed tools (mise, etc.)
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "User") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "Machine")

# Install bun via mise (if not already installed)
Write-Host "`nInstalling bun via mise..." -ForegroundColor Yellow
if (mise list bun 2>$null | Select-String "bun") {
    Write-Host "  bun already installed via mise" -ForegroundColor Gray
} else {
    mise use -g bun@latest 2>&1 | Write-Host
}

# Add mise shims to PATH for current session
$miseDataDir = if ($env:MISE_DATA_DIR) { $env:MISE_DATA_DIR } else { "$env:LOCALAPPDATA\mise" }
$env:PATH = "$miseDataDir\shims;$env:PATH"

# Install AI CLI tools via bun
Write-Host "`nInstalling AI CLI tools..." -ForegroundColor Yellow

# Claude Code
if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host "  Claude Code already installed" -ForegroundColor Gray
} else {
    Write-Host "  Installing Claude Code..." -ForegroundColor Gray
    bun install -g @anthropic-ai/claude-code 2>&1 | Write-Host
}

# OpenAI Codex CLI
if (Get-Command codex -ErrorAction SilentlyContinue) {
    Write-Host "  OpenAI Codex CLI already installed" -ForegroundColor Gray
} else {
    Write-Host "  Installing OpenAI Codex CLI..." -ForegroundColor Gray
    bun install -g @openai/codex 2>&1 | Write-Host
}

# Gemini CLI
if (Get-Command gemini -ErrorAction SilentlyContinue) {
    Write-Host "  Gemini CLI already installed" -ForegroundColor Gray
} else {
    Write-Host "  Installing Gemini CLI..." -ForegroundColor Gray
    bun install -g @google/gemini-cli 2>&1 | Write-Host
}

# Configure PowerShell profile for mise and starship
Write-Host "`nConfiguring PowerShell profile..." -ForegroundColor Yellow

$profileContent = @'
# Initialize mise
Invoke-Expression (& mise activate pwsh)

# Initialize starship prompt
Invoke-Expression (&starship init powershell)
'@

# Configure for PowerShell Core (pwsh)
$pwshProfileDir = "$env:USERPROFILE\Documents\PowerShell"
$pwshProfile = "$pwshProfileDir\Microsoft.PowerShell_profile.ps1"

if (-not (Test-Path $pwshProfileDir)) {
    New-Item -ItemType Directory -Path $pwshProfileDir -Force | Out-Null
}

if (-not (Test-Path $pwshProfile)) {
    $profileContent | Out-File -FilePath $pwshProfile -Encoding UTF8
    Write-Host "  Created PowerShell Core profile" -ForegroundColor Gray
} elseif (-not (Select-String -Path $pwshProfile -Pattern "starship init" -Quiet)) {
    Add-Content -Path $pwshProfile -Value "`n$profileContent"
    Write-Host "  Updated PowerShell Core profile" -ForegroundColor Gray
} else {
    Write-Host "  PowerShell Core profile already configured" -ForegroundColor Gray
}

# Configure for Windows PowerShell
$winPsProfileDir = "$env:USERPROFILE\Documents\WindowsPowerShell"
$winPsProfile = "$winPsProfileDir\Microsoft.PowerShell_profile.ps1"

if (-not (Test-Path $winPsProfileDir)) {
    New-Item -ItemType Directory -Path $winPsProfileDir -Force | Out-Null
}

if (-not (Test-Path $winPsProfile)) {
    $profileContent | Out-File -FilePath $winPsProfile -Encoding UTF8
    Write-Host "  Created Windows PowerShell profile" -ForegroundColor Gray
} elseif (-not (Select-String -Path $winPsProfile -Pattern "starship init" -Quiet)) {
    Add-Content -Path $winPsProfile -Value "`n$profileContent"
    Write-Host "  Updated Windows PowerShell profile" -ForegroundColor Gray
} else {
    Write-Host "  Windows PowerShell profile already configured" -ForegroundColor Gray
}

Write-Host "`nSetup complete!" -ForegroundColor Green
