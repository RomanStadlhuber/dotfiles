-- Language servers. mason installs them into stdpath('data')/mason, so no
-- system packages are needed. setup.sh runs :MasonToolsInstallSync to
-- install them headless. The names are both mason package names and
-- nvim-lspconfig config names.
local servers = { 'clangd', 'basedpyright', 'ruff' }

return {
  {
    'mason-org/mason.nvim',
    -- setup() puts mason's bin dir on PATH, so vim.lsp finds the servers
    opts = {},
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'mason-org/mason.nvim' },
    opts = { ensure_installed = servers },
  },
  {
    -- the server configs (lsp/*.lua), plus clangd's :LspClangdSwitchSourceHeader.
    -- nvim's own client runs them.
    'neovim/nvim-lspconfig',
    dependencies = { 'mason-org/mason.nvim' },
    config = function()
      -- basedpyright finds a uv project's <root>/.venv by itself.
      -- Its default mode ('recommended') is very strict. 'standard' is the
      -- milder default. A [tool.basedpyright] section in pyproject.toml (or a
      -- pyrightconfig.json) replaces these settings. Without typeCheckingMode
      -- there, basedpyright falls back to 'recommended'.
      vim.lsp.config('basedpyright', {
        settings = { basedpyright = { analysis = { typeCheckingMode = 'standard' } } },
      })
      -- adding this as incremental sync broke some c++ files while in edit
      vim.lsp.config('clangd', { flags = { allow_incremental_sync = false } })
      vim.lsp.enable(servers)

      -- nvim 0.12 already maps K (hover), grn (rename), gra (code action),
      -- gri (implementation), grt (type definition), gO (document symbols),
      -- insert <C-s> (signature help), <C-]> (definition), <C-w>] (definition
      -- in a split) and <C-w>} (definition in the preview window).
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local map = function(lhs, rhs, desc)
            vim.keymap.set('n', lhs, rhs, { buffer = args.buf, desc = desc })
          end
          local builtin = require('telescope.builtin')
          map('gd', builtin.lsp_definitions, 'Go to definition')
          map('grr', builtin.lsp_references, 'References (with preview)')

          if vim.lsp.get_client_by_id(args.data.client_id).name == 'clangd' then
            map('<leader>h', '<cmd>LspClangdSwitchSourceHeader<cr>', 'Switch header/source')
            map('<leader>H', '<cmd>vsplit | LspClangdSwitchSourceHeader<cr>',
              'Header/source side by side')
          end
        end,
      })
    end,
  },
}
