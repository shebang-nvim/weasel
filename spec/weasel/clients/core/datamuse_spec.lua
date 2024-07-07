describe("weasel.clients.core.datamuse", function()
  it("does not fail", function()
    local client = require "weasel.clients.core.datamuse.client"
    vim.print(client)
    assert(1)
  end)
end)
