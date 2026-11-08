return {
  'saghen/blink.cmp',
  -- a release tag, so blink.cmp downloads its prebuilt fuzzy matcher
  version = '1.*',
  -- defaults: <C-y> accept, <C-n>/<C-p> select, sources lsp/path/snippets/buffer.
  -- blink also passes its completion capabilities to every LSP server.
  opts = {
    -- no completion inside comments (any language with a treesitter parser).
    -- :lua vim.b.completion = false turns it off for the whole buffer.
    enabled = function()
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      -- col - 1: in insert mode at the line end, the cursor is past the text
      local ok, node = pcall(vim.treesitter.get_node, { pos = { row - 1, math.max(col - 1, 0) } })
      return not (ok and node and node:type():find('comment'))
    end,
    signature = { enabled = true }, -- show the signature while typing arguments
  },
}
