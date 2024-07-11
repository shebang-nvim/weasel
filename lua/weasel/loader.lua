local core = require "weasel.core"
local config, log, modules = core.config, core.log, core.modules
local utils = require "weasel.core.utils"

---@class weasel.loader
local loader = {}

---comment
---@param name string
function loader.load_client(name)
  local client = require("weasel.core.client").Client.get(name)

  log.debug("module loaded", module)
  return client
end

loader.accessors = {
  client = loader.load_client,
}
---comment
---@param parent table
---@param k string The wanted key
function loader.handle_api_access(parent, k)
  local endpoint = loader.accessors[k]
  if type(endpoint) == "function" then
    log.debug("returning endpoint", k)
    return endpoint
  end

  return error("unknown API endpoint: " .. tostring(k))
end

return loader
