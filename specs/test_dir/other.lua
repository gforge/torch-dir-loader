local doc = require "argcheck.doc"

doc[[test_other]]

local params = {...}
local my_object = params[1]

my_object.other = 2
