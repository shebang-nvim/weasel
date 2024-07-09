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
--- @field equal weasel.assert_op
--- @field Function weasel.assert_op
--- @field String weasel.assert_op
--- @field Table weasel.assert_op

--- @alias weasel.luassert weasel.assert_modifier

--- weasle types
--- -------------------------------------------------------------------------------
---

--- @alias weasel.module.configuration.public.services { [string]: weasel.service }

--- @class weasel.module.configuration.public
--- @field services weasel.module.configuration.public.services

--- Defines both a public and private configuration for a weasle module.
--- Public configurations may be tweaked by the user from the `weasle.setup()` function,
--- whereas private configurations are for internal use only.
--- @class (exact) weasel.module.configuration
--- @field custom? table         Internal table that tracks the differences (changes) between the default `public` table and the new (altered) `public` table. It contains only the tables that the user has altered in their own configuration.
--- @field public private? table Internal configuration variables that may be tweaked by the developer.
--- @field public public? weasel.module.configuration.public  Configuration variables that may be tweaked by the user.

--- @alias weasel.module.public { version: string, [any]: any }
---
--- @class (exact) weasle.module.events
--- @field defined? { [string]: weasel.event }              Lists all events defined by this module.
--- @field subscribed? { [string]: { [string]: boolean } } Lists the events that the module is subscribed to.

--- @alias weasel.module.setup { success: boolean }

--- Defines a module.
--- @class (exact) weasel.module
--- @field config? weasel.module.configuration The configuration for the module class.
--- @field events? weasle.module.events Describes all information related to events for this module.
--- @field type weasel.module_type
--- @field name string The name of the module.
--- @field service string The service this module uses.
--- @field path string The full path to the module (a more verbose version of `name`).
--- @field weasel_post_load? fun() Function that is invoked after all modules are loaded. Useful if you want the Neorg environment to be fully set up before performing some task.
--- @field setup? fun(): weasel.module.setup Setup function to configure the module.
--- @field public private? table A convenience table to place all of your private variables that you don't want to expose.
--- @field public public? weasel.module.public Public interface of the module.
--- @field on_event fun(event: weasel.event) A callback that is invoked any time an event the module has subscribed to has fired.

--- @class (exact) weasel.event
--- @field type string The type of the event. Exists in the format of `category.name`.

--- @class (exact) weasel.auth

--- @class (exact) weasel.auth.bearer_token:weasel.auth
--- @field token fun():string

--- @class (exact) weasel.endpoint
--- @field method 'GET'|'POST'
--- @field headers? {[string]: string}
--- @field authentication? weasel.auth
--- @field url string
--- @field limits table
--- @field parameters table

--- @class (exact) weasel.service
--- @field name string
--- @field description string
--- @field endpoint weasel.endpoint
