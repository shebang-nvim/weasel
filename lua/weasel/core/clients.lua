--- @alias weasel.client.configuration.public.services { [string]: weasel.service }

--- @class weasel.client.configuration.public
--- @field services weasel.client.configuration.public.services

--- Defines both a public and private configuration for a weasle client.
--- Public configurations may be tweaked by the user from the `weasle.setup()` function,
--- whereas private configurations are for internal use only.
--- @class (exact) weasel.client.configuration
--- @field custom? table         Internal table that tracks the differences (changes) between the default `public` table and the new (altered) `public` table. It contains only the tables that the user has altered in their own configuration.
--- @field public private? table Internal configuration variables that may be tweaked by the developer.
--- @field public public? weasel.client.configuration.public  Configuration variables that may be tweaked by the user.

--- @alias weasel.client.public { version: string, [any]: any }
---
--- @class (exact) weasle.client.events
--- @field defined? { [string]: weasel.event }              Lists all events defined by this module.
--- @field subscribed? { [string]: { [string]: boolean } } Lists the events that the module is subscribed to.

--- @alias weasel.client.setup { success: boolean, requires?: string[], replaces?: string, replace_merge?: boolean, wants?: string[] }

--- Defines a client.
--- @class (exact) weasel.client
--- @field config? weasel.client.configuration The configuration for the client class.
--- @field events? weasle.client.events Describes all information related to events for this client.
--- @field name string The name of the client.
--- @field service string The service this client uses.
--- @field path string The full path to the client (a more verbose version of `name`).
--- @field setup? fun(): weasel.client.setup Setup function to configure the client.
--- @field public private? table A convenience table to place all of your private variables that you don't want to expose.
--- @field public public? weasel.client.public Public interface of the client.

--- @class (exact) weasel.event
--- @field type string The type of the event. Exists in the format of `category.name`.

--- @class (exact) weasel.auth

--- @class (exact) weasel.auth.bearer_token:weasel.auth
--- @field token fun():string

--- @class (exact) weasel.endpoint
--- @field method 'GET'|'POST'
--- @field headers? {[string]: string}
--- @field authentication? weasel.auth
--- @field url string
--- @field limits table
--- @field parameters table

--- @class (exact) weasel.service
--- @field name string
--- @field description string
--- @field endpoint weasel.endpoint

local clients = {}

--- Returns a new weasel client, exposing all the necessary function and variables.
--- @param name string The name of the new client.
--- @return weasel.client
function clients.create(name)
  ---create a new client
  ---@type weasel.client
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
