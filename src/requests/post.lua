local baseHTTP = require("baseHTTP")
local dump  = require('dump')

--- Класс роутинга POST запроса
local post = {
    entry = baseHTTP.const.entrys.post,
    --- Функция вызываемая из базового класса
    -- Поведение при вызове метода POST 
    -- POST /kv body: {key: "test", "value": {SOME ARBITRARY JSON}} 
    -- POST возвращает 409 если ключ уже существует,
    -- POST возвращают 400 если боди некорректное
    -- @self table сслыка на текущий класс
    -- @key string ключ
    -- @value string значение
    -- @request table server:route параметр из функции роутинга
    -- return table server:route:render Отформатированный ответ с правильным HTTP_CODE
    execEntry = function (self, request, key, value)
        dump({request=request})
        local ok, ret = self:parse(value)
        dump(key, value)
        if(not ok or not ret['key']  or not ret['value']) then
            return self:returnErrorBodyParse(request, value)
        end

        key   = ret['key']
        value = ret['value']

        local curValue = self:testExist(key)
        if curValue then
            return self:returnKeyExist()
        end
        
        local value = josn.encode(value)
        self:setData(key, josn.encode(value))
        return self:returnValue(value)
    end
}

return baseHTTP:setParent(post)