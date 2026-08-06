# dotfiles

This repo is structured around a terminal focused workflow. The dotfiles cover a lot, however, they are easy to explore so take time in doing that.

## Tools

1. Kitty - Terminal
2. Tmux - Multiplexer
3. Oh-My-ZSH - Shell
4. Editor - Neovim

> Runtimes and additional CLI tools are handled automatically by `mise` whilst
> dev tools are handled automatically by mason.lua in `nvim`.

## Quick Start

```bash
# 1. Clone the repo
git clone <repo-url> ~/dotfiles
# 2. Run symlinks to wire configs
ln -sf ~/dotfiles/nvim ~/.config/nvim
ln -sf ~/dotfiles/tmux/tmux.conf ~/.config/tmux/tmux.conf
ln -sf ~/dotfiles/mise/ ~/.config/mise/config.toml
ln -sf ~/dotfiles/zshrc ~/.config/zshrc
ln -sf ...
# 3. Install terminal (only works on macOS/Linux)
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
# 4. Install shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# 5. Install mise
https://mise.jdx.dev/installing-mise.html#dnf
# 6. Build mise environment
mise install -vf
# 7. Build neovim environment
mise run setup-nvim

```

## License

See [LICENSE](./LICENSE) for details.
