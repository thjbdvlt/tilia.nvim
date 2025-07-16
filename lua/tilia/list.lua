local sort = require "tilia.sort"
local opts = require "tilia.opts"
local util = require "tilia.util"
local parse = require "tilia.parse"
local window = require "tilia.window"
local open = require "tilia.open"
local conv = require "tilia.conv"


local function parse_tasks()
  -- Default due date is when the sun will die in 5 billion years
  local default_due = os.time({ year = 5000000000, month = 99, day = 99, s = "" })
  local state = {
    year = util.curyear(),
    no_due = { time = default_due, s = "" },
    project = "",
    tree = {},
    tree_due = {},
    priority = nil,
    tree_priority = {},
  }
  local output = io.popen(opts.cmd_find_todo_files)
  if not output then return {} end
  local tasks = {}
  for file in output:lines() do
    state.project = ""
    state.tree = {}
    local n = 0
    for l in io.lines(file) do
      n = n + 1
      local task = parse.parse_line(l, state)
      if task ~= nil then
        task.file = file
        task.linenr = n
        table.insert(tasks, task)
      end
    end
  end
  output:close()
  return tasks
end

local function filter(tasks, searches)
  if opts.iconv_search then
    for i, s in ipairs(searches) do
      searches[i] = conv(s)
    end
  end
  if searches then
    local filtered_tasks = {}
    for i = 1, #tasks do
      local s = vim.fn.tolower(tasks[i].text)
      if opts.iconv_search then
        s = conv(s)
      end
      if util.match(s, searches) then
        table.insert(filtered_tasks, tasks[i])
      end
    end
    tasks = filtered_tasks
  end
  return tasks
end

return function(searches)
  local tasks = parse_tasks()
  if searches[1] == "!" then
    searches[1] = ""
    table.sort(tasks, sort.sort_priority_date)
  else
    table.sort(tasks, sort.sort_date_priority)
  end
  tasks = filter(tasks, searches)
  if not tasks[1] then
    print("No task found.")
    return
  elseif not tasks[2] then
    open(tasks[1])
    return
  end
  local lines = {}
  for i = 1, #tasks do
    table.insert(lines, tasks[i].text)
  end
  local buf, win = window.list(lines)
  window.map_q(buf)
  window.map_open(buf, tasks)
  return win
end
