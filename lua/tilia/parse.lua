local tr = require "tilia.tree"
local util = require "tilia.util"

local M = {}

local function parse_priority(s)
  if s:find("%!") then
    s = s:gsub('"[^"]+"', ""):gsub("%([^%)]+%)", "")
    local priority = util.count(s, "!")
    if priority ~= 0 then
      return priority
    end
  elseif s:find("%?") then
    return -util.count(s, "?")
  end
end

local function parse_date(s, state)
  local day, month, year = s:match("(%d+)%.(%d+)%.?(%d*)")
  if not day or not month then return nil end
  local fmt
  if year == '' or tonumber(year) == state.year then
    year = state.year
    fmt = " @%d.%m"
  else
    fmt = " @%d.%m.%y"
  end
  local time = os.time({ day = day, month = month, year = year })
  return { time = time, s = os.date(fmt, time) }
end

function M.parse_line(line, state)
  local indent, sign = util.get_indent(line)
  if sign == "/" and indent == 0 then
    state.project = line:gsub("^%s*/%s*", "")
    state.tree = {}
    state.tree_due = {}
    state.tree_priority = {}
    return nil
  elseif sign ~= "-" then
    return nil
  end
  local text = line:sub(indent + 1, #line)
  local start_index, end_index = line:find("@[%d%.]+")
  local due
  if start_index ~= nil then
    due = parse_date(line:sub(start_index, end_index), state)
  else
    due = tr.get_from_tree(indent, state, "tree_due")
    if due ~= nil then
      text = text .. due.s
    else
      due = state.no_due
    end
  end
  local priority = (parse_priority(text) or 0) + (tr.get_from_tree(indent, state, "tree_priority") or 0)
  state.tree[indent] = text
  state.tree_due[indent] = due
  state.tree_priority[indent] = priority
  return {
    project = state.project,
    text = tr.clean_main(text) .. tr.tree_to_string(indent, state),
    due = due,
    indent = indent,
    priority = priority or 0,
  }
end

return M
