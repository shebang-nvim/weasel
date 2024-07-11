local assert = assert
---@cast assert -function,+weasel.luassert

local promise = require "promise"

describe("weasel.client #integration", function()
  describe("weasel.client('datamuse')", function()
    -- load library using defaults
    local weasel = require("weasel").setup()

    it("returns the datamuse client", function()
      -- get datamuse client
      local client = weasel.client "datamuse"
      assert(client)
    end)

    describe("weasel.client('datamuse').methods", function()
      it("exports the datamuse API methods", function()
        -- get datamuse client
        local methods = weasel.client("datamuse").methods
        local utils = require "weasel.core.utils"

        local expected_methods = {
          "sounds_like",
        }
        for _, method_name in ipairs(expected_methods) do
          assert(methods[method_name])
          assert.True(utils.is_callable(methods[method_name]))
        end
      end)
    end)
    local clock = os.clock
    local function sleep(n) -- seconds
      local t0 = clock()
      while clock() - t0 <= n do
      end
    end
    describe("weasel.client('datamuse').methods.sounds_like", function()
      it("returns words", function()
        -- get datamuse client
        local sounds_like = weasel.client("datamuse").methods.sounds_like
        sounds_like("house")
          :thenCall(function(data)
            print "thenCall> fulfilled>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
            -- vim.print(data)
          end, function(reason)
            print "thenCall> error>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
            print("client ERROR: ", reason)
          end)
          :finally(function(e)
            print(e and string.format("finally: %s", e) or "")
          end)
        sleep(2)
      end)
    end)
  end)

  describe("Client.methods.sounds_like", function()
    local Client = require("weasel.core.client").Client
    it("returns a response", function()
      local client = Client.get "datamuse"

      -- local repsonse = client.methods.async_test "house"
    end)
  end)
end)
