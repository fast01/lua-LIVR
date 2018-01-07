
--
-- lua-LIVR : <http://fperrad.github.com/lua-LIVR/>
--

local tonumber = tonumber
local tostring = tostring
local type = type
local _ENV = nil

local function valid_email (s)
    -- TODO
    if s:match' ' then
        return
    end
    local pos = s:match'@()'
    if not pos then
        return
    end
    if s:match('[@_]', pos) then
        return
    end
    return true
end

local schemes = { http = true, https = true }
local function valid_url (s)
    -- TODO
    local scheme = s:match"^(%w+)://"
    if schemes[scheme and scheme:lower()] then
        local pos = s:match'?()'
        local path = s:sub(1, tonumber(pos) or #s)
        if path:match'_' then
            return
        end
        return true
    end
end

local function leap_year (year)
    return ((year % 4) == 0 and (year % 100) ~= 0) or (year % 400) == 0
end
local months = { 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
local function valid_date (s)
    local year, month, day = s:match"^(%d%d%d%d)%-(%d%d)%-(%d%d)$"
    year = tonumber(year)
    month = tonumber(month)
    day = tonumber(day)
    if year and month and day then
        if month >= 1 and month <= 12 and day >= 1 and day <= months[month] then
            if month ~= 2 or day ~= 29 or leap_year(year) then
                return true
            end
        end
    end
end

return {
    email = function ()
        return function (value)
            if value ~= nil and value ~= '' then
                if type(value) ~= 'string' then
                    return value, 'FORMAT_ERROR'
                end
                if not valid_email(value) then
                    return value, 'WRONG_EMAIL'
                end
            end
            return value
        end
    end,

    equal_to_field = function (_, field)
        return function (value, params)
            if value ~= nil and value ~= '' then
                if type(value) ~= 'string' and type(value) ~= 'number' and type(value) ~= 'boolean' then
                    return value, 'FORMAT_ERROR'
                end
                if tostring(value) ~= tostring(params[field]) then
                    return value, 'FIELDS_NOT_EQUAL'
                end
            end
            return value
        end
    end,

    url = function ()
        return function (value)
            if value ~= nil and value ~= '' then
                if type(value) ~= 'string' then
                    return value, 'FORMAT_ERROR'
                end
                if not valid_url(value) then
                    return value, 'WRONG_URL'
                end
            end
            return value
        end
    end,

    iso_date = function ()
        return function (value)
            if value ~= nil and value ~= '' then
                if type(value) ~= 'string' then
                    return value, 'FORMAT_ERROR'
                end
                if not valid_date(value) then
                    return value, 'WRONG_DATE'
                end
            end
            return value
        end
    end,
}

--
-- Copyright (c) 2018 Francois Perrad
--
-- This library is licensed under the terms of the MIT/X11 license,
-- like Lua itself.
--
