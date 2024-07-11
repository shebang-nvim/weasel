local function project_root()
  local f = debug.getinfo(1, "S").source:sub(2)
  return vim.fn.fnamemodify(f, ":p:h:h")
end

local root = project_root()

vim.opt.runtimepath:append(root)

-- load library using defaults
local weasel = require("weasel").setup()

-- get openai client
local client = weasel.client "openai"

-- Define the prompt (user input)
local prompt = "What are the benefits of using artificial intelligence in healthcare?"

local parameters = {
  prompt = prompt,
  model = "text-davinci-003",
  max_tokens = 150,
  temperature = 0.7,
}

client.methods
  .generate_text(parameters)
  :thenCall(function(data)
    print("Generated text: ", data.choices[1].text)
  end, function(reason)
    print("client ERROR: ", reason)
  end)
  :finally(function(e)
    print(e and string.format("finally: %s", e) or "Completion finished")
  end)
