describe("weasel.modules.core.datamuse #unit", function()
  it("does not fail", function()
    local module = require "weasel.modules.core.datamuse.module"
    vim.print(module)
    assert(1)
  end)
end)
