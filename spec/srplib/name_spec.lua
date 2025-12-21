require("matcher_combinators.luassert")

local Name = require('srplib.name')

local function failed_on(input)
    return "Failed on input: '" .. tostring(input) .. "'"
end

describe("Name.new", function()

    it("empty has size 0", function ()
        local name = Name:new({})
        assert.are.equals(0, name:size())
        assert.are.equals('', name:tostring())
    end)

    it("one segment", function ()
        local name = Name:new({'a'})
        assert.are.equals(1, name:size())
        assert.are.equals('a', name:tostring())
    end)

    it("multiple segments", function ()
        local name = Name:new({'a', 'b', 'c'})
        assert.are.equals(3, name:size())
        assert.are.equals('a.b.c', name:tostring())
    end)
end)

describe("Name.capitalize", function()

    it("one word", function ()
        assert.are.equals('One', Name.capitalize('one'))
    end)

    it("multiple words", function ()
        assert.are.equals('CamelCase', Name.capitalize('camelCase'))
    end)
end)

describe("Name.kebab", function()

    it("one segment", function ()
        local name = Name:new({'one'})
        assert.are.equals('one', name:kebab())
    end)

    it("multiple segments. lower by default", function ()
        local name = Name:new({'One', 'tWo', 'THREE'})
        assert.are.equals('one-two-three', name:kebab())
    end)

    it("multiple segments, lower case", function ()
        local name = Name:new({'One', 'tWo', 'THREE'})
        assert.are.equals('ONE-TWO-THREE', name:kebab(true))
    end)

    it("multiple segments, upper case", function ()
        local name = Name:new({'One', 'tWo', 'THREE'})
        assert.are.equals('one-two-three', name:kebab(false))
    end)
end)

describe("Name.snake", function()

    it("one segment", function ()
        local name = Name:new({'one'})
        assert.are.equals('one', name:snake())
    end)

    it("multiple segments", function ()
        local name = Name:new({'one', 'two', 'three'})
        assert.are.equals('one_two_three', name:snake())
    end)

    it("multiple segments, lower case", function ()
        local name = Name:new({'One', 'tWo', 'THREE'})
        assert.are.equals('ONE_TWO_THREE', name:snake(true))
    end)

    it("multiple segments, upper case", function ()
        local name = Name:new({'One', 'tWo', 'THREE'})
        assert.are.equals('one_two_three', name:snake(false))
    end)
end)


describe("Name.pascal", function()

    it("one segment", function ()
        local name = Name:new({'one'})
        assert.are.equals('One', name:pascal())
    end)

    it("multiple segments", function ()
        local name = Name:new({'one', 'two', 'three'})
        assert.are.equals('OneTwoThree', name:pascal())
    end)
end)

describe("Name.camel", function()

    it("one segment", function ()
        local name = Name:new({'one'})
        assert.are.equals('one', name:camel())
    end)

    it("multiple segments", function ()
        local name = Name:new({'one', 'two', 'three'})
        assert.are.equals('oneTwoThree', name:camel())
    end)
end)

