# torch-dir-loader

Loads a directory of files. You use the function as:
```
local loader = requrie 'torch-dir-loader'

local loaded_files, docs, my_object = loader('src')
```

The `loaded_files` contains all the files that have been loaded. The `docs` contains
docs if you're using the `argcheck.doc` system. The `my_object` will be an object
if you have an `init.lua` that returns an object.

## init.lua details

If there is an `init.lua` it will load that files collect any returning object and send it to the other files via the parameters. In order to use the object returned from the `init.lua` just use the following
in all other files, below is an example on how to extend a `torch.class`:

```
local params = {...}
local my_object = params[1]

my_object.additional_function = function()

end
```

## Only load once

Each file that the loader calls is remembered and therefore each file is only loaded
once. This means that the second time that the loader is invoked on the same directory
it won't result in any returned data.
