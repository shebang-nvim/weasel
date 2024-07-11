---@class weasel.core.module.resolver
local Resolver = {}

local utils = require "weasel.core.utils"

Resolver.vendor_tags = {
  "builtin",
  "ext",
}
Resolver.module_types = {
  "provider",
  "auth",
}

--- @alias weasel.module.resolver_retval weasel.module.handle|string

--- resolve a module name to a Lua path
--- 1. "provider.datamuse" -> "weasel.modules.provider.core.datamuse"
--- @param name string
--- @param vendor_tag? string
--- @return boolean,weasel.module.resolver_retval
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