describe("Name.parse", function()

    it("nil string returns nil", function ()
        local name = Name.parse(nil)
        assert.is_nil(name)
    end)

    it("empty string", function ()
        local name = Name.parse('')
        assert.are.same({}, name.segments, failed_on(name.original))
    end)

    it("one segment", function ()
        local name = Name.parse('segment')
        assert.are.same({'segment'}, name.segments)
    end)

    it("kebab case", function ()
        local name = Name.parse('first-second-third')
        assert.are.same({'first', 'second', 'third'}, name.segments, failed_on(name.original))
    end)

    it("snake case", function ()
        local name = Name.parse('first_second_third')
        assert.are.same({'first', 'second', 'third'}, name.segments, failed_on(name.original))
    end)

    it("pascal case", function ()
        local name = Name.parse('FirstSecondThird')
        assert.are.same({'first', 'second', 'third'}, name.segments, failed_on(name.original))
    end)

    it("camel case", function ()
        local name = Name.parse('firstSecondThird')
        assert.are.same({'first', 'second', 'third'}, name.segments, failed_on(name.original))
    end)

    it("digit is a part of previous word", function ()
        local name = Name.parse('item2Item3')
        assert.are.same({'item2', 'item3'}, name.segments, failed_on(name.original))
    end)

    it("pascal with acronyms. Word after acronym is capitallized.", function ()
        local name = Name.parse('XMLHttpRequest')
        assert.are.same({'xml', 'http', 'request'}, name.segments, failed_on(name.original))
    end)

    it("non-pascal with acronyms. Word after acronym is NOT capitallized.", function ()
        local name = Name.parse('XMLhttpRequest')
        assert.are.same({'xm', 'lhttp', 'request'}, name.segments, failed_on(name.original))
    end)

    local data = {
        -- Mixed separators
        { 'first-Second_third', { 'first', 'second', 'third' } },
        { 'first_Second-third', { 'first', 'second', 'third' } },
        { 'first_SecondXMLThird-case', {'first', 'second', 'xml', 'third', 'case'} },
        { 'first_SecondXMLthird-case', {'first', 'second', 'xm', 'lthird', 'case'} },
        { 'api-v2_EndpointTest', {'api', 'v2', 'endpoint', 'test'} },
        { 'DB_Connection-Pool', {'db', 'connection', 'pool'} },
        { 'XML-HTTP_Request', {'xml', 'http', 'request'} },

        -- Single and double words
        { 'test', {'test'} },
        { 'Test', {'test'} },
        { 'TEST', {'test'} },
        { 'testTest', {'test', 'test'} },
        { 'TestTest', {'test', 'test'} },
        { 'TEST_TEST', {'test', 'test'} },
        { 'test-test', {'test', 'test'} },

        -- Consecutive capitals and ambiguous cases
        { 'USAMap', {'usa', 'map'} },
        { 'XMLServer', {'xml', 'server'} },
        { 'XMLserver', {'xm', 'lserver'} },
        { 'SecondXMLthird', {'second', 'xm', 'lthird'} },

        -- Empty and separator-only
        { '', {} },
        { '_', {} },
        { '-', {} },
        { '___', {} },
        { '---', {} },

        -- Leading/trailing separators
        { '_private_', {'private'} },
        { '-public-', {'public'} },
        { '__internal__var__', {'internal', 'var'} },

        -- Multiple consecutive separators
        { 'test__name', {'test', 'name'} },
        { 'test--name', {'test', 'name'} },
        { 'test___name---here', {'test', 'name', 'here'} },

        -- All caps variations
        { 'MAX_SIZE', {'max', 'size'} },
        { 'MAX-SIZE', {'max', 'size'} },
        { 'MAXSize', {'max', 'size'} },

        -- Mixed case variations
        { 'MiXeD_CaSe', {'mi', 'xe', 'd', 'ca', 'se'} },
        { 'MiXeD-CaSe', {'mi', 'xe', 'd', 'ca', 'se'} },
        { 'MiXeDCaSe',  {'mi', 'xe', 'd', 'ca', 'se'} },

        -- Long complex examples
        { 'veryLongCamelCaseNameWithManyWords', {'very', 'long', 'camel', 'case', 'name', 'with', 'many', 'words'} },
        { 'HTTP_REST_API_JSON_Endpoint_V2', {'http', 'rest', 'api', 'json', 'endpoint', 'v2'} },
        { 'mysql-database-connection-pool-manager', {'mysql', 'database', 'connection', 'pool', 'manager'} },

        -- File formats and protocols
        { 'jsonSchemaValidator', {'json', 'schema', 'validator'} },
        { 'xmlNamespaceParser', {'xml', 'namespace', 'parser'} },
        { 'yamlConfigLoader', {'yaml', 'config', 'loader'} },
        { 'webSocketHandler', {'web', 'socket', 'handler'} },

        -- Database related
        { 'postgreSQLAdapter', {'postgre', 'sql', 'adapter'} },
        { 'mongoDBCollection', {'mongo', 'db', 'collection'} },
        { 'redisCacheManager', {'redis', 'cache', 'manager'} },
    }
    for _, item in ipairs(data) do
        local input = item[1]
        local expected = item[2]
        local name = Name.parse(input)
        it("stress test", function()
            assert.are.same(expected, name.segments, failed_on(input))
        end)
    end
end)

