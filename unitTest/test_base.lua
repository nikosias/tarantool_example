package.path = package.path .. ";./src/?.lua"
local mock = require('unitTest/mock')
local dump = require('dump')

local t = require('luatest')
local g = t.group('HTTP')

local base       = require('baseHTTP')
dump(mock)
mock.mockBase(base)

local post       = require('requests/post')
local put        = require('requests/put')
local get        = require('requests/get')
local delete     = require('requests/delete')
local randomtime = require('requests/randomtime')

--- Test all request and base
g.test_entryPoint = function()
    t.assert (base)
    t.assert (post)
    t.assert (put)
    t.assert (get)
    t.assert (delete)
    t.assert (randomtime)
end

--- Test all log function whith mock
g.test_logFunction = function()
    local logsType = {
        [base.const.logTypesEntry.info]  = 'logInfo',
        [base.const.logTypesEntry.error] = 'logError',
        [base.const.logTypesEntry.debug] = 'logDebug'
    }
    local text = 'test meassage '
    for _type, _function in pairs(logsType) do
        local textWhithType = text.._type
        base[_function](base, textWhithType)
        local data = mock.getLastLogMessage()
        t.assert_equals(data.entry, _type) 
        t.assert_equals(data.text, string.format(base.message[base.const.logTypes[_type]], base.entry, textWhithType)) 
    end
end
