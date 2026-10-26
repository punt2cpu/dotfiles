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

**Neovim (>= 0.11.2)**
- LazyVim base with `clangd`, `clangd_extensions.nvim`, and `nvim-treesitter` for C/C++.
- `snacks.nvim`, `flash.nvim`, `grug-far.nvim`, and `trouble.nvim` for navigation/search.
- `blink.cmp` for completion.

**Tmux**
- `escape-time 0`, 50k scrollback, 1-indexed windows/panes, mouse enabled.
- Splits on `Prefix + |` and `Prefix + -`, Vim pane navigation (`Prefix + h/j/k/l`).
- `tmux-telemetry.sh`: polls `/proc` and `/sys/class/hwmon` every 3s for CPU (`k10temp`), RAM, AMD GPU (`amdgpu`), and RX/TX throughput. State is kept in `/dev/shm` so it doesn't touch the disk.

## Fresh Setup (Debian / Ubuntu)

1. Install base packages and latest Neovim (`apt` packages are too old for LazyVim):

```bash
sudo apt update && sudo apt install -y git stow tmux ripgrep fd-find build-essential clangd curl unzip tar && \
curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz -o /tmp/nvim.tar.gz && \
sudo rm -rf /opt/nvim && sudo mkdir -p /opt/nvim && \
sudo tar -C /opt/nvim --strip-components=1 -xzf /tmp/nvim.tar.gz && \
sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim && \
rm -f /tmp/nvim.tar.gz
```

2. Clone and stow dotfiles:

```bash
git clone https://github.com/punt2cpu/dotfiles.git ~/dotfiles && \
cd ~/dotfiles && \
mkdir -p ~/.config ~/.local/bin && \
ln -sf "$(which fdfind)" ~/.local/bin/fd && \
stow --no-folding -t ~ nvim tmux
```
