local util = require "tilia.util"

local M = {}

function M.set_sign(line, i, new)
  local line_start = string.sub(line, 1, i - 1)
  local line_end = string.sub(line, i + 1, #line)
  return line_start .. new .. line_end
end

function M.check_doable(indent, c)
  -- Ensure there is no situation like this one:
  --
  -- x done task 1
  --      - undone subtask 1.1
  --
  -- This should not be acceptable because 1 cannot considered
  -- done if 1.1 isn't.
  --
  -- (Tasks are always 'Undoable'.)
  if c == 'x' then return true end
  -- Get all lines after the current one.
  local line_start = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(0, line_start, -1, false)
  for y = 1, #lines do
    local line = lines[y]
    local sub_indent, x = util.get_indent(line)
    -- Equal/lower indentation: independant task
    if sub_indent <= indent then
      return true
    end
    -- If subtask isn't done, then task isn't neither. Tell to user.
    if x == '-' then
      local nr = y + line_start
      local msg = "Can't complete, incomplete subtask (L." .. nr .. ').'
      vim.notify(msg, 1, {})
      return false
    end
  end
  return true
end

function M.do_sub_lines(line_start, indent)
  local lines = vim.api.nvim_buf_get_lines(0, line_start, -1, false)
  local new_lines = {}
  for y = 1, #lines do
    local sub_line = lines[y]
    local sub_indent, sign = util.get_indent(sub_line)
    if sub_indent <= indent then
      return new_lines
    end
    if sign == '-' then
      sub_line = M.set_sign(sub_line, sub_indent + 1, 'x')
    end
    new_lines[y] = sub_line
  end
  return new_lines
end

function M.undo_recursive(line_end, indent)
  line_end = line_end or vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(0, 0, line_end, false)
  local new_lines = {}
  local cur_indent = indent
  for y = 1, #lines do
    y = #lines - y + 1
    local sub_line = lines[y]
    local sub_indent, sign = util.get_indent(sub_line)
    if sub_indent < indent and sub_indent < cur_indent and sign == 'x' then
      sub_line = M.set_sign(sub_line, sub_indent + 1, '-')
      cur_indent = sub_indent
    end
    table.insert(new_lines, 1, sub_line)
    if sub_indent == 0 then
      vim.api.nvim_buf_set_lines(0, y - 1, line_end, true, new_lines)
      return
    end
  end
end

return M
