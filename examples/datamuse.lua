local function project_root()
  local f = debug.getinfo(1, "S").source:sub(2)
  return vim.fn.fnamemodify(f, ":p:h:h")
end

local root = project_root()

vim.opt.runtimepath:append(root)

--- @param data weasel.provider.datamuse.ep.SoundsLikeResponse[]
local function show_words(data)
  for _, value in ipairs(data) do
    print(string.format("word: %s (score: %s, syllables: %s)", value.word, value.score, value.numSyllables))
  end
end

-- load library using defaults
local weasel = require("weasel").setup()

-- get datamuse client
local client = weasel.client "datamuse"

client.methods
  .sounds_like("house")
  :thenCall(function(data)
    show_words(data.body)
  end, function(reason)
    print("client ERROR: ", reason)
  end)
  :finally(function(e)
    print(e and string.format("finally: %s", e) or "")
  end)
