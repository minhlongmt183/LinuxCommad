# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Bash script (`setup.sh`) that automates pentesting server setup on fresh Linux systems (Debian/Ubuntu only). It installs Docker, Docker Compose, Go tools, pentesting utilities, and Zsh with Oh My Zsh.

## Running the Script

```bash
# Standard execution (requires root)
sudo ./setup.sh

# Non-interactive mode (no prompts, unattended install)
sudo ./setup.sh -n

# Verbose mode (show detailed output)
sudo ./setup.sh -v

# Combined flags
sudo ./setup.sh -n -v

# Show usage
./setup.sh -h
```

## Architecture

The script uses `set -e` for error handling and follows a sequential installation pattern:
1. Root privilege + OS check (Debian/Ubuntu only)
2. Single `apt update` at the start
3. Package installations via `install_package()` wrapper (curl, wget, git, make)
4. Docker and Docker Compose installation with version pinning
5. Go toolchain installation (download script first, then execute)
6. PDTM auto-installation via `go install`
7. Pentesting tools via PDTM
8. Zsh + Oh My Zsh setup (unattended mode supported)
9. Tmux + TPM (Tmux Plugin Manager) + optimized config for security research
10. Swap alias setup (writes to `.zshrc` and `.bashrc`)

### Key Constants

- `DOCKER_COMPOSE_VERSION`: v2.29.2
- `GO_VERSION`: 1.24.0
- `PENTEST_TOOLS`: subfinder, nuclei, httpx, waybackurls, gau, ffuf
- `LOG_FILE`: `/tmp/setup-server-<timestamp>.log`

### Key Functions

- `check_os()`: Validates Debian/Ubuntu before proceeding
- `log_output()`: Logs command output (verbose mode shows on screen)
- `install_pdtm()`: Auto-installs PDTM via `go install`
- `install_tmux()`: Installs tmux and TPM (Tmux Plugin Manager)
- `setup_tmux_config()`: Creates optimized `.tmux.conf` for security research (vi mode, 50k history, session resurrect)
- `setup_swap_alias()`: Persists `free_mem` alias to shell configs

## Parent Repository Context

This subdirectory is part of a larger `LinuxCommad` repository containing various pentesting utilities, scripts, and configurations organized by tool/purpose (powerline, pwntool, web-exploit, zsh, vim_configure).
