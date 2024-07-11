--- @brief [[
--- Defines the configuration table for use throughout weasel.
--- @brief ]]

-- TODO(vhyrro): Make `weasel_version` and `version` a `Version` class.

--- @alias weasel.configuration.module { config?: table }

--- @class (exact) weasel.configuration.user
--- @field hook? fun(manual: boolean, arguments?: string)    A user-defined function that is invoked whenever weasel starts up. May be used to e.g. set custom keybindings.
--- @field lazy_loading? boolean                             Whether to defer loading the weasel core until after the user has entered a `.weasel` file.
--- @field load table<weasel.module_type, table<string, weasel.configuration.module>> A list of modules to load, alongside their configurations.
--- @field logger? weasel.log.configuration                   A configuration table for the logger.

--- @class (exact) weasel.configuration
--- @field user_config weasel.configuration.user              Stores the configuration provided by the user.
--- @field version string                                    The version of weasel that is currently active. Automatically updated by CI on every release.

---@type weasel.configuration.user
local user_configuration_defaults = {
  lazy_loading = false,
  load = {
    provider = {},
    auth = {},
  },
}

--- Stores the configuration for the entirety of weasel.
--- This includes not only the user configuration (passed to `setup()`), but also internal
--- variables that describe something specific about the user's hardware.
--- @see weasel.setup
---
--- @type weasel.configuration
local config = {
  user_config = user_configuration_defaults,
  version = "0.1.0",
}

return config
