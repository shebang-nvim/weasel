local M = {}
local log = require "weasel.core.log"
local utils = require "weasel.core.utils"
local request = require "weasel.core.request"
local response = require "weasel.core.response"
local async = require "async"
local promise = require "promise"

local Clients = {}

local Service = {}

---@alias weasel.core.service_url string|fun():string
---@alias weasel.core.service_method 'GET'|'POST'
---@alias weasel.core.service_params table<string,string>
---@alias weasel.core.service_limits table

---@class weasel.core.ServiceEndpoint
---@field url weasel.core.service_url
---@field method weasel.core.service_method
---@field params weasel.core.service_params
---@field limits weasel.core.service_limits

---@class weasel.core.Service
---@field name string
---@field description string
---@field endpoint weasel.core.ServiceEndpoint
---@overload fun(...):weasel.core.Service
Service = setmetatable({}, { ---@diagnostic disable-line: cast-local-type
  __call = function(t, ...)
    return Service:new(...)
  end,
})
---comment
---@param spec table
---@return weasel.core.Service
function Service:new(spec)
  local obj = {}

  ---@type weasel.core.Service
  obj = setmetatable(obj, {
    __index = Service,
    -- __call = function(t, fn)
    -- end,
  })

  return obj
end

local Client = {}

---@class weasel.core.Client
---@field name string
---@overload fun(...):weasel.core.Client
Client = setmetatable({}, { ---@diagnostic disable-line: cast-local-type
  __call = function(t, ...)
    return Client:new(...)
  end,
})

-- Client.__index = Client

---comment
---@param module weasel.module.Module
---@return weasel.core.Client
function Client:new(module)
  if module.type ~= "provider" then
    error("invalid module type: " .. tostring(module.type))
  end

  local obj = {
    name = module.name,
  }

  ---@type weasel.core.Client
  obj = setmetatable(obj, {
    __index = Client,
    -- __call = function(t, fn)
    -- end,
  })

  return obj
end

local function make_service_requestor(opts)
  return setmetatable(opts, {
    __call = function(t, ...)
      local args = ...
      if type(args) ~= "table" then
        args = { args }
      end
      return async(function()
        local method = t.endpoint.method:lower()
        local url_params = utils.url_params(utils.tbl_keys(t.endpoint.parameters), args)
        if not utils.endswith(t.endpoint.url, "/") then
          t.endpoint.url = t.endpoint.url .. "/"
        end
        local data = await(request[method] {
          url = t.endpoint.url .. table.concat(url_params, ""),
        })
        return data
        -- log.debug("Client make_service_requestor", t)
      end)
    end,
  })
end

Client.methods = {}

---comment
---@param module weasel.module.Module
---@return weasel.core.Client
function Client.from_module(module)
  if type(module.setup) == "function" then
    Client.setup = module.setup
  end

  if type(module.post_load) == "function" then
    Client.post_load = module.post_load
  end

  for key, value in pairs(module.spec.services) do
    Client.methods[key] = make_service_requestor(value)
  end

  local cli = Client:new(module)

  return cli
end

---comment
---@param name string
---@return boolean
function Client.is_loaded(name)
  return Clients[name] ~= nil
end

---comment
---@param name string
--- @param vendor_tag? string
---@return weasel.core.Client
function Client.get(name, vendor_tag)
  if Client.is_loaded(name) then
    return Clients[name]
  end

  ---@type boolean
  local ok

  ---@type weasel.module.handle|string
  local handle

  ---@type weasel.module.Module
  local module

  local Module = require "weasel.core.module.module"
  local Resolver = require "weasel.core.module.resolver"

  ok, handle = Resolver.resolve_name("provider." .. name, vendor_tag)

  if not ok then
    log.error("error resolving client: " .. tostring(name))
    error(handle)
  end

  ---@cast handle -string

  ok, module = Module.load(handle)

  if not ok then
    log.error("error loading client: " .. tostring(name))
    error(module)
  end

  local client = Client.from_module(module)
  Clients[name] = client

  return client
end

M.Client = Client

return M
