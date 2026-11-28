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
  init = function()
    -- subtle accent: reuse a low-contrast background group
    local function link()
      vim.api.nvim_set_hl(0, 'WinBar', { link = 'StatusLineNC' })
      vim.api.nvim_set_hl(0, 'WinBarNC', { link = 'StatusLineNC' })
    end
    link()
    vim.api.nvim_create_autocmd('ColorScheme', { callback = link })
  end,
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
