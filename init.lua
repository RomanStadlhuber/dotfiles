-- minimal options so the scratch config is usable
vim.g.mapleader = ' ' -- leader is used to add plugin bindings
vim.g.maplocalleader = ' '
vim.opt.number = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- yank to the system clipboard, but only when it is reachable. Without X
-- access (e.g. a docker container without xhost) every yank would fail.
local function clipboard_reachable()
  if vim.fn.executable('xclip') == 0 then
    return true -- other or no clipboard tool: nvim handles it
  end
  local r = vim.system({ 'xclip', '-selection', 'clipboard', '-t', 'TARGETS', '-o' }, { text = true })
    :wait(1000)
  return r.code ~= 124 and not (r.stderr or ''):find('open display')
end
if clipboard_reachable() then
  vim.opt.clipboard = 'unnamedplus'
end
vim.opt.mouse = 'a'
-- load a project's .nvim.lua (per-project settings, e.g. clangd in a docker
-- container). nvim asks once per file before it runs one.
vim.opt.exrc = true

-- custom keymaps
require('keymaps')
require('diagnostics')


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
