-- rendered markdown in normal mode. ASCII by default, Nerd Font glyphs with
-- vim.g.have_nerd_font (see init.lua).
local nerd = vim.g.have_nerd_font

return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', { 'nvim-tree/nvim-web-devicons', cond = nerd } },
  ft = 'markdown',
  keys = {
    { '<leader>tm', '<cmd>RenderMarkdown buf_toggle<cr>', desc = 'Toggle markdown rendering' },
  },
  opts = {
    sign = { enabled = false },
    heading = nerd and {} or { icons = {}, sign = false },
    bullet = nerd and {} or { icons = { '-', '-', '-', '-' } },
    checkbox = nerd and {} or {
      unchecked = { icon = '[ ]' },
      checked = { icon = '[x]' },
    },
    code = nerd and {} or { language_icon = false, sign = false },
  },
}
