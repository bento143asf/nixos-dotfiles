# NixOS Dotfiles

> My personal **NixOS + Hyprland** desktop configuration.

This repository is mainly a place to keep my configuration **version-controlled and organized**, while making it public for anyone who happens to find something useful here.

---

## Screenshots

### Empty Desktop

![Empty Desktop](Screenshots/emptydesk.png)

---

### Quickshell Topbar (unfinished)

![Quickshell Topbar Beta](Screenshots/topbar-beta.png)

---

### Quickshell Launcher

![Quickshell Launcher](Screenshots/qslauncher.png)

---

### Normal Desktop

![Normal Desktop](Screenshots/desktop.png)

---

## What's Inside (simplified)

```
Nix-Dots/
├── Hyprland/
│   ├── Hypr/
│   ├── quickshell-launcher/
│   └── quickshell-topbar/
│
├── Nix/
│   └── configuration.nix
│
├── Nvim/
│   ├── init.lua
│   └── lua/
│
├── Screenshots/
│
└── Terminal/
    ├── fastfetch/
    ├── fish/
    └── kitty/
```

---

### Hyprland

Includes:

* Hyprland
* Hyprpaper
* Window rules
* Workspace configuration
* Keybinds
* Quickshell integration
* Various desktop behavior tweaks

**All Hyprland config is at only 1 file, maybe I'll change it later**.

---

### Quickshell

The repository currently contains two main Quickshell components:

* **Topbar**
* **Launcher**

Topbar is still under development and should be considered **experimental**.

---

### Neovim

My personal Neovim configuration.

It currently includes things such as:

* LSP
* Autocompletion
* Treesitter
* Telescope
* Dracula Theme
* Various quality-of-life plugins

---

### Terminal

* **Shell: Fish**
* **Terminal: Kitty**
* **Fastfetch**

---

## Main Keybinds

These are some of the main Hyprland shortcuts:
|   Keybind   | Action                                          |
| :---------: | ----------------------------------------------- |
| `Super + Q` | Open terminal                                   |
| `Super + C` | Close active window                             |
| `Super + D` | Open launcher                                   |
| `Super + V` | Toggle floating window                          |
| `Super + F` | Maximize/stretch window without true fullscreen |

There are additional keybinds throughout the configuration.

---

## System

This configuration was developed primarily on a **NixOS desktop running Hyprland with NVIDIA graphics**.

Because this is a personal configuration, some parts are tied to my own hardware and workflow.

If you're using a different GPU or system, especially **AMD or Intel graphics**, some hardware-specific settings may need to be changed.

---

## Language

Some parts of the configuration are written in **Brazilian Portuguese (`pt-BR`)**.

This includes some comments, naming, and configuration-related text.

---

## NixOS & Flakes

This configuration **does not use Nix flakes** at the moment.

It's currently based around a more traditional NixOS configuration.

I may eventually add:

* `flake.nix`
* A more modular Nix structure
* Home Manager

---

## Status

> **Work in progress.**

Not everything here is finished.

Some parts are stable, while others are still experimental or have known issues.

Current rough edges include:

* Quickshell components still being developed
* Incomplete modules
* Hardware-specific configuration
* Configuration that hasn't been fully generalized
* Things that may simply break while I'm changing them

So, if something doesn't work, **that's not necessarily a surprise**.

---

If you find something useful here, feel free to use it.

If something doesn't work on your machine, you'll probably need to adapt it.

**This repository is not intended to be a universal NixOS configuration or a plug-and-play rice.**

---

## Future Plans

Some things I *might* work on in the future:

* Add a Nix flake
* Improve the Quickshell launcher
* Finish the Quickshell topbar
* Clean up the configuration structure
* Reduce hardware-specific assumptions
* Improve documentation
* Add more reusable modules

These aren't commitments, the repository will simply evolve alongside my desktop.

Some things will get removed, rewritten, broken, fixed, or replaced.

---

