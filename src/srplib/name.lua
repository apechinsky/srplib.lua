--
-- Name conversion.
--
-- Converts between different naming schemes.
--
-- Parses an arbitrary name and converts it to different naming schemes:
-- * kebab-case
-- * KEBAB-CASE
-- * snake_case
-- * SNAKE_CASE
-- * PascalCase
-- * camelCase
-- * etc.
--

local Name = {}

---
--- Creates name with list of segments
---
--- @param segments list of segments
---
function Name:new(segments)
    self.__index = self
    local instance = setmetatable({}, self)

    instance.segments = segments

    return instance
end

---
--- Creates name from the given string
---
--- Word boundaries:
--- * '-', '_'
--- * lower-to-upper case letter (camelCase -> camel case)
--- * acronym - next word boundary (XMLServer -> xml server, XMLserver -> xm lserver)
--- * letter-digit boundary (version1Alpha -> version1 alpha)
---
--- Recognized words are saved in lower case.
---
--- @param name string to parse
--- @return Name instance or nil if input is nil
---
function Name.parse(name)
    if name == nil then
        return nil
    end

    local segments = {}

    local normalized = name;

    -- '_' and '_' word boundary (kebab-case and snake_case)
    normalized = normalized:gsub("[%-_]", " ")

    -- lower-to-upper word boundary (camelCase -> camel Case)
    normalized = normalized:gsub("(%l)(%u)", "%1 %2")

    -- acronym - next word boundary (XMLServer -> XML Server, XMLserver -> XM Lserver)
    normalized = normalized:gsub("(%u)(%u%l)", "%1 %2")

    -- letter-digit word boundary (version1Alpha -> version1 Alpha)
    normalized = normalized:gsub("(%d)([%u%l])", "%1 %2")

    for word in normalized:gmatch("%S+") do
        table.insert(segments, word:lower())
    end

    local instance = Name:new(segments)
    instance.original = name

    return instance
end

---
--- Return number of segments in name
---
function Name:size()
    return #self.segments
end

---
--- Returns name in kebab-case
---
--- @param upper boolean result in uppper case (default: false)
---  true - convert to uppercase
---  false - convert to lower case
---
function Name:kebab(upper)
    local converter = upper and string.upper or string.lower
    return table.concat(
        Name.convert(self.segments, converter),
        "-")
end

---
--- Returns name in snake_case
---
--- @param upper boolean result in uppper case (default: false)
---  true - convert to uppercase
---  false - convert to lower case
---
function Name:snake(upper)
    local converter = upper and string.upper or string.lower
    return table.concat(
        Name.convert(self.segments, converter),
        "_")
end

---
--- Returns name in PascalCase
---
function Name:pascal()
    return table.concat(
        Name.convert(self.segments, Name.capitalize),
        "")
end

---
--- @return string name in camelCase
---
function Name:camel()
    local result = self:pascal()
    return result:sub(1,1):lower() .. result:sub(2)
end

---
--- @return string a string representation of the name
---
function Name:tostring()
    return table.concat(self.segments, '.')
end

---
--- Capitalize given string
---
--- @param string string
--- @return string letter to upper case, other letters as is
---
function Name.capitalize(string)
    return string:sub(1,1):upper() .. string:sub(2)
end

---
--- Uncapitalize given string
---
--- @param string string an arbitrary string
--- @return string first latter in lower case + other letters as is
---
function Name.uncapitalize(string)
    return string:sub(1,1):lower() .. string:sub(2)
end

---
--- Convert all strings in the list using the given converter function
---
--- @param strings table of strings
--- @param converter function to convert string
--- @return table of converted strings
---
function Name.convert(strings, converter)
    local result = {}

    for _, value in pairs(strings) do
        table.insert(result, converter(value))
    end

    return result
end

return Name


