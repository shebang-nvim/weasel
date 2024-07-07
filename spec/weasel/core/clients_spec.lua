describe("weasel.core.clients", function()
  it("does not fail", function()
    local client = require "weasel.core.clients"
    vim.print(client)
    assert(1)
  end)
end)
