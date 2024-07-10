---@class weasel.core.module.Loader
local Loader = {}

local resolver = require "weasel.core.module.resolver"

--- resolve a module name to a Lua path
--- 1. "provider.datamuse" -> "weasel.modules.provider.core.datamuse"
--- @param handle weasel.module.handle
--- @return boolean,any
function Loader.load_module(handle)
  local ok, module = pcall(require, handle.path)
  if not ok then
    return false, module
  end

  return true, module
end

---comment
---@param handle weasel.module.handle
---@return boolean
function Loader.module_is_loaded(handle) end
return Loader
