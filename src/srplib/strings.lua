local strings = {}

--
-- Checks if string has specified suffix
--
-- @param str string to test
-- @param suffix suffix
--
function strings.has_suffix(str, suffix)
    if str == nil then
        return suffix == nil
    end
    return string.sub(str, #str - #suffix + 1, #str) == suffix
end

--
-- Checks if string has specified prefix
--
-- @param str string to test
-- @param suffix suffix affix
--
function strings.has_prefix(str, prefix)
    if str == nil then
        return prefix == nil
    end
    return string.sub(str, 1, #prefix) == prefix
end

function strings.trim_right(str, substr)
    -- assert(substr ~= nil, "Trim char must not be nil or empty")

    if str == nil or substr == nil or substr == '' then
        return str
    end

    local result = str
    while strings.has_suffix(result, substr) do
        result = string.sub(result, 1, #result - #substr)
    end
    return result
end

function strings.trim_left(str, substr)
    if str == nil or substr == nil or substr == '' then
        return str
    end

    local result = str
    while strings.has_prefix(result, substr) do
        result = string.sub(result, #substr + 1)
    end
    return result
end


return strings
