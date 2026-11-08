-- nvim-treesitter (main branch) compiles parsers with the tree-sitter CLI.
-- setup.sh installs a glibc-2.17 build of the CLI into stdpath('data')/bin,
-- so it also runs on older distros. Put that dir first on nvim's PATH, so a
-- system-wide tree-sitter (possibly one that cannot run here) never wins.
local bin = vim.fn.stdpath('data') .. '/bin'
if not vim.startswith(vim.env.PATH or '', bin .. ':') then
  vim.env.PATH = bin .. ':' .. (vim.env.PATH or '')
end

local parsers = {
  'c', 'cpp', 'cmake', 'make',
  'python',
  'lua', 'vim', 'vimdoc', 'query',
  'bash', 'json', 'yaml', 'toml',
  'markdown', 'markdown_inline',
}

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false, -- the main branch does not support lazy-loading
  build = ':TSUpdate',
  config = function()
    local task = require('nvim-treesitter').install(parsers)
    -- headless = setup.sh: block until the parsers are built, so the
    -- install is complete when the script exits
    if #vim.api.nvim_list_uis() == 0 then
      task:wait(300000)
    end

    vim.api.nvim_create_autocmd('FileType', {
      callback = function(args)
        -- start() fails when no parser exists for the filetype
        if pcall(vim.treesitter.start, args.buf)
            and not vim.tbl_contains({'c', 'cpp'}, vim.bo[args.buf].filetype)
        then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
