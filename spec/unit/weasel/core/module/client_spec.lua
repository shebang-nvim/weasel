local assert = assert
---@cast assert -function,+weasel.luassert

-- local helper = require "spec.helper"
describe("weasel.core.module.client #unit", function()
  ---@type weasel.module.handle
  local handle = {

    name = "testmod",
    path = "spec.fixtures.modules.builtin.provider.testmod.module",
    short_name = "builtin.provider.testmod",
    type = "provider",
    vendor_tag = "builtin",
  }

  describe("from_module", function()
    local Module = require "weasel.core.module.module"
    local Client = require("weasel.core.client").Client
    it("returns a client", function()
      local client = Client.from_module(Module.get(handle))
      vim.print(">>>>>>>>>>>>>>>>>>", client)
    end)
  end)
end)
