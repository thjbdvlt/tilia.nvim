local function find_buf_by_path(path)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local buf_path = vim.fs.abspath(vim.api.nvim_buf_get_name(buf))
    if buf_path == path then
      return buf
    end
  end
  return nil
end

local function add_to_file_not_open(file, linenr, line)
  local lines = {}
  for i in io.lines(file) do
    table.insert(lines, i)
  end
  if linenr == -1 then
    linenr = #lines
  end
  table.insert(lines, linenr, line)
  local f = io.open(file, "w")
  if not f then
    print("(Tilia) Error open file:", file)
    return
  end
  f:write(table.concat(lines, "\n"))
  f:close()
end

local function add_to_file_open(file, linenr, line)
  local buf = find_buf_by_path(file)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  if linenr == -1 then
    table.insert(lines, line)
  else
    table.insert(lines, linenr, line)
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

-- To append to a file, use -1 as linenr.
return function(file, linenr, line)
  if #vim.api.nvim_list_uis() > 0 and vim.fn.bufloaded(file) ~= 0 then
    add_to_file_open(file, linenr, line)
  else
    add_to_file_not_open(file, linenr, line)
  end
end
