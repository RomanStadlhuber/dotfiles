# tree-sitter CLI

`nvim-treesitter` (main branch) builds parsers with the `tree-sitter` CLI.
Upstream binaries need glibc >= 2.39, so this repo ships its own build against glibc 2.17.

- `setup.sh` downloads it from the `tree-sitter-v<version>` release into `~/.local/share/nvim-kick/bin`.
- `lua/plugins/treesitter.lua` puts that dir first on nvim's `PATH`.
- If the download fails, `setup.sh` builds it with `build.sh` in this folder (about 2-5 min).

To bump the version:

1. Change `TS_VERSION` (and the crate sha256) in `build.sh`, then run it.
2. Create the release: `gh release create tree-sitter-v<version> dist/tree-sitter-linux-x86_64-glibc2.17*`
3. Update `TS_VERSION` and `TS_SHA256_X86_64` in `setup.sh`.
