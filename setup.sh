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
#   3. installs the tree-sitter CLI (glibc 2.17 build) for nvim-treesitter
#   4. installs plugins at the commits recorded in lazy-lock.json,
#      and the treesitter parsers
#
# Usage:  ./setup.sh
#
set -eu

NVIM_VERSION=v0.12.4

# Built by tools/tree-sitter/build.sh and attached to the GitHub release.
TS_VERSION=0.27.1
TS_RELEASE_URL=https://github.com/RomanStadlhuber/dotfiles/releases/download/tree-sitter-v${TS_VERSION}
TS_SHA256_X86_64=28dd514c3e5cb58f5486e1e474600e79ac183d9b5c25c1ef8abb6c22a49f2a85
# The checkout's folder name is the NVIM_APPNAME. Take it from the script's
# own location, so the script works from any working directory.
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
APPNAME=${SCRIPT_DIR##*/}

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

    config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/$APPNAME"
    if [ ! -f "$config_dir/init.lua" ]; then
        echo "error: no config at $config_dir" >&2
        echo "Clone the repo there first, then re-run this script." >&2
        exit 1
    fi

    install_deps
    install_neovim
    install_tree_sitter
    install_plugins

    echo
    echo "Done. Reload the shell for changes to take effect."
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

# ---------------------------------------------------------------- tree-sitter

install_tree_sitter() {
    # nvim-treesitter (main) needs the tree-sitter CLI to build parsers.
    # Upstream binaries need glibc >= 2.39, so we ship our own glibc 2.17
    # build. lua/plugins/treesitter.lua puts this dir first on nvim's PATH.
    bin_dir="${XDG_DATA_HOME:-$HOME/.local/share}/$APPNAME/bin"
    target="$bin_dir/tree-sitter"
    arch=$(uname -m)
    asset="tree-sitter-linux-${arch}-glibc2.17"

    if [ -x "$target" ] && "$target" --version 2>/dev/null | grep -q " ${TS_VERSION}\$"; then
        echo "==> tree-sitter ${TS_VERSION} already installed"
        return
    fi

    echo "==> installing tree-sitter ${TS_VERSION}"
    mkdir -p "$bin_dir"
    ts_tmp=$(mktemp -d)

    # The gate, same as for nvim: checksum match AND the binary runs here.
    if [ "$arch" = x86_64 ] \
        && curl -fsSL -o "$ts_tmp/$asset" "$TS_RELEASE_URL/$asset" \
        && echo "$TS_SHA256_X86_64  $ts_tmp/$asset" | sha256sum -c --quiet - \
        && chmod +x "$ts_tmp/$asset" \
        && "$ts_tmp/$asset" --version >/dev/null 2>&1
    then
        mv "$ts_tmp/$asset" "$target"
    else
        echo "    no usable release binary, building from source (~2-5 min)"
        "$config_dir/tools/tree-sitter/build.sh" "$ts_tmp"
        mv "$ts_tmp/$asset" "$target"
    fi
    rm -rf "$ts_tmp"
    echo "    $("$target" --version)"
}

# -------------------------------------------------------------------- plugins

install_plugins() {
    echo "==> installing plugins"
    # restore, NOT sync: restore installs at the SHAs in lazy-lock.json.
    # sync would update them and rewrite the lockfile.
    # lua/plugins/treesitter.lua blocks on the parser install when headless.
    NVIM_APPNAME="$APPNAME" nvim --headless "+Lazy! restore" +qa
}

main "$@"
