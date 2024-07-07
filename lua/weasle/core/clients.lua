--- Defines a client.
--- @class (exact) weasle.client
--- @field config? table
--- @field events? table
--- @field name string The name of the client.
--- @field service string The service this client uses.
--- @field path string The full path to the client (a more verbose version of `name`).
--- @field setup? fun(): table Setup function to configure the client.

local clients = {}

--- Returns a new weasle client, exposing all the necessary function and variables.
--- @param name string The name of the new client.
--- @return weasle.client
function clients.create(name)
  ---create a new client
  ---@type weasle.client
  local new_client = {
    service = "",
    name = "",
    path = "",
    setup = function()
      return { success = true }
    end,

    config = {
      public = {},
    },
    events = {
      subscribed = { -- The events that the client is subscribed to
        --[[
                --]]
      },
      defined = { -- The events that the client itself has defined
        --[[
                --]]
      },
    },
  }
  new_client.name = name
  new_client.path = "clients." .. name
  return new_client
end

return clients
