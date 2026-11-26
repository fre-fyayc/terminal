#!/usr/bin/env python3
"""
iterm-manager.py - Manages iTerm2 configuration, profiles, and color presets.
Supports exporting the user's current configuration, creating dynamic profiles,
importing color schemes, and generating theme presets for colleagues.
"""

import sys
import os
import json
import uuid
import plistlib
import subprocess
import argparse
from pathlib import Path

# Common theme color definitions (Hex values)
THEMES_HEX = {
    "Catppuccin-Mocha": {
        "name": "Catppuccin Mocha",
        "background": "#1e1e2e",
        "foreground": "#cdd6f4",
        "bold": "#cdd6f4",
        "cursor": "#f5e0dc",
        "cursor_text": "#11111b",
        "selection": "#585b70",
        "selected_text": "#cdd6f4",
        "ansi": [
            "#45475a",  # 0: Black (Surface1)
            "#f38ba8",  # 1: Red
            "#a6e3a1",  # 2: Green
            "#f9e2af",  # 3: Yellow
            "#89b4fa",  # 4: Blue
            "#f5c2e7",  # 5: Magenta (Pink)
            "#94e2d5",  # 6: Cyan (Teal)
            "#bac2de",  # 7: White (Subtext1)
            "#585b70",  # 8: Bright Black (Surface2)
            "#f38ba8",  # 9: Bright Red
            "#a6e3a1",  # 10: Bright Green
            "#f9e2af",  # 11: Bright Yellow
            "#89b4fa",  # 12: Bright Blue
            "#f5c2e7",  # 13: Bright Magenta
            "#94e2d5",  # 14: Bright Cyan
            "#a6adc8",  # 15: Bright White (Subtext0)
        ]
    },
    "Catppuccin-Latte": {
        "name": "Catppuccin Latte",
        "background": "#eff1f5",
        "foreground": "#4c4f69",
        "bold": "#4c4f69",
        "cursor": "#dc8a78",
        "cursor_text": "#eff1f5",
        "selection": "#acb0be",
        "selected_text": "#4c4f69",
        "ansi": [
            "#5c5f77",  # 0
            "#d20f39",  # 1
            "#40a02b",  # 2
            "#df8e1d",  # 3
            "#1e66f5",  # 4
            "#ea76cb",  # 5
            "#179299",  # 6
            "#acb0be",  # 7
            "#6c6f85",  # 8
            "#d20f39",  # 9
            "#40a02b",  # 10
            "#df8e1d",  # 11
            "#1e66f5",  # 12
            "#ea76cb",  # 13
            "#179299",  # 14
            "#bcc0cc",  # 15
        ]
    },
    "Tokyo-Night": {
        "name": "Tokyo Night",
        "background": "#1a1b26",
        "foreground": "#c0caf5",
        "bold": "#c0caf5",
        "cursor": "#c0caf5",
        "cursor_text": "#1a1b26",
        "selection": "#283457",
        "selected_text": "#c0caf5",
        "ansi": [
            "#15161e",  # 0
            "#f7768e",  # 1
            "#9ece6a",  # 2
            "#e0af68",  # 3
            "#7aa2f7",  # 4
            "#bb9af7",  # 5
            "#7dcfff",  # 6
            "#a9b1d6",  # 7
            "#414868",  # 8
            "#f7768e",  # 9
            "#9ece6a",  # 10
            "#e0af68",  # 11
            "#7aa2f7",  # 12
            "#bb9af7",  # 13
            "#7dcfff",  # 14
            "#c0caf5",  # 15
        ]
    },
    "Nord": {
        "name": "Nord",
        "background": "#2e3440",
        "foreground": "#d8dee9",
        "bold": "#d8dee9",
        "cursor": "#d8dee9",
        "cursor_text": "#2e3440",
        "selection": "#434c5e",
        "selected_text": "#eceff4",
        "ansi": [
            "#3b4252",  # 0
            "#bf616a",  # 1
            "#a3be8c",  # 2
            "#ebcb8b",  # 3
            "#81a1c1",  # 4
            "#b48ead",  # 5
            "#88c0d0",  # 6
            "#e5e9f0",  # 7
            "#4c566a",  # 8
            "#bf616a",  # 9
            "#a3be8c",  # 10
            "#ebcb8b",  # 11
            "#81a1c1",  # 12
            "#b48ead",  # 13
            "#8fbcbb",  # 14
            "#eceff4",  # 15
        ]
    },
    "Gruvbox-Dark": {
        "name": "Gruvbox Dark",
        "background": "#282828",
        "foreground": "#ebdbb2",
        "bold": "#ebdbb2",
        "cursor": "#ebdbb2",
        "cursor_text": "#282828",
        "selection": "#504945",
        "selected_text": "#ebdbb2",
        "ansi": [
            "#282828",  # 0
            "#cc241d",  # 1
            "#98971a",  # 2
            "#d79921",  # 3
            "#458588",  # 4
            "#b16286",  # 5
            "#689d6a",  # 6
            "#a89984",  # 7
            "#928374",  # 8
            "#fb4934",  # 9
            "#b8bb26",  # 10
            "#fabd2f",  # 11
            "#83a598",  # 12
            "#d3869b",  # 13
            "#8ec07c",  # 14
            "#ebdbb2",  # 15
        ]
    },
    "One-Dark": {
        "name": "One Dark",
        "background": "#282c34",
        "foreground": "#abb2bf",
        "bold": "#abb2bf",
        "cursor": "#528bff",
        "cursor_text": "#282c34",
        "selection": "#3e4451",
        "selected_text": "#abb2bf",
        "ansi": [
            "#282c34",  # 0
            "#e06c75",  # 1
            "#98c379",  # 2
            "#e5c07b",  # 3
            "#61afef",  # 4
            "#c678dd",  # 5
            "#56b6c2",  # 6
            "#abb2bf",  # 7
            "#5c6370",  # 8
            "#e06c75",  # 9
            "#98c379",  # 10
            "#e5c07b",  # 11
            "#61afef",  # 12
            "#c678dd",  # 13
            "#56b6c2",  # 14
            "#ffffff",  # 15
        ]
    },
    "Solarized-Dark": {
        "name": "Solarized Dark",
        "background": "#002b36",
        "foreground": "#839496",
        "bold": "#93a1a1",
        "cursor": "#839496",
        "cursor_text": "#002b36",
        "selection": "#073642",
        "selected_text": "#93a1a1",
        "ansi": [
            "#073642",  # 0
            "#dc322f",  # 1
            "#859900",  # 2
            "#b58900",  # 3
            "#268bd2",  # 4
            "#d33682",  # 5
            "#2aa198",  # 6
            "#eee8d5",  # 7
            "#002b36",  # 8
            "#cb4b16",  # 9
            "#586e75",  # 10
            "#657b83",  # 11
            "#839496",  # 12
            "#6c71c4",  # 13
            "#93a1a1",  # 14
            "#fdf6e3",  # 15
        ]
    }
}


