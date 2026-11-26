#!/usr/bin/env python3
"""
starship-styler.py - Generates Starship prompt configuration matching the chosen terminal theme.
"""

import sys
import argparse
from pathlib import Path

THEME_PALETTES = {
    "Dracula": {
        "user": "#bd93f9",
        "dir": "#6272a4",
        "git": "#ff79c6",
        "lang": "#8be9fd",
        "docker": "#50fa7b",
        "time": "#44475a",
        "fg_dark": "#282a36",
        "fg_light": "#f8f8f2",
    },
    "Catppuccin-Mocha": {
        "user": "#cba6f7",   # Mauve
        "dir": "#45475a",    # Surface1
        "git": "#f5c2e7",    # Pink
        "lang": "#89dceb",   # Sky
        "docker": "#a6e3a1", # Green
        "time": "#313244",   # Surface0
        "fg_dark": "#1e1e2e",
        "fg_light": "#cdd6f4",
    },
    "Catppuccin-Latte": {
        "user": "#8839ef",   # Mauve
        "dir": "#acb0be",    # Surface1
        "git": "#ea76cb",    # Pink
        "lang": "#179299",   # Teal
        "docker": "#40a02b", # Green
        "time": "#ccd0da",   # Surface0
        "fg_dark": "#4c4f69",
        "fg_light": "#eff1f5",
    },
    "Tokyo-Night": {
        "user": "#bb9af7",
        "dir": "#283457",
        "git": "#f7768e",
        "lang": "#7dcfff",
        "docker": "#9ece6a",
        "time": "#414868",
        "fg_dark": "#1a1b26",
        "fg_light": "#c0caf5",
    },
    "Nord": {
        "user": "#b48ead",
        "dir": "#434c5e",
        "git": "#bf616a",
        "lang": "#88c0d0",
        "docker": "#a3be8c",
        "time": "#4c566a",
        "fg_dark": "#2e3440",
        "fg_light": "#eceff4",
    },
    "Gruvbox-Dark": {
        "user": "#d3869b",
        "dir": "#504945",
        "git": "#fb4934",
        "lang": "#8ec07c",
        "docker": "#b8bb26",
        "time": "#3c3836",
        "fg_dark": "#282828",
        "fg_light": "#ebdbb2",
    },
    "One-Dark": {
        "user": "#c678dd",
        "dir": "#3e4451",
        "git": "#e06c75",
        "lang": "#56b6c2",
        "docker": "#98c379",
        "time": "#4b5263",
        "fg_dark": "#282c34",
        "fg_light": "#abb2bf",
    },
    "Solarized-Dark": {
        "user": "#6c71c4",
        "dir": "#073642",
        "git": "#dc322f",
        "lang": "#2aa198",
        "docker": "#859900",
        "time": "#586e75",
        "fg_dark": "#002b36",
        "fg_light": "#93a1a1",
    }
}


