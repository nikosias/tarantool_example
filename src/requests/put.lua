local baseHTTP = require("baseHTTP")
local dump  = require('dump')

--- Класс роутинга PUT запроса
local put = {
    entry = baseHTTP.const.entrys.get,
    --- Функция вызываемая из базового класса
    -- Поведение при вызове метода PUT 
    -- PUT kv/{id} - обновить данные в ключе
    -- PUT возвращают 400 если боди некорректное
    -- PUT возвращает 404 если такого ключа нет
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
        return self:returnValue(request, key, self:updateDataInDB(key, self:valueToString(value))[2])
    end
}
return baseHTTP:setParent(put)