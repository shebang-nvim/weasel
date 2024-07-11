--- FIXME:move assert stuff
--- @alias weasel.assert_fun fun(...:any):any
---
--- @class weasel.assert_assertions
--- @field equal weasel.assert_fun
--- @field string weasel.assert_fun
--- @field same weasel.assert_fun

--- @alias weasel.assert_op weasel.assert_modifier|weasel.assert_assertions

--- @class weasel.assert_modifier
--- @field is weasel.assert_op
--- @field are weasel.assert_op
--- @field was weasel.assert_op
--- @field has weasel.assert_op
--- @field does weasel.assert_op
--- @field not weasel.assert_op
--- @field no weasel.assert_op
--- @field same weasel.assert_op
--- @field equal weasel.assert_op
--- @field False weasel.assert_op
--- @field True weasel.assert_op
--- @field Number weasel.assert_op
--- @field Function weasel.assert_op
--- @field Boolean weasel.assert_op
--- @field String weasel.assert_op
--- @field Table weasel.assert_op

--- @alias weasel.luassert weasel.assert_modifier

--- weasle types
--- -------------------------------------------------------------------------------

--- @alias weasel.OperatingSystem
--- | "windows"
--- | "wsl"
--- | "wsl2"
--- | "mac"
--- | "linux"
--- | "bsd"

--- @alias weasel.module.vendor_tag 'builtin'|'ext'
--- @alias weasel.module.type 'provider'|'auth'

--- @class weasel.module.spec.public

--- @class weasel.module.handle
--- @field name string
--- @field short_name string
--- @field path string
--- @field vendor_tag weasel.module.vendor_tag
--- @field type weasel.module.type

--- Defines both a public and private configuration for a weasle module.
--- Public configurations may be tweaked by the user from the `weasle.setup()` function,
--- whereas private configurations are for internal use only.
--- @class (exact) weasel.module.spec
--- @field public private? table Internal configuration variables that may be tweaked by the developer.
--- @field public public? weasel.module.spec.public  Configuration variables that may be tweaked by the user.

--- @alias weasel.module.setup { success: boolean }

--- Defines a module.
--- @class (exact) weasel.module
--- @field spec? weasel.module.spec The configuration for the module class.
--- @field type weasel.module.type
--- @field name string The name of the module.
--- @field path string The full path to the module (a more verbose version of `name`).
--- @field post_load? fun() Function that is invoked after all modules are loaded. Useful if you want the Neorg environment to be fully set up before performing some task.
--- @field setup? fun(): weasel.module.setup Setup function to configure the module.
