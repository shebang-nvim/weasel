local configuration = require "weasel.core.config"
local log = require "weasel.core.log"

local utils = {}
local version = vim.version() -- TODO: Move to a more local scope

--- Checks whether Neovim is running at least at a specific version.
--- @param major number The major release of Neovim.
--- @param minor number The minor release of Neovim.
--- @param patch number The patch number (in case you need it).
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

function utils.lua_module_name(module_type, module_name)
  return "weasel." .. module_type .. "." .. module_name .. ".module"
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

--- Opens up an array of files and runs a callback for each opened file.
--- @param files (string|PathlibPath)[] An array of files to open.
--- @param callback fun(buffer: integer, filename: string) The callback to invoke for each file.
function utils.read_files(files, callback)
  for _, file in ipairs(files) do
    file = tostring(file)
    local bufnr = vim.uri_to_bufnr(vim.uri_from_fname(file))

    local should_delete = not vim.api.nvim_buf_is_loaded(bufnr)

    vim.fn.bufload(bufnr)
    callback(bufnr, file)
    if should_delete then
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end
  end
end

return utils
