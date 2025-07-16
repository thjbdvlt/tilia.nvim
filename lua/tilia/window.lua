local opts = require "tilia.opts"
local open = require "tilia.open"

local M = {}

local function winconfig()
  if type(opts.float_win_config) == "function" then
    return opts.float_win_config()
  else
    return opts.float_win_config
  end
end

function M.minwidth(lines)
  local width = 1
  for _, i in ipairs(lines) do
    local len = i:len()
    if len > width then
      width = i:len()
    end
  end
  return width
end

local function make_window(lines, options, config)
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, config)
  vim.api.nvim_buf_set_lines(buf, 0, 1, true, lines)
  for k, v in pairs(options) do
    vim.api.nvim_buf_set_option(buf, k, v)
  end
  return buf, win
end

function M.project(lines)
  local options = {
    ft = nil,
    wrap = opts.float_wrap,
    signcolumn = "no",
    stc = "",
    modifiable = false,
    number = false,
    relativenumber = false,
  }
  local config = {
    relative = "win",
    row = 0,
    col = 0,
    width = M.minwidth(lines),
    height = #lines,
    style = nil,
    border = 'single',
  }
  return make_window(lines, options, config)
end

function M.list(lines)
  local options = {
    ft = "tilia",
    wrap = opts.float_wrap,
    signcolumn = "no",
    stc = "",
    modifiable = false,
    relativenumber = false,
    number = false,
  }
  return make_window(lines, options, winconfig())
end

function M.map_q(buf)
  vim.api.nvim_buf_set_keymap(buf, "n", opts.map.quit, "", {
    callback = function()
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  })
end

function M.map_open(buf, lookup)
  vim.api.nvim_buf_set_keymap(buf, "n", opts.map.open, "", {
    callback = function()
      local row = vim.api.nvim_win_get_cursor(0)[1]
      vim.api.nvim_buf_delete(buf, { force = true })
      open(lookup[row])
    end
  })
end

return M
