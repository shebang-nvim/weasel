---@class weasel.core.module.loader
local Loader = {}

local _registry = {
  modules = {
    ---@type table<string,weasel.module.ModuleSpec>
    loaded = {},
  },
  count_loaded = 0,
}

local resolver = require "weasel.core.module.resolver"

---comment
--- @param handle weasel.module.handle
--- @return boolean
function Loader.is_loaded(handle)
  return _registry.modules.loaded[handle.path] ~= nil
end

---comment
--- @param handle weasel.module.handle
--- @return weasel.module.ModuleSpec
function Loader.get(handle)
  return _registry.modules.loaded[handle.path]
end

--- resolve a module name to a Lua path
--- 1. "provider.datamuse" -> "weasel.modules.provider.core.datamuse"
--- @param handle weasel.module.handle
--- @return boolean,weasel.module.ModuleSpec
function Loader.load_module(handle)
  if Loader.is_loaded(handle) then
    return true, Loader.get(handle)
  end

  local ok, module = pcall(require, handle.path)
  if not ok then
    return false, module
  end

  _registry.modules.loaded[handle.path] = module
  _registry.count_loaded = _registry.count_loaded + 1
  return true, module
end

return Loader
