local function project_root()
  local f = debug.getinfo(1, "S").source:sub(2)
  return vim.fn.fnamemodify(f, ":p:h:h")
end

local root = project_root()

vim.opt.runtimepath:append(root)
local log = require "weasel.core.log"
local client = require("weasel.core.client").Client.get "datamuse"

local result = client.methods.sounds_like "house"
-- vim.print(result)
result:thenCall(function(data)
  vim.print(">>>>>>>>>>>>>>>>>>>>>>>>>>> fullfilled", data)
end, function(reason)
  vim.print("client ERROR: ", reason)
end)
