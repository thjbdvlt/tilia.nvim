local M = {}

-- Most indented tasks have higher rank
local function sort_by_indent(i1, i2)
  if i1 > i2 then
    return true
  elseif i1 < i2 then
    return false
  else
    return nil
  end
end

-- Task with nearest due date have higher rank
local function sort_by_date(d1, d2)
  if d1 == d2 then
    return nil
  elseif d1.time > d2.time then
    return false
  elseif d2.time < d1.time then
    return true
  else
    return nil
  end
end

-- Task with highest priority have higher rank
local function sort_by_priority(p1, p2)
  if p1 > p2 then
    return true
  elseif p1 < p2 then
    return false
  else
    return nil
  end
end

function M.sort_date_priority(t1, t2)
  local x
  x = sort_by_date(t1.due, t2.due)
  if x ~= nil then return x end
  x = sort_by_priority(t1.priority, t2.priority)
  if x ~= nil then return x end
  x = sort_by_indent(t1.indent, t2.indent)
  if x ~= nil then return x end
  return false
end

function M.sort_priority_date(t1, t2)
  local x
  x = sort_by_priority(t1.priority, t2.priority)
  if x ~= nil then return x end
  x = sort_by_date(t1.due, t2.due)
  if x ~= nil then return x end
  x = sort_by_indent(t1.indent, t2.indent)
  if x ~= nil then return x end
  return false
end

return M
