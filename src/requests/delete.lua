local baseHTTP = require("baseHTTP")
--- Класс роутинга DELETE  запроса
local delete = {
    entry = baseHTTP.const.entrys.get,
    --- Функция вызываемая из базового класса
    -- Поведение при вызове метода DELETE 
    -- DELETE kv/{id} - удалить данные по ключу
    -- DELETE возвращает 404 если такого ключа нет
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
        local delData = self:deleteDataInDB(key)
        if(not delData)then
            return self:returnKeyNotFound(request, key)
        end
        return self:returnValue(request, key, delData[2])
    end
}
return baseHTTP:setParent(delete)