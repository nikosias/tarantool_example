local const = require('constant')
local json  = require('json')
local clock = require('clock')

--- Родительский класс
-- Отсновные функции и переменные для всех маршрутов
local baseHTTP = {
    message = require('messages'),
    log     = require('log'),
    const   = const,
    entry   = const.entrys.base,
    entrys  = {},
    config = {},
    timeRPS = 0,
    countRPS = 0,
    countWindowRPS = {0,0,0,0,0,0,0,0,0,0},
    --- Основная функция логирования
    -- Проверяем что все параметры верны и записываем сообщение в лог
    -- @self table сслыка на текущий класс
    -- @type string тип логирования одино из значений constant.logTypesEntry
    -- @text string текстовоя запись для помещения в лог
    loging = function (self, type, text)
         if(not const.entrys[self.entry]) then
            return self.log.error(string.format(self.message.log_errorEntryNotFound,tostring(self.entry)))
        end
        if(not const.logTypes[type]) then
            return self.log.error(string.format(self.message.log_errorTypeNotFound,tostring(self.type)))
        end
        return self.log[type](string.format(self.message[const.logTypes[type]], self.entry, text))
    end,
    --- Логирование информационных сообщений
    -- @self table сслыка на текущий класс
    -- @text string текстовоя запись для помещения в лог
    logInfo = function (self, text)
        return self:loging(const.logTypesEntry.info, text)
    end,
    --- Логирование ошибок
    -- @self table сслыка на текущий класс
    -- @text string текстовоя запись для помещения в лог
    logError = function (self, text)
        return self:loging(const.logTypesEntry.error, text)
    end,
    --- Логирование отладочных сообщений
    -- @self table сслыка на текущий класс
    -- @text string текстовоя запись для помещения в лог
    logDebug = function (self, text)
        return self:loging(const.logTypesEntry.debug, text)
    end,
    --- Проверка на превышение RPS
    -- Переопределяемая в зависимости от config.rateLimiting.algoritm
    -- расчитываем можно ли отправить сообщение
    -- @self table сслыка на текущий класс
    -- return bool true - разрешаем; false - отбрасываем
    testRPS = function (self)
        return true
    end,
    --- Проверка на превышение RPS простой алгоритм
    -- расчитываем можно ли отправить сообщение
    -- если у с начала текущей секунды отправлено сообщений меньше чем  config.rateLimiting.rps
    -- то разрешаем обработку сообщения
    -- @self table сслыка на текущий класс
    -- return bool true - разрешаем; false - отбрасываем
    testRPSSimple = function (self)
        local cursecond = math.ceil(clock.realtime())
        if(self.timeRPS ~= cursecond)then
            self.timeRPS = cursecond
            self.countRPS = -1
        end
        self.countRPS = self.countRPS + 1
        return self.countRPS < self.config.rateLimiting.rps
    end,
    --- Проверка на превышение RPS алгоритм скользящее окно
    -- расчитываем можно ли отправить сообщение
    -- берем интервалы в 100 мс и не позваляем в этомпериоде превышать config.rateLimiting.maxWindowRequest 
    -- и сумарно config.rateLimiting.rps за 10 интервалов.
    -- @self table сслыка на текущий класс
    -- return bool true - разрешаем; false - отбрасываем
    testRPSwindow = function (self)
        local cursecond = math.ceil(clock.realtime()*10)
        if self.timeRPS ~= cursecond then
            self.timeRPS = cursecond
            for i = 1, 9 do
                self.countWindowRPS[i]=self.countWindowRPS[i+1]
            end
            self.countWindowRPS[9]=self.countRPS
            self.countRPS = 0
        end
        
        if (self.countRPS > self.config.rateLimiting.maxWindowRequest) then
            return false
        end

        local allRPS = self.countRPS
        for i = 1, 9 do
            allRPS = allRPS + self.countWindowRPS[i]
        end
        if (allRPS>self.config.rateLimiting.rps) then
            return false
        end
        
        self.countRPS = self.countRPS + 1
        return true
    end,
    --- Проверка на валидность пришедшего json
    -- @self table сслыка на текущий класс
    -- @stringJSON string строка содержащая json
    -- return table | false , err - Возвращаем распарсенный json или false если ошибка в этом случаее во втором параметре ошибка 
    parse = function(self, stringJSON)
        local ret
        local ok, err = pcall(function() ret = json.decode(stringJSON) end)
        return ok and ret, err
    end,
    --- Проверка на существование ключа в хранилище
    -- @self table сслыка на текущий класс
    -- @key string ключ
    -- return string | nil найденное значение или nil если значение отсутствует
    testExist = function (self, key)
        local value = self.schema:get(key)
        return value and value[2]
    end,
    --- Сохраняем ключ -> значение в хранилище
    -- @self table сслыка на текущий класс
    -- @key string ключ
    -- @value string | table значение
    -- return table {key, value} | throw error - стандартные ошибки вставки
    setDataInDB = function (self, key, value)
        return self.schema:insert({key, value})
    end,
    --- Обновляем ключ -> значение в хранилище
    -- @self table сслыка на текущий класс
    -- @key string ключ
    -- @value string | table значение
    -- return table {key, value} | throw error - стандартные ошибки вставки
    updateDataInDB = function (self, key, value)
        return self.schema:update(key, {{'=', 2, value}})
    end,
    --- Обновляем ключ -> значение в хранилище
    -- @self table сслыка на текущий класс
    -- @key string ключ
    -- return table {key, value} | throw error - стандартные ошибки вставки
    deleteDataInDB = function (self, key)
        return self.schema:delete(key)
    end,
    --- устанавливаем дб и конфигурацию
    -- @self table сслыка на текущий класс
    -- @schema schema tarantool:space_object ссылка на db
    -- @config table переопределяем базовые настройки
    setSchemaConfig = function (self, schema, config)
        if not schema then
            self:logError(self.message.log_errorSchemaBroken)
            os.exit(1)
        end
        self.schema = schema
        if config then
            self.config = config
        end
        self.testRPS = self[self.const.algoritm[self.config.rateLimiting.algoritm] or self.const.algoritm.simple]
    end,
    --- Связываем класс запроса с базовым
    -- Устанавливаем через metatable связь между классами
    -- Возвращаем заскоупенную функцию для работы с роутингом
    -- @self table базовый клас
    -- @child table родительский клас
    -- return function -> exec
    setParent = function (self, child)
        self.entrys[child.entry] = child
        setmetatable(child, {
            __index = function (_self, key)
                if(self[key])then
                    return self[key]
                end
                return nil
            end
        })
        return function(...) return child:exec(unpack({...})) end
    end,
    --- Заглушка базового клаясса
    -- Возвращаем 404 если в роутине вызван базовый кла а не клас запроса
    -- @self table сслыка на текущий класс
    -- @request table server:route параметр из функции роутинга
    -- return table server:route:render Отформатированный ответ с правильным HTTP_CODE
    execEntry = function(self,request)
        self:logError(self.message.log_requestClassNotFound)
        local ret = request:render({text = '' })
        ret.status = self.const.httpCode.notFound
        return ret
    end,
    --- Форматируем значение для вывода
    -- @self table сслыка на текущий класс
    -- @value string | table значение
    -- return string
    valueToString = function(self, value)
        return type(value)=='table' and json.encode(value) or tostring(value)
    end,
    --- Возвращаем найденное значение
    -- Возвращаем HTTP_CODE 200 и value
    -- @self table сслыка на текущий класс
    -- @request table server:route параметр из функции роутинга
    -- @key string ключ
    -- @value string | table значение
    -- return table server:route:render Отформатированный ответ с правильным HTTP_CODE
    returnValue = function(self, request, key, value)
        value = self:valueToString(value)
        self:logDebug(self.message.log_requestReturnValue:format(request.peer.host,request.peer.port, self.entry, key, value))
        local ret = request:render({text = value })
        ret.status = self.const.httpCode.ok
        return ret
    end, 
    --- Возвращаем ошибку ключ не найден
    -- Возвращаем HTTP_CODE 404 и отформатированную ошибку
    -- @self table сслыка на текущий класс
    -- @request table server:route параметр из функции роутинга
    -- @key string ключ
    -- @value string | table значение
    -- return table server:route:render Отформатированный ответ с правильным HTTP_CODE
    returnKeyNotFound = function(self, request, key)
        local message = self.message.log_returnKeyNotFound:format(request.peer.host,request.peer.port, self.entry, key, body)
        self:logDebug(message)
        local ret = request:render({text = message })
        ret.status = self.const.httpCode.notFound
        return ret
    end, 
    --- Возвращаем ошибку ключ уже создан
    -- Возвращаем HTTP_CODE 409 и отформатированную ошибку
    -- @self table сслыка на текущий класс
    -- @request table server:route параметр из функции роутинга
    -- @key string ключ
    -- return table server:route:render Отформатированный ответ с правильным HTTP_CODE
    returnKeyExist = function(self, request, key)
        local message = self.message.log_errorKeyExist:format(request.peer.host,request.peer.port, self.entry, key)
        self:logError(message)
        local ret = request:render({text = message})
        ret.status = self.const.httpCode.conflict
        return ret
    end, 
    --- Возвращаем ошибку неправильный запрос
    -- Возвращаем HTTP_CODE 400 и отформатированную ошибку
    -- @self table сслыка на текущий класс
    -- @request table server:route параметр из функции роутинга
    -- @value string | table значение
    -- return table server:route:render Отформатированный ответ с правильным HTTP_CODE
    returnErrorBodyParse = function(self, request, value)
        value = self:valueToString(value)
        local message = self.message.log_errorBodyParse:format(request.peer.host,request.peer.port, self.entry, value)
        self:logError(message)
        local ret = request:render({text = message})
        ret.status = self.const.httpCode.badRequest
        return ret
    end,
    --- Возвращаем ошибку не задан ключ в запросе
    -- Возвращаем HTTP_CODE 400 и отформатированную ошибку
    -- @self table сслыка на текущий класс
    -- @request table server:route параметр из функции роутинга
    -- return table server:route:render Отформатированный ответ с правильным HTTP_CODE
    returnErrorKeyNotInRequest = function(self, request)
        local message = self.message.log_errorKeyNotInRequest:format(request.peer.host,request.peer.port, self.entry)
        self:logError(message)
        local ret = request:render({text = message})
        ret.status = self.const.httpCode.badRequest
        return ret
    end,
    --- Базовая функция вызываемая из роутинга
    -- Проверяем что можно парсить данные
    -- проверяем коректность входных параметров
    -- если все хорошо вызываем execEntry текущего класа роутинга
    -- @self table сслыка на текущий класс
    -- @request table server:route параметр из функции роутинга
    -- return table server:route:render Отформатированный ответ с правильным HTTP_CODE
    exec = function (self, request)
        local key     = false
        local keyPost = false
        local value   = false

        pcall(function() key     = request:stash('key') end)
        pcall(function() keyPost = request:param('key') end)
        pcall(function() value   = request:param('value') end)

        if not (key or keyPost) then
            return self:returnErrorKeyNotInRequest(request)
        end
        
        if (self:testRPS()) then
            return self:execEntry(request, key or keyPost, value)
        end

        value = self:valueToString(body)
        local message = self.message.log_errorManyRPS:format(request.peer.host,request.peer.port, self.entry, key, value)
        self:logError(message)
        local ret = request:render({text = message})
        ret.status = self.const.httpCode.tooManyRequests
        return ret
    end
}
return baseHTTP