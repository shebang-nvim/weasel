local configuration = require "weasel.core.config"
local log = require "weasel.core.log"

local utils = {}
local version = vim.version() -- TODO: Move to a more local scope

-- NOTE: vim.loop has been renamed to vim.uv in Neovim >= 0.10 and will be removed later
local uv = vim.uv or vim.loop

--- Checks whether Neovim is running at least at a specific version.
--- @param major integer The major release of Neovim.
--- @param minor integer The minor release of Neovim.
--- @param patch integer The patch number (in case you need it).
--- @return boolean # Whether Neovim is running at the same or a higher version than the one given.
function utils.is_minimum_version(major, minor, patch)
  if major ~= version.major then
    return major < version.major
  end
  if minor ~= version.minor then
    return minor < version.minor
  end
  if patch ~= version.patch then
    return patch < version.patch
  end
  return true
end

---comment
---@param s string
---@param del? string
function utils.split_string(s, del)
  local sep, fields = del or "%.", {}
  local pattern = string.format("([^%s]+)", sep)
  _ = s:gsub(pattern, function(c)
    fields[#fields + 1] = c
  end)
  return fields
end

--- Parses a version string like "0.4.2" and provides back a table like { major = <number>, minor = <number>, patch = <number> }
--- @param version_string string The input string.
--- @return table? # The parsed version string, or `nil` if a failure occurred during parsing.
function utils.parse_version_string(version_string)
  if not version_string then
    return
  end

  -- Define variables that split the version up into 3 slices
  local split_version, versions, ret =
    vim.split(version_string, ".", { plain = true }), { "major", "minor", "patch" }, { major = 0, minor = 0, patch = 0 }

  -- If the sliced version string has more than 3 elements error out
  if #split_version > 3 then
    log.warn(
      "Attempt to parse version:",
      version_string,
      "failed - too many version numbers provided. Version should follow this layout: <major>.<minor>.<patch>"
    )
    return
  end

  -- Loop through all the versions and check whether they are valid numbers. If they are, add them to the return table
  for i, ver in ipairs(versions) do
    if split_version[i] then
      local num = tonumber(split_version[i])

      if not num then
        log.warn "Invalid version provided, string cannot be converted to integral type."
        return
      end

      ret[ver] = num
    end
  end

  return ret
end

--- Custom weasel notifications. Wrapper around `vim.notify`.
--- @param msg string Message to send.
--- @param log_level integer? Log level in `vim.log.levels`.
function utils.notify(msg, log_level)
  vim.notify(msg, log_level, { title = "weasel" })
end

---Encodes a string into its escaped hexadecimal representation
---taken from Lua Socket and added underscore to ignore
---@param str string Binary string to be encoded
---@return string
function utils.escape(str)
  local encoded = string.gsub(str, "([^A-Za-z0-9_])", function(c)
    return string.format("%%%02x", string.byte(c))
  end)

  return encoded
end

---Check if a file exists in the given `path`
---@param path string file path
---@return boolean
function utils.file_exists(path)
  ---@diagnostic disable-next-line undefined-field
  local fd = uv.fs_open(path, "r", 438)
  if fd then
    ---@diagnostic disable-next-line undefined-field
    uv.fs_close(fd)
    return true
  end

  return false
end

---Read a file if it exists
---@param path string file path
---@return string
function utils.read_file(path)
  ---@type string|nil
  local content
  if utils.file_exists(path) then
    ---@diagnostic disable-next-line undefined-field
    local file = uv.fs_open(path, "r", 438)
    ---@diagnostic disable-next-line undefined-field
    local stat = uv.fs_fstat(file)
    ---@diagnostic disable-next-line undefined-field
    content = uv.fs_read(file, stat.size, 0)
    ---@diagnostic disable-next-line undefined-field
    uv.fs_close(file)
  else
    ---@diagnostic disable-next-line need-check-nil
    log.error("Failed to read file '" .. path .. "'")
    return ""
  end

  ---@cast content string
  return content
end

---comment
---@param keys table
---@param values table
---@return table
function utils.url_params(keys, values)
  assert(type(keys) == "table", "keys must be a table")
  assert(type(values) == "table", "values must be a table")
  assert(#keys == #values, "keys and values must be of the same size")

  local fields = {}

  local del = "?"
  del = del .. string.rep("&", #keys - 1)

  for index, value in ipairs(keys) do
    fields[#fields + 1] = del:sub(index, 1) .. value .. "=" .. values[index]
  end

  return fields
end

--- Tests if `s` ends with `suffix`.
---
---@param s string String
---@param suffix string Suffix to match
---@return boolean `true` if `suffix` is a suffix of `s`
function utils.endswith(s, suffix)
  utils.validate("s", s, "string")
  utils.validate("suffix", suffix, "string")
  return #suffix == 0 or s:sub(-#suffix) == suffix
end

do
  --- @alias weasel.core.utils.Type
  --- | 't' | 'table'
  --- | 's' | 'string'
  --- | 'n' | 'number'
  --- | 'f' | 'function'
  --- | 'c' | 'callable'
  --- | 'nil'
  --- | 'thread'
  --- | 'userdata

  local type_names = {
    ["table"] = "table",
    t = "table",
    ["string"] = "string",
    s = "string",
    ["number"] = "number",
    n = "number",
    ["boolean"] = "boolean",
    b = "boolean",
    ["function"] = "function",
    f = "function",
    ["callable"] = "callable",
    c = "callable",
    ["nil"] = "nil",
    ["thread"] = "thread",
    ["userdata"] = "userdata",
  }

  --- @nodoc
  --- @class weasel.core.utils.Spec [any, string|string[], boolean]
  --- @field [1] any Argument value
  --- @field [2] string|string[]|fun(v:any):boolean, string? Type name, or callable
  --- @field [3]? boolean

  local function _is_type(val, t)
    return type(val) == t or (t == "callable" and vim.is_callable(val))
  end

  --- @param param_name string
  --- @param spec weasel.core.utils.Spec
  --- @return string?
  local function is_param_valid(param_name, spec)
    if type(spec) ~= "table" then
      return string.format("opt[%s]: expected table, got %s", param_name, type(spec))
    end

    local val = spec[1] -- Argument value
    local types = spec[2] -- Type name, or callable
    local optional = (true == spec[3])

    if type(types) == "string" then
      types = { types }
    end

    if vim.is_callable(types) then
      -- Check user-provided validation function
      local valid, optional_message = types(val)
      if not valid then
        local error_message = string.format("%s: expected %s, got %s", param_name, (spec[3] or "?"), tostring(val))
        if optional_message ~= nil then
          error_message = string.format("%s. Info: %s", error_message, optional_message)
        end

        return error_message
      end
    elseif type(types) == "table" then
      local success = false
      for i, t in ipairs(types) do
        local t_name = type_names[t]
        if not t_name then
          return string.format("invalid type name: %s", t)
        end
        types[i] = t_name

        if (optional and val == nil) or _is_type(val, t_name) then
          success = true
          break
        end
      end
      if not success then
        return string.format("%s: expected %s, got %s", param_name, table.concat(types, "|"), type(val))
      end
    else
      return string.format("invalid type name: %s", tostring(types))
    end
  end

  --- @param opt table<weasel.core.utils.Type,weasel.core.utils.Spec>
  --- @return boolean, string?
  local function is_valid(opt)
    if type(opt) ~= "table" then
      return false, string.format("opt: expected table, got %s", type(opt))
    end

    local report --- @type table<string,string>?

    for param_name, spec in pairs(opt) do
      local msg = is_param_valid(param_name, spec)
      if msg then
        report = report or {}
        report[param_name] = msg
      end
    end

    if report then
      for _, msg in vim.spairs(report) do -- luacheck: ignore
        return false, msg
      end
    end

    return true
  end

  --- Validate function arguments.
  ---
  --- This function has two valid forms:
  ---
  --- 1. weasel.core.utils(name: str, value: any, type: string, optional?: bool)
  --- 2. weasel.core.utils(spec: table)
  ---
  --- Form 1 validates that argument {name} with value {value} has the type
  --- {type}. {type} must be a value returned by |lua-type()|. If {optional} is
  --- true, then {value} may be null. This form is significantly faster and
  --- should be preferred for simple cases.
  ---
  --- Example:
  ---
  --- ```lua
  --- function vim.startswith(s, prefix)
  ---   weasel.core.utils('s', s, 'string')
  ---   weasel.core.utils('prefix', prefix, 'string')
  ---   ...
  --- end
  --- ```
  ---
  --- Form 2 validates a parameter specification (types and values). Specs are
  --- evaluated in alphanumeric order, until the first failure.
  ---
  --- Usage example:
  ---
  --- ```lua
  --- function user.new(name, age, hobbies)
  ---   weasel.core.utils{
  ---     name={name, 'string'},
  ---     age={age, 'number'},
  ---     hobbies={hobbies, 'table'},
  ---   }
  ---   ...
  --- end
  --- ```
  ---
  --- Examples with explicit argument values (can be run directly):
  ---
  --- ```lua
  --- weasel.core.utils{arg1={{'foo'}, 'table'}, arg2={'foo', 'string'}}
  ---    --> NOP (success)
  ---
  --- weasel.core.utils{arg1={1, 'table'}}
  ---    --> error('arg1: expected table, got number')
  ---
  --- weasel.core.utils{arg1={3, function(a) return (a % 2) == 0 end, 'even number'}}
  ---    --> error('arg1: expected even number, got 3')
  --- ```
  ---
  --- If multiple types are valid they can be given as a list.
  ---
  --- ```lua
  --- weasel.core.utils{arg1={{'foo'}, {'table', 'string'}}, arg2={'foo', {'table', 'string'}}}
  --- -- NOP (success)
  ---
  --- weasel.core.utils{arg1={1, {'string', 'table'}}}
  --- -- error('arg1: expected string|table, got number')
  --- ```
  ---
  ---@param opt table<weasel.core.utils.Type,weasel.core.utils.Spec> (table) Names of parameters to validate. Each key is a parameter
  ---          name; each value is a tuple in one of these forms:
  ---          1. (arg_value, type_name, optional)
  ---             - arg_value: argument value
  ---             - type_name: string|table type name, one of: ("table", "t", "string",
  ---               "s", "number", "n", "boolean", "b", "function", "f", "nil",
  ---               "thread", "userdata") or list of them.
  ---             - optional: (optional) boolean, if true, `nil` is valid
  ---          2. (arg_value, fn, msg)
  ---             - arg_value: argument value
  ---             - fn: any function accepting one argument, returns true if and
  ---               only if the argument is valid. Can optionally return an additional
  ---               informative error message as the second returned value.
  ---             - msg: (optional) error string if validation fails
  --- @overload fun(name: string, val: any, expected: string, optional?: boolean)
  function utils.validate(opt, ...)
    local ok = false
    local err_msg ---@type string?
    local narg = select("#", ...)
    if narg == 0 then
      ok, err_msg = is_valid(opt)
    elseif narg >= 2 then
      -- Overloaded signature for fast/simple cases
      local name = opt --[[@as string]]
      local v, expected, optional = ... ---@type string, string, boolean?
      local actual = type(v)

      ok = (actual == expected) or (v == nil and optional == true)
      if not ok then
        err_msg = ("%s: expected %s, got %s%s"):format(name, expected, actual, v and (" (%s)"):format(v) or "")
      end
    else
      error "invalid arguments"
    end

    if not ok then
      error(err_msg, 2)
    end
  end
end
--- Returns true if object `f` can be called as a function.
---
---@param f any Any object
---@return boolean `true` if `f` is callable, else `false`
function utils.is_callable(f)
  if type(f) == "function" then
    return true
  end
  local m = getmetatable(f)
  if m == nil then
    return false
  end
  return type(m.__call) == "function"
end

--- Return a list of all keys used in a table.
--- However, the order of the return table of keys is not guaranteed.
---
---@see From https://github.com/premake/premake-core/blob/master/src/base/table.lua
---
---@generic T
---@param t table<T, any> (table) Table
---@return T[] : List of keys
function utils.tbl_keys(t)
  utils.validate("t", t, "table")
  --- @cast t table<any,any>

  local keys = {}
  for k in pairs(t) do
    table.insert(keys, k)
  end
  return keys
end

--- Return a list of all values used in a table.
--- However, the order of the return table of values is not guaranteed.
---
---@generic T
---@param t table<any, T> (table) Table
---@return T[] : List of values
function utils.tbl_values(t)
  utils.validate("t", t, "table")

  local values = {}
  for _, v in
    pairs(t --[[@as table<any,any>]])
  do
    table.insert(values, v)
  end
  return values
end

--- Default transformers for statistics
local transform = {
  ---Transform `time` into a readable typed time (e.g. 200ms)
  ---@param time string
  ---@return string
  time = function(time)
    ---@diagnostic disable-next-line cast-local-type
    time = tonumber(time)

    if time >= 60 then
      time = string.format("%.2f", time / 60)

      return time .. " min"
    end

    local units = { "s", "ms", "µs", "ns" }
    local unit = 1

    while time < 1 and unit <= #units do
      ---@diagnostic disable-next-line cast-local-type
      time = time * 1000
      unit = unit + 1
    end

    time = string.format("%.2f", time)

    return time .. " " .. units[unit]
  end,

  ---Transform `bytes` into another bigger size type if needed
  ---@param bytes string
  ---@return string
  size = function(bytes)
    ---@diagnostic disable-next-line cast-local-type
    bytes = tonumber(bytes)

    local units = { "B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB" }
    local unit = 1

    while bytes >= 1024 and unit <= #units do
      ---@diagnostic disable-next-line cast-local-type
      bytes = bytes / 1024
      unit = unit + 1
    end

    bytes = string.format("%.2f", bytes)

    return bytes .. " " .. units[unit]
  end,
}

utils.transform_time = transform.time
utils.transform_size = transform.size

return utils
