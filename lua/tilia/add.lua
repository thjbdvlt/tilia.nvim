local opts = require "tilia.opts"
local pro = require "tilia.projects"
local write = require "tilia.write"

local function serialize(t)
  local due, indent = '', ''
  local desc = t.desc
  if t.due then
    due = ' @' .. table.concat({ t.due.day, t.due.month, t.due.year }, ".")
  end
  if t.project then
    for _ = 1, 1, opts.shiftwidth do
      indent = '  ' .. indent
    end
  end
  return indent .. '- ' .. desc .. due
end

local function parse_due(t)
  local prefix, due, suffix = t.desc:match("(.*)@(%d+)d%s?(.*)")
  if not due then return end
  t.due = os.date("*t", os.time() + (24 * 60 * 60 * due))
  t.desc = prefix .. suffix
end

local function parse_project(t)
  if t.desc:match("^%s*/") then
    t.project, t.desc = t.desc:match("^%s*/%s*(%S+)%s*(.*)")
  end
end

local function parse_add_input(desc)
  local t = { due = nil, project = nil, desc = desc }
  parse_due(t)
  parse_project(t)
  t.desc = t.desc:gsub("^%s+", ""):gsub("%s+$", "")
  if t.desc ~= "" then
    return t
  end
end

return function(args)
  local t = parse_add_input(table.concat(args, " "))
  if not t or not t.desc then
    print("No task description provided")
    return
  end
  local file, row, project, msg
  if not t.project then
    row = -1
    file = vim.fs.abspath(vim.fn.expand(opts.file_add_task))
    msg = "Task added"
  else
    project = pro.find(t.project)
    if not project then return end
    file = project.file
    row = project.row
    msg = "Task added to project " .. project.name
  end
  write(file, row, serialize(t))
  print(msg)
end
