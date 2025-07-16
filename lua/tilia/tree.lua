local opts = require "tilia.opts"

local M = {}

-- Remove due dates, comments in parentheses and multipe spaces
function M.clean_string(s)
  return s:gsub(" @[%d%.]+", ""):gsub(" %([^%)]+%)", ""):gsub("  +", " ")
end

function M.clean_main(s)
  return s:gsub("%([^%)]+%)", "()"):gsub("|", "_")
end

function M.tree_to_string(indent, state)
  local tree = ""
  for i = indent - 1, 0, -1 do
    local y = state.tree[i]
    if y ~= nil then
      if opts.tree_truncate ~= nil then
        y = y:sub(1, opts.tree_truncate)
      end
      tree = tree .. " | " .. y:gsub("^[-%s]+", "")
    end
  end
  if state.project ~= nil and state.project ~= "" then
    tree = tree .. " /" .. state.project .. '/'
  end
  return M.clean_string(tree)
end

function M.get_from_tree(indent, state, key)
  for i = indent - 1, 0, -1 do
    local due = state[key][i]
    if due ~= nil then
      return due
    end
  end
end

return M
