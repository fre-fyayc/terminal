#!/usr/bin/env bash
# ==============================================================================
# sync-my-setup.sh - Personal Setup & Maintenance Script
# ==============================================================================
# Usage:
#   ./sync-my-setup.sh --rebuild    Rebuild/restore YOUR setup on this or a new Mac
#   ./sync-my-setup.sh --update     Export current Mac configs back into this repo
#   ./sync-my-setup.sh --status     Check status and differences with current system
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/utils.sh"

check_macos

show_usage() {
    print_header "Personal Setup Manager (iTerm2 + Vim + Shell)"
    echo -e "${BOLD}Usage:${RESET}"
    echo -e "  ${CYAN}./sync-my-setup.sh --rebuild${RESET}   Rebuild your exact setup (Homebrew, Fonts, iTerm2, Vim, Shell)"
    echo -e "  ${CYAN}./sync-my-setup.sh --update${RESET}    Export current setup from your Mac into this repo"
    echo -e "  ${CYAN}./sync-my-setup.sh --status${RESET}    Compare system files with repo files"
    echo -e "  ${CYAN}./sync-my-setup.sh --help${RESET}      Show this help message"
    echo ""
    echo -e "${DIM}Tip: You can also run ./rebuild-my-setup.sh or ./update-my-setup.sh directly.${RESET}"
    echo ""
}

rebuild_setup() {
    print_header "Rebuilding Your Personal Setup"
    log_info "Target machine: $(uname -m) macOS $(sw_vers -productVersion)"

    # 1. Homebrew & Dependencies
    log_step "1/5 Checking Homebrew & core tools..."
    ensure_homebrew

    # Casks
    log_info "Ensuring GUI apps and Nerd Fonts..."
    ensure_brew_cask "iterm2"
    ensure_brew_cask "font-fira-code-nerd-font"
    ensure_brew_cask "font-jetbrains-mono-nerd-font"

    # Formulas
    log_info "Ensuring terminal tools and formulas..."
    ensure_brew_formula "vim"
    ensure_brew_formula "antidote"
    ensure_brew_formula "starship"
    ensure_brew_formula "fastfetch"

    # 2. Restore Vim Configuration
    log_step "2/5 Restoring Vim configuration..."
    local vimrc_src="${SCRIPT_DIR}/configs/vim/vimrc"
    local vimrc_dest="${HOME}/.vimrc"
    if [[ -f "$vimrc_src" ]]; then
        install_file "$vimrc_src" "$vimrc_dest"
    else
        log_error "Vim configuration file missing: $vimrc_src"
        return 1
    fi

    # 3. Restore iTerm2 Setup
    log_step "3/5 Restoring iTerm2 setup (Dracula profile & colors)..."
    python3 "${SCRIPT_DIR}/scripts/iterm-manager.py" apply-user --repo-root "${SCRIPT_DIR}"

    # 4. Restore Shell Configuration
    log_step "4/5 Restoring Zsh, Starship & Antidote plugins..."
    install_file "${SCRIPT_DIR}/configs/shell/zsh_plugins.txt" "${HOME}/.zsh_plugins.txt"
    install_file "${SCRIPT_DIR}/configs/shell/starship.toml" "${HOME}/.config/starship.toml"
    install_file "${SCRIPT_DIR}/configs/shell/zshrc_aliases" "${HOME}/.config/zsh/zshrc_aliases"
    install_file "${SCRIPT_DIR}/configs/shell/zshrc" "${HOME}/.zshrc"

    # 5. Finalize
    log_step "5/5 Finalizing..."
    log_success "All configurations restored successfully!"
    echo ""
    echo -e "${BOLD}${GREEN}✔ Rebuild complete!${RESET}"
    echo -e "  • ${WHITE}Vim:${RESET} ~/.vimrc (clipboard sync, 24-bit truecolor, line numbers)"
    echo -e "  • ${WHITE}iTerm2:${RESET} Dracula profile with FiraCode NF & JetBrains Mono NF (active via Dynamic Profiles)"
    echo -e "  • ${WHITE}Shell:${RESET} Antidote plugins + Starship Dracula prompt"
    echo ""
    echo -e "${DIM}Note: Restart iTerm2 or run 'exec zsh' to enjoy your updated environment.${RESET}"
}

