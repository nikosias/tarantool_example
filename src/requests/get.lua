local baseHTTP = require("baseHTTP")
--- Класс роутинга GET запроса
local get = {
    entry = baseHTTP.const.entrys.get,
    --- Функция вызываемая из базового класса
    -- Поведение при вызове метода GET 
    -- GET kv/{id} - return существующий объект в базе
    -- GET возвращает 404 если такого ключа нет
    -- @self table сслыка на текущий класс
    -- @key string ключ
    -- @value string значение
    -- @request table server:route параметр из функции роутинга
    -- return table server:route:render Отформатированный ответ с правильным HTTP_CODE
    execEntry = function (self, request, key, value)
        local curValue = self:testExist(key)
        if not curValue then
            return self:returnKeyNotFound(request, key)
        end
        return self:returnValue(request, key, curValue)
    end
}
return baseHTTP:setParent(get)