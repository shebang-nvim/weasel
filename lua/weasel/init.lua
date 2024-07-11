---@tag weasel
---@config { ["module"] = "weasel" }

---@brief [[
--- `Weasel` is a Lua web service module library with pluggable service modules that provides fully asynchronous
--- interfaces for interacting with remote services.
---
--- The architecture of this library is inspired by `neorg`.
---
--- Terminology:
---
--- - weasel-module: A Lua module that provides functionality. Each module can be packaged and distributed separately and has proper version tags.
---
--- - provider: Providers offer interfaces to service endpoints. This is the top-level class for vendor APIs.
---   - services: Each provider has one or more services that can be used.
---     - endpoints: Each service has an endpoint and defines the interfaces needed to communicate with a specific API.
---     - methods: Each API provides certain methods (CRUD) to work with data.
---     - auth: Each API offers specific authentication methods to authenticate the user.--
---
---
--- The following providers are available:
---
--- - datamuse: datamuse service endpoint
---
---@brief ]]

--- Initialization logic of this library
---

--- @class weasel
--- @field client fun(...:any):table
--- @field config weasel.configuration
--- @field os_info weasel.OperatingSystem The operating system that weasel is currently running under.
--- @field pathsep "\\"|"/" The operating system that weasel is currently running under.
local weasel = {
  initialized = false,
}
local utils = require "weasel.core.utils"

--- Initializes weasel. Parses the supplied user configuration, initializes all selected modules.
--- @param cfg weasel.configuration A table that reflects the structure of `config.user_config`.
--- @see config.user_config
--- @see weasel.configuration.user
local function init(cfg)
  local loader = require "weasel.loader"
  local core = require "weasel.core"
  local config, log = core.config, core.log

  -- Create a new global instance of the weasel logger.
  log.new(config.user_config.logger or log.get_default_config(), true)

  --- library exports
  ---@type weasel
  return setmetatable(weasel, {
    -- __call = function(_, ...) end,
    __index = function(t, k)
      return loader.handle_api_access(t, k)
    end,
  })
end

--- Initializes weasel. Parses the supplied user configuration, initializes all selected modules.
--- @param cfg weasel.configuration.user? A table that reflects the structure of `config.user_config`.
--- @see config.user_config
--- @see weasel.configuration.user
function weasel.setup(cfg)
  local config = require "weasel.core.config"

  -- If the user supplied no configuration then generate a default one (assume the user wants the defaults)
  cfg = cfg or config.user_config

  -- If no `load` table was passed whatsoever then assume the user wants the default ones.
  -- If the user explicitly sets `load = {}` in their configs then that means they do not want
  -- any modules loaded.
  --
  -- We check for nil specifically because some users might think `load = false` is a valid thing.
  -- With the explicit check `load = false` will issue an error.
  if cfg.load == nil then
    cfg = config.user_config.load
  end

  -- TODO: parse environment vars
  -- If the user has supplied any weasel environment variables
  -- then parse those here

  config.user_config = utils.tbl_deep_extend("force", config.user_config, cfg)
  weasel.config = config
  weasel.initialized = true

  weasel.os_info = utils.get_os_info()

  weasel.path_sep = weasel.os_info == "windows" and "\\" or "/"
  return init(config)
end

-- TODO: maby use the following pattern to manage config
--
-- ---@param opts? LazyVimOptions
-- function M.setup(opts)
--   options = vim.tbl_deep_extend("force", defaults, opts or {}) or {}
-- end
--
-- setmetatable(M, {
--   __index = function(_, key)
--     if options == nil then
--       return vim.deepcopy(defaults)[key]
--     end
--     ---@cast options LazyVimConfig
--     return options[key]
--   end,
-- })
--
return weasel
