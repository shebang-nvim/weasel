local assert = assert
---@cast assert -function,+weasel.luassert

describe("weasel #integration", function()
  describe("require 'weasel'", function()
    it("exports setup function", function()
      local weasel = require "weasel"
      assert(weasel)
      assert.Function(weasel.setup)
    end)

    it("exports initialized=false", function()
      local weasel = require "weasel"
      assert(weasel)
      assert.False(weasel.initialized)
    end)
  end)

  describe("setup", function()
    it("sets initialized=true", function()
      local weasel = require "weasel"
      local api = weasel.setup()
      assert(api)
      assert.True(api.initialized)
    end)

    it("exports weasel.config", function()
      local weasel = require "weasel"
      local api = weasel.setup()
      local expect = {
        user_config = {
          lazy_loading = false,
          load = {
            auth = {},
            provider = {},
          },
        },
        version = "0.1.0",
      }
      assert.same(expect, api.config)
    end)

    it("exports weasel.os_info", function()
      local weasel = require "weasel"
      local api = weasel.setup()
      assert.String(api.os_info)
    end)

    it("exports weasel.path_sep", function()
      local weasel = require "weasel"
      local api = weasel.setup()
      assert.String(api.path_sep)
    end)
  end)
end)
