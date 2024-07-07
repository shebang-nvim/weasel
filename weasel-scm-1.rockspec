local MODREV, SPECREV = "scm", "-1"
rockspec_format = "3.0"
package = "weasel"
version = MODREV .. SPECREV

source = {
  url = "https://github.com/shebang-nvim/weasel/archive/v" .. MODREV .. ".zip",
}
description = {
  summary = "An API client supporting pluggable API connectors.",
  detailed = [[
      weasel is a Lua libary for talking to web services using pluggable connectors.
      It supports async opperations, JSON and various common service endpoints.
   ]],
  homepage = "http://github.com/shebang-nvim/weasel",
  license = "MIT",
}
dependencies = {
  "lua >= 5.1",
  "lua-openai",
  "lpeg",
  "lua-cjson",
  "tableshape",
  "luasocket",
  "luasec",
}
test_dependencies = {
  "busted",
}
test = {
  type = "busted",
}

local function make_plat(plat)
  local defines = {
    unix = {
      "weasel_DEBUG",
    },
    macosx = {
      "weasel_DEBUG",
    },
  }
end
build = {
  type = "builtin",
  modules = {

    ["weasel"] = "lua/weasel/init.lua",
    ["weasel.client"] = "lua/weasel/client.lua",
  },
  platforms = {
    unix = make_plat "unix",
    macosx = make_plat "macosx",
  },
  copy_directories = {
    "docs",
    "samples",
    "test",
  },
}
