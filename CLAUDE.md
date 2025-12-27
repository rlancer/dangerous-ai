# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository provides cross-platform setup scripts to install a development environment with AI coding assistants (Claude, Codex, Gemini) on Windows and macOS.

## Architecture

Hybrid shell + TypeScript approach: shell scripts bootstrap the package manager and bun, then hand off to a cross-platform TypeScript script.

- **config/config.json**: Central configuration file defining all packages for both platforms.
- **scripts/setup.ps1**: Windows bootstrap (PowerShell). Installs Scoop, git, packages, bun, then calls setup.ts. Supports `irm URL | iex` remote execution.
- **scripts/setup.sh**: macOS bootstrap (Bash). Installs Homebrew, packages, bun, then calls setup.ts. Requires jq for JSON parsing.
- **scripts/setup.ts**: Cross-platform TypeScript (runs via bun). Handles mise tools, bun globals, shell profiles, and SSH key setup.
- **tests/test-setup.ps1**: Test runner using Windows Sandbox to validate setup.ps1 in isolation.

## Commands

### Run Setup Locally

```powershell
# Windows
powershell -ExecutionPolicy Bypass -File scripts\setup.ps1

# macOS
bash scripts/setup.sh
```

### Test in Windows Sandbox

```powershell
# Enable sandbox feature (requires restart)
.\tests\test-setup.ps1 -EnableSandbox

# Run test
.\tests\test-setup.ps1 -RunTest
```

## Package Managers

- **Windows**: Scoop (buckets: extras, nerd-fonts)
- **macOS**: Homebrew (tap: homebrew/cask-fonts)
- **Both**: Bun for global npm packages (claude-code, codex, gemini-cli)

## Key Patterns

- Scripts are idempotent - check if packages/configs already exist before installing
- Config changes cascade to both platforms - edit config.json, not the scripts
- Remote execution supported on Windows via config fetch from GitHub
- Test artifacts (test-sandbox.wsb, test-wrapper.ps1) are gitignored and generated at runtime
