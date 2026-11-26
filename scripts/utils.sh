#!/usr/bin/env bash
# ==============================================================================
# scripts/utils.sh - Shared utility functions for terminal setup scripts
# ==============================================================================

# ANSI Color codes
BOLD="\033[1m"
DIM="\033[2m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[1;37m"
RESET="\033[0m"

log_info() {
    echo -e "${BLUE}ℹ${RESET}  $*"
}

log_success() {
    echo -e "${GREEN}✔${RESET}  $*"
}

log_warn() {
    echo -e "${YELLOW}▲${RESET}  $*"
}

log_error() {
    echo -e "${RED}✖${RESET}  $*" >&2
}

log_step() {
    echo -e "\n${BOLD}${CYAN}==>${RESET} ${BOLD}$*${RESET}"
}

print_header() {
    local title="$1"
    local width=64
    echo ""
    echo -e "${MAGENTA}┌$(printf '─%.0s' $(seq 1 $width))┐${RESET}"
    printf "${MAGENTA}│${RESET}  ${BOLD}%-62s${RESET}${MAGENTA}│\n" "$title"
    echo -e "${MAGENTA}└$(printf '─%.0s' $(seq 1 $width))┘${RESET}"
    echo ""
}

# Ensure Homebrew is available
ensure_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        log_success "Homebrew is installed: $(brew --version | head -n1)"
        return 0
    fi

    # Check default paths on Apple Silicon or Intel
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        log_success "Homebrew detected in /opt/homebrew"
        return 0
    elif [[ -x "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
        log_success "Homebrew detected in /usr/local"
        return 0
    fi

    log_warn "Homebrew is not installed."
    read -rp "Would you like to install Homebrew now? [Y/n] " response
    case "$response" in
        [nN][oO]|[nN])
            log_error "Homebrew is required to install fonts, iTerm2, and tools. Aborting."
            return 1
            ;;
        *)
            log_step "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            if [[ -x "/opt/homebrew/bin/brew" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [[ -x "/usr/local/bin/brew" ]]; then
                eval "$(/usr/local/bin/brew shellenv)"
            fi
            ;;
    esac
}

# Ensure a Homebrew formula is installed
ensure_brew_formula() {
    local formula="$1"
    if brew list --formula "$formula" >/dev/null 2>&1; then
        log_info "Homebrew formula already installed: $formula"
    else
        log_step "Installing formula: $formula"
        brew install "$formula"
    fi
}

# Ensure a Homebrew cask is installed
ensure_brew_cask() {
    local cask="$1"
    if brew list --cask "$cask" >/dev/null 2>&1; then
        log_info "Homebrew cask already installed: $cask"
    else
        log_step "Installing cask: $cask"
        brew install --cask "$cask"
    fi
}

# Backup existing file with timestamp
backup_file() {
    local target="$1"
    if [[ -e "$target" || -L "$target" ]]; then
        local timestamp
        timestamp="$(date +%Y%m%d_%H%M%S)"
        local backup="${target}.backup.${timestamp}"
        cp -a "$target" "$backup"
        log_warn "Existing file found: $target -> backed up to: $backup"
    fi
}

# Safe install file (backup if exists, then copy)
install_file() {
    local src="$1"
    local dest="$2"
    local dest_dir
    dest_dir="$(dirname "$dest")"
    mkdir -p "$dest_dir"

    if [[ -f "$dest" ]]; then
        if cmp -s "$src" "$dest"; then
            log_info "File unchanged: $dest"
            return 0
        fi
        backup_file "$dest"
    fi

    cp "$src" "$dest"
    log_success "Installed: $dest"
}

# Check if running on macOS
check_macos() {
    if [[ "$(uname -s)" != "Darwin" ]]; then
        log_error "This script is designed specifically for macOS."
        exit 1
    fi
}
