-- file tree. ASCII symbols by default, Nerd Font icons with vim.g.have_nerd_font
-- (see init.lua).
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
    },
    filesystem = {
      -- show dotfiles. Gitignored files stay hidden. `H` toggles them.
      filtered_items = { hide_dotfiles = false },
    },
  },
  config = function(_, opts)
    if not nerd then
      -- neo-tree reads diagnostic symbols from the diagnostic config
      opts.default_component_configs.diagnostics = {
        symbols = { hint = 'H', info = 'I', warn = 'W', error = 'E' },
      }
    end
    require('neo-tree').setup(opts)
  end,
}
