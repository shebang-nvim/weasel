describe("weasle.core.clients", function()
  it("does not fail", function()
    local client = require "weasle.core.clients"
    vim.print(client)
    assert(1)
  end)
end)
