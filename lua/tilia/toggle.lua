local util = require "tilia.util"
local do_undo = require "tilia.do_undo"

local M = {}

function M.DoRecursive()
  -- Current line
  local line = vim.api.nvim_get_current_line()
  local indent = util.get_indent(line)
  line = line:gsub("%S", "x", 1)
  vim.api.nvim_set_current_line(line)
  -- Subsequent lines
  local line_start = vim.api.nvim_win_get_cursor(0)[1]
  local new = do_undo.do_sub_lines(line_start, indent)
  if new then
    vim.api.nvim_buf_set_lines(0, line_start, line_start + #new, true, new)
  end
end

function M.Toggle()
  local line = vim.api.nvim_get_current_line()
  local indent = line:find("%S")
  local c = line:sub(indent, indent)
  local signs = { ["-"] = "x", ["x"] = "-" }
  local new = signs[c]
  if not new then return end
  if do_undo.check_doable(indent, c) then
    line = line:gsub(c, new, 1)
    vim.api.nvim_set_current_line(line)
  end
  if new == "-" then
    do_undo.undo_recursive(nil, indent)
  end
end

return M