update_setup() {
    print_header "Exporting Current Setup to Repo"
    log_info "Reading configurations from current user environment ($HOME)..."

    # 1. Export Vim
    log_step "1/3 Exporting Vim configuration..."
    if [[ -f "${HOME}/.vimrc" ]]; then
        cp "${HOME}/.vimrc" "${SCRIPT_DIR}/configs/vim/vimrc"
        log_success "Exported ~/.vimrc -> configs/vim/vimrc"
    else
        log_warn "~/.vimrc not found on system."
    fi

    # 2. Export iTerm2
    log_step "2/3 Exporting iTerm2 profiles & color presets..."
    python3 "${SCRIPT_DIR}/scripts/iterm-manager.py" export-user --repo-root "${SCRIPT_DIR}"

    # 3. Export Shell
    log_step "3/3 Exporting Shell & Starship configurations..."
    if [[ -f "${HOME}/.zshrc" ]]; then
        cp "${HOME}/.zshrc" "${SCRIPT_DIR}/configs/shell/zshrc"
        # Sanitize personal username to $HOME for portability
        sed -i '' "s|/Users/${USER}/\.local/bin|\$HOME/\.local/bin|g" "${SCRIPT_DIR}/configs/shell/zshrc" 2>/dev/null || true
        log_success "Exported ~/.zshrc -> configs/shell/zshrc"
    fi

    if [[ -f "${HOME}/.zsh_plugins.txt" ]]; then
        cp "${HOME}/.zsh_plugins.txt" "${SCRIPT_DIR}/configs/shell/zsh_plugins.txt"
        log_success "Exported ~/.zsh_plugins.txt -> configs/shell/zsh_plugins.txt"
    fi

    if [[ -f "${HOME}/.config/starship.toml" ]]; then
        cp "${HOME}/.config/starship.toml" "${SCRIPT_DIR}/configs/shell/starship.toml"
        log_success "Exported ~/.config/starship.toml -> configs/shell/starship.toml"
    fi

    if [[ -f "${HOME}/.config/zsh/zshrc_aliases" ]]; then
        cp "${HOME}/.config/zsh/zshrc_aliases" "${SCRIPT_DIR}/configs/shell/zshrc_aliases"
        sed -i '' "s|/Users/${USER}|~|g" "${SCRIPT_DIR}/configs/shell/zshrc_aliases" 2>/dev/null || true
        log_success "Exported ~/.config/zsh/zshrc_aliases -> configs/shell/zshrc_aliases"
    fi

    echo ""
    log_step "Repository Status:"
    cd "${SCRIPT_DIR}"
    if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git status -s
        echo ""
        log_info "To save and commit these changes, run:"
        echo -e "  ${CYAN}git add . && git commit -m \"Update terminal configuration\"${RESET}"
    fi
    log_success "Export complete!"
}

status_setup() {
    print_header "Configuration Status Comparison"
    local files=(
        "${HOME}/.vimrc:${SCRIPT_DIR}/configs/vim/vimrc:Vim configuration"
        "${HOME}/.zshrc:${SCRIPT_DIR}/configs/shell/zshrc:Zsh configuration"
        "${HOME}/.zsh_plugins.txt:${SCRIPT_DIR}/configs/shell/zsh_plugins.txt:Zsh plugins"
        "${HOME}/.config/starship.toml:${SCRIPT_DIR}/configs/shell/starship.toml:Starship configuration"
        "${HOME}/.config/zsh/zshrc_aliases:${SCRIPT_DIR}/configs/shell/zshrc_aliases:Zsh aliases"
    )

    for item in "${files[@]}"; do
        IFS=":" read -r sys_file repo_file desc <<< "$item"
        if [[ ! -f "$sys_file" ]]; then
            log_warn "$desc: Missing on system ($sys_file)"
        elif [[ ! -f "$repo_file" ]]; then
            log_warn "$desc: Missing in repo ($repo_file)"
        elif cmp -s "$sys_file" "$repo_file"; then
            log_success "$desc: In sync"
        else
            log_warn "$desc: Has differences between system and repo"
            echo -e "      ${DIM}diff -u $repo_file $sys_file${RESET}"
        fi
    done
}

ACTION="${1:-}"
case "$ACTION" in
    --rebuild|-r|rebuild)
        rebuild_setup
        ;;
    --update|-u|update|--export|-e|export)
        update_setup
        ;;
    --status|-s|status)
        status_setup
        ;;
    --help|-h|help)
        show_usage
        ;;
    "")
        show_usage
        ;;
    *)
        log_error "Unknown option: $ACTION"
        show_usage
        exit 1
        ;;
esac
