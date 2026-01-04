require("matcher_combinators.luassert")

local Path = require('srplib.path')

--
-- Creates Path object from string or table.
-- In both cases '/' separator is used.
-- function is used as simple Path constructor for unit tests.
--
local function newpath(value)
    if type(value) == 'string' then
        return Path.parse(value, '/')
    elseif type(value) == 'table' then
        return Path:new(value, '/')
    else
        assert(false, string.format("Can not create path from '%s'. " ..
            "Expected string or table.", value))
    end
end

describe("Path.parse", function()

    it("nil string parsed as nil path", function ()
        local path = Path.parse(nil, '.')
        assert.are.equals(nil, path)
    end)

    it("empty string parsed as empty path", function ()
        local path = Path.parse('', '.')
        assert.are.same({}, path.segments)
    end)

    it("string without separators is single segment path", function ()
        local path = Path.parse('abc', '.')
        assert.are.same({'abc'}, path.segments)
    end)

    it("two segments path", function ()
        local path = Path.parse('ab.cd', '.')
        assert.are.same({'ab', 'cd'}, path.segments)
    end)

    it("trailing separator does not count", function ()
        local path = Path.parse('ab.cd.hello.', '.')
        assert.are.same({'ab', 'cd', 'hello'}, path.segments)
    end)

    it("three segments path", function ()
        local path = Path.parse('ab.cd.hello', '.')
        assert.are.same({'ab', 'cd', 'hello'}, path.segments)
    end)

    it("alternative separator", function ()
        local path = Path.parse('ab/cd/hello', '/')
        assert.are.same({'ab', 'cd', 'hello'}, path.segments)
    end)

    it("alternative separator2", function ()
        local path = Path.parse('ab_cd_hello', '_')
        assert.are.same({'ab', 'cd', 'hello'}, path.segments)
    end)

    it("subsequent separators treated as single one", function ()
        local path = Path.parse('ab..cd', '.')
        assert.are.same({'ab', 'cd'}, path.segments)
    end)

    it("separator only treated as empty path", function ()
        local path = Path.parse('.', '.')
        assert.are.same({}, path.segments)
    end)
end)

describe("Path.clone", function ()
    it("Clones are independent", function ()
        local path = Path:new({1}, '/')
        local clone = path:clone()
        clone.segments = {2}
        clone.separator = '.'

        assert.are.equals('/', path.separator)
        assert.are.same({1}, path.segments)

        assert.are.equals('.', clone.separator)
        assert.are.same({2}, clone.segments)
    end)
end)

describe("Path.tostring", function()

    it("empty path", function()
        local path = Path:new({}, "/")
        assert.are.equals('', path:tostring())
    end)

    it("one segment", function()
        local path = Path:new({'segment'}, "/")
        assert.are.equals('segment', path:tostring())
    end)

    it("multiple segments", function()
        local path = Path:new({'a', 'b', 'c'}, ".")
        assert.are.equals('a.b.c', path:tostring())
    end)

end)

describe("Path.subpath", function ()

    local path = Path:new({4, 5, 6, 7, 8, 9}, ".")

    it("Start index less than 1", function ()
        assert.has_error(function () path:subpath(0, 1) end)
    end)

    it("End index greater than size", function ()
        assert.has_error(function () path:subpath(1, 100) end)
    end)

    it("Start index greater than end index", function ()
        assert.has_error(function () path:subpath(2, 1) end)
    end)

    it("Getting single segment subpath", function ()
        assert.are.same('6', path:subpath(3, 3):tostring())
    end)

    it("Ordinary subpath", function ()
        assert.are.same('5.6.7.8', path:subpath(2, 5):tostring())
    end)

    it("First segment subpath", function ()
        assert.are.same('4.5', path:subpath(1, 2):tostring())
    end)

    it("Last segment subpath", function ()
        assert.are.same('9', path:subpath(path:size(), path:size()):tostring())
    end)

end)

describe("Path.parent", function()

    it("Parent of empty path is nil", function ()
        local path = Path:new({}, '.')
        local parent = path:parent()
        assert.are.same(nil, parent)
    end)

    it("Parent of single segment path is empty path", function ()
        local path = Path:new({'abc'}, '.')
        local parent = path:parent()
        assert.are.same({}, parent.segments)
    end)

    it("Parent of multiple segment path", function ()
        local path = Path:new({'a', 'b', 'c', 'd'}, '.')
        local parent = path:parent()
        assert.are.same({'a', 'b', 'c'}, parent.segments)
    end)

end)

describe("Path.child", function ()

    it("Child of empty", function ()
        local path = Path:new({}, '.')
        local child = path:child(1)
        assert.are.same('1', child:tostring())
    end)

    it("Child of non-empty", function ()
        local path = Path:new({1,2,3}, '.')
        local child = path:child(4)
        assert.are.same('1.2.3.4', child:tostring())
    end)
end)

describe("Path.sibling", function ()

    it("Empty path sibling is empty path", function ()
        local path = Path:new({}, '.')
        local child = path:sibling(5)
        assert.are.same('', child:tostring())
    end)

    it("Non-empty path sibling", function ()
        local path = Path:new({1,2,3}, '.')
        local child = path:sibling(5)
        assert.are.same('1.2.5', child:tostring())
    end)
end)

describe("Path.size", function ()

    it("Empty path size is 0", function ()
        local path = Path:new({}, '.')
        assert.are.equals(0, path:size())
    end)

    it("Non-empty path size", function ()
        local path = Path:new({1,2,3,4,5}, '.')
        assert.are.equals(5, path:size())
    end)
end)

local function assertRelative(pathSegments, baseSegments, expectedSegments)
    local pathObject = newpath(pathSegments)
    local baseObject = newpath(baseSegments)
    local expectedObject = newpath(expectedSegments)

    local resultObject = pathObject:relative(baseObject)

    assert.are.same(expectedObject.segments, resultObject.segments)
end

describe("Path.relative", function ()

    it("Empty relative to empty is empty", function ()
        assertRelative('', '', '')
    end)

    it("Empty relative to non-empty", function ()
        assertRelative('', 'a', 'a/..')
    end)

    it("Non-empty relative to empty", function ()
        assertRelative('a', '', 'a')
    end)

    it("Child relation", function ()
        assertRelative('a/b/c/d/e', 'a/b/c', 'd/e')
    end)

    it("Non-child relation with common segments", function ()
        assertRelative('common/b/c', 'common/e/f', 'e/f/../../b/c')
    end)

    it("Non-child relation without common segments", function ()
        assertRelative('a/b/c', 'd/e/f', 'd/e/f/../../../a/b/c')
    end)
end)
