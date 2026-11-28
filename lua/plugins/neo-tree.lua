-- file tree. Nerd Font icons only with vim.g.have_nerd_font (see init.lua).
-- Else ASCII replaces the Nerd glyphs. Plain Unicode defaults (tree lines) stay.
local nerd = vim.g.have_nerd_font

return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    -- file icons: only loaded with a Nerd Font
    { 'nvim-tree/nvim-web-devicons', cond = nerd },
  },
  cmd = 'Neotree',
  keys = {
    { '<leader>e', '<cmd>Neotree toggle<cr>', desc = 'Toggle file tree' },
  },
  init = function()
    -- tree lines: the default highlight is too dim to see
    local function link()
      vim.api.nvim_set_hl(0, 'NeoTreeIndentMarker', { link = 'Comment' })
    end
    link()
    vim.api.nvim_create_autocmd('ColorScheme', { callback = link })
  end,
  opts = {
    default_component_configs = {
      icon = nerd and {} or {
        folder_closed = '+',
        folder_open = '-',
        folder_empty = 'o',
        folder_empty_open = 'o',
        selected = 'x',
        default = ' ', -- file icon
      },
      indent = nerd and {} or {
        expander_collapsed = '+',
        expander_expanded = '-',
      },
      git_status = {
        symbols = nerd and {} or {
          added = '[+]',
          modified = '[~]',
          deleted = '[x]',
          renamed = '[r]',
          untracked = '[?]',
          ignored = '[i]',
          unstaged = '[u]',
          staged = '[s]',
          conflict = '[!]',
        },
      },
      diagnostics = nerd and {} or {
        symbols = { hint = 'H', info = 'I', warn = 'W', error = 'E' },
      },
    },
    filesystem = {
      -- show dotfiles. Gitignored files stay hidden. `H` toggles them.
      filtered_items = { hide_dotfiles = false },
      -- expand the tree to the file of the current buffer
      follow_current_file = { enabled = true },
    },
  },
}
