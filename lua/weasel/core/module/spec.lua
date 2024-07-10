local M = {}

local types = require("tableshape").types

local loaded = false
M.module_types = {}

M.schema = {}
M.schema.composables = {}

M.schema.composables.module_types = types.one_of { types.literal "provider", types.literal "auth" }
M.schema.composables.url = types.one_of { types.string, types.func }

M.schema.module = types.shape {
  type = M.schema.composables.module_types,
  name = types.string,
  enabled = types.boolean:is_optional(),
  post_load = types.func:is_optional(),
  setup = types.func:is_optional(),
  spec = types.table,
  config = types.table,
}

M.schema.modules = {}

M.schema.modules.provider = types.shape {
  -- type = types.one_of { types.literal "provider", types.literal "auth" },
  -- name = types.string,
  -- enabled = types.boolean:is_optional(),
  -- post_load = types.func:is_optional(),
  -- setup = types.func:is_optional(),
  services = types.map_of(
    types.string,
    types.shape {

      description = types.string,
      name = types.string,
      endpoint = types.shape {

        url = M.schema.composables.url,
        method = types.one_of { types.literal "GET", types.literal "POST" },
        limits = types.shape({}):is_optional(),
        parameters = types.map_of(types.string, types.any),
      },
    }
  ),
}

---comment
---@param type string
---@param data table
M.create = function(type, data)
  if not M.schema.modules[type] then
    error("no such shape for type " .. tostring(type))
  end

  data.type = type

  local obj = {
    spec = data,
    shape = M.schema.modules[type],
    validate = function()
      assert(M.schema.module(data))
      assert(M.schema.modules[type](data.spec))
      return true
    end,
  }

  return obj
end

if not loaded then
  for key, _ in pairs(M.schema.modules) do
    M.module_types[#M.module_types + 1] = key
    M.schema.composables.module_types[#M.schema.composables.module_types + 1] = types.literal(key)
  end

  loaded = true
end

return M