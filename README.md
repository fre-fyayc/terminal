# macOS Terminal & Vim Setup

> **New to Terminal or non-technical?** Start with the step-by-step **[Getting Started Guide (GETTING-STARTED.md)](./GETTING-STARTED.md)**.

A clean, reproducible setup for **iTerm2**, **Vim**, **Nerd Fonts**, and **Zsh / Starship**, split into two workflows:
1. **Personal Setup (`sync-my-setup.sh`)**: Rebuilds your exact environment on any Mac and lets you export updates from your current Mac back into this repository.
2. **Colleague Installer (`install-colleague.sh`)**: Interactive onboarding script for colleagues with choices for themes, fonts, transparency, and optional shell enhancements.

---

## 1. For You (Personal Rebuild & Sync)

### Rebuild your setup on a new or freshly wiped Mac
```bash
./rebuild-my-setup.sh
# or: ./sync-my-setup.sh --rebuild
```
What this does:
- Installs Homebrew (if missing)
- Installs `iterm2`, `font-fira-code-nerd-font`, `font-jetbrains-mono-nerd-font`
- Installs `vim` (with `+clipboard`), `antidote`, `starship`, and `fastfetch`
- Restores your exact `~/.vimrc`
- Restores your **Dracula** iTerm2 profile (FiraCode NF 12, JetBrains Mono NF 12 for non-ASCII, 15% transparency, 135×35 window) and sets it as default
- Restores `~/.zshrc`, `~/.zsh_plugins.txt`, `~/.config/starship.toml`, and `~/.config/zsh/zshrc_aliases`

### Update this repository after you tweak your Mac
Whenever you change your `.vimrc`, iTerm2 colors/profile, or Zsh/Starship configuration:
```bash
./update-my-setup.sh
# or: ./sync-my-setup.sh --update
```
This exports your live configs back into `configs/` (sanitizing home paths for portability) and displays `git status` so you can commit and push.

### Check sync status
```bash
./sync-my-setup.sh --status
```

---

## 2. For Colleagues (Customizable Installer)

Run the interactive wizard:
```bash
./install-colleague.sh
```

Colleagues can customize:
- **Themes**:
  - `Dracula` (Team Standard)
  - `Catppuccin-Mocha`
  - `Catppuccin-Latte`
  - `Tokyo-Night`
  - `Nord`
  - `Gruvbox-Dark`
  - `One-Dark`
  - `Solarized-Dark`
- **Fonts**: FiraCode Nerd Font + JetBrains Mono Nerd Font (recommended), either individually, or skip
- **Transparency**: Subtle 15% transparency or solid 0% background
- **Vim**: Installs the curated `~/.vimrc` (Vim 9 defaults, relative line numbers, macOS clipboard sharing, 24-bit truecolor, 4-space tabs, `Space` leader, `Ctrl+hjkl` split navigation)
- **Optional Shell Prompt**: Opt-in **Starship** prompt (auto-styled to match their chosen iTerm2 theme!) and **Antidote** Zsh plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions`)

Existing dotfiles (`~/.vimrc`, `~/.zshrc`, `~/.config/starship.toml`) are always backed up with a timestamp before any changes are made.

### Non-interactive mode
```bash
./install-colleague.sh --theme tokyo-night --font both --transparency 0.15 --with-shell --yes
```
Run `./install-colleague.sh --help` for all flags.

---

## Repository Structure

```text
terminal/
├── rebuild-my-setup.sh        # Shortcut for ./sync-my-setup.sh --rebuild
├── update-my-setup.sh         # Shortcut for ./sync-my-setup.sh --update
├── sync-my-setup.sh           # Personal rebuild, export, and status tool
├── install-colleague.sh       # Interactive & CLI installer for colleagues
├── configs/
│   ├── vim/vimrc              # Curated Vim configuration
│   ├── iterm2/
│   │   ├── com.googlecode.iterm2.plist
│   │   ├── DynamicProfiles/   # Live-reloaded iTerm2 profile JSON
│   │   └── presets/           # .itermcolors files for all supported themes
│   └── shell/                 # Zsh, Antidote plugins, aliases, Starship config
└── scripts/
    ├── iterm-manager.py       # Python helper for iTerm2 plist & Dynamic Profiles
    ├── starship-styler.py     # Generates theme-matched starship.toml
    └── utils.sh               # Shared bash logging, Homebrew, and backup helpers
```

---

## Vim Quick Reference (`~/.vimrc`)

| Key / Setting | Behavior |
|---|---|
| `Leader` | `Space` |
| `<Space> + n` | Clear search highlight (`:nohlsearch`) |
| `Ctrl + h/j/k/l` | Move between split panes |
| `y` / `p` | Shares directly with macOS clipboard (`unnamed`) |
| Line numbers | Hybrid (`number` + `relativenumber`) |
| Indentation | 4 spaces (`expandtab`, `smarttab`) |
