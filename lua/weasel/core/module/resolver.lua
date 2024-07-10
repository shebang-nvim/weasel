---@class weasel.core.module.Loader
local Resolver = {}

local utils = require "weasel.core.utils"

--- @enum wease.core.module.VendorTags
Resolver.vendor_tags = {
  "builtin",
  "ext",
}
--- @enum wease.core.module.Types
Resolver.module_types = {
  "provider",
  "auth",
}

--- resolve a module name to a Lua path
--- 1. "provider.datamuse" -> "weasel.modules.provider.core.datamuse"
--- @param name string
--- @param vendor_tag? string
--- @return boolean,weasel.module.handle|string
function Resolver.resolve_name(name, vendor_tag)
  vendor_tag = vendor_tag or "builtin"

  if type(name) ~= "string" or name == "" then
    return false, "name must be a non empty string"
  end

  if not name:match "%." then
    return false, "name must have the form <type>.<name>"
  end

  local module_prefix = "weasel.modules."

  local fields = utils.split_string(name)

  if #fields ~= 2 then
    return false, "name must have the form <type>.<name>"
  end

  return true,
    {
      type = fields[1],
      name = fields[2],
      short_name = fields[1] .. "." .. vendor_tag .. "." .. fields[2],
      path = module_prefix .. vendor_tag .. "." .. fields[1] .. "." .. fields[2] .. ".module",
      vendor_tag = vendor_tag,
    }
end

return Resolver
