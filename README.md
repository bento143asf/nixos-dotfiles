# NixOS Dotfiles

> My personal **NixOS + Hyprland** desktop configuration.

A collection of my personal dotfiles for my daily desktop environment.  
This repository is mainly a place to keep my configuration **version-controlled and organized**, while making it public for anyone who happens to find something useful here.

**This is not a popularity-focused project, or a plug-and-play configuration.**  
It's just my setup.

---

## Screenshots

### Empty Desktop

![Empty Desktop](Screenshots/emptydesk.png)

---

### Quickshell Topbar — Beta

![Quickshell Topbar Beta](Screenshots/topbar-beta.png)

---

### Quickshell Launcher

![Quickshell Launcher](Screenshots/qslauncher.png)

---

### Normal Desktop

![Normal Desktop](Screenshots/desktop.png)

---

## What's Inside

```text
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
````

### Hyprland

My main **Wayland compositor** configuration.

Includes:

* Hyprland
* Hyprpaper
* Window rules
* Workspace configuration
* Keybinds
* Quickshell integration
* Various desktop behavior tweaks

### Quickshell

The repository currently contains two main Quickshell components:

* **Topbar** — a custom top bar with workspaces, system statistics, Wi-Fi, Bluetooth, volume, brightness, media controls, clock, and other modules.
* **Launcher** — a custom application launcher with support for pinned applications.

Both are still under development and should be considered **beta / experimental**.

### Neovim

My personal Neovim configuration, written in **Lua**.

It currently includes things such as:

* LSP
* Autocompletion
* Treesitter
* Telescope
* Themes
* Various quality-of-life plugins

### Terminal

My terminal environment is built around:

* **Fish**
* **Kitty**
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

I may translate or clean these up in the future, but for now I'm keeping them as they naturally exist in my personal setup.

---

## NixOS & Flakes

This configuration **does not use Nix flakes** at the moment.

It's currently based around a more traditional NixOS configuration.

I may eventually add:

* `flake.nix`
* A more modular Nix structure
* Home Manager
* Additional Nix tooling

But there is no guarantee that these will be added. I'll introduce them if they actually make sense for the configuration.

---

## Status

> **Work in progress.**

Not everything here is finished.

Some parts are stable, while others are still experimental or have known issues.

Current rough edges include:

* Quickshell components still being developed
* UI bugs
* Incomplete modules
* Hardware-specific configuration
* Configuration that hasn't been fully generalized
* Things that may simply break while I'm changing them

So, if something doesn't work, **that's not necessarily a surprise**.

---

## Philosophy

There isn't a complicated philosophy behind this repository.

It's **my desktop**.

I wanted a place to:

1. Keep my configuration backed up and version-controlled.
2. Experiment with my setup.
3. Learn from the things I'm building.
4. Make the configuration publicly available.

If you find something useful here, feel free to use it.

If something doesn't work on your machine, you'll probably need to adapt it.

**This repository is not intended to be a universal NixOS configuration or a plug-and-play rice.**

---

## Future Plans

Some things I *might* work on in the future:

* [ ] Add a Nix flake
* [ ] Improve the Quickshell topbar
* [ ] Finish the Quickshell launcher
* [ ] Fix remaining UI bugs
* [ ] Clean up the configuration structure
* [ ] Reduce hardware-specific assumptions
* [ ] Improve documentation
* [ ] Add more reusable modules

These aren't commitments — the repository will simply evolve alongside my desktop.

---

## Final Note

This configuration is a snapshot of **how I currently use Linux**.

It's going to change.

Some things will get removed, rewritten, broken, fixed, or replaced.


