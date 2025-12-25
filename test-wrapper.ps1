# Test wrapper for setup.ps1
$ErrorActionPreference = 'Continue'
$transcriptFile = "C:\Users\WDAGUtilityAccount\Desktop\setup-transcript.txt"

# Start transcript to capture ALL output
Start-Transcript -Path $transcriptFile -Force

Write-Host "Starting setup.ps1 test..."
Write-Host "PowerShell Version: $($PSVersionTable.PSVersion)"

try {
    # Dot-source the setup script so it runs in this session
    . "C:\TestFiles\setup.ps1"
    Write-Host "Setup script completed successfully!"
} catch {
    Write-Host "ERROR: $_"
    Write-Host $_.ScriptStackTrace
}

# Verify installations
Write-Host "
=== Verification ==="

Write-Host "Checking scoop..."
if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Write-Host "  scoop: INSTALLED"
    Write-Host "  Installed packages:"
    scoop list
} else {
    Write-Host "  scoop: NOT FOUND"
}

Write-Host "
Checking mise..."
if (Get-Command mise -ErrorAction SilentlyContinue) {
    Write-Host "  mise: INSTALLED"
    mise list
} else {
    Write-Host "  mise: NOT FOUND"
}

Write-Host "
Checking bun..."
if (Get-Command bun -ErrorAction SilentlyContinue) {
    Write-Host "  bun: INSTALLED ($(bun --version))"
} else {
    Write-Host "  bun: NOT FOUND"
}

Write-Host "
Checking claude..."
if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host "  claude: INSTALLED"
} else {
    Write-Host "  claude: NOT FOUND"
}

Write-Host "
=== Test Complete ==="

Stop-Transcript

Write-Host "Transcript saved to: $transcriptFile"

# Keep window open
Read-Host "
Press Enter to close"
