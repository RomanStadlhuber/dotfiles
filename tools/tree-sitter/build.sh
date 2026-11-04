#!/bin/sh
#
# Builds tree-sitter-cli against glibc 2.17, so the binary runs on old
# distros (e.g. Ubuntu 22.04 with glibc 2.35). Upstream release binaries
# need glibc >= 2.39.
#
# Why not a static musl build: `tree-sitter build` dlopen()s the parser it
# just compiled as a self-check. A static musl binary cannot dlopen, so the
# command exits 1 and nvim-treesitter aborts the parser install.
#
# How: cargo-zigbuild links against glibc 2.17 symbol versions through zig.
# Everything (rustup, cargo, zig) goes into a private work dir. Nothing
# touches ~/.cargo or ~/.rustup. Needs only: curl, tar, xz, sha256sum, cc.
#
# Usage:  tools/tree-sitter/build.sh [OUT_DIR]
#         OUT_DIR defaults to ./dist. Prints the binary path when done.
#
set -eu

TS_VERSION=0.27.1
TS_CRATE_SHA256=a2dcd60558068c1b09a8ad52eeb8ef04cecace4789d162b0bfb57760cc623b37
RUST_TOOLCHAIN=1.99.1
CARGO_ZIGBUILD_VERSION=0.24.0
ZIG_VERSION=0.17.0
GLIBC_VERSION=2.17

OUT_DIR=$(mkdir -p "${1:-dist}" && cd "${1:-dist}" && pwd)
WORK="${TS_BUILD_WORK:-${XDG_CACHE_HOME:-$HOME/.cache}/tree-sitter-glibc-build}"

arch=$(uname -m)
case "$arch" in
    x86_64)  zig_sha256=1cbe9df9f27e6b78d14ccbca43b6703a404ef79ef1c463de901d7f088d4e2026 ;;
    aarch64) zig_sha256=9e8d11661d4ae3bd57702a3832781e23ad151dde5798e16a5ccd503f65234ff8 ;;
    *) echo "error: unsupported arch: $arch" >&2; exit 1 ;;
esac
target="${arch}-unknown-linux-gnu"
asset="tree-sitter-linux-${arch}-glibc${GLIBC_VERSION}"

export RUSTUP_HOME="$WORK/rustup" CARGO_HOME="$WORK/cargo"
export PATH="$WORK/zig:$CARGO_HOME/bin:$PATH"
mkdir -p "$WORK"

fetch() { # url sha256 dest
    curl -fsSL -o "$3.part" "$1"
    echo "$2  $3.part" | sha256sum -c --quiet -
    mv "$3.part" "$3"
}

# ------------------------------------------------------------------ toolchain
#
# - rustup + the pinned Rust toolchain, installed into $WORK (not ~/.rustup)
# - zig, the C compiler + linker that can target an old glibc. The download
#   is checked against the sha256 from ziglang.org/download/index.json
# - cargo-zigbuild, which makes cargo use zig as C compiler and linker
# - every step is skipped when the pinned version is already in $WORK

if [ ! -x "$CARGO_HOME/bin/rustup" ]; then
    echo "==> installing rustup into $WORK"
    curl -fsSL https://sh.rustup.rs \
        | sh -s -- -y --profile minimal --default-toolchain none --no-modify-path >/dev/null
fi
rustup toolchain install --profile minimal "$RUST_TOOLCHAIN" >/dev/null 2>&1
rustup default "$RUST_TOOLCHAIN" >/dev/null

if [ ! -x "$WORK/zig/zig" ] || [ "$("$WORK/zig/zig" version)" != "$ZIG_VERSION" ]; then
    echo "==> installing zig $ZIG_VERSION"
    fetch "https://ziglang.org/download/${ZIG_VERSION}/zig-${arch}-linux-${ZIG_VERSION}.tar.xz" \
        "$zig_sha256" "$WORK/zig.tar.xz"
    rm -rf "$WORK/zig" && mkdir -p "$WORK/zig"
    tar xJf "$WORK/zig.tar.xz" -C "$WORK/zig" --strip-components=1
    rm "$WORK/zig.tar.xz"
fi

if ! cargo zigbuild --version 2>/dev/null | grep -q " $CARGO_ZIGBUILD_VERSION\$"; then
    echo "==> installing cargo-zigbuild $CARGO_ZIGBUILD_VERSION"
    cargo install --quiet --locked --version "$CARGO_ZIGBUILD_VERSION" cargo-zigbuild
fi

# --------------------------------------------------------------------- source
#
# - download the tree-sitter-cli source archive (.crate) from crates.io
# - check it against TS_CRATE_SHA256, the "cksum" of that version in the
#   crates.io index (https://index.crates.io/tr/ee/tree-sitter-cli)
# - unpack it, then patch build.rs for zig (see below). Fail if the patch
#   no longer applies

src="$WORK/tree-sitter-cli-$TS_VERSION"
rm -rf "$src"
fetch "https://static.crates.io/crates/tree-sitter-cli/tree-sitter-cli-${TS_VERSION}.crate" \
    "$TS_CRATE_SHA256" "$WORK/ts.crate"
tar xzf "$WORK/ts.crate" -C "$WORK"
rm "$WORK/ts.crate"

# zig's linker rejects -Wl,--dynamic-list. The list only exports the four
# ts_current_* allocator symbols to parsers the CLI loads. -rdynamic exports
# them too (with everything else), which zig accepts.
perl -0pi -e 's/println!\(\s*"cargo:rustc-link-arg=-Wl,--dynamic-list=\{\}",\s*out_dir\.display\(\)\s*\);/let _ = out_dir;\n        println!("cargo:rustc-link-arg=-rdynamic");/' \
    "$src/build.rs"
if grep -q 'dynamic-list' "$src/build.rs" || ! grep -q 'rustc-link-arg=-rdynamic' "$src/build.rs"; then
    echo "error: build.rs patch did not apply. Upstream build.rs changed, update the patch." >&2
    exit 1
fi

# ---------------------------------------------------------------------- build
#
# - compile with the crate's own Cargo.lock (--locked), linked against
#   glibc $GLIBC_VERSION symbols
# - check that the binary runs, then copy it to OUT_DIR as the release
#   asset, with a .sha256 file next to it

echo "==> building tree-sitter-cli $TS_VERSION for $target (glibc $GLIBC_VERSION)"
(cd "$src" && cargo zigbuild --quiet --release --locked --target "$target.$GLIBC_VERSION")

bin="$src/target/$target/release/tree-sitter"
"$bin" --version >/dev/null
cp "$bin" "$OUT_DIR/$asset"
(cd "$OUT_DIR" && sha256sum "$asset" > "$asset.sha256")
echo "$OUT_DIR/$asset"