def hex_to_iterm_color(hex_str, alpha=1.0):
    hex_str = hex_str.lstrip("#")
    r = int(hex_str[0:2], 16) / 255.0
    g = int(hex_str[2:4], 16) / 255.0
    b = int(hex_str[4:6], 16) / 255.0
    return {
        "Color Space": "sRGB",
        "Red Component": r,
        "Green Component": g,
        "Blue Component": b,
        "Alpha Component": float(alpha)
    }


def theme_to_iterm_preset(theme_dict):
    preset = {
        "Background Color": hex_to_iterm_color(theme_dict["background"]),
        "Foreground Color": hex_to_iterm_color(theme_dict["foreground"]),
        "Bold Color": hex_to_iterm_color(theme_dict["bold"]),
        "Cursor Color": hex_to_iterm_color(theme_dict["cursor"]),
        "Cursor Text Color": hex_to_iterm_color(theme_dict["cursor_text"]),
        "Selection Color": hex_to_iterm_color(theme_dict["selection"]),
        "Selected Text Color": hex_to_iterm_color(theme_dict["selected_text"]),
    }
    for idx, hex_val in enumerate(theme_dict["ansi"]):
        preset[f"Ansi {idx} Color"] = hex_to_iterm_color(hex_val)
    return preset


def get_user_iterm_plist_path():
    return Path(os.path.expanduser("~/Library/Preferences/com.googlecode.iterm2.plist"))


def get_dynamic_profiles_dir():
    dp = Path(os.path.expanduser("~/Library/Application Support/iTerm2/DynamicProfiles"))
    dp.mkdir(parents=True, exist_ok=True)
    return dp


