# Getting Started Guide (No Tech Background Needed)

Welcome! This guide walks you through setting up a nicer, easier-to-read Terminal (**iTerm2**) and text editor (**Vim**) on your Mac.

You don't need to know how to code to run this—just copy and paste a couple of commands, answer 4 simple multiple-choice questions, and everything is set up automatically.

> **Is it safe?** Yes! If you already have any settings on your Mac, the script saves a backup copy first (with `.backup` in the name) before changing anything.

---

## Before You Start (Quick Checklist)

1. **You are on a Mac** (this setup is only for macOS).
2. **You are connected to the internet** (needed to download iTerm2 and the fonts).
3. **Know your Mac password**: You may be asked for the password you use to log into your Mac.
   - **Important:** When typing your password in the Terminal, **nothing will show up on the screen** (no dots or stars). That is normal! Just type your password and press **Return**.
4. **Apple popup check**: If a popup asks to install *"Command Line Developer Tools"*, click **Install** and wait for it to finish before continuing.

---

## Step-by-Step Instructions

### Step 1: Open the Terminal app
1. Press **Command (`⌘`) + Spacebar** on your keyboard to open Spotlight Search.
2. Type `Terminal` and press **Return**.

### Step 2: Go to this folder
In the Terminal window, go to the folder where you saved these files. For example, if it is in your `Downloads` folder, type:
```bash
cd ~/Downloads/terminal
```
*(Tip: You can also type `cd ` with a space after it, drag the `terminal` folder from Finder into the Terminal window, and press **Return**.)*

### Step 3: Start the installer
Copy and paste this command and press **Return**:
```bash
./install-colleague.sh
```

### Step 4: Answer the 4 questions
The script will ask you 4 simple questions. **You can just press Return** on any question to choose the recommended option:

1. **Color Theme** — Pick how you want your terminal to look (for example, `1` for Dracula dark theme, or `3` for Catppuccin Latte if you prefer a light background).
2. **Fonts** — Press `1` (Recommended) so icons and text look crisp.
3. **Window Transparency** — Press `1` for a slight see-through background, or `2` for a solid background.
4. **Colorful Prompt (Starship)** — Type `y` and press **Return** if you want a helpful prompt that shows your current folder and time, or just press **Return** to skip it.

Finally, press **Return** when it asks `Proceed with installation? [Y/n]`.

*(Grab a coffee—the first-time download of fonts and iTerm2 may take 1–2 minutes.)*

---

## What to Check After It Finishes

Once you see **"Setup Successfully Completed!"**:

1. **Open the new iTerm app**
   - Press **Command (`⌘`) + Spacebar**, type `iTerm`, and press **Return**.
   - *(From now on, use **iTerm** instead of the old **Terminal** app!)*

2. **Check the colors and text**
   - Your window should now appear in the color theme you picked.
   - If it still looks plain black-and-white:
     1. Click **iTerm2** in the top-left Mac menu bar → **Settings** (or **Preferences**).
     2. Click **Profiles** at the top.
     3. Find your chosen theme name on the left list, click it, then click **Other Actions...** (at the bottom) → **Set as Default**.
     4. Press **Command (`⌘`) + Q** to quit iTerm completely, then open it again.

3. **Check icons (if you chose the colorful prompt)**
   - If you see strange boxes or question marks (`[?]`) instead of small icons, quit iTerm completely (**Command (`⌘`) + Q**) and reopen it so the new fonts load.

4. **Test copy & paste in Vim (optional)**
   - Copying (`y`) and pasting (`p`) inside Vim now works directly with your Mac's normal clipboard (`⌘C` / `⌘V`).

---

## Common Questions

- **"It says `Permission denied` when I run `./install-colleague.sh`"**
  Run this command once, then try again:
  ```bash
  chmod +x install-colleague.sh
  ./install-colleague.sh
  ```

- **"Where did my old settings go?"**
  Any previous files were saved in your home folder with `.backup.` and the date in the filename (for example, `~/.vimrc.backup.20261126_093000`).

- **"Can I change my theme later?"**
  Yes! Just run `./install-colleague.sh` again and pick a different theme number.
