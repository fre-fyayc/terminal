#!/usr/bin/env bash
# ==============================================================================
# install-colleague.sh - Team Terminal & Vim Onboarding Setup Script
# ==============================================================================
# Interactive installer for colleagues to set up a unified, high-productivity
# macOS terminal environment (iTerm2, Vim, Nerd Fonts, optional Starship prompt)
# with customizable themes and fonts.
#
# Usage:
#   ./install-colleague.sh                  # Interactive guided setup
#   ./install-colleague.sh --help           # Show command-line options
#   ./install-colleague.sh --theme tokyo-night --font both --yes
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/utils.sh"

check_macos

# Defaults
CHOSEN_THEME="Dracula"
CHOSEN_FONT="both"         # both | firacode | jetbrains | none
CHOSEN_TRANSPARENCY="0.15" # 0.15 (15%) or 0.0 (opaque)
INSTALL_SHELL="ask"        # yes | no | ask
NON_INTERACTIVE=false

# Available Themes
THEME_KEYS=(
    "Dracula"
    "Catppuccin-Mocha"
    "Catppuccin-Latte"
    "Tokyo-Night"
    "Nord"
    "Gruvbox-Dark"
    "One-Dark"
    "Solarized-Dark"
)

THEME_NAMES=(
    "Dracula (Team Standard - Vibrant dark with purple/pink accents)"
    "Catppuccin Mocha (Soothing, pastel dark aesthetic)"
    "Catppuccin Latte (Clean, elegant light theme)"
    "Tokyo Night (Modern dark palette with neon blue/magenta)"
    "Nord (Arctic, calm, north-bluish palette)"
    "Gruvbox Dark (Warm, retro groove earthy palette)"
    "One Dark (Iconic Atom / VS Code dark palette)"
    "Solarized Dark (Scientifically tuned low-contrast dark)"
)

show_help() {
    print_header "Team Terminal & Vim Installer"
    echo -e "${BOLD}Usage:${RESET}"
    echo -e "  ${CYAN}./install-colleague.sh${RESET} [OPTIONS]"
    echo ""
    echo -e "${BOLD}Options:${RESET}"
    echo -e "  ${WHITE}--theme <name>${RESET}        Theme choice (${CYAN}dracula${RESET}, ${CYAN}catppuccin-mocha${RESET}, ${CYAN}catppuccin-latte${RESET}, ${CYAN}tokyo-night${RESET}, ${CYAN}nord${RESET}, ${CYAN}gruvbox-dark${RESET}, ${CYAN}one-dark${RESET}, ${CYAN}solarized-dark${RESET})"
    echo -e "  ${WHITE}--font <choice>${RESET}       Font choice (${CYAN}both${RESET}, ${CYAN}firacode${RESET}, ${CYAN}jetbrains${RESET}, ${CYAN}none${RESET})"
    echo -e "  ${WHITE}--transparency <val>${RESET}  Window background transparency, e.g. ${CYAN}0.15${RESET} or ${CYAN}0.0${RESET} (solid)"
    echo -e "  ${WHITE}--with-shell${RESET}          Install Starship prompt & Zsh plugins matching the theme"
    echo -e "  ${WHITE}--no-shell${RESET}            Skip Starship & Zsh plugins (only configure iTerm2 and Vim)"
    echo -e "  ${WHITE}-y, --yes${RESET}             Non-interactive mode (use defaults or specified flags)"
    echo -e "  ${WHITE}-h, --help${RESET}            Show this help message"
    echo ""
}

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --theme)
            arg_lower="$(echo "$2" | tr '[:upper:]' '[:lower:]')"
            matched=false
            for k in "${THEME_KEYS[@]}"; do
                k_lower="$(echo "$k" | tr '[:upper:]' '[:lower:]')"
                if [[ "$arg_lower" == "$k_lower" ]]; then
                    CHOSEN_THEME="$k"
                    matched=true
                    break
                fi
            done
            if [[ "$matched" == false ]]; then
                log_error "Unknown theme: $2"
                exit 1
            fi
            shift 2
            ;;
        --font)
            CHOSEN_FONT="$2"
            shift 2
            ;;
        --transparency)
            CHOSEN_TRANSPARENCY="$2"
            shift 2
            ;;
        --with-shell)
            INSTALL_SHELL="yes"
            shift
            ;;
        --no-shell)
            INSTALL_SHELL="no"
            shift
            ;;
        -y|--yes)
            NON_INTERACTIVE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Interactive Wizard
