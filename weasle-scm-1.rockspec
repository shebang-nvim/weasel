local MODREV, SPECREV = "scm", "-1"
rockspec_format = "3.0"
package = "weasle"
version = MODREV .. SPECREV

source = {
  url = "http://github.com/shborg/neorg/archive/v" .. MODREV .. ".zip",
}
description = {
  summary = "An API client supporting pluggable API connectors.",
  detailed = [[
      Weasle is a Lua libary for talking to web services using pluggable connectors.
      It supports async opperations, JSON and various common service endpoints.
   ]],
  homepage = "https://github.com/shborg/weasle",
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
      "WEASLE_DEBUG",
    },
    macosx = {
      "WEASLE_DEBUG",
    },
  }
end
build = {
  type = "builtin",
  modules = {

    ["weasle"] = "lua/weasle/init.lua",
    ["weasle.client"] = "lua/weasle/client.lua",
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
