-- :Cheatsheet opens a float with the key list. "General" always shows.
-- A language section shows when the current buffer has a matching filetype.
local general = [[
# General

## Telescope
`<leader>ff` files, `<leader>fg` grep
`<leader>fb` buffers, `<leader>fr` recent
`<leader>fh` help

## Search
`<leader>/` search the visible lines only
`<leader>s` (visual) search + replace the selection

## LSP
`gd` definition, `grr` references (Telescope)
`K` hover, `grn` rename
`gra` code action, `gri` implementation
`grt` type definition, `gO` document symbols
`<C-]>` tag jump, `<C-w>]` jump in split
`<C-w>}` preview window

## Diagnostics
`]d` / `[d` next / previous, `<C-w>d` float
`<leader>td` toggle all
`<leader>tv` line-end text: cursor line / all lines

## Edit
`<C-s>` format + save (normal and insert)

## Completion (blink.cmp, insert mode)
`<C-space>` open menu (again: show / hide docs)
`<C-n>` / `<C-p>` or `<Down>` / `<Up>` select
`<C-y>` accept, `<C-e>` or `<C-d>` close
`<C-b>` / `<C-f>` scroll docs
`<Tab>` / `<S-Tab>` next / previous snippet field
`<C-k>` show / hide signature
`:lua vim.b.completion = false` turns completion off for the buffer
]]

local c_cpp = [[
# C/C++

`<leader>h` switch header/source
`<leader>H` header/source side by side

## Project files
`compile_commands.json` navigation
(CMake: `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`)
`.clang-format` used by `<C-s>`
`.clang-tidy` extra diagnostics

## clangd in docker
`.nvim.lua` in the project root can run clangd in docker:

```lua
vim.lsp.config('clangd', {
  cmd = {
    'docker', 'exec', '-i', '-u', '<uid>:<gid>', '<container>',
    'clangd', '--path-mappings=<host dir>=<container dir>',
  },
})
```
]]

local python = [[
# Python

## Project files
ruff: reads `[tool.ruff]` in `pyproject.toml`
basedpyright: reads `typeCheckingMode` from `[tool.basedpyright]`
in `pyproject.toml` or from `pyrightconfig.json`
(this config defaults to `standard`)
uv projects: basedpyright finds `.venv` without config
]]

local sections_by_ft = { c = c_cpp, cpp = c_cpp, python = python }

local function build_lines(ft)
  local text = general
  local extra = sections_by_ft[ft]
  if extra then
    text = text .. '\n' .. extra
  end
  return vim.split(vim.trim(text), '\n')
end

local function open()
  local lines = build_lines(vim.bo.filetype)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = 'markdown'
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = 'wipe'

  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(l))
  end
  width = math.min(width + 2, vim.o.columns - 2)
  -- cmdheight and the border take 2 lines each (border: top and bottom)
  local max_height = math.max(vim.o.lines - vim.o.cmdheight - 2, 1)
  local height = math.min(#lines, max_height)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((max_height - height) / 2),
    col = math.floor((vim.o.columns - width - 2) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' Cheatsheet ',
    title_pos = 'center',
  })
  vim.wo[win].wrap = false

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end
  for _, key in ipairs({ 'q', '<Esc>' }) do
    vim.keymap.set('n', key, close, { buffer = buf, nowait = true, desc = 'Close cheatsheet' })
  end
end

vim.api.nvim_create_user_command('Cheatsheet', open, { desc = 'Show the key cheatsheet' })
