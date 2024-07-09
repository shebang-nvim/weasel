local M = {}

local Client = {}

---@class weasel.core.Client
---@field name string
---@overload fun(...):weasel.core.Client
Client = setmetatable({}, { ---@diagnostic disable-line: cast-local-type
  __call = function(t, ...)
    return Client:new(...)
  end,
})
---comment
---@param spec table
---@return weasel.core.Client
function Client:new(spec)
  local obj = {}

  ---@type weasel.core.Client
  obj = setmetatable(obj, {
    __index = Client,
    -- __call = function(t, fn)
    -- end,
  })

  return obj
end

---comment
---@param module weasel.module
---@return weasel.core.Client
function Client.from_module(module)
  local cli = Client:new(module)

  return cli
end

M.Client = Client

return M
