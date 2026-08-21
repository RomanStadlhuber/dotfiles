#!/bin/sh
#
# PRELIMINARY setup script.
#
# Assumes this repo has ALREADY been cloned by hand to ~/.config/$APPNAME.
# It does not fetch the config itself — that comes later, once the repo is
# public and can be curl'd without credentials.
#
# What it does:
#   1. installs apt dependencies
#   2. installs a pinned Neovim to /opt, symlinked into /usr/local/bin
#   3. installs plugins at the commits recorded in lazy-lock.json
#
# Usage:  ./setup.sh
#
set -eu

NVIM_VERSION=v0.12.4
APPNAME=nvim-kick

main() {
    if [ "$(id -u)" -ne 0 ]; then
        SUDO="sudo"
    else
        SUDO=""
    fi

    if ! command -v apt-get >/dev/null 2>&1; then
        echo "error: apt-get not found. This script only supports Debian/Ubuntu." >&2
        exit 1
    fi

    config_dir="$HOME/.config/$APPNAME"
    if [ ! -f "$config_dir/init.lua" ]; then
        echo "error: no config at $config_dir" >&2
        echo "Clone the repo there first, then re-run this script." >&2
        exit 1
    fi

    install_deps
    install_neovim
    install_plugins

    echo
    echo "Done. Run:  NVIM_APPNAME=$APPNAME nvim"
}

# ---------------------------------------------------------------- dependencies

install_deps() {
    # git       - lazy.nvim clones plugins with it (hard requirement)
    # curl,tar  - fetching the Neovim tarball
    # ripgrep   - telescope live_grep
    # fd-find   - telescope find_files (installs as `fdfind` on Ubuntu)
    # make,gcc  - builds telescope-fzf-native
    missing=""
    for cmd in git curl tar rg fdfind make gcc; do
        command -v "$cmd" >/dev/null 2>&1 || missing="$missing $cmd"
    done

    if [ -z "$missing" ]; then
        echo "==> dependencies already present"
        return
    fi

    echo "==> installing dependencies:$missing"
    $SUDO apt-get update -qq
    DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -y -qq \
        git curl tar ca-certificates ripgrep fd-find make gcc
}

# --------------------------------------------------------------------- neovim

install_neovim() {
    target="/opt/nvim-${NVIM_VERSION}"

    if [ -x "$target/bin/nvim" ] && "$target/bin/nvim" --version >/dev/null 2>&1; then
        echo "==> Neovim ${NVIM_VERSION} already installed"
    else
        echo "==> installing Neovim ${NVIM_VERSION}"
        tmp=$(mktemp -d)
        trap 'rm -rf "$tmp"' EXIT

        # neovim-releases builds against glibc 2.17, so it runs on far more
        # machines than the official build. Same source, different build env.
        url="https://github.com/neovim/neovim-releases/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"

        if ! curl -fSL -o "$tmp/nvim.tar.gz" "$url"; then
            echo "error: download failed: $url" >&2
            exit 1
        fi

        tar xzf "$tmp/nvim.tar.gz" -C "$tmp"

        # The gate. A binary that cannot run must never be symlinked into place.
        if ! "$tmp/nvim-linux-x86_64/bin/nvim" --version >/dev/null 2>&1; then
            echo "error: the downloaded binary does not run here." >&2
            echo "  glibc: $(ldd --version 2>/dev/null | head -1)" >&2
            echo "  arch:  $(uname -m)" >&2
            exit 1
        fi

        $SUDO rm -rf "$target"
        $SUDO mv "$tmp/nvim-linux-x86_64" "$target"
    fi

    $SUDO ln -sfn "$target/bin/nvim" /usr/local/bin/nvim
    hash -r 2>/dev/null || true
    echo "    $(nvim --version | head -1)"
}

# -------------------------------------------------------------------- plugins

install_plugins() {
    echo "==> installing plugins"
    # restore, NOT sync: restore installs at the SHAs in lazy-lock.json.
    # sync would update them and rewrite the lockfile.
    NVIM_APPNAME="$APPNAME" nvim --headless "+Lazy! restore" +qa
}

main "$@"
