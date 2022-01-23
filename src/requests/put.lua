local baseHTTP = require("baseHTTP")
local put = {
    entry = baseHTTP.const.entrys.put,
    execEntry = function (self, key, value)
        local curValue = self:testExist(key)
        if(not curValue) then
            self:error(self.message.log_errorKeyNotFound:format(key)
            return
        end
        self:logInfo('POST', message)
        return true
    end
}
local baseMeta = getmetatable(baseHTTP)

setmetatable(put, baseMeta)
return put