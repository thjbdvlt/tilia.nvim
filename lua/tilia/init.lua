local toggle = require "tilia.toggle"
local insert_new = require "tilia.insert_new"
local opts = require "tilia.opts"

local M = { opts = opts }

local maps = {
  ["n"] = {
    toggle = toggle.Toggle,
    do_recursive = toggle.DoRecursive,
    new_after = insert_new.after,
    new_before = insert_new.before,
  }
}

local function set_keymaps()
  for mode, modemaps in pairs(maps) do
    for k, fn in pairs(modemaps) do
      k = M.opts.map[k]
      if k ~= nil then
        vim.api.nvim_buf_set_keymap(0, mode, k, "", {
          silent = true, noremap = true, callback = fn
        })
      end
    end
  end
end

local cmds = {
  list = require "tilia.list",
  add = require "tilia.add",
  clean = require "tilia.clean",
}

local function Cmd(args)
  local cmd_name = args.fargs[1]
  table.remove(args.fargs, 1)
  local fn = cmds[cmd_name]
  if fn then
    fn(args.fargs)
  else
    vim.notify("Unkown command: " .. cmd_name, 1, {})
  end
end

function M.setup()
  vim.api.nvim_create_user_command(opts.user_cmd, Cmd, { nargs = '+' })
  vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = opts.ft,
    callback = set_keymaps,
  })
end

return M
