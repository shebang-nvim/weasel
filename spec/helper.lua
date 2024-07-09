local M = {}

function M.unload_weasel()
  local mods = {
    "weasel",
    "weasel.core",
    "weasel.core.init",
    "weasel.core.config",
    "weasel.core.modules",
    "weasel.core.utils",
    "weasel.core.log",
  }

  for _, mod_name in ipairs(mods) do
    package.loaded[mod_name] = nil
  end
end

return M
