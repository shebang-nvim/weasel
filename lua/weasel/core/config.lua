--- @brief [[
--- Defines the configuration table for use throughout weasel.
--- @brief ]]

-- TODO(vhyrro): Make `weasel_version` and `version` a `Version` class.

--- @alias _OperatingSystem
--- | "windows"
--- | "wsl"
--- | "wsl2"
--- | "mac"
--- | "linux"
--- | "bsd"

--- @alias weasel.configuration.module { config?: table }

--- @class (exact) weasel.configuration.user
--- @field hook? fun(manual: boolean, arguments?: string)    A user-defined function that is invoked whenever weasel starts up. May be used to e.g. set custom keybindings.
--- @field lazy_loading? boolean                             Whether to defer loading the weasel core until after the user has entered a `.weasel` file.
--- @field load table<weasel.module_type, table<string, weasel.configuration.module>> A list of modules to load, alongside their configurations.
--- @field logger? weasel.log.configuration                   A configuration table for the logger.

--- @class (exact) weasel.configuration
--- @field arguments table<string, string>                   A list of arguments provided to the `:weaselStart` function in the form of `key=value` pairs. Only applicable when `user_config.lazy_loading` is `true`.
--- @field manual boolean?                                   Used if weasel was manually loaded via `:weaselStart`. Only applicable when `user_config.lazy_loading` is `true`.
--- @field modules table<weasel.module_type, table<string, weasel.configuration.module>> Acts as a copy of the user's configuration that may be modified at runtime.
--- @field weasel_version string                               The version of the file format to be used throughout weasel. Used internally.
--- @field os_info _OperatingSystem                           The operating system that weasel is currently running under.
--- @field pathsep "\\"|"/"                                  The operating system that weasel is currently running under.
--- @field started boolean                                   Set to `true` when weasel is fully initialized.
--- @field user_config weasel.configuration.user              Stores the configuration provided by the user.
--- @field version string                                    The version of weasel that is currently active. Automatically updated by CI on every release.

--- Gets the current operating system.
--- @return _OperatingSystem
local function get_os_info()
	local os = vim.loop.os_uname().sysname:lower()

	if os:find("windows_nt") then
		return "windows"
	elseif os == "darwin" then
		return "mac"
	elseif os == "linux" then
		local f = io.open("/proc/version", "r")
		if f ~= nil then
			local version = f:read("*all")
			f:close()
			if version:find("WSL2") then
				return "wsl2"
			elseif version:find("microsoft") then
				return "wsl"
			end
		end
		return "linux"
	elseif os:find("bsd") then
		return "bsd"
	end

	error("[weasel]: Unable to determine the currently active operating system!")
end

local os_info = get_os_info()

---@type weasel.configuration.user
local user_configuration_defaults = {
	lazy_loading = false,
	load = {
		provider = {
			["core.generic"] = {},
		},

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

	modules = {
		provider = {},
		auth = {},
	},
	manual = nil,
	arguments = {},

	weasel_version = "1.1.1",
	version = "8.8.1",

	os_info = os_info,
	pathsep = os_info == "windows" and "\\" or "/",

	hook = nil,
	started = false,
}

return config
