# weasel - A Lua Web API Client for Neovim

## Quickstart

```lua
local weasel = require("weasel")
local datamuse = weasel.client.datamuse()

-- sync
local words = datamuse.sounds_like("house")

-- async

weasel.run(function()
  local words = datamuse.sounds_like("house")
end)
```

## Providers

- datamuse
- openai (planned)
