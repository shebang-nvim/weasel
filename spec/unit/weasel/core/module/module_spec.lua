local assert = assert
---@cast assert -function,+weasel.luassert

local helper = require "spec.helper"

describe("weasel.core.module.module #unit", function()
  ---@type weasel.module.handle
  local handle = {

    name = "testmod",
    path = "spec.fixtures.modules.builtin.provider.testmod.module",
    short_name = "builtin.provider.testmod",
    type = "provider",
    vendor_tag = "builtin",
  }

  describe("with valid args", function()
    local Module = require "weasel.core.module.module"
    it("returns a module", function()
      local ok, module = Module.load(handle)
      assert.True(ok)
      assert.Table(module)
    end)

    it("increase Module.count_loaded", function()
      Module.load(handle)
      assert.equal(1, Module.count_loaded)
    end)

    it("Module.is_loaded returns true", function()
      Module.load(handle)
      assert.True(Module.is_loaded(handle))
    end)

    -- it("Module.get returns the loaded module", function()
    --   local ok, module = Module.load(handle)
    --   assert.same(module, Module.get(handle))
    -- end)
  end)
end)
