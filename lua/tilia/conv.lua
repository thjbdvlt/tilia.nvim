local opts = require "tilia.opts"

local iconv = require "iconv"
local conv = vim.fn.tolower
if opts.iconv_from then
  local cd, err = iconv.new("ascii//translit", opts.iconv_from)
  if not err then
    conv = function(s) return cd:iconv(vim.fn.tolower(s)) end
  end
end

return conv