if [[ "$NON_INTERACTIVE" == false ]]; then
    print_header "Welcome to the Team Terminal Setup Wizard"
    echo -e "This script sets up a blazing fast, beautifully themed terminal environment on macOS:"
    echo -e "  ✔ ${WHITE}Vim:${RESET} Ergonomic configuration (macOS clipboard sync, line numbers, 4-space indent, split navigation)"
    echo -e "  ✔ ${WHITE}iTerm2:${RESET} Custom profile, Nerd Fonts, window styling, and color presets"
    echo -e "  ✔ ${WHITE}Safety:${RESET} Existing configuration files are always backed up with timestamps first"
    echo ""

    # 1. Theme Choice
    echo -e "${BOLD}${CYAN}[1/4] Select a Color Theme:${RESET}"
    for i in "${!THEME_NAMES[@]}"; do
        idx=$((i + 1))
        if [[ $idx -eq 1 ]]; then
            echo -e "  ${BOLD}${GREEN}${idx})${RESET} ${THEME_NAMES[$i]} ${YELLOW}(Default)${RESET}"
        else
            echo -e "  ${BOLD}${CYAN}${idx})${RESET} ${THEME_NAMES[$i]}"
        fi
    done
    read -rp "Enter choice [1-${#THEME_NAMES[@]}] (Default 1): " theme_input
    theme_input="${theme_input:-1}"
    if [[ "$theme_input" =~ ^[1-8]$ ]]; then
        CHOSEN_THEME="${THEME_KEYS[$((theme_input - 1))]}"
    else
        log_warn "Invalid selection. Defaulting to Dracula."
        CHOSEN_THEME="Dracula"
    fi
    log_success "Selected theme: ${BOLD}${CHOSEN_THEME}${RESET}\n"

    # 2. Font Choice
    echo -e "${BOLD}${CYAN}[2/4] Select Font Installation:${RESET}"
    echo -e "  ${BOLD}${GREEN}1)${RESET} FiraCode Nerd Font + JetBrains Mono Nerd Font ${YELLOW}(Recommended)${RESET}"
    echo -e "  ${BOLD}${CYAN}2)${RESET} FiraCode Nerd Font only"
    echo -e "  ${BOLD}${CYAN}3)${RESET} JetBrains Mono Nerd Font only"
    echo -e "  ${BOLD}${CYAN}4)${RESET} Skip font installation (use current system fonts)"
    read -rp "Enter choice [1-4] (Default 1): " font_input
    font_input="${font_input:-1}"
    case "$font_input" in
        1) CHOSEN_FONT="both" ;;
        2) CHOSEN_FONT="firacode" ;;
        3) CHOSEN_FONT="jetbrains" ;;
        4) CHOSEN_FONT="none" ;;
        *) CHOSEN_FONT="both" ;;
    esac
    log_success "Selected font option: ${BOLD}${CHOSEN_FONT}${RESET}\n"

    # 3. Transparency
    echo -e "${BOLD}${CYAN}[3/4] Window Transparency:${RESET}"
    echo -e "  ${BOLD}${GREEN}1)${RESET} Subtle glass transparency (15%) ${YELLOW}(Recommended)${RESET}"
    echo -e "  ${BOLD}${CYAN}2)${RESET} Solid opaque background (0%)"
    read -rp "Enter choice [1-2] (Default 1): " trans_input
    trans_input="${trans_input:-1}"
    if [[ "$trans_input" == "2" ]]; then
        CHOSEN_TRANSPARENCY="0.0"
    else
        CHOSEN_TRANSPARENCY="0.15"
    fi
    log_success "Transparency set to: ${BOLD}${CHOSEN_TRANSPARENCY}${RESET}\n"

    # 4. Optional Shell & Prompt
    if [[ "$INSTALL_SHELL" == "ask" ]]; then
        echo -e "${BOLD}${CYAN}[4/4] Shell Prompt & Plugins:${RESET}"
        echo -e "Would you like to install the ${BOLD}Starship prompt${RESET} (styled in ${CHOSEN_THEME})"
        echo -e "and ${BOLD}Antidote plugins${RESET} (command autosuggestions & syntax highlighting)?"
        read -rp "Install Starship + plugins? [y/N]: " shell_input
        case "$shell_input" in
            [yY][eE][sS]|[yY])
                INSTALL_SHELL="yes"
                ;;
            *)
                INSTALL_SHELL="no"
                ;;
        esac
    fi
    echo ""
