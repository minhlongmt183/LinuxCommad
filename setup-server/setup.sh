#!/bin/bash

set -e

# Constants
DOCKER_COMPOSE_VERSION="v2.29.2"
DOCKER_COMPOSE_BIN="/usr/local/bin/docker-compose"
DOCKER_COMPOSE_URL="https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)"
PENTEST_TOOLS=(subfinder nuclei httpx waybackurls gau ffuf)
GO_INSTALLER_URL="https://git.io/vQhTU"
GO_VERSION="1.24.0"
LOG_FILE="/tmp/setup-server-$(date +%Y%m%d_%H%M%S).log"

# Global flags
isNonInteractive=false
isVerbose=false

# Functions
print_usage() {
  echo -e "\nUsage: $0 [-n] [-v] [-h]"
  echo -e "\t-n  Non-interactive installation (Optional)"
  echo -e "\t-v  Verbose mode - show detailed output"
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

log_output() {
  if [[ "$isVerbose" == true ]]; then
    "$@" 2>&1 | tee -a "$LOG_FILE"
  else
    "$@" >> "$LOG_FILE" 2>&1
  fi
}

check_os() {
  if [[ ! -f /etc/debian_version ]]; then
    print_message 1 "Error: This script only supports Debian/Ubuntu based systems."
    print_message 1 "Detected OS: $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d= -f2 || echo 'Unknown')"
    exit 1
  fi
  print_message 2 "OS check passed: Debian/Ubuntu detected."
}

check_root() {
  if [[ "$EUID" -ne 0 ]]; then
    print_message 1 "Error: Please run this script as root!"
    print_message 1 "Example: sudo ./setup.sh"
    exit 1
  fi
}

run_apt_update() {
  print_message 4 "Updating package lists..."
  apt update
  print_message 2 "Package lists updated."
}

install_package() {
  local package=$1
  print_message 4 "Installing $package..."

  if command -v "$package" &>/dev/null; then
    print_message 2 "$package is already installed. Skipping."
  else
    apt install -y "$package" && print_message 2 "$package installed successfully!"
  fi
}

install_docker() {
  print_message 4 "Installing Docker..."

  if command -v docker &>/dev/null; then
    print_message 2 "Docker is already installed. Skipping."
  else
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sh /tmp/get-docker.sh
    rm -f /tmp/get-docker.sh
    print_message 2 "Docker installed successfully!"
  fi
}

install_docker_compose() {
  print_message 4 "Installing Docker Compose ${DOCKER_COMPOSE_VERSION}..."

  if command -v docker-compose &>/dev/null; then
    print_message 2 "Docker Compose is already installed. Skipping."
  else
    curl -L "$DOCKER_COMPOSE_URL" -o "$DOCKER_COMPOSE_BIN"
    chmod +x "$DOCKER_COMPOSE_BIN"
    ln -sf "$DOCKER_COMPOSE_BIN" /usr/bin/docker-compose
    print_message 2 "Docker Compose installed successfully!"
  fi
}

install_go_tools() {
  print_message 4 "Installing Go ${GO_VERSION}..."

  if command -v go &>/dev/null; then
    print_message 2 "Go is already installed. Skipping."
    return 0
  fi

  local installer_script="/tmp/go-installer.sh"

  # Download installer script first
  if ! wget -q "$GO_INSTALLER_URL" -O "$installer_script"; then
    print_message 1 "Failed to download Go installer. Check your internet connection."
    return 1
  fi

  # Execute installer
  if log_output bash "$installer_script" --version "$GO_VERSION"; then
    print_message 2 "Go installed successfully!"
    rm -f "$installer_script"

    # Source Go environment
    export GOROOT="$HOME/.go"
    export GOPATH="$HOME/go"
    export PATH="$GOPATH/bin:$GOROOT/bin:$PATH"
  else
    print_message 1 "Go installation failed. Check log: $LOG_FILE"
    rm -f "$installer_script"
    return 1
  fi
}

install_pdtm() {
  print_message 4 "Installing PDTM (ProjectDiscovery Tool Manager)..."

  if command -v pdtm &>/dev/null; then
    print_message 2 "PDTM is already installed. Skipping."
    return 0
  fi

  # Ensure Go environment is set
  export GOROOT="${GOROOT:-$HOME/.go}"
  export GOPATH="${GOPATH:-$HOME/go}"
  export PATH="$GOPATH/bin:$GOROOT/bin:$PATH"

  if ! command -v go &>/dev/null; then
    print_message 1 "Go is not installed. Cannot install PDTM."
    return 1
  fi

  if log_output go install -v github.com/projectdiscovery/pdtm/cmd/pdtm@latest; then
    print_message 2 "PDTM installed successfully!"
  else
    print_message 1 "PDTM installation failed. Check log: $LOG_FILE"
    return 1
  fi
}

install_pentest_tools() {
  print_message 4 "Installing pentest tools: ${PENTEST_TOOLS[*]}"

  # Ensure PATH includes Go binaries
  export PATH="$HOME/go/bin:$HOME/.go/bin:$PATH"

  if command -v pdtm &>/dev/null; then
    pdtm -i "$(IFS=,; echo "${PENTEST_TOOLS[*]}")"
    print_message 2 "Pentest tools installed successfully!"
  else
    print_message 1 "PDTM is not available. Skipping pentest tools installation."
  fi
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

install_zsh() {
  print_message 4 "Installing Zsh and Oh My Zsh..."
  install_package "zsh"

  # Check if Oh My Zsh is already installed
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    print_message 2 "Oh My Zsh is already installed. Skipping."
  else
    # Install Oh My Zsh in unattended mode
    if [[ "$isNonInteractive" == true ]]; then
      RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
      RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
    print_message 2 "Oh My Zsh installed successfully!"
  fi

  # Change default shell to zsh (skip in non-interactive mode)
  if [[ "$isNonInteractive" != true ]]; then
    chsh -s "$(which zsh)"
  fi
}

setup_swap_alias() {
  print_message 4 "Setting up swap memory alias..."

  local zshrc="$HOME/.zshrc"
  local bashrc="$HOME/.bashrc"
  local alias_cmd='alias free_mem="sudo fallocate -l 8G /swap && sudo chmod 600 /swap && sudo mkswap /swap && sudo swapon /swap"'

  # Add to .zshrc if exists
  if [[ -f "$zshrc" ]]; then
    if ! grep -q "alias free_mem" "$zshrc"; then
      echo "" >> "$zshrc"
      echo "# Swap memory alias" >> "$zshrc"
      echo "$alias_cmd" >> "$zshrc"
      print_message 2 "Added free_mem alias to .zshrc"
    else
      print_message 2 "free_mem alias already exists in .zshrc"
    fi
  fi

  # Add to .bashrc if exists
  if [[ -f "$bashrc" ]]; then
    if ! grep -q "alias free_mem" "$bashrc"; then
      echo "" >> "$bashrc"
      echo "# Swap memory alias" >> "$bashrc"
      echo "$alias_cmd" >> "$bashrc"
      print_message 2 "Added free_mem alias to .bashrc"
    else
      print_message 2 "free_mem alias already exists in .bashrc"
    fi
  fi
}

install_tmux() {
  print_message 4 "Installing tmux..."
  install_package "tmux"

  # Install TPM (Tmux Plugin Manager)
  local tpm_dir="$HOME/.tmux/plugins/tpm"
  if [[ -d "$tpm_dir" ]]; then
    print_message 2 "TPM is already installed. Skipping."
  else
    print_message 4 "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    print_message 2 "TPM installed successfully!"
  fi
}

setup_tmux_config() {
  print_message 4 "Setting up tmux configuration..."

  local tmux_conf="$HOME/.tmux.conf"

  if [[ -f "$tmux_conf" ]]; then
    print_message 3 "Existing .tmux.conf found. Backing up to .tmux.conf.bak"
    cp "$tmux_conf" "${tmux_conf}.bak"
  fi

  cat > "$tmux_conf" << 'EOF'
# =============================================================================
# Tmux Configuration for Security Researchers
# =============================================================================

# Basic settings
set -g default-terminal "screen-256color"
set -g history-limit 50000      # Large scrollback for long enum outputs
set -g base-index 1             # Start windows from 1
setw -g pane-base-index 1
set -g escape-time 0            # No delay for vim
set -g status-keys vi
setw -g mode-keys vi            # Vi mode for copy/scroll
set -g mouse on                 # Mouse support (scroll, resize)
set -g renumber-windows on      # Renumber windows when one is closed

# Change prefix to C-a (easier than C-b)
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Reload config
bind r source-file ~/.tmux.conf \; display 'Config Reloaded!'

# Split panes (Vim style)
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Resize panes
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# Copy mode (Vi)
bind Escape copy-mode
bind p paste-buffer
bind -T copy-mode-vi v send-keys -X begin-selection
bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel

# Status bar (compatible with tmux 3.x)
set -g status-style bg=black,fg=white
set -g window-status-current-style bg=white,fg=black,bold
set -g status-interval 60
set -g status-left-length 30
set -g status-left '#[fg=green](#S) #(whoami) '
set -g status-right '#[fg=yellow]#(cut -d " " -f 1-3 /proc/loadavg)#[default] #[fg=white]%H:%M#[default]'

# Pane border colors
set -g pane-border-style fg=colour238
set -g pane-active-border-style fg=colour39

# Activity monitoring
setw -g monitor-activity on
set -g visual-activity off

# Plugins (install with prefix + I)
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-yank'        # Copy to system clipboard
set -g @plugin 'tmux-plugins/tmux-resurrect'   # Save/restore sessions

# Resurrect settings
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-strategy-vim 'session'

# Initialize TPM (keep at the end)
run '~/.tmux/plugins/tpm/tpm'
EOF

  print_message 2 "Tmux configuration created at $tmux_conf"
  print_message 3 "Note: Press prefix+I (Ctrl+A then I) to install plugins after starting tmux"
}

# Parse arguments
while getopts "nvh" opt; do
  case $opt in
    n) isNonInteractive=true ;;
    v) isVerbose=true ;;
    h) print_usage ;;
    ?) print_usage ;;
  esac
done

# Main Execution
print_message 6 "=== Pentesting Server Setup Script ==="
print_message 6 "Log file: $LOG_FILE"
echo ""

check_root
check_os

run_apt_update
install_package "curl"
install_package "wget"
install_package "git"
install_docker
install_docker_compose
install_package "make"
check_docker_status
install_go_tools
install_pdtm
install_pentest_tools
install_zsh
install_tmux
setup_tmux_config
setup_swap_alias

<<<<<<< HEAD
echo ""
print_message 2 "=== Setup completed successfully! ==="
print_message 6 "Log file saved to: $LOG_FILE"
print_message 3 "Notes:"
print_message 3 "  - Run 'source ~/.zshrc' or restart terminal to use new aliases"
print_message 3 "  - Start tmux and press Ctrl+A then I to install tmux plugins"
=======
print_message 2 "Setup completed successfully!"
>>>>>>> parent of 6577bed (Update setup.sh)
