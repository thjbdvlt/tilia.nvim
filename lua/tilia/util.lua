local M = {}

-- TODO: Configurable signs?
function M.get_new_char(c)
  if c == "-" then
    return "x"
  elseif c == "x" then
    return "-"
  else
    return nil
  end
end

function M.get_priority_from_string(s)
  s = s:gsub('"[^"]+"', ""):gsub("%([^%)]+%)", "")
  local priority = M.count(s, "!")
  if priority ~= 0 then
    return priority
  end
  return -M.count(s, "?")
end

-- Get indent length and first char
function M.get_indent(s)
  local indent, first_char = s:match("^( *)(.)")
  if indent then
    return indent:len(), first_char
  end
  return 0, first_char
end

-- https://stackoverflow.com/questions/11152220
-- /counting-number-of-string-occurrences
function M.count(s, c)
  return select(2, string.gsub(s, c, ""))
end

function M.match(text, searches)
  text = vim.fn.tolower(text)
  local next_not = false
  for i = 1, #searches do
    if searches[i] == "not" then
      next_not = true
    else
      local start_index, _ = string.find(text, searches[i], 1, true)
      if start_index == nil and not next_not then
        return false
      elseif start_index ~= nil and next_not then
        return false
      end
      next_not = false
    end
  end
  return true
end

function M.get_priority_from_tree(indent, state)
  -- for i=indent-1, 0, -1 do
  for i=indent-1, 0, -1 do
    local p = state.tree_priority[i]
    if p ~= nil then
      return p
    end
  end
end

function M.get_due_from_tree(indent, state)
  for i=indent-1, 0, -1 do
    local due = state.tree_due[i]
    if due ~= nil then
      return due
    end
  end
end

return M