fi

# Execution Summary
echo -e "${BOLD}Configuration to be applied:${RESET}"
echo -e "  • Theme:        ${MAGENTA}${CHOSEN_THEME}${RESET}"
echo -e "  • Fonts:        ${CYAN}${CHOSEN_FONT}${RESET}"
echo -e "  • Transparency: ${YELLOW}${CHOSEN_TRANSPARENCY}${RESET}"
echo -e "  • Vim Setup:    ${GREEN}Yes (~/.vimrc with macOS clipboard + 24-bit color)${RESET}"
echo -e "  • Shell Prompt: $([[ "$INSTALL_SHELL" == "yes" ]] && echo -e "${GREEN}Yes (Starship + Antidote)${RESET}" || echo -e "${DIM}Skipped${RESET}")"
echo ""

if [[ "$NON_INTERACTIVE" == false ]]; then
    read -rp "Proceed with installation? [Y/n] " proceed
    case "$proceed" in
        [nN][oO]|[nN])
            log_info "Installation cancelled by user."
            exit 0
            ;;
    esac
fi

# ==============================================================================
# Step 1: Homebrew & Dependencies
# ==============================================================================
log_step "Step 1: Checking Homebrew..."
ensure_homebrew

# Cask: iTerm2
log_info "Ensuring iTerm2 is installed..."
ensure_brew_cask "iterm2"

# Casks: Fonts
normal_font="Monaco 12"
non_ascii_font="Monaco 12"

case "$CHOSEN_FONT" in
    both)
        log_info "Installing FiraCode Nerd Font and JetBrains Mono Nerd Font..."
        ensure_brew_cask "font-fira-code-nerd-font"
        ensure_brew_cask "font-jetbrains-mono-nerd-font"
        normal_font="FiraCodeNF-Reg 12"
        non_ascii_font="JetBrainsMonoNF-Regular 12"
        ;;
    firacode)
        log_info "Installing FiraCode Nerd Font..."
        ensure_brew_cask "font-fira-code-nerd-font"
        normal_font="FiraCodeNF-Reg 12"
        non_ascii_font="FiraCodeNF-Reg 12"
        ;;
    jetbrains)
        log_info "Installing JetBrains Mono Nerd Font..."
        ensure_brew_cask "font-jetbrains-mono-nerd-font"
        normal_font="JetBrainsMonoNF-Regular 12"
        non_ascii_font="JetBrainsMonoNF-Regular 12"
        ;;
    none)
        log_info "Skipping font installation."
        ;;
esac

# Vim formula (Homebrew Vim includes +clipboard for Mac pasteboard sharing)
log_info "Ensuring Vim formula is installed (with +clipboard support)..."
ensure_brew_formula "vim"

# ==============================================================================
# Step 2: Vim Configuration
# ==============================================================================
log_step "Step 2: Installing Vim configuration..."
install_file "${SCRIPT_DIR}/configs/vim/vimrc" "${HOME}/.vimrc"

# ==============================================================================
# Step 3: iTerm2 Setup
# ==============================================================================
log_step "Step 3: Configuring iTerm2 Profile (${CHOSEN_THEME})..."

