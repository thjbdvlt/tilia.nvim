local sort = require "tilia.sort"
local opts = require "tilia.opts"
local util = require "tilia.util"
local parse = require "tilia.parse"

local function float_tasks(tasks, search)
  local buf = vim.api.nvim_create_buf(false, true)
  if opts.show_tree == true then
    for i = 1, #tasks do
      tasks[i].text = tasks[i].text .. tasks[i].tree
    end
  else
  end
  if search ~= nil then
    local filtered_tasks = {}
    for i = 1, #tasks do
      if util.match(tasks[i].text, search) then
        table.insert(filtered_tasks, tasks[i])
      end
    end
    tasks = filtered_tasks
  else
  end
  local lines = {}
  for i = 1, #tasks do
    local line = "- " .. tasks[i].text
    table.insert(lines, line)
  end
  vim.api.nvim_buf_set_lines(buf, 0, 1, true, lines)
  local float_win_config = opts.float_win_config
  if type(float_win_config) == "function" then
    float_win_config = float_win_config()
  end
  local win = vim.api.nvim_open_win(buf, true, float_win_config)
  vim.api.nvim_buf_set_option(buf, "ft", opts.ft)
  vim.api.nvim_buf_set_option(buf, "wrap", opts.float_wrap)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_keymap(buf, "n", opts.map.quit, "", {
    callback = function()
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  })
  vim.api.nvim_buf_set_keymap(buf, "n", opts.map.open, "", {
    callback = function()
      local row = vim.api.nvim_win_get_cursor(0)[1]
      vim.api.nvim_buf_delete(buf, { force = true })
      vim.cmd.edit(tasks[row].file)
      vim.api.nvim_win_set_cursor(0, { tasks[row].linenr, 0 })
    end
  })
  return win
end

return function(search)
  local state = {
    year = os.date("*t", os.time()).year,
    -- Default due date is when the sun will die in 5 billion years
    no_due = { year = 5000000000, month = 99, day = 99, s = "" },
    project = "",
    tree = {},
    tree_due = {},
    priority = nil,
  }
  local output = assert(io.popen(opts.cmd_find_todo_files))
  local tasks = {}
  for file in output:lines() do
    state.project = ""
    state.tree = {}
    local f = assert(io.open(file))
    local n = 0
    for l in f:lines() do
      n = n + 1
      local task = parse.parse_line(l, state)
      if task ~= nil then
        task.file = file
        task.linenr = n
        table.insert(tasks, task)
      end
    end
    f:close()
  end
  output:close()
  if search[1] == "!" then
    search[1] = ""
    table.sort(tasks, sort.sort2)
  else
    table.sort(tasks, sort.sort1)
  end
  float_tasks(tasks, search)
end
