require 'lfs'
local _ = require 'moses'

describe("Load test_dir with object", function()
  local loader
  before_each(function()
    -- Make sure that directory structure is always the same
    if (string.match(lfs.currentdir(), "/specs$")) then
      lfs.chdir("..")
    end

    -- Get loader
    loader = dofile('init.lua')

    -- Go into specs so that the loading of CSV:s is the same as always
    lfs.chdir("specs")
  end)

  it("Retrieves the object, paths, and leaves the docs", function()
    local paths_loaded, docs, obj = loader('test_dir')
    assert.truthy(_.find(paths_loaded, 'test_dir/init.lua'),
                  'Couldn\'t find init.lua in loaded paths')
    assert.truthy(_.find(paths_loaded, 'test_dir/other.lua'),
                  'Couldn\'t find init.lua in loaded paths')
    assert.are.same(obj.a, 1)
    assert.are.same(obj.other, 2)
    assert.are.same(docs, {})

    paths_loaded, docs, obj = loader('test_dir')
    assert.are.same(paths_loaded, {}, 'Shouldn\'t load anything the second time around')
    assert.is_nil(obj, 'The returned object should be null the second time')
    assert.are.same(docs, {})
  end)

  it("Retrieves the object, paths, and leaves the docs", function()
    local paths_loaded, docs, obj = loader{
        path = 'test_dir',
        docs = true
    }
    assert.truthy(_.find(paths_loaded, 'test_dir/init.lua'),
                  'Couldn\'t find init.lua in loaded paths')
    assert.truthy(_.find(paths_loaded, 'test_dir/other.lua'),
                  'Couldn\'t find init.lua in loaded paths')
    assert.are.same(obj.a, 1)
    assert.are.same(obj.other, 2)
    assert.are.same(docs, {
      ['test_dir/init.lua'] = '',
      ['test_dir/other.lua'] = 'test_other'
    })

    local paths_loaded, docs, obj = loader{
        path = 'test_dir',
        docs = true
    }
    assert.are.same(docs, {}, 'The docs shouldn\'t be re-run a second time')
  end)
end)
