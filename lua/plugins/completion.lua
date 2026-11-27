return {
  'saghen/blink.cmp',
  -- a release tag, so blink.cmp downloads its prebuilt fuzzy matcher
  version = '1.*',
  -- defaults: <C-y> accept, <C-n>/<C-p> select, sources lsp/path/snippets/buffer.
  -- blink also passes its completion capabilities to every LSP server.
  opts = {
    -- no completion in prose filetypes (markdown, LaTeX) and inside comments
    -- (any language with a treesitter parser).
    -- :lua vim.b.completion = false turns it off for the whole buffer.
    enabled = function()
      if vim.tbl_contains({ 'markdown', 'tex', 'plaintex' }, vim.bo.filetype) then
        return false
      end
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      -- col - 1: in insert mode at the line end, the cursor is past the text
      local ok, node = pcall(vim.treesitter.get_node, { pos = { row - 1, math.max(col - 1, 0) } })
      return not (ok and node and node:type():find('comment'))
    end,
    keymap = {
      preset = 'default',
      -- <C-d> ("dismiss") closes the menu like <C-e>.
      -- Without an open menu it keeps nvim's insert-mode <C-d> (de-indent).
      ['<C-d>'] = { 'cancel', 'fallback' },
    },
    signature = { enabled = true }, -- show the signature while typing arguments
  },
}
