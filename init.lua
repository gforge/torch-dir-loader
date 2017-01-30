local paths = require 'paths'
local loader_dir = string.gsub(paths.thisfile(), "[^/]+$", "")

-- Get the loader funciton and start by making utils available to all
local main_file = loader_dir .. "src/main.lua"
local dir_loader = assert(loadfile(main_file))()

return dir_loader
