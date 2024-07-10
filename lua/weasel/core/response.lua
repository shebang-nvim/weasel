---@class weasel.core.Response
local Response = {}
-- load the http module
-- local cjson = require "cjson"
local async = require "async"
local promise = require "promise"
local utils = require "weasel.core.utils"

---@class weasel.core.HTTPResponseData
---@field code integer
---@field headers string
---@field method string
---@field statistics table
---@field url string
---@field body table

---comment
---@param data weasel.core.HTTPResponseData
function Response.create(data)
  return promise:new(function(resolve, reject)
    local obj = {}

    -- obj.body = cjson.decode(data.body)
    obj.body = utils.json.decode(data.body)
    obj.url = data.url
    obj.code = data.code
    obj.method = data.method
    resolve(obj)
  end)
end

return Response