def generate_starship_config(theme_name, output_path=None):
    palette = THEME_PALETTES.get(theme_name, THEME_PALETTES["Dracula"])
    u = palette["user"]
    d = palette["dir"]
    g = palette["git"]
    l = palette["lang"]
    doc = palette["docker"]
    t = palette["time"]
    f_dark = palette["fg_dark"]
    f_light = palette["fg_light"]

    content = f'''"$schema" = 'https://starship.rs/config-schema.json'

# Palette: {theme_name}
# Username:      {u}
# Directory:     {d}
# Git:           {g}
# Languages:     {l}
# Docker:        {doc}
# Time:          {t}

format = """
[]({u})\\
$os\\
$username\\
[](bg:{d} fg:{u})\\
$directory\\
[](fg:{d} bg:{g})\\
$git_branch\\
$git_status\\
[](fg:{g} bg:{l})\\
$c\\
$cpp\\
$elixir\\
$elm\\
$golang\\
$gradle\\
$haskell\\
$java\\
$julia\\
$maven\\
$nodejs\\
$bun\\
$nim\\
$rust\\
$scala\\
[](fg:{l} bg:{doc})\\
$docker_context\\
[](fg:{doc} bg:{t})\\
$time\\
[ ](fg:{t})\\
"""

[username]
show_always = true
style_user = "bg:{u} fg:{f_dark} bold"
style_root = "bg:{u} fg:{f_dark} bold"
format = '[$user ]($style)'
disabled = false

[os]
style = "bg:{u} fg:{f_dark}"
disabled = true

[directory]
style = "bg:{d} fg:{f_light}"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[directory.substitutions]
"Documents" = "󰈙 "
"Downloads" = " "
"Music" = " "
"Pictures" = " "

[git_branch]
symbol = ""
style = "bg:{g} fg:{f_dark} bold"
format = '[ $symbol $branch ]($style)'

[git_status]
style = "bg:{g} fg:{f_dark}"
format = '[$all_status$ahead_behind ]($style)'

[jj_bookmark]
symbol = ""
style = "bg:{g} fg:{f_dark}"
format = '[ $symbol $bookmark(@$remote)$diverged( \\\\(+$overflow_count others\\\\)) ]($style)'

[jj_status]
style = "bg:{g} fg:{f_dark}"
format = '[$all ]($style)'

# --- Programmiersprachen & Runtimes ---

[c]
symbol = " "
style = "bg:{l} fg:{f_dark}"
format = '[ $symbol ($version) ]($style)'

[cpp]
symbol = " "
style = "bg:{l} fg:{f_dark}"
format = '[ $symbol ($version) ]($style)'

[elixir]
symbol = " "
style = "bg:{l} fg:{f_dark}"
format = '[ $symbol ($version) ]($style)'

[elm]
symbol = " "
style = "bg:{l} fg:{f_dark}"
format = '[ $symbol ($version) ]($style)'

[golang]
symbol = " "
style = "bg:{l} fg:{f_dark}"
format = '[ $symbol ($version) ]($style)'

[gradle]
symbol = " "
style = "bg:{l} fg:{f_dark}"
format = '[ $symbol ($version) ]($style)'

[haskell]
symbol = " "
style = "bg:{l} fg:{f_dark}"
format = '[ $symbol ($version) ]($style)'

[java]
symbol = " "
style = "bg:{l} fg:{f_dark}"
format = '[ $symbol ($version) ]($style)'

[julia]
symbol = " "
style = "bg:{l} fg:{f_dark}"
format = '[ $symbol ($version) ]($style)'

[maven]
symbol = " "
style = "bg:{l} fg:{f_dark}"
format = '[ $symbol ($version) ]($style)'

[nodejs]
symbol = ""
style = "bg:{l} fg:{f_dark}"
format = '[ $symbol ($version) ]($style)'

[bun]
symbol = ""
style = "bg:{l} fg:{f_dark}"
format = '[ $symbol ($version) ]($style)'

[nim]
symbol = "󰆥 "
style = "bg:{l} fg:{f_dark}"
format = '[ $symbol ($version) ]($style)'

[rust]
symbol = ""
style = "bg:{l} fg:{f_dark}"
format = '[ $symbol ($version) ]($style)'

[scala]
symbol = " "
style = "bg:{l} fg:{f_dark}"
format = '[ $symbol ($version) ]($style)'

# --- Tools & Status ---

[docker_context]
symbol = " "
style = "bg:{doc} fg:{f_dark}"
format = '[ $symbol $context ]($style)'

[time]
disabled = false
time_format = "%R"
style = "bg:{t} fg:{f_light}"
format = '[ ♥ $time ]($style)'
'''
    if output_path:
        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"✓ Generated Starship configuration for {theme_name}: {output_path}")
    else:
        print(content)


def main():
    parser = argparse.ArgumentParser(description="Generate themed starship.toml")
    parser.add_argument("--theme", default="Dracula", choices=list(THEME_PALETTES.keys()))
    parser.add_argument("--output", "-o", help="Output file path")
    args = parser.parse_args()

    generate_starship_config(args.theme, args.output)


if __name__ == "__main__":
    main()
