local baseHTTP = require("baseHTTP")
local json = require('json')

--- Класс роутинга POST запроса
local post = {
    entry = baseHTTP.const.entrys.post,
    --- Функция вызываемая из базового класса
    -- Поведение при вызове метода POST 
    -- POST /kv body: {key: "test", "value": {SOME ARBITRARY JSON}}  - внести в базу по ключу key значение value
    -- POST возвращает 409 если ключ уже существует,
    -- POST возвращают 400 если боди некорректное
    -- @self table сслыка на текущий класс
    -- @key string ключ
    -- @value string значение
    -- @request table server:route параметр из функции роутинга
    -- return table server:route:render Отформатированный ответ с правильным HTTP_CODE
    execEntry = function (self, request, key, value)
        local val, err = false, nil
        val, err = type(value)=='table' and value or self:parse(value)
        if not val then
            return self:returnErrorBodyParse(request, value, err)
        end
        local curValue = self:testExist(key)
        if curValue then
            return self:returnKeyExist(request, key)
        end
        local value = json.encode(val)
        return self:returnValue(request, key, self:setDataInDB(key, value)[2])
    end
}

return baseHTTP:setParent(post)