preset_file="${SCRIPT_DIR}/configs/iterm2/presets/${CHOSEN_THEME}.itermcolors"
if [[ ! -f "$preset_file" ]]; then
    log_warn "Preset not found at $preset_file. Generating presets..."
    python3 "${SCRIPT_DIR}/scripts/iterm-manager.py" export-user --repo-root "${SCRIPT_DIR}"
fi

python3 "${SCRIPT_DIR}/scripts/iterm-manager.py" apply-theme \
    --name "${CHOSEN_THEME}" \
    --preset "$preset_file" \
    --font "$normal_font" \
    --non-ascii-font "$non_ascii_font" \
    --transparency "$CHOSEN_TRANSPARENCY"

# ==============================================================================
# Step 4: Shell & Prompt Configuration (Optional)
# ==============================================================================
if [[ "$INSTALL_SHELL" == "yes" ]]; then
    log_step "Step 4: Installing Starship & Zsh Plugins..."
    ensure_brew_formula "starship"
    ensure_brew_formula "antidote"

    # 1. Generate themed starship.toml
    mkdir -p "${HOME}/.config"
    backup_file "${HOME}/.config/starship.toml"
    python3 "${SCRIPT_DIR}/scripts/starship-styler.py" \
        --theme "${CHOSEN_THEME}" \
        --output "${HOME}/.config/starship.toml"

    # 2. Install plugins file
    install_file "${SCRIPT_DIR}/configs/shell/zsh_plugins.txt" "${HOME}/.zsh_plugins.txt"

    # 3. Configure ~/.zshrc
    mkdir -p "${HOME}/.config/zsh"
    install_file "${SCRIPT_DIR}/configs/shell/zshrc_aliases" "${HOME}/.config/zsh/zshrc_aliases"

    # Safely ensure ~/.zshrc sources antidote and starship
    if [[ -f "${HOME}/.zshrc" ]]; then
        # Check if already has starship
        if ! grep -q "starship init zsh" "${HOME}/.zshrc"; then
            backup_file "${HOME}/.zshrc"
            cat << 'EOF' >> "${HOME}/.zshrc"

# --- Added by Terminal Team Setup ---
if [[ -d "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote" ]]; then
  source "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote/antidote.zsh"
  antidote load
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

if [[ -f "$HOME/.config/zsh/zshrc_aliases" ]]; then
  source "$HOME/.config/zsh/zshrc_aliases"
fi
# ------------------------------------
EOF
            log_success "Updated ~/.zshrc with Starship and Antidote integrations"
        else
            log_info "~/.zshrc already contains starship initialization"
        fi
    else
        install_file "${SCRIPT_DIR}/configs/shell/zshrc" "${HOME}/.zshrc"
    fi
else
    log_step "Step 4: Skipping Shell & Starship installation."
fi

# ==============================================================================
# Finish
# ==============================================================================
print_header "Setup Successfully Completed!"
echo -e "${BOLD}${GREEN}✔ Installation Finished!${RESET}"
echo -e "  • ${WHITE}Theme:${RESET} ${CHOSEN_THEME}"
echo -e "  • ${WHITE}Vim:${RESET} ~/.vimrc (clipboard sharing, relative numbers, 4-space tabs, split navigation)"
echo -e "  • ${WHITE}iTerm2:${RESET} New profile '${CHOSEN_THEME}' is ready in iTerm2"
echo ""
echo -e "${BOLD}Next Steps:${RESET}"
echo -e "  1. Open ${BOLD}iTerm2${RESET}."
echo -e "  2. Go to ${BOLD}iTerm2 > Preferences > Profiles${RESET}."
echo -e "  3. Select '${BOLD}${CHOSEN_THEME}${RESET}' (it is automatically loaded via Dynamic Profiles!)."
if [[ "$INSTALL_SHELL" == "yes" ]]; then
    echo -e "  4. Reload your shell by typing: ${CYAN}source ~/.zshrc${RESET} or ${CYAN}exec zsh${RESET}"
fi
echo ""
