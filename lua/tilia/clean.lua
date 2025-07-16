return function()
  local buf = vim.api.nvim_get_current_buf()
  if vim.api.nvim_get_option_value("ft", { scope = "local", buf = buf }) ~= "tilia" then return end
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local new = {}
  for _, line in ipairs(lines) do
    if not line:find('^%s*x') then
      table.insert(new, line)
    end
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, new)
end
