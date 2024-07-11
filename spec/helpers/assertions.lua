local say = require "say"
local assert = require "luassert"

local function is_callable(state, arguments)
  if type(arguments) == "function" then
    return true
  end
  local m = getmetatable(arguments)
  if m == nil then
    return false
  end
  return type(m.__call) == "function"
end

local function has_property(state, arguments)
  local has_key = false

  if not type(arguments[1]) == "table" or #arguments ~= 2 then
    return false
  end

  for key, value in pairs(arguments[1]) do
    if key == arguments[2] then
      has_key = true
    end
  end

  return has_key
end
say:set("assertion.is_callable.positive", "Expected %s \nto have property: %s")
say:set("assertion.is_callable.negative", "Expected %s \nto not have property: %s")
assert:register(
  "assertion",
  "is_callable",
  is_callable,
  "assertion.is_callable.positive",
  "assertion.is_callable.negative"
)
say:set("assertion.has_property.positive", "Expected %s \nto have property: %s")
say:set("assertion.has_property.negative", "Expected %s \nto not have property: %s")
assert:register(
  "assertion",
  "has_property",
  has_property,
  "assertion.has_property.positive",
  "assertion.has_property.negative"
)
