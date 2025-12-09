local opts = require "tilia.opts"
local util = require "tilia.util"
local window = require "tilia.window"
local open = require "tilia.open"
local conv = require "tilia.conv"

local parse = require "tilia.parse"

local M = {}

local function common_prefix_len(a, b)
  local max = math.min(a:len(), b:len())
  for i = 1, max do
    if a:sub(1, i) ~= b:sub(1, i) then
      return i - 1
    end
  end
  return max
end

local function find_uniq_prefixes(t)
  local ids, cmp = {}, {}
  for _, i in ipairs(t) do cmp[i] = {} end
  for _, i in ipairs(t) do
    local common = 0
    local min = 0
    for _, y in ipairs(t) do
      if i ~= y then
        common = cmp[y][i] or common_prefix_len(i, y)
        if common > min then
          min = common
        end
        cmp[i][y] = common
      end
    end
    table.insert(ids, min + 1)
  end
  return ids
end

local function parse_projects()
  local output = io.popen(opts.cmd_find_todo_files)
  local now = os.time()
  local current_year = util.year(now)
  local state = {year = current_year}
  if not output then return {} end
  local projects = {}
  local pro
  for file in output:lines() do
    local row = 1
    for line in io.lines(file) do
      row = row + 1
      local indent, sign = util.get_indent(line)
      if indent == 0 then
        local name = conv(line:gsub("^/%s*", ""))
        table.insert(projects, pro)
        if sign == "/" then
          pro = {
            file = file,
            row = row,
            n = 0,
            priority = 0,
            time = nil,
            name = name,
          }
        else
          pro = nil
        end
      elseif sign == "-" and pro then
        local s = line:gsub('"[^"]+"', ""):gsub("%([^%)]+%)", "")
        pro.n = pro.n + 1
        local time = parse.parse_date(s, state)
        if time then
          pro.time = math.min(time.time, pro.time or now)
        end
        if s:find("%!") then
          local priority = util.count(s, "!")
          if priority > pro.priority then
            pro.priority = priority
          end
        end
      end
    end
    if pro then
      table.insert(projects, pro)
      pro = nil
    end
  end
  return projects
end

-- List projects, filtered using a fixed string search
function M.list(search)
  search = conv(search)
  local output = io.popen(opts.cmd_find_todo_files)
  local current_year = util.curyear()
  if not output then return {} end
  local projects = {}
  local pro
  for file in output:lines() do
    local row = 1
    for line in io.lines(file) do
      row = row + 1
      if line:sub(1, 1) == "/" then
        line = conv(line:gsub("^/%s*", ""))
        if line:find(search) then
          table.insert(projects, { file = file, name = line, row = row })
        end
      end
    end
  end
  return projects
end

-- Find a project using a fixed string search
function M.find(search)
  local projects = M.list(search)
  local n = #projects
  if n == 0 then
    if search then
      print("Project not found.")
    end
    return
  elseif n == 1 then
    return projects[1]
  end
  -- If there are many projects that match that search, then we look for one that are prefixed by this search. If there are only one that starts with this string, it"s considered to be the searched project.
  local projects_prefixed = {}
  local name_len = search:len()
  for _, pro in ipairs(projects) do
    if search == pro.name:sub(1, name_len) then
      table.insert(projects_prefixed, pro)
    end
  end
  if #projects_prefixed == 1 then
    return projects_prefixed[1]
  end
  -- If no project name starts with the search, or if many do, it"s an ambiguous project name search.
  print("Ambiguous project description. Matches:")
  for _, pro in pairs(projects) do
    print("  ", pro.name)
  end
  return nil
end

local function set_marks_project_id(projects, buf, ns)
  local set_mark = vim.api.nvim_buf_set_extmark
  for _, t in pairs(projects) do
    set_mark(buf, ns, t.row, t.id.col, {
      hl_group = "TiliaProjectID",
      end_col = t.id.end_col,
      strict = false,
    })
    set_mark(buf, ns, t.row, t.id.end_col, {
      hl_group = "TiliaProjectNONID",
      end_col = t.len,
      strict = false,
    })
    local hl = {
      priority = "Operator",
      time = "Constant",
      number = "Statement",
    }
    for k, v in pairs(hl) do
      if t.idx[k] then
        set_mark(buf, ns, t.row, t.idx[k].start_idx, {
          end_col = t.idx[k].end_idx,
          strict = false,
          hl_group = v,
        })
      end
    end
  end
end

function M.go_project(args)
  local project = M.find(args[1])
  if project then
    open({ file = project.file, linenr = project.row })
  else
    M.projects()
  end
end

local function serialize_project_infos(p, now)
  local s = p.name
  local idx = p.len
  p.idx = { name = { start_idx = 0, end_col = p.len } }
  if p.priority > 0 then
    p.idx.priority = { start_idx = idx }
    s = s .. " "
    for _ = 1, p.priority do
      s = s .. "!"
    end
    idx = idx + p.priority + 1
    p.idx.priority.end_idx = idx
  end
  if p.time then
    p.idx.time = { start_idx = idx }
    local days = math.floor(os.difftime(p.time, now) / (24 * 60 * 60)) .. "d"
    s = s .. " " .. days
    idx = idx + days:len() + 1
    p.idx.time.end_idx = idx
  end
  p.idx.number = { start_idx = idx }
  local n = tostring(p.n)
  s = s .. " " .. n
  p.idx.number.end_idx = idx + 1 + n:len()
  return s
end

function M.projects()
  local now = os.time()
  -- Parse all projects and sort by number of tasks
  local projects = parse_projects()
  table.sort(projects, function(a, b) return a.n > b.n end)
  -- Extract names and get unique IDs
  local names = {}
  for _, i in ipairs(projects) do
    table.insert(names, i.name)
    i.len = i.name:len()
  end
  -- Serialize due and priority
  local lines = {}
  for _, p in ipairs(projects) do
    local s = serialize_project_infos(p, now)
    table.insert(lines, s)
    p.s = s
  end
  -- Put highlight marks
  local marks = {}
  local uniq_prefixes = find_uniq_prefixes(names)
  for i, t in ipairs(projects) do
    local id_len = uniq_prefixes[i]
    t.id = { col = 0, end_col = id_len }
    t.linenr = t.row -- Position in file
    t.row = i - 1    -- Position in floating window
    table.insert(marks, t)
  end
  local ns = vim.api.nvim_create_namespace("Tilia")
  local buf, win = window.project(lines)
  window.map_q(buf)
  window.map_open(buf, marks)
  set_marks_project_id(marks, buf, ns)
  return win
end

return M
