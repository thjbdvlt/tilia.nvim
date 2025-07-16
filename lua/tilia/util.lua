local M = {}

-- Get indent length and first char
function M.get_indent(s)
  local start_idx = s:find("%S")
  if start_idx then
    return start_idx - 1, s:sub(start_idx, start_idx)
  end
  return 0, s:sub(1, 1)
end

-- https://stackoverflow.com/questions/11152220
-- /counting-number-of-string-occurrences
function M.count(s, c)
  return select(2, s:gsub(c, ""))
end

function M.match(text, searches)
  local next_not = false
  for _, s in ipairs(searches) do
    local match = text:find(s, 1, true)
    if s == "not" then
      next_not = true
    elseif (not match and not next_not) or (match and next_not) then
      return false
    else
      next_not = false
    end
  end
  return true
end

function M.escape_regex(s)
  return s:gsub("[%[%]%(%)%{%}%.%?%+%*%|%$%^%:%-%\\]", "\\%1")
end

function M.curyear()
  return os.date("*t", os.time()).year
end

return M
