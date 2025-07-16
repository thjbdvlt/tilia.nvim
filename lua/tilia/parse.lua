local tree_to_line = require "tilia.tree_to_line"
local util = require "tilia.util"
local opts = require "tilia.opts"

local M = {}

local function parse_date(s, state)
  local due = { year = state.year, s = s, month = 0, day = 0 }
  local n = 1
  for d in string.gmatch(s, "%d+") do
    local v = tonumber(d)
    if n == 1 then
      due.day = v
    elseif n == 2 then
      due.month = v
    else
      due.year = v
    end
    n = n + 1
  end
  return due
end

function M.parse_line(line, state)
  local indent, sign = util.get_indent(line)
  if sign == "*" then
    state.project, _ = string.gsub(line, "^ *%* *", "")
    state.tree = {}
    state.tree_due = {}
    state.tree_priority = {}
    return nil
  elseif sign ~= "-" then
    return nil
  end
  local text = line:sub(indent+1, #line)
  local start_index, end_index = string.find(line, "@[%d%.]+")
  local due
  if start_index ~= nil then
    due = parse_date(string.sub(line, start_index, end_index), state)
  else
    due = util.get_due_from_tree(indent, state)
    if due ~= nil then
      text = text .. " " .. due.s
    else
      due = state.no_due
    end
  end
  local tree
  if opts.show_tree == true then
    tree = tree_to_line.tree_to_string(indent, state)
  end
  local priority = util.get_priority_from_string(text)
  if priority == 0 then
    priority = util.get_priority_from_tree(indent, state)
  end
  state.tree[indent] = text
  state.tree_due[indent] = due
  state.tree_priority[indent] = priority
  return {
    project = state.project,
    text = tree_to_line.clean_main(text),
    due = due,
    tree = tree,
    indent = indent,
    priority = priority or 0,
  }
end

return M
