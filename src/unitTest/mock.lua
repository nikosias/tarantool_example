local dump = require('dump')
config = {
    logFile = nil,--'tarantool.log',
    rateLimiting = {
        rps = 10,
        maxDelay = 0.1,
        algoritm = 'simple',  -- simple , window
    }
}
local logArchive = {}
local baseHTTP = false
local log = function (entry, text)
    logArchive[#logArchive+1]= { entry = entry,  text = text}
end
local logTable={}
setmetatable(logTable, {
    __index  = function (_self, entry)
        return function(text)
            log( entry, text)
        end
    end
})
function mockLog(baseHttp)
    baseHTTP = baseHTTP
    baseHttp.log=logTable
end
function getLastLogMessage()
    return logArchive[#logArchive]
end
