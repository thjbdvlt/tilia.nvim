local opts = require "tilia.opts"

return function(t)
  vim.cmd.edit(t.file)
  vim.api.nvim_win_set_cursor(0, { t.linenr, 0 })
  vim.cmd(opts.after_open)
end