def export_user_setup(repo_root):
    """
    Exports the user's current iTerm2 setup:
    - Current Dracula/active profile as dynamic profile
    - Dracula color preset
    - Cleaned com.googlecode.iterm2.plist
    """
    repo_root = Path(repo_root)
    plist_path = get_user_iterm_plist_path()
    if not plist_path.exists():
        print(f"Error: iTerm plist not found at {plist_path}", file=sys.stderr)
        return False

    with open(plist_path, "rb") as f:
        pl = plistlib.load(f)

    # 1. Export Dracula color preset
    presets = pl.get("Custom Color Presets", {})
    presets_dir = repo_root / "configs" / "iterm2" / "presets"
    presets_dir.mkdir(parents=True, exist_ok=True)

    if "Dracula" in presets:
        dracula_preset_path = presets_dir / "Dracula.itermcolors"
        with open(dracula_preset_path, "wb") as f:
            plistlib.dump(presets["Dracula"], f, fmt=plistlib.FMT_XML)
        print(f"✓ Exported Dracula preset to {dracula_preset_path}")

    # Generate all other theme presets if not already there
    for key, val in THEMES_HEX.items():
        theme_path = presets_dir / f"{key}.itermcolors"
        theme_preset = theme_to_iterm_preset(val)
        with open(theme_path, "wb") as f:
            plistlib.dump(theme_preset, f, fmt=plistlib.FMT_XML)
        print(f"✓ Generated theme preset: {key} -> {theme_path.name}")

    # 2. Export Profile as Dynamic Profile
    bookmarks = pl.get("New Bookmarks", [])
    default_guid = pl.get("Default Bookmark Guid")
    selected_bm = None

    for bm in bookmarks:
        if bm.get("Name") == "Dracula" or bm.get("Guid") == default_guid:
            selected_bm = bm
            break

    if not selected_bm and bookmarks:
        selected_bm = bookmarks[0]

    if selected_bm:
        dyn_dir = repo_root / "configs" / "iterm2" / "DynamicProfiles"
        dyn_dir.mkdir(parents=True, exist_ok=True)
        dyn_file = dyn_dir / "dracula-profile.json"
        with open(dyn_file, "w", encoding="utf-8") as f:
            json.dump({"Profiles": [selected_bm]}, f, indent=2)
        print(f"✓ Exported dynamic profile to {dyn_file}")

    # 3. Export cleaned plist
    cleaned_plist = repo_root / "configs" / "iterm2" / "com.googlecode.iterm2.plist"
    with open(cleaned_plist, "wb") as f:
        plistlib.dump(pl, f, fmt=plistlib.FMT_XML)
    print(f"✓ Exported complete iTerm2 plist to {cleaned_plist}")

    return True


def build_profile_from_preset(name, preset_dict, font_normal, font_non_ascii, transparency, columns=135, rows=35):
    """
    Constructs a full iTerm2 profile dictionary using colors from a preset.
    """
    guid = str(uuid.uuid5(uuid.NAMESPACE_DNS, f"iterm2.profile.{name}"))
    profile = {
        "Name": name,
        "Guid": guid,
        "Description": f"{name} profile",
        "Terminal Type": "xterm-256color",
        "Normal Font": font_normal,
        "Non Ascii Font": font_non_ascii,
        "Use Non-ASCII Font": True,
        "ASCII Anti Aliased": True,
        "Non-ASCII Anti Aliased": True,
        "Non-ASCII Ligatures": True,
        "Draw Powerline Glyphs": True,
        "Use Bold Font": True,
        "Use Italic Font": True,
        "Use Bright Bold": True,
        "Use Bright Bold (Dark)": True,
        "Use Bright Bold (Light)": True,
        "Brighten Bold Text (Dark)": True,
        "Brighten Bold Text (Light)": True,
        "Blinking Cursor": True,
        "Cursor Type": 0,  # Block cursor
        "Transparency": float(transparency),
        "Blur": False,
        "Columns": int(columns),
        "Rows": int(rows),
        "Window Type": 0,  # Normal window
        "Scrollback Lines": 50000,
        "Unlimited Scrollback": False,
        "Close Sessions On End": True,
        "Prompt Before Closing 2": False,
        "Silence Bell": False,
        "Visual Bell": True,
        "Flashing Bell": False,
        "Mouse Reporting": True,
        "Disable Window Resizing": True,
        "Horizontal Spacing": 1.0,
        "Vertical Spacing": 1.0,
        "Working Directory": os.path.expanduser("~"),
        "Custom Directory": "No",
        "Custom Command": "No",
        "Command": "",
        "Default Bookmark": "No",
        "Option Key Sends": 0,
        "Right Option Key Sends": 0,
    }

    # Merge all colors from preset
    for k, v in preset_dict.items():
        if "Color" in k:
            profile[k] = v

    return profile


