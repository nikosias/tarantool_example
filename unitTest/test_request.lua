package.path = package.path .. ";./src/?.lua"
local mock=require('unitTest/mock')
local dump  = require('dump')

local t = require('luatest')
local g = t.group('request')

local base       = require('baseHTTP')
mock.mockBase(base)
local post       = require('requests/post')
local put        = require('requests/put')
local get        = require('requests/get')
local delete     = require('requests/delete')
local randomtime = require('requests/randomtime')

--- Test key not found
g.test_keyNotFound = function()
    local request = mock.getRequest()
    local answ = post(request)

    t.assert_equals(answ.status, 400, 'test_keyNotFound status 400') 
    t.assert_equals(answ.answer.text, 'Error. Request from 999.999.999.999:7777777 to post. Field: key not found', 'test_keyNotFound status 400') 
end
    --- Test post request
g.test_post = function()
    local request = mock.getRequest(nil,'key','"value"')
    local answ = post(request)
    t.assert_equals(answ.status, 200, 'test_post status 200') 
    t.assert_equals(answ.answer.text, '"value"', 'test_post status 200 texst success') 

    request = mock.getRequest(nil, 'key','"value"')
    answ = post(request)
    t.assert_equals(answ.status, 409, 'test_post status 409') 
    t.assert_equals(answ.answer.text, 'Error. Request from 999.999.999.999:7777777 to post. key: key alredy exist', 'test_post status 409 texst success') 

    request = mock.getRequest(nil, 'key1','value"')
    answ = post(request)
    t.assert_equals(answ.status, 400, 'test_post status 400') 
    t.assert_equals(answ.answer.text, 'Error. Request from 999.999.999.999:7777777 to post. parse: wrong json: value\"', 'test_post status 400 texst success') 
end

--- Test get request
g.test_get = function()
    local request = mock.getRequest(nil,'get','"value"')
    local answ = post(request)

    request = mock.getRequest('get')
    answ = get(request)
    t.assert_equals(answ.status, 200, 'test_get status 200') 
    t.assert_equals(answ.answer.text, "\"value\"", 'test_get status 200 texst success') 

    request = mock.getRequest('get1')
    answ = get(request)
    t.assert_equals(answ.status, 404, 'test_get status 404') 
    t.assert_equals(answ.answer.text,"Request from 999.999.999.999:7777777 to get. Key: get1 not found.", 'test_get status 404 texst success') 
end

--- Test put request
g.test_put = function()
    local request = mock.getRequest('put',nil,'"value"')
    local answ = post(request)

    request = mock.getRequest('put',nil,'"value1"')
    answ = put(request)
    t.assert_equals(answ.status, 200, 'test_put status 200') 
    t.assert_equals(answ.answer.text, "\"value1\"", 'test_put status 200 texst success') 

    request = mock.getRequest('put1',nil,'"value1"')
    answ = put(request)
    t.assert_equals(answ.status, 404, 'test_put status 404') 
    t.assert_equals(answ.answer.text,"Request from 999.999.999.999:7777777 to put. Key: put1 not found.", 'test_put status 404 texst success') 

    request = mock.getRequest('put', nil,'value"')
    answ = put(request)
    t.assert_equals(answ.status, 400, 'test_put status 400') 
    t.assert_equals(answ.answer.text, 'Error. Request from 999.999.999.999:7777777 to put. parse: wrong json: value\"', 'test_put status 400 texst success') 
end

--- Test delete request
g.test_delete = function()
    local request = mock.getRequest(nil,'delete','"value"')
    local answ = post(request)

    request = mock.getRequest('delete')
    answ = delete(request)
    t.assert_equals(answ.status, 200, 'test_delete status 200') 
    t.assert_equals(answ.answer.text, "\"value\"", 'test_delete status 200 texst success') 

    request = mock.getRequest('delete')
    answ = delete(request)
    t.assert_equals(answ.status, 404, 'test_delete status 404') 
    t.assert_equals(answ.answer.text,"Request from 999.999.999.999:7777777 to delete. Key: delete not found.", 'test_delete status 404 texst success') 
end

--- Test get randomtime
g.test_randomtime = function()
    local request = mock.getRequest(nil,'randomtime','"value"')
    local answ = post(request)

    request = mock.getRequest('randomtime')
    answ = randomtime(request)
    t.assert_equals(answ.status, 200, 'test_randomtime status 200') 
    t.assert_equals(answ.answer.text, "\"value\"", 'test_randomtime status 200 texst success') 

    request = mock.getRequest('randomtime1')
    answ = randomtime(request)
    t.assert_equals(answ.status, 404, 'test_randomtime status 404') 
    t.assert_equals(answ.answer.text,"Request from 999.999.999.999:7777777 to randomtime. Key: randomtime1 not found.", 'test_randomtime status 404 texst success') 
end
