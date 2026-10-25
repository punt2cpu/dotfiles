# Dotfiles (Neovim & Tmux)

Personal Linux development environment managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Repository Structure

    ~/dotfiles/
    ├── nvim/
    │   └── .config/nvim/                  # LazyVim configuration + clangd C/C++ LSP
    └── tmux/
        ├── .tmux.conf                     # Tmux keybindings & status bar config
        └── .local/bin/tmux-telemetry.sh   # RAM-backed (/dev/shm) CPU/GPU/RAM/Net telemetry

## Features

### Neovim (nvim)
* **Framework:** [LazyVim](https://www.lazyvim.org/) with automatic `lazy.nvim` bootstrapping on first launch.
* **C / C++ Development:** `clangd`, `clangd_extensions.nvim`, `nvim-treesitter`, and `mason.nvim`.
* **Fast Search & Navigation:** `snacks.nvim`, `flash.nvim`, `grug-far.nvim`, and `trouble.nvim`.
* **Completion:**  autocompletion via `blink.cmp`.

### Tmux (tmux)
* **Neovim-Friendly:** Zero escape time (`escape-time 0`), 50,000-line scrollback buffer, 1-indexed windows/panes, and mouse support enabled.
* **Keybindings:**
  * `Prefix + |` : Split pane horizontally
  * `Prefix + -` : Split pane vertically
  * `Prefix + h/j/k/l` : Vim-style pane navigation
* **Hardware Telemetry (`tmux-telemetry.sh`):**
  * Refreshes every 3 seconds directly from `/proc` and `/sys/class/hwmon`.
  * Caches delta state in `/dev/shm` (in-memory `tmpfs`) to avoid SSD wear.
  * Displays **CPU Usage % + Load Avg + Temp (`k10temp`)**, **Memory Usage (GiB & %)**, **AMD GPU Load + Edge/Junction Temps + VRAM (`amdgpu`)**, and **Live RX/TX Network Throughput**.

## Prerequisites

Install required packages on Debian/Ubuntu:

    sudo apt update && sudo apt install -y git stow tmux neovim ripgrep fd-find build-essential clangd

## Installation (Clone & Restore)

1. **Clone the repository into `~/dotfiles`:**

    git clone git@github.com:punt2cpu/dotfiles.git ~/dotfiles
    cd ~/dotfiles

2. **Ensure `~/.local/bin` and `~/.config` exist before stowing:**

    mkdir -p ~/.config ~/.local/bin

3. **Symlink configurations using GNU Stow:**

    stow --no-folding nvim tmux

4. **Launch Tmux and Neovim:**

    tmux
    nvim
