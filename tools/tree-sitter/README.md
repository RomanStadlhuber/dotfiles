# tree-sitter CLI

`nvim-treesitter` (main branch) builds parsers with the `tree-sitter` CLI.
Upstream binaries need glibc >= 2.39, so this repo ships its own build against glibc 2.17.

- `setup.sh` downloads it from the `tree-sitter-v<version>` release into `~/.local/share/<appname>/bin` (`<appname>` = the checkout's folder name).
- `lua/plugins/treesitter.lua` puts that dir first on nvim's `PATH`.
- If the download fails, `setup.sh` builds it with `build.sh` in this folder (about 2-5 min).

To bump the version:

1. In `build.sh`, set `TS_VERSION` and `TS_CRATE_SHA256`, then run it.
   Take the sha256 from the crates.io index (the `cksum` of that version):

   ```sh
   curl -fsSL https://index.crates.io/tr/ee/tree-sitter-cli | grep '"vers":"<version>"' | grep -o '"cksum":"[0-9a-f]*"'
   ```

2. Create the release: `gh release create tree-sitter-v<version> dist/tree-sitter-linux-x86_64-glibc2.17*`
3. Update `TS_VERSION` and `TS_SHA256_X86_64` in `setup.sh`.
