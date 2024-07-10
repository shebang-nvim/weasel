local assert = assert
---@cast assert -function,+weasel.luassert

local helper = require "spec.helper"

describe("weasel.core.module.resolver #unit", function()
  local resolver = require "weasel.core.module.resolver"
  describe("with valid args", function()
    it("returns a module handle", function()
      local ok, handle = resolver.resolve_name "provider.datamuse"
      assert.True(ok)
      assert.Boolean(ok)
      assert.same({
        name = "datamuse",
        path = "weasel.modules.builtin.provider.datamuse.module",
        short_name = "provider.builtin.datamuse",
        type = "provider",
        vendor_tag = "builtin",
      }, handle)
    end)
  end)
  describe("with invalid args", function()
    it("returns false and and error string if arg is missing", function()
      local ok, handle = resolver.resolve_name() ---@diagnostic disable-line: missing-parameter
      assert.Boolean(ok)
      assert.False(ok)
      assert.equal("name must be a non empty string", handle)
    end)
    it("returns false and and error string if the form is wrong", function()
      local ok, handle = resolver.resolve_name "provider"
      assert.Boolean(ok)
      assert.False(ok)
      assert.equal("name must have the form <type>.<name>", handle)
    end)
  end)
end)
