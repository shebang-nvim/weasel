local assert = assert
---@cast assert -function,+weasel.luassert

local helper = require "spec.helper"

describe("weasel.core.module.loader #unit", function()
  local loader = require "weasel.core.module.loader"
  describe("with valid args", function()
    ---@type weasel.module.handle
    local handle = {

      name = "testmod",
      path = "spec.fixtures.modules.builtin.provider.testmod.module",
      short_name = "builtin.provider.testmod",
      type = "provider",
      vendor_tag = "builtin",
    }
    it("returns a module handle", function()
      local ok, module = loader.load_module(handle)
      assert(module.validate())
      -- assert.True(ok)
      -- assert.Table(module)
      -- assert.equal("testmod", module.spec.name)
      -- assert.Function(module.spec.setup)
      -- assert.equal("provider", module.spec.type)
    end)
  end)
end)
