local core = require("weasel.core")
local config, log, modules = core.config, core.log, core.modules

---@class weasel.loader
local loader = {}

------@class weasel.loader
------ overload fun(...):corevim.colors.Theme
---loader = setmetatable({}, {
---  __call = function(_, ...) end,
---  __index = loader,
---})

function loader.load_module(module_type, module_name, arguments)
	-- If we have already started weasel or if we haven't defined any modules to load then bail
	if config.started or not module_name or not module_type then
		return
	end

	-- If the user has supplied any weasel environment variables
	-- then parse those here
	if arguments and arguments:len() > 0 then
		for key, value in arguments:gmatch("([%w%W]+)=([%w%W]+)") do
			config.arguments[key] = value
		end
	end

	for name, module in pairs(module_list) do
		-- If the module's data is not empty and we have not defined a config table then it probably means there's junk in there
		if not vim.tbl_isempty(module) and not module.config then
			log.warn(
				"Potential bug detected in",
				name,
				"- nonstandard tables found in the module definition. Did you perhaps mean to put these tables inside of the config = {} table?"
			)
		end

		-- Apply the config
		config.modules[module_type][name] =
			vim.tbl_deep_extend("force", config.modules[module_type][name] or {}, module.config or {})
	end

	-- After all config are merged proceed to actually load the modules
	local load_module = modules.load_module
	for name, _ in pairs(module_list) do
		-- If it could not be loaded then halt
		if not load_module(name, module_type) then
			log.warn("Recovering from error...")
			modules.loaded_modules[module_type][name] = nil
		end
	end

	-- Goes through each loaded module and invokes weasel_post_load()
	for _, module in pairs(modules.loaded_modules[module_type]) do
		module.weasel_post_load()
	end
end

---comment
---@param name string
function loader.load_client(name)
	if not vim.tbl_contains(modules.providers, name) then
		error("invalid provider module: " .. name)
	end

	local ok = modules.load_module(name, "provider")
	if not ok then
		log.error("error loaded client: " .. name)
		return false
	end

	local module = modules.get_module(name, "provider")

	log.debug("module loaded", module)
end

loader.accessors = {
	client = loader.load_client,
}
---comment
---@param parent table
---@param k string The wanted key
function loader.handle_api_access(parent, k)
	local endpoint = loader.accessors[k]
	if type(endpoint) == "function" then
		log.debug("returning endpoint", k)
		return endpoint
	end

	return error("unknown API endpoint: " .. tostring(k))
	-- local modules = require "weasel.core.modules"
	-- local loaded_modules = modules.loaded_modules
end

return loader
