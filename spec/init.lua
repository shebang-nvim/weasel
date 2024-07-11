package.path = os.getenv "PWD" .. "/lua/?.lua;" .. package.path
local compat = require "promise-async.compat"

require "spec.helpers.assertions"
