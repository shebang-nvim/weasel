local spec = require "weasel.core.module.spec"

--- Creates a specification for the ChatGPT provider module
-- @return table: The specification for the ChatGPT module
return spec.create("provider", {

  name = "openai",

  --- Setup function for the ChatGPT module
  -- @return table: A table indicating successful setup
  setup = function()
    return { success = true }
  end,

  post_load = function() end,

  config = {
    --- Function which fetches a bearer token from a secret store
    --- @param kind string
    api_key = function(kind)
      return spec.bearer_token(kind)
    end,
    base_url = "https://api.openai.com/v1",
    services = {
      chat = {},
      generate_text = {},
    },
  },

  spec = {
    services = {
      chat = {
        name = "chat",

        endpoint = {
          url = "https://api.openai.com/v1/chat/completions",
          method = "POST",

          parameters = {
            model = "gpt-3.5-turbo",
            max_tokens = 150,
            temperature = 0.7,
            prompt = "",
          },

          headers = {
            ["Authorization"] = "Bearer YOUR_API_KEY",
            ["Content-Type"] = "application/json",
          },

          defaults = {},

          limits = {},
        },

        description = [[
                Chat with OpenAI's GPT model. Provide a conversation history and receive a response.
                ]],
      },
      generate_text = {
        name = "generate_text",

        endpoint = {
          url = "https://api.openai.com/v1/completions",
          method = "POST",

          parameters = {
            prompt = "string",
            model = "text-davinci-003",
            max_tokens = 100,
            temperature = 0.7,
          },

          headers = {
            ["Authorization"] = "Bearer YOUR_API_KEY",
            ["Content-Type"] = "application/json",
          },

          defaults = {},

          limits = {},
        },

        description = [[
                Generate text using OpenAI's GPT model. Provide a prompt and receive a completion.
                ]],
      },
    },
  },
})
