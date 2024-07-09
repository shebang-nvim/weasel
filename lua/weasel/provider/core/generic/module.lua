--[[
    file: generic
    title: generic module
    summary: An API module for generic endpoints
    internal: true
    ---
    WIP
--]]

local weasel = require "weasel.core"
local log, modules, utils = weasel.log, weasel.modules, weasel.utils

local module = modules.create "core.generic"

module.config.public = {
  name = "generic",
  type = "provider",
  services = {

    get = {
      name = "get",
      endpoint = {
        url = "",
        method = "GET",
        headers = {
          ["Content-Type"] = "application/json",
        },
        parameters = {},
        limits = {},
      },
      description = [[
      Generic GET (see docs)
  ]],
    },
  },
}

module.private = {
  -- All the private stuff
}

---@class core.generic
module.public = {

  version = "0.0.9",

  ---comment
  ---@param opts table
  http_get = function(opts) end,
}

module.on_event = function(event) end

module.events.defined = {}

module.events.subscribed = {}

module.setup = function()
  return { success = true }
end
return module
