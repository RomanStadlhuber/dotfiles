-- breadcrumbs in the winbar. ASCII by default, Nerd Font glyphs with
-- vim.g.have_nerd_font (see init.lua).
local nerd = vim.g.have_nerd_font

return {
  'Bekaboo/dropbar.nvim',
  dependencies = { { 'nvim-tree/nvim-web-devicons', cond = nerd } },
  keys = {
    { '<leader>;', function() require('dropbar.api').pick() end, desc = 'Pick breadcrumb' },
  },
  -- dropbar attaches to the winbar at startup, so load it at once
  lazy = false,
  opts = {
    icons = {
      enable = nerd and true or false,
      -- with icons off, dropbar blanks the whole ui table, so set the
      -- separators here
      ui = nerd and {} or {
        bar = { separator = ' > ', extends = '...' },
        menu = { separator = ' ', indicator = '> ' },
      },
    },
  },
}
