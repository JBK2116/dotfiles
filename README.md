# dotfiles

This repo is structured around a terminal focused workflow. The dotfiles cover a lot, however, they are easy to explore so take time in doing that.

## Tools

1. Kitty - Terminal
2. Tmux - Multiplexer
3. Oh-My-ZSH - Shell
4. Editor - Neovim
5. Note-Taking - Neovim Obsidian
6. AI - Neovim Code Companion

> Runtimes and additional CLI tools are handled automatically by `mise` whilst
> dev tools are handled automatically by mason.lua in `nvim`.

## Quick Start

```bash
# 1. Clone the repo
git clone <repo-url> ~/dotfiles
cd ~/dotfiles

# 2. Create required directories
mkdir -p ~/.config/kitty
mkdir -p ~/.config/mise
mkdir -p ~/.config/nvim
mkdir -p ~/.config/starship
mkdir -p ~/.config/tmux
mkdir -p ~/.tmux/plugins

# 3. Symlink configs (each tool has a SYMLINK comment showcasing how to configure them)
ln -sf ~/dotfiles/zshrc ~/.zshrc
ln -sf ~/dotfiles/kitty/kitty.conf ~/.config/kitty/kitty.conf
ln -sf ~/dotfiles/kitty/current-theme.conf ~/.config/kitty/current-theme.conf
ln -sf ~/dotfiles/tmux/tmux.conf ~/.config/tmux/tmux.conf
ln -sf ~/dotfiles/tmux/tmux.reset.conf ~/.config/tmux/tmux.reset.conf
ln -sf ~/dotfiles/starship/starship.toml ~/.config/starship/starship.toml
ln -sf ~/dotfiles/mise/config.toml ~/.config/mise/config.toml
ln -sf ~/dotfiles/nvim ~/.config/nvim
ln -sf ~/dotfiles/ideavim/ideavimrc ~/.ideavimrc

# 4. Install shell (before symlinking zshrc, so it doesn't overwrite your configs)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 5. Install tmux plugin manager (tpm)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# 6. Install Terminal (only works on macOS & Linux)
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

# 7. Install mise (see https://mise.jdx.dev/installing-mise.html for your platform)
curl https://mise.run | sh

# 8. Build mise environment
mise install
mise trust ~/.config/mise/config.toml

# 9. Build dev environment
mise run setup

# 10. Install docker engine
https://docs.docker.com/engine/install/

```

> **After setup:** Launch tmux and press `prefix + I` (default prefix is backtick `` ` ``) to install tmux plugins.

## License

See [LICENSE](./LICENSE) for details.
