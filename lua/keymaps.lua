vim.keymap.set("v", "<leader>s", function()
  -- Yank the visual selection into register "v"
  vim.cmd('noau normal! "vy"')
  local text = vim.fn.getreg("v")

  -- Escape special characters for the search pattern
  text = vim.fn.escape(text, "/\\.*$^~[]")
  text = text:gsub("\n", "\\n")

  -- Pre-fill the command line with :%s/<text>//gc
  local keys = ":%s/" .. text .. "/" .. text .. "/gc"
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(keys, true, false, true),
    "n",
    false
  )

  -- Move cursor left so it sits between the two slashes
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(string.rep("<Left>", 3), true, false, true),
    "n",
    false
  )
end, { desc = "Search and replace visual selection" })
