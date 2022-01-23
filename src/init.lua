local config = require('config')
local baseHTTP = require('baseHTTP')

--- Возвращаем ошибку 404 и текст путь не найден
-- @request table server:route параметр из функции роутинга
-- return table server:route:render Отформатированный ответ с правильным HTTP_CODE
local notFound = function(request)
    local ret = request:render({text = 'Not found: '..request.path })
    ret.status = 404
    return ret
end

box.cfg{
   listen = 3301,
   log = config and config.logFile,
}
math.randomseed(os.time())
if not box.space.apiDB then
    box.once('init', function()
        local schema = box.schema.space.create('apiDB')
        schema:format({
            {name = 'key',   type = 'string'},
            {name = 'value', type = 'string'},
        })
        schema:create_index('primary', {
            type = 'hash',
            parts = {{field=1, type='string'}}
        })
        
    end)
end

baseHTTP:setSchemaConfig(box.space.apiDB, config)

local server = require('http.server').new(config.addr, config.port)
server:route({path = '/kv',      method = 'POST'  }, require('requests/post'))
server:route({path = '/kv/:key', method = 'GET'   }, require('requests/get'))
server:route({path = '/kv/:key', method = 'PUT'   }, require('requests/put'))
server:route({path = '/kv/:key', method = 'DELETE'}, require('requests/delete'))
server:route({path = '/randomtime/:key' }          , require('requests/randomtime'))
server:route({path = '/' , file='index.html'})
server:route({path = '/*whatever'}, notFound)
server:start()