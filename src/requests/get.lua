local baseHTTP = require("baseHTTP")
local dump = require('dump')
local get = {
    entry = baseHTTP.const.entrys.get,
    execEntry = function (self, request, key, body)
        dump({request,self,key, body})
        local curValue = self:testExist(key)
        if not curValue then
            return self:returnKeyNotFound()
        end
        return self:returnValue(curValue)
    end
}

return baseHTTP:setParent(get)