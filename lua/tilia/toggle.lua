local util = require "tilia.util"
local do_undo = require "tilia.do_undo"

local M = {}

function M.DoRecursive()
  -- Current line
  local line = vim.api.nvim_get_current_line()
  local indent, _ = util.get_indent(line)
  vim.api.nvim_set_current_line(do_undo.set_sign(line, indent + 1, "x"))
  -- Subsequent lines
  local line_start = vim.api.nvim_win_get_cursor(0)[1]
  local new_lines = do_undo.do_sub_lines(line_start, indent)
  if new_lines == nil then return end
  local line_end = line_start + #new_lines
  vim.api.nvim_buf_set_lines(0, line_start, line_end, true, new_lines)
end

function M.Toggle()
  local line = vim.api.nvim_get_current_line()
  local indent = 0
  for i = 1, #line do
    local new
    local c = string.sub(line, i, i)
    if c ~= " " then
      new = util.get_new_char(c)
      if new == nil then return end
      if do_undo.check_doable(indent, c) == true then
        vim.api.nvim_set_current_line(do_undo.set_sign(line, i, new))
        if new == "-" then
          do_undo.undo_recursive(nil, indent)
        end
      end
    else
      indent = indent + 1
    end
  end
end

return M
