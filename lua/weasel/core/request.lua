---@class weasel.core.Request
local Request = {}
-- load the http module
local log = require "weasel.core.log"
local curl = require "weasel.lib.curl"
local async = require "async"
local promise = require "promise"

---@class weasel.core.HTTPRequestParams

---comment
---@param params weasel.core.HTTPRequestParams
function Request.get(params)
  return promise:new(function(resolve, reject)
    -- log.debug("Request.get (promise): ", params)
    local data = curl.request {
      request = {
        method = "GET",
        url = params.url,
      },
      headers = {
        ["Content-Type"] = "application/json",
      },
      start = true,
      body = {},
    }
    resolve(require("weasel.core.response").create(data))
  end)
end

return Request
