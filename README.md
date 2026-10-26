# dotfiles

Personal Neovim and tmux config, managed with GNU Stow.

## Structure

```text
~/dotfiles/
├── nvim/
│   └── .config/nvim/                  # LazyVim + clangd C/C++ setup
└── tmux/
    ├── .tmux.conf                     # Keybindings & status bar
    └── .local/bin/tmux-telemetry.sh   # sysfs/procfs status bar telemetry
```

## What's inside

**Neovim**
- LazyVim base with `clangd`, `clangd_extensions.nvim`, and `nvim-treesitter` for C/C++.
- `snacks.nvim`, `flash.nvim`, `grug-far.nvim`, and `trouble.nvim` for navigation/search.
- `blink.cmp` for completion.

**Tmux**
- `escape-time 0`, 50k scrollback, 1-indexed windows/panes, mouse enabled.
- Splits on `Prefix + |` and `Prefix + -`, Vim pane navigation (`Prefix + h/j/k/l`).
- `tmux-telemetry.sh`: polls `/proc` and `/sys/class/hwmon` every 3s for CPU (`k10temp`), RAM, AMD GPU (`amdgpu`), and RX/TX throughput. State is kept in `/dev/shm` so it doesn't touch the disk.

## Dependencies (Debian / Ubuntu)

```bash
sudo apt update && sudo apt install -y git stow tmux neovim ripgrep fd-find build-essential clangd
```

## Setup

```bash
git clone https://github.com/punt2cpu/dotfiles.git ~/dotfiles
cd ~/dotfiles
mkdir -p ~/.config ~/.local/bin
stow --no-folding -t ~ nvim tmux
```
