# AI for the Rest - Gemini Context

## Project Overview
"AI for the Rest" is a cross-platform infrastructure project designed to automate the setup of a modern development environment integrated with AI coding assistants. It supports Windows (via PowerShell/Scoop) and macOS (via Bash/Homebrew).

The project installs:
*   **AI CLIs:** `@anthropic-ai/claude-code`, `@openai/codex`, `@google/gemini-cli` (via Bun).
*   **Shell Tools:** Starship (prompt), Mise (runtime manager), DuckDB, Touch, Which.
*   **Editors:** Visual Studio Code.
*   **Fonts:** Hack Nerd Font.
*   **Terminals:** Windows Terminal (Windows), iTerm2 (macOS).

## Architecture

*   **`config/config.json`**: The single source of truth for all packages. It defines lists for `common`, `windows` (Scoop), `macos` (Brew), and global `bun` packages.
*   **`scripts/`**:
    *   `setup.ps1`: Windows orchestration script. Handles Scoop installation, bucket addition, package installation, and profile configuration.
    *   `setup.sh`: macOS orchestration script. Handles Homebrew and package installation.
*   **`tests/`**: Contains Windows Sandbox configurations (`.wsb`) and PowerShell scripts (`test-setup.ps1`) to verify the installation process in an isolated environment.

## Usage Commands

### Windows Setup
Run the script from an elevated PowerShell session (or with appropriate permissions):
```powershell
powershell -ExecutionPolicy Bypass -File scripts\setup.ps1
```

### macOS Setup
Run the script from the terminal:
```bash
bash scripts/setup.sh
```

### Testing (Windows Sandbox)
To verify the setup in a clean environment:
```powershell
# 1. Enable sandbox support (if not done)
.\tests\test-setup.ps1 -EnableSandbox

# 2. Run the test
.\tests\test-setup.ps1 -RunTest
```

## Development Conventions

*   **Config-Driven:** Do not hardcode new packages in the scripts. Add them to `config/config.json`. The scripts dynamically read this file.
*   **Idempotency:** Scripts are designed to be safe to re-run. They check for existing installations before attempting to install.
*   **Platform Specifics:**
    *   **Windows:** Uses **Scoop** as the primary package manager. Uses `pwsh` (PowerShell Core) where possible but maintains compatibility with Windows PowerShell.
    *   **macOS:** Uses **Homebrew** as the primary package manager.
    *   **Global:** Uses **Bun** to install the AI CLI tools globally on both platforms.
*   **Shell Configuration:** The scripts automatically configure shell profiles (PowerShell profile or `.zshrc`) to initialize Mise and Starship.
