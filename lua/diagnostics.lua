-- How LSP errors and warnings show up. Sources: clangd (with clang-tidy
-- when the project has a .clang-tidy file), basedpyright, ruff.
-- nvim 0.12 already maps <C-w>d (float with all messages of the line) and
-- ]d / [d (next/previous diagnostic).
local current_line_only = { current_line = true }

vim.diagnostic.config({
  severity_sort = true, -- errors win: line-end text shows the most severe one
  virtual_text = current_line_only, -- message at the line end, cursor line only
  float = { source = true }, -- name the server that reports it
})

vim.keymap.set('n', '<leader>td', function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = 'Toggle diagnostics' })

vim.keymap.set('n', '<leader>tv', function()
  local all = vim.diagnostic.config().virtual_text == true
  vim.diagnostic.config({ virtual_text = all and current_line_only or true })
end, { desc = 'Toggle line-end text: cursor line / all lines' })
