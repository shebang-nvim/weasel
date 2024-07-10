---@class weasel.core.module.Module
local Module = {}

local log = require "weasel.core.log"

local Registry = {
  modules = {
    loaded = {},
  },
}

---@class weasel.core.module.Module
---@field name string
---@field setup fun(config:table)
---@field post_load fun()
---@field type string
---@field spec table
---@overload fun(...):weasel.core.module.Module
Module = setmetatable({}, { ---@diagnostic disable-line: cast-local-type
  __call = function(t, ...)
    return Module:new(...)
  end,
})
Module.count_loaded = 0
-- Module.__index = Module

---@class weasel.core.module.Spec
local module_spec = {
  name = "",
  setup = function() end,
  post_load = function() end,
  config = {},
  spec = {},
}

---comment
---@param raw_module table
---@return weasel.core.module.Module
function Module:new(raw_module)
  local obj = {
    name = raw_module.spec.name,
    setup = raw_module.spec.setup,
    post_load = raw_module.spec.post_load,
    config = raw_module.spec.config,
    type = raw_module.spec.type,
    spec = raw_module.spec.spec,
  }

  ---@type weasel.core.module.Module
  obj = setmetatable(obj, {
    __index = Module,
  })

  return obj
end

---comment
--- @param handle weasel.module.handle
--- @return boolean
function Module.is_loaded(handle)
  return Registry.modules.loaded[handle.path] ~= nil
end

---comment
--- @param handle weasel.module.handle
--- @return boolean, weasel.core.module.Module
function Module.load(handle)
  if Module.is_loaded(handle) then
    return true, Module.get(handle)
  end

  local ok, mod = require("weasel.core.module.loader").load_module(handle)
  if not ok then
    return false, mod
  end

  mod:validate()
  local obj = Module:new(mod)

  Registry.modules.loaded[handle.path] = obj

  Module.count_loaded = Module.count_loaded + 1
  return true, obj
end

--- Returns a module from the cache or loads the module if not
--- loaded. Raises an error of loading fails.
--- @param handle weasel.module.handle
--- @return weasel.core.module.Module
function Module.get(handle)
  if Module.is_loaded(handle) then
    return Registry.modules.loaded[handle.path]
  end

  local ok, mod = Module.load(handle)
  if not ok then
    log.error(mod)
    error(mod)
  end

  -- log.debug("successfully loaded module", mod)
  return mod
end

return Module
