local baseHTTP = require("baseHTTP")
local randomtime = {
    entry = baseHTTP.const.entrys.randomtime,
    execEntry = function (key, value)
        if self:testExist(key) then
            self:error(self.message.log_errorKeyExist:format(key))
            return
        end
        self:logInfo('POST', message)
        return true
    end
}

return baseHTTP:setParent(randomtime)