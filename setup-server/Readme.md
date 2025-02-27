# Pentesting Server Setup Script

## Overview
This Bash script automates the installation of essential dependencies required for setting up a newly created server for penetration testing. It ensures that all necessary tools and configurations are in place.

## Features
- **Automated installation** of Docker, Docker Compose, Zsh, and other pentesting-related dependencies.
- **Non-interactive mode** for seamless deployment.
- **Pre-checks** to verify if dependencies are already installed.
- **Error handling** and informative messages for smooth execution.

## Usage
```bash
chmod +x setup.sh
sudo ./setup.sh [-n] [-h]
```

### Options
- `-n` : Run the installation in non-interactive mode.
- `-h` : Display usage information.

## Prerequisites
Ensure you have:
- **Root privileges** (`sudo` access required).
- **A stable internet connection** for downloading dependencies.

## What It Installs
1. **Curl** - Command-line tool for transferring data.
2. **Docker** - Containerization platform.
3. **Docker Compose** - Tool for defining and running multi-container Docker applications.
4. **Make** - Build automation tool.
5. **Go tools** - Installs PDTM (ProjectDiscovery's tool manager).
6. **Zsh & Oh My Zsh** - Alternative shell with a powerful plugin system.
7. **Common Pentesting Tools** - Various security-focused utilities to aid in penetration testing.

## Installation Steps
The script follows these steps:
1. **Checks for root privileges** before proceeding.
2. **Verifies existing installations** of required packages.
3. **Installs missing dependencies** such as Curl, Docker, and Docker Compose.
4. **Configures Zsh as the default shell** and installs Oh My Zsh.
5. **Ensures Docker is running** before proceeding.

## Example Run
```bash
sudo ./setup.sh
```

For non-interactive installation:
```bash
sudo ./setup.sh -n
```

## Troubleshooting
If Docker is not running, manually start it with:
```bash
sudo systemctl start docker
```

If any dependency fails to install, check your internet connection and retry.

## Contribution
Feel free to fork and modify the script to enhance its functionality. PRs are welcome!
