#!/bin/bash

# Constants
DOCKER_COMPOSE_VERSION="v2.5.0"
DOCKER_COMPOSE_BIN="/usr/local/bin/docker-compose"
DOCKER_COMPOSE_URL="https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)"
PENTEST_TOOLS=(nmap masscan gobuster amass subfinder nuclei)

# Functions
print_usage() {
  echo -e "\nUsage: $0 [-n] [-h]"
  echo -e "\t-n  Non-interactive installation (Optional)"
  echo -e "\t-h  Show usage"
  exit 1
}

print_message() {
  local color=$1
  shift
  tput setaf "$color"
  echo "$@"
  tput sgr0
}

check_root() {
  if [[ "$EUID" -ne 0 ]]; then
    print_message 1 "Error: Please run this script as root!"
    print_message 1 "Example: sudo ./setup.sh"
    exit 1
  fi
}

install_package() {
  local package=$1
  print_message 4 "Installing $package..."
  
  if command -v "$package" &>/dev/null; then
    print_message 2 "$package is already installed. Skipping."
  else
    sudo apt update && sudo apt install -y "$package" && print_message 2 "$package installed successfully!"
  fi
}

install_docker() {
  print_message 4 "Installing Docker..."
  
  if command -v docker &>/dev/null; then
    print_message 2 "Docker is already installed. Skipping."
  else
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm -f get-docker.sh
    print_message 2 "Docker installed successfully!"
  fi
}

install_docker_compose() {
  print_message 4 "Installing Docker Compose..."
  
  if command -v docker-compose &>/dev/null; then
    print_message 2 "Docker Compose is already installed. Skipping."
  else
    curl -L "$DOCKER_COMPOSE_URL" -o "$DOCKER_COMPOSE_BIN"
    chmod +x "$DOCKER_COMPOSE_BIN"
    ln -sf "$DOCKER_COMPOSE_BIN" /usr/bin/docker-compose
    print_message 2 "Docker Compose installed successfully!"
  fi
}

install_pentest_tools() {
  print_message 4 "Installing penetration testing tools..."
  for tool in "${PENTEST_TOOLS[@]}"; do
    install_package "$tool"
  done
}

check_docker_status() {
  print_message 4 "Checking Docker status..."
  
  if docker info &>/dev/null; then
    print_message 2 "Docker is running."
  else
    print_message 1 "Docker is not running. Please start Docker and try again."
    print_message 1 "Run: sudo systemctl start docker"
    exit 1
  fi
}

install_go_tools() {
  print_message 4 "Installing Go tools..."
  wget -q -O - https://git.io/vQhTU | bash -s -- --version 1.24.0 >/dev/null 2>&1
  go install -v github.com/projectdiscovery/pdtm/cmd/pdtm@latest
}

install_zsh() {
  print_message 4 "Installing Zsh and Oh My Zsh..."
  install_package "zsh"
  chsh -s "$(which zsh)"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

# Parse arguments
isNonInteractive=false
while getopts "nh" opt; do
  case $opt in
    n) isNonInteractive=true ;;
    h) print_usage ;;
    ?) print_usage ;;
  esac
done

# Main Execution
check_root

install_package "curl"
install_docker
install_docker_compose
install_package "make"
install_pentest_tools
check_docker_status
install_go_tools
install_zsh

print_message 2 "Setup completed successfully!"
