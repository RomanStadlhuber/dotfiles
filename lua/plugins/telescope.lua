return {
  'nvim-telescope/telescope.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  config = function()
    local telescope = require('telescope')
    -- include hidden files (dotfiles), but not the .git folder.
    -- Files in .gitignore stay excluded.
    local hidden = { '--hidden', '--glob', '!**/.git/*' }
    telescope.setup({
      pickers = {
        find_files = { find_command = vim.list_extend({ 'rg', '--files' }, hidden) },
        live_grep = { additional_args = hidden },
        grep_string = { additional_args = hidden },
      },
    })
    pcall(telescope.load_extension, 'fzf')

    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep,  { desc = 'Live grep' })
    vim.keymap.set('n', '<leader>fb', builtin.buffers,    { desc = 'Buffers' })
    vim.keymap.set('n', '<leader>fh', builtin.help_tags,  { desc = 'Help tags' })
    vim.keymap.set('n', '<leader>fr', builtin.oldfiles,   { desc = 'Recent files' })
  end,
}
