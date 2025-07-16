local do_undo = require "tilia.do_undo"
local util = require "tilia.util"

local function new(before)
  local x, y, cursor_x
  if before == false then
    x = 0
    y = 2
    cursor_x = 1
  else
    x = -1
    y = 0
    cursor_x = 1
  end
  local line_start = vim.api.nvim_win_get_cursor(0)[1]
  local indent = util.get_indent(vim.api.nvim_get_current_line())
  line_start = line_start + x
  indent = indent + y
  if line_start < 0 then
    line_start = 0
  end
  local prefix = { "- " }
  for _ = 1, indent do
    table.insert(prefix, 1, ' ')
  end
  local lines = { table.concat(prefix) }
  vim.api.nvim_buf_set_lines(0, line_start, line_start, false, lines)
  vim.api.nvim_win_set_cursor(0, { line_start + cursor_x, 0 })
  do_undo.undo_recursive(nil, indent)
  vim.cmd [[startinsert!]]
end

return {
  after = function() return new(false) end,
  before = function() return new(true) end
}
