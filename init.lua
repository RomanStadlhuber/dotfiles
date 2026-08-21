-- minimal options so the scratch config is usable
vim.g.mapleader = ' ' -- leader is used to add plugin bindings
vim.g.maplocalleader = ' '
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.mouse = 'a'

-- autorefresh
vim.opt.autoread = true
vim.opt.updatetime = 250

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  callback = function()
    if vim.fn.mode() ~= 'c' and vim.fn.getcmdwintype() == '' then
      vim.cmd.checktime()
    end
  end,
})

vim.api.nvim_create_autocmd('FileChangedShellPost', {
  callback = function()
    vim.notify('File reloaded from disk', vim.log.levels.WARN)
  end,
})


-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local ok = vim.system({
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath,
  }):wait()
  if ok.code ~= 0 then
    vim.notify('lazy.nvim clone failed — continuing without plugins', vim.log.levels.ERROR)
    return
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({ import = 'plugins' })
