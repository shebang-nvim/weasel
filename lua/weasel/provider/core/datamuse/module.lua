--[[
    file: datamuse
    title: datamuse module
    summary: An API module for datamuse endpoints
    internal: true
    ---
    WIP
--]]

local weasel = require "weasel.core"
local log, modules, utils = weasel.log, weasel.modules, weasel.utils

local module = modules.create "core.datamuse"

module.config.public = {
  name = "datamuse",
  type = "provider",
  services = {

    sounds_like = {
      name = "sounds_like",
      endpoint = {
        url = "https://api.datamuse.com/words",
        method = "GET",
        headers = {
          ["Content-Type"] = "application/json",
        },
        parameters = {
          sl = "YOUR_SEARCH_TERM_HERE",
        },
        limits = {},
      },
      description = [[
    Sounds like constraint: require that the results are pronounced similarly to this string of characters. 
    (If the string of characters doesn't have a known pronunciation, the system will make its best guess 
    using a text-to-phonemes algorithm.)
  ]],
    },
  },
}

module.private = {
  -- All the private stuff
}

---@class core.datamuse
module.public = {

  version = "0.0.9",
  name = "datamuse",
  type = "provider",
  services = {

    sounds_like = {
      name = "sounds_like",
      endpoint = {
        url = "https://api.datamuse.com/words",
        method = "GET",
        headers = {
          ["Content-Type"] = "application/json",
        },
        parameters = {
          sl = "YOUR_SEARCH_TERM_HERE",
        },
        limits = {},
      },
      description = [[
    Sounds like constraint: require that the results are pronounced similarly to this string of characters. 
    (If the string of characters doesn't have a known pronunciation, the system will make its best guess 
    using a text-to-phonemes algorithm.)
  ]],
    },
  },
}

module.on_event = function(event) end

module.events.defined = {}

module.events.subscribed = {}

module.setup = function()
  return { success = true }
end
return module
