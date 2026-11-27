-- rendered markdown in normal mode. ASCII by default, Nerd Font glyphs with
-- vim.g.have_nerd_font (see init.lua).
local nerd = vim.g.have_nerd_font

-- plugin defaults that use Nerd Font or box-drawing glyphs, replaced with ASCII
local ascii = {
  sign = { enabled = false },
  -- an empty inline icon still hides the `#` marker. A nil icon does not.
  heading = { position = 'inline', icons = { '' }, sign = false },
  bullet = { icons = { '-', '-', '-', '-' } },
  checkbox = {
    unchecked = { icon = '[ ]' },
    checked = { icon = '[x]' },
    custom = { todo = { rendered = '[-]' } },
  },
  code = { language_icon = false, sign = false, language_border = ' ', above = ' ', below = ' ' },
  dash = { icon = '-' },
  quote = { icon = '|' },
  indent = { icon = '|' },
  pipe_table = {
    border = { '+', '+', '+', '+', '+', '+', '+', '+', '+', '|', '-' },
    alignment_indicator = ':',
  },
  -- links only add icons
  link = { enabled = false },
  callout = {},
}
-- callout titles: plain name instead of an icon and the name
for _, name in ipairs({
  'note', 'tip', 'important', 'warning', 'caution', 'abstract', 'summary', 'tldr',
  'info', 'todo', 'hint', 'success', 'check', 'done', 'question', 'help', 'faq',
  'attention', 'failure', 'fail', 'missing', 'danger', 'error', 'bug', 'example',
  'quote', 'cite',
}) do
  ascii.callout[name] = { rendered = name:sub(1, 1):upper() .. name:sub(2) }
end

return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', { 'nvim-tree/nvim-web-devicons', cond = nerd } },
  ft = 'markdown',
  keys = {
    { '<leader>tm', '<cmd>RenderMarkdown buf_toggle<cr>', desc = 'Toggle markdown rendering' },
  },
  opts = nerd and { sign = { enabled = false } } or ascii,
}
