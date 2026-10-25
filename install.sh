#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"
BACKUP="$HOME/.dotfiles-backup/$(date +%s)"
OS="$(uname -s)"

# helper function to symlink files and directories
link() {
  local src="$1" dst="$2"
  [ -e "$src" ] || { echo "skip (missing): $src"; return; }
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    mkdir -p "$BACKUP"
    mv "$dst" "$BACKUP/"
    echo "backed up $dst -> $BACKUP"
  fi
  ln -s "$src" "$dst"
  echo "linked $dst"
}

# install system dependencies
if [ "$OS" = "Darwin" ]; then
  xcode-select -p >/dev/null 2>&1 || { xcode-select --install; echo "finish the Xcode CLT install, then re-run."; exit 1; }
  if ! command -v brew >/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
  brew install git curl zsh unzip tree pkg-config cmake
elif command -v apt >/dev/null; then
  sudo apt update
  sudo apt install -y git curl zsh unzip gcc make tar xclip tree pkg-config
elif command -v dnf >/dev/null; then
  sudo dnf install -y git curl zsh unzip gcc make tar xclip tree pkgconf-pkg-config
else
  echo "no supported package manager found"; exit 1
fi

# install oh-my-zsh shell and it's plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
clone_plugin() {
  [ -d "$ZSH_CUSTOM/plugins/$1" ] || git clone --depth 1 "$2" "$ZSH_CUSTOM/plugins/$1"
}
clone_plugin zsh-autosuggestions     https://github.com/zsh-users/zsh-autosuggestions
clone_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting

# symlink the files and directories
link "$DOTFILES/zshrc"                     "$HOME/.zshrc"
link "$DOTFILES/ideavim/ideavimrc"         "$HOME/.ideavimrc"
link "$DOTFILES/nvim"                      "$CONFIG/nvim"
link "$DOTFILES/kitty/kitty.conf"          "$CONFIG/kitty/kitty.conf"
link "$DOTFILES/kitty/current-theme.conf"  "$CONFIG/kitty/current-theme.conf"
link "$DOTFILES/tmux/tmux.conf"            "$CONFIG/tmux/tmux.conf"
link "$DOTFILES/tmux/tmux.reset.conf"      "$CONFIG/tmux/tmux.reset.conf"
link "$DOTFILES/starship/starship.toml"    "$CONFIG/starship/starship.toml"
link "$DOTFILES/mise/config.toml"          "$CONFIG/mise/config.toml"

# install tmux plugin manager
[ -d "$HOME/.tmux/plugins/tpm" ] || \
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

# install kitty terminal
if ! command -v kitty >/dev/null; then
  if [ "$OS" = "Darwin" ]; then
    brew install --cask kitty
  elif [ ! -d "$HOME/.local/kitty.app" ]; then
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
    mkdir -p "$HOME/.local/bin"
    ln -sf "$HOME/.local/kitty.app/bin/kitty" "$HOME/.local/kitty.app/bin/kitten" "$HOME/.local/bin/"
  fi
fi

# install mise + toolchains
export PATH="$HOME/.local/bin:$PATH"
command -v mise >/dev/null || curl https://mise.run | sh
mise trust "$CONFIG/mise/config.toml"
mise install
mise run setup

# device secrets file 
if [ ! -f "$HOME/.secrets" ]; then
  install -m 600 /dev/null "$HOME/.secrets"
  echo "secrets file made: ~/.secrets"
fi

# set default shell to oh-my-zsh
if [ "$(basename "${SHELL:-}")" != "zsh" ]; then
  chsh -s "$(command -v zsh)" || echo "run manually: chsh -s $(command -v zsh)"
fi

echo "setup complete"
