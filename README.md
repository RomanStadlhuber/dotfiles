# dotfiles

Neovim config, a pinned Neovim, and the git editor setting.
There are two ways to install it.

## Font (optional)

Icons need a Nerd Font on the machine that runs the terminal.
Install FiraCode Nerd Font:

```bash
mkdir -p ~/.local/share/fonts/FiraCodeNerd
curl -fL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.tar.xz \
  | tar -xJ -C ~/.local/share/fonts/FiraCodeNerd
fc-cache -f
```

Then set the terminal font to `FiraCode Nerd Font Mono`.
Without the font, the config shows no Nerd Font glyphs. It uses ASCII and plain Unicode (tree lines, borders) instead.

## `LC_NERD_FONT`

Set `LC_NERD_FONT=1` to turn on Nerd Font icons.
Neovim reads it at every start. Unset or `0` means no Nerd Font glyphs.

- Local shell: add `export LC_NERD_FONT=1` to the shell rc.
- SSH: stock configs forward `LC_*` already.
- Docker: add `environment: [LC_NERD_FONT]` (compose) or use `docker run -e LC_NERD_FONT` / `docker exec -e LC_NERD_FONT`.
- tmux / byobu: add `set -ga update-environment LC_NERD_FONT` to the tmux config.

## Quick start (recommended)

Needs `curl` and `git`. On a bare Ubuntu: `sudo apt-get install -y curl git`.

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply RomanStadlhuber/dotfiles
```

This installs chezmoi, links the config to `~/.config/nvim` and runs `setup.sh`.
It replaces an existing `~/.config/nvim`.
For a machine where chezmoi is not wanted, use `setup.sh` (below).

## Install with `setup.sh` (no chezmoi)

```bash
git clone https://github.com/RomanStadlhuber/dotfiles ~/.config/nvim
~/.config/nvim/setup.sh
```

The script installs the apt dependencies, Neovim, the tree-sitter CLI,
the plugins at the commits in `lazy-lock.json`, the language servers,
and sets the pinned Neovim as git `core.editor`.
It is safe to run again.

The folder name is the `NVIM_APPNAME`.
Clone to `~/.config/<name>` to install the config under a different name.

## Install with chezmoi

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply RomanStadlhuber/dotfiles
```

This repo is the chezmoi source dir (`~/.local/share/chezmoi`).
chezmoi then does two things:

1. It makes `~/.config/nvim` a symlink to the source dir.
2. It runs `setup.sh` through that symlink.

Update with `chezmoi update`.

> **Note:** chezmoi replaces an existing `~/.config/nvim`.
> Without a terminal it does this without a prompt.

> **Note:** The chezmoi path needs `XDG_CONFIG_HOME` unset or set to `~/.config`.
> The symlink always goes to `~/.config/nvim`, but `setup.sh` reads `$XDG_CONFIG_HOME/nvim`.

### Layout

- `.chezmoiroot` contains `home`. chezmoi reads only `home/`, so the repo root stays a plain Neovim config.
- `home/dot_config/symlink_nvim.tmpl` gives the symlink `~/.config/nvim -> {{ .chezmoi.workingTree }}`.
- `home/run_onchange_after_setup.sh.tmpl` calls `~/.config/nvim/setup.sh`. Its comments hold the sha256 of `lazy-lock.json` and the `NVIM_VERSION` line from `setup.sh`. chezmoi runs the script again only when one of these changes.

Why a symlink and not `home/dot_config/nvim/`:

- `setup.sh` and the clone install stay as they are.
- The source dir is the live config. Lazy writes `lazy-lock.json` into the repo, the same as with a plain clone.
- `setup.sh` takes `NVIM_APPNAME` from its folder name. Through the symlink it gets `nvim`, not `chezmoi`.