def apply_profile(name, preset_path, font_normal, font_non_ascii, transparency, set_as_default=True):
    """
    Installs profile into iTerm2:
    1. Writes dynamic profile JSON into ~/Library/Application Support/iTerm2/DynamicProfiles/
    2. Writes into ~/Library/Preferences/com.googlecode.iterm2.plist if available
    """
    preset_path = Path(preset_path)
    if not preset_path.exists():
        print(f"Error: Preset not found at {preset_path}", file=sys.stderr)
        return False

    with open(preset_path, "rb") as f:
        preset_dict = plistlib.load(f)

    profile = build_profile_from_preset(
        name=name,
        preset_dict=preset_dict,
        font_normal=font_normal,
        font_non_ascii=font_non_ascii,
        transparency=transparency
    )

    # 1. Save Dynamic Profile
    dp_dir = get_dynamic_profiles_dir()
    slug = name.lower().replace(" ", "-")
    dp_file = dp_dir / f"{slug}.json"
    with open(dp_file, "w", encoding="utf-8") as f:
        json.dump({"Profiles": [profile]}, f, indent=2)
    print(f"✓ Dynamic Profile created: {dp_file}")

    # 2. Update Preferences Plist
    plist_path = get_user_iterm_plist_path()
    if plist_path.exists():
        try:
            with open(plist_path, "rb") as f:
                pl = plistlib.load(f)

            # Ensure Custom Color Presets has this theme
            presets = pl.setdefault("Custom Color Presets", {})
            presets[name] = preset_dict

            # Check if profile already exists in New Bookmarks
            bookmarks = pl.setdefault("New Bookmarks", [])
            existing_idx = None
            for idx, bm in enumerate(bookmarks):
                if bm.get("Name") == name or bm.get("Guid") == profile["Guid"]:
                    existing_idx = idx
                    break

            if existing_idx is not None:
                bookmarks[existing_idx] = profile
            else:
                bookmarks.append(profile)

            if set_as_default:
                pl["Default Bookmark Guid"] = profile["Guid"]

            with open(plist_path, "wb") as f:
                plistlib.dump(pl, f, fmt=plistlib.FMT_BINARY)

            # Trigger cfprefsd reload
            subprocess.run(["defaults", "read", "com.googlecode.iterm2"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            print(f"✓ Profile '{name}' injected into com.googlecode.iterm2.plist")
            if set_as_default:
                print(f"✓ Default Bookmark Guid set to '{name}' ({profile['Guid']})")
        except Exception as e:
            print(f"! Notice: Could not directly write to com.googlecode.iterm2.plist: {e}")
            print("  (iTerm2 will still load the dynamic profile immediately!)")

    return True


def apply_user_exact(repo_root):
    """
    Applies the exact setup for the user:
    - Imports Dracula.itermcolors
    - Injects Dracula profile with FiraCode NF 12 & JetBrains Mono NF 12, 15% transparency
    - Sets Dracula as default
    """
    repo_root = Path(repo_root)
    preset_path = repo_root / "configs" / "iterm2" / "presets" / "Dracula.itermcolors"
    if not preset_path.exists():
        # Export first if missing
        export_user_setup(repo_root)

    return apply_profile(
        name="Dracula",
        preset_path=preset_path,
        font_normal="FiraCodeNF-Reg 12",
        font_non_ascii="JetBrainsMonoNF-Regular 12",
        transparency=0.1528,
        set_as_default=True
    )


def list_available_themes(repo_root):
    repo_root = Path(repo_root)
    presets_dir = repo_root / "configs" / "iterm2" / "presets"
    themes = []
    if presets_dir.exists():
        for p in sorted(presets_dir.glob("*.itermcolors")):
            themes.append(p.stem)
    return themes


def main():
    parser = argparse.ArgumentParser(description="iTerm2 Setup and Profile Manager")
    subparsers = parser.add_subparsers(dest="command")

    # export-user
    export_p = subparsers.add_parser("export-user")
    export_p.add_argument("--repo-root", default=".")

    # apply-user
    apply_u = subparsers.add_parser("apply-user")
    apply_u.add_argument("--repo-root", default=".")

    # apply-theme
    apply_t = subparsers.add_parser("apply-theme")
    apply_t.add_argument("--name", required=True, help="Profile Name")
    apply_t.add_argument("--preset", required=True, help="Path to .itermcolors file")
    apply_t.add_argument("--font", default="FiraCodeNF-Reg 12", help="Normal Font")
    apply_t.add_argument("--non-ascii-font", default="JetBrainsMonoNF-Regular 12", help="Non-ASCII Font")
    apply_t.add_argument("--transparency", type=float, default=0.15, help="Window transparency (0.0 to 1.0)")
    apply_t.add_argument("--no-default", action="store_true", help="Do not set as default profile")

    # list-themes
    list_t = subparsers.add_parser("list-themes")
    list_t.add_argument("--repo-root", default=".")

    args = parser.parse_args()

    if args.command == "export-user":
        success = export_user_setup(args.repo_root)
        sys.exit(0 if success else 1)
    elif args.command == "apply-user":
        success = apply_user_exact(args.repo_root)
        sys.exit(0 if success else 1)
    elif args.command == "apply-theme":
        success = apply_profile(
            name=args.name,
            preset_path=args.preset,
            font_normal=args.font,
            font_non_ascii=args.non_ascii_font,
            transparency=args.transparency,
            set_as_default=not args.no_default
        )
        sys.exit(0 if success else 1)
    elif args.command == "list-themes":
        themes = list_available_themes(args.repo_root)
        for t in themes:
            print(t)
        sys.exit(0)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
