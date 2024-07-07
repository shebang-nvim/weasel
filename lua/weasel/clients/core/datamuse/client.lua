--[[
    file: datamuse
    title: datamuse client
    summary: An API client for datamuse endpoints
    internal: true
    ---
    WIP
--]]

local weasel = require "weasel.core"
local log, clients, utils = weasel.log, weasel.clients, weasel.utils

local client = clients.create "core.datamuse"

client.config.public = {
  endpoints = {
    ["sounds-like"] = {
      name = "sounds-like",
      url = "https://api.datamuse.com/words?sl=",
      description = [[
    Sounds like constraint: require that the results are pronounced similarly to this string of characters. 
    (If the string of characters doesn't have a known pronunciation, the system will make its best guess 
    using a text-to-phonemes algorithm.)
  ]],
    },
  },
}

client.private = {
  -- All the private stuff
}

---@class core.datamuse
client.public = {

  version = "0.0.9",
}

client.on_event = function(event) end

client.events.defined = {}

client.events.subscribed = {}

return client
