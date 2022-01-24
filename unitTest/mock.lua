local config = {
    logFile = nil,--'tarantool.log',
    rateLimiting = {
        rps = 10,
        maxDelay = 0.1,
        algoritm = 'simple',  -- simple , window
    }
}
local logArchive = {}
local baseHTTP = false
local log = function (entry, text)
    logArchive[#logArchive+1]= { entry = entry,  text = text}
end
local logTable={}
setmetatable(logTable, {
    __index  = function (_self, entry)
        return function(text)
            log( entry, text)
        end
    end
})
local schema = {
    fakeDB = {},
    get = function(self, key)
        return {key, self.fakeDB[key]}
    end,
    insert = function(self, data)
        self.fakeDB[data[1]] = data[2]
        return {data[1], self.fakeDB[data[1]]}
    end,
    update = function(self, key, value)
        self.fakeDB[key] = value[1][3]
        return {key, self.fakeDB[key]}
    end,
    delete = function(self, key)
        local value = self.fakeDB[key]
        self.fakeDB[key] = nil
        return {key, value}
    end
}

--- Переопределяем основные функции
local function mockBase(baseHttp)
    baseHTTP = baseHttp
    baseHttp.log=logTable
    baseHTTP:setSchemaConfig(schema, config)
end

--- Просмотреть последнюю запись в логе
-- return table последняя запись в таблице логов
local function getLastLogMessage()
    return logArchive[#logArchive]
end


--- Сформировать фейковый http.router.request
-- @key string ключ - для stash
-- @key string ключ - для param
-- @value string | table значение
-- return table http.router.request 
local function getRequest(key, postKey, value)
    local body = {
        data={
            stash = {key = key},
            param = {key = postKey, value = value}
        },
        peer = {
            host = '999.999.999.999',
            port = '7777777'
        },
        stash = function(self, id)
            return self.data.stash[id]
        end,
        param = function(self, id)
            return self.data.param[id]
        end,
        render = function(self,data)
            self.answer = data
            return self
        end
    }
    return body
end
return {
    mockBase = mockBase,
    getLastLogMessage = getLastLogMessage,
    getRequest = getRequest,
}