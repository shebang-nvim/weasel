local assert = assert
---@cast assert -function,+weasel.luassert

local promise = require "promise"
-- local fixtures = require "spec.promise_async.fixtures"
-- local helpers = require "spec.promise_async.helpers.init"
-- local basics = require "spec.promise_async.helpers.basics"
-- local reasons = require "spec.promise_async.helpers.reasons"
-- local setTimeout = helpers.setTimeout
-- local dummy = { dummy = "dummy" }
-- local sentinel = { sentinel = "sentinel" }
-- local sentinel2 = { sentinel = "sentinel2" }
-- local sentinel3 = { sentinel = "sentinel3" }
-- local other = { other = "other" }

describe("client.datamuse #integration", function()
  -- describe("promise test", function()
  --   local p = promise.resolve(1)
  --   -- assert.truthy(tostring(p):match "<fulfilled>")
  --   p:thenCall(function(value)
  --     assert.equal(1, value)
  --     done()
  --   end)
  --   assert.True(wait())
  -- end)
  describe("Client.get", function()
    local Client = require("weasel.core.client").Client
    it("returns a client", function()
      local client = Client.get "datamuse"
      assert(client)
    end)
  end)
  describe("Client.methods.sounds_like", function()
    local Client = require("weasel.core.client").Client
    it("returns a response", function()
      local client = Client.get "datamuse"

      -- async()
      -- local repsonse = client.methods.sounds_like "house"
      -- vim.wait(2000)
      -- vim.print(">>>>>> sounds_like returns", response)
      local repsonse = client.methods.async_test "house"

      vim.wait(1000, function()
        return resolve and response.thenCall
      end, 500)
      -- response:thenCall(function(data)
      --   -- done()
      -- end)
      -- local async = require "async"
      -- local promise = require "promise"
      -- vim.print(">>>>>>>>>>>>>>>>>>", client.methods)
    end)
  end)
end)
