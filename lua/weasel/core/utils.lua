local configuration = require "weasel.core.config"
local log = require "weasel.core.log"
local vim_compat = require "weasel.lib.vim_compat"

local utils = {}
local version = vim.version() -- TODO: Move to a more local scope

utils.tbl_keys = vim_compat.tbl_keys
utils.tbl_values = vim_compat.tbl_values
utils.tbl_isempty = vim_compat.tbl_isempty
utils.tbl_contains = vim_compat.tbl_contains
utils.tbl_deep_extend = vim_compat.tbl_deep_extend
utils.is_callable = vim_compat.is_callable
utils.validate = vim_compat.validate
utils.deepcopy = vim_compat.deepcopy
utils.endswith = vim_compat.endswith

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

--- Gets the current operating system.
--- @return weasel.OperatingSystem
function utils.get_os_info()
  local os = vim.loop.os_uname().sysname:lower()

  if os:find "windows_nt" then
    return "windows"
  elseif os == "darwin" then
    return "mac"
  elseif os == "linux" then
    local f = io.open("/proc/version", "r")
    if f ~= nil then
      local _version = f:read "*all"
      f:close()
      if _version:find "WSL2" then
        return "wsl2"
      elseif _version:find "microsoft" then
        return "wsl"
      end
    end
    return "linux"
  elseif os:find "bsd" then
    return "bsd"
  end

  error "[weasel]: Unable to determine the currently active operating system!"
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

local json = {}

function json.decode(data)
  local ok, cjson = pcall(require, "cjson")
  local decode = (ok and cjson and cjson.decode) and cjson.decode
    or (vim and vim.json and vim.json.decode) and vim.json.decode
  return decode(data)
end

utils.json = json

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
