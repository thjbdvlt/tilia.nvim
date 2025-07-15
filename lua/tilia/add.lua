local opts = require "tilia.opts"

local function days_from_now(days)
  local date = os.date("*t", os.time() + (24 * 60 * 60 * days))
  return {
    day = date.day,
    month = date.month,
    year = date.year,
    s = table.concat({ "@", date.day, ".", date.month, ".", date.year })
  }
end

local function parse_add_input(task)
  local start_index, end_index = string.find(task, "@%d+d")
  if start_index ~= nil then
    local days = string.sub(task, start_index + 1, end_index - 1)
    local due = days_from_now(days).s
    local task_start = string.sub(task, 1, start_index - 1)
    local task_end = string.sub(task, end_index + 1, #task)
    task = task_start .. due .. task_end
  end
  -- Check if empty
  local x = string.gsub(task, "%s*", "")
  if x == "" then
    return nil
  end
  return task
end

return function(desc)
  desc = parse_add_input(desc)
  if desc == nil then return end
  local f = io.open(vim.fn.expand(opts.file_add_task), "a")
  if not f then
    vim.notify("Error opening file. Task not added", 1, {})
    return
  end
  f:write("- " .. desc)
  f:close()
end
