local baseHTTP = require("../baseHTTP")
local delete = {
    entry = baseHTTP.const.entrys.delete,
    execEntry = function (key, value)
        if(self:testExist(key) then
            self:error(self.message.log_errorKeyNotFound:format(key))
            return
        end
        self:logInfo(self.const.logTypes.info, message)
        return true
    end
}
local baseMeta = getmetatable(baseHTTP)
baseMeta['__index'] = function (self, key)
    if(baseHTTP[key])then
        return baseHTTP[key]
    end
end
setmetatable(delete, baseMeta)
return delete