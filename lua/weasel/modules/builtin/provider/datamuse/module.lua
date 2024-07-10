local spec = require "weasel.core.module.spec"
return spec.create("provider", {

  name = "datamuse",
  setup = function()
    return { success = true }
  end,
  post_load = function() end,
  config = {},
  spec = {
    services = {

      sounds_like = {
        name = "sounds_like",
        endpoint = {
          url = "https://api.datamuse.com/words",
          method = "GET",
          -- headers = {
          --   ["Content-Type"] = "application/json",
          -- },
          parameters = {
            sl = "string",
          },
          limits = {},
        },
        description = [[
    Sounds like constraint: require that the results are pronounced similarly to this string of characters. 
    (If the string of characters doesn't have a known pronunciation, the system will make its best guess 
    using a text-to-phonemes algorithm.)
  ]],
      },
    },
  },
})
