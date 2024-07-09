describe("weasel.core.modules #unit", function()
  it("does not fail", function()
    local module = require "weasel.core.modules"
    vim.print(module)
    assert(1)
  end)
end)
