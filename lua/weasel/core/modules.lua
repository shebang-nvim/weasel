--- @brief [[
--- Base file for modules.
---
---
--- Module types:
---
--- providers: weasel.core.providers.*
--- auth: weasel.core.auth.*
---
--- Loading rules:
---
--- - dependencies not supported yet
--- - replacing modules not supported yet
--- - module must return { success=true }
---
--- @brief ]]

-- TODO: What goes below this line until the next notice used to belong to modules.base
-- We need to find a way to make these constructors easier to maintain and more efficient

-- local callbacks = require "weasel.core.callbacks"
local config = require("weasel.core.config")
local log = require("weasel.core.log")
local utils = require("weasel.core.utils")

local modules = setmetatable({}, {
	__index = function(t, k)
		local v = rawget(t, k)
		if v then
			return v
		end
		--- TODO: add discovery
		if k == "providers" then
			return {
				"core.datamuse",
				"core.generic",
			}
		end
	end,
})

--- Returns a new weasel module, exposing all the necessary function and variables.
--- @param name string The name of the new module.
--- @return weasel.module
function modules.create(name)
	---create a new module
	---@type weasel.module
	local new_module = {
		service = "",
		name = "",
		path = "",
		type = "provider",
		setup = function()
			return { success = true }
		end,

		on_event = function(event) end,
		weasel_post_load = function() end,
		config = {
			public = {
				services = {},
			},
		},
		events = {
			subscribed = { -- The events that the module is subscribed to
				--[[
                --]]
			},
			defined = { -- The events that the module itself has defined
				--[[
                --]]
			},
		},
	}
	new_module.name = name
	new_module.path = "modules." .. name
	return new_module
end

-- TODO: What goes below this line until the next notice used to belong to modules
-- We need to find a way to make these functions easier to maintain

--- Tracks the amount of currently loaded modules.
modules.loaded_modules_count = 0

--- The table of currently loaded modules
--- @type { [ weasel.module_type ]: { [string]: weasel.module } }
modules.loaded_modules = {
	provider = {},
	auth = {},
}

--- Loads and enables a module
--- Loads a specified module. If the module subscribes to any events then they will be activated too.
--- @param module weasel.module The actual module to load.
--- @return boolean # Whether the module successfully loaded.
function modules.load_module_from_table(module)
	log.info("Loading module with name", module.name)

	-- If our module is already loaded don't try loading it again
	if modules.loaded_modules[module.name] then
		log.trace("module", module.name, "already loaded. Omitting...")
		return true
	end

	-- Invoke the setup function. This function returns whether or not the loading of the module was successful and some metadata.
	---@type weasel.module.setup|nil
	local loaded_module = module.setup and module.setup() or nil

	--
	-- We do not expect module.setup() to ever return nil, that's why this check is in place
	if not loaded_module then
		log.error(
			"module",
			utils.lua_module_name(module.type, module.name),
			"does not handle module loading correctly; module.setup() returned nil. Omitting..."
		)
		return false
	end

	-- A part of the table returned by module.setup() tells us whether or not the module initialization was successful
	if loaded_module.success == false then
		log.trace("module", module.name, "did not load properly.")
		return false
	end

	log.info("Successfully loaded module", utils.lua_module_name(module.type, module.name))

	-- Keep track of the number of loaded modules
	modules.loaded_modules_count = modules.loaded_modules_count + 1

	-- Call the load function
	-- if module.load then
	--   module.load()
	-- end

	-- modules.broadcast_event {
	--   type = "core.module_loaded",
	--   split_type = { "core", "module_loaded" },
	--   filename = "",
	--   filehead = "",
	--   cursor_position = { 0, 0 },
	--   referrer = "core",
	--   line_content = "",
	--   content = module,
	--   broadcast = true,
	--   buffer = vim.api.nvim_get_current_buf(),
	--   window = vim.api.nvim_get_current_win(),
	--   mode = vim.fn.mode(),
	-- }
	--
	return true
end

---@alias weasel.module_type 'provider'|'auth'

