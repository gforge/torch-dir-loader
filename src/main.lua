local argcheck = require "argcheck"
local paths = require "paths"
local argdoc = require 'argcheck.doc'

argdoc[[

## Package load functions

]]

get_sorted_files  = argcheck{
	doc=[[
<a name="get_sorted_lua_files">
### get_sorted_lua_files(@ARGP)

Calls the `paths.files()` with the directory and sorts the files according to
name.

@ARGT

_Return value_: table with sorted file names
]],
	{name="path", type="string",
	 doc="The directory path"},
	{name="match_str", type="string", default="[.]lua$",
	 doc="The file matching string to search for. Defaults to lua file endings."},
	call=function(path, match_str)
	local files = {}
	for f in paths.files(path) do
		if (f:match(match_str)) then
			files[#files + 1] = f
		end
	end

	table.sort(files)

	return files
end}

load_dir_files = argcheck{
	doc=[[
<a name="load_dir_files">
### load_dir_files(@ARGP)

Traverses a directory and loads all files within

@ARGT

_Return values_:
 1. The files loaded in the processed order
 2. The doc content if `docs` argument was true - otherwise it's an empty table
 3. The object that is returned from the `init.lua` if such exists
]],
	{name="path", type="string", doc="The directory"},
	{name="params", type="table", doc="Objects to pass to the files", default={}},
	{name="docs", type="boolean", doc="Run with argcheck.doc", default=false},
	call = (function()
	-- Hidden variable that makes sure we don't reload files
	local loaded_files = {paths.thisfile()}

	local function is_loaded(file)
		for _,fn in ipairs(loaded_files) do
			if (fn == file) then
				return true
			end
		end

		return false
	end

	local function load_file(file, params, docs, ret_docs, ret_fpaths)
		if (docs) then
			argdoc.record()
		end

		local ret = assert(loadfile(file))(table.unpack(params))

		if (docs) then

			-- Assigns to parent ret_docs
			ret_docs[file] = argdoc.stop()
		end

		table.insert(loaded_files, file)
		table.insert(ret_fpaths, file)
		return ret
	end

	return function(path, params, docs)
		if (not path:match("/$")) then
			path = path .. "/"
		end

		assert(paths.dirp(path), ("The path '%s' isn't a valid directory"):format(path))
		table.insert(params, path)
		local ret_docs = {}
		local ret_fpaths = {}
		local obj

		local init_path = path .. "init.lua"
		if (paths.filep(init_path) and not is_loaded(init_path)) then
			obj = load_file(init_path, params, docs, ret_docs, ret_fpaths)
			table.insert(params, 1, obj)
		end

		local files = get_sorted_files(path)
		for _,file in pairs(files) do
			local file = path .. file

			if (not is_loaded(file)) then

				load_file(file, params, docs, ret_docs, ret_fpaths)

			end
		end

		return ret_fpaths, ret_docs, obj
	end
end)()}

return load_dir_files
