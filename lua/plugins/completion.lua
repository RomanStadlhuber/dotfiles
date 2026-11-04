return {
  'saghen/blink.cmp',
  -- a release tag, so blink.cmp downloads its prebuilt fuzzy matcher
  version = '1.*',
  -- defaults: <C-y> accept, <C-n>/<C-p> select, sources lsp/path/snippets/buffer.
  -- blink also passes its completion capabilities to every LSP server.
  opts = {
    signature = { enabled = true }, -- show the signature while typing arguments
  },
}