--- Unlike `load_module_from_table()`, which loads a module from memory, `load_module()` tries to find the corresponding module file on disk and loads it into memory.
--- If the module cannot not be found, attempt to load it off of github (unimplemented). This function also applies user-defined config and keymaps to the modules themselves.
--- This is the recommended way of loading modules - `load_module_from_table()` should only really be used by weasel itself.
--- @param module_name string A path to a module on disk. A path seperator in weasel is '.', not '/'.
--- @param module_type weasel.module_type The type of the module
--- @param cfg table? A config that reflects the structure of `weasel.config.user_config.load["module.name"].config`.
--- @return boolean # Whether the module was successfully loaded.
function modules.load_module(module_name, module_type, cfg)
	-- Don't bother loading the module from disk if it's already loaded
	if modules.is_module_loaded(module_name, module_type) then
		return true
	end

	-- Attempt to require the module, does not throw an error if the module doesn't exist
	local exists, module = pcall(require, "weasel." .. module_type .. "." .. module_name .. ".module")

	-- If the module doesn't exist then return false
	if not exists then
		log.error(
			"Unable to load module '"
				.. utils.lua_module_name(module_type, module_name)
				.. "'. The module probably does not exist! Stacktrace: ",
			module
		)
		return false
	end

	-- If the module is nil for some reason return false
	if not module then
		log.error(
			"Unable to load module",
			utils.lua_module_name(module_type, module_name),
			"- loaded file returned nil. Be sure to return the table created by modules.create() at the end of your module.lua file!"
		)
		return false
	end

	-- If the value of `module` is strictly true then it means the required file returned nothing
	-- We obviously can't do anything meaningful with that!
	if module == true then
		log.error(
			"An error has occurred when loading",
			utils.lua_module_name(module_type, module_name),
			"- loaded file didn't return anything meaningful. Be sure to return the table created by modules.create() at the end of your module.lua file!"
		)
		return false
	end

	-- Add the module into the list of loaded modules
	-- The reason we do this here is so other modules don't recursively require each other in the dependency loading loop below
	modules.loaded_modules[module.type][module.name] = module

	-- Load the user-defined config
	if cfg and not vim.tbl_isempty(cfg) then
		module.config.custom = cfg
		module.config.public = vim.tbl_deep_extend("force", module.config.public, cfg)
	else
		module.config.custom = config.modules[module_type][module_name]
		module.config.public = vim.tbl_deep_extend("force", module.config.public, module.config.custom or {})
	end

	-- Pass execution onto load_module_from_table() and let it handle the rest
	return modules.load_module_from_table(module)
end

--- Retrieves the public API exposed by the module.
--- @generic T
--- @param module_name `T` The name of the module to retrieve.
--- @param module_type weasel.module_type The type of the module
--- @return T?
function modules.get_module(module_name, module_type)
	if not modules.is_module_loaded(module_name, module_type) then
		log.trace("Attempt to get module with name", module_name, "failed - module is not loaded.")
		return
	end

	return modules.loaded_modules[module_type][module_name].public
end

--- Returns the module.config.public table if the module is loaded
--- @param module_name string The name of the module to retrieve (module must be loaded)
--- @param module_type weasel.module_type The type of the module
--- @return table?
function modules.get_module_config(module_name, module_type)
	if not modules.is_module_loaded(module_name, module_type) then
		log.trace("Attempt to get module config with name", module_name, module_type, "failed - module is not loaded.")
		return
	end

	return modules.loaded_modules[module_type][module_name].config.public
end

--- Returns true if module with name module_name is loaded, false otherwise
--- @param module_name string The name of an arbitrary module
--- @param module_type weasel.module_type The type of the module
--- @return boolean
function modules.is_module_loaded(module_name, module_type)
	return modules.loaded_modules[module_type][module_name] ~= nil
end

--- Reads the module's public table and looks for a version variable, then converts it from a string into a table, like so: `{ major = <number>, minor = <number>, patch = <number> }`.
--- @param module_name string The name of a valid, loaded module.
--- @param module_type weasel.module_type The type of the module
--- @return table? parsed_version
function modules.get_module_version(module_name, module_type)
	-- If the module isn't loaded then don't bother retrieving its version
	if not modules.is_module_loaded(module_name, module_type) then
		log.trace("Attempt to get module version with name", module_name, module_type, "failed - module is not loaded.")
		return
	end

	-- Grab the version of the module
	local version = modules.get_module(module_name, module_type).version

	-- If it can't be found then error out
	if not version then
		log.trace(
			"Attempt to get module version with name",
			module_name,
			module_type,
			"failed - version variable not present."
		)
		return
	end

	return utils.parse_version_string(version)
end

return modules
